# Ignite 🔥

A Discord bot for managing Steam game servers with slash commands.

## Features

- 🎮 **Start/Stop Game Servers** - Control your Steam game server via Discord
- 📊 **Server Status** - Query Steam server status using A2S protocol
- 🔒 **Role-Based Access Control** - Restrict commands by Discord roles and servers
- ⚙️ **Easy Configuration** - Interactive CLI setup
- 🔄 **Multi-Platform** - Works on Linux, macOS, and Windows

## Quick Start

### Prerequisites

- Rust 1.70+ ([install here](https://rustup.rs/))
- A Discord bot token ([create one](https://discord.com/developers/applications))
- A Steam game server (optional, for testing)

### Installation

```bash
git clone https://github.com/mbround18/ignite.git
cd ignite
cargo build --release
```

### Setup (30 seconds)

```bash
# Initialize configuration
cargo run -- init

# Create .env file with your Discord token
cp .env.example .env
# Edit .env and add your DISCORD_TOKEN

# Start the bot
cargo run -- start
```

That's it! The bot will register commands with Discord and be ready to use.

## Commands

- `/status` - Check server status (everyone can use)
- `/start` - Start the game server (admin only, if configured)
- `/stop` - Stop the game server (admin only, if configured)

## Configuration

Run `cargo run -- init` to create `~/.ignition/ignition.json` interactively:

```json
{
  "working_dir": "/path/to/server",
  "start_command": "./start.sh",
  "stop_command": "./stop.sh",
  "admin_role_ids": [123456789],
  "server_ids": [987654321],
  "host": "127.0.0.1",
  "port": 27015
}
```

**Config Search Locations:**

1. `./ignition.json` (current directory)
2. `./config/ignition.json` (config subdirectory)
3. `~/.ignition/ignition.json` (home directory)
4. Custom: `ignite --config /path/to/ignition.json start`

**Access Control:**

- Empty `admin_role_ids` = everyone can use start/stop
- Empty `server_ids` = works in all servers
- Both empty = no restrictions (public bot)

## Getting Discord IDs

1. Enable Developer Mode (Settings → Advanced → Developer Mode)
2. Right-click role/server → Copy ID

## Development

```bash
# Build
cargo build

# Test
cargo test

# Format & lint
cargo fmt
cargo clippy

# Run
cargo run -- init
cargo run -- start
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed development guide.

## Releases

Binaries for all platforms are available on the [Releases page](https://github.com/mbround18/ignite/releases).

```bash
# Create a release
git tag v1.0.0
git push origin v1.0.0
# GitHub Actions will build and release automatically
```

## Troubleshooting

**Bot doesn't respond to commands?**

- Wait up to 1 hour for slash command registration
- Verify bot has "Use Application Commands" permission

**Permission denied?**

- Check role/server IDs are correct
- Verify user has the role assigned

**Steam query offline?**

- Ensure server is running
- Check host:port is correct
- Verify firewall allows UDP traffic on query port

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details

## Support

- 📖 [Full Documentation](docs/)
- 🐛 [Report Issues](https://github.com/mbround18/ignite/issues)
- 💬 [Discussions](https://github.com/mbround18/ignite/discussions)

---

Made with ❤️ by [mbround18](https://github.com/mbround18)
