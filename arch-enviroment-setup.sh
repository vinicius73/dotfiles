# https://www.ostechnix.com/install-yaourt-arch-linux/

sudo pacman -S --needed base-devel git wget yajl --noconfirm && \
yaourt -S sublime-text-dev smartgit telegram-desktop-bin && \
yaourt -S nodejs npm  yarn && \
yaourt -S java-environment=8 --noconfirm && \
yaourt -S android-platform android-sdk android-sdk-platform-tools android-sdk-build-tools gradle --noconfirm && \
yaourt -S docker docker-compose --noconfirm && \
yaourt -S ttf-font powerline powerline-fonts fira-code-git screenfetch figlet --noconfirm && \
yaourt -S yarn --noconfirm


sudo groupadd docker && \
sudo usermod -aG docker $USER && \
sudo systemctl enable docker && \
sudo systemctl start docker
