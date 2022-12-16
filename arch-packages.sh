#!/usr/bin/env bash

# https://aur.archlinux.org/packages/paru-bin

sudo pacman -Sy --needed base-devel git --noconfirm && \
paru -S terminator alacritty fish pv fzf cowsay htop screenfetch figlet --noconfirm --needed && \
paru -S git-extras ctop-bin gotop-bin --noconfirm --needed && \
paru -S nodejs npm yarn --noconfirm --needed && \
paru -S visual-studio-code-bin 1password --noconfirm --needed && \
paru -S telegram-desktop --noconfirm --needed && \
paru -S ttf-font powerline powerline-fonts noto-fonts-emoji ttf-fira-code ttf-liberation --noconfirm --needed && \
paru -S libratbag piper --noconfirm  --needed && \
paru -S peco ghq micro exa --noconfirm --needed

# paru -S dbeaver insomnia-bin --noconfirm  --needed