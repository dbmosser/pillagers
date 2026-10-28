# Builds tools/handoff/drafts/draft-cw-spmoney.json from the current game (anchors read from the file, so they match exactly).
import json, re
R='/home/user/pillagers/'
G=open(R+'dark_raiders.html',encoding='utf-8').read().replace('\r','')
L=G.split('\n')
def find(s, start=0):
    hits=[i for i,l in enumerate(L) if l==s]
    assert len(hits)==1, (s[:80], len(hits)); return hits[0]
def block(first_prefix, last_prefix):
    a=[i for i,l in enumerate(L) if l.startswith(first_prefix)]; assert len(a)==1,(first_prefix,len(a)); a=a[0]
    b=[i for i,l in enumerate(L) if i>=a and l.startswith(last_prefix)][0]
    return '\n'.join(L[a:b+1])
E=[]
# 1. extraction: DAMAGE TAKEN gets its own class so it can sit under the result and line up with it
an="    DEATH_FEED_HTML=recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN, when anything hit you"; find(an)
E.append({'anchor':an,'replacement':an+"\n    if(DEATH_FEED_HTML) DEATH_FEED_HTML='<div class=\"ocrecap\">'+DEATH_FEED_HTML+'</div>';   // v16.xx (cw-spmoney): on the EXTRACTED card the damage block is a footnote under the result, lined up with it (CSS ocrecap)"})
# 2. extraction: the result leads, DAMAGE TAKEN after it
an="  document.getElementById('oc_manifest').innerHTML=\n    (DEATH_FEED_HTML||'')+lines.join('<br>');"
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"  // v16.xx (cw-spmoney), HIS ORDER (2026-10-28) on the extracted card: \"this extracted screen is an absolute mess\". The result leads: on an extraction DAMAGE TAKEN\n"
"  // comes after the ledger and the lines, where it was the first thing under the title; a KIA card still opens on what killed you.\n"
"  document.getElementById('oc_manifest').innerHTML=(how==='extract')?\n"
"    (lines.join('<br>')+(DEATH_FEED_HTML||'')):((DEATH_FEED_HTML||'')+lines.join('<br>'));"})
# 3. the xp line on a CAREER card: the figure only, as every other card has it since cw-haulread and cw-endcards2
an="    if(/>(CAREER SCORE |SCORE LOST|CAREER BEST|CAREER BOARD #)/.test(ln)) continue;\n    rest.push(ln);"
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"    if(/>(CAREER SCORE |SCORE LOST|CAREER BEST|CAREER BOARD #)/.test(ln)) continue;\n"
"    // v16.xx (cw-spmoney): the xp line here reads \"+2,782 xp\" (or \"+65 xp . 50% penalty\"), as ocStatRow made it on every other card. The season total and the\n"
"    // \"next: ..., reward n of 100, ... claim it at the mainframe\" sentence stay as hidden text (ocsr), so nothing that reads the card moves. In his picture of\n"
"    // 2026-10-28 that sentence was the line cut in half behind the leaderboard button.\n"
"    if((m=/^(<span style=\"color:var\\(--amber\\)\">\\+[\\d,]+ XP)(?: (\\((\\d+)% penalty [^)]*\\)))?(  &middot;  [\\d,]+(?: of [\\d,]+| XP in all))(<\\/span>)(.*)$/.exec(ln))){ rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class=\"ocsr\">'+(m[2]?' '+m[2]:'')+m[4]+'</span>'+m[5]+(m[6]?'<span class=\"ocsr\">'+m[6]+'</span>':'')); continue; }\n"
"    rest.push(ln);"})
# 4. the ledger: two panels, sp only and $ only
an=block("  if(s-sum!==0) parts.push(['OTHER','BONUSES',s-sum]);","  h+=row('tot'+(ex?'':' lost'),")
assert G.count(an)==1
E.append({'anchor':an,'replacement':
"  if(s-sum!==0) parts.push(['OTHER','BONUSES',s-sum]);\n"
"  // v16.xx (cw-spmoney), HIS ORDER (2026-10-28), on a picture of this card: \"this extracted screen is an absolute mess -- money versus raid score/sp should never be\n"
"  // intermingled\". It was one list: sp rows, then the credits in $, then the haul, then a RAID TOTAL in $ drawn in the score's own gold. Now two panels side by side.\n"
"  // RAID SCORE (gold, sp only): where each point came from, the x2 or the KIA half, and its total. MONEY (teal, $ only): items secured, haul value, the credits\n"
"  // banked, and its total. No row carries both units and no total sits in the other panel. The figures, the classes the tally and the checks read (sc, cr, hv,\n"
"  // tot, lost, haultot) and his rules (1 sp banks $1 on an extraction, KIA halves the score and banks nothing) are unchanged. The haul pictures sit under both.\n"
"  var sh='', mh='';\n"
"  for(i=0;i<parts.length;i++){\n"
"    p=parts[i]; v=p[2]; if(!v) continue;\n"
"    sh+=row('','<span class=\"lgl\">'+p[1]+'</span>'+((v<0)?('<b>-'+arcadeCr(-v)+'</b>'):cnt(v,'')));\n"
"  }\n"
"  if(ex) sh+=row('','<span class=\"lgl\">EXTRACTION x2</span>'+cnt(s,'+'));\n"
"  else if(s>0) sh+=row('lost','<span class=\"lgl\">KIA -50%</span><b>-'+arcadeCr(s-fin)+'</b>');   // v28.67 (lean1): HIS RULE, KIA is a 50% score penalty\n"
"  sh+=row('sc','<span class=\"lgl\">TOTAL</span>'+((fin>0)?cnt(fin,''):('<b>'+arcadeCr(0)+'</b>')));\n"
"  if(ex){\n"
"    mh+=row('ni','<span class=\"lgl\">ITEMS SECURED</span><b>'+ni+'</b>');\n"
"    mh+=row('hv','<span class=\"lgl\">HAUL VALUE</span><b id=\"haultot\" data-pre=\"\">'+arcadeMoney(hv)+'</b>');\n"
"    mh+=row('cr','<span class=\"lgl\">CREDITS BANKED</span>'+((fin>0)?cnt(fin,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));\n"
"    tot=fin+hv;\n"
"  } else {\n"
"    mh+=row('lost','<span class=\"lgl\">HAUL VALUE</span><b><s>'+arcadeMoney(lostV||x.haul||0)+'</s> LOST</b>');\n"
"    mh+=row('lost','<span class=\"lgl\">CREDITS NOT BANKED</span><b><s>+'+arcadeMoney(fin)+'</s> LOST</b>');\n"
"    tot=0;\n"
"  }\n"
"  mh+=row('tot'+(ex?'':' lost'),'<span class=\"lgl\">TOTAL</span>'+((tot>0)?cnt(tot,'',1):('<b>'+arcadeMoney(0)+'</b>')));\n"
"  h+='<div class=\"lgcols\"><div class=\"lgp lgps\"><div class=\"lgh\">RAID SCORE'+((R&&R.best)?' <em class=\"lgpb\">PERSONAL BEST</em>':'')+'</div>'+sh+'</div>'+\n"
"     '<div class=\"lgp lgpm\"><div class=\"lgh\">MONEY</div>'+mh+'</div></div>';\n"
"  if(ex&&strip){ h+='<div class=\"lgstrip\" style=\"--i:'+idx+'\">'+strip+'</div>'; idx++; }"})
# 5. the CSS for the panels and the damage footnote
an="  '.lg.lgdone .lgr,.lg.lgdone .lgstrip,.lg.lgdone .lgst,.lg.lgdone .lgem{animation:none;opacity:1}');"; find(an)
E.append({'anchor':an,'replacement':
"  '.lg.lgdone .lgr,.lg.lgdone .lgstrip,.lg.lgdone .lgst,.lg.lgdone .lgem{animation:none;opacity:1}'+\n"
"  // v16.xx (cw-spmoney): the two panels. Each has one colour for its figures and its top bar (score gold #ffc04a, money teal #7fe3d4, the colours the\n"
"  // RAID SCORE and CREDITS rows already had), rows at 16px with no tag column, and its total pinned to its foot so the two totals line up. The ledger takes the\n"
"  // card's full 624px, so six medal emblems fit on one line.\n"
"  '.lg{width:100%;max-width:624px}'+\n"
"  '.lg .lgcols{display:grid;grid-template-columns:1fr 1fr;gap:16px;align-items:stretch}'+\n"
"  '.lg .lgp{display:flex;flex-direction:column;min-width:0;padding:12px 16px 14px;border:1px solid var(--ui-line,#2e3337);border-top:3px solid var(--lgc);border-radius:4px;background:rgba(0,0,0,.22)}'+\n"
"  '.lg .lgps{--lgc:#ffc04a}.lg .lgpm{--lgc:#7fe3d4}'+\n"
"  '.lg .lgh{display:flex;align-items:center;gap:8px;min-height:24px;margin:0 0 4px;font-size:16px;letter-spacing:.14em;color:var(--lgc)}'+\n"
"  '.lg .lgh .lgpb{margin-left:auto;font-size:12px}'+\n"
"  '.lg .lgp .lgr{grid-template-columns:1fr auto;gap:0 12px;padding:4px 0;font-size:16px;border-bottom:0}'+\n"
"  '.lg .lgp .lgr .lgl{grid-column:auto;min-width:0}'+\n"
"  '.lg .lgp .lgr b{color:var(--lgc)}.lg .lgp .lgr.ni b{color:var(--tx-1,#efe9dc)}.lg .lgp .lgr.lost b,.lg .lgp .lgr.lost .lgl{color:var(--rust)}'+\n"
"  '.lg .lgp .lgr.sc,.lg .lgp .lgr.tot{margin-top:auto;padding:10px 0 0;border:0;border-top:1px solid var(--lgc);border-radius:0;background:none;font-size:28px;letter-spacing:.06em;color:var(--lgc)}'+\n"
"  '.lg .lgp .lgr.sc .lgl,.lg .lgp .lgr.tot .lgl{align-self:center;font-size:16px;letter-spacing:.14em;color:var(--tx-2,#aaa498)}'+\n"
"  '.lg .lgp .lgr.tot.lost{border-top-color:var(--rust)}'+\n"
"  '#root #oc_manifest .ocrecap{width:100%;max-width:624px;margin:8px auto 0;text-align:left}'+\n"
"  '#root #oc_manifest .ocrecap>div>div{font-size:16px !important;letter-spacing:.04em}'+\n"
"  '#root #oc_manifest .ocrecap>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}');"})
# 6. the lines under the ledger get the chip treatment every other card has (recovered guns, a contract done)
an="  return ['<div class=\"lg\">'+h+'</div>'].concat(rest);"; find(an)
E.append({'anchor':an,'replacement':
"  // v16.xx (cw-spmoney): the lines under the ledger go through ocStatRow like every other card, so each recovered gun is one name chip and a finished\n"
"  // contract one chip, not a sentence a line (eight recovered guns were eight sentences and ran the card past 1080p). Their words stay as hidden text (ocsr).\n"
"  try{ rest=ocStatRow(rest,{}); }catch(_osr){}\n"
"  return ['<div class=\"lg\">'+h+'</div>'].concat(rest);"})
check=check=open('/tmp/claude-0/-home-user-pillagers/1c6f0e92-09e3-5935-b255-ee9e2a127028/scratchpad/check-spmoney.js').read()
d={'title':'THE EXTRACTED CARD SPLITS SCORE AND MONEY',
   'why':'his order 10-28 with a picture of the extracted card: \"this extracted screen is an absolute mess -- money versus raid score/sp should never be intermingled\". The career ledger was one list: sp rows, the credits in $, the haul, and a raid total in $ drawn in the score gold; damage taken sat above the result; the card ran past 1080p so the xp line and a next reward sentence were cut off behind the button. Now a raid score panel (sp only, gold) and a money panel ($ only, teal) side by side, each with its own total; the haul pictures under both; damage taken under the result on an extraction; the xp line is the figure only. Same figures and same rules (1 sp banks 1 dollar on an extraction, KIA halves the score).',
   'now':'the extracted card keeps score and money apart: score on the left in sp, money on the right in dollars',
   'edits':E,'check':check}
for e in E:
    for t in (e['anchor'],e['replacement']):
        bad=[c for c in t if ord(c)>126]; assert not bad, bad[:3]
open(R+'tools/handoff/drafts/draft-cw-spmoney.json','w').write(json.dumps(d,indent=1))
print('edits',len(E))
