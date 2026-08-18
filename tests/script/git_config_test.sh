#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
temporary_dir=$(CDPATH='' cd -- "$temporary_dir" && pwd -P)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
home="$temporary_dir/home"
public_config="$home/.gitconfig"
public_identity_include=$(printf '%s' '~'/.config/git/identity.local)
private_config="$home/.config/git/identity.local"
work_config="$home/.config/git/identities/work.local"

file_mode() {
  if stat -f '%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%Lp' "$1"
  else
    stat -c '%a' "$1"
  fi
}

mkdir -p "$home/.config/git/identities" "$temporary_dir/personal/project" "$temporary_dir/work/project"
chmod 700 "$home/.config/git" "$home/.config/git/identities"

cp "$repo_root/home/dot_gitconfig" "$public_config"
cp "$repo_root/home/dot_config/git/identity.local.example" "$temporary_dir/identity.local.example"

assert_equals "$(git config --file "$public_config" --get include.path)" "$public_identity_include"
if git config --file "$public_config" --get-regexp '^url\.' >/dev/null 2>&1; then
  fail "public configuration unexpectedly rewrites remote URLs"
fi
if git config --file "$temporary_dir/identity.local.example" --get commit.gpgsign >/dev/null 2>&1; then
  fail "identity example unexpectedly enables commit signing"
fi
assert_path_absent "$private_config"
assert_equals "$(HOME="$home" git config --global --get pull.rebase)" "false"

cat > "$private_config" <<EOF
[user]
	name = Default User
	email = default@example.com
	signingkey = DEFAULT_OPENPGP_FINGERPRINT
[commit]
	gpgsign = true
[tag]
	gpgSign = true
[gpg]
	format = openpgp
[includeIf "gitdir:$temporary_dir/work/"]
	path = ~/.config/git/identities/work.local
EOF
chmod 600 "$private_config"

cat > "$work_config" <<'EOF'
[user]
	name = Work User
	email = work@example.com
	signingkey = WORK_OPENPGP_FINGERPRINT
EOF
chmod 600 "$work_config"

for repository in "$temporary_dir/personal/project" "$temporary_dir/work/project"; do
  git -C "$repository" init -q
done

assert_equals "$(file_mode "$home/.config/git")" "700"
assert_equals "$(file_mode "$home/.config/git/identities")" "700"
assert_equals "$(file_mode "$private_config")" "600"
assert_equals "$(file_mode "$work_config")" "600"

output=$(HOME="$home" git -C "$temporary_dir/personal/project" config --show-origin --show-scope --includes --get-regexp '^(user|commit|tag|gpg)\.')
assert_contains "$output" "file:$private_config	user.email default@example.com"
assert_not_contains "$output" "work@example.com"
assert_contains "$output" "file:$private_config	gpg.format openpgp"
assert_equals "$(HOME="$home" git -C "$temporary_dir/personal/project" config --get user.email)" "default@example.com"

output=$(HOME="$home" git -C "$temporary_dir/work/project" config --show-origin --show-scope --includes --get-regexp '^(user|commit|tag|gpg)\.')
assert_contains "$output" "file:$work_config	user.email work@example.com"
assert_contains "$output" "file:$private_config	commit.gpgsign true"
assert_contains "$output" "file:$private_config	tag.gpgsign true"
assert_equals "$(HOME="$home" git -C "$temporary_dir/work/project" config --get user.email)" "work@example.com"
