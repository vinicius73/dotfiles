# https://www.ostechnix.com/install-yaourt-arch-linux/

sudo pacman -S --needed base-devel git wget yajl --noconfirm &
yaourt -S java-environment=8 --noconfirm &
yaourt -S android-platform android-sdk android-sdk-platform-tools android-sdk-build-tools --noconfirm &
yaourt -S docker docker-compose --noconfirm
yaourt -S ttf-font powerline powerline-fonts fira-code-git screenfetch figlet --noconfirm
yaourt -S yarn --noconfirm &


sudo groupadd docker &
sudo usermod -aG docker $USER
