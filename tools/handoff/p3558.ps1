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

# PARTNER SHIP STAYS AFTER HOST EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(_xi=0;_xi<(G.zones||[]).length;_xi++){ _xz=G.zones[_xi]; if(!_xz) continue; if(dist(p,_xz)<_xz.r&&typeof _xz.hold==='number'){ _xz.beaconT=null; _xz.hold=null; if(_xz===G.active){ G.beaconT=null; G.shipHold=null; } } _xz.pullT=null; _xz.boardT=0; _xz.pullFloor=0; }
'@ @'
    // v28.xx (cw-cx-partnership): his Q65, "In 2P the run ends when both players are out." Keep the shared ship and its remaining time; clear only this window's boarding progress.
    for(_xi=0;_xi<(G.zones||[]).length;_xi++){ _xz=G.zones[_xi]; if(!_xz) continue; _xz.pullT=null; _xz.boardT=0; _xz.pullFloor=0; }
'@

SubRx @'
var VER='35.57';
'@ @'
var VER='35.58';
'@

$pat = "(?m)^  now:'v35\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.58: When player 1 extracts first, the called ship stays for player 2 until its boarding window closes. Check 35.58 fails on v35.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
