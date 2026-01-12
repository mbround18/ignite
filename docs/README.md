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

### Install

Use the prebuilt binaries from the latest release.

Linux/macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/mbround18/ignite/main/install.sh | bash
```

Specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/mbround18/ignite/main/install.sh | bash -s -- --version v1.0.0
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/mbround18/ignite/main/install.ps1 | iex
```

Specific version:

```powershell
irm https://raw.githubusercontent.com/mbround18/ignite/main/install.ps1 | iex -ArgumentList "-Version v1.0.0"
```

### Upgrading

To upgrade to the latest version, just re-run the install script:

Linux/macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/mbround18/ignite/main/install.sh | bash
```

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/mbround18/ignite/main/install.ps1 | iex
```

Install a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/mbround18/ignite/main/install.sh | bash -s -- --version vX.Y.Z
```

```powershell
irm https://raw.githubusercontent.com/mbround18/ignite/main/install.ps1 | iex -ArgumentList "-Version vX.Y.Z"
```

### Setup (30 seconds)

```bash
# Initialize configuration
ignite init

# Create .env file with your Discord token
cp .env.example .env
# Edit .env and add your DISCORD_TOKEN

# Start the bot
ignite start
```

That's it! The bot will register commands with Discord and be ready to use.

## Commands

- `/status` - Check server status (everyone can use)
- `/start` - Start the game server (admin only, if configured)
- `/stop` - Stop the game server (admin only, if configured)

## Configuration

Run `cargo run -- init` to create `~/.ignition/ignition.json` interactively.

### Configuration Options

| Field                  | Type             | Required | Default     | Description                                                                                                  |
| ---------------------- | ---------------- | -------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
| `working_dir`          | `string`         | ✅       | -           | Working directory where server files are located                                                             |
| `start_command`        | `string`         | ✅       | -           | Shell command to start the server (e.g., `./start.sh`)                                                       |
| `stop_command`         | `string`         | ✅       | -           | Shell command to stop the server (e.g., `./stop.sh`)                                                         |
| `admin_role_ids`       | `array<u64>`     | ❌       | `[]`        | Discord role IDs that can use start/stop commands. Empty = no restrictions                                   |
| `server_ids`           | `array<u64>`     | ❌       | `[]`        | Discord server IDs where bot can be used. Empty = works in all servers                                       |
| `host`                 | `string`         | ❌       | `127.0.0.1` | Steam server IP address for status queries                                                                   |
| `port`                 | `u16`            | ❌       | `27015`     | Steam server query port (UDP)                                                                                |
| `broadcast_channel_id` | `u64 \| null`    | ❌       | `null`      | Discord channel ID to broadcast join URL when bot starts                                                     |
| `join_address`         | `string \| null` | ❌       | `null`      | Custom join address. Can include `steam://connect/` prefix or just `host:port`. Overrides `host:port` if set |

### Example Configuration

```json
{
  "working_dir": "/path/to/server",
  "start_command": "./start.sh",
  "stop_command": "./stop.sh",
  "admin_role_ids": [123456789],
  "server_ids": [987654321],
  "host": "51.222.244.152",
  "port": 2457,
  "broadcast_channel_id": 1234567890123456789,
  "join_address": "my-server.com:27015"
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

See [CONTRIBUTING.md](CONTRIBUTING.md) for development details.

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
