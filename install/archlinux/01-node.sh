#!/usr/bin/env bash

# Exit on error, undefined variable, or pipeline failure
set -euo pipefail

# Install Volta (Node.js version manager) securely
curl --fail --silent https://get.volta.sh | bash

# Install Node.js LTS and Yarn using Volta
volta install node@lts
volta install yarn

npm install -g gitmoji-cli