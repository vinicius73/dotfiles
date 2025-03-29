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

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    error "Flatpak is not installed. Please install it first."
    echo "Visit https://flatpak.org/setup/ for installation instructions."
    exit 1
fi

# Define the Flathub repository URL
FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add Flathub repository if it doesn't already exist
add_flathub_repo() {
    info "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub "$FLATHUB_URL"
}

# List current Flatpak remotes
list_remotes() {
    info "Listing Flatpak remotes..."
    flatpak remotes
}

# Update Flatpak packages
update_flatpak() {
    info "Updating Flatpak packages..."
    flatpak update -y
}

# Install or update Flatpak applications
install_or_update_apps() {
    local apps=(
        "com.redis.RedisInsight"
        "app.zen_browser.zen"
        "com.github.tchx84.Flatseal"
        "com.jetpackduba.Gitnuro"
        "org.videolan.VLC"
        "com.heroicgameslauncher.hgl"
        "org.keepassxc.KeePassXC"
        "io.missioncenter.MissionCenter"
        "dev.geopjr.Collision"
        "io.podman_desktop.PodmanDesktop"
        "io.github.realmazharhussain.GdmSettings"
        "com.usebruno.Bruno"
    )

    info "Installing or updating Flatpak applications..."
    for app in "${apps[@]}"; do
        info "Processing $app..."
        if ! flatpak install flathub "$app" --or-update -y; then
            warn "Failed to install or update $app. Skipping..."
        fi
    done
}

# List installed Flatpak applications
list_installed_apps() {
    info "Listing installed Flatpak applications..."
    flatpak list
}

# Main script execution
add_flathub_repo
list_remotes
update_flatpak
install_or_update_apps
list_installed_apps

info "All tasks completed successfully!"