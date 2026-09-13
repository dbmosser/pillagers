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

# THE WHAT-IS-NEW CARD NEVER SAID THE WELCOME PACK NOW GOES TO THE STASH.
#
# His ruling of 2026-09-13 (v13.29) sent the whole welcome pack to the stash, guns as
# items, with nothing equipped. v13.31 and v13.32 then taught the sector page and the
# raid to say so. None of it reached the what-is-new card: its stamp still reads 13.22,
# so a friend coming back is shown nothing new, and the entry about the pack (v10.29)
# sits far below where the card stops drawing and says nothing about the stash.
#
# ONE LINE, drawn: inserted right after the X line, as entry 5. Check 13.22 keeps B
# within the first three entries and the plate line within four, and both stay where
# they are. The card draws thirteen entries at the default text size (measured,
# START-HERE). The stamp moves to 13.34 so the card is shown again.
SubRx @'
  'X SEARCHES WHAT YOU ARE STANDING ON, even inside an extraction point, where E is the key that calls for extraction.',
'@ @'
  'X SEARCHES WHAT YOU ARE STANDING ON, even inside an extraction point, where E is the key that calls for extraction.',
  'THE WELCOME PACK GOES TO YOUR STASH AND EQUIPS NOTHING. Both guns wait there as items: open your stash and choose Equip as your gun on one. Until you do, the lift issues you a loaner, and the sector page and the raid both say so.',
'@

SubRx @'
var WHATSNEW_VER='13.22';
'@ @'
var WHATSNEW_VER='13.34';
'@

SubRx @'
var VER='13.33';
'@ @'
var VER='13.34';
'@

$pat = "(?m)^  now:'v13\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.34: THE WHAT-IS-NEW CARD NEVER SAID THE WELCOME PACK NOW GOES TO THE STASH. His ruling of 2026-09-13 sent the whole welcome pack to the stash, guns as items, with nothing equipped, and v13.31 and v13.32 taught the sector page and the raid to say so. None of it reached the card: its stamp still read 13.22, so a friend coming back was shown nothing new, and the old entry about the pack sits far below where the card stops drawing and never mentions the stash. One line now, inserted right after the X line as entry 5, inside the thirteen the card draws, with B and the plate line left where check 13.22 keeps them; the stamp moves to 13.34 so the card is shown again. Check 13.34 requires the stamp to be no older than the stash ruling, and an entry within the drawn thirteen that says the pack goes to the stash and names Equip as your gun, and fails on v13.33. The same build gives check 13.32 the pane guard 13.33 already has, so a pane with no layout skips instead of throwing',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
