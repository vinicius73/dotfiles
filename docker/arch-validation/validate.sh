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

sh tests/run.sh

sh -n \
  script/bootstrap \
  script/profile \
  script/verify \
  script/lib/dotfiles.sh \
  script/lib/pokemonsay.sh \
  script/lib/shell-plugins.sh \
  script/libexec/pokemonsay-wrapper \
  maintenance/clean-node-artifacts \
  maintenance/clean-go-artifacts \
  maintenance/clean-rust-artifacts \
  maintenance/audit-js-vulnerabilities \
  home/dot_config/dotfiles/shell/env.sh
bash -n home/dot_bashrc
zsh -n home/dot_zshrc
shellcheck -s sh \
  script/bootstrap \
  script/profile \
  script/verify \
  script/lib/dotfiles.sh \
  script/lib/pokemonsay.sh \
  script/lib/shell-plugins.sh \
  script/libexec/pokemonsay-wrapper \
  maintenance/clean-node-artifacts \
  maintenance/clean-go-artifacts \
  maintenance/clean-rust-artifacts \
  maintenance/audit-js-vulnerabilities \
  home/dot_config/dotfiles/shell/env.sh
fish --no-execute \
  home/dot_config/fish/config.fish \
  home/dot_config/fish/conf.d/git-extras.fish \
  home/dot_config/fish/functions/dotfiles_greeting.fish \
  home/dot_config/fish/functions/dotfiles_load_environment.fish \
  home/dot_config/fish/functions/fisher.fish

for brewfile in packages/macos/*.Brewfile; do
  ruby -c "$brewfile"
done

temporary_home=$(mktemp -d)
temporary_config=
trap 'rm -rf "$temporary_home" "$temporary_config"' EXIT HUP INT TERM
chezmoi --source "$repo_root/home" --destination "$temporary_home" apply
chezmoi --source "$repo_root/home" --destination "$temporary_home" verify
test -r "$temporary_home/.config/fish/quotes.txt"
test -r "$temporary_home/.config/fish/conf.d/git-extras.fish"
HOME="$temporary_home" fish -ic 'true' >/dev/null 2>&1
HOME="$temporary_home" zsh -ic 'true' >/dev/null 2>&1

temporary_config=$(mktemp -d)
MISE_CONFIG_DIR="$temporary_config" mise trust "$repo_root/home/dot_config/mise/config.toml"
MISE_CONFIG_DIR="$temporary_config" mise config ls --cd "$repo_root/home/dot_config/mise"
