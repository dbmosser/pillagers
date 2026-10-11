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

# ARCADE: IDLE RETURN AND END RUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <button id="abandonbtn" style="padding:8px 22px;border-color:var(--rust);color:var(--rust)">Abandon run</button>
'@ @'
    <button id="abandonbtn" style="padding:8px 22px;border-color:var(--rust);color:var(--rust)">Abandon run</button>
    <!-- v23.39 (arcade16): the arcade pause box offers END RUN in place of Settings and Abandon run -->
    <button id="arcendbtn" style="padding:8px 22px;border-color:var(--rust);color:var(--rust);display:none">END RUN</button>
'@

SubRx @'
    if(_ab) _ab.style.display=(_inRaid&&!_bleed)?'':'none';
'@ @'
    if(_ab) _ab.style.display=(_inRaid&&!_bleed)?'':'none';
    // v23.39 (arcade16): an arcade raid offers END RUN in place of Settings and Abandon run; every other box is as before
    var _arcP=!!(_inRaid&&G.arcade&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on), _aeb=document.getElementById('arcendbtn'), _psb=document.getElementById('pausesetbtn');
    if(_arcP&&_ab) _ab.style.display='none';
    if(_aeb) _aeb.style.display=_arcP?'':'none';
    if(_psb) _psb.style.display=_arcP?'none':'';
'@

SubRx @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
'@ @'
document.getElementById('pausesetbtn').onclick=function(){ openSettings(); };
document.getElementById('arcendbtn').onclick=function(){ togglePauseBox(false); try{ arcadeRunEnd('menu'); }catch(_are){} };   // v23.39 (arcade16)
'@

SubRx @'
try{ sayWhenFree(String(nm).toUpperCase()+((hw==='killed')
'@ @'
try{ sayWhenFree((G.arcade&&hw==='abandoned')?'PLAYER 2 OUT':String(nm).toUpperCase()+((hw==='killed')
'@

SubRx @'
  g.player.arcSh=1;   // v23.30 (arcade9): the spawn shield
'@ @'
  g.player.arcSh=1;   // v23.30 (arcade9): the spawn shield
  ARCADE.ownAt=Date.now(); ARCADE.idleSaid=0;   // v23.39 (arcade16): a fresh drop starts the idle clock
'@

SubRx @'
  ARCADE.streak=null;   // v23.38 (arcade15): the kill streak starts again
'@ @'
  ARCADE.streak=null;   // v23.38 (arcade15): the kill streak starts again
  ARCADE.over=null; try{ arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card goes
'@

SubRx @'
  ARCADE.banner=null;   // v23.23 (arcade4)
  try{ ambienceOff(); }catch(_ao){}
'@ @'
  ARCADE.banner=null;   // v23.23 (arcade4)
  try{ ambienceOff(); }catch(_ao){}
  if(why==='idle'||why==='end'){   // v23.39 (arcade16): an idle out or a run end lets the party raid go (abandon, never a late ban) and stops the recorder
    try{ if(typeof NET==='object'&&NET&&NET.on) netUpEnd('abandon'); }catch(_ne){}
    try{ recStop(); }catch(_rs){}
  }
'@

SubRx @'
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
'@ @'
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
    if(m.t==='arcend'){   // v23.39 (arcade16): the host ended the run: tear down silently, back to the attract
      if(!ARCADE.on) return 'ignored';
      if(G&&G.arcade&&!G.netWasJoin) arcadeRaidStop('end');
      ARCADE.wantIn=0; ARCADE.late=0; ARCADE.idleSaid=0;
      try{ arcadeAttShow(); }catch(_ae){}
      return 'arcend';
    }
'@

SubRx @'
    if(m.t==='arcjoin'){ ARCADE.p2Busy=0; return arcadeJoinAsk(); }   // v23.25 (arcade6): player 2 pressed A
'@ @'
    if(m.t==='arcjoin'){ ARCADE.p2Busy=0; return arcadeJoinAsk(); }   // v23.25 (arcade6): player 2 pressed A
    if(m.t==='arcact'){ ARCADE.mateAt=Date.now(); return 'arcact'; }   // v23.39 (arcade16): player 2 is playing
    if(m.t==='arcleft'){ ARCADE.mateAt=0; if(arcadeBenched()) arcadeRunEnd('idle'); return 'arcleft'; }   // v23.39 (arcade16): player 2 idled out; nobody left playing ends the run
'@

SubRx @'
  try{ arcadeScFlush(Date.now()); }catch(_sf){}   // v23.29 (arcade8): a held score word, and the 2 s repeat
'@ @'
  try{ arcadeScFlush(Date.now()); }catch(_sf){}   // v23.29 (arcade8): a held score word, and the 2 s repeat
  try{ arcadeIdleTick(Date.now()); }catch(_ai){}   // v23.39 (arcade16): idle return and the run end
  if(ARCADE.role==='p2'){ var _an=Date.now(), _ao=arcadeOwnAt(); if(_ao>(+ARCADE.actSent||0)&&_an-(+ARCADE.actAt||0)>=ARCADE_IDLE.actMs){ ARCADE.actAt=_an; ARCADE.actSent=_ao; netSamePost({t:'arcact',pair:NET.pair}); } }   // v23.39 (arcade16)
'@

SubRx @'
  } else if(!ATT.tried){ try{ attStart(); }catch(_st){} }
  return true;
}
'@ @'
  } else if(!ATT.tried){ try{ attStart(); }catch(_st){} }
  try{ arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card
  return true;
}
'@

SubRx @'
  G.player.specOut=0;
  try{ attStop(); }catch(_as){}
  arcadeRespawn('bench');
'@ @'
  G.player.specOut=0;
  ARCADE.ownAt=Date.now(); ARCADE.idleSaid=0;   // v23.39 (arcade16)
  try{ attStop(); }catch(_as){}
  arcadeRespawn('bench');
'@

SubRx @'
// The containers as this window holds them, for the test page handle.
'@ @'
// v23.39, HIS ORDER (2026-10-11), build 16 of 20 (arcade16): IDLE RETURN AND END RUN. A party machine must go back to the demo on its
// own when the players walk away. Each window stamps its own activity (ARCADE.ownAt: keydown, mousedown, wheel, touch, a mousemove
// over 12 px, and its own pad through RUMBLE.usedAt), and player 2 tells the host (arcact, every 2 s while active). The run
// authority (the host, or player 2 after a host takeover) counts idle from the last activity of anyone playing: at 90 s STILL
// PLAYING?, from 120 s RUN ENDS IN 30 counting down, at 150 s the run ends. A player idle 150 s while the other plays is benched:
// player 1 stands out (specOut) under PLAYER 1: PRESS ANY BUTTON, and player 2 goes out of the raid (abandon, never a late ban,
// arcleft) back to its attract; the host says PLAYER 2 OUT. The run end (or END RUN in the pause box, which replaces Settings and
// Abandon run in an arcade raid) tells player 2 (arcend), tears the raid down with nothing settled and nothing saved, and shows
// the RUN OVER card on the attract for 12 s: the team score and a row per player. Only the arcade reaches any of it.
var ARCADE_IDLE={ask:90000,warn:120000,out:150000,overMs:12000,movePx:12,actMs:2000};
function arcadeStamp(e){
  if(!ARCADE.on||!e) return;
  if(String(e.type||'')==='mousemove'){
    var x=+e.clientX||0, y=+e.clientY||0, m=ARCADE.mvAt;
    if(!m||Math.hypot(x-m.x,y-m.y)<=ARCADE_IDLE.movePx){ if(!m) ARCADE.mvAt={x:x,y:y}; return; }
    ARCADE.mvAt={x:x,y:y};
  }
  ARCADE.ownAt=Date.now();
}
try{ ['keydown','mousedown','wheel','touchstart','mousemove'].forEach(function(t){ window.addEventListener(t,arcadeStamp,{capture:true,passive:true}); }); }catch(_ast){}
// The last activity of this window: its own input, or its own pad (RUMBLE.usedAt is on the performance clock).
function arcadeOwnAt(){
  var a=+ARCADE.ownAt||0, u=+RUMBLE.usedAt, pn=(typeof performance!=='undefined')?performance.now():Date.now(), pd;
  if(isFinite(u)&&u>0&&u<=pn){ pd=Date.now()-(pn-u); if(pd>a) a=pd; }
  return a;
}
// A teammate is up in this raid.
function arcadeMateLive(){
  var i, u;
  if(typeof NET!=='object'||!NET||!NET.on||!Array.isArray(NET.up)) return false;
  for(i=0;i<NET.up.length;i++){ u=NET.up[i]; if(u&&u.seat!==NET.seat) return true; }
  return false;
}
// Run every half second. Returns what it did: '', ask, warn, bench, out or end.
function arcadeIdleTick(now){
  if(!ARCADE.on||!G||!G.arcade||G.over||G.sim) return '';
  now=+now||Date.now();
  var own=now-arcadeOwnAt(), auth=(ARCADE.role==='host')||!!G.netWasJoin, live=auth&&ARCADE.role==='host'&&arcadeMateLive(),
      mate=live?now-(+ARCADE.mateAt||0):Infinity, bench=!!(G.player&&G.player.specOut), w, end, n;
  if(!auth){ w=own; end=false; }                                       // player 2: its own idle takes it out
  else if(live&&!bench&&mate<ARCADE_IDLE.out){ w=own; end=false; }    // the other is playing: his own idle benches him
  else { w=Math.min(own,mate); end=true; }                             // nobody playing: the run ends
  if(w>=ARCADE_IDLE.out){
    ARCADE.idleSaid=0;
    if(!auth) return arcadeP2Out('idle')?'out':'';
    if(!end){ G.player.specOut=1; G.player.vx=0; G.player.vy=0; keys={}; try{ arcadeAttShow(); }catch(_ab){} return 'bench'; }
    return arcadeRunEnd('idle')?'end':'';
  }
  if(w<ARCADE_IDLE.ask){ ARCADE.idleSaid=0; return ''; }
  if(w<ARCADE_IDLE.warn){
    if(ARCADE.idleSaid!=='ask'){ ARCADE.idleSaid='ask'; try{ say('STILL PLAYING?','warn',{sub:'PRESS ANY BUTTON',key:'arcidle'}); }catch(_s1){} }
    return 'ask';
  }
  n=Math.max(1,Math.ceil((ARCADE_IDLE.out-w)/1000));
  if(ARCADE.idleSaid!==n){ ARCADE.idleSaid=n; try{ say((end?'RUN ENDS IN ':'OUT IN ')+n,'warn',{sub:'PRESS ANY BUTTON',key:'arcidle'}); }catch(_s2){} }
  return 'warn';
}
// The run end, from idle or END RUN. Player 2 that is not the run authority goes out instead.
function arcadeRunEnd(why){
  if(!ARCADE.on||!G||!G.arcade) return false;
  if(ARCADE.role!=='host'&&!G.netWasJoin) return arcadeP2Out(why);
  var host=(ARCADE.role==='host'), me={s:Math.max(0,ARCADE.mine|0),k:ARCADE.kills|0,x:ARCADE.ext|0,d:ARCADE.deaths|0},
      mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
  if(host) netSamePost({t:'arcend',pair:NET.pair});
  arcadeRaidStop('end');
  ARCADE.wantIn=0; ARCADE.idleSaid=0;
  try{ arcadeAttShow(); }catch(_as){}
  return true;
}
// Player 2 goes out of the arcade raid, back to its attract.
function arcadeP2Out(why){
  if(!ARCADE.on||ARCADE.role!=='p2'||!G||!G.arcade) return false;
  netSamePost({t:'arcleft',pair:NET.pair});
  arcadeRaidStop('idle');
  ARCADE.wantIn=0; ARCADE.late=0; ARCADE.idleSaid=0;
  try{ arcadeAttShow(); }catch(_as){}
  return true;
}
// The RUN OVER card on the attract overlay.
function arcadeOverEl(){
  var d=attEl(), c=d.querySelector('.arcover'), st;
  if(c) return c;
  st=document.createElement('style');
  st.textContent='#attract .arcover{position:absolute;left:0;right:0;top:24%;padding:.45em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.8) 18%,rgba(0,0,0,.8) 82%,transparent);text-align:center;'+
    'font:800 clamp(16px,1.9vw,46px) "Rubik",system-ui,sans-serif;letter-spacing:.08em;color:#f2e6c8;text-shadow:0 3px 0 #000,0 0 18px rgba(0,0,0,.9)}'+
    '#attract .arcover .aoh{font-size:2.4em;color:#ff5a3a}#attract .arcover .aos{font-size:1.5em;color:#ffc04a;margin:.12em 0 .4em}#attract .arcover .aor{margin:.14em 0;opacity:.94}';
  document.head.appendChild(st);
  c=document.createElement('div'); c.className='arcover'; c.style.display='none'; d.appendChild(c);
  return c;
}
function arcadeOverRow(nm,r){
  if(!r) return '';
  var t=nm+'  '+arcadeN(r.s)+'  \u00b7  '+(r.k|0)+' KILLS  \u00b7  '+(r.x|0)+' EXT';
  if(r.d>=0) t+='  \u00b7  '+(r.d|0)+' DEATHS';
  return t;
}
function arcadeOverSync(){
  var o=ARCADE.over, on=!!(ARCADE.on&&o&&Date.now()-(+o.at||0)<ARCADE_IDLE.overMs&&!(G&&G.arcade&&!arcadeBenched())), c, i, ln, el;
  if(!on&&!document.querySelector('#attract .arcover')) return false;
  c=arcadeOverEl();
  if(on&&c.getAttribute('data-at')!==String(o.at)){
    c.textContent=''; c.setAttribute('data-at',String(o.at));
    ln=[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]];
    for(i=0;i<ln.length;i++){ if(!ln[i][1]) continue; el=document.createElement('div'); el.className=ln[i][0]; el.textContent=ln[i][1]; c.appendChild(el); }
  }
  c.style.display=on?'block':'none';
  return on;
}
// The containers as this window holds them, for the test page handle.
'@

SubRx @'
var VER='23.38';
'@ @'
var VER='23.39';
'@

$pat = "(?m)^  now:'v23\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.39: In the arcade nobody playing for 150 seconds ends the run back to the demo with a RUN OVER card, a player who walks off is benched, and the pause box offers END RUN. Check 23.39 fails on v23.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
