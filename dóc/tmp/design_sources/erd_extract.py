from zipfile import ZipFile
import xml.etree.ElementTree as E,pathlib
p=pathlib.Path('tmp/design_sources');ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main','a':'http://schemas.openxmlformats.org/drawingml/2006/main','r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
with ZipFile('tmp/design_sources/online_report3.docx') as z:
 rels={x.get('Id'):x.get('Target') for x in E.fromstring(z.read('word/_rels/document.xml.rels'))}
 r=E.fromstring(z.read('word/document.xml'));ps=r.findall('.//w:p',ns)
 for i,e in enumerate(ps):
  txt=''.join(t.text or '' for t in e.findall('.//w:t',ns))
  if 'Conceptual entity relationship diagram' in txt:
   for v in ps[max(0,i-8):i+1]:
    for b in v.findall('.//a:blip',ns):
     target=rels[b.get('{'+ns['r']+'}embed')];out=p/('erd_'+pathlib.Path(target).name);out.write_bytes(z.read('word/'+target));print(str(out))
