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

# HIS REPORT, 2026-09-12: "ESC still is killing the fullscreen in chrome on itch."
#
# THE GAME PROMISED OTHERWISE. v13.09 added a what is new entry saying Escape no
# longer drops you out of fullscreen in Chrome and Edge. That is true only when the
# game is the top-level page. On itch it is not, and itch is where every friend
# plays, so the promise was false in exactly the place it was read.
#
# WHY IT CANNOT BE MADE TRUE FROM INSIDE THE GAME. fsOn reads the game document
# fullscreen state, but itch fullscreens its OWN page around the frame, so the game
# sees no fullscreen and never asks for the lock. And Chrome grants the keyboard
# lock only to a top-level page, so even fullscreening the game itself inside the
# frame cannot keep Escape. This is a browser rule, not a missing line of code.
#
# THE ENTRY NOW SAYS WHAT IS TRUE and names the key that works everywhere. It does
# NOT suggest F11: that is untested on itch while the page is locked, and a promise
# the game cannot back is the mistake being corrected.
#
# WHATSNEW_VER IS NOT MOVED. This corrects a line below the fold rather than adding
# a change to how he plays, so re-showing the card for it would be a nag.
SubRx @'
  'ESC NO LONGER DROPS YOU OUT OF FULLSCREEN, IN CHROME AND EDGE. A page is not allowed to cancel that key, so the game now asks the browser to hand Escape over while you are fullscreen, which is what the browser built for games like this. Firefox and Safari do not offer it and will still drop out; P pauses in every browser. Holding Escape always leaves fullscreen, so you can never be stuck.',
'@ @'
  'ESC ONLY KEEPS FULLSCREEN WHEN THE GAME HAS ITS OWN TAB, IN CHROME AND EDGE. Played inside another page, such as itch, the browser does not let the game keep that key, so Escape leaves fullscreen there. B backs out of any menu in every browser, and P pauses. Holding Escape always leaves fullscreen, so you can never be stuck.',
'@

SubRx @'
var VER='13.24';
'@ @'
var VER='13.25';
'@

$pat = "(?m)^  now:'v13\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.25: HIS REPORT of 2026-09-12, ESC still kills fullscreen in Chrome on itch. The game promised otherwise: v13.09 added a what is new entry saying Escape no longer drops you out of fullscreen in Chrome and Edge, which is true only when the game is the top-level page, and on itch it is not, and itch is where every friend plays, so the promise was false in exactly the place it was read. It cannot be made true from inside the game: fsOn reads the game document fullscreen state, but itch fullscreens its own page around the frame, so the game sees no fullscreen and never asks for the lock; and Chrome grants the keyboard lock only to a top-level page, so even fullscreening the game itself inside the frame cannot keep Escape. That is a browser rule, not a missing line of code. The entry now says what is true and names the key that works everywhere, B. It does not suggest F11, which is untested on itch while the page is locked, because a promise the game cannot back is the mistake being corrected. WHATSNEW_VER is not moved, since this corrects a line below the fold rather than adding a change to how he plays. Check 13.25 requires no entry to promise Escape keeps fullscreen without the own-tab qualification, and one entry to say what happens inside another page; it fails on v13.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
