import json
R='/home/user/pillagers/'; S='/tmp/claude-0/-home-user-pillagers/1c6f0e92-09e3-5935-b255-ee9e2a127028/scratchpad/'
G=open(R+'dark_raiders.html',encoding='utf-8').read().replace('\r','')
L=G.split('\n')
def one(s):
    n=[i for i,l in enumerate(L) if l==s]; assert len(n)==1,(s[:90],len(n)); return n[0]
def chk(t): assert all(ord(c)<127 for c in t), [c for c in t if ord(c)>126][:3]
E=[]
an='    <div class="plist" id="gamblelist" style="border:1px solid var(--steel);max-height:220px"></div>'; one(an)
E.append({'anchor':an,'replacement':'    <div id="gambleodds"></div><!-- v16.xx (cw-menupolish2): the mystery tile and the odds of each rarity (gambleOddsDraw) -->\n'+an})
an="function renderGamble(){"; one(an)
E.append({'anchor':an,'replacement':
"// v16.xx (cw-menupolish2), menus master pass 2026-10-28: THE GAMBLE panel was an empty box over its button until a first roll (its \"nothing rolled yet\" line is\n"
"// hidden on purpose), beside an offer panel with a 192px picture. It now has a mystery tile of the same size and the odds of each rarity, read from\n"
"// GAMBLE_POOL (a key counts as rare, as the keys are), each in its rarity colour. Display only: the pool, its weights and the price do not move.\n"
"function gambleOdds(){\n"
"  var by={}, tot=0, i, k, w, r, out=[], order=['common','uncommon','rare','elite','gold'];\n"
"  for(i=0;i<GAMBLE_POOL.length;i++){ k=GAMBLE_POOL[i][0]; w=+GAMBLE_POOL[i][1]||0; r=(k==='KEY')?'rare':((typeof dispR==='function'&&dispR(k))||(ITEMS[k]&&ITEMS[k].r)||'common'); by[r]=(by[r]||0)+w; tot+=w; }\n"
"  for(i=0;i<order.length;i++) if(by[order[i]]) out.push([order[i],tot?by[order[i]]/tot:0]);\n"
"  return out;\n"
"}\n"
"function gambleOddsDraw(){\n"
"  var el=document.getElementById('gambleodds'), O, h, i, pc;\n"
"  if(!el) return false;\n"
"  O=gambleOdds(); h='<div class=\"gbtile\"><span>?</span></div><div class=\"gbodds\">';\n"
"  for(i=0;i<O.length;i++){ pc=Math.round(O[i][1]*100); h+='<div class=\"gbrow\" style=\"--rc:'+(RCOL[O[i][0]]||'#9da3a8')+'\"><span>'+O[i][0]+'</span><i><b style=\"width:'+pc+'%\"></b></i><em>'+pc+'%</em></div>'; }\n"
"  el.innerHTML=h+'</div>';\n"
"  return true;\n"
"}\n"
"function renderGamble(){"})
an="  el.innerHTML=h;\n  var b=document.getElementById('gamblebtn');"; assert G.count(an)==1
E.append({'anchor':an,'replacement':"  el.innerHTML=h;\n  try{ gambleOddsDraw(); }catch(_god){}   // v16.xx (cw-menupolish2): the mystery tile and the odds\n  var b=document.getElementById('gamblebtn');"})
an="#root #gamblemodal #wirtlot > span[title] img{width:176px !important;height:176px !important;}"; one(an)
E.append({'anchor':an,'replacement':an+"\n"
"/* v16.xx (cw-menupolish2): THE GAMBLE panel: a 192px mystery tile (the offer picture's size) over the odds, one row a rarity: name in its colour, a 6px bar, the percent */\n"
"#root #gamblemodal #gambleodds{flex:none;display:flex;flex-direction:column;align-items:stretch;gap:var(--sp-3);width:100%;}\n"
"#root #gamblemodal #gambleodds .gbtile{align-self:center;box-sizing:border-box;width:192px;height:192px;display:flex;align-items:center;justify-content:center;border-radius:var(--rad);background:radial-gradient(circle at 50% 50%,rgba(168,102,224,.24),rgba(0,0,0,0) 68%),var(--ui-raised);font:700 112px/1 var(--f-cond);color:var(--tx-2);}\n"
"#root #gamblemodal #gambleodds .gbodds{display:flex;flex-direction:column;gap:var(--sp-1);}\n"
"#root #gamblemodal #gambleodds .gbrow{display:grid;grid-template-columns:calc(var(--sp-1) * 14) 1fr calc(var(--sp-1) * 7);gap:var(--sp-2);align-items:center;font:600 var(--fs-label)/1.4 var(--f-cond);letter-spacing:var(--track);}\n"
"#root #gamblemodal #gambleodds .gbrow span{color:var(--rc);}\n"
"#root #gamblemodal #gambleodds .gbrow i{display:block;height:6px;border-radius:3px;overflow:hidden;background:var(--ui-line);}\n"
"#root #gamblemodal #gambleodds .gbrow i b{display:block;height:100%;background:var(--rc);}\n"
"#root #gamblemodal #gambleodds .gbrow em{font-style:normal;text-align:right;font-variant-numeric:tabular-nums;color:var(--tx-2);}"})
an="#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(9,minmax(0,1fr));gap:8px!important;width:100%;}"; one(an)
E.append({'anchor':an,'replacement':an+"\n#root #hub #hotplanwrap{box-sizing:border-box;padding:0 12px;}   /* v16.xx (cw-menupolish2): the hotbar slots sit on the backpack grid's 12px inset; they ran to the panel edge */"})
d={'title':'THE GAMBLE SHOWS ITS ODDS AND THE STASH HOTBAR LINES UP',
   'why':"menus master pass 10-28: at Wirt the gamble panel was an empty box over its button until a first roll, beside an offer panel with a big picture; it now shows a mystery tile of the same size and the odds of each rarity from the gamble pool (common 9, uncommon 34, rare 32 with keys, elite 25). On the stash screen the hotbar slots ran to the panel edge while every other grid sits on a 12px inset; they line up now.",
   'now':'the gamble shows its odds by rarity and the stash hotbar lines up',
   'edits':E,'check':open(S+'check-menupolish2.js').read()}
for e in E: chk(e['anchor']); chk(e['replacement'])
chk(d['check']); open(R+'tools/handoff/drafts/draft-cw-menupolish2.json','w').write(json.dumps(d,indent=1)); print('ok')
