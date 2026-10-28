# vm-fix-round2.py (menus master, VM, 2026-10-28): the VM preflight of 13:44 failed "the last hotbar slot ends at x 1775, the backpack row at 1769".
# Cause: on Windows Chrome the backpack box (#kitgrid, overflow auto, 2 rows in a 1.x row box) shows its 8px scroll bar, which takes
# about 7px from the slots; the cloud's headless Chromium draws overlay scroll bars with no width, so it passed there. The hotbar's right
# inset now takes the same scroll bar width (hotInsetSync, after each renderKitCol and from a ResizeObserver on the box). Run from the repo root: python this.
import json
R='tools/handoff/drafts/draft-cw-menupolish2.json'
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
d=json.load(open(R,encoding='utf-8'))
def tag(s): return s.replace('v16.xx (cw-menupolish2)','v35.xx (cw-menupolish2)')
for e in d['edits']: e['replacement']=tag(e['replacement'])
d['check']=tag(d['check'])
d['edits']=[e for e in d['edits'] if 'hotInsetSync' not in e['replacement']]
an='function renderKitCol(){'; assert G.count('\n'+an+'\n')==1
d['edits'].append({'anchor':an,'replacement':
"// v35.xx (cw-menupolish2), menus master pass 2026-10-28: THE HOTBAR ENDS WHERE THE BACKPACK ROW ENDS. The backpack box scrolls, and on a\n"
"// Windows screen its 8px scroll bar takes width from the slots, so on the 12px inset alone the hotbar ran 6px past them at 1080. The hotbar's\n"
"// right inset takes the same scroll bar width (none when the box does not scroll). Display only.\n"
"// The stash renders while it is still hidden (the terminal adds .on after renderHub), so a ResizeObserver on the box measures again when\n"
"// it shows and when its scroll bar comes or goes (its content box narrows); setting the hotbar inset never resizes the box.\n"
"var _hotInsetRO=null;\n"
"function hotInsetSync(){\n"
"  var kg=document.getElementById('kitgrid'), hw=document.getElementById('hotplanwrap'), cs, sb;\n"
"  if(!kg||!hw) return;\n"
"  if(!_hotInsetRO&&typeof ResizeObserver==='function'){ _hotInsetRO=new ResizeObserver(function(){ try{ hotInsetSync(); }catch(_hr){} }); _hotInsetRO.observe(kg); }\n"
"  cs=getComputedStyle(kg);\n"
"  sb=Math.max(0,kg.offsetWidth-kg.clientWidth-(parseFloat(cs.borderLeftWidth)||0)-(parseFloat(cs.borderRightWidth)||0));\n"
"  hw.style.paddingRight=(12+sb)+'px';\n"
"}\n"
+an})
an='  renderKitCol();'; assert G.count('\n'+an+'\n')==1
d['edits'].append({'anchor':an+'\n\n  shown.forEach(function(k){','replacement':an+'\n  try{ hotInsetSync(); }catch(_his){}   // v35.xx (cw-menupolish2): the hotbar ends on the backpack row, scroll bar or not\n\n  shown.forEach(function(k){'})
assert G.count(d['edits'][-1]['anchor'])==1
d['why']=d['why']+' The backpack box shows a scroll bar on a Windows screen, so the hotbar right inset follows its width.'
for e in d['edits']: assert all(ord(c)<127 for c in e['replacement']) and G.count(e['anchor'])==1, e['anchor'][:60]
open(R,'w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok', len(d['edits']),'edits')
# 4K pass (VM pictures 10-28): at 4K the gamble panel is about 500px tall (the window frame caps it), so the 192px tile stacked over the
# odds pushed the gamble button out of the panel, and the old 200px floor on the roll list made it worse. The tile now sits BESIDE the
# odds (as tall as the offer picture), and the roll list takes only the room that is left.
R2=[("#root #gamblemodal #gambleodds{flex:none;display:flex;flex-direction:column;align-items:stretch;gap:var(--sp-3);width:100%;}",
     "#root #gamblemodal #gambleodds{flex:none;display:flex;flex-direction:row;align-items:center;gap:var(--sp-3);width:100%;}\n#root #gamblemodal #wirtsec_gamble #gamblelist{min-height:0;}"),
    ("#root #gamblemodal #gambleodds .gbtile{align-self:center;box-sizing:border-box;","#root #gamblemodal #gambleodds .gbtile{flex:none;box-sizing:border-box;"),
    ("#root #gamblemodal #gambleodds .gbodds{display:flex;","#root #gamblemodal #gambleodds .gbodds{flex:1 1 auto;min-width:0;display:flex;"),
    ("a 192px mystery tile (the offer picture's size) over the odds, one row a rarity","a 192px mystery tile (the offer picture's size) beside the odds, one row a rarity; the roll list takes what is left")]
for e in d['edits']:
    for a,b in R2: e['replacement']=e['replacement'].replace(a,b)
assert sum(e['replacement'].count('#wirtsec_gamble #gamblelist{min-height:0;}') for e in d['edits'])==1
d['why']=d['why'].replace('a mystery tile of the same size and the odds','a mystery tile of the same size beside the odds')
for e in d['edits']: assert all(ord(c)<127 for c in e['replacement'])
open(R,'w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok 4k pass')
