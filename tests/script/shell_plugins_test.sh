#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

fish_plugins="$repo_root/home/dot_config/fish/fish_plugins"
zsh_plugins="$repo_root/home/dot_config/zsh/plugins.txt"

[ -s "$fish_plugins" ] || fail "missing Fish plugin declaration"
while IFS= read -r plugin; do
  if ! printf '%s\n' "$plugin" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@[0-9a-f]{40}$'; then
    fail "invalid Fish plugin pin: $plugin"
  fi
done < "$fish_plugins"

[ -s "$zsh_plugins" ] || fail "missing Zsh plugin declaration"
while IFS= read -r plugin; do
  if ! printf '%s\n' "$plugin" | grep -Eq '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+( path:[A-Za-z0-9_./-]+)? pin:[0-9a-f]{40}$'; then
    fail "invalid Zsh plugin pin: $plugin"
  fi
done < "$zsh_plugins"

if grep -Eq 'curl|fisher (install|update)|antidote (bundle|load|update)|git (clone|pull)' "$repo_root/home/dot_config/fish/config.fish" "$repo_root/home/dot_zshrc"; then
  fail "shell startup must not install or update plugins"
fi

[ -f "$repo_root/packages/arch/aur-shell-plugins.txt" ] || fail "missing Arch AUR shell plugin manifest"
grep -Fqx 'zsh-antidote' "$repo_root/packages/arch/aur-shell-plugins.txt" || fail "missing Arch Antidote package"
grep -Fqx 'brew "antidote"' "$repo_root/packages/macos/cli.Brewfile" || fail "missing macOS Antidote package"
if ! grep -Fqx 'zsh' "$repo_root/packages/arch/base.txt" || ! grep -Fqx 'brew "zsh"' "$repo_root/packages/macos/base.Brewfile"; then
  fail "Zsh must be declared on both platforms"
fi

for package in bat eza fd fzf ghq git-extras; do
  grep -Fqx "$package" "$repo_root/packages/arch/cli.txt" || fail "missing Arch CLI package: $package"
  grep -Fqx "brew \"$package\"" "$repo_root/packages/macos/cli.Brewfile" || fail "missing macOS CLI package: $package"
done
