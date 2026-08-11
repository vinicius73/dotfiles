#!/bin/sh

if ! command -v dotfiles_die >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/core.sh"
fi
if ! command -v dotfiles_validate_manifest >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/manifests.sh"
fi

dotfiles_brew() {
  if dotfiles_brew=$(command -v brew 2>/dev/null); then
    [ -x "$dotfiles_brew" ] && { printf '%s\n' "$dotfiles_brew"; return 0; }
  fi
  for dotfiles_brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$dotfiles_brew" ] && { printf '%s\n' "$dotfiles_brew"; return 0; }
  done
  return 1
}

dotfiles_require_brew() {
  dotfiles_brew || dotfiles_die "Homebrew is required. Install Xcode Command Line Tools and Homebrew, then rerun this command."
}

dotfiles_install_brewfile() {
  dotfiles_brew=$(dotfiles_require_brew)
  "$dotfiles_brew" bundle check --file "$1" >/dev/null 2>&1 || "$dotfiles_brew" bundle install --file "$1" --no-upgrade
}

dotfiles_install_arch_manifest() {
  dotfiles_require_command paru
  set --
  dotfiles_validate_manifest "$1"
  while IFS= read -r dotfiles_package; do
    [ -n "$dotfiles_package" ] && set -- "$@" "$dotfiles_package"
  done < "$1"
  paru -S --needed "$@"
}
