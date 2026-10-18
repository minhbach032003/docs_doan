import pathlib,xml.etree.ElementTree as E,re,html,json
p=pathlib.Path('tmp/design_sources');root=E.parse('WMSD_Bangach (1).drawio').getroot()
for i,d in enumerate(root.findall('diagram')):
 labels={}
 for c in d.iter():
  if c.get('id'):
   s=c.get('value') or c.get('label') or ''
   s=html.unescape(re.sub('<[^>]*>',' ',s)).strip()
   if s:labels[c.get('id')]=s
 out=[f'PAGE {i+1} {d.get("name")}']
 out += [f'{k}: {v}' for k,v in labels.items()]
 out += ['EDGES']
 for c in d.findall('.//mxCell'):
  if c.get('edge')=='1':out.append(f'{labels.get(c.get("source"),c.get("source"))} --> {labels.get(c.get("target"),c.get("target"))} | {labels.get(c.get("id"),"")}')
 for u in d.findall('.//UserObject'):
  if u.get('plantUmlData'):out+=['PLANTUML',json.loads(u.get('plantUmlData')).get('data','')]
 (p/f'page_{i+1:02}.txt').write_text('\n'.join(out),encoding='utf-8')
