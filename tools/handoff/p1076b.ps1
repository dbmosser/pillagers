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

# ==== THE CORPUS CAUGHT ME, AND IT WAS RIGHT. The WHAT IS NEW card was still at
# ==== v10.61 against a build at v10.76, so a friend opening the game on Saturday
# ==== would read news fifteen builds old. I have been updating the DEVNOW line
# ==== every build and never the card, which is a different field with a
# ==== different rule: WHATSNEW_VER moves only when the list itself changes, so
# ==== it does not nag, and the price of that is remembering to move it when the
# ==== list DOES change. Exactly the failure v10.60 had at fifteen builds stale.
# ==== The seven lines below are the player-facing half of v10.62 to v10.76.
SubRx @'
var WHATSNEW_VER='10.61';
'@ @'
var WHATSNEW_VER='10.76';
'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CARD AT THE END OF A RAID HAS A COPY REPORT BUTTON. It puts that raid and every raid before it on your clipboard, ready to paste straight to Daniel. That is the fastest way to get anything fixed.',
  'A GUN YOU FIND GOES INTO YOUR EMPTY SLOT, not over the gun in your hands. You carry two; a find fills the free one and leaves your choice alone. With both slots full the gun you are holding is still the one it replaces.',
  'F IS A MELEE STRIKE, with whatever you are holding, gun or fists. It is in both controls lists.',
  'FIRST TIME OUT IS A REAL BRIEFING NOW. A new character reads it instead of having it painted over by the welcome pack, and the card says how many of its eighteen pages are still below the fold.',
  'THE SAFE POCKET TELLS YOU THE TRUTH. It only saves the item it names if you are actually carrying it, and it says NOT PACKED when you are not, on the stash screen and on the ascent check.',
  'THE END OF RAID CARD COUNTS THE GUN YOU LOST, in the number and in the money. A loaner is in neither, because you never owned it. The two buttons at the bottom stay on screen however long the ledger runs.',
  'THE TITLE SCREEN USES THE WHOLE MONITOR, and the ten stash layouts have their picker back, in Settings beside the text size.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
