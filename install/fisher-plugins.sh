#!/usr/bin/env bash

set -e

log() {
    local GREEN="\033[1;32m"
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${GREEN}[INFO]${RESET} $1"
}

log_error() {
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${RED}[ERROR]${RESET} $1"
}


# Fisher installation command
FISHER_CMD="fish -c"

# Install Fisher itself
log "Installing Fisher..."
if $FISHER_CMD "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"; then
    log "Fisher installed successfully."
else
    log_error "Failed to install Fisher."
    exit 1
fi

# List of Fisher plugins to install
plugins=(
  "jethrokuan/fzf"
  "edc/bass"
  "franciscolourenco/done"
  "jethrokuan/z"
  "rafaelrinaldi/pure"
)

# Install each plugin
for plugin in "${plugins[@]}"; do
  log "Installing plugin: $plugin..."
  if $FISHER_CMD "fisher install $plugin"; then
      log "Plugin $plugin installed successfully."
  else
      log_error "Failed to install plugin: $plugin."
      exit 1
  fi
done

log "All plugins installed successfully."