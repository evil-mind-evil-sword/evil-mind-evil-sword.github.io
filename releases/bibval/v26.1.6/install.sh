#!/bin/sh
set -e

# bibval installer
# Usage: curl -fsSL https://evil-mind-evil-sword.github.io/releases/bibval/install.sh | sh

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${BIBVAL_INSTALL_DIR:-$HOME/.local/bin}"

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

ASSET="bibval-${ARCH}-${OS}"

# Get version from manifest
if [ -n "$BIBVAL_VERSION" ]; then
  VERSION="$BIBVAL_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" | grep -o '"bibval"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fi

URL="${RELEASES_BASE}/bibval/${VERSION}/${ASSET}"

echo "Downloading bibval ${VERSION} for ${OS}/${ARCH}..."
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -fsSL "$URL" -o "$TMPDIR/bibval"

# Install
mkdir -p "$INSTALL_DIR"
mv "$TMPDIR/bibval" "$INSTALL_DIR/bibval"
chmod +x "$INSTALL_DIR/bibval"

echo "bibval installed to $INSTALL_DIR/bibval"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Add to your PATH:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Run 'bibval --help' to get started"
