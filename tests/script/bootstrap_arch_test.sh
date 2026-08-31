#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin"
printf '#!/bin/sh\ncase "$1" in -s) printf "Linux\\n" ;; -m) printf "x86_64\\n" ;; esac\n' > "$temporary_dir/bin/uname"
printf '#!/bin/sh\nexit 99\n' > "$temporary_dir/bin/paru"
chmod 755 "$temporary_dir/bin/uname" "$temporary_dir/bin/paru"
: > "$temporary_dir/arch-release"
output=$(DOTFILES_ARCH_RELEASE_FILE="$temporary_dir/arch-release" PATH="$temporary_dir/bin:$PATH" "$repo_root/script/bootstrap" plan)
assert_contains "$output" "Platform: arch"
assert_contains "$output" "Base packages:"
