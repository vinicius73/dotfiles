#!/usr/bin/env bash
yay -Sy java-environment=8 gradle --noconfirm --needed  && \
ysy -S android-studio --noconfirm --needed && \
yay -S android-platform android-sdk android-sdk-platform-tools android-sdk-build-tools --noconfirm --needed && \
