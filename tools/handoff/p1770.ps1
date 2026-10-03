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

# ONE SOUND SETTING FOR THE PAIR: BOTH, PLAYER 1 ONLY OR PLAYER 2 ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=(NET.sndOn||netSndSplitOn())?1:0; }catch(e){} } if(NET.sndP){ try{ NET.sndP.pan.value=netSndSplitOn()?((NET.same==='p2')?1:-1):0; }catch(e2){} } return NET.sndOn; }
'@ @'
// v17.70, HIS ORDER 2026-10-02: ONE SOUND SETTING FOR THE PAIR. World sound plays in both windows, in player 1 only, or in
// player 2 only; one setting both windows read (the same origin shares it, and the storage event tells the other window the
// moment it changes). It replaces the per-window SOUND ON/OFF buttons, which had to be set in each window and read what the
// other had said. With both, SPLIT SPEAKERS still puts player 1 left and player 2 right.
var NET_WHO_KEY='salvagerun:samesound:who';
function netSndWho(){ var v=null; try{ v=localStorage.getItem(NET_WHO_KEY); }catch(e){ v=null; } return (v==='p1'||v==='p2')?v:'both'; }
function netSndWhoOn(){ var w=netSndWho(); return !NET.same||w==='both'||(w==='p1'&&NET.same==='host')||(w==='p2'&&NET.same==='p2'); }
function netSndWhoSet(v){ v=(v==='p1'||v==='p2')?v:'both'; try{ localStorage.setItem(NET_WHO_KEY,v); }catch(e){} NET.sndOn=netSndWhoOn(); netSndApply(); try{ renderParty(); }catch(e2){} return v; }
function netSndWhoCycle(){ var w=netSndWho(); return netSndWhoSet(w==='both'?'p1':(w==='p1'?'p2':'both')); }
function netSndWhoLabel(){ var w=netSndWho(); return 'WORLD SOUND: '+(w==='p1'?'PLAYER 1 ONLY':(w==='p2'?'PLAYER 2 ONLY':'BOTH PLAYERS')); }
function netSndApply(){ var on=netSndWhoOn(); NET.sndOn=on; if(NET.sndG){ try{ NET.sndG.gain.value=on?1:0; }catch(e){} } if(NET.sndP){ try{ NET.sndP.pan.value=(on&&netSndWho()==='both'&&netSndSplitOn())?((NET.same==='p2')?1:-1):0; }catch(e2){} } return on; }
'@

SubRx @'
try{ window.addEventListener('storage',function(ev){ if(ev&&ev.key===NET_SPLIT_KEY&&NET.same){ netSndApply(); try{ renderParty(); }catch(e){} } }); }catch(_se){}
'@ @'
try{ window.addEventListener('storage',function(ev){ if(ev&&(ev.key===NET_SPLIT_KEY||ev.key===NET_WHO_KEY)&&NET.same){ netSndApply(); try{ renderParty(); }catch(e){} } }); }catch(_se){}
'@

SubRx @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Only one window should play world sound, or you hear everything twice.'; } }
'@ @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent=netSndWhoLabel(); if(sn) sn.textContent='Press to change. Both windows follow this setting. With both, SPLIT SPEAKERS puts player 1 left and player 2 right.'; } }   // v17.70: one setting for the pair
'@

SubRx @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
'@ @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndWhoCycle(); };   // v17.70: both / player 1 only / player 2 only
'@

SubRx @'
var VER='17.69';
'@ @'
var VER='17.70';
'@

$pat = "(?m)^  now:'v17\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.70: Two-player sound is one setting in the PARTY window: WORLD SOUND: BOTH PLAYERS, PLAYER 1 ONLY or PLAYER 2 ONLY. Both windows follow it. Check 17.70 fails on v17.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
