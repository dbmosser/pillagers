import json
R='/home/user/pillagers/'; S='/tmp/claude-0/-home-user-pillagers/1c6f0e92-09e3-5935-b255-ee9e2a127028/scratchpad/'
G=open(R+'dark_raiders.html',encoding='utf-8').read().replace('\r','')
L=G.split('\n')
n=[i for i,l in enumerate(L) if l.startswith("    if((m=/^(<span style=\"color:var\\(--amber\\)\">\\+[\\d,]+ XP)") and "rest.push(m[1]" in l]
assert len(n)==1, n
old=L[n[0]]
tail="rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class=\"ocsr\">'+(m[2]?' '+m[2]:'')+m[4]+'</span>'+m[5]+(m[6]?'<span class=\"ocsr\">'+m[6]+'</span>':'')); continue; }"
assert old.endswith(tail), old[-200:]
new=old[:-len(tail)]+"rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class=\"ocsr\">'+(m[2]?' '+m[2]:'')+m[4]+(m[6]||'')+'</span>'+m[5]); continue; }   // v16.xx (cw-xpbreak), his picture 2026-10-28 (\"+2,386 xpthe seal on cold storage is broken...\"): the hidden part sits inside the xp span, so the line no longer ends on an ocsr span and the .ocsr + br rule no longer eats the break after it"
E=[{'anchor':old,'replacement':new}]
d={'title':'THE XP LINE KEEPS ITS OWN LINE ON THE EXTRACTED CARD',
   'why':'his picture 10-28: "+2,386 xpthe seal on cold storage is broken. it reseals harder: stage 1 needs 55 seconds." cw-spmoney (v35.45) hid the season total and the next reward sentence of the career xp line in a span that ended the line, and the .ocsr + br rule hid the line break after it, so the next line ran into the xp figure. The hidden part now sits inside the xp span and the break stays.',
   'now':'the xp line on the extracted card keeps its own line',
   'edits':E,'check':open(S+'check-xpbreak.js').read()}
for t in (old,new,d['check']): assert all(ord(c)<127 for c in t)
open(R+'tools/handoff/drafts/draft-cw-xpbreak.json','w').write(json.dumps(d,indent=1)); print('ok')
