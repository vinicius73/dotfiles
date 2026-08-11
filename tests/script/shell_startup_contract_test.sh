#!/bin/sh

set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
. "$repo_root/tests/lib/assert.sh"

temporary_dir=$(mktemp -d)
trap 'rm -rf "$temporary_dir"' 0 HUP INT TERM
home="$temporary_dir/home"
mkdir -p "$home/.config/dotfiles/shell" "$temporary_dir/bin"
printf '%s\n' '#!/bin/sh' 'printf Darwin' > "$temporary_dir/bin/uname"
chmod 755 "$temporary_dir/bin/uname"

assert_configure_shell() {
  shell_name=$1
  command=$2
  output=$(HOME="$home" VOLTA_HOME="$home/volta" PATH="$temporary_dir/bin:/before:$home/volta/bin:/after" "$shell_name" -c "$command" 2>/dev/null)
  assert_contains "$output" 'micro:micro:'
  assert_not_contains "$output" "$home/volta/bin"

  for mysql_bin in /opt/homebrew/opt/mysql-client/bin /usr/local/opt/mysql-client/bin; do
    if [ -d "$mysql_bin" ]; then
      case "$output" in "micro:micro:$mysql_bin:"*) ;; *) fail "$shell_name did not prepend mysql-client on macOS" ;; esac
      return
    fi
  done
}

sh_path=$(command -v sh)
zsh_path=$(command -v zsh)
fish_path=$(command -v fish)

assert_configure_shell "$sh_path" ". '$repo_root/home/dot_config/dotfiles/shell/configure.sh'; dotfiles_configure_shell; printf '%s:%s:%s' \"\$EDITOR\" \"\$VISUAL\" \"\$PATH\""
assert_configure_shell "$zsh_path" ". '$repo_root/home/dot_config/dotfiles/shell/configure.sh'; dotfiles_configure_shell; printf '%s:%s:%s' \"\$EDITOR\" \"\$VISUAL\" \"\$PATH\""
assert_configure_shell "$fish_path" "source '$repo_root/home/dot_config/fish/functions/dotfiles_configure_shell.fish'; dotfiles_configure_shell; printf '%s:%s:%s' \"\$EDITOR\" \"\$VISUAL\" \"\$PATH\""

printf '%s\n' 'printf secret-loader-ran' > "$home/.config/dotfiles/shell/env.sh"
output=$(HOME="$home" bash --noprofile --norc -c "source '$repo_root/home/dot_bashrc'" 2>&1)
assert_not_contains "$output" 'secret-loader-ran'
output=$(HOME="$home" zsh -f -c "source '$repo_root/home/dot_zshrc'" 2>&1)
assert_not_contains "$output" 'secret-loader-ran'
output=$(fish --no-config -c "function dotfiles_load_environment; printf secret-loader-ran; end; source '$repo_root/home/dot_config/fish/config.fish'" 2>&1)
assert_not_contains "$output" 'secret-loader-ran'
