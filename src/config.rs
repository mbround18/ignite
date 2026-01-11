use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub working_dir: String,
    pub start_command: String,
    pub stop_command: String,
    #[serde(default)]
    pub admin_role_ids: Vec<u64>,
    #[serde(default)]
    pub server_ids: Vec<u64>,
    #[serde(default = "default_host")]
    pub host: String,
    #[serde(default = "default_port")]
    pub port: u16,
    #[serde(default)]
    pub broadcast_channel_id: Option<u64>,
    #[serde(default)]
    pub join_address: Option<String>,
}

fn default_host() -> String {
    "127.0.0.1".to_string()
}

fn default_port() -> u16 {
    27015
}

impl Config {
    /// Get the config directory path (~/.ignition/)
    pub fn config_dir() -> Result<PathBuf> {
        let home = std::env::var("HOME").context("HOME environment variable not set")?;
        Ok(PathBuf::from(home).join(".ignition"))
    }

    /// Get the default config file path (~/.ignition/ignition.json)
    pub fn default_config_path() -> Result<PathBuf> {
        Ok(Self::config_dir()?.join("ignition.json"))
    }

    /// Find config file in multiple locations
    /// Search order:
    /// 1. ./ignition.json (current directory)
    /// 2. ./config/ignition.json (config subdirectory)
    /// 3. ~/.ignition/ignition.json (home directory)
    pub fn find_config_path() -> Result<PathBuf> {
        let candidates = vec![
            PathBuf::from("./ignition.json"),
            PathBuf::from("./config/ignition.json"),
            Self::default_config_path()?,
        ];

        for path in candidates {
            if path.exists() {
                return Ok(path);
            }
        }

        // If none found, return default path for error message
        Self::default_config_path()
    }

    /// Load config from specified path or search default locations
    pub fn load(custom_path: Option<&str>) -> Result<Self> {
        let path = if let Some(custom) = custom_path {
            // Use custom path if provided
            let p = PathBuf::from(custom);
            if !p.exists() {
                anyhow::bail!("Config file not found at specified path: {}", p.display());
            }
            p
        } else {
            // Search for config in default locations
            let found = Self::find_config_path()?;
            if !found.exists() {
                anyhow::bail!(
                    "Config file not found. Searched locations:\n\
                    - ./ignition.json\n\
                    - ./config/ignition.json\n\
                    - ~/.ignition/ignition.json\n\n\
                    Run 'ignite init' to create a config file."
                );
            }
            found
        };

        let contents = fs::read_to_string(&path)
            .with_context(|| format!("Failed to read config file: {}", path.display()))?;

        let config: Config =
            serde_json::from_str(&contents).context("Failed to parse ignition.json")?;

        println!("📝 Loaded config from: {}", path.display());
        Ok(config)
    }

    /// Save config to ~/.ignition/ignition.json
    pub fn save(&self) -> Result<()> {
        let dir = Self::config_dir()?;
        let path = Self::default_config_path()?;

        // Create directory if it doesn't exist
        fs::create_dir_all(&dir)
            .with_context(|| format!("Failed to create directory: {}", dir.display()))?;

        // Serialize config to pretty JSON
        let json = serde_json::to_string_pretty(self).context("Failed to serialize config")?;

        // Write to file
        fs::write(&path, json)
            .with_context(|| format!("Failed to write config file: {}", path.display()))?;

        println!("✓ Config saved to {}", path.display());
        Ok(())
    }

    /// Get the join URL for the server
    /// Uses join_address if set, otherwise builds from host:port
    /// Ensures the URL has the steam://connect/ prefix
    pub fn get_join_url(&self) -> String {
        let address = self.join_address.as_deref().unwrap_or("");

        if !address.is_empty() {
            // Use custom join_address
            if address.starts_with("steam://connect/") {
                address.to_string()
            } else {
                format!("steam://connect/{}", address)
            }
        } else {
            // Build from host:port
            format!("steam://connect/{}:{}", self.host, self.port)
        }
    }
}
