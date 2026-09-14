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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 5: A DRINK STOPPED WEARING OFF WHILE YOU WERE
# DOWN OR ROLLING. tickBuzz counts each drink down, but updatePlayer called it on the standing
# path, below the downed return and the roll return. Every second on the floor or in a roll
# pushed the effect and its wears-off line back, and an extraction does not clear the drinks,
# so the frozen time came home. v11.83 moved the stim clock above both returns for exactly this
# reason; the drink clock now sits beside it.
SubRx @'
  if(!G.sim) tickBuzz(dt);
  // Once per frame, not once per enemy: 57 bodies each scanning the bush list
'@ @'
  // Once per frame, not once per enemy: 57 bodies each scanning the bush list
'@
SubRx @'
  if(p.stimT>0){ p.stimT-=dt; if(p.stimT<=0){ p.stimT=0; if(!G.sim) say('The stim wears off.'); } }
'@ @'
  if(p.stimT>0){ p.stimT-=dt; if(p.stimT<=0){ p.stimT=0; if(!G.sim) say('The stim wears off.'); } }
  // v13.75, downed audit: the drink clock too. It ticked below the downed and roll returns, so a
  // drink stopped wearing off on the floor and in every roll.
  if(!G.sim) tickBuzz(dt);
'@
SubRx @'
var VER='13.74';
'@ @'
var VER='13.75';
'@

$pat = "(?m)^  now:'v13\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.75: A DRINK KEEPS WEARING OFF WHILE YOU ARE DOWN. Downed and extraction audit of 2026-09-14, finding 5: tickBuzz ran on the standing path of updatePlayer, below the downed and roll returns, so every second on the floor or in a roll pushed a drink and its wears-off line back, and the frozen time came home at an extraction. It now ticks beside the stim clock, which v11.83 moved above both returns for the same reason. Check 13.75 downs the player with a drink running and requires two seconds of frames to take two seconds off it, with the same two seconds standing as the control; it fails on v13.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
