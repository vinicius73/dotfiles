#!/bin/sh

profile_shell_plugins_plan() {
  shell_plugins_plan
}

profile_shell_plugins_apply() {
  shell_plugins_install_fish
  shell_plugins_install_zsh
}
