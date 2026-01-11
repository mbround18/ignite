mod bot;
mod config;
mod steam;

use anyhow::Result;
use clap::{Parser, Subcommand};
use config::Config;

#[derive(Parser)]
#[command(name = "ignite")]
#[command(about = "Discord bot for managing Steam game servers", long_about = None)]
struct Cli {
    /// Path to config file (overrides default search locations)
    #[arg(short, long, global = true)]
    config: Option<String>,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize the bot configuration
    Init,
    /// Start the Discord bot
    Start,
    /// Stop the Discord bot (placeholder - graceful shutdown needs process management)
    Stop,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize logging
    tracing_subscriber::fmt::init();

    let cli = Cli::parse();

    match cli.command {
        Commands::Init => init_command().await?,
        Commands::Start => start_command(cli.config.as_deref()).await?,
        Commands::Stop => stop_command().await?,
    }

    Ok(())
}

async fn init_command() -> Result<()> {
    use std::io::{self, Write};

    println!("🔥 Ignite Bot Configuration\n");

    // Helper function to prompt for input
    fn prompt(message: &str) -> Result<String> {
        print!("{}", message);
        io::stdout().flush()?;
        let mut input = String::new();
        io::stdin().read_line(&mut input)?;
        Ok(input.trim().to_string())
    }

    // Helper function to parse comma-separated u64 IDs
    fn parse_ids(input: &str) -> Vec<u64> {
        input
            .split(',')
            .filter_map(|s| s.trim().parse::<u64>().ok())
            .collect()
    }

    // Prompt for configuration values
    let working_dir = prompt("Working directory (where server files are located): ")?;
    let start_command = prompt("Start command (e.g., './start.sh' or 'systemctl start server'): ")?;
    let stop_command = prompt("Stop command (e.g., './stop.sh' or 'systemctl stop server'): ")?;

    let admin_input = prompt("Admin role IDs (comma-separated, optional - press Enter to skip): ")?;
    let admin_role_ids = if admin_input.is_empty() {
        Vec::new()
    } else {
        parse_ids(&admin_input)
    };

    let server_input = prompt("Server IDs (comma-separated, optional - press Enter to skip): ")?;
    let server_ids = if server_input.is_empty() {
        Vec::new()
    } else {
        parse_ids(&server_input)
    };

    let host = prompt("Steam server host (default: 127.0.0.1): ")?;
    let host = if host.is_empty() {
        "127.0.0.1".to_string()
    } else {
        host
    };

    let port_str = prompt("Steam server query port (default: 27015): ")?;
    let port = if port_str.is_empty() {
        27015
    } else {
        port_str.parse::<u16>().unwrap_or(27015)
    };

    // Create config
    let config = Config {
        working_dir,
        start_command,
        stop_command,
        admin_role_ids,
        server_ids,
        host,
        port,
    };

    // Save config
    config.save()?;

    println!("\n✅ Configuration complete!");
    println!("\n📝 Next steps:");
    println!("   1. Create a .env file with your DISCORD_TOKEN");
    println!("   2. Run 'cargo run -- start' to start the bot");
    println!("\n💡 The config can also be placed at:");
    println!("   - ./ignition.json (current directory)");
    println!("   - ./config/ignition.json (config subdirectory)");
    println!("   - Use --config flag to specify custom location");

    Ok(())
}

async fn start_command(config_path: Option<&str>) -> Result<()> {
    // Load environment variables
    dotenvy::dotenv().ok();

    // Load config
    let config = Config::load(config_path)?;

    // Get Discord token from environment
    let token = std::env::var("DISCORD_TOKEN").expect(
        "Missing DISCORD_TOKEN environment variable. Create a .env file with your bot token.",
    );

    println!("🚀 Starting Ignite bot...");
    println!("   Working dir: {}", config.working_dir);
    println!("   Steam server: {}:{}", config.host, config.port);

    if !config.admin_role_ids.is_empty() {
        println!("   Admin roles: {:?}", config.admin_role_ids);
    }
    if !config.server_ids.is_empty() {
        println!("   Restricted to servers: {:?}", config.server_ids);
    }

    // Start the bot
    bot::run(token, config).await?;

    Ok(())
}

async fn stop_command() -> Result<()> {
    println!("⚠️  Stop command not yet implemented.");
    println!("    To stop the bot, use Ctrl+C in the terminal where it's running.");
    Ok(())
}
