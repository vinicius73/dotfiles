#!/bin/sh

shell_plugins_root() {
  shell_plugins_data_home=$(dotfiles_xdg_home XDG_DATA_HOME "$HOME/.local/share")
  case "$shell_plugins_data_home" in "$HOME"/*) ;; *) dotfiles_die "XDG data directory must be below HOME." ;; esac
  [ ! -e "$shell_plugins_data_home" ] || [ ! -L "$shell_plugins_data_home" ] || dotfiles_die "Refusing symlinked XDG data directory: $shell_plugins_data_home"
  shell_plugins_root_dir="$shell_plugins_data_home/dotfiles/shell"
  shell_plugins_lock="$DOTFILES_REPO_ROOT/home/dot_config/zsh/plugins.lock"
}

shell_plugins_validate_lock() {
  [ -s "$shell_plugins_lock" ] || dotfiles_die "Shell plugin lockfile is missing: $shell_plugins_lock"
  while IFS=' ' read -r shell_plugins_repository shell_plugins_commit shell_plugins_extra; do
    [ -n "$shell_plugins_repository" ] || continue
    [ -z "${shell_plugins_extra:-}" ] || dotfiles_die "Invalid shell plugin lockfile entry."
    case "$shell_plugins_repository" in [A-Za-z0-9_.-]*/[A-Za-z0-9_.-]*) ;; *) dotfiles_die "Invalid shell plugin repository." ;; esac
    if ! printf '%s\n' "$shell_plugins_commit" | grep -Eq '^[0-9a-f]{40}$'; then
      dotfiles_die "Shell plugin commits must be full lowercase SHA-1 values."
    fi
  done < "$shell_plugins_lock"
}

shell_plugins_install_zsh() {
  shell_plugins_root
  shell_plugins_validate_lock
  dotfiles_require_command git
  mkdir -p "$shell_plugins_root_dir"
  [ ! -L "$shell_plugins_root_dir" ] || dotfiles_die "Refusing symlinked shell plugin directory: $shell_plugins_root_dir"
  while IFS=' ' read -r shell_plugins_repository shell_plugins_commit; do
    [ -n "$shell_plugins_repository" ] || continue
    shell_plugins_name=${shell_plugins_repository##*/}
    shell_plugins_target="$shell_plugins_root_dir/$shell_plugins_name"
    shell_plugins_stage=$(mktemp -d "$shell_plugins_root_dir/.${shell_plugins_name}.stage.XXXXXX")
    trap 'rm -rf "${shell_plugins_stage:-}"' 0 HUP INT TERM
    git clone --no-checkout "https://github.com/$shell_plugins_repository.git" "$shell_plugins_stage"
    git -C "$shell_plugins_stage" checkout --detach "$shell_plugins_commit"
    [ "$(git -C "$shell_plugins_stage" rev-parse HEAD)" = "$shell_plugins_commit" ] || dotfiles_die "Shell plugin did not resolve to the required commit: $shell_plugins_repository"
    : > "$shell_plugins_stage/.dotfiles-shell-plugin"
    if [ -e "$shell_plugins_target" ] || [ -L "$shell_plugins_target" ]; then
      [ -d "$shell_plugins_target" ] && [ ! -L "$shell_plugins_target" ] && [ -f "$shell_plugins_target/.dotfiles-shell-plugin" ] || dotfiles_die "Refusing unmanaged shell plugin path: $shell_plugins_target"
      git -C "$shell_plugins_target" remote get-url origin | grep -Fx "https://github.com/$shell_plugins_repository.git" >/dev/null || dotfiles_die "Refusing unexpected shell plugin source: $shell_plugins_target"
      if ! git -C "$shell_plugins_target" diff --quiet || ! git -C "$shell_plugins_target" diff --cached --quiet || [ -n "$(git -C "$shell_plugins_target" status --porcelain --untracked-files=all | grep -v -E '^\?\? \.dotfiles-shell-plugin$' || true)" ]; then
        dotfiles_die "Refusing modified shell plugin path: $shell_plugins_target"
      fi
      shell_plugins_backup=$(mktemp -d "$shell_plugins_root_dir/.${shell_plugins_name}.backup.XXXXXX")
      rmdir "$shell_plugins_backup"
      mv "$shell_plugins_target" "$shell_plugins_backup"
    else
      shell_plugins_backup=
    fi
    if ! mv "$shell_plugins_stage" "$shell_plugins_target"; then
      [ -z "$shell_plugins_backup" ] || mv "$shell_plugins_backup" "$shell_plugins_target" || true
      dotfiles_die "Unable to activate shell plugin: $shell_plugins_repository"
    fi
    shell_plugins_stage=
    [ -z "$shell_plugins_backup" ] || rm -rf "$shell_plugins_backup"
  done < "$shell_plugins_lock"
}

shell_plugins_install_fish() {
  dotfiles_require_command fish
  fish_plugins_file="$HOME/.config/fish/fish_plugins"
  [ -f "$fish_plugins_file" ] || dotfiles_die "Fish plugin declaration is missing: $fish_plugins_file"
  fish -c 'fisher update'
}

shell_plugins_verify_zsh() {
  shell_plugins_root
  shell_plugins_validate_lock
  while IFS=' ' read -r shell_plugins_repository shell_plugins_commit; do
    [ -n "$shell_plugins_repository" ] || continue
    shell_plugins_target="$shell_plugins_root_dir/${shell_plugins_repository##*/}"
    if [ -d "$shell_plugins_target" ] && [ ! -L "$shell_plugins_target" ] && [ -f "$shell_plugins_target/.dotfiles-shell-plugin" ] && [ "$(git -C "$shell_plugins_target" rev-parse HEAD 2>/dev/null || true)" = "$shell_plugins_commit" ]; then
      printf '%-5s %s %s\n' ok "zsh.plugin.${shell_plugins_repository##*/}" "$shell_plugins_commit"
    else
      printf '%-5s %s %s\n' fail "zsh.plugin.${shell_plugins_repository##*/}" invalid
    fi
  done < "$shell_plugins_lock"
}

shell_plugins_verify_fish() {
  fish_plugins_file="$HOME/.config/fish/fish_plugins"
  if command -v fish >/dev/null 2>&1 && [ -f "$fish_plugins_file" ] && fish -c 'fisher list' >/dev/null 2>&1; then
    printf '%-5s %s %s\n' ok fish.plugins valid
  else
    printf '%-5s %s %s\n' skip fish.plugins not-installed
  fi
}

shell_plugins_plan() {
  shell_plugins_root
  shell_plugins_validate_lock
  printf '%s\n' "Fish plugins: $DOTFILES_REPO_ROOT/home/dot_config/fish/fish_plugins"
  printf '%s\n' "Vendored Fisher: a04308be92daa6cfecdbb0ca58b1e8508664cff2"
  printf '%s\n' "Zsh plugins: $shell_plugins_lock"
  printf '%s\n' "Managed Zsh data: $shell_plugins_root_dir"
}

shell_plugins_apply() {
  shell_plugins_plan
  shell_plugins_install_zsh
  shell_plugins_install_fish
}
