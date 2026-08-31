#!/bin/sh

. "$DOTFILES_REPO_ROOT/script/lib/profiles/shell-plugins-fish.sh"
. "$DOTFILES_REPO_ROOT/script/lib/profiles/shell-plugins-zsh.sh"

shell_plugins_plan() {
  shell_plugins_fish_config
  shell_plugins_zsh_paths
  printf '%s\n' "Fish plugins: $DOTFILES_REPO_ROOT/home/dot_config/fish/fish_plugins"
  printf '%s\n' "Zsh plugins: $shell_plugins_zsh_bundles"
  printf '%s\n' "Generated Zsh loader: $shell_plugins_zsh_static"
  if [ "$(dotfiles_platform)" = arch ]; then
    printf '%s\n' "AUR package: zsh-antidote"
  fi
  printf '%s\n' "Network access: Fisher and Antidote fetch missing pinned plugins."
}

shell_plugins_verify() {
  shell_plugins_verify_fish
  shell_plugins_verify_zsh
}
