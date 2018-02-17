source ~/dotfiles/fish/commands.fish
source ~/dotfiles/fish/env.fish

set welcomeFile "$HOME/dotfiles/bash/welcome.sh" 

function fish_greeting
  cal -3
  bash $welcomeFile
end