import pathlib,json,math
from PIL import Image,ImageOps,ImageDraw,ImageFont
import pdfplumber
p=pathlib.Path('tmp/pdfs/wmsd_final');files=sorted(p.glob('page-*.png'))
for k in range(0,len(files),4):
 imgs=[]
 for f in files[k:k+4]:
  im=Image.open(f).convert('RGB');im.thumbnail((700,990));canvas=Image.new('RGB',(720,1025),'#d9e1e6');canvas.paste(im,((720-im.width)//2,25));ImageDraw.Draw(canvas).text((10,6),f.stem,fill='black');imgs.append(canvas)
 sheet=Image.new('RGB',(1440,2050),'#aebbc4')
 for j,im in enumerate(imgs):sheet.paste(im,((j%2)*720,(j//2)*1025))
 sheet.save(p/f'contact-{k//4+1:02}.png')
issues=[];stats=[]
with pdfplumber.open('output/pdf/WMSD_Thiet_ke_he_thong_chi_tiet.pdf') as pdf:
 for i,page in enumerate(pdf.pages,1):
  chars=page.chars;body=[c for c in chars if 40<c['top']<page.height-40]
  bad=[c['text'] for c in body if c['x0']<42 or c['x1']>page.width-42]
  if bad:issues.append({'page':i,'out_of_margin':''.join(bad)})
  stats.append({'page':i,'chars':len(chars),'bottom':round(max([c['bottom'] for c in body] or [0]),1)})
print(json.dumps({'pngs':len(files),'issues':issues,'pages':stats},ensure_ascii=False))
