#!/usr/bin/env bash

fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" && \
fish -c "fisher install jethrokuan/fzf" && \
fish -c "fisher install edc/bass" && \
fish -c "fisher install franciscolourenco/done" && \
fish -c "fisher install jethrokuan/z" && \
fish -c "fisher install rafaelrinaldi/pure"
