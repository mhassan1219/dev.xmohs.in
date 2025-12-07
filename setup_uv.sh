#!/usr/bin/env bash
# Minimal macOS bootstrap for Python work using uv.

set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  log "Please do not run as root."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (may prompt a dialog)..."
  xcode-select --install || log "Command Line Tools install already in progress."
else
  log "Command Line Tools already installed."
fi

log "Making ~/Library visible."
chflags nohidden "${HOME}/Library" || true

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load brew into the current shell if it is not already present.
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
fi

log "Updating Homebrew..."
brew update

packages=(uv git openssl readline sqlite3 zlib wget)
for pkg in "${packages[@]}"; do
  if brew list "$pkg" >/dev/null 2>&1; then
    log "$pkg already installed."
  else
    log "Installing $pkg..."
    brew install "$pkg"
  fi
done

casks=(tabby visual-studio-code docker 1password arc raycast insomnia rectangle)
for app in "${casks[@]}"; do
  if brew list --cask "$app" >/dev/null 2>&1; then
    log "$app already installed."
  else
    log "Installing $app..."
    brew install --cask "$app"
  fi
done

if ! grep -q "uv/bin" "${HOME}/.zshrc" 2>/dev/null; then
  log "Adding uv to PATH in ~/.zshrc."
  printf '\n# uv\nexport PATH="$HOME/.uv/bin:$HOME/.local/bin:$PATH"\n' >> "${HOME}/.zshrc"
fi
export PATH="$HOME/.uv/bin:$HOME/.local/bin:$PATH"

log "Installing Python 3.12 with uv..."
uv python install 3.12
uv python list

log "All done. Use 'uv init <project>' to create new projects."
