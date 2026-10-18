import pathlib,re,json
p=pathlib.Path('tmp/design_sources');s=(p/'report3.txt').read_text(encoding='utf-8');ls=s.splitlines()
start=s.index('Primary Actors\n');end=s.index('\nField Name\n',start)
blocks=s[start:end].split('Primary Actors\n')[1:]
ucs=[]
for i,b in enumerate(blocks):
 lines=list(dict.fromkeys(b.splitlines())); u={'id':f'UC-{i+1:02}','text':'\n'.join(lines)};ucs.append(u)
(p/'ucs.json').write_text(json.dumps(ucs,ensure_ascii=False,indent=2),encoding='utf-8')
out=[]
for u in ucs:
 out.append(u['id'])
 out += [x for x in u['text'].splitlines() if x.startswith(('Source records','Required inputs','Validation and uniqueness','A4 — Business-specific','Successful outcome','Operation','Sub-operation','3. ','4. ','5. ','6. '))]
(p/'uc_digest.txt').write_text('\n'.join(out),encoding='utf-8')
print('UC blocks',len(ucs))
st=s.index('UC\nOperation\nStore Owner');en=s.index('\n#\n',st)
pm=s[st:en].splitlines()[7:];rows=[]
while pm and re.fullmatch(r'UC-\d+',pm[0]):
 rows.append(pm[:7]);pm=pm[7:]
(p/'permissions.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8');print('Permission rows',len(rows))
