#!/bin/sh
set -e

# alice installer template
# Variables substituted: v26.1.34

RELEASES_BASE="https://evil-mind-evil-sword.github.io/releases"
INSTALL_DIR="${ALICE_INSTALL_DIR:-$HOME/.local/bin}"

echo "Installing alice plugin..."
echo ""

# --- Install alice binary ---

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

BINARY="alice-${OS}-${ARCH}"

# Get version from manifest using jq (installed below if needed)
get_version() {
  if [ -n "$ALICE_VERSION" ]; then
    echo "$ALICE_VERSION"
  elif command -v jq >/dev/null 2>&1; then
    V=$(curl -fsSL "${RELEASES_BASE}/manifest.json" 2>/dev/null | jq -r '.alice.version // empty' 2>/dev/null || echo "")
    if [ -n "$V" ]; then echo "$V"; else echo "v26.1.34"; fi
  else
    echo "v26.1.34"
  fi
}

VERSION=$(get_version)
URL="${RELEASES_BASE}/alice/${VERSION}/${BINARY}"

echo "Installing alice CLI ${VERSION} for ${OS}/${ARCH}..."

mkdir -p "$INSTALL_DIR"
if curl -fsSL "$URL" -o "$INSTALL_DIR/alice" 2>/dev/null; then
  chmod +x "$INSTALL_DIR/alice"
  echo "alice CLI installed to $INSTALL_DIR/alice"
else
  echo "Warning: Could not download alice binary. Hooks may not work."
  echo "You can build from source: cd alice && zig build && cp zig-out/bin/alice ~/.local/bin/"
fi

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo ""
  echo "Note: Add to your PATH if not already present:"
  echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""

# --- Install dependencies ---

echo "Checking dependencies..."

# Check for jq
if ! command -v jq >/dev/null 2>&1; then
  echo "Installing jq..."
  if command -v brew >/dev/null 2>&1; then
    brew install jq
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y jq
  else
    echo "Error: jq not found. Please install jq manually."
    exit 1
  fi
fi

# Install jwz
if ! command -v jwz >/dev/null 2>&1; then
  echo "Installing jwz..."
  curl -fsSL "${RELEASES_BASE}/jwz/install.sh" | sh
fi

# Install tissue
if ! command -v tissue >/dev/null 2>&1; then
  echo "Installing tissue..."
  curl -fsSL "${RELEASES_BASE}/tissue/install.sh" | sh
fi

echo "Dependencies installed."
echo ""

# --- Install plugin via Claude Code ---

if command -v claude >/dev/null 2>&1; then
  echo "Installing alice plugin via Claude Code..."
  claude plugin marketplace add evil-mind-evil-sword/marketplace 2>/dev/null || true
  echo "Updating marketplace..."
  claude plugin marketplace update emes 2>/dev/null || true

  if claude plugin list 2>/dev/null | grep -q "alice@emes"; then
    echo "Updating alice plugin..."
    if claude plugin update alice@emes 2>/dev/null; then
      echo "alice plugin updated!"
    else
      claude plugin uninstall alice@emes 2>/dev/null || true
      if claude plugin install alice@emes 2>/dev/null; then
        echo "alice plugin reinstalled!"
      else
        echo "Plugin update failed. Try manually: /plugin update alice@emes"
      fi
    fi
  else
    echo "Installing alice plugin..."
    if claude plugin install alice@emes 2>/dev/null; then
      echo "alice plugin installed!"
    else
      echo "Plugin install failed. Try manually in Claude Code:"
      echo "  /plugin marketplace add evil-mind-evil-sword/marketplace"
      echo "  /plugin install alice@emes"
    fi
  fi
else
  echo "claude CLI not found. Install the plugin manually in Claude Code:"
  echo "  /plugin marketplace add evil-mind-evil-sword/marketplace"
  echo "  /plugin install alice@emes"
fi

echo ""
echo "Installation complete!"
echo ""
echo "The alice plugin is now active. Use #alice to enable review."
echo ""
echo "Installed:"
echo "  alice   - CLI for hooks and tracing"
echo "  jwz     - Agent messaging"
echo "  tissue  - Issue tracking"
