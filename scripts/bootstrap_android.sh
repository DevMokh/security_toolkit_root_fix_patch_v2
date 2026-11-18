#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bootstrap_android.sh <flutter-project-root>" >&2
  exit 2
fi
ROOT="$(realpath "$1")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
[[ -f pubspec.yaml ]] || { echo "ERROR: pubspec.yaml not found in $ROOT" >&2; exit 1; }
[[ -f lib/main.dart ]] || { echo "ERROR: lib/main.dart not found in $ROOT" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
for item in lib test assets; do [[ ! -e "$item" ]] || cp -a "$item" "$TMP_DIR/"; done
for item in pubspec.yaml pubspec.lock analysis_options.yaml README.md; do [[ ! -f "$item" ]] || cp -a "$item" "$TMP_DIR/"; done
if [[ -f android/app/src/main/AndroidManifest.xml ]]; then
  cp -a android/app/src/main/AndroidManifest.xml "$TMP_DIR/AndroidManifest.xml"
fi
rm -rf android
flutter create --platforms=android --org com.security --project-name security_toolkit --overwrite .
for item in lib test assets; do
  if [[ -e "$TMP_DIR/$item" ]]; then rm -rf "$item"; cp -a "$TMP_DIR/$item" "$item"; fi
done
for item in pubspec.yaml pubspec.lock analysis_options.yaml README.md; do [[ ! -f "$TMP_DIR/$item" ]] || cp -a "$TMP_DIR/$item" "$item"; done
if [[ -f "$TMP_DIR/AndroidManifest.xml" ]]; then
  cp -a "$TMP_DIR/AndroidManifest.xml" android/app/src/main/AndroidManifest.xml
fi
python3 - <<'PYCODE'
from pathlib import Path
import re
for p in (Path('android/app/build.gradle.kts'), Path('android/app/build.gradle')):
    if not p.is_file():
        continue
    s=p.read_text(encoding='utf-8')
    if p.suffix == '.kts':
        s=re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', 'applicationId = "com.security.toolkit"', s, count=1)
        s=re.sub(r'namespace\s*=\s*["\'][^"\']+["\']', 'namespace = "com.security.toolkit"', s, count=1)
    else:
        s=re.sub(r'applicationId\s+["\'][^"\']+["\']', 'applicationId "com.security.toolkit"', s, count=1)
        s=re.sub(r'namespace\s+["\'][^"\']+["\']', 'namespace "com.security.toolkit"', s, count=1)
    p.write_text(s, encoding='utf-8')
    break
else:
    raise SystemExit('ERROR: Generated Android Gradle file not found.')
PYCODE
find android/app/src/main -type f \( -name MainActivity.kt -o -name MainActivity.java \) -delete
MAIN_DIR=android/app/src/main/kotlin/com/security/toolkit
mkdir -p "$MAIN_DIR"
cat > "$MAIN_DIR/MainActivity.kt" <<'KOTLIN'
package com.security.toolkit

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
KOTLIN
python3 "$SCRIPT_DIR/repair_android_manifest.py"
echo "Android regenerated for $ROOT with V2 embedding."
