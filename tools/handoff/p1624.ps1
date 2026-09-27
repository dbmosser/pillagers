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

# SPLIT SPEAKERS, player 1 left and player 2 right. His note of 2026-09-27.

SubRx @'
    try{ NET.sndG=a.createGain(); NET.sndG.gain.value=NET.sndOn?1:0; NET.sndG.connect(a.destination); NET.sndAc=a; }
'@ @'
    try{ NET.sndG=a.createGain(); NET.sndG.gain.value=NET.sndOn?1:0; NET.sndAc=a;
         // v16.24: through a stereo panner, so SPLIT SPEAKERS can put player 1 on the left and player 2 on the right
         NET.sndP=null; try{ if(a.createStereoPanner){ NET.sndP=a.createStereoPanner(); NET.sndG.connect(NET.sndP); NET.sndP.connect(a.destination); } }catch(_sp){ NET.sndP=null; }
         if(!NET.sndP) NET.sndG.connect(a.destination);
         netSndApply(); }
'@

SubRx @'
function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=NET.sndOn?1:0; }catch(e){} } return NET.sndOn; }
'@ @'
function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=(NET.sndOn||netSndSplitOn())?1:0; }catch(e){} } if(NET.sndP){ try{ NET.sndP.pan.value=netSndSplitOn()?((NET.same==='p2')?1:-1):0; }catch(e2){} } return NET.sndOn; }
// v16.24, HIS NOTE: AN OPTION TO PUT PLAYER ONE'S SOUND IN THE LEFT SPEAKER AND PLAYER TWO'S IN THE RIGHT. SPLIT SPEAKERS in the
// sound row of the PARTY window, in a same machine mode: both windows play the world sound, player 1's window panned hard left and
// player 2's hard right, whatever SOUND ON or OFF says. It is one setting for the pair, kept in the browser; the other window picks
// up the change at once (the storage event), so pressing it in either window switches both. Off, everything is as before.
var NET_SPLIT_KEY='salvagerun:samesound:split';
function netSndSplitOn(){ var v=null; if(!NET.same) return false; try{ v=localStorage.getItem(NET_SPLIT_KEY); }catch(e){ v=null; } return v==='1'; }
function netSndSplitToggle(){ var on=!netSndSplitOn(); try{ localStorage.setItem(NET_SPLIT_KEY,on?'1':'0'); }catch(e){} netSndApply(); try{ renderParty(); }catch(e2){} return on; }
try{ window.addEventListener('storage',function(ev){ if(ev&&ev.key===NET_SPLIT_KEY&&NET.same){ netSndApply(); try{ renderParty(); }catch(e){} } }); }catch(_se){}
'@

SubRx @'
    <button id="partysndbtn" style="padding:6px 16px">THIS WINDOW: SOUND ON</button>
'@ @'
    <button id="partysndbtn" style="padding:6px 16px">THIS WINDOW: SOUND ON</button>
    <button id="partysplitbtn" style="padding:6px 16px;margin-left:8px">SPLIT SPEAKERS: OFF</button>
'@

SubRx @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Only one window should play world sound, or you hear everything twice.'; } }
'@ @'
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Only one window should play world sound, or you hear everything twice.'; } }
  if(g('partysplitbtn')) g('partysplitbtn').textContent=netSndSplitOn()?'SPLIT SPEAKERS: ON (P1 LEFT, P2 RIGHT)':'SPLIT SPEAKERS: OFF';   // v16.24
'@

SubRx @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
'@ @'
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
  if(g('partysplitbtn')) g('partysplitbtn').onclick=function(){ netSndSplitToggle(); };   // v16.24: player 1 left, player 2 right
'@

SubRx @'
var VER='16.23';
'@ @'
var VER='16.24';
'@

$pat = "(?m)^  now:'v16\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.24: SPLIT SPEAKERS. His note. In two player co-op on one PC the PARTY window sound row has SPLIT SPEAKERS: both windows play sound, player 1 in the left speaker and player 2 in the right. Pressing it in either window switches both. No number moved. Check 16.24 fails on v16.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
