# build-round5b.py (menus master, VM, 10-28): cw-kiafit. Run from the repo root.
# At his 4K screen (run card 840 layout px) the KIA card with a full hit history (8 rows, the most HOW IT WENT keeps) was 911 px of content,
# so the how did that run feel button sat under the sticky log run button. Rows 30 px (16px type, line height 1.6 + 4) become 24.4; the KIA card's
# lost money and lost tiles gaps go 32 to 12 and 16 to 8. 836 px now.
import json
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
an="  '#root #oc_manifest .ockia>div:first-child>div:nth-child(2){font-size:14px !important;letter-spacing:.06em}'+"
assert G.count(an)==1
E.append({'anchor':an,'replacement':an+"\n"
"  // v35.xx (cw-kiafit), menus master pass 2026-10-28, his 4K screen: with 8 hits the KIA card ran 71px past the card, so the how did that run feel button sat under log run.\n"
"  '#root #oc_manifest .ockia>div>div{line-height:1.4 !important;padding-top:1px !important;padding-bottom:1px !important}'+\n"
"  '#root #oc_manifest:has(.ockia) .ocloss{margin-bottom:12px !important}#root #oc_manifest:has(.ockia) .octiles{margin-bottom:8px !important}'+"})
d={'title':'KIA CARD FITS AT 4K WITH A FULL HIT LIST',
   'why':'menus master pass 10-28, on his 4K screen: with 8 hits in how it went the KIA card ran 71 px past the card, so the how did that run feel button hid under the log run button. Table rows are tighter and the lost money and lost items sit closer, so the whole card shows with no scrolling.',
   'now':'at 4k the kia card shows every hit and the run feel button without scrolling',
   'edits':E,'check':open('tools/handoff/drafts/menus-round5/check-kiafit.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-kiafit.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok')
