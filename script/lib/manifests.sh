#!/bin/sh

if ! command -v dotfiles_die >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/core.sh"
fi

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
