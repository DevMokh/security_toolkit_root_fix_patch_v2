from pathlib import Path
import xml.etree.ElementTree as ET
p=Path('android/app/src/main/AndroidManifest.xml')
ns='http://schemas.android.com/apk/res/android'; ET.register_namespace('android',ns)
t=ET.parse(p); r=t.getroot(); app=r.find('application')
if app is None: raise SystemExit('ERROR: Manifest has no application element')
a=lambda k:f'{{{ns}}}{k}'
if app.get(a('name'))=='io.flutter.app.FlutterApplication': app.attrib.pop(a('name'),None)
md=[x for x in app.findall('meta-data') if x.get(a('name'))=='flutterEmbedding']
for x in md[1:]: app.remove(x)
n=md[0] if md else ET.SubElement(app,'meta-data')
n.set(a('name'),'flutterEmbedding'); n.set(a('value'),'2')
app.set(a('label'),'Security Toolkit'); app.set(a('usesCleartextTraffic'),'false')
t.write(p,encoding='utf-8',xml_declaration=True)
print('Manifest normalized to V2.')
