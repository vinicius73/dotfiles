#!/bin/sh

shell_plugins_fish_config() {
  shell_plugins_fish_config=$(dotfiles_xdg_home XDG_CONFIG_HOME "$HOME/.config")/fish
}

shell_plugins_zsh_paths() {
  shell_plugins_cache_home=$(dotfiles_xdg_home XDG_CACHE_HOME "$HOME/.cache")
  shell_plugins_zsh_bundles="$DOTFILES_REPO_ROOT/home/dot_config/zsh/plugins.txt"
  shell_plugins_zsh_static="$shell_plugins_cache_home/dotfiles/zsh/plugins.zsh"
}

shell_plugins_antidote() {
  case "$(dotfiles_platform)" in
    macos)
      shell_plugins_brew=$(dotfiles_require_brew)
      shell_plugins_antidote=$("$shell_plugins_brew" --prefix antidote)/share/antidote/antidote.zsh
      ;;
    arch) shell_plugins_antidote=/usr/share/antidote/antidote.zsh ;;
  esac
  [ -r "$shell_plugins_antidote" ] || dotfiles_die "Antidote is unavailable. Install the cli profile first."
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

shell_plugins_install_zsh() {
  dotfiles_require_command zsh
  if [ "$(dotfiles_platform)" = arch ]; then
    shell_plugins_aur_manifest="$DOTFILES_REPO_ROOT/packages/arch/aur-shell-plugins.txt"
    dotfiles_validate_manifest "$shell_plugins_aur_manifest"
    dotfiles_confirm "Install the displayed AUR shell plugin packages."
    dotfiles_install_arch_manifest "$shell_plugins_aur_manifest"
  fi
  shell_plugins_zsh_paths
  shell_plugins_antidote
  [ -s "$shell_plugins_zsh_bundles" ] || dotfiles_die "Zsh plugin declaration is missing: $shell_plugins_zsh_bundles"
  mkdir -p "${shell_plugins_zsh_static%/*}"
  shell_plugins_stage=$(mktemp "${shell_plugins_zsh_static%/*}/.plugins.stage.XXXXXX")
  trap 'rm -f "${shell_plugins_stage:-}"' 0 HUP INT TERM
  ANTIDOTE_HOME="$shell_plugins_cache_home/antidote" zsh -fc "source \"$shell_plugins_antidote\"; antidote bundle < \"$shell_plugins_zsh_bundles\"" > "$shell_plugins_stage"
  [ -s "$shell_plugins_stage" ] || dotfiles_die "Antidote did not generate a Zsh plugin loader."
  mv -f "$shell_plugins_stage" "$shell_plugins_zsh_static"
  shell_plugins_stage=
}

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
  shell_plugins_fish_config
  shell_plugins_zsh_paths
  if command -v fish >/dev/null 2>&1 && [ -f "$shell_plugins_fish_config/fish_plugins" ] && cmp -s "$DOTFILES_REPO_ROOT/home/dot_config/fish/fish_plugins" "$shell_plugins_fish_config/fish_plugins" && fish -c 'fisher list' >/dev/null 2>&1; then
    result ok fish.plugins valid
  else
    result skip fish.plugins not-installed
  fi
  if [ -s "$shell_plugins_zsh_static" ]; then
    result ok zsh.plugins "$shell_plugins_zsh_static"
  else
    result skip zsh.plugins not-installed
  fi
}
