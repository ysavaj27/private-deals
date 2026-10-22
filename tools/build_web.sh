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
    --output|--output=*|-o|-o=*)
      echo "Web hosting uses build/web; custom output directories are not supported by this wrapper." >&2
      exit 1
      ;;
    --build-name|--build-name=*|--build-number|--build-number=*)
      echo "Set the release version in pubspec.yaml instead of using $argument." >&2
      exit 1
      ;;
  esac
done
# Every build needs its own identity, even when pubspec.yaml is unchanged.
# Randomness also separates builds started in the same second/on different Macs.
release_id="$app_version-$(date -u +%Y%m%d%H%M%S)-$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
"$flutter_bin" build web --release "$@"
node --input-type=module - "$release_id" <<'NODE'
import { readFileSync, writeFileSync } from 'node:fs';
const path = 'build/web/version.json';
const metadata = JSON.parse(readFileSync(path, 'utf8'));
metadata.release_id = process.argv[2];
writeFileSync(path, JSON.stringify(metadata));
const htmlPath = 'build/web/index.html';
const html = readFileSync(htmlPath, 'utf8');
writeFileSync(htmlPath, html.replace(/(<meta name="app-version" content=")[^"]*(")/,
  `$1${metadata.release_id}$2`));
NODE
node tools/verify_web_build.mjs
echo "Web release $release_id is ready in build/web."
