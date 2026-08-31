#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin" "$temporary_dir/config/fish" "$temporary_dir/cache/dotfiles/zsh"
printf '#!/bin/sh\nexit 0\n' > "$temporary_dir/bin/fish"
printf '#!/bin/sh\ncase "$1" in -s) printf "Darwin\\n" ;; -m) printf "arm64\\n" ;; esac\n' > "$temporary_dir/bin/uname"
cp "$repo_root/home/dot_config/fish/fish_plugins" "$temporary_dir/config/fish/fish_plugins"
printf '%s\n' 'loader' > "$temporary_dir/cache/dotfiles/zsh/plugins.zsh"
chmod 755 "$temporary_dir/bin/fish" "$temporary_dir/bin/uname"

output=$(DOTFILES_REPO_ROOT="$repo_root" HOME="$temporary_dir" XDG_CONFIG_HOME="$temporary_dir/config" XDG_CACHE_HOME="$temporary_dir/cache" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/core.sh"; . "$1/script/lib/platform.sh"; . "$1/script/lib/xdg.sh"; . "$1/script/lib/packages.sh"; . "$1/script/lib/shell-plugins.sh"; shell_plugins_verify' sh "$repo_root")
assert_contains "$output" "ok fish.plugins valid"
assert_contains "$output" "ok zsh.plugins $temporary_dir/cache/dotfiles/zsh/plugins.zsh"
