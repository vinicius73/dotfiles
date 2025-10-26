#!/usr/bin/env bash
paru -Sy docker docker-compose --noconfirm --needed && \
mkdir $HOME/.docker && \
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R && \
sudo chmod g+rwx "$HOME/.docker" -R && \
sudo usermod -aG docker $USER && \
sudo systemctl enable docker.service && \
sudo systemctl enable containerd.service
