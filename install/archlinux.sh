#!/bin/bash

# Exit immediately if a command exits with a non-zero status,
# treat unset variables as errors, and propagate errors in pipelines.
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

# Directory containing the scripts
SCRIPT_DIR="$(dirname "$(realpath "$0")")/archlinux"

# Check if the directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
    error "Script directory '$SCRIPT_DIR' does not exist."
    exit 1
fi

info "Starting script execution from directory: $SCRIPT_DIR"

# Iterate over the scripts in order
for script in "$SCRIPT_DIR"/*.sh; do
    # Extract the script name
    script_name=$(basename "$script")
    
    # Prompt the user
    printf "Do you want to run %s? (y/n): " "$script_name"
    read -r answer
    
    # Validate the user's response
    case "$answer" in
        [yY]) 
            info "Running $script_name..."
            if bash "$script"; then
                info "$script_name completed successfully."
            else
                error "$script_name encountered an error."
            fi
            ;;
        [nN]) 
            warn "Skipping $script_name."
            ;;
        *) 
            warn "Invalid input. Skipping $script_name."
            ;;
    esac
done

info "All scripts processed."