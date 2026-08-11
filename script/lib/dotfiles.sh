#!/bin/sh

set -eu

dotfiles_die() {
  printf '%s\n' "$1" >&2
  exit "${2:-1}"
}

dotfiles_platform() {
  dotfiles_os=$(uname -s)
  dotfiles_arch=$(uname -m)
  case "$dotfiles_os:$dotfiles_arch" in
    Darwin:arm64|Darwin:x86_64) printf '%s\n' macos ;;
    Linux:*)
      [ -e "${DOTFILES_ARCH_RELEASE_FILE:-/etc/arch-release}" ] || dotfiles_die "Unsupported Linux distribution. Only Arch Linux is supported."
      printf '%s\n' arch
      ;;
    *) dotfiles_die "Unsupported platform: $dotfiles_os $dotfiles_arch" ;;
  esac
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

dotfiles_manifest_path() {
  dotfiles_profile=$1
  dotfiles_platform=$2
  case "$dotfiles_platform:$dotfiles_profile" in
    macos:base|macos:cli|macos:desktop|macos:docker|macos:pokemonsay)
      printf '%s\n' "$DOTFILES_REPO_ROOT/packages/macos/$dotfiles_profile.Brewfile"
      ;;
    arch:base|arch:cli|arch:desktop|arch:docker|arch:pokemonsay|arch:rust)
      printf '%s\n' "$DOTFILES_REPO_ROOT/packages/arch/$dotfiles_profile.txt"
      ;;
    *) return 1 ;;
  esac
}

dotfiles_validate_manifest() {
  [ -s "$1" ] || dotfiles_die "Package manifest is empty or missing: $1"
  while IFS= read -r dotfiles_package; do
    [ -n "$dotfiles_package" ] || continue
    case "$dotfiles_package" in
      -*|*[!A-Za-z0-9@._+:-]*) dotfiles_die "Invalid package name in $1: $dotfiles_package" ;;
    esac
  done < "$1"
}

dotfiles_read_manifest() {
  dotfiles_validate_manifest "$1"
  while IFS= read -r dotfiles_package; do
    [ -n "$dotfiles_package" ] && printf '%s\n' "$dotfiles_package"
  done < "$1"
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

dotfiles_absolute_path() {
  case "$1" in
    /*) ;;
    *) dotfiles_die "Path must be absolute: $1" ;;
  esac
}

dotfiles_xdg_home() {
  case "$1" in
    XDG_DATA_HOME) dotfiles_path=${XDG_DATA_HOME:-$2} ;;
    XDG_BIN_HOME) dotfiles_path=${XDG_BIN_HOME:-$2} ;;
    XDG_CONFIG_HOME) dotfiles_path=${XDG_CONFIG_HOME:-$2} ;;
    *) dotfiles_die "Unsupported XDG variable: $1" ;;
  esac
  dotfiles_absolute_path "$dotfiles_path"
  printf '%s\n' "$dotfiles_path"
}
