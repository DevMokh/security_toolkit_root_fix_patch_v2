from pathlib import Path
import sys, xml.etree.ElementTree as ET
if len(sys.argv) != 2:
    raise SystemExit('Usage: verify_android_embedding.py <flutter-project-root>')
root_dir=Path(sys.argv[1]).resolve()
manifest=root_dir/'android/app/src/main/AndroidManifest.xml'
if not manifest.is_file(): raise SystemExit(f'ERROR: Missing {manifest}')
ns='http://schemas.android.com/apk/res/android'; root=ET.parse(manifest).getroot()
apps=root.findall('application')
if len(apps)!=1: raise SystemExit(f'ERROR: Expected one application element, found {len(apps)}')
app=apps[0]
if app.get(f'{{{ns}}}name')=='io.flutter.app.FlutterApplication': raise SystemExit('ERROR: Legacy FlutterApplication V1 detected')
values=[x.get(f'{{{ns}}}value') for x in app.findall('meta-data') if x.get(f'{{{ns}}}name')=='flutterEmbedding']
if values!=['2']: raise SystemExit(f'ERROR: Expected one flutterEmbedding=2, got {values!r}')
main=root_dir/'android/app/src/main/kotlin/com/security/toolkit/MainActivity.kt'
if not main.is_file() or 'io.flutter.embedding.android.FlutterActivity' not in main.read_text():
    raise SystemExit(f'ERROR: V2 MainActivity missing/invalid: {main}')
print(f'PASS: Android V2 embedding verified in {root_dir}')
