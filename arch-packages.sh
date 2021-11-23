#!/usr/bin/env bash

# https://aur.archlinux.org/packages/yay-bin/

sudo pacman -Sy --needed base-devel git wget yajl --noconfirm && \
yay -S terminator fish pv fzf cowsay htop screenfetch figlet --noconfirm --needed && \
yay -S git-extras ctop-bin gotop-bin --noconfirm --needed && \
yay -S nodejs npm yarn --noconfirm --needed && \
yay -S sublime-text-dev atom visual-studio-code-bin --noconfirm --needed && \
yay -S telegram-desktop slack-desktop spotify --noconfirm --needed && \
yay -S ttf-font powerline powerline-fonts noto-fonts-emoji ttf-fira-code ttf-liberation --noconfirm --needed && \
yay -S dbeaver insomnia-bin libratbag piper --noconfirm  --needed && \
yay -S peco ghq micro --noconfirm --needed