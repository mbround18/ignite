#!/usr/bin/env bash
set -e

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

# Determine download URL
if [ "$VERSION" = "latest" ]; then
  DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${BINARY_NAME}"
  echo "   Fetching: latest release"
else
  DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}"
  echo "   Fetching: ${VERSION}"
fi

# Download binary
echo ""
echo "📥 Downloading from GitHub..."
if command -v curl &> /dev/null; then
  curl -fsSL -o ignite "$DOWNLOAD_URL"
elif command -v wget &> /dev/null; then
  wget -q -O ignite "$DOWNLOAD_URL"
else
  echo "❌ Neither curl nor wget found. Please install one of them."
  exit 1
fi

# Make executable
chmod +x ignite

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
