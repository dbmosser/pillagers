$ErrorActionPreference = 'Stop'
# PILLAGERS LINT. Written 2026-09-09 so the machine hunts the defect classes I
# have had to find by hand, over and over, one instance at a time.
#
# It prints COUNTS ONLY. Everything it finds goes to tools/lint-report.txt, so a
# run costs almost nothing to read and the detail is there when a count moves.
# Run it after any build: powershell -File tools/lint.ps1
$g = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($g)
$lines = $s -split "\r?\n"
$out = New-Object Collections.ArrayList
function Say([string]$t) { [void]$out.Add($t) }
function LineOf([int]$idx) { return ($s.Substring(0, $idx) -split "\r?\n").Count }

Say '# PILLAGERS LINT REPORT'
Say ''

# ---------------------------------------------------------------- CLASS A
# A SETTINGS DIAL THAT NOTHING READS. Memory: a floor outranks the menu, and a
# dial written but never read is a row in Settings that does nothing at all.
$aHits = 0
$cfgM = [regex]::Match($s, '(?s)var CFG=\{(.*?)\n\};')
if (-not $cfgM.Success) { $cfgM = [regex]::Match($s, '(?s)var CFG=\{(.*?)\};') }
Say '## A. dials defined but never read'
Say ''
if ($cfgM.Success) {
  $body = $cfgM.Groups[1].Value
  $keys = [regex]::Matches($body, '([A-Za-z_][A-Za-z0-9_]*)\s*:') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
  foreach ($k in $keys) {
    $reads = ([regex]::Matches($s, 'CFG\.' + [regex]::Escape($k) + '(?![A-Za-z0-9_])')).Count
    $bracket = ([regex]::Matches($s, "CFG\[\s*'" + [regex]::Escape($k) + "'\s*\]")).Count
    if ($reads -eq 0 -and $bracket -eq 0) { $aHits++; Say ("  " + $k + " : defined in the defaults and read nowhere") }
  }
} else { Say '  (could not find the CFG defaults object)' }
Say ''

# ---------------------------------------------------------------- CLASS B
# HIS VOCABULARY, IN PROSE HE CAN READ. Only long prose strings are scanned, so
# identifiers like mkRaider and raiderFeud do not drown the real hits. This is
# the general version of the check I drafted too narrowly at v12.48, which
# asserts three words and would have shipped green over the word cash.
$bHits = 0
$banned = @('cash','hotbar','touchdown','boarding','bag','standing','tier')
Say '## B. banned vocabulary in prose the player can read'
Say ''
foreach ($m in [regex]::Matches($s, "'([^'\\\r\n]{30,400})'")) {
  $t = $m.Groups[1].Value
  if (($t -split ' ').Count -lt 5) { continue }
  if ($t -notmatch '[a-z]{3} [a-z]{3}') { continue }
  foreach ($w in $banned) {
    if ($t -match ('(?i)(^|[^A-Za-z])' + $w + '($|[^A-Za-z])')) {
      $bHits++
      Say ("  line " + (LineOf $m.Index) + " [" + $w + "] " + $t.Substring(0, [Math]::Min(150, $t.Length)))
      break
    }
  }
}
Say ''

# ---------------------------------------------------------------- CLASS C
# A MIGRATION A NEW PROFILE STILL MEETS. This is exactly v12.43: a repair meant
# for old saves runs once on a brand new one and silently takes something.
# Rule: a one-shot guard that stamps itself must have that stamp in the literal
# a new profile is born from.
$cHits = 0
Say '## C. one-shot migrations missing from the born profile'
Say ''
$bornM = [regex]::Match($s, '(?s)var P=\{credits:(.*?)\};')
if ($bornM.Success) {
  $born = $bornM.Groups[0].Value
  foreach ($m in [regex]::Matches($s, 'if\(!P\.([A-Za-z0-9_]+)\)')) {
    $n = $m.Groups[1].Value
    # freeKit stamps itself the same way but is a GAME ACTION, not a repair: a
    # new player has correctly NOT taken the kit, so it must not be born set.
    if ($n -eq 'freeKit') { continue }
    $win = $s.Substring($m.Index, [Math]::Min(400, $s.Length - $m.Index))
    if ($win -match ('P\.' + [regex]::Escape($n) + '=1(?![0-9])')) {
      if ($born -notmatch ([regex]::Escape($n) + '\s*:')) {
        $cHits++
        Say ("  line " + (LineOf $m.Index) + " : " + $n + " stamps itself but a new profile is not born with it")
      }
    }
  }
} else { Say '  (could not find the born profile literal)' }
Say ''

# ---------------------------------------------------------------- CLASS D
# A LINE WRITTEN AND THEN WRITTEN OVER IN THE SAME BREATH. This is v12.73: the
# message line holds exactly one string, so a say() inside a loop followed by an
# unconditional say() after it can never be read.
$dHits = 0
Say '## D. a message written inside a loop and overwritten after it'
Say ''
foreach ($fm in [regex]::Matches($s, '(?s)\nfunction ([A-Za-z0-9_]+)\([^)]*\)\{(.{0,9000}?)\n\}')) {
  $fname = $fm.Groups[1].Value
  $bodyF = $fm.Groups[2].Value
  $loopAt = [regex]::Match($bodyF, '(?s)for\s*\(.*?say\(')
  if (-not $loopAt.Success) { continue }
  $tail = $bodyF.Substring($loopAt.Index + $loopAt.Length)
  $closes = [regex]::Match($tail, '(?s)\n  \}(.*)$')
  if (-not $closes.Success) { continue }
  if ($closes.Groups[1].Value -match 'say\(') {
    $dHits++
    Say ("  line " + (LineOf $fm.Index) + " : " + $fname + " says something inside a loop and says something else after it")
  }
}
Say ''

Say ('TOTALS  A=' + $aHits + '  B=' + $bHits + '  C=' + $cHits + '  D=' + $dHits)
[IO.File]::WriteAllText('C:\claudecode\dark raiders\tools\lint-report.txt', ($out -join "`r`n"), (New-Object Text.UTF8Encoding $false))
Write-Output ('LINT  dials-never-read=' + $aHits + '  banned-words=' + $bHits + '  unstamped-migrations=' + $cHits + '  overwritten-lines=' + $dHits)
Write-Output 'detail: tools/lint-report.txt'
