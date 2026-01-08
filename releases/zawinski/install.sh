#!/bin/sh
set -e

# zawinski installer
# Usage: curl -fsSL https://evil-mind-evil-sword.github.io/releases/zawinski/install.sh | sh

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${JWZ_INSTALL_DIR:-$HOME/.local/bin}"

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

BINARY="jwz-${OS}-${ARCH}"

# Get version from manifest
if [ -n "$JWZ_VERSION" ]; then
  VERSION="$JWZ_VERSION"
else
  VERSION=$(curl -fsSL "${RELEASES_BASE}/manifest.json" | grep -o '"zawinski"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
fi

URL="${RELEASES_BASE}/zawinski/${VERSION}/${BINARY}"

echo "Installing jwz ${VERSION} for ${OS}/${ARCH}..."

mkdir -p "$INSTALL_DIR"
curl -fsSL "$URL" -o "$INSTALL_DIR/jwz"
chmod +x "$INSTALL_DIR/jwz"

echo "jwz installed to $INSTALL_DIR/jwz"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Add to your PATH:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "Get started:"
echo "  jwz init"
echo "  jwz topic new general -d 'General discussion'"
