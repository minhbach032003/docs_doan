import json
import re
import textwrap
import xml.etree.ElementTree as ET
from collections import Counter, OrderedDict
from pathlib import Path

BASE = Path(__file__).resolve().parent
OUT = BASE / 'output' / 'usecase'
OUT.mkdir(parents=True, exist_ok=True)
SOURCE = json.loads((BASE / 'usecases_source.json').read_text(encoding='utf-8'))
UC = {u['id']: u for u in SOURCE}
ACTORS = ['Store Owner', 'Purchasing Staff', 'Inventory Staff', 'Sales Staff', 'Delivery Staff', 'Accountant', 'Administrator', 'SMTP Service']

# These decompositions are inferred from the descriptions, not new source UC IDs.
# relation type, support goal, evidence, optional extension condition.
SUPPORT = {
 'UC-07': [('include', 'Validate Batch Uniqueness', 'UC-07; GBR-01', '')],
 'UC-15': [('include', 'Check Remaining Location Inventory', 'UC-15', '')],
 'UC-17': [('include', 'Validate Already Received Quantities', 'UC-17; GBR-03', ''), ('generalization', 'Update Purchase Order', 'UC-17', ''), ('generalization', 'Cancel Purchase Order', 'UC-17', '')],
 'UC-26': [('include', 'Post Goods Receipt to Inventory', 'UC-26; GBR-04', '')],
 'UC-29': [('extend', 'Reduce Previously Received Inventory', 'UC-29; GBR-06', 'goods previously received into inventory')],
 'UC-30': [('include', 'Check Storage Capacity', 'UC-30', '')],
 'UC-32': [('include', 'Update Source and Destination Location Balances', 'UC-32', '')],
 'UC-44': [('include', 'Compare Physical Counts with Book Stock', 'UC-44', '')],
 'UC-46': [('include', 'Validate Stocktake Approval', 'UC-46; GBR-09', ''), ('include', 'Post Approved Inventory Adjustment', 'UC-46; GBR-09', '')],
 'UC-48': [('include', 'Validate Reserved, Issued and Delivered Quantities', 'UC-48', ''), ('generalization', 'Update Sales Order', 'UC-48', ''), ('generalization', 'Cancel Sales Order', 'UC-48', '')],
 'UC-49': [('include', 'Validate Eligible Available Stock', 'UC-49; GBR-07', ''), ('include', 'Select Batches and Reserve Quantities', 'UC-49', '')],
 'UC-51': [('include', 'Verify Stock, Batches and Requested Quantities', 'UC-51', '')],
 'UC-52': [('include', 'Verify Outbound Quantities, Batches and Color Codes', 'UC-52', '')],
 'UC-53': [('include', 'Validate Eligible Issue Quantity', 'UC-53; GBR-08', ''), ('include', 'Post Goods Issue and Update Order Quantities', 'UC-53; GBR-08', '')],
 'UC-61': [('include', 'Validate Inspection and Return Approval', 'UC-61; GBR-10', ''), ('include', 'Post Customer Return to Inventory', 'UC-61', '')],
 'UC-67': [('generalization', 'Create Employee Account', 'UC-67', ''), ('generalization', 'Update Employee Account', 'UC-67', ''), ('generalization', 'Lock Employee Account', 'UC-67', '')],
 'UC-70': [('include', 'Validate Warehouse Assignment and Location-Code Uniqueness', 'UC-70; GBR-11', '')],
 'UC-72': [('include', 'Validate Source and Destination Warehouses', 'UC-72; OR-01; OR-04', '')],
 'UC-73': [('include', 'Post Source Dispatch and In-Transit Stock', 'UC-73; GBR-12', '')],
 'UC-74': [('include', 'Compare Received and Dispatched Quantities', 'UC-74', ''), ('include', 'Post Destination Receipt by Batch and Location', 'UC-74; GBR-12', '')],
}
EXTENSIONS = [
 ('UC-23', 'UC-22', 'a shortage, surplus, incorrect batch or damaged goods is found', 'UC-22; UC-23; GBR-05'),
 ('UC-56', 'UC-55', 'delivery is short or fails', 'UC-55; UC-56'),
 ('UC-75', 'UC-74', 'received and dispatched quantities or condition differ', 'UC-74; UC-75; GBR-13'),
]
FEATURE_NAMES = ['Master Data Management', 'Purchasing Management', 'Goods Receiving Management', 'Inventory Management', 'Stocktake Management', 'Sales Management', 'Goods Issue Management', 'Delivery Management', 'Customer Returns Management', 'Reporting Management', 'System Administration']
FONT = 'fontFamily=Arial;fontSize=15;fontColor=#111111;'
ELLIPSE = 'ellipse;whiteSpace=wrap;html=1;align=center;verticalAlign=middle;strokeWidth=1.3;strokeColor=#333333;spacing=8;' + FONT
EDGE = 'edgeStyle=none;rounded=1;orthogonalLoop=1;jettySize=auto;html=1;strokeWidth=1.1;strokeColor=#444444;labelBackgroundColor=#ffffff;fontFamily=Arial;fontSize=13;fontColor=#111111;'
META = []
MANIFEST = []

def vertex(root, id_, value, x, y, w, h, style, parent='1', data=None):
    attrs = dict(id=id_, value=value, style=style, vertex='1', parent=parent)
    if data:
        attrs.update({k: str(v) for k, v in data.items()})
    cell = ET.SubElement(root, 'mxCell', attrs)
    ET.SubElement(cell, 'mxGeometry', dict(x=str(x), y=str(y), width=str(w), height=str(h), **{'as':'geometry'}))
    return cell

def edge(root, id_, source, target, label='', kind='association', points=None, ports=None, evidence='', condition=''):
    style = EDGE
    style += 'endArrow=none;startArrow=none;' if kind == 'association' else ('endArrow=block;endFill=0;endSize=14;dashed=0;' if kind == 'generalization' else 'endArrow=open;endFill=0;endSize=12;dashed=1;dashPattern=5 4;')
    if ports:
        for k,v in ports.items():
            style += f'{k}={v};'
    cell = ET.SubElement(root,'mxCell',dict(id=id_, value=label, style=style, edge='1', parent='1', source=source, target=target, relationship=kind, evidence=evidence, condition=condition))
    geo=ET.SubElement(cell,'mxGeometry',dict(relative='1', **{'as':'geometry'}))
    if points:
        arr=ET.SubElement(geo,'Array',{'as':'points'})
        for x,y in points:
            ET.SubElement(arr,'mxPoint',dict(x=str(x),y=str(y)))
    META.append(dict(page=current_actor,source=source,target=target,type=kind,evidence=evidence,condition=condition))

def label(text, width=32):
    return '\n'.join(textwrap.wrap(text, width=width, break_long_words=False, break_on_hyphens=False))

def uc_vertex(root, ucid, y, x=420, provenance='source'):
    u=UC[ucid]
    vertex(root,ucid,ucid+'\n'+label(u['name']),x,y,280,90,ELLIPSE+'fillColor=#ffffff;',data={'ucId':ucid,'provenance':provenance,'sourceFile':'Report3.docx.pdf','sourcePage':u['page'],'sourceActors':', '.join(u['actors']),'description':u['description']})

mxfile=ET.Element('mxfile',dict(host='drawio',version='31.5.3',type='device',pages=str(len(ACTORS)),compressed='false'))
for actor_index, current_actor in enumerate(ACTORS,1):
    own=[u for u in SOURCE if current_actor in u['actors']]
    groups=OrderedDict()
    for feature in FEATURE_NAMES:
        members=[u for u in own if u['feature'].startswith(feature)]
        if members:
            groups[feature]=members
    positions={}
    helper_positions={}
    heading_positions=[]
    cursor=170
    for feature, members in groups.items():
        heading_positions.append((feature,cursor))
        cursor+=40
        for u in members:
            helpers=SUPPORT.get(u['id'],[])
            # A foreign base UC is context only, never associated to this actor.
            foreign=[e for e in EXTENSIONS if e[0]==u['id'] and e[1] not in {v['id'] for v in own}]
            num_helpers=len(helpers)+len(foreign)
            row_h=max(130,num_helpers*120)
            positions[u['id']]=cursor+round((row_h-90)/20)*10
            helper_positions[u['id']]=(cursor,helpers,foreign)
            cursor+=row_h
        cursor+=30
    height=max(760,cursor+140)
    diagram=ET.SubElement(mxfile,'diagram',dict(id='actor-'+str(actor_index),name=current_actor))
    model=ET.SubElement(diagram,'mxGraphModel',dict(dx='1400',dy='900',grid='0',gridSize='10',guides='1',tooltips='1',connect='1',arrows='1',fold='1',page='1',pageScale='1',pageWidth='1400',pageHeight=str(height+100),math='0',shadow='0',background='#ffffff'))
    root=ET.SubElement(model,'root')
    ET.SubElement(root,'mxCell',{'id':'0'})
    ET.SubElement(root,'mxCell',{'id':'1','parent':'0'})
    # Boundary is a visual system frame; actor is outside it.
    vertex(root,'system','',330,50,980,height-50,'rounded=0;html=1;fillColor=none;strokeColor=#222222;strokeWidth=1.4;pointerEvents=0;container=1;collapsible=0;')
    vertex(root,'title','WMSD — Warehouse Management System',350,65,930,30,'text;html=1;align=center;fontFamily=Arial;fontSize=21;fontStyle=1;')
    vertex(root,'subtitle',current_actor+' Use Case Diagram',350,100,930,25,'text;html=1;align=center;fontFamily=Arial;fontSize=17;')
    actor_y=(height//2-70) if own else 300
    vertex(root,'actor',current_actor,100,actor_y,50,100,'shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;html=1;whiteSpace=wrap;strokeWidth=1.5;fillColor=#ffffff;strokeColor=#222222;'+FONT)
    for feature,y in heading_positions:
        vertex(root,'heading-'+str(y),feature,430,y,830,30,'text;html=1;align=left;fontFamily=Arial;fontSize=16;fontStyle=1;fontColor=#555555;')
    for uid,y in positions.items():
        uc_vertex(root,uid,y)
    for n,(uid,y) in enumerate(positions.items()):
        edge(root,'association-'+uid,'actor',uid,ports={'exitX':1,'exitY':round((n+1)/(len(positions)+1),4),'entryX':0,'entryY':0.5},evidence=uid+' Primary Actor(s)')
        start,helpers,foreign=helper_positions[uid]
        for j,(kind,name,evidence,condition) in enumerate(helpers):
            hid=f'SUP-{uid[3:]}-{j+1}'
            hy=start+j*120
            value=hid+'\n'+label(name)
            if condition:
                value+='\n[previously received goods]'
            vertex(root,hid,value,970,hy,290,90,ELLIPSE+'fillColor=#f4f4f4;',data={'provenance':'derived','evidence':evidence,'condition':condition})
            if kind=='include':
                src,dst=uid,hid
            else:
                src,dst=hid,uid
            # Distinct perimeter slots leave arrowheads and labels clear.
            p=(j+1)/(len(helpers)+len(foreign)+1)
            ports={'exitX':1 if src==uid else 0,'exitY':p if src==uid else 0.5,'entryX':0 if dst==hid else 1,'entryY':0.5 if dst==hid else p}
            edge(root,'relation-'+hid,src,dst,'' if kind=='generalization' else '«'+kind+'»',kind,ports=ports,evidence=evidence,condition=condition)
        for j,ext in enumerate(foreign,len(helpers)):
            _,base,condition,evidence=ext
            foreign_id=base+'-context'
            u=UC[base]
            hy=start+j*120
            vertex(root,foreign_id,base+'\n'+label(u['name'])+'\n(context)',970,hy,290,90,ELLIPSE+'fillColor=#f4f4f4;',data={'ucId':base,'sourcePage':u['page'],'sourceActors':', '.join(u['actors']),'provenance':'source-context'})
            edge(root,'extension-'+uid,uid,foreign_id,'«extend»\n['+label(condition,28)+']','extend',ports={'exitX':1,'exitY':0.5,'entryX':0,'entryY':0.5},evidence=evidence,condition=condition)
    for source,base,condition,evidence in EXTENSIONS:
        if source in positions and base in positions:
            # Both source UCs are adjacent in the primary column. A vertical
            # connector uses their gap and avoids crossing support relations.
            sy=positions[source]
            ty=positions[base]+90
            edge(root,'extension-'+source,source,base,'«extend»','extend',ports={'exitX':0.5,'exitY':0,'entryX':0.5,'entryY':1},evidence=evidence,condition=condition)
            ecell=root.findall('mxCell')[-1]
            ET.SubElement(ecell.find('mxGeometry'),'mxPoint',dict(x='100',y='0',**{'as':'offset'}))
            vertex(root,'condition-'+source,'['+label(condition,27)+']',715,(sy+ty)/2-45,215,90,'text;whiteSpace=wrap;html=1;align=left;verticalAlign=middle;fontFamily=Arial;fontSize=13;fontColor=#555555;')
    if not own:
        notes={
            'Accountant':'Actor appears in the system context (page 1).\nInvoice and receivable/payable interactions are mentioned in GBR-15 and OR-06.\nNo use case in UC-01–UC-75 assigns Accountant as a primary actor.\nDetailed accounting use cases are not specified in this list.',
            'Administrator':'Actor appears in the system context (page 1).\nUC-67 and UC-68 explicitly assign account and permission management to Store Owner.\nNo use case in UC-01–UC-75 assigns Administrator as a primary actor.\nAdministrator privileges must be clarified before adding associations.',
            'SMTP Service':'External actor appears in the system context (page 1).\nOR-08 requires notification requests, delivery attempts and delivery results to be distinguished.\nNo email use case is defined in UC-01–UC-75.\nSMTP associations require a detailed email use case specification.',
        }
        vertex(root,'gap-note',notes[current_actor],420,220,800,290,'shape=note;size=20;whiteSpace=wrap;html=1;align=left;verticalAlign=middle;spacing=25;fillColor=#fff8e6;strokeColor=#999999;fontFamily=Arial;fontSize=18;')
    foot_y=height-110
    vertex(root,'legend','Source: Report3.docx.pdf, §4.2 (pages 1–4).  UC-nn: original use case.  SUP-nn-n: derived support / specialization.\nSolid line: actor association.  Dashed open arrow: «include» (base → required behavior), «extend» (optional behavior → base).\nSolid hollow triangle: generalization (specialized → general).  Gray source UC marked (context): no actor assignment implied.\nRelationships are modeling interpretations of descriptions / business rules; sequential workflow steps remain separate.',360,foot_y,920,100,'text;whiteSpace=wrap;html=1;align=left;verticalAlign=middle;fontFamily=Arial;fontSize=12;fontColor=#555555;')
    # True containment removes accidental sibling overlap and preserves UML
    # boundary membership when the system is moved in the editor.
    for cell in root.findall('mxCell'):
        if cell.get('vertex')=='1' and cell.get('id') not in {'system','actor'}:
            cell.set('parent','system')
            geo=cell.find('mxGeometry')
            geo.set('x',str(float(geo.get('x'))-330))
            geo.set('y',str(float(geo.get('y'))-50))
    MANIFEST.append(dict(actor=current_actor,page=actor_index,primary_uc_count=len(own),primary_uc_ids=[u['id'] for u in own],width=1400,height=height+100))

ET.indent(mxfile,space='  ')
DEST=OUT/'WMSD_Use_Case_Diagrams.drawio'
ET.ElementTree(mxfile).write(DEST,encoding='utf-8',xml_declaration=True)
(OUT/'usecase_model.json').write_text(json.dumps({'source':'Report3.docx.pdf','usecases':SOURCE,'pages':MANIFEST,'relations':META},ensure_ascii=False,indent=2),encoding='utf-8')

coverage={m['actor']:m['primary_uc_ids'] for m in MANIFEST}
assert sorted({id_ for ids in coverage.values() for id_ in ids}) == sorted(UC)
for u in SOURCE:
    assert {a for a,ids in coverage.items() if u['id'] in ids} == set(u['actors']),u['id']
assert len(UC)==75
assert len(MANIFEST)==8
summary=Counter(r['type'] for r in META)
print(json.dumps({'file':str(DEST),'source_usecases':len(UC),'pages':[(m['actor'],m['primary_uc_count']) for m in MANIFEST],'relations':summary},ensure_ascii=False,indent=2))
