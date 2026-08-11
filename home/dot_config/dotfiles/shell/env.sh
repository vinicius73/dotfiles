dotfiles_shell_dir=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/shell

# shellcheck disable=SC1091
# shellcheck source=security.sh
. "$dotfiles_shell_dir/security.sh" || return 1
# shellcheck disable=SC1091
# shellcheck source=declarations.sh
. "$dotfiles_shell_dir/declarations.sh" || return 1
# shellcheck disable=SC1091
# shellcheck source=keychain.sh
. "$dotfiles_shell_dir/keychain.sh" || return 1
# shellcheck disable=SC1091
# shellcheck source=environment.sh
. "$dotfiles_shell_dir/environment.sh" || return 1
# shellcheck disable=SC1091
# shellcheck source=configure.sh
. "$dotfiles_shell_dir/configure.sh" || return 1
