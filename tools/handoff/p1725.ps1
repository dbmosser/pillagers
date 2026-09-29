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

# THE WHAT IS NEW CARD NAMES THE MENU AND STASH FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.09';
'@ @'
var WHATSNEW_VER='17.25';
'@

SubRx @'
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@ @'
  'STEADIER MENUS AND STASH. A plain click on a gun in your armoury leaves it there, a controller can put a gun in gun 1 or gun 2 from the stash (press A twice on the gun), an item on belt key 1 no longer buries your gun, and ESC or TAB on Settings in a raid shuts Settings only. A hire you paid for is spent at the lift, and the game open in two tabs no longer wipes what the other tab saved.',
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@

SubRx @'
var VER='17.24';
'@ @'
var VER='17.25';
'@

$pat = "(?m)^  now:'v17\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.25: THE WHAT IS NEW CARD NAMES THE MENU AND STASH FIXES. One line goes in under the playtest line naming the menu, stash, belt, Settings, hire and two-tab fixes of v17.15 to v17.24, and the stamp moves to this build. Check 17.25 fails on v17.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
