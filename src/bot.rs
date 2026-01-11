use crate::config::Config;
use crate::steam;
use anyhow::{Context as _, Result};
use poise::serenity_prelude as serenity;
use std::process::Command as ProcessCommand;
use std::sync::Arc;

// Bot state data
pub struct Data {
    pub config: Arc<Config>,
}

type Error = Box<dyn std::error::Error + Send + Sync>;
type Context<'a> = poise::Context<'a, Data, Error>;

/// Check if user has permission to execute admin commands
async fn check_permissions(ctx: Context<'_>) -> Result<bool, Error> {
    let config = &ctx.data().config;

    // If no restrictions are set, allow everyone
    if config.admin_role_ids.is_empty() && config.server_ids.is_empty() {
        return Ok(true);
    }

    // Check guild restriction
    if !config.server_ids.is_empty() {
        let guild_id = ctx
            .guild_id()
            .ok_or("This command can only be used in a server")?;
        if !config.server_ids.contains(&guild_id.get()) {
            return Ok(false);
        }
    }

    // Check role restriction
    if !config.admin_role_ids.is_empty() {
        let member = ctx
            .author_member()
            .await
            .ok_or("Could not fetch member information")?;

        let has_role = member
            .roles
            .iter()
            .any(|role: &serenity::RoleId| config.admin_role_ids.contains(&role.get()));

        if !has_role {
            return Ok(false);
        }
    }

    Ok(true)
}

/// Start the game server
#[poise::command(slash_command, guild_only)]
async fn start(ctx: Context<'_>) -> Result<(), Error> {
    // Check permissions
    if !check_permissions(ctx).await? {
        ctx.say("❌ You don't have permission to use this command.")
            .await?;
        return Ok(());
    }

    ctx.defer().await?;

    let config = &ctx.data().config;

    // Execute start command
    let output = ProcessCommand::new("sh")
        .arg("-c")
        .arg(&config.start_command)
        .current_dir(&config.working_dir)
        .output()
        .context("Failed to execute start command")?;

    let response = if output.status.success() {
        format!(
            "✅ **Server started successfully!**\n\n```\n{}\n```",
            String::from_utf8_lossy(&output.stdout)
        )
    } else {
        format!(
            "❌ **Failed to start server**\n\n```\n{}\n```",
            String::from_utf8_lossy(&output.stderr)
        )
    };

    ctx.say(response).await?;
    Ok(())
}

/// Stop the game server
#[poise::command(slash_command, guild_only)]
async fn stop(ctx: Context<'_>) -> Result<(), Error> {
    // Check permissions
    if !check_permissions(ctx).await? {
        ctx.say("❌ You don't have permission to use this command.")
            .await?;
        return Ok(());
    }

    ctx.defer().await?;

    let config = &ctx.data().config;

    // Execute stop command
    let output = ProcessCommand::new("sh")
        .arg("-c")
        .arg(&config.stop_command)
        .current_dir(&config.working_dir)
        .output()
        .context("Failed to execute stop command")?;

    let response = if output.status.success() {
        format!(
            "✅ **Server stopped successfully!**\n\n```\n{}\n```",
            String::from_utf8_lossy(&output.stdout)
        )
    } else {
        format!(
            "❌ **Failed to stop server**\n\n```\n{}\n```",
            String::from_utf8_lossy(&output.stderr)
        )
    };

    ctx.say(response).await?;
    Ok(())
}

/// Get the game server status
#[poise::command(slash_command)]
async fn status(ctx: Context<'_>) -> Result<(), Error> {
    ctx.defer().await?;

    let config = &ctx.data().config;

    // Query server status
    match steam::query_server_status(&config.host, config.port).await {
        Ok(status) => {
            ctx.say(status.format()).await?;
        }
        Err(e) => {
            ctx.say(format!("❌ **Failed to query server**\n\n{}", e))
                .await?;
        }
    }

    Ok(())
}

/// Run the Discord bot
pub async fn run(token: String, config: Config) -> Result<()> {
    let framework = poise::Framework::builder()
        .options(poise::FrameworkOptions {
            commands: vec![start(), stop(), status()],
            ..Default::default()
        })
        .setup(|ctx, _ready, framework| {
            Box::pin(async move {
                println!("✅ Bot logged in as {}", _ready.user.name);

                // Register commands globally
                poise::builtins::register_globally(ctx, &framework.options().commands).await?;

                println!("✅ Commands registered globally");

                Ok(Data {
                    config: Arc::new(config),
                })
            })
        })
        .build();

    let intents = serenity::GatewayIntents::non_privileged()
        | serenity::GatewayIntents::GUILDS
        | serenity::GatewayIntents::GUILD_MESSAGES;

    let mut client = serenity::ClientBuilder::new(token, intents)
        .framework(framework)
        .await?;

    println!("🔥 Bot is ready! Press Ctrl+C to stop.");

    client.start().await?;

    Ok(())
}
