# build-stashtabs.py (menus master, VM, 10-28): cw-stashtabs. Run from the repo root.
# HIS PICK 10-28 ("Ok I guess go with A") on the stash backpack page: at his 4K screen the loadout column got 207 to 255 layout px and needed
# 410, so the 12 backpack slots had no room and the key hints sat on the gun keys. Option a: the loadout column has two tabs, BACKPACK
# (the 12 slots at full size, then the hotbar) and KEYS (gun keys and the item wheel); the 160px item details strip under the grids becomes a
# card beside the stash item under the mouse or the pad highlight, floating, so nothing resizes (his 10-27 order).
import json
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
def rep(a,b):
    assert G.count(a)==1,(a[:60],G.count(a))
    E.append({'anchor':a,'replacement':b})
an='<div class="lohead">LOADOUT<em>$<span id="kitval">0</span> going up</em></div>'
rep(an,an+'\n          <div class="lotabs" id="lotabs" role="tablist"><button type="button" data-lt="pack" class="on" aria-selected="true">BACKPACK</button><button type="button" data-lt="keys" aria-selected="false">KEYS</button></div><!-- v28.xx (cw-stashtabs), HIS PICK 2026-10-28: the loadout column in two tabs -->')
an="#root #hub #stashdetail>div>div{line-height:1.3!important;}"
rep(an,an+"\n"
"/* v28.xx (cw-stashtabs), HIS PICK (2026-10-28, \"Ok I guess go with A\"): at his 4K screen the loadout column had 207 to 255px for 410px of content, so the 12 backpack slots got no room and the key hints sat on the gun keys. The column has two tabs now: BACKPACK (the 12 slots at full size, then the hotbar) and KEYS (gun keys and the item wheel). The 160px details strip is a card beside the stash item under the mouse or the pad highlight; it floats, so nothing resizes (his 10-27 order), and its buttons stay on the right-click menu. */\n"
"html #root #hub #lotabs{display:flex;gap:24px;padding:4px 0 0;margin:0 0 8px;border-bottom:1px solid var(--ui-line-hi);}\n"
"html #root #hub #lotabs button{appearance:none;background:none!important;border:0!important;border-bottom:3px solid transparent!important;border-radius:0!important;box-shadow:none!important;min-height:0!important;min-width:0!important;margin:0!important;padding:0 0 4px!important;font:600 var(--fs-body)/1.6 var(--f-cond)!important;letter-spacing:.04em;color:var(--tx-2)!important;cursor:pointer;}\n"
"html #root #hub #lotabs button.on{color:var(--tx-1)!important;border-bottom-color:var(--acc)!important;}\n"
"html #root #hub #lotabs button:hover{color:var(--tx-1)!important;}\n"
"html #root #hub #kitcol.lt-keys > .losec:not(#kitsetup),html #root #hub #kitcol.lt-keys > #firstkit{display:none!important;}\n"
"html #root #hub #kitcol:not(.lt-keys) > #kitsetup{display:none!important;}\n"
"html #root #hub #kitcol > #kitsetup{border-top:none!important;}\n"
"html #root #hub #kitcol .losec{flex:none!important;}\n"
"html #root #hub #kitgrid{flex:none!important;height:auto!important;min-height:0!important;max-height:none!important;overflow:visible!important;grid-template-columns:repeat(6,minmax(0,1fr))!important;gap:8px!important;}\n"
"html #root #hub #kitgrid .cell{width:auto!important;height:auto!important;min-height:0!important;aspect-ratio:1/1;}\n"
"html #root #hub #stashdetail{position:absolute!important;z-index:40;display:none!important;box-sizing:border-box;width:min(560px,46%);height:auto!important;min-height:0!important;max-height:none!important;overflow:visible!important;pointer-events:none;margin:0!important;padding:12px 16px!important;background:var(--ui-raised)!important;border:1px solid var(--ui-line-hi)!important;}\n"
"html #root #hub #stashdetail.sdon{display:block!important;}\n"
"html #root #hub #stashdetail #stashacts{display:none!important;}\n"
"html #root #hub #stashdetail>div{grid-template-rows:none!important;grid-auto-flow:row!important;grid-template-columns:repeat(2,minmax(0,1fr));}")
an="  if(el!==old&&el.closest&&el.closest('#stashgrid')){ try{ if(typeof el.onmouseenter==='function') el.onmouseenter(); else el.dispatchEvent(new MouseEvent('mouseenter')); }catch(_me){} }"
rep(an,an+"\n  try{ stashCardAt(el); }catch(_sc){}   // v28.xx (cw-stashtabs): the details card follows the pad highlight")
an="function padMenu(pressed){"
rep(an,
"// v28.xx (cw-stashtabs), HIS PICK 2026-10-28: the loadout column's two tabs (BACKPACK, KEYS) and the stash details card. The card is the\n"
"// old details strip (#stashdetail, written by the stash cell's onmouseenter as before), floated beside the cell under the mouse or the pad\n"
"// highlight, kept inside the window, hidden when nothing is under it. Only stash cells write it, so only stash cells show it.\n"
"function stashCardAt(cell){\n"
"  var d=document.getElementById('stashdetail'); if(!d) return;\n"
"  if(!cell||!cell.closest||!cell.closest('#stashgrid')||!d.innerHTML.trim()){ d.classList.remove('sdon'); return; }\n"
"  d.classList.add('sdon');\n"
"  var par=d.offsetParent; if(!par) return;\n"
"  var z=(d.getBoundingClientRect().width/(d.offsetWidth||1))||1, cr=cell.getBoundingClientRect(), pr=par.getBoundingClientRect(), w=d.offsetWidth, h=d.offsetHeight;\n"
"  var x=(cr.right-pr.left)/z+12, y=(cr.top-pr.top)/z;\n"
"  if(x+w>par.clientWidth-8) x=(cr.left-pr.left)/z-12-w;\n"
"  if(x<8) x=8; if(y+h>par.clientHeight-8) y=par.clientHeight-8-h; if(y<8) y=8;\n"
"  d.style.left=Math.round(x)+'px'; d.style.top=Math.round(y)+'px';\n"
"}\n"
"function stashTabSet(keys){\n"
"  var c=document.getElementById('kitcol'); if(!c) return;\n"
"  c.classList.toggle('lt-keys',!!keys);\n"
"  [].forEach.call(document.querySelectorAll('#lotabs button[data-lt]'),function(b){ var on=(b.getAttribute('data-lt')==='keys')===!!keys; b.classList.toggle('on',on); b.setAttribute('aria-selected',on?'true':'false'); });\n"
"}\n"
"document.addEventListener('click',function(ev){ var b=ev.target&&ev.target.closest?ev.target.closest('#lotabs button[data-lt]'):null; if(!b) return; stashTabSet(b.getAttribute('data-lt')==='keys'); try{ sndUi('move'); }catch(_su){} });\n"
"document.addEventListener('mouseover',function(ev){ var c=ev.target&&ev.target.closest?ev.target.closest('#stashgrid .cell'):null; if(c) setTimeout(function(){ stashCardAt(c); },0); });\n"
"document.addEventListener('mouseout',function(ev){ var c=ev.target&&ev.target.closest?ev.target.closest('#stashgrid .cell'):null; if(c&&!(ev.relatedTarget&&c.contains(ev.relatedTarget))) stashCardAt(null); });\n"
+an)
d={'title':'STASH LOADOUT IN TWO TABS: BACKPACK AND KEYS',
   'why':'HIS PICK 10-28 (option a): at his 4K screen the loadout column was too short, so the 12 backpack slots got no room and the key hints sat on the gun keys. The column has a backpack tab (12 full slots and the hotbar) and a keys tab (gun keys and item wheel), and item details show as a card beside the item under the mouse, so nothing resizes.',
   'now':'the stash loadout has a backpack tab and a keys tab, and item details pop up beside the item',
   'edits':E,'check':open('tools/handoff/drafts/menus-round6/check-stashtabs.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-stashtabs.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok',len(E))
