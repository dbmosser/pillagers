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

# VOICES CARRY BY DISTANCE UP TOP. Multiplayer, plan.md and net.md section 4 (proximity volume).

SubRx @'
function voiceVol(peer){ if(peer&&peer.vGain&&peer.vGain.gain) peer.vGain.gain.value=(P&&P.netMute&&peer.pid&&P.netMute[peer.pid])?0:1; }
'@ @'
function voiceVol(peer){ if(peer&&peer.vGain&&peer.vGain.gain) peer.vGain.gain.value=(P&&P.netMute&&peer.pid&&P.netMute[peer.pid])?0:voiceProx(peer); }
// v16.10, MULTIPLAYER: VOICES CARRY BY DISTANCE UP TOP (plan.md: in the raid, voices get quieter with distance; net.md section 4
// gives the curve). When this player and the teammate are both up top on the party seed, his voice is full out to 120, falls
// to -30 dB at 900 on a straight decibel line, fades out by 1,100, and is halved with a wall between them. Anywhere else (the
// Undercroft, one of them still below) it is full, as before. Every window works it out for itself ten times a second from the
// state words (netUpTick) and again when a raid ends; MUTE still wins.
function voiceProx(peer){
  var g, p, d, v;
  if(typeof G==='undefined'||!G||G.sim||!G.player||!NET.upSeed||(G.seed>>>0)!==(NET.upSeed>>>0)||!peer) return 1;
  g=NET.up[peer.seat];
  if(!g||g.sd!==(NET.upSeed>>>0)||!(g.n>0)) return 1;
  p=G.player; d=Math.hypot(g.x-p.x,g.y-p.y);
  if(d<=120) v=1;
  else if(d<=900) v=Math.pow(10,(-30*(d-120)/780)/20);
  else if(d<1100) v=Math.pow(10,-1.5)*(1100-d)/200;
  else v=0;
  try{ if(v>0&&G.map&&G.map.segs&&!losClear(p.x,p.y,g.x,g.y,G.map.segs)) v*=0.5; }catch(e){}
  return v;
}
function voiceProxAll(){ var i; for(i=0;i<NET.peers.length;i++) voiceVol(NET.peers[i]); }
'@

SubRx @'
  if(NET.upAcc<NET_HUB_STEP) return 0;
'@ @'
  if(NET.upAcc<NET_HUB_STEP) return 0;
  try{ voiceProxAll(); }catch(_vp){}   // v16.10: voices by distance, on the same clock
'@

SubRx @'
function netUpEnd(how){
  if(!NET.on) return false;
'@ @'
function netUpEnd(how){
  if(!NET.on) return false;
  setTimeout(function(){ try{ voiceProxAll(); }catch(_vp){} },0);   // v16.10: back to full voices once the raid is let go
'@

SubRx @'
var VER='16.09';
'@ @'
var VER='16.10';
'@

$pat = "(?m)^  now:'v16\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.10: VOICES CARRY BY DISTANCE UP TOP. Multiplayer. When you and a teammate are both up top, his voice is full out to 120, falls to about a thirtieth by 900, is gone past 1,100, and is halved with a wall between you. In the Undercroft voices stay full. Mute still wins. No number moved in the game. Check 16.10 fails on v16.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
