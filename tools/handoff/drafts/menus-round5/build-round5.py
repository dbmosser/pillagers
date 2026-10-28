# build-round5.py (menus master, VM, 10-28): cw-wirtfit. Run from the repo root.
# At his 4K screen (zoom 2.47, the Wirt card 874 layout px tall) the limited time offer column held 469 px of content in a 432 px box:
# the buy button sat 8 px past the panel floor and its "need $X more" line hung under the panel border, out of line with the gamble side.
# The offer picture tile may now give up to half its height when the panel is short (192 down to 96); with room (1080) it stays 192.
import json
G=open('dark_raiders.html',encoding='utf-8').read().replace('\r','')
E=[]
an="#root #gamblemodal #wirtlotbtn{position:relative;flex:none;width:100%;min-width:0;min-height:56px;margin-bottom:32px;}"
assert G.count(an)==1
E.append({'anchor':an,'replacement':an+"\n"
"/* v35.xx (cw-wirtfit), menus master pass 2026-10-28, his 4K screen: the offer column ran 37px past its panel, so the buy button and its need line hung under the panel border. The picture tile gives up height first (192 down to 96, the inline flex:none it is built with is overridden), so the buy button lines up with the gamble button and the need line sits inside the panel. */\n"
"#root #gamblemodal #wirtlot > span[title]{flex:1 1 192px !important;min-height:96px;max-height:192px;height:auto !important;}\n"
"#root #gamblemodal #wirtlot > span[title] img{width:auto !important;height:calc(100% - 16px) !important;max-height:176px;aspect-ratio:1/1;}"})
d={'title':'WIRT OFFER FITS AT 4K: THE NEED LINE SITS INSIDE ITS PANEL',
   'why':'menus master pass 10-28, on his 4K screen: the limited time offer column was 37 px taller than its panel, so the buy button sat off the panel floor and its need more line hung under the panel border. The offer picture now shrinks a little when the panel is short, so both buttons and both need lines line up inside their panels.',
   'now':'at 4k the wirt buy button lines up with the gamble button and its need line sits inside the panel',
   'edits':E,'check':open('tools/handoff/drafts/menus-round5/check-wirtfit.js',encoding='utf-8').read()}
for e in E: assert all(ord(c)<127 for c in e['replacement'])
assert all(ord(c)<127 for c in d['check'])
open('tools/handoff/drafts/draft-cw-wirtfit.json','w',encoding='utf-8',newline='\n').write(json.dumps(d,indent=1)); print('ok')
