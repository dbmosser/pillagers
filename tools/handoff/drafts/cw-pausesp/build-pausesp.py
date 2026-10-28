# Builds tools/handoff/drafts/draft-cw-pausesp.json from the current game (anchors read from the file, so they match exactly).
import json
R='/home/user/pillagers/'
S='/tmp/claude-0/-home-user-pillagers/1c6f0e92-09e3-5935-b255-ee9e2a127028/scratchpad/'
G=open(R+'dark_raiders.html',encoding='utf-8').read().replace('\r','')
L=G.split('\n')
def one(s):
    n=[i for i,l in enumerate(L) if l==s]; assert len(n)==1,(s[:90],len(n)); return n[0]
def starts(p):
    n=[i for i,l in enumerate(L) if l.startswith(p)]; assert len(n)==1,(p[:90],len(n)); return n[0]
E=[]
Q="HIS ORDER (2026-10-28), on a picture of the pause box: \"this isn't really helpful -- this is where all the modifiers/settings that impact sp should be shown, so the player knows exactly what they are playing\""
Q=Q.replace("isn't","isnt")  # keep the comment free of a quote that would end a JS string if ever pasted inside one
# 1. markup: the run log div becomes the sp panel
a=starts("  <!-- v35.xx (cw-msgroute): the last lines of the run log"); assert L[a+1].startswith('  <div id="pauselog"')
E.append({'anchor':L[a]+'\n'+L[a+1],'replacement':
"  <!-- v16.xx (cw-pausesp): what this raid pays in sp, setting by setting (pauseSpSync). It replaces the run log list (cw-msgroute), which stays in the run report -->\n"
"  <div id=\"pausesp\" style=\"display:none\"></div>"})
# 2. the run log list function becomes the sp panel
a=starts("// v35.xx (cw-msgroute): THE RUN LOG ON THE PAUSE BOX."); b=one("function togglePauseBox(on){")
E.append({'anchor':'\n'.join(L[a:b]),'replacement':
"// v16.xx (cw-pausesp), "+Q+".\n"
"// THE SCORE PANEL ON THE PAUSE BOX, in a raid (career or demo; never on the floor). The headline is the settings multiplier this raid pays (diffMul, what spMul\n"
"// puts on every sp), then one row per setting that moves it, with the choice it stands at and its own factor: pillager bots, machines, how hard they hit, heat\n"
"// when you call for extraction and fog of war as the raid was built with them (G.dmrows, kept beside G.dmul at the build, so a linked window shows the host's\n"
"// rows, as it is paid), and superhot as it stands now (read live, as diffMul reads it). The rows multiply to the headline. Under them the two end rules every\n"
"// raid scores by: an extraction doubles the raid score, a death halves it. Words are the Settings labels, so a row can be found there. The run log list that\n"
"// stood here (cw-msgroute) is gone from the box; the run log itself (G.msgLog) still goes out in the run report.\n"
"function gameOptLabel(k){ for(var i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) return String(GAMEOPTS[i].label).toLowerCase(); return k; }\n"
"function dmulRows(c){\n"
"  var t=diffTiers(c), K=[['raiders','raiders'],['robots','robots'],['hits','hits'],['ext','ext'],['fog','fogWar']], out=[], i, k, oi, w, row;\n"
"  for(i=0;i<K.length;i++){\n"
"    k=K[i][0]; row=null;\n"
"    for(oi=0;oi<GAMEOPTS.length;oi++) if(GAMEOPTS[oi].k===K[i][1]) row=GAMEOPTS[oi];\n"
"    if(k==='fog') w=t.fog?'on':'off';\n"
"    else { oi=gameOptLive(K[i][1]); w=(row&&oi>=0)?row.opts[oi].n:'custom'; }\n"
"    out.push([gameOptLabel(K[i][1]),String(w).toLowerCase(),DMUL_ON?1+DMUL_STEP[k]*(t[k]|0):1]);\n"
"  }\n"
"  return out;\n"
"}\n"
"function pauseSpSync(on){\n"
"  var el=document.getElementById('pausesp'), R, h, i, sh;\n"
"  if(!el) return false;\n"
"  if(!(on&&G&&!G.over&&!G.sim)){ el.style.display='none'; el.textContent=''; return false; }\n"
"  R=(G.dmrows&&G.dmrows.length)?G.dmrows:dmulRows(CFG);\n"
"  sh=(CFG&&CFG.superhot)?1:(DMUL_ON?1+DMUL_STEP.superhot:1);\n"
"  function rw(l,w,x){ return '<div class=\"psprow'+(x>1?'':' z')+'\"><span>'+escHtml(l)+'</span><i>'+escHtml(w)+'</i><b>x'+x.toFixed(2)+'</b></div>'; }\n"
"  h='<div class=\"psph\"><span>score</span><b>x'+diffMul().toFixed(2)+'</b></div>';\n"
"  for(i=0;i<R.length;i++) h+=rw(R[i][0],R[i][1],R[i][2]);\n"
"  h+=rw(gameOptLabel('superhot'),(CFG&&CFG.superhot)?'on':'off',sh);\n"
"  h+='<div class=\"psprule psp1\"><span>extract</span><b>x2</b></div><div class=\"psprule\"><span>killed in action</span><b>-50%</b></div>';\n"
"  el.innerHTML=h; el.style.display='';\n"
"  return true;\n"
"}"})
# 3. the box calls the panel
an="  try{ pauseLogSync(on); }catch(_pls){}   // v35.xx (cw-msgroute): the run log's last lines"; one(an)
E.append({'anchor':an,'replacement':"  try{ pauseSpSync(on); }catch(_pls){}   // v16.xx (cw-pausesp): what this raid pays in sp, setting by setting (it was the run log's last lines, cw-msgroute)"})
# 4. the rows a raid is built with, beside the product
for an in ("  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows this raid was built with (a linked window builds under the host word)",
           "  g.dmul=diffMulOf(CFG,1);   // v35.xx (cw-diffmul): the settings multiplier rows, as for a career raid (his rule: the demo and career play the same)"):
    one(an)
    E.append({'anchor':an,'replacement':an+"\n  try{ g.dmrows=dmulRows(CFG); }catch(_dr){ g.dmrows=null; }   // v16.xx (cw-pausesp): each row's choice and factor, for the pause box score panel"})
# 5. leaving Settings mid raid redraws the panel (superhot is read live)
an="  document.getElementById('settingsmodal').classList.remove('on');\n};"
assert G.count("document.getElementById('closesettings').onclick=function(){\n  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first\n"+an)==1
an="  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first\n"+an
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first\n"
"  document.getElementById('settingsmodal').classList.remove('on');\n"
"  try{ if(pauseOpen) pauseSpSync(true); }catch(_psr){}   // v16.xx (cw-pausesp): a superhot switched in Settings mid raid shows at once on the pause box\n"
"};"})
# 6. CSS
an=starts("#root #pausebox.asking #pausex{ top:")
E.append({'anchor':L[an],'replacement':L[an]+"\n"
"/* v16.xx (cw-pausesp): the score panel under the title, the column's own width (--pw). Headline row: score label left, the multiplier in the sp gold at title size.\n"
"   A row: the setting, its choice, its factor; a factor of x1.00 is muted. A line, then the two end rules. Hidden while abandon asks and while a pad is lost. */\n"
"#root #pausebox #pausesp{ box-sizing:border-box; width:var(--pw); max-width:100%; display:flex; flex-direction:column; text-align:left; font:600 var(--fs-label)/1.25 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }\n"
"#root #pausebox #pausesp .psph{ display:flex; align-items:baseline; justify-content:space-between; padding:0 0 var(--sp-1); }\n"
"#root #pausebox #pausesp .psph span{ color:var(--tx-2); }\n"
"#root #pausebox #pausesp .psph b{ font:700 var(--fs-title)/1 var(--f-cond); color:#ffc04a; font-variant-numeric:tabular-nums; }\n"
"#root #pausebox #pausesp .psprow{ display:grid; grid-template-columns:1fr auto calc(var(--sp-1) * 7); gap:var(--sp-2); align-items:baseline; padding:4px 0; }\n"
"#root #pausebox #pausesp .psprule{ display:grid; grid-template-columns:1fr calc(var(--sp-1) * 7); gap:var(--sp-2); align-items:baseline; padding:4px 0; color:var(--tx-2); }\n"
"#root #pausebox #pausesp .psp1{ margin-top:var(--sp-1); padding-top:calc(var(--sp-1) + 4px); border-top:1px solid var(--ui-line); }\n"
"#root #pausebox #pausesp i{ font-style:normal; color:var(--tx-2); }\n"
"#root #pausebox #pausesp .psprow b, #root #pausebox #pausesp .psprule b{ text-align:right; color:#ffc04a; font-variant-numeric:tabular-nums; }\n"
"#root #pausebox #pausesp .psprow.z b{ color:var(--tx-2); }\n"
"#root #pausebox.asking #pausesp, #root #pausebox.padlost #pausesp{ display:none !important; }"})
check=open(S+'check-pausesp.js').read()
d={'title':'THE PAUSE BOX SHOWS WHAT THE RAID PAYS IN SP',
   'why':"his order 10-28 with a picture of the raid pause box: the run log list there is not helpful; it is where every setting that changes sp should show, so the player knows exactly what they are playing. The box now shows the settings multiplier this raid pays, one row per setting that moves it (pillager bots, machines, how hard they hit, heat when you call for extraction, fog of war, superhot) with its choice and factor, and the two end rules (extract x2, killed in action -50%). The run log list leaves the box; the run log stays in the run report.",
   'now':'the pause box shows what your raid pays in sp, setting by setting',
   'edits':E,'check':check}
for e in E:
    for t in (e['anchor'],e['replacement']):
        bad=[c for c in t if ord(c)>126]; assert not bad, bad[:3]
assert all(ord(c)<127 for c in check)
open(R+'tools/handoff/drafts/draft-cw-pausesp.json','w').write(json.dumps(d,indent=1))
print('edits',len(E))
