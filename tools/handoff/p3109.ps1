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

# a raid opens on the sector map and the clock waits for a click (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(G&&G.rise) G.rise=null;
'@ @'
if(G&&G.rise&&!G.mapFirst) G.rise=null;
'@

SubRx @'
function startRaid(){
'@ @'
// cw-mapfirst, HIS NOTE (2026-10-18, in a raid, build 30.57): "raid should show map at the beginning of the game and player has to click to proceed
// into the actual raid, clock/game doesn't start until map is dismissed, that way player can see where relevant hotspots, etc are". A raid now opens
// on the sector map (G.mapOpen, drawMapOverlay) over a FROZEN world. G.mapFirst holds G.paused up through syncPause, the one freeze there is (no second
// clock), so the raid clock, the bodies, the weather, the bleed and superhot do not move and the sound of a raid does not start; netPauseLive is false
// while it is up, so a shared raid cannot run the world behind it either. A click, E, Space, Enter, Esc, Tab or M on a keyboard, or A on a pad, starts
// it, and the click is never a shot (the mouse handler returns before the trigger). The press must come 0.25 s of loop time into the raid, so the
// click or key that launched the raid cannot also dismiss it, and a key repeat never counts. Shutting the map any other way (B, D-up) counts as the
// press and the map stays up until it is answered. With a teammate the clock starts when every window up top has pressed: each state word carries
// mf (0 running, 1 on the map, 2 pressed), a window that has pressed shows "waiting for p2" and follows any teammate who is already running. A seat
// that said it came up and never sends a word is waited for peerWait seconds at most, a shared raid lets go after max seconds, and the party arcade
// (nobody may be at the machine) lets go by itself after auto seconds. MAPFIRST.skip is 0 in the game; the test fixture sets it to 1 so every older
// check that deploys a raid still gets a live one, and the check for this screen turns it back on itself.
var MAPFIRST={skip:0,hold:0.25,peerWait:4,auto:20,max:60};
function mapFirstOn(){ return !!(typeof G!=='undefined'&&G&&G.mapFirst&&!G.over&&!G.sim); }
function mapFirstWord(){ return mapFirstOn()?(G.mapFirstMe?2:1):0; }
function mapFirstBegin(){
  var g=G;
  if(MAPFIRST.skip||!g||g.sim||g.over) return false;
  g.mapFirst=1; g.mapFirstMe=0; g.mapFirstT=0; g.mapFirstW=0; g.mapFirstWhy='';
  g.mapOpen=true; g.mapCur=null; g.bagOpen=false; g.drag=null;
  mouse.down=false;
  syncPause();
  return true;
}
function mapFirstEnd(why){
  var g=G;
  if(!g||!g.mapFirst) return false;
  g.mapFirst=0; g.mapFirstMe=0; g.mapFirstWhy=String(why||''); g.mapOpen=false; g.mapCur=null;
  mouse.down=false;
  syncPause();
  return true;
}
// Where the other windows up top stand: onMap (still deciding), ready (pressed), run (the clock is theirs already), unseen (said they came up, no word yet).
function mapFirstPeers(){
  var r={shown:0,onMap:0,ready:0,run:0,unseen:0,who:[]}, seen={}, i, g, q, s;
  if(typeof NET!=='object'||!NET||!NET.on||!NET.upSeed||!G||!Array.isArray(NET.up)) return r;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i];
    if(!g||!netUpShown(g)||netUpGone(g)) continue;
    seen[g.seat]=1; r.shown++;
    if(g.mf===1){ r.onMap++; r.who.push(g.seat); }
    else if(g.mf===2) r.ready++;
    else r.run++;
  }
  if(NET.role==='host'){
    for(i=0;i<NET.peers.length;i++){
      q=NET.peers[i]; s=q.seat;
      if(q.state==='in'&&!seen[s]&&NET.upOut&&NET.upOut[s]===0){ r.unseen++; r.who.push(s); }
    }
  } else if(NET.role==='join'){
    q=netPeerOfSeat(0);
    if(q&&!seen[0]&&!(NET.upOut&&NET.upOut[0]===(NET.upSeed>>>0))){ r.unseen++; r.who.push(0); }
  }
  return r;
}
function mapFirstWho(seats){
  var out=[], i, s, arc=!!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&!ARCADE.solo);
  for(i=0;i<seats.length&&out.length<2;i++){ s=seats[i]; out.push((arc&&(s===0||s===1))?('p'+(s+1)):String(netSeatName(s)||'your team').toLowerCase()); }
  return out.length?out.join(' and '):'your team';
}
// The press. False when it is too early (the click that launched the raid), already given, or there is no map first screen.
function mapFirstGo(how){
  var g=G;
  if(!mapFirstOn()||g.mapFirstMe) return false;
  if((+g.mapFirstT||0)<MAPFIRST.hold) return false;
  g.mapFirstMe=1; g.mapFirstHow=String(how||'');
  try{ sndUi('ok'); }catch(_ms){}
  mapFirstStep(0);
  return true;
}
// A benched arcade host (player 2 started a fresh raid) has nothing to press: it must not hold player 2 on the map.
function mapFirstBench(){
  var g=G;
  if(!mapFirstOn()) return false;
  g.mapFirstMe=1;
  return true;
}
// Every raid frame while it is up (the loop, with the clamped frame time). Returns true when it let go.
function mapFirstStep(dt){
  var g=G, r;
  if(!g||!g.mapFirst) return false;
  if(g.over||g.sim||state!=='raid') return mapFirstEnd('over');
  if(!(dt>0)) dt=0;
  g.mapFirstT=(+g.mapFirstT||0)+dt;
  g.bagOpen=false;
  if(!g.mapOpen){ g.mapOpen=true; g.mapCur=null; mapFirstGo('map'); if(!g.mapFirst) return true; }   // the map was shut by B, D-up or Tab: that is the press, or nothing yet
  r=mapFirstPeers();
  if(g.mapFirstMe){
    if(r.run>0||(r.onMap===0&&r.unseen===0)) return mapFirstEnd('ready');
    if(r.onMap===0){ g.mapFirstW=(+g.mapFirstW||0)+dt; if(g.mapFirstW>=MAPFIRST.peerWait) return mapFirstEnd('no word'); }
  } else if(r.run>0) return mapFirstEnd('follow');
  if(g.arcade&&PARTY&&g.mapFirstT>=MAPFIRST.auto) return mapFirstEnd('auto');
  if(g.mapFirstT>=MAPFIRST.max&&(r.shown>0||r.unseen>0)) return mapFirstEnd('max');
  return false;
}
// A key press while it is up (raidKey, after the pause box rule). Every key is held back; the answers start the raid. P still pauses.
function mapFirstKey(code,repeat,ev){
  if(!mapFirstOn()||pauseOpen||tuneOpen||code==='KeyP') return false;
  if(document.querySelector('.modal.on')) return false;
  keys[code]=false;
  if(code==='Mouse1') return true;
  if(code==='KeyE'||code==='Space'||code==='Enter'||code==='NumpadEnter'||code==='Escape'||code==='Tab'||code==='KeyM'){
    if(ev) ev.preventDefault();
    if(!repeat) mapFirstGo('key');
  }
  return true;
}
// The one prompt: the key or the pad button of the last device used, then the words; after the press, who it waits for.
function mapFirstPrompt(){
  var g=G, r;
  if(!g||!g.mapFirst) return null;
  if(g.mapFirstMe){ r=mapFirstPeers(); return {k:'',a:'',t:'waiting for '+mapFirstWho(r.who),wait:1}; }
  if(padOn()) return {k:String(padB('A')),a:'',t:'to start',wait:0};
  return {k:String(keyLabel('KeyE','E')),a:'or click ',t:'to start',wait:0};
}
// Drawn after the map, in the band under it, at the screen's own scale (hudRes); the plate is as tall as the band lets it be.
function mapFirstDraw(){
  var g=G, pr=mapFirstPrompt(), z, mp, top, cy, fpx, a, kh, kslot=0, gap=0, tw, dw=0, pw, ph, x0, by, tx, pl, i, T;
  if(!pr||!g||g.over||!(W>0&&H>0)) return false;
  z=(typeof hudRes==='function')?hudRes():1; T=+g.mapFirstT||0;
  mp=mapProj(); top=mp.oy+WORLD_H*mp.sc+3*z;
  ctx.save();
  try{
    ph=LH(32);
    cy=Math.min(top+(H-top)/2,H-ph*z/2-6*z);
    ctx.translate(W/2,cy); ctx.scale(z,z);
    ctx.font=FS(TYPE.head); ctx.textAlign='left'; ctx.textBaseline='alphabetic';
    fpx=parseFloat(((/([\d.]+)px/).exec(ctx.font)||[0,20])[1])||20; a=Math.round(fpx*0.7);
    kh=a+LH(7);
    tw=hudRawW(pr.a+pr.t);
    if(pr.k){ kslot=Math.max(kh+LH(2),hudRawW(pr.k)+LH(12)); gap=LH(10); }
    if(pr.wait) dw=LH(34);
    pw=LH(16)+kslot+gap+tw+dw+LH(16);
    x0=-pw/2; by=Math.round(a/2);
    pl=0.9+0.1*Math.sin(T*3.4);
    ctx.globalAlpha=pl;
    hudPlate(x0,-ph/2,pw,ph,pr.wait?HUDC.extract:UIC.acc,'rgba(14,17,20,.96)');
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1;
    ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x0,-ph/2,pw,ph,Math.max(0,Math.min(LH(4),ph/2))); else ctx.rect(x0,-ph/2,pw,ph); ctx.stroke();
    if(pr.k) hudKey(pr.k,x0+LH(16),by,a,kslot);
    tx=x0+LH(16)+kslot+gap;
    ctx.fillStyle=HUDC.text; ctx.textAlign='left'; ctx.fillText(pr.a+pr.t,tx,by);
    if(pr.wait){
      ctx.fillStyle=HUDC.extract;
      for(i=0;i<3;i++){ ctx.globalAlpha=pl*(0.25+0.75*Math.max(0,Math.sin(T*5-i*0.9))); ctx.beginPath(); ctx.arc(tx+tw+LH(12)+i*LH(9),by-a*0.35,LH(2.4),0,6.2832); ctx.fill(); }
    }
  } finally { ctx.restore(); }
  return true;
}
var _mapFirstSync0=syncPause;
syncPause=function(){ _mapFirstSync0(); if(mapFirstOn()) G.paused=true; };
var _mapFirstDraw0=drawMapOverlay;
drawMapOverlay=function(){ _mapFirstDraw0(); try{ if(G&&G.mapFirst&&!G.over) mapFirstDraw(); }catch(_mfd){} };
function startRaid(){
'@

SubRx @'
  applyGhost();
  showScreen('raid');

'@ @'
  applyGhost();
  showScreen('raid');
  try{ mapFirstBegin(); }catch(_mfb){}   // cw-mapfirst: the raid opens on the sector map, over a frozen world, until it is answered

'@

SubRx @'
  if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); if(!repeat){ keys[code]=false; pauseKeyNav(code); } return; }   // v24.15 (his #39): arrows and ENTER work the box

'@ @'
  if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); if(!repeat){ keys[code]=false; pauseKeyNav(code); } return; }   // v24.15 (his #39): arrows and ENTER work the box
  if(mapFirstKey(code,repeat,ev)) return;   // cw-mapfirst: while the raid waits on its map every key is held back and E, Space, Enter, Esc, Tab and M start it

'@

SubRx @'
  // MARK A WAYPOINT. While the map is up the click belongs to the map and must

'@ @'
  if(G&&G.mapFirst&&!G.over){ if(e.button===0) mapFirstGo('click'); return; }   // cw-mapfirst: a click on the opening map starts the raid and is never a shot
  // MARK A WAYPOINT. While the map is up the click belongs to the map and must

'@

SubRx @'
else if(now&&!PAD.prev[n]&&n===0&&(PAD.aSpent||G.bagOpen||G.mapOpen)){}
'@ @'
else if(now&&!PAD.prev[n]&&n===0&&G.mapFirst&&!PAD.aSpent&&mapFirstGo('pad')){}   // cw-mapfirst: A starts the raid from its opening map
    else if(now&&!PAD.prev[n]&&n===0&&(PAD.aSpent||G.bagOpen||G.mapOpen)){}
'@

SubRx @'
ctx.fillText(padOn()?'R STICK move marker
'@ @'
ctx.fillText(G.mapFirst?'':padOn()?'R STICK move marker
'@

SubRx @'
  if(NET.on) netUpTick(dt);   // v15.79: where the party stands up top, eased in and sent out, whatever the frame does below

'@ @'
  if(G.mapFirst) mapFirstStep(dt);   // cw-mapfirst: the opening map, its press and its wait for the other windows (the clock below stays still while it is up)
  if(NET.on) netUpTick(dt);   // v15.79: where the party stands up top, eased in and sent out, whatever the frame does below

'@

SubRx @'
pz:G.paused?1:0,
'@ @'
pz:G.paused?1:0,mf:mapFirstWord(),
'@

SubRx @'
g.pz=m.pz?1:0;
'@ @'
g.pz=m.pz?1:0; g.mf=(m.mf===1||m.mf===2)?m.mf:0;
'@

SubRx @'
out.pz=g.pz;
'@ @'
out.pz=g.pz; out.mf=g.mf|0;
'@

SubRx @'
function netPauseLive(){ return netUpShared()&&!netAllPaused(); }
'@ @'
function netPauseLive(){ return !mapFirstOn()&&netUpShared()&&!netAllPaused(); }
'@

SubRx @'
  m.late={t:+(+G.t||0).toFixed(2),left:(typeof G.timeLeft==='number')?+G.timeLeft.toFixed(2):null,x:Math.round(G.player.x),y:Math.round(G.player.y)};
'@ @'
  m.late={t:+(+G.t||0).toFixed(2),left:(typeof G.timeLeft==='number')?+G.timeLeft.toFixed(2):null,x:Math.round(G.player.x),y:Math.round(G.player.y),mf:mapFirstWord()};
'@

SubRx @'
  if(!L||typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';

'@ @'
  if(!L||typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
  try{ if(!(L.mf>0)) mapFirstEnd('late'); }catch(_mfl){}   // cw-mapfirst: a raid that is already running is joined running; one still on its map is joined on the map

'@

SubRx @'
    G.player.specOut=1; G.player.vx=0; G.player.vy=0;
    arcadeAttShow();
    return 'bench';
'@ @'
    G.player.specOut=1; G.player.vx=0; G.player.vy=0;
    try{ mapFirstBench(); }catch(_mfb1){}   // cw-mapfirst: a benched host has nothing to press
    arcadeAttShow();
    return 'bench';
'@

SubRx @'
  if(bench){ G.player.specOut=1; arcadeAttShow(); }
'@ @'
  if(bench){ G.player.specOut=1; try{ mapFirstBench(); }catch(_mfb2){} arcadeAttShow(); }
'@

SubRx @'
var VER='31.08';
'@ @'
var VER='31.09';
'@

$pat = "(?m)^  now:'v31\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.09: A raid opens on the sector map. Click, press E or press A to start. The clock waits for you, and for your partner. Check 31.09 fails on v31.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
