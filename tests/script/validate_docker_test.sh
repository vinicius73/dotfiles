#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/bin"
printf '#!/bin/sh\nexit 1\n' > "$temporary_dir/bin/docker"
chmod 755 "$temporary_dir/bin/docker"

if output=$(PATH="$temporary_dir/bin:$PATH" "$repo_root/script/validate-docker" 2>&1); then
  fail "validation unexpectedly succeeded without a Docker daemon"
fi
assert_contains "$output" "Docker daemon is unavailable"
