#!/bin/sh
# https://www.ostechnix.com/install-yaourt-arch-linux/
# https://aur.archlinux.org/packages/yay-bin/

sudo pacman -Sy --needed base-devel git wget yajl --noconfirm
yay -S terminator fish cowsay htop --noconfirm
yay -S smartgit telegram-desktop --noconfirm
yay -S sublime-text-dev atom visual-studio-code-bin --noconfirm
yay -S nodejs npm yarn --noconfirm
yay -S ttf-font powerline powerline-fonts ttf-fira-code ttf-liberation screenfetch figlet --noconfirm
yay -S pgadmin3 dbeaver redis-desktop-manager insomnia --noconfirm
