import xml.etree.ElementTree as E, re, json, html, pathlib, zipfile
p=pathlib.Path('tmp/design_sources')
root=E.parse('WMSD_Bangach (1).drawio').getroot()
pages=[]
for i,d in enumerate(root.findall('diagram')):
 cells=d.findall('.//mxCell'); names={c.get('id'):html.unescape(re.sub('<[^>]*>',' ',c.get('value',''))).strip() for c in cells}
 nodes=[{'id':c.get('id'),'text':names[c.get('id')],'parent':c.get('parent')} for c in cells if names[c.get('id')]]
 edges=[{'from':names.get(c.get('source'),c.get('source')),'to':names.get(c.get('target'),c.get('target')),'label':names.get(c.get('id'))} for c in cells if c.get('edge')=='1']
 uml=[]
 for u in d.findall('.//UserObject'):
  if u.get('plantUmlData'):
   uml.append(json.loads(u.get('plantUmlData')).get('data'))
 item={'index':i+1,'name':d.get('name'),'id':d.get('id'),'nodes':nodes,'edges':edges,'uml':uml};pages.append(item)
 (p/f'diagram_{i+1:02}.json').write_text(json.dumps(item,ensure_ascii=False,indent=2),encoding='utf-8')
(p/'diagram_index.json').write_text(json.dumps([{'index':x['index'],'name':x['name'],'nodes':len(x['nodes']),'edges':len(x['edges'])} for x in pages],ensure_ascii=False,indent=2),encoding='utf-8')
for no in [1,3]:
 with zipfile.ZipFile(f'WMSD_Report{no}_Fix.docx') as z:
  r=E.fromstring(z.read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
  lines=[''.join(t.itertext()) for t in []]
  lines=[''.join(t.text or '' for t in e.findall('.//w:t',ns)) for e in r.findall('.//w:p',ns)]
  (p/f'local_report{no}.txt').write_text('\n'.join(lines),encoding='utf-8')
print((p/'diagram_index.json').read_text(encoding='utf-8'))
