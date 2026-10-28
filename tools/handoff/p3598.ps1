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

# RUN OVER CROWN AND MOMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeBmNew(){ return {st:0,hl:0,ls:0,cur:0,lid:''}; }
'@ @'
// v28.xx (cw-cx-overmoments), his #196 yes (2026-10-28): crown, closest call and most damage. No saved state or seeded draws.
function arcadeBmNew(){ return {st:0,hl:0,ls:0,cc:0,dm:0,cur:0,lid:''}; }
function arcadeBmAuth(){ return ARCADE.role==='host'||!!(G&&G.netWasJoin); }
// v28.xx (cw-cx-overmoments): return the original blow unchanged; record health actually removed once on the body authority.
function arcadeBmDamage(e,n,seat){
  var b, v;
  if(!G||G.sim||!G.arcade||!ARCADE.on||!arcadeBmAuth()||seat<0||!e||e.finished||e.merc||e.friendlyPC||!(e.hp>0)||!(n>0)) return n;
  v=Math.min(e.hp,n);
  if((seat|0)>0) b=ARCADE.mateBm||(ARCADE.mateBm=arcadeBmNew());
  else b=ARCADE.bm||(ARCADE.bm=arcadeBmNew());
  b.dm=(+b.dm||0)+v; ARCADE.scDirty=1;
  return n;
}
function arcadeBmHealth(p){
  var b;
  if(!G||G.sim||!G.arcade||!ARCADE.on||!p||p.downed||p.dying||p.specOut||!(p.hp>0)) return;
  b=ARCADE.bm||(ARCADE.bm=arcadeBmNew());
  if(!b.cc||p.hp<b.cc){ b.cc=p.hp; ARCADE.scDirty=1; }
}
// v28.xx (cw-cx-overmoments): the final host snapshot survives arcend beating the last score heartbeat.
function arcadeBmEndTake(m){
  var out={}, k, r;
  if(!m||typeof m!=='object') return null;
  for(k in m) if(['st','hl','ls','cc','dm','cr'].indexOf(k)>=0){
    r=m[k]; if(!r||!isFinite(r.v)||r.v<0) continue;
    out[k]={v:+r.v,who:/^(P1|P2|p1|p2|p1 \+ p2)$/.test(r.who)?r.who:''};
  }
  return out;
}
'@

SubRx @'
function arcadeBmWire(){ var b=ARCADE.bm||arcadeBmNew(); return [b.st|0,b.hl|0,b.ls|0]; }
'@ @'
function arcadeBmWire(){ var b=ARCADE.bm||arcadeBmNew(); return [b.st|0,b.hl|0,b.ls|0,+b.cc||0,+b.dm||0]; }
'@

SubRx @'
function arcadeBmTake(w){ if(!Array.isArray(w)) return null; return {st:Math.max(0,w[0]|0),hl:Math.max(0,w[1]|0),ls:Math.max(0,w[2]|0)}; }
'@ @'
function arcadeBmTake(w){ if(!Array.isArray(w)) return null; return {st:Math.max(0,w[0]|0),hl:Math.max(0,w[1]|0),ls:Math.max(0,w[2]|0),cc:isFinite(w[3])?Math.max(0,+w[3]):0,dm:isFinite(w[4])?Math.max(0,+w[4]):0}; }
'@

SubRx @'
  try{ m.bm=arcadeBmWire(); }catch(_bmw){}   // v23.xx (his answer 20): the best moments go with the score
'@ @'
  try{ m.bm=arcadeBmWire(); }catch(_bmw){}   // v23.xx (his answer 20): the best moments go with the score
  if(arcadeBmAuth()) m.md=+(ARCADE.mateBm&&ARCADE.mateBm.dm)||0; // v28.xx (cw-cx-overmoments): the host measured player 2 damage.
'@

SubRx @'
  try{ if(m.bm) ARCADE.mateBm=arcadeBmTake(m.bm); }catch(_bmt){}   // v23.xx (his answer 20)
'@ @'
  // v28.xx (cw-cx-overmoments): a peer reports its health, but only the authority measures damage applied to bodies.
  try{
    if(m.bm){
      var _mb=arcadeBmTake(m.bm), _md=+(ARCADE.mateBm&&ARCADE.mateBm.dm)||0;
      if(_mb){ if(arcadeBmAuth()) _mb.dm=_md; ARCADE.mateBm=_mb; }
    }
    if(!arcadeBmAuth()&&isFinite(m.md)&&m.md>=0){ (ARCADE.bm||(ARCADE.bm=arcadeBmNew())).dm=+m.md; }
  }catch(_bmt){}
'@

SubRx @'
  return out;
}
function arcadeBmDraw(c,o,counting){
'@ @'
  // v28.xx (cw-cx-overmoments): low positive health wins closest call; ties share credit, with stable seat names in either window.
  ['cc','dm'].forEach(function(key){
    a=+me[key]||0; b=mt?(+mt[key]||0):0;
    var remote=key==='cc'?(b>0&&(!a||b<a)):(b>a), v=remote?b:a;
    out[key]={v:v,who:two?(a>0&&a===b?'p1 + p2':(remote?(host?'p2':'p1'):(host?'p1':'p2'))):''};
  });
  if(two){
    a=Math.max(0,ARCADE.mine|0); b=Math.max(0,ARCADE.mate|0);
    out.cr={v:Math.max(a,b),who:a===b?'p1 + p2':(a>b?(host?'p1':'p2'):(host?'p2':'p1'))};
  }
  return out;
}
function arcadeBmDraw(c,o,counting){
'@

SubRx @'
    if(m.st&&m.st.v>=2) rows.push(['BEST STREAK',m.st.v+' KILLS',m.st.who]);
'@ @'
    // v28.xx (cw-cx-overmoments): three short two-player callouts ahead of the existing moments.
    if(!ARCADE.solo&&m.cr){
      rows.push(['crown',arcadeCr(m.cr.v),m.cr.who]);
      if(m.cc&&m.cc.v>0) rows.push(['closest call',Math.max(1,Math.ceil(m.cc.v))+' hp',m.cc.who]);
      if(m.dm&&m.dm.v>0) rows.push(['most damage',Math.max(1,Math.round(m.dm.v)).toLocaleString('en-US'),m.dm.who]);
    }
    if(m.st&&m.st.v>=2) rows.push(['BEST STREAK',m.st.v+' KILLS',m.st.who]);
'@

SubRx @'
    el.style.cssText='display:none;justify-content:center;gap:2.4em;margin:.55em 0 .1em;';
'@ @'
    el.style.cssText='display:none;grid-template-columns:repeat(3,minmax(0,1fr));width:100%;gap:16px 24px;margin:.55em 0 .1em;';
'@

SubRx @'
      t=document.createElement('div'); t.className='aobmt'; t.style.cssText='text-align:center;line-height:1.05';
'@ @'
      t=document.createElement('div'); t.className='aobmt'+(rows[i][0]==='crown'?' aocrown':''); t.style.cssText='text-align:center;line-height:1.05;min-width:0';
'@

SubRx @'
  el.style.display=counting?'none':'flex';
'@ @'
  el.style.display=counting?'none':'grid';
'@

SubRx @'
body #attract .arcover .aobmt > div:last-child{ font-size:calc(var(--fs-body) * var(--attz,1)) !important; line-height:1.4; color:var(--acc) !important; }
'@ @'
body #attract .arcover .aobmt > div:last-child{ font-size:calc(var(--fs-body) * var(--attz,1)) !important; line-height:1.4; color:var(--acc) !important; }
/* v28.xx (cw-cx-overmoments): six moments in two rows of three; only the crown figure uses the accent. */
body #attract .arcover .aobmt > div:last-child{color:var(--tx-1) !important;}
body #attract .arcover .aocrown > div:last-child{color:var(--acc) !important;}
'@

SubRx @'
  p.hp-=amt;
'@ @'
  p.hp-=amt;
  if(amt>0) arcadeBmHealth(p); // v28.xx (cw-cx-overmoments): a fatal or downing blow is never a survived health value.
'@

SubRx @'
      e.hp-=dm; e.hitT=.2;
      if(!seat)
'@ @'
      e.hp-=arcadeBmDamage(e,dm,seat); e.hitT=.2;
      if(!seat)
'@

SubRx @'
        e.hp-=BRL_FIRE_EN*dt;
'@ @'
        e.hp-=arcadeBmDamage(e,BRL_FIRE_EN*dt,f.by);
'@

SubRx @'
      e.hp-=dm; e.hitT=.2;
      if(s===0)
'@ @'
      e.hp-=arcadeBmDamage(e,dm,s); e.hitT=.2;
      if(s===0)
'@

SubRx @'
    e.hp-=dm; e.hitT=.2;
    if(s===0)
'@ @'
    e.hp-=arcadeBmDamage(e,dm,s); e.hitT=.2;
    if(s===0)
'@

SubRx @'
      best.hp-=a; best.hitT=.16;
'@ @'
      best.hp-=arcadeBmDamage(best,a,s); best.hitT=.16;
'@

SubRx @'
e.hp-=Q.en*dt*(ELEM_MACH[e.kind]?Q.mach:1);
'@ @'
e.hp-=arcadeBmDamage(e,Q.en*dt*(ELEM_MACH[e.kind]?Q.mach:1),f.by);
'@

SubRx @'
else e.hp-=_fdm;
'@ @'
else e.hp-=arcadeBmDamage(e,_fdm,_fMine?0:-1);
'@

SubRx @'
else { e.hp=0; e.byPlayer=true; e.pHitT=.3; e.pHitSeat=0; }
'@ @'
else { arcadeBmDamage(e,e.hp,0); e.hp=0; e.byPlayer=true; e.pHitT=.3; e.pHitSeat=0; }
'@

SubRx @'
else _me.hp-=_mdm;
'@ @'
else _me.hp-=arcadeBmDamage(_me,_mdm,0);
'@

SubRx @'
  best.hp-=a; best.hitT=.16; best.pHitT=.3; best.pHitSeat=seat|0;
'@ @'
  best.hp-=arcadeBmDamage(best,a,seat); best.hitT=.16; best.pHitT=.3; best.pHitSeat=seat|0;
'@

SubRx @'
e.hp-=(e.burnDps||0)*t;
'@ @'
e.hp-=arcadeBmDamage(e,(e.burnDps||0)*t,e.burnBy|0);
'@

SubRx @'
else en.hp-=affixSoak(en,edmg);
'@ @'
else en.hp-=arcadeBmDamage(en,affixSoak(en,edmg),0);
'@

SubRx @'
  e.hp-=(m.sk?affixSoak(e,d):d);
'@ @'
  e.hp-=arcadeBmDamage(e,(m.sk?affixSoak(e,d):d),m.nc?-1:s);
'@

SubRx @'
} else e.hp-=dm;   // v27.19 (coop6):
'@ @'
} else e.hp-=arcadeBmDamage(e,dm,0);   // v27.19 (coop6):
'@

SubRx @'
  var run0=ARCADE.run, k0=ARCADE.kills|0;   // v23.29 (arcade8): the same run, so the team score carries on
'@ @'
  var run0=ARCADE.run, k0=ARCADE.kills|0;   // v23.29 (arcade8): the same run, so the team score carries on
  var _mom0=ARCADE.bm, _mateMom0=ARCADE.mateBm; // v28.xx (cw-cx-overmoments): player 2 joining continues this run.
'@

SubRx @'
  if(run0) ARCADE.run=run0; ARCADE.kills=k0;
'@ @'
  if(run0){ ARCADE.run=run0; ARCADE.bm=_mom0; ARCADE.mateBm=_mateMom0; } ARCADE.kills=k0;
'@

SubRx @'

      mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@ @'

      mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@

SubRx @'

  mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@ @'

  mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@

SubRx @'
ARCADE.endSend={id:id,at:now,last:now,x2:x2,ko:ko,hf:hf};
'@ @'
ARCADE.endSend={id:id,at:now,last:now,x2:x2,ko:ko,hf:hf,bm:ARCADE.over&&ARCADE.over.bm};
'@

SubRx @'
var _am={t:'arcend',pair:NET.pair,run:id,x2:x2};
'@ @'
var _am={t:'arcend',pair:NET.pair,run:id,x2:x2,bm:ARCADE.endSend.bm};
'@

SubRx @'
var _am={t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0};
'@ @'
var _am={t:'arcend',pair:NET.pair,run:e.id,x2:e.x2?1:0,bm:e.bm};
'@

SubRx @'
  try{ ARCADE.over.bm=arcadeBmFinal(); }catch(_bmf){}
  return ARCADE.over;
'@ @'
  try{ ARCADE.over.bm=arcadeBmEndTake(m&&m.bm)||arcadeBmFinal(); }catch(_bmf){}
  return ARCADE.over;
'@

SubRx @'
var VER='35.97';
'@ @'
var VER='35.98';
'@

$pat = "(?m)^  now:'v35\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.98: Two player run over shows crown, closest call and most damage alongside the existing moments. Check 35.98 fails on v35.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
