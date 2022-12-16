#!/usr/bin/env bash
paru -Sy docker docker-compose --noconfirm --needed

sudo usermod -aG docker $USER && \
sudo systemctl enable docker && \
sudo systemctl start docker
