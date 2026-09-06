$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Adds the harness-repair paragraph to the v11.77 entry already in DESIGN.md
# (and to the d1177 draft), before its "Not verified:" line.
$para = @'
A HARNESS REPAIR IN THE SAME BUILD. The first cut of this check handed the
loader a bare profile and left it there: the loader replaces the profile with
what it is given, and the fixture's clean-up keeps what it finds rather than
rebuilding, so every later check that leans on the profile lost its stash,
its weapons and its seventeen cosmetic fields. Three corpus runs went red on
three different checks (8.72 belt to stash, 10.34 and 10.33 sprite
cosmetics), one each, which is the signature of a poisoned profile and not
of a broken build. The check now snapshots the clean profile after its own
clean-up and puts it back through the real loader at the end.

'@
foreach ($f in @('C:\claudecode\dark raiders\DESIGN.md', 'C:\claudecode\dark raiders\tools\handoff\d1177.txt')) {
  $s = [IO.File]::ReadAllText($f)
  $anchor = 'Not verified: his own play, and whether these are the numbers he wants, which'
  $c = ([regex]::Matches($s, [regex]::Escape($anchor))).Count
  if ($c -ne 1) { throw "anchor matched $c times in $f" }
  $nl = if ($s.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }
  $s = $s.Replace($anchor, $para.Replace("`r`n", "`n").Replace("`n", $nl) + $anchor)
  [IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
  Write-Output ("amended: " + $f)
}
