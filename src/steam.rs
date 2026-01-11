use a2s::A2SClient;
use anyhow::Result;
use std::net::{IpAddr, SocketAddr};

#[derive(Debug)]
pub struct ServerStatus {
    pub online: bool,
    pub name: String,
    pub map: String,
    pub players: u8,
    pub max_players: u8,
    pub game: String,
}

/// Query Steam server status using A2S_INFO protocol
pub async fn query_server_status(host: &str, port: u16) -> Result<ServerStatus> {
    // Parse IP address
    let ip: IpAddr = host
        .parse()
        .map_err(|_| anyhow::anyhow!("Invalid IP address: {}", host))?;

    let addr = SocketAddr::new(ip, port);

    // Run blocking A2S query in a separate thread
    let result = tokio::task::spawn_blocking(move || {
        // Create A2S client
        let client = A2SClient::new()?;

        // Query server info (this is a blocking operation)
        client.info(addr)
    })
    .await;

    match result {
        Ok(Ok(info)) => Ok(ServerStatus {
            online: true,
            name: info.name,
            map: info.map,
            players: info.players,
            max_players: info.max_players,
            game: info.game,
        }),
        Ok(Err(_e)) => {
            // Server query failed - likely offline or unreachable
            Ok(ServerStatus {
                online: false,
                name: "Unknown".to_string(),
                map: "N/A".to_string(),
                players: 0,
                max_players: 0,
                game: "Unknown".to_string(),
            })
        }
        Err(e) => {
            // Task panicked or was cancelled
            Err(anyhow::anyhow!("Query task failed: {}", e))
        }
    }
}

impl ServerStatus {}
