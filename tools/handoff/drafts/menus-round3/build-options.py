# build-options.py (menus master, 10-28): picture options for the stash loadout column at his 4K screen (3840x2160, TV-size text,
# the hub at zoom 2.27, so about 1690x950 layout px). Measured there: the loadout column gets 207 px (new player, the freebie bar shows)
# or 255 px (stocked career), and its content needs 410 before the backpack's 12 slots (his answers 8 and 28) get any room, so today the
# backpack box is 0 tall and the key hints row sits on the gun keys. Mockups only (CSS and a fake tab row injected after staging).
import json
D=json.load(open('tools/handoff/shots/ui-screens-js.json',encoding='utf-8'))
base={s['name']:s for s in D['screens'] if s['name'] in ('04-stash-terminal','67-career-stash-stocked')}
BP=("#root #hub #kitcol .losec{flex:none!important;}"
    "#root #hub #kitgrid{flex:none!important;height:auto!important;min-height:0!important;max-height:none!important;overflow:visible!important;"
    "grid-template-columns:repeat(6,minmax(0,1fr))!important;gap:8px!important;}"
    "#root #hub #kitgrid .cell{width:auto!important;height:auto!important;min-height:0!important;aspect-ratio:1/1;}")
CARD="#root #hub #stashdetail{display:none!important;}"
OPT={
 'a-keys-tab': CARD+BP+"#root #hub #kitsetup{display:none!important;}"
   "#root #hub .mmtabs{display:flex;gap:24px;padding:4px 12px 0;border-bottom:1px solid var(--ui-line-hi);font:600 20px/1.6 var(--f-cond);letter-spacing:.04em;}"
   "#root #hub .mmtabs b{color:var(--tx-1);border-bottom:3px solid var(--acc);padding-bottom:4px;}#root #hub .mmtabs span{color:var(--tx-2);padding-bottom:4px;}",
 'b-scroll': BP+"#root #hub #kitcol{overflow-y:auto!important;overflow-x:hidden!important;}",
 'c-compact': CARD+BP.replace("repeat(6,minmax(0,1fr))","repeat(6,minmax(0,64px))").replace("gap:8px!important;}","gap:8px!important;justify-content:space-between;}")+
   "#root #hub #kitsetup .kst,#root #hub #kitsetup .kstc{height:44px!important;min-height:44px!important;grid-template-columns:40px minmax(0,1fr)!important;grid-template-rows:40px!important;}"
   "#root #hub #kitsetup .kst .ic{grid-column:1!important;grid-row:1!important;}#root #hub #kitsetup .kst span{grid-column:2!important;grid-row:1!important;text-align:left!important;line-height:40px!important;}",
}
TAB="var k=document.querySelector('#kitcol .lohead'); if(k&&!document.querySelector('.mmtabs')){ var t=document.createElement('div'); t.className='mmtabs'; t.innerHTML='<b>backpack</b><span>keys</span>'; k.after(t); }"
out=[]
for on,css in OPT.items():
  for bn,s in base.items():
    n=dict(s); n['name']=bn[:2]+'-'+on
    css=css.replace('#root #hub','html #root #hub').replace('html html','html')
    inj="var st=document.getElementById('mmopt')||document.createElement('style'); st.id='mmopt'; st.textContent="+json.dumps(css)+"; document.head.appendChild(st);"+(TAB if on.startswith('a') else '')+" await U.wait(300); "
    js=s['js']; i=js.rfind('return ')
    n['js']=js[:i]+inj+js[i:] if i>=0 else js+';'+inj
    out.append(n)
for bn,s in base.items():
  n=dict(s); n['name']=bn[:2]+'-now'; out.append(n)
D['screens']=out
json.dump(D,open('tools/handoff/drafts/menus-round3/recipes-options.json','w',encoding='utf-8'),indent=1); print(len(out),'recipes')
