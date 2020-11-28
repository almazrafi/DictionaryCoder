#!/bin/sh

if [[ ! $CI && ! $SKIP_SWIFTLINT ]]; then
  if which swiftlint >/dev/null; then
    swiftlint --no-cache
  else
    echo "warning: SwiftLint does not exist, download it from https://github.com/realm/SwiftLint"
  fi
fi
