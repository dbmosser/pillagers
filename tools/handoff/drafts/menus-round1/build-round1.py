import json
R='/home/user/pillagers/'; S='/tmp/claude-0/-home-user-pillagers/1c6f0e92-09e3-5935-b255-ee9e2a127028/scratchpad/'
G=open(R+'dark_raiders.html',encoding='utf-8').read().replace('\r','')
L=G.split('\n')
def one(s):
    n=[i for i,l in enumerate(L) if l==s]; assert len(n)==1,(s[:90],len(n)); return n[0]
def starts(p):
    n=[i for i,l in enumerate(L) if l.startswith(p)]; assert len(n)==1,(p[:90],len(n)); return n[0]
def chk(t): assert all(ord(c)<127 for c in t), [c for c in t if ord(c)>126][:3]
# ---- cw-pausecond
E=[]
an=("  h='<div class=\"psph\"><span>score</span><b>x'+diffMul().toFixed(2)+'</b></div>';\n"
    "  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);\n"
    "  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);")
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"  // v16.xx (cw-pausecond), his order of 2026-10-28 (\"all the modifiers/settings that impact sp\"): the raid conditions that pay sp since cw-cx-condition-sp\n"
"  // (night, hard weather, each signed term, x1.05 each, raidConditionRows) are rows too, under the settings, and the headline is the settings multiplier times\n"
"  // the conditions, which is what an sp is paid at (a career raid puts the conditions on at the settlement, a demo raid as it earns). No condition: one muted row.\n"
"  var C=[], cm=1;\n"
"  try{ C=raidConditionRows()||[]; cm=raidConditionMul(); }catch(_rc){ C=[]; cm=1; }\n"
"  h='<div class=\"psph\"><span>score</span><b>x'+(Math.round(diffMul()*cm*100)/100).toFixed(2)+'</b></div>';\n"
"  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);\n"
"  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);\n"
"  if(C.length) for(i=0;i<C.length;i++) h+=rw(C[i][0],'',DMUL_ON?C[i][1]:1).replace('class=\"psprow','class=\"psprow'+(i?'':' psc'));\n"
"  else h+=rw('conditions','none',1).replace('class=\"psprow','class=\"psprow psc');"})
an=L[starts("#root #pausebox.asking #pausesp, #root #pausebox.padlost #pausesp{")]
E.append({'anchor':an,'replacement':an+"\n#root #pausebox #pausesp .psc{ margin-top:var(--sp-1); }   /* v16.xx (cw-pausecond): the raid conditions sit a step under the settings rows */"})
d={'title':'THE PAUSE BOX LISTS THE RAID CONDITIONS THAT PAY SP',
   'why':"his order 10-28 for the pause box was every modifier that changes sp. cw-pausesp listed the settings; the conditions (night, hard weather, signed terms, x1.05 each since cw-cx-condition-sp the same day) were missing and the headline left them out. They are rows now, a clear day shows one muted conditions none row, and the headline is settings times conditions.",
   'now':'the pause box also lists night, weather and terms in the score panel',
   'edits':E,'check':open(S+'check-pausecond.js').read()}
for e in E: chk(e['anchor']); chk(e['replacement'])
chk(d['check']); open(R+'tools/handoff/drafts/draft-cw-pausecond.json','w').write(json.dumps(d,indent=1))
# ---- cw-menupolish1
E=[]
an="  money.innerHTML=(c.reward||0).toLocaleString()+'<em>c</em>';   // v8.42: see the note on the contract row"; one(an)
E.append({'anchor':an,'replacement':"  money.innerHTML='$'+(c.reward||0).toLocaleString();   // v8.42: see the note on the contract row. v16.xx (cw-menupolish1): money reads $N (his rule: $ for money), never N c"})
a=one("    h+='<div style=\"display:flex;gap:14px;font-size:14px;padding:3px 0;color:'+(P.ach[a.id]?'var(--amber)':'var(--ash)')+'\">'+")
assert L[a+1]=="       '<span style=\"width:230px;flex:0 0 230px\">'+(P.ach[a.id]?'':'LOCKED ')+a.n+'</span><span style=\"flex:1\">'+a.d+'</span></div>';"
E.append({'anchor':L[a]+'\n'+L[a+1],'replacement':
"    // v16.xx (cw-menupolish1): a locked achievement shows a lock icon before its name, not the word LOCKED glued to it (it read \"locked first out\"), and an\n"
"    // earned one carries class achon so it stands out in the gold its emblem has on the extracted card.\n"
"    h+='<div class=\"achrow'+(P.ach[a.id]?' achon':'')+'\" style=\"display:flex;gap:14px;font-size:14px;padding:3px 0;color:'+(P.ach[a.id]?'var(--amber)':'var(--ash)')+'\">'+\n"
"       '<span style=\"width:230px;flex:0 0 230px\">'+(P.ach[a.id]?'':uiIcon('lock',16,'achlk'))+a.n+'</span><span style=\"flex:1\">'+a.d+'</span></div>';"})
an=L[starts("#root #opane_rec #achlist > div > span{width:auto !important;min-width:0;}")]
E.append({'anchor':an,'replacement':an+"\n"
"/* v16.xx (cw-menupolish1): the lock icon sits before a locked name in the muted colour; an earned achievement reads in the emblem gold, its line in tx-1 */\n"
"#root #opane_rec #achlist .achlk{display:inline-block;vertical-align:-2px;margin-right:8px;color:var(--tx-2);}\n"
"#root #opane_rec #achlist > div.achrow.achon{color:var(--tx-1) !important;}\n"
"#root #opane_rec #achlist > div.achrow.achon > span:first-child{color:#ffe69a;}\n"
"#root #opane_rec #achlist > div.achrow:not(.achon) > span:first-child{color:var(--tx-2);}"})
d={'title':'MAINFRAME MONEY IN DOLLARS AND A LOCK ICON ON LOCKED ACHIEVEMENTS',
   'why':"menus master pass of 10-28 over every station window: the Mainframe contract card paid its money as 320 c (his rule: $ for money), and the achievements list glued the word LOCKED to each locked name (locked first out) with earned and locked rows in one colour. The reward reads $320, a locked row gets a lock icon, an earned row reads in the emblem gold.",
   'now':'contract rewards read in dollars and locked achievements show a lock',
   'edits':E,'check':open(S+'check-menupolish1.js').read()}
for e in E: chk(e['anchor']); chk(e['replacement'])
chk(d['check']); open(R+'tools/handoff/drafts/draft-cw-menupolish1.json','w').write(json.dumps(d,indent=1))
print('ok')
