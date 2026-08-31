#!/bin/sh

if ! command -v dotfiles_die >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/core.sh"
fi

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
