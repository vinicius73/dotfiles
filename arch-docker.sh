#!/usr/bin/env bash
yay -Sy docker docker-compose --noconfirm --needed

sudo usermod -aG docker $USER && \
sudo systemctl enable docker && \
sudo systemctl start docker
