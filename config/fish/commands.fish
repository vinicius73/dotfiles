if type -q exa
  alias ll "exa -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso"
  alias la "exa -l -g --icons --octal-permissions --no-permissions --no-user -s type --time-style long-iso -a"
  alias lla "ll -a"
end

# elixir
function iex
  docker run -it -v $HOME:/root --rm elixir
end

function elixir
  docker run -it --rm --name elixir-inst1 -v (pwd):/usr/src/myapp -w /usr/src/myapp elixir elixir $argv
end
