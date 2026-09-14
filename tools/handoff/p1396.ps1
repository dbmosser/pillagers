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

# MACHINE AND PILLAGER AI AUDIT OF 2026-09-14, finding 1: YOUR HIRE CAUGHT IN AN ENEMY CHARGE STARTED HUNTING
# YOU. explodeFrag turns every survivor in the blast into a chaser, and since v13.69 only your own charge
# skips your hire. An enemy pillager's charge going off near him set him to chase, nothing on a hire ever
# puts him back, and the pillager chase branch treats him as a pillager hunting the player: he fired at you
# every cycle, threw his own charges at you if his bag held one, and dropped his LOOT or HOLD order. A
# blast no longer stands your hire up into a chaser, whoever threw it; he keeps the damage.
SubRx @'
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed){
'@ @'
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed&&!e.merc){   // v13.96, AI audit: a blast never turns your hire on you
'@
SubRx @'
var VER='13.95';
'@ @'
var VER='13.96';
'@

$pat = "(?m)^  now:'v13\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.96: AN ENEMY CHARGE DOES NOT TURN YOUR HIRE ON YOU. Machine and pillager AI audit of 2026-09-14, finding 1: explodeFrag sets every survivor in the blast to chase, and only your own charge skipped your hire, so an enemy pillager charge near him set him chasing, nothing put a hire back, and the pillager chase branch had him fire at you and throw his own charges at you while dropping his orders. A blast now never stands your hire up into a chaser; he keeps the damage. Check 13.96 bursts an enemy charge beside your hire and requires him not chasing, with an ordinary pillager beside the same blast chasing as the control; it fails on v13.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
