#!/bin/sh

if ! command -v dotfiles_die >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/core.sh"
fi

dotfiles_xdg_home() {
  case "$1" in
    XDG_DATA_HOME) dotfiles_path=${XDG_DATA_HOME:-$2} ;;
    XDG_BIN_HOME) dotfiles_path=${XDG_BIN_HOME:-$2} ;;
    XDG_CACHE_HOME) dotfiles_path=${XDG_CACHE_HOME:-$2} ;;
    XDG_CONFIG_HOME) dotfiles_path=${XDG_CONFIG_HOME:-$2} ;;
    *) dotfiles_die "Unsupported XDG variable: $1" ;;
  esac
  dotfiles_absolute_path "$dotfiles_path"
  printf '%s\n' "$dotfiles_path"
}
