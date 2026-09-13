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

# A CONTROLLER COULD NOT CROUCH.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics, reproduced live on
# v13.34 with a stubbed navigator.getGamepads: RS click held 8 frames set
# keys.ControlLeft (the pad reached the game; the left stick also moved the player 53
# units) and G.crouchTog stayed false, while keyboard Ctrl toggles it.
#
# Both controller key lists say RS click crouches. RS click sat in PADHOLD, which only
# sets a held key, and nothing reads keys.ControlLeft: crouch has been a toggle since
# v10.07, flipped only inside raidKey, and read through crouchHeld from G.crouchTog.
#
# FIX: button 11 moves from PADHOLD to PADTAP, so its press goes through raidKey, the
# handler Ctrl and C use; holding it is one change, because PADTAP is edge-detected
# through PAD.prev. The left stick click stays a held sprint. No words, labels or
# numbers change. This block has plain LF line endings and the new text keeps them.
SubRx @'
  15:'KeyG'       // Dpad right  use the selected belt slot (was autoloot, v6.79)
};
var PADHOLD={
  // A is the trigger now, v6.89, so search moves across and reload moves with it.
  2:'KeyE',       // X      search, and hold to call the dropship
  3:'KeyR',       // Y      reload
  13:'KeyF',      // Dpad down   use medical
  10:'ShiftLeft', // LS click    sprint
  11:'ControlLeft'// RS click    crouch
};
'@ @'
  15:'KeyG',      // Dpad right  use the selected belt slot (was autoloot, v6.79)
  // v13.36, audit 2026-09-13: RS click is raised on the press. Crouch has been a
  // toggle flipped only inside raidKey since v10.07, and nothing reads the held
  // key, so while RS sat in PADHOLD it set a key no code looked at and a controller
  // could not crouch at all, under two controller key lists that say RS crouches.
  11:'ControlLeft'// RS click    crouch, one change per click
};
var PADHOLD={
  // A is the trigger now, v6.89, so search moves across and reload moves with it.
  2:'KeyE',       // X      search, and hold to call the dropship
  3:'KeyR',       // Y      reload
  13:'KeyF',      // Dpad down   use medical
  10:'ShiftLeft'  // LS click    sprint (held: updatePlayer reads the key itself)
};
'@

SubRx @'
var VER='13.35';
'@ @'
var VER='13.36';
'@

$pat = "(?m)^  now:'v13\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.36: A CONTROLLER COULD NOT CROUCH. Found by a read-only hunt, confirmed by two skeptics and reproduced live on v13.34 with a faked controller: holding the right stick click set the held key and moved nothing, the left stick still moved the player, and crouch never changed, while keyboard Ctrl toggles it. Both controller key lists say the right stick click crouches. The click sat in the table of held buttons, which only sets a key, and no code reads that key: crouch has been a toggle since v10.07, flipped only by the key handler. The click now sits in the table of pressed buttons, so it goes through the same handler as Ctrl and C; holding it is one change, and the left stick click stays a held sprint. No words, labels or numbers change. Check 13.36 fakes a controller, confirms the left stick click still reaches the raid, then requires one click to crouch, a held click to change the stance once, a third click to crouch again, a crouched walk on the stick to be slower, and keyboard C to still work; it fails on v13.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
