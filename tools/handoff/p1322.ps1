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

# THE WHAT IS NEW CARD HAD ROTTED AGAIN, the third time in the class the memory
# names: WHATSNEW_VER is not enforced, so it sat at 13.10 through twelve builds,
# and five of them change how he plays.
#
# ONLY LINES THAT CHANGE HOW HE PLAYS, the card own rule, never fixes. So B
# backing out, the found plate going to the backpack, X searching, the offer
# selling once, and the refused roll speaking. The medical line on the death card
# and the Copy report repairs are fixes and stay off it.
#
# MOST IMPORTANT FIRST, because the card shows only the top entries that fit the
# screen and cuts at the last whole one. B is first: it is the key he was given
# because Escape is not working for him, and a key nobody is told about does not
# exist.
#
# AND ONE OLD ENTRY WAS NOW FALSE. It said the X key is gone and that X is still
# search only on a controller; since v13.10 X searches on the keyboard too. It is
# below the fold and never drawn, but a list that contradicts the controls is
# wrong wherever it is read, and no check keys on its text.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'PRESS B TO BACK OUT OF ANY MENU. It closes whatever is in front, one thing per press, in the Undercroft and on the surface. With nothing open it still gives your hire his orders, and it never opens the pause box.',
  'AN ARMOUR PLATE YOU FIND GOES IN YOUR BACKPACK. It no longer snaps onto your armour when you pick it up: select it on your tactical belt and use it, which takes two seconds, or carry it home.',
  'X SEARCHES WHAT YOU ARE STANDING ON, even inside an extraction point, where E is the key that calls for extraction.',
  'THE LIMITED TIME OFFER SELLS ONCE. Buy it and the counter stays empty until the next offer arrives.',
  'A ROLL WITH NO STAMINA LEFT SAYS SO. A roll costs almost half the bar, so the third in a row is refused, and it used to fail without a word.',
'@

SubRx @'
  'X NO LONGER SWAPS WEAPONS. The tactical belt does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@ @'
  'X NO LONGER SWAPS WEAPONS. The tactical belt does that job, and X searches what you are standing on instead, on a keyboard and on a controller. Your stowed gun and its ammo are still shown, just without a key in front of them.',
'@

SubRx @'
var WHATSNEW_VER='13.10';
'@ @'
var WHATSNEW_VER='13.22';
'@

SubRx @'
var VER='13.21';
'@ @'
var VER='13.22';
'@

$pat = "(?m)^  now:'v13\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.22: THE WHAT IS NEW CARD HAD ROTTED AGAIN, the third time in the class the memory names, because WHATSNEW_VER is not enforced: it sat at 13.10 through twelve builds while five of them changed how he plays, and parsecheck calls a drift of 0.11 fine and only flags STALE past 0.20, so it would not have caught this for another ten builds. Only lines that change how he plays go on the card, which is its own rule, so the medical line on the death card and the Copy report repairs are fixes and stay off it. Five lines, most important first, because the card shows only the top entries that fit the screen and cuts at the last whole one: B backs out of any menu, first, because it is the key he was given since Escape is not working for him and a key nobody is told about does not exist; a found armour plate goes to the backpack; X searches what you stand on; the Limited Time Offer sells once; a refused roll says so. And one old entry was now false, saying the X key is gone and that X is still search only on a controller, while since v13.10 X searches on the keyboard too; it sits below the fold and is never drawn, but a list that contradicts the controls is wrong wherever it is read, and no check keys on its text. Check 13.22 requires the stamp to be no older than the oldest change it lists, requires B and the plate to sit high enough to be drawn, and requires that no entry still claims the X key is gone; all three fail on v13.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
