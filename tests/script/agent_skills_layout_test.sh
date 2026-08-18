#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

skills_dir="$repo_root/home/dot_agents/skills"
[ -d "$skills_dir" ] || fail "missing global skills directory: $skills_dir"

for local_skill_name in orca-cli orchestration; do
  assert_path_absent "$skills_dir/$local_skill_name"
done

for skill_dir in "$skills_dir"/*; do
  [ -d "$skill_dir" ] || fail "unexpected global skill entry: $skill_dir"
  [ ! -L "$skill_dir" ] || fail "global skill must not be a symlink: $skill_dir"

  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  assert_file_exists "$skill_file"
  [ ! -L "$skill_file" ] || fail "global skill file must not be a symlink: $skill_file"

  expected_name="name: $skill_name"
  if ! grep -Fqx "$expected_name" "$skill_file"; then
    fail "global skill name does not match its directory: $skill_dir"
  fi

  if ! grep -Eq '^description:[[:space:]]*([^[:space:]]|>[-+]?)' "$skill_file"; then
    fail "global skill has no description: $skill_file"
  fi
done

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
local_skill="$temporary_dir/home/.agents/skills/orca-cli/SKILL.md"
mkdir -p "$(dirname "$local_skill")"
printf '%s\n' 'local Orca skill' > "$local_skill"
chezmoi --source "$repo_root/home" --destination "$temporary_dir/home" apply
assert_file_exists "$temporary_dir/home/.agents/skills/address-pr-comments/SKILL.md"
assert_equals "$(cat "$local_skill")" "local Orca skill"
managed_targets=$(chezmoi managed --source "$repo_root/home" --destination "$temporary_dir/home" --include files,symlinks --path-style absolute)
assert_not_contains "$managed_targets" "$local_skill"
chezmoi --source "$repo_root/home" --destination "$temporary_dir/home" verify
