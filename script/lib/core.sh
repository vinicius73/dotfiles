#!/bin/sh

set -eu

dotfiles_die() {
  printf '%s\n' "$1" >&2
  exit "${2:-1}"
}

dotfiles_require_tty() {
  [ -t 0 ] && [ -t 1 ] || dotfiles_die "This operation requires an interactive terminal."
}

dotfiles_confirm() {
  dotfiles_prompt=$1
  dotfiles_require_tty
  printf '%s\n' "$dotfiles_prompt"
  printf '%s' "Type APPLY to continue: "
  IFS= read -r dotfiles_answer < /dev/tty || exit 1
  [ "$dotfiles_answer" = APPLY ] || dotfiles_die "Operation cancelled."
}

dotfiles_require_command() {
  command -v "$1" >/dev/null 2>&1 || dotfiles_die "Required command is unavailable: $1"
}

dotfiles_absolute_path() {
  case "$1" in
    /*) ;;
    *) dotfiles_die "Path must be absolute: $1" ;;
  esac
}
