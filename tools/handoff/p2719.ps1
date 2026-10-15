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

# PLAYER 2 HAS HIS OWN AIR STRIKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function airScan(){
  var A=airS(), i, e, h, drop;
'@ @'
function airScan(){
  var A=airS(), i, e, h, drop;
  if(flowPeer()) return;   // v27.19 (coop6): a linked window's meter is charged by the damage it sends the host (airCharge, in netShotSend), not by watching bodies it does not run
'@

SubRx @'
    if(typeof e.airH==='number'&&h<e.airH&&(+e.pHitT||0)>0&&airSide(e)){
'@ @'
    if(typeof e.airH==='number'&&h<e.airH&&(+e.pHitT||0)>0&&airSide(e)&&!(e.pHitSeat|0)){   // v27.19 (coop6): and never a round player 2 landed, that is his meter
'@

SubRx @'
  say('AIR STRIKE INBOUND','warn');
  return true;
'@ @'
  say('AIR STRIKE INBOUND','warn');
  try{ flowNetAirSend(x,y,a0); }catch(_fas){}   // v27.19 (coop6): and the other window sees it come
  return true;
'@

SubRx @'
  for(j=G.ents.length-1;j>=0;j--){
    e=G.ents[j];
    if(!airFoe(e)) continue;
'@ @'
  if(st.fx) return;   // v27.19 (coop6): a strike called in the other window: the rings, the blasts and the shake here, its damage is dealt there
  for(j=G.ents.length-1;j>=0;j--){
    e=G.ents[j];
    if(!airFoe(e)) continue;
'@

SubRx @'
    if(typeof NET==='object'&&NET&&NET.on&&typeof netEntsPeer==='function'&&netEntsPeer()) netShotSend(e,dm,Math.atan2(e.y-q.y,e.x-q.x),null); else e.hp-=dm;
'@ @'
    if(typeof NET==='object'&&NET&&NET.on&&typeof netEntsPeer==='function'&&netEntsPeer()){ airS().blast=1; try{ netShotSend(e,dm,Math.atan2(e.y-q.y,e.x-q.x),null); } finally { airS().blast=0; } } else e.hp-=dm;   // v27.19 (coop6): the strike own damage never refills the meter, on a linked window either
'@

SubRx @'
function netShotSend(e,dmg,ang,wk,ar,el){
  var q, m;
  if(!e||!e.nid||!NET.on||NET.role!=='join'||!netEntsPeer()) return false;
  q=netPeerOfSeat(0); if(!q) return false;
'@ @'
function netShotSend(e,dmg,ang,wk,ar,el){
  var q, m;
  if(!e||!e.nid||!NET.on||NET.role!=='join'||!netEntsPeer()) return false;
  q=netPeerOfSeat(0); if(!q) return false;
  try{ airCharge(e,dmg); }catch(_ach){}   // v27.19 (coop6): the damage a linked window sends the host charges its own air strike meter
'@

SubRx @'
  // FLOW-NET-WORD (the next coop builds take their words above this line)
'@ @'
  if(m.k==='air'){
    if(!flowOn()||!isFinite(+m.x)||!isFinite(+m.y)||!isFinite(+m.a)) return 'bad';
    if(typeof netUpShared!=='function'||!netUpShared()) return 'off';
    airStrikeFx(clamp(+m.x,0,WORLD_W),clamp(+m.y,0,WORLD_H),+m.a,m.s|0);
    if(NET.role==='host') for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],m);
    return 'air';
  }
  // FLOW-NET-WORD (the next coop builds take their words above this line)
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.19 (coop6), HIS ORDER (2026-10-14), the two player first: PLAYER 2 HAS HIS OWN AIR STRIKE. The meter filled from the health a body lost while it carried your hit mark, read from the bodies in your
// own window; on a linked window the bodies belong to the host (their health arrives in tenths of a second and the mark is never set by a round that was only sent), so player 2's meter
// never filled. And on the host, a round player 2 landed set the same mark, so player 2 filled player 1's meter. Now each meter is filled by its own player: the host reads a drop of health only
// when the hit mark is the host's own (not a seat's), and a linked window adds the damage it sends the host (netShotSend, the figure its own round worked out, never more than the health
// the body shows) when the body is a machine or a hostile pillager. The strike's own damage never refills either meter. THE STRIKE IS SEEN AND FELT BY BOTH: calling it tells the other
// windows (t fl, k air: the spot and the spread angle, so the same six points), which show AIR STRIKE INBOUND, the six rings and the blasts with the sound and the shake, and no damage there;
// the damage is dealt by the window that called it, on the bodies it runs or asks the host to hurt.
function airCharge(e,dmg){
  var A, add;
  if(!flowOn()||!airSide(e)||!(+dmg>0)) return 0;
  A=airS(); if(A.blast) return 0;
  add=Math.min(+dmg,(+e.hp>0)?+e.hp:0); if(!(add>0)) return 0;
  A.dealt+=add;
  if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+add); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:'PRESS G'}); } }
  return add;
}
function flowNetAirSend(x,y,a0){
  var i, m;
  if(typeof NET!=='object'||!NET||!NET.on||typeof netUpShared!=='function'||!netUpShared()) return false;
  m={t:'fl',k:'air',x:Math.round(x),y:Math.round(y),a:+(+a0).toFixed(3),s:NET.seat|0};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],m);
  return true;
}
function airStrikeFx(x,y,a0,seat){
  var A=airS(), pts=[], i, a, r, nm;
  if(A.sk.length>=6) return false;
  for(i=0;i<AIR.n;i++){ a=a0+i*2.4; r=AIR.spread*Math.sqrt((i+0.5)/AIR.n); pts.push({x:x+Math.cos(a)*r,y:y+Math.sin(a)*r}); }
  A.sk.push({x:x,y:y,t:0,n:0,pts:pts,fx:1});
  nm=(typeof netSeatName==='function')?netSeatName(seat):null;
  try{ say('AIR STRIKE INBOUND','warn',nm?{sub:String(nm).toUpperCase()}:undefined); }catch(_asf){}
  return true;
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.18';
'@ @'
var VER='27.19';
'@

$pat = "(?m)^  now:'v27\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.19: Player 2 now has his own air strike meter, and both players see and feel each strike. Check 27.19 fails on v27.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
