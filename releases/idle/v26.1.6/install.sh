#!/bin/sh
set -e

# idle installer
# Usage: curl -fsSL https://evil-mind-evil-sword.github.io/releases/idle/install.sh | sh

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${IDLE_INSTALL_DIR:-$HOME/.local/bin}"

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

BINARY="idle-${OS}-${ARCH}"

# Get version from manifest
if [ -n "$IDLE_VERSION" ]; then
  VERSION="$IDLE_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" | grep -o '"idle"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fi

URL="${RELEASES_BASE}/idle/${VERSION}/${BINARY}"

echo "Installing idle CLI ${VERSION} for ${OS}/${ARCH}..."

mkdir -p "$INSTALL_DIR"
curl -fsSL "$URL" -o "$INSTALL_DIR/idle"
chmod +x "$INSTALL_DIR/idle"

echo "idle CLI installed to $INSTALL_DIR/idle"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Add to your PATH:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Note: The idle Claude Code plugin is installed separately via:"
echo "  claude /plugin install idle@emes"
echo ""
echo "Get started with the CLI:"
echo "  idle trace <session_id>     # View session trace"
echo "  idle trace <session_id> -v  # Verbose: show tool inputs/outputs"
