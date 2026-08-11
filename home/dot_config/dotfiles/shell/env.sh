dotfiles_env_dir=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/env.d

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

dotfiles_load_environment() {
  [ -e "$dotfiles_env_dir" ] || return 0
  if [ ! -d "$dotfiles_env_dir" ] || [ -L "$dotfiles_env_dir" ] || ! dotfiles_env_is_secure "$dotfiles_env_dir" directory; then
    printf '%s\n' "dotfiles: refusing insecure environment directory" >&2
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
}
