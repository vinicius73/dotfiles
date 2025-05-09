##############################################################################
#   Filename: .bashrc                                                        #
# Maintainer: Michael J. Smalley <michaeljsmalley@gmail.com>                 #
#        URL: http://github.com/michaeljsmalley/dotfiles                     #
#                                                                            #
#                                                                            #
# Sections:                                                                  #
#   01. General ................. General Bash behavior                      #
#   02. Aliases ................. Aliases                                    #
#   03. Theme/Colors ............ Colors, prompts, fonts, etc.               #
##############################################################################

##############################################################################
# 01. General                                                                #
##############################################################################
# Shell prompt
#export PS1="\n\[\e[0;36m\]┌─[\[\e[0m\]\[\e[1;33m\]\u\[\e[0m\]\[\e[1;36m\] @ \[\e[0m\]\[\e[1;33m\]\h\[\e[0m\]\[\e[0;36m\]]─[\[\e[0m\]\[\e[1;34m\]\w\[\e[0m\]\[\e[0;36m\]]\[\e[0;36m\]─[\[\e[0m\]\[\e[0;31m\]\t\[\e[0m\]\[\e[0;36m\]]\[\e[0m\]\n\[\e[0;36m\]└─[\[\e[0m\]\[\e[1;37m\]\$\[\e[0m\]\[\e[0;36m\]]› \[\e[0m\]"

export GOPATH=~/projects/go
export PATH=$PATH:~/bin
export DOTFILES=$HOME/dotfiles
export ANSIBLE_NOCOWS=1

##############################################################################
# 03. Theme/Colors                                                           #
##############################################################################
# CLI Colors
export CLICOLOR=1
# Set "ls" colors
export LSCOLORS=Gxfxcxdxbxegedabagacad

black='\e[0;30m'
blue='\e[0;34m'
green='\e[0;32m'
cyan='\e[0;36m'
red='\e[0;31m'
purple='\e[0;35m'
brown='\e[0;33m'
lightgray='\e[0;37m'
darkgray='\e[1;30m'
lightblue='\e[1;34m'
lightgreen='\e[1;32m'
lightcyan='\e[1;36m'
lightred='\e[1;31m'
lightpurple='\e[1;35m'
yellow='\e[1;33m'
white='\e[1;37m'
nc='\e[0m'
#------------------------------------------////
# Functions and Scripts:
#------------------------------------------////

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL=ignoreboth
export VISUAL="subl3"

# EXTRA
export FONTCONFIG_FILE=/etc/fonts/

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

# https://github.com/denisidoro/navi#shell-widget
[[ -s "~/bin/nav" ]] && source "$(navi widget bash)" # ctrl+g

source $DOTFILES/bash/docker-alias.bash
source $DOTFILES/bash/ambientum.bash

#------------------------------------------////
# Some default .bashrc contents:
#------------------------------------------////

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

#------------------------------------------////
# Prompt:
#------------------------------------------////
# sh history settings
# export HISTFILESIZE=1000000
# export HISTSIZE=100000
# export HISTCONTROL=ignorespace
# export HISTIGNORE='ls:history:ll'
# export HISTTIMEFORMAT='%F %T '


#------------------------------------------////
# System Information:
#------------------------------------------////

upinfo ()
{
  echo -ne "${green}$HOSTNAME ${red}uptime is ${cyan} \t ";uptime | awk /'up/ {print $3,$4,$5,$6,$7,$8,$9,$10}'
}

clear
echo -e "${LIGHTGRAY}"; figlet "Vinicius Reis";
echo -ne "${red}Hoje é:\t\t${cyan}" `date`; echo ""
echo -e "${red}Kernel: \t${cyan}" `uname -smr`
echo -ne "${cyan}";upinfo;echo ""
echo -e "${cyan}"; cal -3

[[ -s "$DOTFILES/bash/envs.bash" ]] && source "$DOTFILES/bash/envs.bash"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '${DOTFILES}/google-cloud-sdk/path.bash.inc' ]; then . '${DOTFILES}/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '${DOTFILES}/google-cloud-sdk/completion.bash.inc' ]; then . '${DOTFILES}/google-cloud-sdk/completion.bash.inc'; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


if [ -d "$HOME/.deno" ]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

if [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi


[ -d "$HOME/.cargo" ] && 
if [ -d "$HOME/.volta" ]; then
  export VOLTA_HOME="$HOME/.volta"
  # it will manage npm global installs
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

export GPG_TTY=$(tty)
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi
