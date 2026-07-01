#!/usr/bin/env bash
set -euo pipefail

# Cached between Netlify builds via netlify-plugin-cache (see netlify.toml).
export PUB_CACHE="${PUB_CACHE:-$PWD/.pub-cache}"
mkdir -p "$PUB_CACHE"

FLUTTER_DIR="$PWD/flutter-sdk"
export PATH="$FLUTTER_DIR/bin:$PATH"

if [ -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Reusing cached Flutter SDK"
else
  echo "Downloading Flutter SDK (cache miss — slower build)..."
  rm -rf "$FLUTTER_DIR"
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_DIR"
fi

flutter --version

if [ ! -f "$FLUTTER_DIR/.web-precached" ]; then
  echo "Precaching Flutter web artifacts..."
  flutter config --no-analytics --enable-web
  flutter precache --web
  touch "$FLUTTER_DIR/.web-precached"
else
  echo "Skipping precache (cached)"
fi

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
