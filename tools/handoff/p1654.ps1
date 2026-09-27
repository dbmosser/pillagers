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

# THE WHAT IS NEW CARD CATCHES UP: the party features since v16.33 and the stability pass of 2026-09-27.

SubRx @'
var WHATSNEW_VER='16.33';
'@ @'
var WHATSNEW_VER='16.54';
'@

SubRx @'
  'GRENADES, BELT KEYS, STASH, WARDROBE, SAVES AND STORMS.
'@ @'
  'NEW FOR THE PARTY. Every player chooses a kit at the lift. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
  'STEADIER CO-OP. A search keeps running after the host has left the raid, the pause box shuts when a raid ends under it, a controller tap on the map places your marker and shuts the map, a controller can no longer hand itself to the wrong window from the PARTY window, and the buttons in Settings that would drop you out of a raid are greyed out until you are back in the Undercroft.',
  'GRENADES, BELT KEYS, STASH, WARDROBE, SAVES AND STORMS.
'@

SubRx @'
var VER='16.53';
'@ @'
var VER='16.54';
'@

$pat = "(?m)^  now:'v16\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.54: THE WHAT IS NEW CARD CATCHES UP. It was last written at v16.33 and had fallen more than fifteen builds behind. Two lines go in under the co-op line: the party features since then (a kit for every player, ping, map markers on a controller, the kill feed, the teammate arrow, the party on the end of raid card, kid mode and Settings in a raid) and the stability pass before a co-op session. Old checks that tested words the game has since changed on purpose now test the new words. Check 16.54 fails on v16.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
