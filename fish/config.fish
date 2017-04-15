source ~/dotfiles/fish/commands.fish
source ~/dotfiles/fish/env.fish

function fish_greeting
  # figlet "Vinicius Reis"
  screenfetch -E
end

# echo -ne "($red)Hoje é:\t\t($cyan)" `date`; echo ""
# echo -e "($red)Kernel: \t($cyan)" `uname -smr`
# echo -ne "($cyan)";upinfo;echo ""
# echo -e "($cyan)"; cal -3
