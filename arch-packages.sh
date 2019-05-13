#!/usr/bin/env bash

# https://aur.archlinux.org/packages/yay-bin/

sudo pacman -Sy --needed base-devel git wget yajl --noconfirm && \
yay -S terminator fish fzf cowsay htop screenfetch figlet --noconfirm && \
yay -S git-extras ctop-bin gotop-bin --noconfirm && \
yay -S nodejs npm yarn --noconfirm && \
yay -S gitkraken sublime-text-dev atom visual-studio-code-bin --noconfirm && \
yay -S telegram-desktop slack-desktop spotify --noconfirm && \
yay -S ttf-font powerline powerline-fonts noto-fonts-emoji ttf-fira-code ttf-liberation --noconfirm && \
yay -S dbeaver insomnia --noconfirm
