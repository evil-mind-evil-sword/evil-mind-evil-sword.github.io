#!/bin/sh
set -e

# termcat installer
# Usage: curl -fsSL https://evil-mind-evil-sword.github.io/releases/termcat/install.sh | sh

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${TERMCAT_INSTALL_DIR:-$HOME/.local/bin}"

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

ASSET="termcat-${ARCH}-${OS}"

# Get version from manifest
if [ -n "$TERMCAT_VERSION" ]; then
  VERSION="$TERMCAT_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" | grep -o '"termcat"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fi

URL="${RELEASES_BASE}/termcat/${VERSION}/${ASSET}"

echo "Downloading termcat ${VERSION} for ${OS}/${ARCH}..."
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -fsSL "$URL" -o "$TMPDIR/termcat"

# Install
mkdir -p "$INSTALL_DIR"
mv "$TMPDIR/termcat" "$INSTALL_DIR/termcat"
chmod +x "$INSTALL_DIR/termcat"

echo "termcat installed to $INSTALL_DIR/termcat"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Add to your PATH:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Run 'termcat --help' to get started"
