# build-round4.py (menus master, VM, 10-28): cw-endcards. Run from the repo root.
# At his 4K screen (zoom 2.47 on the run card, 874 layout px tall) the KIA card with a hit history was 967 px of content in an 840 px card,
# so the stats row and the run feel button slid under the sticky log run button; the extracted card with many recovered guns ran 54 px over and
# its DAMAGE TAKEN footnote sat under the button. HOW IT WENT and DAMAGE TAKEN were 11.5 px rows, names centred.
import json
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
an="    DEATH_FEED_HTML=(DEATH_FEED_HTML||'')+recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN"
assert G.count(an)==1
E.append({'anchor':an,'replacement':an+"\n"
"    if(DEATH_FEED_HTML) DEATH_FEED_HTML='<div class=\"ockia\">'+DEATH_FEED_HTML+'</div>';   // v35.xx (cw-endcards): HOW IT WENT and DAMAGE TAKEN side by side (CSS ockia)"})
an="           '<span style=\"width:92px;text-align:right;opacity:.7\">'+fmtMS(e.t)+'</span>'+"
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"           '<span style=\"width:92px;text-align:right;opacity:.7\">'+(Math.floor(Math.max(0,e.t)/60)+':'+('0'+(Math.max(0,e.t)%60)).slice(-2))+'</span>'+   // v35.xx (cw-endcards): 2:24, as the card's time stat reads, so the side by side table fits"})
an="  '#root #oc_manifest .ocrecap>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}');"
assert G.count(an)==1
E.append({'anchor':an,'replacement':an[:-2]+"+\n"
"  // v35.xx (cw-endcards), menus master pass 2026-10-28: at 4K a hit history made the KIA card taller than the screen, so its stats and the run feel button slid\n"
"  // under the log run button, and the extracted card's DAMAGE TAKEN footnote sat under it with many guns recovered. On the KIA card HOW IT WENT and DAMAGE TAKEN\n"
"  // sit side by side at the 16px body size, names left aligned (11.5px rows, stacked, names centred); on the EXTRACTED card the sources take two columns.\n"
"  '#root #oc_manifest .ockia{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(0,1fr);column-gap:24px;align-items:start;width:100%;margin:0 0 8px;text-align:left}'+\n"
"  '#root #oc_manifest .ockia>div{margin-top:0 !important}'+\n"
"  '#root #oc_manifest .ockia>div>div{font-size:16px !important;letter-spacing:.02em}'+\n"
"  '#root #oc_manifest .ockia>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}'+\n"
"  '#root #oc_manifest .ockia>div:first-child>div:nth-child(2){font-size:14px !important;letter-spacing:.06em}'+\n"
"  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(1){width:44px !important;text-align:left !important}'+\n"
"  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(3){width:60px !important}'+\n"
"  '#root #oc_manifest .ockia>div:first-child>div>span:nth-child(4){width:64px !important;white-space:nowrap}'+\n"
"  '#root #oc_manifest .ockia>div:last-child>div>span:nth-child(2){width:40px !important}'+\n"
"  '#root #oc_manifest .ockia>div:last-child>div>span:nth-child(3){width:auto !important;min-width:44px;white-space:nowrap}'+\n"
"  '#root #oc_manifest:has(.ockia) .ocloss{margin-top:8px}#root #oc_manifest:has(.ockia) .octiles{margin-bottom:16px}#root #oc_manifest:has(.ockia) .ocstat{margin-bottom:8px}'+\n"
"  '#root #oc_manifest:has(.ockia) span:empty+br{display:none}'+\n"
"  '#root #oc_manifest .ocrecap>div{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));column-gap:24px}'+\n"
"  '#root #oc_manifest .ocrecap>div>div:first-child{grid-column:1 / -1}'+\n"
"  '#root #oc_manifest .ocrecap>div>div>span:last-child{width:auto !important;min-width:48px;white-space:nowrap}');"})
d={'title':'THE RUN CARDS FIT AT 4K: KIA TABLES SIDE BY SIDE, DAMAGE IN TWO COLUMNS',
   'why':'menus master pass 10-28, on his 4K screen: the KIA card with a hit history ran past the screen, so its stats and the run feel button slid under the log run button, and its HOW IT WENT and DAMAGE TAKEN tables were tiny stacked rows with centred names. They sit side by side at body size now. On the extracted card with many recovered guns the damage footnote ran under the button; its sources take two columns.',
   'now':'the kia card tables sit side by side and the extracted damage list fits above the button',
   'edits':E,'check':open('tools/handoff/drafts/menus-round4/check-endcards.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-endcards.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok')
