$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\AUDIT.md'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
| STILL OPEN, from v10.40: niches plugged by furniture | OPEN |
'@ @'
| STILL OPEN, measured at v10.68: two fifths of the briefing is below the fold | OPEN | measured on the REAL game at 1920x1080 from an empty browser, not on a fixture. FIRST TIME OUT holds 18 cards in 1558 pixels inside a 912 pixel box: 11 are on screen and SEVEN ARE NOT. The scrollbar is 5 pixels wide and nothing anywhere says there is more, so a new player has no reason to think the card continues. What is hidden: the Undercroft radio, the Pillbox that never chases you, arranging the HUD, THE BULWARK AND ITS SLAB, contracts that judge how you played, junk building the Mainframe, and Settings being a station. The three the card itself calls the ones that get people killed are all above the fold, and so is calling extraction, so this is not fatal; the Bulwark card is the one that costs a life. Two columns does NOT fix it: halving the width roughly doubles each card's height. The fix is a cue that names how many are below plus a scrollbar wide enough to see. Not built yet |
| STILL OPEN, from v10.40: niches plugged by furniture | OPEN |
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
