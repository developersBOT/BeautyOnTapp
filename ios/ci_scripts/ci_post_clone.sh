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
pod_install_attempt=1
while ! pod install; do
  if [ "$pod_install_attempt" -ge 3 ]; then
    echo "pod install failed after 3 attempts" >&2
    exit 1
  fi

  retry_delay=$((pod_install_attempt * 15))
  echo "pod install failed (attempt $pod_install_attempt/3); retrying in ${retry_delay}s..." >&2
  sleep "$retry_delay"
  pod_install_attempt=$((pod_install_attempt + 1))
done
