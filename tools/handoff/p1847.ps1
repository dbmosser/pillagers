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

# A DROP IS NEVER LOST ON ITS WAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof G==='undefined'||!G||G.over||typeof netContHost!=='function'||!netContHost()) return 'down';
'@ @'
  if(typeof G==='undefined'||!G||(G.over&&G!==NET.specG)||typeof netContHost!=='function'||!netContHost()) return 'down';   // v18.47: a spectating host still runs the boxes
'@

SubRx @'
    var _ib=0; if(key==='bandage'&&(G.issuedBandages||0)>0){ G.issuedBandages--; _ib=1; if(G.bandSeen!==undefined) G.bandSeen--; }
    var _q=netPeerOfSeat(0); if(_q) netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib});
    return key;
'@ @'
    // v18.47, FROM THE CODE COMB (2026-10-06): the word goes only when there is a host to take it; with no link the pile is made
    // here, as solo, so the item never leaves the backpack for nowhere
    var _q=netPeerOfSeat(0), _ib=(key==='bandage'&&(G.issuedBandages||0)>0)?1:0;
    if(_q&&netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib})){ if(_ib){ G.issuedBandages--; if(G.bandSeen!==undefined) G.bandSeen--; } return key; }
'@

SubRx @'
var VER='18.46';
'@ @'
var VER='18.47';
'@

$pat = "(?m)^  now:'v18\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.47: Dropping an item for your teammate always leaves it on the ground, even after the host has extracted. Check 18.47 fails on v18.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
