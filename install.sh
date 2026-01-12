#!/usr/bin/env bash
set -euo pipefail

# Ignite installer script for Linux/macOS
# Usage: ./install.sh [--version VERSION]

REPO="mbround18/ignite"
VERSION="latest"
INSTALL_DIR="."

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./install.sh [--version VERSION]"
      exit 1
      ;;
  esac
done

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
  linux*)
    OS="linux"
    ;;
  darwin*)
    OS="macos"
    ;;
  *)
    echo "❌ Unsupported operating system: $OS"
    exit 1
    ;;
esac

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64)
    ARCH="x86_64"
    ;;
  aarch64|arm64)
    ARCH="aarch64"
    ;;
  *)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Construct binary name based on common Rust target conventions
if [ "$OS" = "linux" ]; then
  BINARY_NAME="ignite-${ARCH}-unknown-linux-gnu"
  TARGET="${ARCH}-unknown-linux-gnu"
elif [ "$OS" = "macos" ]; then
  BINARY_NAME="ignite-${ARCH}-apple-darwin"
  TARGET="${ARCH}-apple-darwin"
fi

echo "🔥 Installing Ignite..."
echo "   OS: $OS"
echo "   Architecture: $ARCH"
echo "   Version: $VERSION"

# Construct candidate asset names
if [ "$OS" = "linux" ]; then
  RAW_ASSET="ignite-${TARGET}"
  ARCHIVE_ASSET="ignite-linux-${ARCH}.tar.gz"
else
  RAW_ASSET="ignite-${TARGET}"
  ARCHIVE_ASSET="ignite-macos-${ARCH}.tar.gz"
fi

# Normalize version tag (add leading v if missing)
VERSION_TAG="$VERSION"
if [ "$VERSION_TAG" != "latest" ] && [[ "$VERSION_TAG" != v* ]]; then
  VERSION_TAG="v$VERSION_TAG"
fi

# Build candidate URLs (raw binary first, then archive)
if [ "$VERSION_TAG" = "latest" ]; then
  URLS=(
    "https://github.com/${REPO}/releases/latest/download/${RAW_ASSET}"
    "https://github.com/${REPO}/releases/latest/download/${ARCHIVE_ASSET}"
  )
else
  URLS=(
    "https://github.com/${REPO}/releases/download/${VERSION_TAG}/${RAW_ASSET}"
    "https://github.com/${REPO}/releases/download/${VERSION_TAG}/${ARCHIVE_ASSET}"
  )
fi

TMP_FILE="$(mktemp)"
TMP_DIR="$(mktemp -d)"
DOWNLOADED_URL=""

echo ""
echo "📥 Downloading from GitHub..."

# Download helper
_download() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 -o "$out" "$url" || return 1
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$out" "$url" || return 1
  else
    echo "❌ Neither curl nor wget found. Please install one of them."
    exit 1
  fi
}

# Try candidates
for u in "${URLS[@]}"; do
  if _download "$u" "$TMP_FILE"; then
    DOWNLOADED_URL="$u"
    break
  fi
done

if [ -z "$DOWNLOADED_URL" ]; then
  echo "❌ Failed to download Ignite."
  echo "   Tried:"
  for u in "${URLS[@]}"; do echo "   - $u"; done
  exit 1
fi

# If archive, extract; else move raw binary
if [[ "$DOWNLOADED_URL" == *.tar.gz ]]; then
  tar -xzf "$TMP_FILE" -C "$TMP_DIR"
  if [ -f "$TMP_DIR/ignite" ]; then
    mv "$TMP_DIR/ignite" "$INSTALL_DIR/ignite"
  else
    BIN_PATH=$(tar -tzf "$TMP_FILE" | grep -E "(^|/)ignite$" | head -n1 || true)
    if [ -n "$BIN_PATH" ]; then
      tar -xzf "$TMP_FILE" -C "$TMP_DIR" "$BIN_PATH"
      mv "$TMP_DIR/$BIN_PATH" "$INSTALL_DIR/ignite"
    else
      echo "❌ Could not find 'ignite' binary in the archive."
      exit 1
    fi
  fi
else
  mv "$TMP_FILE" "$INSTALL_DIR/ignite"
fi

# Make executable
chmod +x "$INSTALL_DIR/ignite"

# Verify installation
if [ -f "./ignite" ]; then
  echo ""
  echo "✅ Ignite installed successfully!"
  echo ""
  echo "   Location: $(pwd)/ignite"
  echo ""
  echo "📝 Next steps:"
  echo "   1. Move to PATH: sudo mv ignite /usr/local/bin/"
  echo "   2. Or run directly: ./ignite --help"
  echo ""
  
  # Try to show version if binary is executable
  if ./ignite --version &> /dev/null; then
    echo "   Installed version: $(./ignite --version)"
  fi
else
  echo "❌ Installation failed"
  exit 1
fi
