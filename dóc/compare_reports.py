from pathlib import Path
import zipfile,xml.etree.ElementTree as E,json,difflib,hashlib
from PIL import Image
root=Path.cwd(); out=root/'output'/'report_comparison'; out.mkdir(parents=True,exist_ok=True)
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
files=['WMSD_Report1.docx','WMSD_Report-3.docx','WMSD_Report1_Fix.docx','WMSD_Report3_Fix.docx']
all={}
for fn in files:
 with zipfile.ZipFile(root/fn) as z:
  tree=E.fromstring(z.read('word/document.xml')); body=tree.find('w:body',ns); blocks=[]
  for i,b in enumerate(body):
   if b.tag.endswith('}p'):
    txt=''.join(b.itertext()) if False else ''.join(t.text or '' for t in b.findall('.//w:t',ns))
    sty=b.find('w:pPr/w:pStyle',ns); style=sty.attrib.get('{'+ns['w']+'}val','') if sty is not None else ''
    if txt: blocks.append({'i':i,'type':'p','style':style,'text':txt})
   elif b.tag.endswith('}tbl'):
    rows=[]
    for row in b.findall('w:tr',ns):
     rows.append(['\n'.join(''.join(t.text or '' for t in p.findall('.//w:t',ns)) for p in c.findall('w:p',ns)) for c in row.findall('w:tc',ns)])
    blocks.append({'i':i,'type':'table','rows':rows,'text':'\n'.join(' | '.join(r) for r in rows)})
  all[fn]=blocks
  (out/(fn+'.json')).write_text(json.dumps(blocks,ensure_ascii=False,indent=2),encoding='utf-8')
  (out/(fn+'.txt')).write_text('\n\n'.join(f"[{b['i']}] {b.get('style',b['type'])}\n{b['text']}" for b in blocks),encoding='utf-8')
  print(fn,'blocks',len(blocks),'tables',sum(b['type']=='table' for b in blocks),'media',len([n for n in z.namelist() if n.startswith('word/media/')]),'tracked',len(tree.findall('.//w:ins',ns)),len(tree.findall('.//w:del',ns)))
for a,b in [(files[0],files[2]),(files[1],files[3])]:
 linesA=[x['text'] for x in all[a]]; linesB=[x['text'] for x in all[b]]
 (out/(a+'.diff.txt')).write_text('\n'.join(difflib.unified_diff('\n\n'.join(linesA).splitlines(),'\n\n'.join(linesB).splitlines(),fromfile=a,tofile=b)),encoding='utf-8')
 print(a,'headings',[(x['i'],x['text']) for x in all[b] if x.get('style','').startswith('Heading')])
for p in root.glob('*Bản sao*.png'):
 im=Image.open(p); print(p.name, im.size, list(im.info.keys()))
 if 'mxfile' in im.info: (out/(p.name+'.xml')).write_text(im.info['mxfile'],encoding='utf-8')
