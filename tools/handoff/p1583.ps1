$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE SECTOR MAP NEVER SITS OVER THE OPEN STALL. The M toggle in raidKey ran before the open-stall block with no stall test,
# and the stall-open line in updatePlayer never read mapOpen, so the map could cover the stall while the stall kept the keys.
SubRx @'
  // v6.41, his note: M is a toggle, not a hold.
  if(code==='KeyM'&&G&&!G.over&&!repeat){ G.mapOpen=!G.mapOpen; }
'@ @'
  // v6.41, his note: M is a toggle, not a hold.
  // v15.83, trade audit finding: THE SECTOR MAP NEVER SITS OVER THE OPEN STALL. This toggle ran before the open-stall block
  // below and had no stall test, so M at the Peddler opened the map; drawMapOverlay is the last draw in the frame and fills
  // the screen at .94, so the stall vanished behind it while it still owned the keys. ESC in the stall block and TAB through
  // backOut (G.trade is tested before G.mapOpen there) shut the hidden stall and left the map up, and the digits still sold
  // the whole backpack and bought stock behind the map, unseen. The open stall owns the keys (v13.49), so M now does nothing
  // while it is open; the other way in, E with the map already up, is closed in updatePlayer where the stall opens. The
  // controller was already right: its stall branch in pollPad returns before the D-UP toggle. No number, no player text and
  // no seeded draw moved.
  if(code==='KeyM'&&G&&!G.over&&!G.trade&&!repeat){ G.mapOpen=!G.mapOpen; }
'@
SubRx @'
    if(!pedOpen()) say('He has heard what you did to the last one. No deal.');
    else { G.trade=ped; mouse.down=false; blip('pick'); }
'@ @'
    if(!pedOpen()) say('He has heard what you did to the last one. No deal.');
    // v15.83, trade audit finding: THE SECTOR MAP NEVER SITS OVER THE OPEN STALL. Nothing here read mapOpen, so E with the map
    // up (or pad X, which padHold turns into E) opened the stall underneath the map, hidden, with its keys live. The map shuts
    // as the stall opens, the way the downed screen clears it (v14.07), so the panel he just opened is the one in front and
    // ESC, TAB and the number row act on what he sees. Paired with the M guard in raidKey.
    else { G.trade=ped; G.mapOpen=false; mouse.down=false; blip('pick'); }
'@
SubRx @'
var VER='15.82';
'@ @'
var VER='15.83';
'@

$pat = "(?m)^  now:'v15\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.83: THE SECTOR MAP NEVER SITS OVER THE OPEN STALL. Pressing M at the open Peddler stall put the sector map over it, and E with the map up opened the stall under the map, so the stall was hidden while ESC, TAB and the number keys still acted on it, and 1 sold the whole backpack unseen. M now does nothing while the stall is open, and opening the stall shuts the map, so every key acts on what is on screen. Check 15.83 opens the stall beside a Peddler and presses M, direct and through the page, then opens the stall with the map up; it fails on v15.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
