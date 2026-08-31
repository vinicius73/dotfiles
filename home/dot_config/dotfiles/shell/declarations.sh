dotfiles_config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles
dotfiles_env_dir=$dotfiles_config_dir/env.d
dotfiles_secrets_file=$dotfiles_config_dir/secrets.conf

dotfiles_secret_is_declared() {
  while IFS= read -r dotfiles_secret_name || [ -n "$dotfiles_secret_name" ]; do
    case "$dotfiles_secret_name" in ''|'#'*) continue ;; esac
    [ "$dotfiles_secret_name" = "$1" ] && return 0
  done < "$dotfiles_secrets_file"
  return 1
}

dotfiles_validate_secrets() {
  [ -e "$dotfiles_secrets_file" ] || return 0
  if [ ! -f "$dotfiles_secrets_file" ] || [ -L "$dotfiles_secrets_file" ] || ! dotfiles_env_is_secure "$dotfiles_secrets_file" file; then
    printf '%s\n' 'dotfiles: refusing insecure secrets declaration' >&2
    return 1
  fi
  while IFS= read -r dotfiles_secret_name || [ -n "$dotfiles_secret_name" ]; do
    case "$dotfiles_secret_name" in ''|'#'*) continue ;; esac
    case "$dotfiles_secret_name" in [A-Za-z_]* ) ;; *) printf '%s\n' 'dotfiles: refusing invalid secrets declaration' >&2; return 1 ;; esac
    case "$dotfiles_secret_name" in *[!A-Za-z0-9_]* ) printf '%s\n' 'dotfiles: refusing invalid secrets declaration' >&2; return 1 ;; esac
  done < "$dotfiles_secrets_file"
}
