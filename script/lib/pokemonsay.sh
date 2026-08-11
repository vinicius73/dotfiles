#!/bin/sh

pokemonsay_source_url=https://github.com/HRKings/pokemonsay-newgenerations.git
pokemonsay_source_commit=f8a24a05dd3330fac2a75fdbaf19f72948cedfb3

pokemonsay_paths() {
  pokemonsay_data_root=$(dotfiles_xdg_home XDG_DATA_HOME "$HOME/.local/share")
  pokemonsay_bin_root=$(dotfiles_xdg_home XDG_BIN_HOME "$HOME/.local/bin")
  case "$pokemonsay_data_root:$pokemonsay_bin_root" in
    "$HOME"/*:"$HOME"/*) ;;
    *) dotfiles_die "XDG data and bin directories must be below HOME." ;;
  esac
  [ ! -e "$pokemonsay_data_root" ] || [ ! -L "$pokemonsay_data_root" ] || dotfiles_die "Refusing symlinked XDG data directory: $pokemonsay_data_root"
  [ ! -e "$pokemonsay_bin_root" ] || [ ! -L "$pokemonsay_bin_root" ] || dotfiles_die "Refusing symlinked XDG bin directory: $pokemonsay_bin_root"
  pokemonsay_parent="$pokemonsay_data_root/dotfiles"
  [ ! -e "$pokemonsay_parent" ] || [ ! -L "$pokemonsay_parent" ] || dotfiles_die "Refusing symlinked pokemonsay parent: $pokemonsay_parent"
  pokemonsay_data_dir="$pokemonsay_parent/pokemonsay"
  pokemonsay_marker="$pokemonsay_data_dir/.dotfiles-pokemonsay"
  pokemonsay_wrapper="$pokemonsay_data_dir/dotfiles-pokemonsay"
  pokemonsay_launcher="$pokemonsay_bin_root/pokemonsay"
}

pokemonsay_validate_existing() {
  [ ! -e "$pokemonsay_data_dir" ] && [ ! -L "$pokemonsay_data_dir" ] || {
    [ -d "$pokemonsay_data_dir" ] && [ ! -L "$pokemonsay_data_dir" ] || dotfiles_die "Refusing invalid pokemonsay data path: $pokemonsay_data_dir"
    [ -f "$pokemonsay_marker" ] || dotfiles_die "Refusing unmanaged pokemonsay data: $pokemonsay_data_dir"
    git -C "$pokemonsay_data_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || dotfiles_die "Refusing invalid pokemonsay data: $pokemonsay_data_dir"
    git -C "$pokemonsay_data_dir" remote get-url origin | grep -Fx "$pokemonsay_source_url" >/dev/null || dotfiles_die "Refusing unexpected pokemonsay source: $pokemonsay_data_dir"
    if ! git -C "$pokemonsay_data_dir" diff --quiet || ! git -C "$pokemonsay_data_dir" diff --cached --quiet; then
      dotfiles_die "Refusing modified pokemonsay data: $pokemonsay_data_dir"
    fi
    pokemonsay_untracked=$(git -C "$pokemonsay_data_dir" status --porcelain --untracked-files=all | grep -v -E '^\?\? (dotfiles-pokemonsay|\.dotfiles-pokemonsay)$' || true)
    [ -z "$pokemonsay_untracked" ] || dotfiles_die "Refusing modified pokemonsay data: $pokemonsay_data_dir"
  }
  [ ! -e "$pokemonsay_launcher" ] && [ ! -L "$pokemonsay_launcher" ] || {
    [ -L "$pokemonsay_launcher" ] || dotfiles_die "Refusing non-symlink launcher: $pokemonsay_launcher"
    [ "$(readlink "$pokemonsay_launcher")" = "$pokemonsay_wrapper" ] || dotfiles_die "Refusing unmanaged pokemonsay launcher: $pokemonsay_launcher"
  }
}

pokemonsay_plan() {
  pokemonsay_paths
  printf '%s\n' "Package dependency: cowsay"
  printf '%s\n' "Pinned source: $pokemonsay_source_url@$pokemonsay_source_commit"
  printf '%s\n' "Managed data: $pokemonsay_data_dir"
  printf '%s\n' "Managed launcher: $pokemonsay_launcher"
}

pokemonsay_preflight() {
  dotfiles_require_command git
  pokemonsay_paths
  pokemonsay_validate_existing
}

pokemonsay_apply() {
  pokemonsay_preflight
  mkdir -p "$pokemonsay_parent" "$pokemonsay_bin_root"
  pokemonsay_stage=$(mktemp -d "$pokemonsay_parent/.pokemonsay.stage.XXXXXX")
  pokemonsay_backup=
  pokemonsay_launcher_stage="$pokemonsay_bin_root/.pokemonsay.launcher.$$"
  trap '[ -n "${pokemonsay_stage:-}" ] && rm -rf "$pokemonsay_stage"; [ -L "${pokemonsay_launcher_stage:-}" ] && rm -f "$pokemonsay_launcher_stage"' 0 HUP INT TERM
  git clone --no-checkout "$pokemonsay_source_url" "$pokemonsay_stage"
  git -C "$pokemonsay_stage" checkout --detach "$pokemonsay_source_commit"
  [ "$(git -C "$pokemonsay_stage" rev-parse HEAD)" = "$pokemonsay_source_commit" ] || dotfiles_die "pokemonsay source did not resolve to the required commit."
  [ -d "$pokemonsay_stage/pokemons" ] || dotfiles_die "pokemonsay source payload is incomplete."
  cp "$DOTFILES_REPO_ROOT/script/libexec/pokemonsay-wrapper" "$pokemonsay_stage/dotfiles-pokemonsay"
  chmod 755 "$pokemonsay_stage/dotfiles-pokemonsay"
  : > "$pokemonsay_stage/.dotfiles-pokemonsay"
  ln -s "$pokemonsay_data_dir/dotfiles-pokemonsay" "$pokemonsay_launcher_stage"
  # Keep the existing payload until the staged payload is ready to activate.
  if [ -e "$pokemonsay_data_dir" ]; then
    pokemonsay_backup=$(mktemp -d "$pokemonsay_parent/.pokemonsay.backup.XXXXXX")
    rmdir "$pokemonsay_backup"
    mv "$pokemonsay_data_dir" "$pokemonsay_backup"
  fi
  # Roll back the payload if either activation step fails.
  if ! mv "$pokemonsay_stage" "$pokemonsay_data_dir" || ! mv -f "$pokemonsay_launcher_stage" "$pokemonsay_launcher"; then
    [ -e "$pokemonsay_data_dir" ] && rm -rf "$pokemonsay_data_dir"
    [ -z "$pokemonsay_backup" ] || mv "$pokemonsay_backup" "$pokemonsay_data_dir" || true
    dotfiles_die "Unable to activate pokemonsay; the previous payload was restored when possible."
  fi
  pokemonsay_stage=
  [ -z "$pokemonsay_backup" ] || rm -rf "$pokemonsay_backup"
  printf '%s\n' "pokemonsay is available at $pokemonsay_launcher"
}
