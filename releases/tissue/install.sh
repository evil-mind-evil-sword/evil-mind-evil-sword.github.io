#!/bin/sh
set -e

# tissue installer
# Usage: curl -fsSL https://evil-mind-evil-sword.github.io/releases/tissue/install.sh | sh

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${TISSUE_INSTALL_DIR:-/usr/local/bin}"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux) OS="linux" ;;
  darwin) OS="macos" ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH="x86_64" ;;
  aarch64|arm64) ARCH="aarch64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

ASSET="tissue-${ARCH}-${OS}"

# Get version from manifest
if [ -n "$TISSUE_VERSION" ]; then
  VERSION="$TISSUE_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" | grep -o '"tissue"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fi

URL="${RELEASES_BASE}/tissue/${VERSION}/${ASSET}"

echo "Downloading tissue ${VERSION} for ${OS}/${ARCH}..."
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -fsSL "$URL" -o "$TMPDIR/tissue"

# Install
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMPDIR/tissue" "$INSTALL_DIR/tissue"
else
  echo "Installing to $INSTALL_DIR (requires sudo)..."
  sudo mv "$TMPDIR/tissue" "$INSTALL_DIR/tissue"
fi

chmod +x "$INSTALL_DIR/tissue"
echo "tissue installed to $INSTALL_DIR/tissue"
echo "Run 'tissue --help' to get started"
