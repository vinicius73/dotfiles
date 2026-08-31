#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin"
printf '#!/bin/sh\ncase "$1" in -s) printf "Linux\\n" ;; -m) printf "x86_64\\n" ;; esac\n' > "$temporary_dir/bin/uname"
printf '#!/bin/sh\nexit 0\n' > "$temporary_dir/bin/paru"
chmod 755 "$temporary_dir/bin/uname" "$temporary_dir/bin/paru"
: > "$temporary_dir/arch-release"

output=$(DOTFILES_ARCH_RELEASE_FILE="$temporary_dir/arch-release" PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" plan cli)
assert_contains "$output" "Platform: arch"
assert_contains "$output" "packages/arch/cli.txt"
assert_contains "$output" "git-extras"

output=$(DOTFILES_ARCH_RELEASE_FILE="$temporary_dir/arch-release" PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" plan shell-plugins)
assert_contains "$output" "AUR package: zsh-antidote"

output=$(DOTFILES_ARCH_RELEASE_FILE="$temporary_dir/arch-release" PATH="$temporary_dir/bin:$PATH" "$repo_root/script/profile" plan rust)
assert_contains "$output" "packages/arch/rust.txt"

for profile_module in \
  packages.sh \
  development.sh \
  shell.sh \
  shell-plugins.sh \
  shell-plugins-fish.sh \
  shell-plugins-zsh.sh; do
  [ -f "$repo_root/script/lib/profiles/$profile_module" ] || fail "missing profile module: $profile_module"
done
