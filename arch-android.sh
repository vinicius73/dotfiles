#!/usr/bin/env bash
paru -Sy java-environment=8 gradle --noconfirm --needed  && \
paru -S android-studio --noconfirm --needed && \
paru -S android-platform android-sdk android-sdk-platform-tools android-sdk-build-tools --noconfirm --needed && \
