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
