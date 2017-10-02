# https://www.ostechnix.com/install-yaourt-arch-linux/

sudo pacman -S --needed base-devel git wget yajl --noconfirm && \
yaourt -S sublime-text-dev smartgit telegram-desktop-bin --noconfirm && \
yaourt -S nodejs npm  yarn --noconfirm && \
yaourt -S java-environment=8 --noconfirm && \
yaourt -S android-platform android-sdk android-sdk-platform-tools android-sdk-build-tools gradle --noconfirm && \
yaourt -S docker docker-compose --noconfirm && \
yaourt -S ttf-font powerline powerline-fonts fira-code-git ttf-liberation screenfetch figlet --noconfirm && \
yaourt -S pgadmin3 dbeaver redis-desktop-manager insomnia --noconfirm


# sudo groupadd docker && \
sudo usermod -aG docker $USER && \
sudo systemctl enable docker && \
sudo systemctl start docker
