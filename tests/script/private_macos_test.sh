#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
mkdir -p "$temporary_dir/private/home/dot_config/opencode" "$temporary_dir/bin" "$temporary_dir/home"
printf 'schema_version=1\nchezmoi_source=home\n' > "$temporary_dir/private/private-macos.conf"
printf '{}\n' > "$temporary_dir/private/home/dot_config/opencode/opencode.json"

cat > "$temporary_dir/bin/uname" <<'EOF'
#!/bin/sh
case "$1" in
  -s) printf '%s\n' Darwin ;;
  -m) printf '%s\n' arm64 ;;
esac
EOF
chmod 755 "$temporary_dir/bin/uname"

cat > "$temporary_dir/bin/chezmoi" <<'EOF'
#!/bin/sh
case "$1" in
  managed)
    case "$*" in
      *"$PRIVATE_SOURCE"*)
        printf '%s\n' "$HOME/.config/opencode/opencode.json"
        if [ -d "$PRIVATE_SOURCE/dot_agents" ]; then
          printf '%s\n' "$HOME/.agents/skills/private-skill/SKILL.md"
        fi
        ;;
      *) printf '%s\n' "$HOME/.bashrc" ;;
    esac
    ;;
  verify) exit 0 ;;
esac
EOF
chmod 755 "$temporary_dir/bin/chezmoi"

private_source=$(CDPATH='' cd -- "$temporary_dir/private/home" && pwd -P)
output=$(DOTFILES_REPO_ROOT="$repo_root" HOME="$temporary_dir/home" PRIVATE_SOURCE="$private_source" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/private-macos.sh"; private_macos_require_platform; private_macos_load_manifest "$2"; private_macos_validate_targets; printf "%s" "$private_macos_source_dir"' sh "$repo_root" "$temporary_dir/private")
assert_equals "$output" "$private_source"

mkdir -p "$temporary_dir/private/home/dot_agents/skills/private-skill"
printf '%s\n' '# Private skill' > "$temporary_dir/private/home/dot_agents/skills/private-skill/SKILL.md"
if DOTFILES_REPO_ROOT="$repo_root" HOME="$temporary_dir/home" PRIVATE_SOURCE="$private_source" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/private-macos.sh"; private_macos_load_manifest "$2"; private_macos_validate_targets' sh "$repo_root" "$temporary_dir/private" >/dev/null 2>&1; then
  fail "private agent path unexpectedly succeeded"
fi
rm -rf "$temporary_dir/private/home/dot_agents"

cat > "$temporary_dir/bin/chezmoi" <<'EOF'
#!/bin/sh
case "$1" in
  managed) printf '%s\n' "$HOME/.config/opencode/opencode.json" ;;
  verify) exit 0 ;;
esac
EOF
chmod 755 "$temporary_dir/bin/chezmoi"

if DOTFILES_REPO_ROOT="$repo_root" HOME="$temporary_dir/home" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/private-macos.sh"; private_macos_load_manifest "$2"; private_macos_validate_targets' sh "$repo_root" "$temporary_dir/private" >/dev/null 2>&1; then
  fail "conflicting private target unexpectedly succeeded"
fi

cat > "$temporary_dir/bin/chezmoi" <<'EOF'
#!/bin/sh
case "$1" in
  managed) printf '%s\n' "$HOME/.config/opencode/opencode.json" ;;
  verify) exit 1 ;;
esac
EOF
chmod 755 "$temporary_dir/bin/chezmoi"

if DOTFILES_REPO_ROOT="$repo_root" HOME="$temporary_dir/home" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/private-macos.sh"; private_macos_public_configuration_valid' sh "$repo_root" >/dev/null 2>&1; then
  fail "private verification unexpectedly accepted missing public configuration"
fi

cat > "$temporary_dir/bin/uname" <<'EOF'
#!/bin/sh
case "$1" in
  -s) printf '%s\n' Linux ;;
  -m) printf '%s\n' x86_64 ;;
esac
EOF
chmod 755 "$temporary_dir/bin/uname"

if DOTFILES_REPO_ROOT="$repo_root" PATH="$temporary_dir/bin:$PATH" sh -c '. "$1/script/lib/private-macos.sh"; private_macos_require_platform' sh "$repo_root" >/dev/null 2>&1; then
  fail "private extension unexpectedly succeeded on Linux"
fi
