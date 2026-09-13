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

# A BOX SEARCHED ON THE HOT GROUND: THE BONUS LINE WAS WRITTEN OVER BY THE FOUND LINE IN
# THE SAME CALL.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics, reproduced live on
# v13.34: a box 238 units from the hot zone centre (radius 620) gained two bonus items and
# the only line shown was "Found: Circuit Board, Armour Plate".
#
# openContainer pushes two bonus items and says the hot ground line, then grantLoot in
# the same call says the Found line over it. Routing the line through sayWhenFree in
# place would work only while a Took line happens to be showing, so the line is kept
# where it is built and said through sayWhenFree just after the grant, when the Found
# line is showing, so it waits behind it. No loot, odds, wording or numbers change, and
# in the sim the line is empty as before. The game file here has plain LF line endings
# and the new lines keep them (the plan note calling it CRLF was stale; its reviewer
# measured it).
SubRx @'
      if(!G.sim) say('Hot ground. There is more in here than there should be.');
'@ @'
      // v13.40: KEPT HERE, SAID AFTER THE GRANT BELOW. grantLoot writes the Found line in
      // this same call and say() holds one line, so said here it was never on screen.
      var _hotLine=G.sim?'':'Hot ground. There is more in here than there should be.';
'@

SubRx @'
  grantLoot(ct,ct.loot,_wnDelay);
'@ @'
  grantLoot(ct,ct.loot,_wnDelay);
  // v13.40: the Found line is showing now, so the hot ground line waits its turn behind it
  // instead of lying under it. Declared in the hot zone block above; undefined elsewhere.
  if(_hotLine) sayWhenFree(_hotLine);
'@

SubRx @'
var VER='13.39';
'@ @'
var VER='13.40';
'@

$pat = "(?m)^  now:'v13\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.40: THE HOT GROUND BONUS LINE WAS WRITTEN OVER BY THE FOUND LINE. Found by a read-only hunt, confirmed by two skeptics and reproduced live on v13.34: a box inside the hot zone gained its two bonus items and the only line on screen was the Found line. Opening the box pushed the bonus items and said Hot ground, then the grant in the same call said the Found line over it. The line is now kept where it is built and said through sayWhenFree just after the grant, while the Found line shows, so it follows when that runs out; saying it through sayWhenFree in place would only work while a Took line happened to be showing. No loot, odds, wording or numbers change, and the sim is untouched. Check 13.40 moves the hot ground onto an ordinary box, holds X beside it through the frame loop until it opens, confirms the bonus was paid and the Found line showed, requires the hot ground line on screen exactly once, and requires a box off the hot ground never to say it; it fails on v13.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
