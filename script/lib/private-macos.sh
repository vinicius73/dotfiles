#!/bin/sh

if ! command -v dotfiles_die >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/core.sh"
fi
if ! command -v dotfiles_platform >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/platform.sh"
fi
if ! command -v dotfiles_install_brewfile >/dev/null 2>&1; then
  . "${DOTFILES_REPO_ROOT:?DOTFILES_REPO_ROOT must be set}/script/lib/packages.sh"
fi

private_macos_require_platform() {
  [ "$(dotfiles_platform)" = macos ] || dotfiles_die "The private macOS extension is only available on macOS."
}

private_macos_physical_directory() {
  dotfiles_absolute_path "$1"
  [ -d "$1" ] && [ ! -L "$1" ] || dotfiles_die "Expected a physical directory: $1"
  private_macos_directory=$(CDPATH='' cd -- "$1" && pwd -P) || dotfiles_die "Cannot resolve directory: $1"
  printf '%s\n' "$private_macos_directory"
}

private_macos_regular_file() {
  [ -f "$1" ] && [ ! -L "$1" ] || dotfiles_die "Expected a regular file: $1"
}

private_macos_root() {
  private_macos_physical_directory "$DOTFILES_REPO_ROOT/private/macos"
}

private_macos_load_manifest() {
  private_macos_root=$1
  private_macos_manifest="$private_macos_root/private-macos.conf"
  private_macos_regular_file "$private_macos_manifest"

  private_macos_schema=false
  private_macos_source=false
  private_macos_brewfile=

  while IFS= read -r private_macos_line || [ -n "$private_macos_line" ]; do
    case "$private_macos_line" in
      schema_version=1)
        [ "$private_macos_schema" = false ] || dotfiles_die "Duplicate schema_version in $private_macos_manifest"
        private_macos_schema=true
        ;;
      chezmoi_source=home)
        [ "$private_macos_source" = false ] || dotfiles_die "Duplicate chezmoi_source in $private_macos_manifest"
        private_macos_source=true
        ;;
      brewfile=packages.Brewfile)
        [ -z "$private_macos_brewfile" ] || dotfiles_die "Duplicate brewfile in $private_macos_manifest"
        private_macos_brewfile="$private_macos_root/packages.Brewfile"
        ;;
      *) dotfiles_die "Invalid private macOS manifest entry: $private_macos_line" ;;
    esac
  done < "$private_macos_manifest"

  [ "$private_macos_schema" = true ] || dotfiles_die "Missing schema_version=1 in $private_macos_manifest"
  [ "$private_macos_source" = true ] || dotfiles_die "Missing chezmoi_source=home in $private_macos_manifest"

  private_macos_source_dir=$(private_macos_physical_directory "$private_macos_root/home")

  if [ -n "$private_macos_brewfile" ]; then
    private_macos_regular_file "$private_macos_brewfile"
  fi
}

private_macos_managed_targets() {
  chezmoi managed --source "$1" --destination "$2" --include files,symlinks --path-style absolute
}

private_macos_targets_conflict() {
  case "$1" in
    "$2"|"$2"/*) return 0 ;;
  esac
  case "$2" in
    "$1"/*) return 0 ;;
  esac
  return 1
}

private_macos_target_is_agents_path() {
  case "$1" in
    "$HOME/.agents"|"$HOME/.agents"/*) return 0 ;;
  esac
  return 1
}

private_macos_validate_targets() {
  private_macos_public_source="$DOTFILES_REPO_ROOT/home"
  private_macos_public_targets=$(mktemp "${TMPDIR:-/tmp}/dotfiles-private-public.XXXXXX") || dotfiles_die "Cannot create temporary target list."
  private_macos_private_targets=$(mktemp "${TMPDIR:-/tmp}/dotfiles-private-private.XXXXXX") || {
    rm -f "$private_macos_public_targets"
    dotfiles_die "Cannot create temporary target list."
  }
  trap 'rm -f "$private_macos_public_targets" "$private_macos_private_targets"' 0 HUP INT TERM

  private_macos_managed_targets "$private_macos_public_source" "$HOME" > "$private_macos_public_targets" || dotfiles_die "Cannot list public Chezmoi targets."
  private_macos_managed_targets "$private_macos_source_dir" "$HOME" > "$private_macos_private_targets" || dotfiles_die "Cannot list private Chezmoi targets."
  sort -u "$private_macos_public_targets" -o "$private_macos_public_targets"
  sort -u "$private_macos_private_targets" -o "$private_macos_private_targets"

  while IFS= read -r private_macos_target; do
    [ -n "$private_macos_target" ] || continue
    if private_macos_target_is_agents_path "$private_macos_target"; then
      dotfiles_die "Private Chezmoi configuration cannot manage agent paths: $private_macos_target"
    fi
    while IFS= read -r private_macos_public_target; do
      if private_macos_targets_conflict "$private_macos_target" "$private_macos_public_target"; then
        dotfiles_die "Private Chezmoi target conflicts with public configuration: $private_macos_target"
      fi
    done < "$private_macos_public_targets"
  done < "$private_macos_private_targets"
}

private_macos_public_configuration_valid() {
  private_macos_public_source="$DOTFILES_REPO_ROOT/home"
  private_macos_regular_file "$private_macos_public_source/dot_bashrc"
  chezmoi verify --source "$private_macos_public_source" --destination "$HOME" >/dev/null 2>&1 || dotfiles_die "Apply the public configuration with script/bootstrap apply before private macOS configuration."
}

private_macos_prepare() {
  private_macos_require_platform
  dotfiles_require_command chezmoi
  private_macos_root=$(private_macos_root)
  private_macos_load_manifest "$private_macos_root"
  private_macos_validate_targets
}

private_macos_plan() {
  private_macos_prepare
  printf '%s\n' "Platform: macos ($(uname -m))"
  printf '%s\n' "Private extension root: $private_macos_root"
  printf '%s\n' "Private Chezmoi source: $private_macos_source_dir"
  if [ -n "$private_macos_brewfile" ]; then
    printf '%s\n' "Private Brewfile: $private_macos_brewfile"
    if private_macos_brew=$(dotfiles_brew); then
      printf '%s\n' "Homebrew: $private_macos_brew"
    else
      printf '%s\n' "Homebrew: missing (required by apply)"
    fi
  else
    printf '%s\n' "Private Brewfile: none"
  fi
  printf '%s\n' "Private managed targets:"
  cat "$private_macos_private_targets"
}

private_macos_verify() {
  private_macos_prepare
  private_macos_public_configuration_valid
  chezmoi verify --source "$private_macos_source_dir" --destination "$HOME" >/dev/null 2>&1 || dotfiles_die "Private macOS configuration is not applied. Run script/private-macos apply."
  printf '%s\n' "ok private-macos.extension valid"
}

private_macos_apply() {
  dotfiles_require_tty
  private_macos_plan
  private_macos_public_configuration_valid
  dotfiles_confirm "Apply the private macOS configuration."
  if [ -n "$private_macos_brewfile" ]; then
    dotfiles_install_brewfile "$private_macos_brewfile"
  fi
  chezmoi diff --source "$private_macos_source_dir" --destination "$HOME"
  dotfiles_confirm "Apply the displayed private Chezmoi changes."
  chezmoi apply --source "$private_macos_source_dir" --destination "$HOME"
  printf '%s\n' "Private macOS configuration applied."
}
