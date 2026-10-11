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

# ARCADE: THE ATTRACT LOOP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  arcadeAttShow();
  return true;
}
// The arcade words on the pair channel
'@ @'
  arcadeAttStart();   // v23.40 (arcade17): the attract loop from the top
  return true;
}
// The arcade words on the pair channel
'@

SubRx @'
ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=
'@ @'
ARCADE.scSeen=Date.now(); ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=
'@

SubRx @'
  ATT.on=true; if(d.style.display!=='block') d.style.display='block';
'@ @'
  if(!ATT.on||!ARCADE.att) ARCADE.att={t:0,at:Date.now(),ph:'',ov:0};   // v23.40 (arcade17): the loop starts again each time the attract comes up
  ATT.on=true; if(d.style.display!=='block') d.style.display='block';
'@

SubRx @'
  try{ arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card
  return true;
'@ @'
  var _ovOn=false; try{ _ovOn=arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card
  try{ arcadeAttLoop(_ovOn); }catch(_al){}   // v23.40 (arcade17): VIDEO, BOARD, HOW TO PLAY, the banner and the team strip
  return true;
'@

SubRx @'
  try{ if(ATT.on) attStop(); ATT.last=Date.now(); }catch(_at){}
'@ @'
  try{ if(ATT.on) attStop(); ATT.last=Date.now(); }catch(_at){}
  try{ arcadeAttUndress(); }catch(_au){}   // v23.40 (arcade17): the title attract has none of the arcade pages
'@

SubRx @'
// The arcade attract: the attract overlay with the clip when there is one, PRESS ANY BUTTON (host) or PLAYER 2: PRESS A, up
'@ @'
// v23.40, HIS ORDER (2026-10-11), build 17 of 20 (arcade17): THE ATTRACT LOOP. The arcade attract was the clip (or a black screen)
// under PRESS ANY BUTTON. It now cycles like a cabinet: the clip for 40 s, TONIGHTS BEST for 10 s (the party board rows when the
// board exists, the last run and the best ever), then HOW TO PLAY for 10 s (keyboard and controller). With no clip it cycles the
// board and HOW TO PLAY only. After a run the RUN OVER card shows first and the loop goes on from the board. HAPPY HALLOWEEN sits
// under PRESS ANY BUTTON, and while a run is live and this window is out (a benched player 1, or player 2 hearing the host
// score word) a strip reads JOIN YOUR TEAM and the team score; LINKING while player 2 waits to get in. ARCADE.att.t is the loop
// clock in seconds. Only the arcade reaches any of it, and leaving the arcade takes it all off the title attract.
var ARCADE_ATT={video:40,board:10,howto:10,live:5000};
var ARCADE_HOW=[['MOVE','WASD','L STICK'],['AIM','MOUSE','R STICK'],['FIRE','LEFT CLICK','RT'],['ROLL','SPACE','A'],['RELOAD','R','X'],['EXTRACT','HOLD E IN A TEAL RING','HOLD X IN A TEAL RING']];
function arcadeAttPhase(t,clip){
  var A=ARCADE_ATT, c;
  t=Math.max(0,+t||0);
  if(clip){ c=t%(A.video+A.board+A.howto); return (c<A.video)?'video':((c<A.video+A.board)?'board':'howto'); }
  c=t%(A.board+A.howto); return (c<A.board)?'board':'howto';
}
function arcadeAttStart(){ ARCADE.att=null; return arcadeAttShow(); }
function arcadeAttEl(cls){
  var d=attEl(), e=d.querySelector('.'+cls), st;
  if(e) return e;
  if(!document.getElementById('arcattcss')){
    st=document.createElement('style'); st.id='arcattcss';
    st.textContent='#attract .arcpage{position:absolute;left:50%;top:24%;transform:translateX(-50%);min-width:44%;max-width:92%;box-sizing:border-box;padding:.55em 1.6em .7em;background:rgba(0,0,0,.74);border:2px solid rgba(255,192,74,.5);border-radius:6px;'+
      'font:800 clamp(12px,1.15vw,30px) "Rubik",system-ui,sans-serif;letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center}'+
      '#attract .arcpage .aph{font-size:1.8em;color:#ffc04a;margin-bottom:.3em}#attract .arcpage .apr{display:flex;justify-content:space-between;gap:2em;line-height:1.3}'+
      '#attract .arcpage .apr.hl{color:#7fe3d4}#attract .arcpage .apn{line-height:1.6;opacity:.8}#attract .arcpage .apb{color:#ff8a1f;margin-top:.35em}'+
      '#attract .arcpage table{margin:0 auto;border-collapse:collapse}#attract .arcpage td,#attract .arcpage th{padding:.2em .9em;text-align:left}#attract .arcpage th{color:#9a8f78;font-size:.8em}#attract .arcpage .apk{color:#ffc04a}'+
      '#attract .arcboo{position:absolute;left:0;right:0;bottom:6%;text-align:center;font:800 clamp(15px,1.7vw,40px) "Rubik",system-ui,sans-serif;letter-spacing:.32em;color:#ff8a1f;text-shadow:0 2px 0 #000,0 0 18px rgba(150,60,255,.85)}'+
      '#attract .arcstrip{position:absolute;left:0;right:0;bottom:28.5%;padding:.2em 0;text-align:center;background:linear-gradient(90deg,transparent,rgba(0,0,0,.66) 26%,rgba(0,0,0,.66) 74%,transparent);'+
      'font:800 clamp(15px,1.6vw,38px) "Rubik",system-ui,sans-serif;letter-spacing:.1em;color:#7fe3d4;text-shadow:0 2px 0 #000}';
    document.head.appendChild(st);
  }
  e=document.createElement('div'); e.className=cls; e.style.display='none'; d.appendChild(e);
  return e;
}
function arcadeAttLine(pg,cls,a,b){
  var e=document.createElement('div'), s;
  e.className=cls;
  if(b===undefined) e.textContent=a;
  else { s=document.createElement('span'); s.textContent=a; e.appendChild(s); s=document.createElement('span'); s.textContent=b; e.appendChild(s); }
  pg.appendChild(e); return e;
}
function arcadeAttBoard(pg){
  var rows=[], best=0, id=(ARCADE.run&&ARCADE.run.id)||'', i, r, o=ARCADE.over;
  try{ if(typeof arcadeBoardTonight==='function') rows=arcadeBoardTonight()||[]; }catch(_bt){ rows=[]; }
  try{ if(typeof arcadeBoardBest==='function') best=+arcadeBoardBest()||0; }catch(_bb){ best=0; }
  arcadeAttLine(pg,'aph','TONIGHT\u2019S BEST');
  if(!rows.length) arcadeAttLine(pg,'apn','NO SCORES YET');
  for(i=0;i<rows.length&&i<10;i++){ r=rows[i]||{}; arcadeAttLine(pg,'apr'+((id&&r.run===id)?' hl':''),(i+1)+'.  '+String(r.i||'???').slice(0,3).toUpperCase(),arcadeN(r.s)); }
  if(o&&(+o.team||0)>0) arcadeAttLine(pg,'apb','LAST RUN '+arcadeN(o.team));
  if(best>0) arcadeAttLine(pg,'apb','BEST EVER '+arcadeN(best));
}
function arcadeAttHow(pg){
  var t=document.createElement('table'), tr, c, i, j, h=['','KEYBOARD','CONTROLLER'], rw;
  arcadeAttLine(pg,'aph','HOW TO PLAY');
  tr=t.insertRow();
  for(j=0;j<h.length;j++){ c=document.createElement('th'); c.textContent=h[j]; tr.appendChild(c); }
  for(i=0;i<ARCADE_HOW.length;i++){
    rw=ARCADE_HOW[i]; tr=t.insertRow();
    c=tr.insertCell(); c.className='apk'; c.textContent=rw[0];
    c=tr.insertCell(); c.textContent=rw[1];
    c=tr.insertCell(); c.textContent=padB(rw[2]);
  }
  pg.appendChild(t);
}
// The team strip: a run is live and this window is out of it.
function arcadeAttStrip(){
  var p2=(ARCADE.role==='p2'), up=!(G&&G.arcade), live=arcadeBenched()||(p2&&up&&Date.now()-(+ARCADE.scSeen||0)<ARCADE_ATT.live), s='';
  if(p2&&up&&ARCADE.wantIn) s='LINKING\u2026';
  else if(live) s='JOIN YOUR TEAM';
  if(live) s+='  \u00b7  TEAM SCORE '+arcadeN(arcadeTeam());
  return s;
}
// One step of the loop, from arcadeAttShow. ovOn: the RUN OVER card is up, so the pages wait and the loop goes on from the board.
function arcadeAttLoop(ovOn){
  var now=Date.now(), a=ARCADE.att, clip=!!ATT.src, d=attEl(), v=d.querySelector('video'), pg=arcadeAttEl('arcpage'), bo=arcadeAttEl('arcboo'), sp=arcadeAttEl('arcstrip'), ph, tx;
  if(!a) a=ARCADE.att={t:0,at:now,ph:'',ov:0};
  a.t=Math.max(0,+a.t||0)+Math.min(1,Math.max(0,(now-(+a.at||now))/1000)); a.at=now;
  if(ovOn){ a.ov=1; ph='over'; }
  else { if(a.ov){ a.ov=0; a.t=clip?ARCADE_ATT.video:0; } ph=arcadeAttPhase(a.t,clip); }
  if(ph!==a.ph){
    a.ph=ph; pg.textContent='';
    if(ph==='board') arcadeAttBoard(pg); else if(ph==='howto') arcadeAttHow(pg);
    pg.setAttribute('data-ph',ph);
  }
  pg.style.display=(ph==='board'||ph==='howto')?'block':'none';
  if(v) v.style.opacity=(ph==='board'||ph==='howto')?'.22':'';
  if(bo.textContent!=='HAPPY HALLOWEEN') bo.textContent='HAPPY HALLOWEEN';
  bo.style.display='block';
  tx=arcadeAttStrip();
  if(sp.textContent!==tx) sp.textContent=tx;
  sp.style.display=tx?'block':'none';
  return ph;
}
// Leaving the arcade: the title attract gets its own clip back with none of the arcade pages on it.
function arcadeAttUndress(){
  var d=ATT.el, i, e, cl=['arcpage','arcboo','arcstrip','arcover'], v;
  ARCADE.att=null;
  if(!d) return false;
  for(i=0;i<cl.length;i++){ e=d.querySelector('.'+cl[i]); if(e) e.style.display='none'; }
  v=d.querySelector('video'); if(v) v.style.opacity='';
  return true;
}
// The arcade attract: the attract overlay with the clip when there is one, PRESS ANY BUTTON (host) or PLAYER 2: PRESS A, up
'@

SubRx @'
var VER='23.39';
'@ @'
var VER='23.40';
'@

$pat = "(?m)^  now:'v23\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.40: In the arcade the attract now cycles the clip, the board and HOW TO PLAY, with HAPPY HALLOWEEN and a JOIN YOUR TEAM strip while a run is live. Check 23.40 fails on v23.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
