# Contributing to Ignite

Thanks for your interest in contributing! This guide will help you get started.

## Getting Started

### Setup

1. **Clone and build:**

   ```bash
   git clone https://github.com/mbround18/ignite.git
   cd ignite
   cargo build
   ```

2. **Install tools:**

   ```bash
   rustup component add rustfmt clippy
   ```

3. **Create .env for testing:**
   ```bash
   cp .env.example .env
   # Add your Discord token for local testing
   ```

## Development Workflow

### Before you code

```bash
# Create a feature branch
git checkout -b feature/my-feature
```

### While coding

```bash
# Build frequently
cargo build

# Run tests
cargo test

# Check code quality
cargo clippy -- -D warnings
cargo fmt -- --check
```

### Before pushing

```bash
# Final checks
cargo test --verbose
cargo clippy -- -D warnings
cargo fmt

# If all pass, commit
git add .
git commit -m "Add: description of change"
git push origin feature/my-feature
```

### Create a PR

1. Go to GitHub and create a Pull Request
2. Describe what you changed and why
3. Wait for CI checks to pass
4. Request review if needed
5. Merge when approved

## Code Style

- Follow Rust conventions (clippy will tell you)
- Use meaningful variable names
- Add doc comments for public items:

```rust
/// Query Steam server status using A2S_INFO protocol
pub async fn query_server_status(host: &str, port: u16) -> Result<ServerStatus> {
    // ...
}
```

## Good Commit Messages

- `Add: new feature description`
- `Fix: bug description`
- `Refactor: what changed`
- `Docs: documentation updates`
- `Test: test additions`

## Project Structure

```
ignite/
├── src/
│   ├── main.rs       # CLI entry point (init, start, stop)
│   ├── config.rs     # Configuration management
│   ├── bot.rs        # Discord bot commands
│   └── steam.rs      # Steam server queries
├── .github/workflows/
│   ├── test.yml      # Tests on push/PR
│   └── release.yml   # Release on git tag
└── Cargo.toml        # Dependencies
```

## Common Tasks

### Add a new Discord command

1. Add to `src/bot.rs`:

```rust
#[poise::command(slash_command)]
async fn mycommand(ctx: Context<'_>) -> Result<(), Error> {
    ctx.say("Response").await?;
    Ok(())
}
```

2. Register in `run()` function:

```rust
commands: vec![start(), stop(), status(), mycommand()],
```

### Add a config field

1. Update `Config` struct in `src/config.rs`
2. Add prompt in `init_command()` in `src/main.rs`
3. Update `ignition.json.example`

### Update dependencies

```bash
cargo update
cargo outdated
```

## Testing

```bash
# Run all tests
cargo test

# Run with output
cargo test -- --nocapture

# Run specific test
cargo test my_test
```

## Debugging

```bash
# Enable debug output
RUST_BACKTRACE=1 cargo run -- start

# Print variables
dbg!(variable);
println!("Debug: {:?}", variable);
```

## CI/CD

All PRs require:

- ✅ Tests pass
- ✅ Clippy clean (no warnings)
- ✅ Code formatted
- ✅ Builds on Linux, macOS, Windows

Run locally before pushing:

```bash
cargo test && cargo clippy -- -D warnings && cargo fmt -- --check
```

## Releases

To release a new version:

1. Update version in `Cargo.toml`
2. Create a git tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions will:
   - Build for all platforms
   - Create a release
   - Upload binaries

No manual steps needed!

## Questions?

- Check existing [issues](https://github.com/mbround18/ignite/issues)
- Start a [discussion](https://github.com/mbround18/ignite/discussions)
- Read [docs/](docs/) for more details

## Code of Conduct

Be respectful and constructive. We welcome everyone!

## License

Your contributions will be licensed under AGPL-3.0 (same as the project).
