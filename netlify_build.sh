#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PWD/flutter-sdk/bin:$PATH"

flutter --version
flutter config --no-analytics --enable-web
flutter precache --web
flutter pub get
flutter build web --release --no-wasm-dry-run

cp web/_redirects build/web/_redirects
echo "Build complete: build/web"
