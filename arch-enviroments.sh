#!/usr/bin/env bash

set -euo pipefail  # Enable strict error handling
IFS=$'\n\t'        # Set safer IFS

log() {
    local GREEN="\033[1;32m"
    local RESET="\033[0m"
    echo -e "${GREEN}[INFO]${RESET} $1"
}

log_error() {
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${RED}[ERROR]${RESET} $1"
}

log_warn() {
    local YELLOW="\033[1;33m"
    local RESET="\033[0m"
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

# Helper function for creating symlinks
create_symlink() {
    local target=$1
    local link=$2

    if [ -e "$link" ] || [ -L "$link" ]; then
        log_warn "Removing existing file or symlink: $link"
        rm -rf "$link"
    fi

    log "Creating symlink: $link -> $target"
    ln -s "$target" "$link"
    echo ""
}

# fish
log "Setting up fish configuration"
mkdir -p ~/.config/fish
log "Ensured ~/.config/fish directory exists"
create_symlink ~/dotfiles/config/fish/config.fish ~/.config/fish/config.fish

# terminator
log "Setting up terminator configuration"
create_symlink ~/dotfiles/config/terminator ~/.config/terminator

# alacritty
log "Setting up alacritty configuration"
create_symlink ~/dotfiles/config/alacritty ~/.config/alacritty

# gitmoji-nodejs
log "Setting up gitmoji-nodejs configuration"
create_symlink ~/dotfiles/config/gitmoji-nodejs ~/.config/gitmoji-nodejs

# bash
log "Setting up bash configuration"
if [ -f ~/.bashrc ]; then
    log_warn "Backing up existing .bashrc to .bashrc_original"
    mv ~/.bashrc ~/.bashrc_original
fi
create_symlink ~/dotfiles/bash/.bashrc ~/.bashrc

# git
log "Setting up git configuration"
if [ -f ~/.gitconfig ]; then
    log_warn "Backing up existing .gitconfig to .gitconfig_original"
    mv ~/.gitconfig ~/.gitconfig_original
fi
create_symlink ~/dotfiles/config/.gitconfig ~/.gitconfig

# anothers
log "Ensuring ~/bin directory exists"
mkdir -p ~/bin
log "Setup complete"