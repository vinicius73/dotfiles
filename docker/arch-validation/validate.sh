#!/bin/sh

set -eu

repo_root=/workspace

[ -d "$repo_root/.git" ] || {
  printf '%s\n' "Expected a repository mount at $repo_root." >&2
  exit 1
}

cd "$repo_root"

HOME=/tmp/dotfiles-home
export HOME
mkdir -p "$HOME"

validate_shell_syntax() {
  sh -n \
    script/bootstrap \
    script/profile \
    script/verify \
    script/validate-docker \
    script/lib/core.sh \
    script/lib/platform.sh \
    script/lib/xdg.sh \
    script/lib/manifests.sh \
    script/lib/packages.sh \
    script/lib/pokemonsay.sh \
    script/lib/shell-plugins.sh \
    script/lib/profiles/packages.sh \
    script/lib/profiles/development.sh \
    script/lib/profiles/shell.sh \
    script/lib/profiles/shell-plugins.sh \
    script/lib/profiles/shell-plugins-fish.sh \
    script/lib/profiles/shell-plugins-zsh.sh \
    script/libexec/pokemonsay-wrapper \
    maintenance/lib/common.sh \
    maintenance/clean-node-artifacts \
    maintenance/clean-go-artifacts \
    maintenance/clean-rust-artifacts \
    maintenance/audit-js-vulnerabilities \
    docker/arch-validation/validate.sh \
    home/dot_config/dotfiles/shell/env.sh \
    home/dot_config/dotfiles/shell/security.sh \
    home/dot_config/dotfiles/shell/declarations.sh \
    home/dot_config/dotfiles/shell/environment.sh \
    home/dot_config/dotfiles/shell/keychain.sh \
    home/dot_config/dotfiles/shell/configure.sh
  bash -n home/dot_bashrc
  zsh -n home/dot_zshrc
  fish --no-execute \
    home/dot_config/fish/config.fish \
    home/dot_config/fish/conf.d/git-extras.fish \
    home/dot_config/fish/functions/dotfiles_configure_shell.fish \
    home/dot_config/fish/functions/dotfiles_environment_secure.fish \
    home/dot_config/fish/functions/dotfiles_greeting.fish \
    home/dot_config/fish/functions/dotfiles_load_environment.fish \
    home/dot_config/fish/functions/dotfiles_load_environment_file.fish \
    home/dot_config/fish/functions/dotfiles_load_keychain_secrets.fish \
    home/dot_config/fish/functions/dotfiles_validate_secrets.fish \
    home/dot_config/fish/functions/fisher.fish
}

validate_shellcheck() {
  shellcheck -s sh -x -P home/dot_config/dotfiles/shell \
    script/bootstrap \
    script/profile \
    script/verify \
    script/validate-docker \
    script/lib/core.sh \
    script/lib/platform.sh \
    script/lib/xdg.sh \
    script/lib/manifests.sh \
    script/lib/packages.sh \
    script/lib/pokemonsay.sh \
    script/lib/shell-plugins.sh \
    script/lib/profiles/packages.sh \
    script/lib/profiles/development.sh \
    script/lib/profiles/shell.sh \
    script/lib/profiles/shell-plugins.sh \
    script/lib/profiles/shell-plugins-fish.sh \
    script/lib/profiles/shell-plugins-zsh.sh \
    script/libexec/pokemonsay-wrapper \
    maintenance/lib/common.sh \
    maintenance/clean-node-artifacts \
    maintenance/clean-go-artifacts \
    maintenance/clean-rust-artifacts \
    maintenance/audit-js-vulnerabilities \
    docker/arch-validation/validate.sh \
    home/dot_config/dotfiles/shell/env.sh
}

validate_brewfiles() {
  for brewfile in packages/macos/*.Brewfile; do
    ruby -c "$brewfile"
  done
}

validate_chezmoi() {
  temporary_home=$(mktemp -d)
  trap 'rm -rf "$temporary_home" "$temporary_config"' EXIT HUP INT TERM
  chezmoi --source "$repo_root/home" --destination "$temporary_home" apply
  chezmoi --source "$repo_root/home" --destination "$temporary_home" verify
  test -r "$temporary_home/.config/fish/quotes.txt"
  test -r "$temporary_home/.config/fish/conf.d/git-extras.fish"
  HOME="$temporary_home" fish -ic 'true' >/dev/null 2>&1
  HOME="$temporary_home" zsh -ic 'true' >/dev/null 2>&1
}

validate_mise() {
  temporary_config=$(mktemp -d)
  MISE_CONFIG_DIR="$temporary_config" mise trust "$repo_root/home/dot_config/mise/config.toml"
  MISE_CONFIG_DIR="$temporary_config" mise config ls --cd "$repo_root/home/dot_config/mise"
}

sh tests/run.sh
validate_shell_syntax
validate_shellcheck
validate_brewfiles
validate_chezmoi
validate_mise
