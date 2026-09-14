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

# RAID HUD AND MAP SCREEN AUDIT OF 2026-09-15, finding 2: AN OPEN MAP OR BACKPACK COVERED THE WHOLE DOWNED SCREEN. Nothing
# closed either panel when he went down, and both draw after the downed overlay: the map's near-opaque fill hid DOWN, the
# bleed seconds and [F] SELF-REVIVE, and the backpack panel sat over the DOWN block with the pointer hidden, so he could bleed
# out not knowing he was down. Going down now closes the map and the backpack, with any drag in hand, as it shuts the stall.
SubRx @'
    p.reloading=0;   // v13.83, combat audit: a reload does not wait on the floor to finish after he stands
'@ @'
    p.reloading=0;   // v13.83, combat audit: a reload does not wait on the floor to finish after he stands
    G.mapOpen=false; G.bagOpen=false; G.drag=null;   // v14.07, HUD audit: nothing covers the downed screen
'@
SubRx @'
var VER='14.06';
'@ @'
var VER='14.07';
'@

$pat = "(?m)^  now:'v14\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.07: GOING DOWN CLOSES THE MAP AND THE BACKPACK. Raid HUD and map screen audit of 2026-09-15, finding 2: nothing closed an open map or backpack when he went down, and both draw after the downed overlay, so the map fill hid DOWN, the bleed seconds and the self-revive prompt and the backpack sat over the DOWN block with the pointer hidden. Going down now closes both, and any drag, as it shuts the stall. Check 14.07 downs the player with the map open and again with the backpack open and requires both closed, with a non-lethal hit leaving the map open as the control; it fails on v14.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
