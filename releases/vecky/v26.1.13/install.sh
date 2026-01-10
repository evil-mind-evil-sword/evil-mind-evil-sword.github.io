#!/bin/sh
set -e

# Generic installer template for emes packages
# Variables are substituted during release:
#   PACKAGE_NAME, PACKAGE_VERSION, RELEASES_BASE, BINARY_PREFIX, INSTALL_DIR_VAR
#
# Usage: Called by deploy-release.sh to generate package-specific install scripts

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${VECKY_INSTALL_DIR:-$HOME/.local/bin}"

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

BINARY="vecky-${OS}-${ARCH}"

# Get version from manifest (with fallback)
if [ -n "$VECKY_VERSION" ]; then
  VERSION="$VECKY_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" 2>/dev/null | \
    jq -r '.vecky.version // empty' 2>/dev/null || echo "")
  if [ -z "$VERSION" ]; then
    VERSION="v26.1.13"
  fi
fi

URL="${RELEASES_BASE}/vecky/${VERSION}/${BINARY}"

echo "Installing vecky ${VERSION} for ${OS}/${ARCH}..."

mkdir -p "$INSTALL_DIR"
if curl -fsSL "$URL" -o "$INSTALL_DIR/vecky" 2>/dev/null; then
  chmod +x "$INSTALL_DIR/vecky"
  echo "vecky installed to $INSTALL_DIR/vecky"
else
  echo "Error: Could not download vecky binary."
  exit 1
fi

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Add to your PATH:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Run 'vecky --help' to get started"
