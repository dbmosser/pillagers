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

# THE PARTY SEES AND HEARS EACH OTHERS FIGHT, AND THE REVIVE HAS A BAR. His notes of 2026-09-27.

SubRx @'
  for(i=0;i<G.bullets.length;i++){
var b=G.bullets[i],bm=Math.sqrt(b.vx*b.vx+b.vy*b.vy)||1;
'@ @'
  var _BLS=(G.fxBullets&&G.fxBullets.length)?G.bullets.concat(G.fxBullets):G.bullets;   // v16.21: with the tracers of the rest of the party
  for(i=0;i<_BLS.length;i++){
var b=_BLS[i],bm=Math.sqrt(b.vx*b.vx+b.vy*b.vy)||1;
'@

SubRx @'
      thru:(wep.id==='lance')?1:0});   // v11.84, HIS NOTE: the Lance travels through crawlers
'@ @'
      thru:(wep.id==='lance')?1:0});   // v11.84, HIS NOTE: the Lance travels through crawlers
    if(NET.on) netFxShot(G.bullets[G.bullets.length-1]);   // v16.21: the rest of the party sees this round
'@

SubRx @'
  if(typeof NET==='object'&&NET&&NET.specTick) return;   // v16.14: the raid a spectating host keeps running for the party makes no sound in his window
'@ @'
  if(typeof NET==='object'&&NET&&NET.on&&!NET.fxIn&&wx!==undefined&&wx!==null) netFxNoise(type,wx,wy,wid);   // v16.21: the rest of the party hears it and sees its ring
  if(typeof NET==='object'&&NET&&NET.specTick) return;   // v16.14: the raid a spectating host keeps running for the party makes no sound in his window
'@

SubRx @'
  if(NET.on) netUpTick(dt);   // v15.79: where the party stands up top, eased in and sent out, whatever the frame does below
'@ @'
  if(NET.on) netUpTick(dt);   // v15.79: where the party stands up top, eased in and sent out, whatever the frame does below
  if(NET.on) netFxStep(dt);   // v16.21: the party's tracers fly, and this window's sounds go out
'@

SubRx @'
  if(G.searching&&!(G.player&&G.player.downed)){   // v14.08: not while down
'@ @'
  try{ if(NET.on&&G.netRevT>0&&G.netRevS>=0&&NET.up[G.netRevS]){   // v16.21, his note: the revive has a bar, like a search
    var _rg=NET.up[G.netRevS], _rs=w2s(_rg.x,26,_rg.y);
    if(_rs){ bar(_rs.x-30,_rs.y-8,60,6,Math.min(1,G.netRevT/NET_REV_T),'#4de3d0');
      ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#4de3d0'; ctx.fillText('REVIVING',_rs.x,_rs.y-14); ctx.textAlign='left'; }
  } }catch(_rvb){}
  if(G.searching&&!(G.player&&G.player.downed)){   // v14.08: not while down
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='fx') return netFxTake(peer,m);   // v16.21: a round or a sound from one of the party, to draw and play
'@

SubRx @'
function netAllPaused(){
'@ @'
// v16.21, HIS NOTE: THE SECOND PLAYER COULD NOT SEE THE FIRST PLAYER'S BULLETS OR HIS RED SOUND RINGS. Every window drew only the
// rounds it made and the sounds it played: a friend never saw the host shoot or the machines fire (the host runs them), and never
// heard them or got their rings. Now, in a shared raid, every round a window makes is sent to the party on the fast channel as a
// tracer (netFxShot), and every positioned sound is sent ten times a second (netFxNoise, netFxStep); the host passes each on to the
// others. A tracer flies on the receiving window until its time runs out or a wall stops it, and hurts nothing (the host lands
// hits, as before). A sound is played through sfx, which draws its ring by the same rules as your own. Nothing is drawn from the
// seeded stream. Solo play never sends or takes any of it.
function netFxShot(b){
  var i, m;
  if(!b||!netUpShared()) return false;
  m={t:'fx',k:'b',s:NET.seat,b:[Math.round(b.x),Math.round(b.y),Math.round(b.vx),Math.round(b.vy),+(+b.life||0).toFixed(3),String(b.tint||'#ffd48a').slice(0,9)]};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  return true;
}
function netFxNoise(type,x,y,wid){
  if(!netUpShared()) return false;
  NET.fxQ=NET.fxQ||[];
  if(NET.fxQ.length<16) NET.fxQ.push([netClean(type,16),Math.round(x),Math.round(y),wid?netClean(wid,16):'']);
  return true;
}
function netFxStep(dt){
  var i, b, nx, ny, m;
  if(typeof G==='undefined'||!G||G.sim) return 0;
  if(G.fxBullets) for(i=G.fxBullets.length-1;i>=0;i--){
    b=G.fxBullets[i]; nx=b.x+b.vx*dt; ny=b.y+b.vy*dt; b.life-=dt;
    if(b.life<=0||(G.map&&G.map.segs&&!losClear(b.x,b.y,nx,ny,G.map.segs))) G.fxBullets.splice(i,1); else { b.x=nx; b.y=ny; }
  }
  NET.fxAcc=(NET.fxAcc||0)+dt;
  if(NET.fxAcc>=NET_HUB_STEP&&NET.fxQ&&NET.fxQ.length){
    NET.fxAcc=0; m={t:'fx',k:'n',s:NET.seat,n:NET.fxQ.slice(0,16)}; NET.fxQ=[];
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  }
  return G.fxBullets?G.fxBullets.length:0;
}
function netFxTake(peer,m){
  var i, a, q;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!netUpShared()) return 'off';
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSendFast(q,m); }
  if(m.k==='b'&&m.b&&m.b.length>=5){
    a=m.b; G.fxBullets=G.fxBullets||[];
    if(G.fxBullets.length<80) G.fxBullets.push({x:+a[0]||0,y:+a[1]||0,vx:+a[2]||0,vy:+a[3]||0,life:Math.min(3,Math.max(0,+a[4]||0)),tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1});
    return 'fx:b';
  }
  if(m.k==='n'&&m.n&&m.n.length){
    NET.fxIn=true;
    try{ for(i=0;i<m.n.length&&i<16;i++){ a=m.n[i]; if(a&&typeof a[0]==='string'&&isFinite(a[1])&&isFinite(a[2])) sfx(a[0],+a[1],+a[2],a[3]||undefined); } }
    finally{ NET.fxIn=false; }
    return 'fx:n';
  }
  return 'bad';
}
function netAllPaused(){
'@

SubRx @'
var VER='16.20';
'@ @'
var VER='16.21';
'@

$pat = "(?m)^  now:'v16\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.21: THE PARTY SEES AND HEARS EACH OTHERS FIGHT, AND THE REVIVE HAS A BAR. His notes. In co-op every round a player or a machine fires now shows as a tracer on every window, and every sound reaches every window with its red ring, so a friend sees and hears the host, the machines and the other friends. Holding E on a downed teammate shows a REVIVING bar over him. Nothing hurts twice: the host still lands every hit. No number moved. Check 16.21 fails on v16.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
