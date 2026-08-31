#!/bin/sh

shell_plugins_fish_config() {
  shell_plugins_fish_config=$(dotfiles_xdg_home XDG_CONFIG_HOME "$HOME/.config")/fish
}

shell_plugins_validate_fish() {
  shell_plugins_fish_config
  shell_plugins_fish_declaration="$shell_plugins_fish_config/fish_plugins"
  [ -f "$shell_plugins_fish_declaration" ] && [ ! -L "$shell_plugins_fish_declaration" ] || dotfiles_die "Fish plugin declaration is missing or invalid: $shell_plugins_fish_declaration"
  cmp -s "$DOTFILES_REPO_ROOT/home/dot_config/fish/fish_plugins" "$shell_plugins_fish_declaration" || dotfiles_die "Fish plugin declaration differs from the managed source. Run script/bootstrap apply and review the diff."
}

shell_plugins_install_fish() {
  dotfiles_require_command fish
  shell_plugins_validate_fish
  fish -c 'fisher update'
}

shell_plugins_verify_fish() {
  shell_plugins_fish_config
  if command -v fish >/dev/null 2>&1 && [ -f "$shell_plugins_fish_config/fish_plugins" ] && cmp -s "$DOTFILES_REPO_ROOT/home/dot_config/fish/fish_plugins" "$shell_plugins_fish_config/fish_plugins" && fish -c 'fisher list' >/dev/null 2>&1; then
    printf '%s\n' "ok fish.plugins valid"
  else
    printf '%s\n' "skip fish.plugins not-installed"
  fi
}
