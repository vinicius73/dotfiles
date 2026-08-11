dotfiles_config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles
dotfiles_env_dir=$dotfiles_config_dir/env.d
dotfiles_secrets_file=$dotfiles_config_dir/secrets.conf

dotfiles_env_stat() {
  if stat -f '%u:%Lp' "$1" >/dev/null 2>&1; then
    stat -f '%u:%Lp' "$1"
  else
    stat -c '%u:%a' "$1"
  fi
}

dotfiles_env_is_secure() {
  dotfiles_env_metadata=$(dotfiles_env_stat "$1") || return 1
  dotfiles_env_owner=${dotfiles_env_metadata%%:*}
  dotfiles_env_mode=${dotfiles_env_metadata#*:}
  [ "$dotfiles_env_owner" = "$(id -u)" ] || return 1
  case "$2:$dotfiles_env_mode" in
    directory:700|file:600) return 0 ;;
    *) return 1 ;;
  esac
}

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

dotfiles_load_keychain_secrets() {
  [ -r "$dotfiles_secrets_file" ] || return 0
  [ "$(uname -s)" = Darwin ] || return 0
  command -v security >/dev/null 2>&1 || return 0
  while IFS= read -r dotfiles_secret_name || [ -n "$dotfiles_secret_name" ]; do
    case "$dotfiles_secret_name" in ''|'#'*) continue ;; esac
    printenv "$dotfiles_secret_name" >/dev/null 2>&1 && continue
    dotfiles_secret_value=$(security find-generic-password -a "$USER" -s "$dotfiles_secret_name" -w 2>/dev/null) || continue
    [ -n "$dotfiles_secret_value" ] && export "$dotfiles_secret_name=$dotfiles_secret_value"
  done < "$dotfiles_secrets_file"
}

dotfiles_configure_shell() {
  : "${EDITOR:=micro}"
  : "${VISUAL:=$EDITOR}"
  export EDITOR VISUAL
  dotfiles_volta_bin=${VOLTA_HOME:-$HOME/.volta}/bin
  dotfiles_shell_path=$PATH:
  dotfiles_path_without_volta=
  dotfiles_path_separator=
  while :; do
    dotfiles_path_entry=${dotfiles_shell_path%%:*}
    dotfiles_shell_path=${dotfiles_shell_path#*:}
    if [ "$dotfiles_path_entry" != "$dotfiles_volta_bin" ]; then
      dotfiles_path_without_volta=${dotfiles_path_without_volta}${dotfiles_path_separator}${dotfiles_path_entry}
      dotfiles_path_separator=:
    fi
    [ -n "$dotfiles_shell_path" ] || break
  done
  PATH=$dotfiles_path_without_volta
  if [ "$(uname -s)" = Darwin ]; then
    for dotfiles_mysql_bin in /opt/homebrew/opt/mysql-client/bin /usr/local/opt/mysql-client/bin; do
      [ -d "$dotfiles_mysql_bin" ] || continue
    case ":$PATH:" in
      *":$dotfiles_mysql_bin:"*) ;;
      *) PATH=$dotfiles_mysql_bin:$PATH ;;
    esac
    break
    done
  fi
  export PATH
}

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
