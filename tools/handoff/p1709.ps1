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

# THE WHAT IS NEW CARD NAMES THE TWO-PLAYER FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='16.88';
'@ @'
var WHATSNEW_VER='17.09';
'@

SubRx @'
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@ @'
  'STEADIER TWO-PLAYER GAMES ON ONE PC. A key held in one window is let go when you click the other, ESC in the player 2 window no longer pauses player 1, and a click in one window never shuts the backpack of the other player. Kid mode at 1/20 really gives player 2 a twentieth of every hit, letting go of the right stick ends aiming so Superhot time stops and kid firing comes back, a downed controller player calls for extraction with X, and a heal your teammate could not take comes back to your backpack. Kills go to whoever made them, and a gun or a loaner Bandage handed between players is never kept by both.',
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@

SubRx @'
var VER='17.08';
'@ @'
var VER='17.09';
'@

$pat = "(?m)^  now:'v17\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.09: THE WHAT IS NEW CARD NAMES THE TWO-PLAYER FIXES. The card was stamped v16.88, twenty builds behind, and the parse check refuses a card that far back. One line goes in under the playtest line naming the two-player fixes of v16.92 to v17.08, and the stamp moves to this build. Check 17.09 fails on v17.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
