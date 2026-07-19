#!/bin/sh

set -eu

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Pin the exact Flutter release used by the tested app instead of tracking
# a moving stable branch.
git clone https://github.com/flutter/flutter.git \
  --depth 1 \
  --branch 3.41.2 \
  "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

export HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods

cd ios
pod install
