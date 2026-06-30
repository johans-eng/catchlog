#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flutter..."
if [ -f flutter-sdk/bin/flutter ]; then
  echo "Reusing cached Flutter SDK"
else
  rm -rf flutter-sdk
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
fi

export PATH="$PWD/flutter-sdk/bin:$PATH"

flutter --version
flutter config --no-analytics --enable-web
flutter precache --web
flutter pub get

BUILD_ARGS=(build web --release --no-wasm-dry-run)
if [ -n "${FIREBASE_API_KEY:-}" ]; then
  BUILD_ARGS+=(
    --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY"
    --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID"
    --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID"
    --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID"
  )
fi

flutter "${BUILD_ARGS[@]}"

cp web/_redirects build/web/_redirects
echo "Build complete: build/web"
