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

# THE HOST SPECTATES. His ruling of 2026-09-26 (replacing the v15.91 end-as-abandon when the host extracts or dies).

SubRx @'
  if(NET.on&&!G.sim){ try{ netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended, and nobody is drawn up top any more
'@ @'
  if(NET.on&&!G.sim){ try{ if(!netSpecStart(how)) netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended; v16.14: unless the host spectates for the party still up top
'@

SubRx @'
  pollPad();
'@ @'
  pollPad();
  if(NET.on&&NET.specG) netSpecTick(dt);   // v16.14: the raid the host left runs on for the party still up top, whatever this window shows
'@

SubRx @'
function netOnMsg(peer,data){
'@ @'
// v16.14: while the host spectates, every word is handled against the raid world it keeps running, whatever this window shows.
function netOnMsg(peer,data){
  if(typeof NET==='object'&&NET&&NET.specG&&G!==NET.specG){ var _kg=G; G=NET.specG; try{ return netOnMsg0(peer,data); } finally{ G=_kg; } }
  return netOnMsg0(peer,data);
}
function netOnMsg0(peer,data){
'@

SubRx @'
function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;
'@ @'
function sfx(type,wx,wy,wid){
  if(G&&G.sim) return;
  if(typeof NET==='object'&&NET&&NET.specTick) return;   // v16.14: the raid a spectating host keeps running for the party makes no sound in his window
'@

SubRx @'
  var best=G.player, bd, i, g, b, d, up;
'@ @'
  var best=G.player, bd, i, g, b, d, up;   // v16.14: a host who is out (spectating) is nobody's target
'@

SubRx @'
  bd=dist(e,best); up=!best.downed;
'@ @'
  bd=dist(e,best); up=!best.downed;
  if(best.specOut){ bd=1e9; up=false; }
'@

SubRx @'
  var d=G.player?dist(pt,G.player):1e9, i, g, q;
'@ @'
  var d=(G.player&&!G.player.specOut)?dist(pt,G.player):1e9, i, g, q;   // v16.14: not the spectating host
'@

SubRx @'
function netPlayersList(){ var out=[], i, g; if(G&&G.player) out.push(G.player);
'@ @'
function netPlayersList(){ var out=[], i, g; if(G&&G.player&&!G.player.specOut) out.push(G.player);
'@

SubRx @'
  st=(m.st==='in'||m.st==='out'||m.st==='no')?m.st:'';
'@ @'
  st=(m.st==='in'||m.st==='out'||m.st==='no'||m.st==='spec')?m.st:'';   // v16.14: spec, the host is out and keeps the raid running
'@

SubRx @'
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended, so this one ends as abandon for the whole party, his ruling
'@ @'
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended with nobody left to run it: abandon for the whole party
  if(NET.role==='join'&&st==='spec'&&s===0){ NET.status='Your host is out. The raid runs on until you are out.'; try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree('Your host is out. The raid runs on until you are out.'); }catch(_sw){} }   // v16.14, his ruling
'@

SubRx @'
  try{ voiceMicOff(); }catch(_vm){}   // v16.09: the mic is let go with the party
'@ @'
  try{ voiceMicOff(); }catch(_vm){}   // v16.09: the mic is let go with the party
  NET.specG=null; NET.specHow=''; NET.specTick=false;   // v16.14: a host who ends the party stops running the raid (the party is told bye: abandon, his ruling)
'@

SubRx @'
function netGuestHeld(){
'@ @'
function netGuestHeld(){
  if(typeof NET==='object'&&NET&&NET.specG){ netSay('Your party is still up top. The lift waits until they are out.'); return true; }   // v16.14: a spectating host does not go up again
'@

SubRx @'
function netEntsHost(){ return !!(NET.on&&NET.role==='host'&&typeof G!=='undefined'&&G&&!G.sim&&!G.over&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }
'@ @'
function netEntsHost(){ return !!(NET.on&&NET.role==='host'&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG)&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }   // v16.14: or the raid a spectating host runs on
// v16.14, HIS RULING OF 2026-09-26: THE HOST SPECTATES. The host window runs the pillagers, the machines and the boxes for the
// party, so when the host extracted, died or abandoned, every friend up top was ended as ABANDON (v15.91) and lost what he
// carried. Now, if a friend is up top on the party seed when the host run ends, the host run ends for the host as always (his
// card, his save) and the raid world is kept (NET.specG) and run every frame (netSpecTick) whatever the host window shows: the
// clock, the bodies, the bullets and throwables, and the words out to the party (bodies, boxes, the world word without the
// rings, which each friend runs himself). The host is nobody's target. Every word that comes in is handled against that world
// (netOnMsg), so shots, searches and beacons go on working, and it makes no sound in the host window. The party is told spec, not
// out, so nobody is ended; a friend hears Your host is out. The raid runs on until you are out. It stops when no friend is up
// top any more (out, dead, abandoned or gone) for a second and a half, and then the party is told out as before. The host
// cannot go up again meanwhile. The host ending the party or losing the link still ends every friend as ABANDON, his ruling of
// 2026-09-25. Solo play never reaches any of it.
function netSpecStart(how){
  var i, n=0;
  if(NET.role!=='host'||typeof G==='undefined'||!G||G.sim||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)||!netInCount()) return false;
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])) n++;
  if(!n) return false;
  NET.specG=G; NET.specHow=String(how||'extract'); NET.specAcc=0; NET.specIdle=0;
  if(G.player) G.player.specOut=1;
  netBroadcast({t:'up',st:'spec',how:netClean(how,12)});
  NET.status='Your party is still up top. The raid runs on until they are out.';
  return true;
}
function netSpecTick(dt){
  var keep=G, S=NET.specG, i, n=0;
  if(!S||NET.role!=='host'){ NET.specG=null; return 0; }
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])) n++;
  if(!n||!netInCount()){ NET.specIdle=(NET.specIdle||0)+dt; if(NET.specIdle>1.5||!netInCount()) return netSpecEnd(); }
  else NET.specIdle=0;
  if(!isFinite(dt)||dt<0) dt=0;
  G=S; NET.specTick=true;
  try{
    G.t+=dt; if(raidClockOn()) G.timeLeft=Math.max(0,G.timeLeft-dt);
    refreshVseg(); updateEnts(dt); updateBullets(dt); updateThrowables(dt);
    NET.specAcc=(NET.specAcc||0)+dt;
    if(NET.specAcc>=NET_HUB_STEP){ NET.specAcc=0; NET.upN++; netEntsTick(); netContTick(); if(NET.upN%5===0) netWorldSend(); }
  }catch(e){}
  finally{ NET.specTick=false; G=keep; }
  return n;
}
function netSpecEnd(){
  var keep=G, S=NET.specG, how=NET.specHow||'extract';
  NET.specG=null; NET.specHow=''; NET.specTick=false;
  G=S; try{ netUpEnd(how); }catch(e){} finally{ G=keep; }
  NET.status='Your party is back down. The raid is over.';
  netRefresh();
  return 0;
}
'@

SubRx @'
  for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }
'@ @'
  if(!G.over) for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }   // v16.14: a spectating host sends no rings: each friend runs his own
'@

SubRx @'
If the host leaves, the run ends as abandoned for everyone.
'@ @'
If the host leaves the party, the run ends as abandoned for everyone; if the host extracts or dies, the raid runs on until the rest of you are out.
'@

SubRx @'
var VER='16.13';
'@ @'
var VER='16.14';
'@

$pat = "(?m)^  now:'v16\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.14: THE HOST SPECTATES. His ruling. When the host extracts, dies or abandons with a friend still up top, the host run ends for the host as always, and the raid keeps running in the host window for the party until the last friend is out: the enemies, the boxes, shots and beacons all work, the host is nobody target, and it makes no sound there. The host cannot go up again until then. The host ending the party or losing the link still ends everyone as abandon. The what is new card says so. No number moved. Check 16.14 fails on v16.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
