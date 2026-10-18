import sys,json,zipfile,xml.etree.ElementTree as E,hashlib,io
from pathlib import Path
from PIL import Image,ImageOps,ImageDraw
sys.stdout.reconfigure(encoding='utf-8'); out=Path('output/report_comparison')
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main','a':'http://schemas.openxmlformats.org/drawingml/2006/main','r':'http://schemas.openxmlformats.org/officeDocument/2006/relationships'}
for fn in ['WMSD_Report1.docx','WMSD_Report1_Fix.docx','WMSD_Report-3.docx','WMSD_Report3_Fix.docx']:
 folder=out/fn.replace('.docx','_media');folder.mkdir(exist_ok=True)
 with zipfile.ZipFile(fn) as z:
  rels={r.attrib['Id']:r.attrib['Target'] for r in E.fromstring(z.read('word/_rels/document.xml.rels'))}
  tree=E.fromstring(z.read('word/document.xml')); heading=''; ims=[]
  for i,p in enumerate(tree.find('w:body',ns)):
   txt=''.join(t.text or '' for t in p.findall('.//w:t',ns)); style=p.find('w:pPr/w:pStyle',ns)
   if style is not None and 'Heading' in str(style.attrib): heading=txt
   for blip in p.findall('.//a:blip',ns):
    target=rels.get(blip.get('{'+ns['r']+'}embed'),''); data=z.read('word/'+target); path=folder/Path(target).name;path.write_bytes(data)
    im=Image.open(io.BytesIO(data)).convert('RGB');ims.append((i,heading,path,im.copy()))
    print(fn,i,heading,Path(target).name,im.size)
  if 'Fix' in fn:
   sheet=Image.new('RGB',(1200,((len(ims)+3)//4)*350),'#dedede');d=ImageDraw.Draw(sheet)
   for j,(idx,h,path,im) in enumerate(ims):
    im.thumbnail((290,310)); x=(j%4)*300;y=(j//4)*350;sheet.paste(im,(x+(300-im.width)//2,y+30));d.text((x+5,y+5),f'{idx} {path.name}',fill='black')
   sheet.save(folder/'contact.png')
for a,b in [('WMSD_Report1.docx','WMSD_Report1_Fix.docx'),('WMSD_Report-3.docx','WMSD_Report3_Fix.docx')]:
 with zipfile.ZipFile(a) as za,zipfile.ZipFile(b) as zb:
  same=[];diff=[]
  for n in za.namelist():
   if not n.startswith('word/media/'):continue
   ia=Image.open(io.BytesIO(za.read(n))).convert('RGBA');ib=Image.open(io.BytesIO(zb.read(n))).convert('RGBA')
   (same if ia.size==ib.size and ia.tobytes()==ib.tobytes() else diff).append(n)
  print('PIXEL MATCH',a,'same',same,'different',diff)
