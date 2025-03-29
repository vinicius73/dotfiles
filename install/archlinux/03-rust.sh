#!/usr/bin/env bash

set -euo pipefail  # Enable strict error handling
IFS=$'\n\t'        # Set IFS to handle whitespace properly

# Function to print messages with colors
log() {
    local GREEN="\033[1;32m"
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${GREEN}[INFO]${RESET} $1"
}

# Function to print error messages with colors
log_error() {
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${RED}[ERROR]${RESET} $1"
}

# Function to remove packages via pacman
remove_package() {
    local package=$1
    if sudo pacman -Rns --noconfirm "$package"; then
        log "$package removed successfully."
    else
        log_error "Failed to remove $package via pacman."
    fi
}

# Check if rust, cargo, or rustup is installed via pacman
if pacman -Q rust &>/dev/null || pacman -Q cargo &>/dev/null || pacman -Q rustup &>/dev/null; then
    log "Rust, Cargo, or Rustup is already installed via pacman."
    read -p "Do you want to remove them before proceeding? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            log "Removing Rust, Cargo, and Rustup installed via pacman..."
            for package in rustup rust cargo; do
                remove_package "$package"
            done
            ;;
        *)
            log "Skipping removal. Exiting script."
            exit 0
            ;;
    esac
fi

# Install Rust using rustup
log "Installing Rust using rustup..."
if command -v rustup &>/dev/null; then
    log "Rustup is already installed. Updating rustup..."
    rustup self update
else
    log "Rustup is not installed. Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Configure Rust toolchain and completions
log "Configuring Rust toolchain and shell completions..."
rustup toolchain install stable
rustup set profile complete
rustup default stable

# Generate shell completions
generate_completions() {
    local shell=$1
    local completion_dir=$2
    mkdir -p "$completion_dir"
    rustup completions "$shell" > "$completion_dir/rustup.$shell"
    log "Generated $shell completions at $completion_dir."
}

generate_completions fish ~/.config/fish/completions
generate_completions bash ~/.local/share/bash-completion/completions

log "Rust installation and configuration completed successfully."