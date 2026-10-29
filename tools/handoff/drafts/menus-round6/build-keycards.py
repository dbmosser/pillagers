# build-keycards.py (menus master, VM, 10-28): cw-keycards. Run from the repo root.
# HIS ORDER 10-28: "I am confused by keyboard keys vs in game keys, can we call the in game keys something else?" In-game keys become keycards.
# Words only: item ids, doors, loot tables and saves are unchanged (names are never saved). His own TXSHIP Data Core line keeps its words but one.
import json,re
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
def rep(a,b):
    assert G.count(a)==1,(a,G.count(a))
    E.append({'anchor':a,'replacement':b})
names=re.findall(r"name:'([A-Za-z ]+ Key)',val:\d+,wt:1,r:'rare',c:'#ffc04a',use:'key'",G)
assert len(names)==16,len(names)
for nm in names: rep("name:'"+nm+"',", "name:'"+nm+"card',")
rep("  if(g.kind==='key') return 'A key to a sealed room';","  if(g.kind==='key') return 'A keycard to a sealed room';   // v28.xx (cw-keycards), HIS ORDER 2026-10-28: in-game keys are keycards, keys are what you press")
rep("    return ITEMS[k]?ITEMS[k].name:'a key';","    return ITEMS[k]?ITEMS[k].name:'a keycard';")
rep("      mapLabel('KEY',ikx,iky-9*_MZ,UIC.tx_1);","      mapLabel('KEYCARD',ikx,iky-9*_MZ,UIC.tx_1);   // v28.xx (cw-keycards)")
rep("['salvage','SALVAGE'],['key','KEYS'],","['salvage','SALVAGE'],['key','KEYCARDS'],")
rep("    ?'Next raid: every locked-room key and every elite shown live on your map. One core per raid.'","    ?'Next raid: every locked-room keycard and every elite shown live on your map. One core per raid.'")
rep("deploys knowing things: every locked-room key location and every elite, live on the M map. One is in the stash.')","deploys knowing things: every locked-room keycard location and every elite, live on the M map. One is in the stash.')")
rep("Spend a Data Core for better map info. Every locked-room key location and every elite will be live on the M map.","Spend a Data Core for better map info. Every locked-room keycard location and every elite will be live on the M map.")
d={'title':'IN-GAME KEYS ARE KEYCARDS NOW',
   'why':'HIS ORDER 10-28: he was confused by keyboard keys versus in-game keys and asked to call the in-game ones something else. Every item that opens a sealed room is now a keycard, the stash tab reads keycards, and the map and Data Core lines say keycard. Words only.',
   'now':'the items that open sealed rooms are keycards, so keys only means keys you press',
   'edits':E,'check':open('tools/handoff/drafts/menus-round6/check-keycards.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-keycards.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok',len(E))
