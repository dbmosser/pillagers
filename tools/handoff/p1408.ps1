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

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 4: THE SEARCH BAR AND THE LOCKED-DOOR PROMPT STAYED UP FOR THE WHOLE
# BLEED-OUT. The downed branch of updatePlayer returns before the door scan and the container scan, which are the only things
# that clear G.nearDoor and G.searching, and going down cleared neither. So a player downed halfway through a search crawled
# away with the amber bar and its items-left plate frozen on the crate, and one downed beside a locked door with its key kept
# [E] UNLOCK on screen while E did nothing for the door. Going down now lets both go, and neither is drawn while down.
SubRx @'
    G.mapOpen=false; G.bagOpen=false; G.drag=null;   // v14.07, HUD audit: nothing covers the downed screen
'@ @'
    G.mapOpen=false; G.bagOpen=false; G.drag=null;   // v14.07, HUD audit: nothing covers the downed screen
    G.searching=null; G.searchT=0; G.nearDoor=null;   // v14.08, HUD audit: no search bar or door prompt frozen over the floor
'@
SubRx @'
  if(G.nearDoor){
    var dsc=w2s(G.nearDoor.doorX,26,G.nearDoor.doorY);
'@ @'
  if(G.nearDoor&&!(G.player&&G.player.downed)){   // v14.08: not while down
    var dsc=w2s(G.nearDoor.doorX,26,G.nearDoor.doorY);
'@
SubRx @'
  if(G.searching){
    var s2=w2s(G.searching.x,26,G.searching.y);
'@ @'
  if(G.searching&&!(G.player&&G.player.downed)){   // v14.08: not while down
    var s2=w2s(G.searching.x,26,G.searching.y);
'@
SubRx @'
var VER='14.07';
'@ @'
var VER='14.08';
'@

$pat = "(?m)^  now:'v14\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.08: GOING DOWN LETS GO OF THE SEARCH AND THE DOOR PROMPT. Raid HUD and map screen audit of 2026-09-15, finding 4: the downed branch returns before the door and container scans, the only places that clear G.nearDoor and G.searching, and going down cleared neither, so the search bar froze on the crate and [E] UNLOCK stayed up for the whole bleed-out. Going down now clears both and neither is drawn while down. Check 14.08 downs the player mid-search beside a door and requires both cleared, with a non-lethal hit leaving the search running as the control; it fails on v14.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
