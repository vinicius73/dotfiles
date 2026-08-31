#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin" "$temporary_dir/pokemons"
cp "$repo_root/script/libexec/pokemonsay-wrapper" "$temporary_dir/dotfiles-pokemonsay"
chmod 755 "$temporary_dir/dotfiles-pokemonsay"
: > "$temporary_dir/pokemons/example.cow"
printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$temporary_dir/bin/cowsay"
chmod 755 "$temporary_dir/bin/cowsay"
output=$(PATH="$temporary_dir/bin:$PATH" "$temporary_dir/dotfiles-pokemonsay" --cowfile example.cow -- hello)
assert_contains "$output" "hello"
if PATH="$temporary_dir/bin:$PATH" "$temporary_dir/dotfiles-pokemonsay" --cowfile ../escape.cow >/dev/null 2>&1; then fail "traversal was accepted"; fi
