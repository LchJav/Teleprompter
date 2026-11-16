#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
BUILD_TMP="$DIST_DIR/.build"
APP_BUNDLE="$DIST_DIR/Teleprompter.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
SINGLE_HTML="$DIST_DIR/Teleprompter.html"

export TMPDIR="/tmp"
export CLANG_MODULE_CACHE_PATH="$BUILD_TMP/ModuleCache"

rm -rf "$BUILD_TMP" "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES" "$BUILD_TMP" "$CLANG_MODULE_CACHE_PATH"

echo "1/4 Generando Teleprompter.html autocontenido..."
python3 - "$ROOT_DIR" "$SINGLE_HTML" <<'PYEOF'
import sys
from pathlib import Path
from urllib.parse import quote

root = Path(sys.argv[1])
out_file = Path(sys.argv[2])

html = (root / "index.html").read_text(encoding="utf-8")
css = (root / "style.css").read_text(encoding="utf-8")
js = (root / "script.js").read_text(encoding="utf-8")

svg_icon = (
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
    '<rect width="64" height="64" rx="14" fill="#0b0b0c"/>'
    '<rect x="2" y="2" width="60" height="60" rx="12" fill="none" stroke="#2a2a2d" stroke-width="2"/>'
    '<rect x="10" y="29" width="44" height="3" fill="#3fb8a6" opacity="0.35"/>'
    '<polygon points="10,24 20,30.5 10,37" fill="#3fb8a6"/>'
    '<rect x="24" y="18" width="28" height="4" rx="2" fill="#8a8a8f" opacity="0.6"/>'
    '<rect x="24" y="28" width="30" height="4" rx="2" fill="#f4f4f2"/>'
    '<rect x="24" y="38" width="22" height="4" rx="2" fill="#f4f4f2"/>'
    '<rect x="24" y="48" width="26" height="4" rx="2" fill="#8a8a8f" opacity="0.6"/>'
    '</svg>'
)
favicon_tag = f'  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,{quote(svg_icon)}">'

css_link = '<link rel="stylesheet" href="style.css">'
js_tag = '<script src="script.js"></script>'

if css_link not in html or js_tag not in html:
    raise SystemExit("No se encontraron las referencias a style.css o script.js en index.html")

html = html.replace(css_link, f"{favicon_tag}\n  <style>\n{css}\n  </style>", 1)
html = html.replace(js_tag, f"<script>\n{js}\n  </script>", 1)

out_file.write_text(html, encoding="utf-8")
PYEOF

echo "2/4 Generando icono de la app..."
swift -module-cache-path "$CLANG_MODULE_CACHE_PATH" "$ROOT_DIR/macos/GenerateIcon.swift" "$APP_RESOURCES/AppIcon.icns"

echo "3/4 Compilando wrapper nativo macOS (WKWebView)..."
swiftc -O \
  -module-cache-path "$CLANG_MODULE_CACHE_PATH" \
  -framework Cocoa \
  -framework WebKit \
  "$ROOT_DIR/macos/TeleprompterApp.swift" \
  -o "$APP_MACOS/Teleprompter"

echo "4/4 Empaquetando Teleprompter.app..."
cp "$SINGLE_HTML" "$APP_RESOURCES/Teleprompter.html"

cat > "$APP_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>es</string>
  <key>CFBundleDisplayName</key>
  <string>Teleprompter</string>
  <key>CFBundleExecutable</key>
  <string>Teleprompter</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>com.teleprompter.app</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Teleprompter</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>12.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true
fi

rm -rf "$BUILD_TMP"

echo "Listo:"
echo "  - $APP_BUNDLE"
echo "  - $SINGLE_HTML"
