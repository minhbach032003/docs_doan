import sys,json,zipfile,hashlib
from pathlib import Path
from PIL import Image
sys.stdout.reconfigure(encoding='utf-8')
out=Path('output/report_comparison')
b=json.loads((out/'WMSD_Report3_Fix.docx.json').read_text(encoding='utf-8'))
for x in b:
 if 138<=x['i']<=174: print(f"[{x['i']}] {x['text']}")
for a,c in [('WMSD_Report1.docx','WMSD_Report1_Fix.docx'),('WMSD_Report-3.docx','WMSD_Report3_Fix.docx')]:
 with zipfile.ZipFile(a) as za,zipfile.ZipFile(c) as zc:
  ma={n:hashlib.sha256(za.read(n)).hexdigest() for n in za.namelist() if n.startswith('word/media/')}
  mc={n:hashlib.sha256(zc.read(n)).hexdigest() for n in zc.namelist() if n.startswith('word/media/')}
  print('MEDIA',a,c,'equal',ma==mc,'changed',[n for n in mc if mc[n]!=ma.get(n)])
for p in Path.cwd().glob('*Bản sao*.png'):
 im=Image.open(p); print('PNG',p.name, im.size,list(im.info.keys()))
 if 'mxfile' in im.info: (out/(p.name+'.xml')).write_text(im.info['mxfile'],encoding='utf-8')
