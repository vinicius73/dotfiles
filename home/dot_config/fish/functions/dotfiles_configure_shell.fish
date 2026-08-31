function dotfiles_configure_shell
  if not set -q EDITOR
    set -gx EDITOR micro
  end
  if not set -q VISUAL
    set -gx VISUAL "$EDITOR"
  end

  set -l volta_bin "$HOME/.volta/bin"
  if set -q VOLTA_HOME
    set volta_bin "$VOLTA_HOME/bin"
  end
  set -gx PATH (string match -v -- "$volta_bin" $PATH)

  if test (uname) = Darwin
    for mysql_bin in /opt/homebrew/opt/mysql-client/bin /usr/local/opt/mysql-client/bin
      if test -d "$mysql_bin"
        contains -- "$mysql_bin" $PATH; or set -gx PATH "$mysql_bin" $PATH
        break
      end
    end
  end
end
