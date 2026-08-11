function dotfiles_greeting
  status is-interactive; or return
  test "$DOTFILES_GREETING_DISABLE" != 1; or return
  test "$DOTFILES_GREETING" = 1; or return
  test -t 0; and test -t 1; or return
  not set -q DOTFILES_GREETING_SHOWN; or return

  for variable in AGENT CI GITHUB_ACTIONS CLAUDECODE OPENCODE OPENCODE_PID VSCODE_INJECTION SSH_CONNECTION SSH_TTY
    set -q $variable; and return
  end

  test "$TERM" != dumb; or return
  test "$TERM_PROGRAM" != vscode; or return

  set -l bin_root "$XDG_BIN_HOME"
  test -n "$bin_root"; or set bin_root "$HOME/.local/bin"
  set -l data_root "$XDG_DATA_HOME"
  test -n "$data_root"; or set data_root "$HOME/.local/share"
  set -l launcher "$bin_root/pokemonsay"
  set -l wrapper "$data_root/dotfiles/pokemonsay/dotfiles-pokemonsay"
  test -L "$launcher"; and test (readlink "$launcher") = "$wrapper"; or return
  test -x "$wrapper"; or return

  set -l config_dir (path dirname (status filename))
  set -l quote_file "$config_dir/../quotes.txt"
  test -r "$quote_file"; or return

  set -l quotes
  while read -l quote
    test -n "$quote"; and set -a quotes "$quote"
  end < "$quote_file"
  test (count $quotes) -gt 0; or return

  set -l quote_index (random 1 (count $quotes))
  printf '%s\n' "$quotes[$quote_index]" | "$launcher" >/dev/tty 2>/dev/null; and set -gx DOTFILES_GREETING_SHOWN 1
end
