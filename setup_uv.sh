#!/bin/bash
{
    # Check for root access
    if [ "$EUID" -eq 0 ]; then
        echo "Please do not run as root"
        exit 1
    fi

    # Install Xcode Command Line Tools
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Make the Library folder visible
    echo "Making the ~/Library folder visible..."
    chflags nohidden ~/Library

    # Check if Homebrew is already installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew already installed."
    fi

    # Update Homebrew
    echo "Updating Homebrew..."
    brew update

    # Install useful packages
    echo "Installing useful Homebrew packages..."
    brew install neovim zsh-completions ssh-copy-id wget git uv openssl readline sqlite3 xz zlib syncthing

    # Install Cask applications
    echo "Installing Cask applications..."
    apps=("tabby" "visual-studio-code" "docker" "1password" "shadow" "superhuman" "utm" "slack" "keybase" "hiddenbar" "numi" "arc" "charles" "itsycal" "raycast" "insomnia" "altserver" "ticktick" "alttab", "tailscale" "snagit" "rocket" "rectangle")

    for app in "${apps[@]}"; do
        if ! brew list --cask "$app" &>/dev/null; then
            brew install --cask "$app"
        else
            echo "$app is already installed."
        fi
    done

    # Install Python through uv
    echo "Installing Python..."
    uv python install
    export PATH="$HOME/.uv/bin:$PATH"
    echo -e "\n# Add uv to PATH\nexport PATH=\"$HOME/.uv/bin:$PATH\"" >> ~/.zshrc
    python --version

    # Upgrade pip and setuptools
    echo "Upgrading Pip and Setuptools..."
    uv pip install --upgrade pip setuptools

    # Install virtualenv
    echo "Installing Virtualenv..."
    uv pip install virtualenv

    # Directory setup
    echo "Creating directories..."
    mkdir -p ~/.config/pip

    # Configure pip
    echo "Configuring Pip..."
    echo -e "[install]\nrequire-virtualenv = true\n\n[uninstall]\nrequire-virtualenv = true" > ~/.config/pip/pip.conf

    # Install Oh My Zsh
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Add global pip function to Zsh configuration
    echo "Adding gpip() to Zsh configuration..."
    echo -e "\n# Global pip function\ngpip(){\n PIP_REQUIRE_VIRTUALENV=\"0\" python -m pip \"\$@\"\n}" >> ~/.zshrc

    # Add Zsh Completions to .zshrc
    echo "Adding Zsh Completions to Zsh configuration..."
    echo -e "\n# Zsh Completions\nif type brew &>/dev/null; then\n FPATH=\$(brew --prefix)/share/zsh-completions:\$FPATH\n autoload -Uz compinit\n compinit\nfi" >> ~/.zshrc

    # Reload Zshrc
    echo "Reloading Zsh configuration..."
    source ~/.zshrc

} 2>&1 | while read -r line; do echo "[$(date +'%Y-%m-%d %H:%M:%S')] $line"; done | tee setup_uv.log

# Finish
echo "Setup complete!"

echo "Setup Syncthing, Superhuman"

echo "Look at the setup_uv.log file for post brew tasks"
