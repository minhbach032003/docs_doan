import pathlib,re,html,json
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.platypus import BaseDocTemplate,PageTemplate,Frame,Paragraph,Spacer,PageBreak,Table,TableStyle,Image,KeepTogether,CondPageBreak
from reportlab.platypus.tableofcontents import TableOfContents
from PIL import Image as PILImage
from pypdf import PdfReader
root=pathlib.Path.cwd();out=root/'output';pdfdir=out/'pdf';pdfdir.mkdir(exist_ok=True)
for name,file in [('Arial','arial.ttf'),('Arial-Bold','arialbd.ttf'),('Arial-Italic','ariali.ttf'),('Arial-BoldItalic','arialbi.ttf')]:pdfmetrics.registerFont(TTFont(name,'C:/Windows/Fonts/'+file))
pdfmetrics.registerFontFamily('Arial',normal='Arial',bold='Arial-Bold',italic='Arial-Italic',boldItalic='Arial-BoldItalic')
W,H=A4;M=43;CW=W-2*M
styles={
'body':ParagraphStyle('body',fontName='Arial',fontSize=10.1,leading=14.5,spaceAfter=6.5,splitLongWords=True),
'h1':ParagraphStyle('h1',fontName='Arial-Bold',fontSize=16,leading=21,spaceBefore=15,spaceAfter=9,keepWithNext=False,textColor=colors.HexColor('#17354A')),
'h2':ParagraphStyle('h2',fontName='Arial-Bold',fontSize=12.2,leading=17,spaceBefore=11,spaceAfter=6,keepWithNext=False,textColor=colors.HexColor('#17354A')),
'cell':ParagraphStyle('cell',fontName='Arial',fontSize=8.7,leading=12.3,spaceAfter=0,splitLongWords=True),
'th':ParagraphStyle('th',fontName='Arial-Bold',fontSize=8.8,leading=12.3,textColor=colors.white),
'title':ParagraphStyle('title',fontName='Arial-Bold',fontSize=30,leading=38,textColor=colors.black,spaceAfter=24),
'sub':ParagraphStyle('sub',fontName='Arial',fontSize=13,leading=19,spaceAfter=16,textColor=colors.HexColor('#456071')),
'small':ParagraphStyle('small',fontName='Arial',fontSize=8.5,leading=12,spaceAfter=5,textColor=colors.HexColor('#52616B')),
'bullet':ParagraphStyle('bullet',fontName='Arial',fontSize=10.1,leading=14.5,spaceAfter=6,leftIndent=12,firstLineIndent=-9),
}
def rich(t):
 t=html.escape(t)
 t=re.sub(r'\*\*(.+?)\*\*',r'<b>\1</b>',t)
 t=re.sub(r'`([^`]+)`',r'<font name="Arial">\1</font>',t)
 t=re.sub(r'(https://[^\s]+)',lambda m:f'<link href="{m[1].rstrip(".")}" color="#195B83">{m[1].rstrip(".")}</link>'+('.' if m[1].endswith('.') else ''),t)
 return t
class Doc(BaseDocTemplate):
 def __init__(self,*a,**kw):
  super().__init__(*a,**kw);self.addPageTemplates(PageTemplate(id='all',frames=[Frame(M,47,CW,H-94,id='normal',leftPadding=0,rightPadding=0,topPadding=0,bottomPadding=0)],onPage=self.page))
 def page(self,c,d):
  if d.page>1:
   c.setFont('Arial',8);c.setFillColor(colors.HexColor('#62717A'));c.drawString(M,H-27,'WMSD  |  Thiết kế hệ thống chi tiết');c.drawRightString(W-M,H-27,'16/10/2026')
  c.setFont('Arial',8);c.setFillColor(colors.HexColor('#62717A'));c.drawString(M,27,'Tân Thương  •  Phạm vi một cửa hàng');c.drawRightString(W-M,27,str(d.page))
 def afterFlowable(self,f):
  if isinstance(f,Paragraph) and f.style.name=='h1':
   text=f.getPlainText();key='s'+str(abs(hash(text)));self.canv.bookmarkPage(key);self.canv.addOutlineEntry(text,key,level=0,closed=False);self.notify('TOCEntry',(0,text,self.page,key))
text=(out/'WMSD_Thiet_ke_he_thong_chi_tiet.md').read_text(encoding='utf-8');lines=text.splitlines()
story=[Spacer(1,60),Paragraph('Thiết kế hệ thống WMSD',styles['title']),Paragraph('Quản lý kho và hoàn tất đơn hàng<br/>Cửa hàng điện nước gạch ốp lát Tân Thương',styles['sub']),Spacer(1,20),Paragraph('Phiên bản 1.0 • Ngày 16 tháng 10 năm 2026',styles['body']),Spacer(1,18),Paragraph(rich(lines[4]),styles['body']),Spacer(1,18),Paragraph('Phạm vi tài liệu',styles['h2']),Paragraph('14 nhóm luồng xử lý • 102 use case • 27 màn hình<br/>58 quy tắc tổng hợp • 42 kịch bản nghiệm thu',styles['body']),Spacer(1,10),Paragraph('Cơ sở: Report 1, Report 3 và bộ sơ đồ draw.io được chọn.<br/>ERD giữ theo hình trong Report 3. Đề xuất kỹ thuật và quyết định cần chốt được phân biệt trong nội dung.',styles['body']),PageBreak(),Paragraph('Mục lục',styles['h2'])]
toc=TableOfContents();toc.levelStyles=[ParagraphStyle('toc',fontName='Arial',fontSize=10.1,leading=15,spaceBefore=4,rightIndent=15)];story+=[toc,PageBreak()]
current='';i=next(j for j,l in enumerate(lines) if l.startswith('## 1 '))
while i<len(lines):
 l=lines[i].strip()
 if not l:i+=1;continue
 if l.startswith('## '):
  current=l[3:];story.extend([CondPageBreak(190),Paragraph(rich(current),styles['h1'])]);i+=1;continue
 if l.startswith('### '):story.extend([CondPageBreak(110),Paragraph(rich(l[4:]),styles['h2'])]);i+=1;continue
 if l.startswith('|'):
  rows=[]
  while i<len(lines) and lines[i].strip().startswith('|'):
   cells=[x.strip() for x in lines[i].strip().strip('|').split('|')]
   if not all(re.fullmatch(r'[-: ]+',x) for x in cells):rows.append(cells)
   i+=1
  n=len(rows[0]);assert all(len(r)==n for r in rows)
  if n==2:widths=[CW*.31,CW*.69]
  elif n==3:
   if rows[0][0]=='Mã':widths=[CW*.13,CW*.55,CW*.32]
   else:widths=[CW*.22,CW*.46,CW*.32]
  elif n==4:
   if 'UC và tên nguồn' in rows[0][0]:widths=[CW*.35,CW*.15,CW*.12,CW*.38]
   else:widths=[CW*.19,CW*.34,CW*.30,CW*.17]
  else:widths=[CW/n]*n
  data=[[Paragraph(rich(x),styles['th'] if j==0 else styles['cell']) for x in row] for j,row in enumerate(rows)]
  t=Table(data,colWidths=widths,repeatRows=1,hAlign='LEFT');t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#24475B')),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),6),('BOTTOMPADDING',(0,0),(-1,-1),6),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#F1F5F7')]),('LINEBELOW',(0,0),(-1,0),.5,colors.HexColor('#24475B')),('LINEBELOW',(0,1),(-1,-1),.25,colors.HexColor('#D7E0E5'))]));story.extend([t,Spacer(1,8)]);continue
 if l.startswith('!['):
  img=out/'WMSD_ERD_tu_Report3.png';iw,ih=PILImage.open(img).size;story.extend([Image(str(img),width=CW,height=CW*ih/iw),Paragraph('Hình ERD trích từ Report 3 mục I.3.1',styles['small'])]);i+=1;continue
 if l.startswith('- '):story.append(Paragraph('• '+rich(l[2:]),styles['bullet']))
 else:story.append(Paragraph(rich(l),styles['body']))
 i+=1
dest=pdfdir/'WMSD_Thiet_ke_he_thong_chi_tiet.pdf'
d=Doc(str(dest),pagesize=A4,title='Thiết kế hệ thống WMSD',author='WMSD',subject='Thiết kế chi tiết theo Report 1 Report 3 và draw.io',allowSplitting=True);d.multiBuild(story)
r=PdfReader(dest);print(json.dumps({'pdf':str(dest),'pages':len(r.pages),'bytes':dest.stat().st_size},ensure_ascii=False))
joined='\n'.join(p.extract_text() for p in r.pages)
(root/'tmp/design_sources/pdf_text.txt').write_text(joined,encoding='utf-8')
assert all(f'UC-{i:02}' in joined for i in range(1,103))
assert all(f'TC-{i:02}' in joined for i in range(1,43))
assert all(f'BR-{i:02}' in joined for i in range(1,59))
