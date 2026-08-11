function dotfiles_greeting
  status is-interactive; or return
  test "$DOTFILES_GREETING_DISABLE" != 1; or return
  test "$DOTFILES_GREETING" = 1; or return
  test -t 0; and test -t 1; or return
  not set -q DOTFILES_GREETING_SHOWN; or return

  for variable in AGENT CI GITHUB_ACTIONS CLAUDECODE OPENCODE OPENCODE_PID VSCODE_INJECTION SSH_CONNECTION SSH_TTY
    set -q $variable; and return
  end

  test "$TERM_PROGRAM" != vscode; or return
  type -q pokemonsay; or return

  set -l config_dir (path dirname (status filename))
  set -l quote_file "$config_dir/../quotes.txt"
  test -r "$quote_file"; or return

  set -l quotes
  while read -l quote
    test -n "$quote"; and set -a quotes "$quote"
  end < "$quote_file"
  test (count $quotes) -gt 0; or return

  set -gx DOTFILES_GREETING_SHOWN 1
  set -l quote_index (random 1 (count $quotes))
  printf '%s\n' "$quotes[$quote_index]" | command pokemonsay >/dev/tty 2>/dev/null
end
