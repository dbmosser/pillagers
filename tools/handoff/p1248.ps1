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

# FOUND BY MY OWN SLIP, 2026-09-08. I wrote a never-word into a player-facing
# line in a draft, caught it, and then swept the card it would have joined. His
# vocabulary order of 2026-09-02 is explicit: extraction for all of it, never
# ship, never boarding, never touchdown, because he never said the extraction
# was a vehicle. The belt has been the tactical belt since v10.26.
#
# Every spoken line and every drawn line in the game is already clean; I swept
# both. The what is new card is not, in five places, and it is a card he reads.
# Four of them use the banned words as ordinary current vocabulary. The lines
# that ANNOUNCE a rename quote the old word on purpose and are left alone.
SubRx @'
  'A HOLD YOU STARTED BEFORE THE EXTRACTION WINDOW SHUT FINISHES: keep holding E and the ship waits for you; let go and it is gone.',
'@ @'
  'A HOLD YOU STARTED BEFORE THE EXTRACTION WINDOW SHUT FINISHES: keep holding E and the extraction waits for you; let go and it is gone.',
'@
SubRx @'
  'THE BOARDING WINDOW SAYS EXTRACT NOW. It used to say EXTRACTION IN PROGRESS, which reads as something happening without you rather than the one moment you have to be in the ring holding E.',
'@ @'
  'THE EXTRACTION WINDOW SAYS EXTRACT NOW. It used to say EXTRACTION IN PROGRESS, which reads as something happening without you rather than the one moment you have to be in the ring holding E.',
'@
SubRx @'
  'A MERC WHO GETS OUT BEFORE YOU NOW PAYS YOUR CUT. If the man you hired ran low, fled and boarded an earlier ship, the card used to say he was left out there and paid nothing. He is remembered now, and if you both get out you take your ten percent.',
'@ @'
  'A MERC WHO GETS OUT BEFORE YOU NOW PAYS YOUR CUT. If the man you hired ran low, fled and took an earlier extraction, the card used to say he was left out there and paid nothing. He is remembered now, and if you both get out you take your ten percent.',
'@
SubRx @'
  'EVERY NOISE YOU CAN HEAR BUT NOT SEE DRAWS ITS RING. Four never did: the storm telegraph and the extraction pulse, touchdown and last call. They do now.',
'@ @'
  'EVERY NOISE YOU CAN HEAR BUT NOT SEE DRAWS ITS RING. Four never did: the storm telegraph and the extraction pulse, the arrival and last call. They do now.',
'@
SubRx @'
  'X NO LONGER SWAPS WEAPONS. The hotbar does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@ @'
  'X NO LONGER SWAPS WEAPONS. The tactical belt does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@

# NEW IN.
SubRx @'
  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER IT WILL NOT TAKE. With an extraction waiting on the point you are lying in, the space bar is refused on purpose so a resting hand cannot throw away a full backpack. It now says so instead of printing a dead prompt.',
'@ @'
  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER IT WILL NOT TAKE. With an extraction waiting on the point you are lying in, the space bar is refused on purpose so a resting hand cannot throw away a full backpack. It now says so instead of printing a dead prompt.',
  'ONE WORD PER THING, ON THIS CARD TOO. Five older entries here still used words you retired: the extraction called a vehicle in three places, and the tactical belt called by its old name in one. They use your words now, and a check holds the whole card to the list from here on.',
'@

# STAMPS.
SubRx @'
var VER='12.47';
'@ @'
var VER='12.48';
'@
SubRx @'
var WHATSNEW_VER='12.47';
'@ @'
var WHATSNEW_VER='12.48';
'@
$cnt=([regex]::Matches($s,"now:'v12\.47:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.47 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.47:[^']*'",{ param($m) "now:'v12.48: found by my own slip on 2026-09-08. I wrote a retired word into a player-facing line in a draft, caught it, and then swept the card it would have joined. His vocabulary order of 2026-09-02 is explicit and I have broken it in five places on the what is new card, which is a card he reads: the extraction is named as a vehicle in three entries, the arrival by a word he retired in a fourth, and the tactical belt by its old name in a fifth. Every spoken line and every drawn line in the game is already clean, both swept for this build; the card was not. The entries that ANNOUNCE a rename quote the old word on purpose and are left exactly as they are. Check 12.48 reads the card back from the game and holds every line to the list: none may name the extraction as a vehicle or use the retired arrival word, a line may only use the old name for the belt if it is the entry announcing that rename, and the same for the backpack, with a control requiring the rename entries themselves to still be present so deleting them cannot pass; fails on v12.47.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
