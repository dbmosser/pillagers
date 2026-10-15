$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE RUN CARD IS ONE AFTER ACTION LEDGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  document.getElementById('oc_manifest').innerHTML=
    (DEATH_FEED_HTML||'')+lines.join('<br>');
'@ @'
  OC_LG=null;
  try{ if(G.career&&G.cs&&!G.sim&&(how==='extract'||how==='dead')) lines=ocLedger(how,lines,{acc:acc,sec:_tsec,hp:Math.round(G.player.hp),haul:haul}); }catch(_lg){ OC_LG=null; }   // v27.NN (cboard2): the AFTER ACTION LEDGER
  document.getElementById('oc_manifest').innerHTML=
    (DEATH_FEED_HTML||'')+lines.join('<br>');
'@

SubRx @'
if(how==='extract'&&!G.sim){ try{ haulRevealStart(); }catch(_hrv){} }
'@ @'
try{ ocLgStart(); }catch(_lgs){}   // v27.NN (cboard2): the ledger tallies row by row, then the haul reveals
  if(how==='extract'&&!G.sim){ try{ haulRevealStart(); }catch(_hrv){} }
'@

SubRx @'
el.textContent='HAUL  $'+Math.round(R.sum).toLocaleString();
'@ @'
el.textContent=(el.hasAttribute('data-pre')?el.getAttribute('data-pre'):'HAUL  ')+'$'+Math.round(R.sum).toLocaleString();
'@

SubRx @'
strip.insertAdjacentHTML('afterend','<div class="haultot" id="haultot">HAUL  $0</div>');
'@ @'
if(!document.getElementById('haultot')) strip.insertAdjacentHTML('afterend','<div class="haultot" id="haultot">HAUL  $0</div>');
'@

SubRx @'
HAUL_REV={list:list,i:0,t:0.3,sum:0,sec:sec};
'@ @'
HAUL_REV={list:list,i:0,t:0.3+((OC_LG&&OC_LG.t)||0),sum:0,sec:sec}; haulTotalLine();
'@

SubRx @'
function haulRevealSkip(){
  var R=HAUL_REV;
  if(!R||R.i>=R.list.length) return false;
'@ @'
function haulRevealSkip(){
  var R=HAUL_REV, lg=false;
  try{ lg=ocLgSkip(); }catch(_lgk){}   // v27.NN (cboard2): a press while the ledger tallies lands the tally first
  if(!R||R.i>=R.list.length) return lg;
'@

SubRx @'
function haulRevealing(){ return !!(HAUL_REV&&HAUL_REV.i<HAUL_REV.list.length); }
'@ @'
function haulRevealing(){ return !!(HAUL_REV&&HAUL_REV.i<HAUL_REV.list.length)||ocLgTally(); }   // v27.NN (cboard2): the ledger tally is part of what a press skips
'@

SubRx @'
function buildTags(){
'@ @'
// v27.NN (cboard2), HIS ORDER (2026-10-15): "stats page should account for scoring system vs haul amt -- need to reconcile the two concepts somehow in a smoother AAA manner".
// The EXTRACTED card showed the haul and no raid score, and the raid score (kills, medals, goals, bounty, strongholds, vaults, the x2) lived only on the HUD, so two
// money numbers read as unrelated. A CAREER card is now ONE AFTER ACTION LEDGER, in terse caps that tally in row by row (a press lands them): the RAID SCORE rows by
// where each point came from (G.cs.b), EXTRACTION x2 on an extraction, RAID SCORE, CREDITS (1 score = 1 credit, banked only on an extraction), the HAUL (the item
// pictures, ITEMS SECURED and HAUL VALUE), and one headline RAID TOTAL = the credits earned plus the haul value. A death keeps the score rows, shows the credits and the
// haul as LOST with the figure struck through, and a RAID TOTAL of nothing, as a death pays and returns empty. The sentences it replaces (items secured for, extracted
// with N of 100 health, the container, accuracy and time line, the ACHIEVEMENT lines and the score words) become five stat tiles (KILLS, ACCURACY, CONTAINERS, TIME,
// HEALTH) and the achievements as medal emblems in the v27.38 chamfered metal. The leaderboard and the run record rank by RAID SCORE. A card of any other raid is as it was.
var OC_LG=null;
function ocLgTally(){ return !!(OC_LG&&OC_LG.end>Date.now()); }
function ocLgStart(){
  var w=document.getElementById('oc_manifest'), lg=w&&w.querySelector('.lg'), els, i;
  if(!OC_LG||!lg){ OC_LG=null; return 0; }
  OC_LG.end=Date.now()+OC_LG.t*1000;
  els=lg.querySelectorAll('[data-to]');
  for(i=0;i<els.length;i++) lbCountStart(els[i],+els[i].getAttribute('data-to')||0,+els[i].getAttribute('data-dl')||0,600);
  return els.length;
}
function ocLgSkip(){
  var w=document.getElementById('oc_manifest'), lg=w&&w.querySelector('.lg');
  if(!ocLgTally()||!lg) return false;
  lg.classList.add('lgdone'); lbCountEnd(lg); OC_LG.end=0;
  return true;
}
function ocEmblem(n,d,id){
  var ic=(typeof UIICON==='object'&&UIICON&&UIICON.xp)||'';
  return '<span class="lgeb" title="'+escHtml(d||'')+'"><svg viewBox="0 0 48 48" aria-hidden="true"><defs><linearGradient id="lgg'+id+'" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffe69a"/><stop offset=".45" stop-color="#f5b73b"/><stop offset="1" stop-color="#8a5a10"/></linearGradient></defs>'+
    '<polygon points="9.6,0 38.4,0 48,9.6 48,38.4 38.4,48 9.6,48 0,38.4 0,9.6" fill="url(#lgg'+id+')"/>'+
    '<polygon points="12.8,5.3 35.2,5.3 42.7,12.8 42.7,35.2 35.2,42.7 12.8,42.7 5.3,35.2 5.3,12.8" fill="#161a1d" stroke="rgba(255,196,74,.6)" stroke-width="1"/>'+
    '<g transform="translate(12 12)"><path d="'+ic+'" fill="none" stroke="#ffc44a" stroke-width="1.8" stroke-linejoin="round" stroke-linecap="round"/></g></svg><i>'+escHtml(n)+'</i></span>';
}
function ocLedger(how,lines,x){
  var ex=(how==='extract'), c=G.cs, s=Math.max(0,c.s|0), fin=ex?s*2:s, b=c.b||{}, T=G.tel||{}, R=G.careerLb, rest=[], strip='', hv=0, ni=0, lostV=0, i, ln, m, sum=0, tot, h='', idx=0, prev='', kn=0, kk, tiles, ach=G.achNew||[], parts, p, v, tg;
  function cnt(v,pre){ return '<b data-to="'+(v|0)+'" data-pre="'+(pre||'')+'" data-dl="'+(idx*90)+'">'+(pre||'')+arcadeCr(v)+'</b>'; }
  function row(cls,inner){ var r='<div class="lgr '+cls+'" style="--i:'+idx+'">'+inner+'</div>'; idx++; return r; }
  for(i=0;i<lines.length;i++){
    ln=String(lines[i]);
    if(ln.indexOf('<span class="haulstrip"')===0){ strip=ln; continue; }
    if((m=/^(\d+) items? secured for \$([\d,]+)$/.exec(ln))){ ni=+m[1]; hv=+m[2].replace(/,/g,''); continue; }
    if((m=/^.* lost, \$([\d,]+) gone$/.exec(ln))){ lostV=+m[1].replace(/,/g,''); continue; }
    if(/^You extracted with \d+ of 100 health$/.test(ln)||ln.indexOf(' accuracy &middot; ')>=0||ln.indexOf('>ACHIEVEMENT: ')>=0) continue;
    if(/>(CAREER SCORE |SCORE LOST|CAREER BEST|CAREER BOARD #)/.test(ln)) continue;
    rest.push(ln);
  }
  parts=[['COMBAT','KILLS',b.kill|0],['COMBAT','MEDALS',b.style|0],['OBJECTIVES','GOALS',b.goal|0],['OBJECTIVES','BOUNTY',b.bounty|0],['OBJECTIVES','STRONGHOLDS',b.strong|0],['OBJECTIVES','VAULTS',b.vault|0],['FORGE','UPGRADES',b.forge|0]];
  for(i=0;i<parts.length;i++) sum+=parts[i][2];
  if(s-sum!==0) parts.push(['OTHER','BONUSES',s-sum]);
  for(i=0;i<parts.length;i++){
    p=parts[i]; v=p[2]; if(!v) continue;
    tg=(p[0]!==prev)?p[0]:''; prev=p[0];
    h+=row('','<span class="lgt">'+tg+'</span><span class="lgl">'+p[1]+'</span>'+((v<0)?('<b>-'+arcadeCr(-v)+'</b>'):cnt(v,'')));
  }
  if(ex) h+=row('','<span class="lgt">EXTRACTION</span><span class="lgl">x2</span>'+cnt(s,'+'));
  h+=row('sc','<span class="lgl">RAID SCORE'+((R&&R.best)?' <em class="lgpb">PERSONAL BEST</em>':'')+'</span>'+((fin>0)?cnt(fin,''):('<b>'+arcadeCr(0)+'</b>')));
  if(ex) h+=row('cr','<span class="lgt">CREDITS</span><span class="lgl">BANKED</span>'+((fin>0)?cnt(fin,'+'):'<b>+'+arcadeCr(0)+'</b>'));
  else h+=row('lost','<span class="lgt">CREDITS</span><span class="lgl">NOT BANKED</span><b><s>+'+arcadeCr(s)+'</s> LOST</b>');
  if(ex){
    h+=row('','<span class="lgt">HAUL</span><span class="lgl">ITEMS SECURED</span><b>'+ni+'</b>');
    if(strip){ h+='<div class="lgstrip" style="--i:'+idx+'">'+strip+'</div>'; idx++; }
    h+=row('hv','<span class="lgt"></span><span class="lgl">HAUL VALUE</span><b id="haultot" data-pre="">'+arcadeCr(hv)+'</b>');
    tot=fin+hv;
  } else {
    h+=row('lost','<span class="lgt">HAUL</span><span class="lgl">VALUE</span><b><s>'+arcadeCr(lostV||x.haul||0)+'</s> LOST</b>');
    tot=0;
  }
  h+=row('tot'+(ex?'':' lost'),'<span class="lgl">RAID TOTAL</span>'+((tot>0)?cnt(tot,''):('<b>'+arcadeCr(0)+'</b>')));
  for(kk in (T.kills||{})) kn+=(T.kills[kk]||0);
  tiles=[[kn,'KILLS'],[(x.acc|0)+'%','ACCURACY'],[T.containers|0,'CONTAINERS'],[fmtClock(x.sec|0),'TIME'],[ex?(x.hp|0):0,'HEALTH']];
  h+='<div class="lgst" style="--i:'+idx+'">';
  for(i=0;i<tiles.length;i++) h+='<div class="lgti"><b>'+tiles[i][0]+'</b><span>'+tiles[i][1]+'</span></div>';
  h+='</div>'; idx++;
  if(ach.length){
    h+='<div class="lgem" style="--i:'+idx+'">';
    for(i=0;i<ach.length;i++) h+=ocEmblem(ach[i].n||'',ach[i].d||ach[i].desc||'',i);
    h+='</div>'; idx++;
  }
  OC_LG={t:idx*0.09+0.35,end:0};
  return ['<div class="lg">'+h+'</div>'].concat(rest);
}
careerStyle('lgcss',
  '.lg{width:min(540px,100%);margin:4px auto 6px;text-align:left;font-family:var(--f-cond);text-transform:uppercase;letter-spacing:.1em;line-height:1.4}'+
  '.lg .lgr{display:grid;grid-template-columns:118px 1fr auto;gap:0 12px;align-items:baseline;padding:3px 4px;font-size:15px;color:var(--bone);border-bottom:1px solid rgba(170,164,152,.12);opacity:0;animation:lgin .28s ease-out both;animation-delay:calc(var(--i,0)*.09s)}'+
  '.lg .lgt{font-size:11.5px;letter-spacing:.2em;color:var(--ash)}'+
  '.lg .lgr b{font-weight:700;text-align:right;font-variant-numeric:tabular-nums}'+
  '.lg .lgr.sc .lgl,.lg .lgr.tot .lgl{grid-column:1/3}'+
  '.lg .lgr.sc{margin-top:5px;padding-top:6px;border-top:1px solid rgba(255,192,74,.45);font-size:18px;color:#ffc04a}'+
  '.lg .lgr.cr b{color:#7fe3d4}'+
  '.lg .lgr.lost b,.lg .lgr.lost .lgl{color:var(--rust)}.lg s{opacity:.75}'+
  '.lg .lgpb{font-style:normal;font-size:.62em;letter-spacing:.2em;padding:2px 8px;margin-left:8px;vertical-align:middle;color:#1a1408;background:linear-gradient(180deg,#ffe69a,#f5b73b);clip-path:polygon(5px 0,calc(100% - 5px) 0,100% 5px,100% calc(100% - 5px),calc(100% - 5px) 100%,5px 100%,0 calc(100% - 5px),0 5px)}'+
  '.lg .lgr.tot{margin-top:9px;padding:9px 12px;background:linear-gradient(90deg,rgba(255,192,74,.18),rgba(255,192,74,.04));border:1px solid rgba(255,192,74,.5);border-radius:3px;font-size:23px;letter-spacing:.16em;color:#ffc04a}'+
  '.lg .lgr.tot.lost{background:rgba(229,72,47,.08);border-color:rgba(229,72,47,.45)}'+
  '.lg .lgstrip{text-align:center;opacity:0;animation:lgin .28s ease-out both;animation-delay:calc(var(--i,0)*.09s)}'+
  '.lg .lgst{display:flex;gap:8px;margin-top:12px;opacity:0;animation:lgin .28s ease-out both;animation-delay:calc(var(--i,0)*.09s)}'+
  '.lg .lgti{flex:1;text-align:center;padding:7px 2px 6px;border:1px solid rgba(170,164,152,.28);border-radius:3px;background:rgba(0,0,0,.25)}'+
  '.lg .lgti b{display:block;font-size:20px;color:var(--bone);letter-spacing:.06em}.lg .lgti span{font-size:10.5px;letter-spacing:.2em;color:var(--ash)}'+
  '.lg .lgem{display:flex;gap:14px;justify-content:center;flex-wrap:wrap;margin-top:14px;opacity:0;animation:lgin .28s ease-out both;animation-delay:calc(var(--i,0)*.09s)}'+
  '.lg .lgeb{width:92px;text-align:center}.lg .lgeb svg{width:46px;height:46px;display:block;margin:0 auto 4px;filter:drop-shadow(0 2px 4px rgba(0,0,0,.6))}'+
  '.lg .lgeb i{display:block;font-style:normal;font-size:10.5px;letter-spacing:.14em;line-height:1.25;color:#ffe69a}'+
  '@keyframes lgin{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:none}}'+
  '.lg.lgdone .lgr,.lg.lgdone .lgstrip,.lg.lgdone .lgst,.lg.lgdone .lgem{animation:none;opacity:1}');
function buildTags(){
'@

SubRx @'
var VER='28.02';
'@ @'
var VER='28.03';
'@

$pat = "(?m)^  now:'v28\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.03: The run card is one ledger: raid score, credits, haul and a raid total. Check 28.03 fails on v28.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
