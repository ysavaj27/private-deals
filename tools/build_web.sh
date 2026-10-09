#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${FLUTTER_BIN:-}" ]]; then
  flutter_bin="$FLUTTER_BIN"
elif [[ -x .flutter-sdk/bin/flutter ]]; then
  flutter_bin=.flutter-sdk/bin/flutter
else
  flutter_bin=flutter
fi
# Read the top-level pubspec version, allowing quotes and a trailing comment.
app_version="$(awk '/^version:[[:space:]]*/ {
  sub(/^version:[[:space:]]*/, "")
  sub(/[[:space:]]+#.*$/, "")
  gsub(/[[:space:]\042\047]/, "")
  print
  exit
}' pubspec.yaml)"
if [[ ! "$app_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-][0-9A-Za-z.-]+)?([+][0-9A-Za-z.-]+)?$ ]]; then
  echo "Set a valid version in pubspec.yaml, for example 1.2.0+15." >&2
  exit 1
fi
# Keep the stamped version and Flutter's version.json consistent.
for argument in "$@"; do
  case "$argument" in
    --build-name|--build-name=*|--build-number|--build-number=*)
      echo "Set the release version in pubspec.yaml instead of using $argument." >&2
      exit 1
      ;;
  esac
done
"$flutter_bin" build web --release "$@" --web-define="APP_VERSION=$app_version"
echo "Web release $app_version is ready in build/web."
