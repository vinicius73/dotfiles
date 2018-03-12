# https://www.ostechnix.com/install-yaourt-arch-linux/
# https://aur.archlinux.org/packages/yay-bin/

sudo pacman -Sy --needed base-devel git wget yajl --noconfirm && \
yay -S terminator fish cowsay htop --noconfirm && \
yay -S sublime-text-dev smartgit telegram-desktop-bin --noconfirm && \
yay -S nodejs npm yarn --noconfirm && \
yay -S docker docker-compose --noconfirm && \
yay -S ttf-font powerline powerline-fonts ttf-fira-code-git ttf-liberation screenfetch figlet --noconfirm && \
yay -S pgadmin3 dbeaver redis-desktop-manager insomnia --noconfirm


# sudo groupadd docker && \
sudo usermod -aG docker $USER && \
sudo systemctl enable docker && \
sudo systemctl start docker
