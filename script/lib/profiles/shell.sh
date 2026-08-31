#!/bin/sh

profile_shell_plan() {
  printf '%s\n' "Sets Fish as the login shell after separate confirmations."
}

profile_shell_apply() {
  profile_shell_fish_bin=$(command -v fish) || dotfiles_die "Fish is not installed. Run script/bootstrap apply first."
  if ! grep -Fx "$profile_shell_fish_bin" /etc/shells >/dev/null 2>&1; then
    dotfiles_confirm "Add $profile_shell_fish_bin to /etc/shells."
    printf '%s\n' "$profile_shell_fish_bin" | sudo tee -a /etc/shells >/dev/null
  fi
  dotfiles_confirm "Change your login shell to $profile_shell_fish_bin."
  chsh -s "$profile_shell_fish_bin"
}
