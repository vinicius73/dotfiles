dotfiles_load_environment() {
  [ -e "$dotfiles_config_dir" ] || return 0
  if [ ! -d "$dotfiles_config_dir" ] || [ -L "$dotfiles_config_dir" ] || ! dotfiles_env_is_secure "$dotfiles_config_dir" directory; then
    printf '%s\n' 'dotfiles: refusing insecure dotfiles configuration directory' >&2
    return 0
  fi
  dotfiles_validate_secrets || return 0
  [ -e "$dotfiles_env_dir" ] || { dotfiles_load_keychain_secrets; return 0; }
  if [ ! -d "$dotfiles_env_dir" ] || [ -L "$dotfiles_env_dir" ] || ! dotfiles_env_is_secure "$dotfiles_env_dir" directory; then
    printf '%s\n' 'dotfiles: refusing insecure environment directory' >&2
    dotfiles_load_keychain_secrets
    return 0
  fi

  for dotfiles_env_file in "$dotfiles_env_dir"/*.env; do
    [ -e "$dotfiles_env_file" ] || continue
    if [ ! -f "$dotfiles_env_file" ] || [ -L "$dotfiles_env_file" ] || ! dotfiles_env_is_secure "$dotfiles_env_file" file; then
      printf '%s\n' "dotfiles: refusing insecure environment file: ${dotfiles_env_file##*/}" >&2
      continue
    fi

    dotfiles_env_valid=1
    while IFS= read -r dotfiles_env_line || [ -n "$dotfiles_env_line" ]; do
      case "$dotfiles_env_line" in ''|'#'*) continue ;; esac
      case "$dotfiles_env_line" in *=*) ;; *) dotfiles_env_valid=0; break ;; esac
      dotfiles_env_name=${dotfiles_env_line%%=*}
      dotfiles_env_value=${dotfiles_env_line#*=}
      case "$dotfiles_env_name" in [A-Za-z_]* ) ;; *) dotfiles_env_valid=0; break ;; esac
      case "$dotfiles_env_name" in *[!A-Za-z0-9_]* ) dotfiles_env_valid=0; break ;; esac
      case "$dotfiles_env_value" in *'"'*|*'`'*|*'$'*|*\\*) dotfiles_env_valid=0; break ;; esac
      dotfiles_secret_is_declared "$dotfiles_env_name" || { dotfiles_env_valid=0; break; }
    done < "$dotfiles_env_file"

    if [ "$dotfiles_env_valid" -ne 1 ]; then
      printf '%s\n' "dotfiles: refusing invalid environment file: ${dotfiles_env_file##*/}" >&2
      continue
    fi

    while IFS= read -r dotfiles_env_line || [ -n "$dotfiles_env_line" ]; do
      case "$dotfiles_env_line" in ''|'#'*) continue ;; esac
      dotfiles_env_name=${dotfiles_env_line%%=*}
      dotfiles_env_value=${dotfiles_env_line#*=}
      export "$dotfiles_env_name=$dotfiles_env_value"
    done < "$dotfiles_env_file"
  done
  dotfiles_load_keychain_secrets
}
