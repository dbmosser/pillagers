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

# MIDDLE MOUSE: PING AND SIGNAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
Mouse3:'MOUSE 4',Mouse4:'MOUSE 5'};
'@ @'
Mouse1:'MIDDLE MOUSE',Mouse3:'MOUSE 4',Mouse4:'MOUSE 5'};
'@

SubRx @'
['KeyT','offer an item to a teammate'],['KeyN','ping'],
'@ @'
['KeyT','offer an item to a teammate'],['KeyN','ping'],['Mouse1','ping / signal (mouse)'],
'@

SubRx @'
['PARTY',['KeyT','KeyZ','KeyN','KeyV']]];
'@ @'
['PARTY',['KeyT','KeyZ','KeyN','KeyV','Mouse1']]];
'@

SubRx @'
if(!(e.button>=3&&e.button<=4)) return false;
'@ @'
if(!(e.button===1||(e.button>=3&&e.button<=4))) return false;   // v25.xx (mmbping): the middle button joins the two side buttons
'@

SubRx @'
if(!inv[pc]) return false;
'@ @'
if(e.button===1){   // v25.xx (mmbping): the middle button is the key Mouse1 (ping / signal). In a live raid its press is claimed here and goes through the key map; anywhere else it is the browser's, as before.
    if(down){ if(!(typeof G!=='undefined'&&G&&!G.over&&state==='raid')) return false; KEYS.mmb=1; e.stopPropagation(); }
    else { if(!KEYS.mmb) return false; KEYS.mmb=0; }
  } else if(!inv[pc]) return false;
'@

SubRx @'
if(e.button===1){ if(G&&!G.over&&NET.on){ netPingMake(); e.preventDefault(); } return; }   // v16.43: the middle button pings for the party
'@ @'
if(e.button===1) return;   // v16.43: the middle button pings for the party; v25.xx (mmbping): through keysMouse and the key map now (Mouse1), so it can be rebound
'@

SubRx @'
if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); if(!repeat){ keys[code]=false; pauseKeyNav(code); } return; }   // v24.15 (his #39): arrows and ENTER work the box
'@ @'
if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); if(!repeat){ keys[code]=false; pauseKeyNav(code); } return; }   // v24.15 (his #39): arrows and ENTER work the box
  // v25.xx (mmbping), HIS ORDER 2026-10-13 ("middle mouse: yes"): MIDDLE MOUSE IS THE PING AND THE SIGNAL, rebindable. With a party it marks
  // what is under the cursor for them (netPingMake, the N key, and on the open map your marker); alone it does what V does (opens and
  // closes the signal strip, so hail and stand down are one click from the aim). It latches no key.
  if(code==='Mouse1'){
    keys[code]=false; if(ev) ev.preventDefault();
    if(repeat||!G||G.over) return;
    if(NET.on) netPingMake(); else { raidKey('KeyV',false,ev); keys['KeyV']=false; }
    return;
  }
'@

SubRx @'
s('KeyN')+' ping &nbsp; '
'@ @'
s('KeyN')+' / '+s('Mouse1')+' ping &nbsp; '
'@

SubRx @'
Rebind any action to a keyboard key or a side mouse button.
'@ @'
Rebind any action to a keyboard key or a mouse button (middle or side).
'@

SubRx @'
var VER='25.76';
'@ @'
var VER='25.77';
'@

$pat = "(?m)^  now:'v25\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.77: Middle mouse pings for the party and, alone, opens the V signal strip; it is on the rebind list. Check 25.77 fails on v25.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
