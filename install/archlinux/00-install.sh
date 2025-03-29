#!/usr/bin/env bash

set -euo pipefail

# Define colors for output
info() {
    tput setaf 2; echo "[INFO] $1"; tput sgr0
}

error() {
    tput setaf 1; echo "[ERROR] $1"; tput sgr0
}

warn() {
    tput setaf 3; echo "[WARNING] $1"; tput sgr0
}

# Ensure `paru` is installed
if ! command -v paru &> /dev/null; then
    error "paru is not installed. Please install it first."
    echo "https://github.com/morganamilo/paru"
    echo ""
    warn "You can install paru from the AUR (Arch User Repository)."
    echo "To install paru, you can use the following command:"
    echo "$  git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si"
    echo "Then run this script again."
    echo ""
    exit 1
fi

# Update system and install base dependencies
info "Updating system and installing base dependencies..."
sudo pacman -Sy --needed base-devel git --noconfirm && sleep 2

# Define a helper function for installing packages with paru
install_packages() {
    local packages=("$@")
    local package_list=""
    for package in "${packages[@]}"; do
        package_list+="$package "
    done
    info "Installing packages: $package_list"
    paru -S --noconfirm --needed "$@"
    if [ $? -ne 0 ]; then
        error "Failed to install packages: $package_list"
        exit 1
    fi
}

install_zed() {
    info "Installing Zed editor..."
    if curl -f https://zed.dev/install.sh | sh; then
        info "Zed editor installed successfully."
    else
        error "Failed to install Zed editor."
        exit 1
    fi
}

info "Installing terminal emulators, shell, and utilities..."
install_packages terminator alacritty fish pv fzf cowsay htop screenfetch figlet

info "Installing additional tools..."
install_packages git-extras gotop-bin 1password telegram-desktop proton-pass-bin

info "Installing browsers..."
install_packages google-chrome opera

info "Installing development tools..."
install_packages visual-studio-code-bin cursor-bin sublime-text-4
install_zed

info "Installing fonts..."
install_packages ttf-font powerline powerline-fonts noto-fonts-emoji ttf-fira-code ttf-liberation

info "Installing mouse configuration tools..."
install_packages libratbag piper

info "Installing other utilities..."
install_packages peco ghq micro exa

info "All tasks completed successfully!"