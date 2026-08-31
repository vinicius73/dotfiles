#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin"
printf '#!/bin/sh\ncase "$1" in -s) printf "Darwin\\n" ;; -m) printf "arm64\\n" ;; esac\n' > "$temporary_dir/bin/uname"
printf '#!/bin/sh\nexit 0\n' > "$temporary_dir/bin/brew"
chmod 755 "$temporary_dir/bin/uname" "$temporary_dir/bin/brew"
output=$(PATH="$temporary_dir/bin:$PATH" "$repo_root/script/bootstrap" plan)
assert_contains "$output" "Platform: macos"
assert_contains "$output" "packages/macos/base.Brewfile"
