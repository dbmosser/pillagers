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

# COUCH MODE WORKS INSIDE ITCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSameChan(){
  if(NET.bc) return NET.bc;

'@ @'
function netSameChan(){
  if(NET.bc) return NET.bc;
  if(netBridgeOn()){ NET.bc=netBridgeChan(); return NET.bc; }   // v33.58 (cw-p2bridge): inside itch's frame the BroadcastChannel is partitioned, so the pair talks over window.opener

'@

SubRx @'
  return base+'?p2=1&mode='+((mode==='pvp')?'pvp':'coop')+'&pair='+String(pair||'')+((NET.arcPick&&mode!=='pvp')?'&arc=1':'');   // v23.24 (arcade5): &arc=1
'@ @'
  var emb=!!reportEmbedded(), keep='';   // v33.58 (cw-p2bridge): embedded only; the top level address is exactly what it was
  if(emb){ keep=String((typeof location!=='undefined'&&location.search)||'').replace(/^\?/,'').split('&').filter(function(s){ return s&&!/^(p2|mode|pair|arc|emb)=/.test(s); }).join('&'); if(keep) keep+='&'; }
  return base+'?'+keep+'p2=1&mode='+((mode==='pvp')?'pvp':'coop')+'&pair='+String(pair||'')+((NET.arcPick&&mode!=='pvp')?'&arc=1':'')+(emb?'&emb=1':'');   // v23.24 (arcade5): &arc=1
'@

SubRx @'
function netSameBootP2(pair,mode){
  var q=(typeof location!=='undefined'&&location.search)||'';
'@ @'
function netSameBootP2(pair,mode,qOver){
  var q=(typeof qOver==='string')?qOver:((typeof location!=='undefined'&&location.search)||'');
'@

SubRx @'
  if(typeof BroadcastChannel!=='function'||!netSupported()){ NET.err='This browser cannot link two windows of the game.'; netRefresh(); return 'unsupported'; }
'@ @'
  NET.embP2=netEmbOf(q);   // v33.58 (cw-p2bridge): opened from itch's frame, so it talks over window.opener
  if(NET.embP2&&!window.opener){ netModeMsg('no link: pick 2 player in the player 1 window'); return 'noopener'; }   // itch turned COOP on, or the window was opened by hand: nothing to talk to
  if(typeof BroadcastChannel!=='function'||!netSupported()){ NET.err='This browser cannot link two windows of the game.'; netRefresh(); return 'unsupported'; }
'@

SubRx @'
function netSameStop(){
'@ @'
// v33.58 (cw-p2bridge), coord-06 (2026-10-21): COUCH MODE ON ITCH. The game runs in a cross-site iframe there, and a BroadcastChannel is
// partitioned between the frame and the player 2 popup (measured: the real game did not link in 20 s). window.opener.postMessage works both ways, so
// in the frame the channel is a bridge: the host posts to the popup handle, the popup posts to its opener, every word wrapped {pg:'pillagers',m}.
// A word is taken only from this origin, only with the game's tag, only from the pair's own window, and only with this pair's code (itch
// serves every html game from one origin, so the source test matters). Top level keeps its BroadcastChannel, untouched.
function netEmbOf(q){ q=String(q||''); return (/[?&]p2=1(&|$)/).test(q)&&(/[?&]emb=1(&|$)/).test(q); }
function netBridgeOn(){
  if(NET.same==='p2') return !!NET.embP2;
  if(NET.same==='host'){ try{ return !!reportEmbedded(); }catch(_be){ return false; } }
  return false;
}
function netBridgeTarget(){
  if(NET.same==='p2'){ try{ return window.opener||null; }catch(_bo){ return null; } }
  return NET.p2win||null;
}
function netBridgeChan(){
  return {br:1,onmessage:null,close:function(){},postMessage:function(m){
    var w=netBridgeTarget();
    if(!w) return;
    w.postMessage({pg:'pillagers',m:m},location.origin);
  }};
}
function netBridgeIn(e){
  var d=e&&e.data, src=e&&e.source, m=d&&d.m;
  if(!NET.bc||!NET.bc.br) return 'off';
  if(!d||typeof d!=='object'||d.pg!=='pillagers'||!m||typeof m!=='object') return 'bad';
  if(e.origin!==location.origin) return 'origin';
  if(NET.same==='host'){
    if(!NET.p2win){ if(!src||m.pair!==NET.pair) return 'source'; NET.p2win=src; }   // a host that lost its handle (the frame reloaded) takes the window that speaks with its pair code
    else if(src!==NET.p2win) return 'source';
  }
  else if(NET.same==='p2'){ if(!src||src!==window.opener) return 'source'; }
  else return 'off';
  return netSameOnMsg(m);
}
try{ window.addEventListener('message',netBridgeIn); }catch(_bm){}
function netSameStop(){
'@

SubRx @'
var VER='33.58';
'@ @'
var VER='33.59';
'@

$pat = "(?m)^  now:'v33\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.59: On itch the player 2 window now links to player 1 through the page, and a player 2 window with no opener says so. Check 33.59 fails on v33.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
