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
