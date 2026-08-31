#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/project/node_modules/dependency" "$temporary_dir/project/.git" "$temporary_dir/bin"
: > "$temporary_dir/project/package.json"
: > "$temporary_dir/project/node_modules/dependency/package.json"
printf '#!/bin/sh\nexit 0\n' > "$temporary_dir/bin/npm"
chmod 755 "$temporary_dir/bin/npm"
output=$(PATH="$temporary_dir/bin:$PATH" "$repo_root/maintenance/audit-js-vulnerabilities" audit --root "$temporary_dir")
assert_contains "$output" "$temporary_dir/project"
case "$output" in *dependency*) fail "audit discovered a dependency manifest" ;; esac
