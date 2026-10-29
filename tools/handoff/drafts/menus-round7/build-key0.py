# build-key0.py (menus master, VM, 10-29): cw-stashkey0. Run from the repo root.
# v36.37 (cw-cx-hotbar9) made HOTBAR_N 10 (a 9 key, key 0 last); the stash item key row still labelled its buttons slot+1, so the
# last one read 10. Check 14.76 (every key on the hover row) went red on the 10-29 run. The row names keys as the hotbar does now.
import json
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
a=("            b.textContent=String(slot+1);\n"
   "            b.title=mine?('Already on key '+(slot+1)+', click to clear')\n"
   "                        :(taken?('Key '+(slot+1)+' holds '+(ITEMS[taken]?ITEMS[taken].name:taken)+', click to replace')\n"
   "                               :('Put it on key '+(slot+1)+' and carry it up'));")
assert G.count(a)==1
E.append({'anchor':a,'replacement':
   "            b.textContent=slotKeyName(slot);   // v28.xx (cw-stashkey0): the tenth key is 0, as on the hotbar (it read 10 after v36.37)\n"
   "            b.title=mine?('Already on key '+slotKeyName(slot)+', click to clear')\n"
   "                        :(taken?('Key '+slotKeyName(slot)+' holds '+(ITEMS[taken]?ITEMS[taken].name:taken)+', click to replace')\n"
   "                               :('Put it on key '+slotKeyName(slot)+' and carry it up'));"})
d={'title':'STASH KEY ROW NAMES KEY 0',
   'why':'v36.37 gave the hotbar a 9 key, and the stash item key row printed 10 on its last button instead of 0, so the old every key check went red on the 10-29 run. The row names keys the way the hotbar does.',
   'now':'the stash item key row ends on key 0, as the hotbar does',
   'edits':E,'check':open('tools/handoff/drafts/menus-round7/check-key0.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-stashkey0.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok')
