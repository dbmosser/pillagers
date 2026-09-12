$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\lint.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE SAME THREE HITS EVERY RUN, AND ALL THREE ARE CLEARED. Class D has named
# useMedical, cycleThrow and doEmote on every run since it was written. I read all
# three at v12.84 and all three are mutually exclusive branches with early returns,
# so nothing is overwritten. A count that never moves is a count nobody reads, and a
# lint whose whole output is known noise stops being a lint.
#
# THEY ARE NOT SUPPRESSED. The detection is untouched, because narrowing it to spot an
# early return would trade a false alarm for a false SILENCE, and a defect hunter that
# goes quiet is worse than one that repeats itself. Instead the report separates what
# has been read from what has not, and the headline count is the unread one, so it
# moves only when something new appears.
#
# A CLEARED ENTRY CARRIES THE BUILD IT WAS CLEARED AT. If one of these functions is
# rewritten later, the note is there to say what was true when it was read, and the
# next reader can decide it needs reading again.
SubRx @'
$dHits = 0
Say '## D. a message written inside a loop and overwritten after it'
Say ''
'@ @'
$dHits = 0
$dSeen = 0
# READ AND CLEARED, with the build it was read at. Class D cannot tell a say() that is
# followed by an early return from one that is not, and these three are all early
# returns in branches that cannot both run.
$dCleared = @{
  'useMedical' = 'v12.84: mutually exclusive branches with early returns, nothing is overwritten';
  'cycleThrow' = 'v12.84: mutually exclusive branches with early returns, nothing is overwritten';
  'doEmote'    = 'v12.84: mutually exclusive branches with early returns, nothing is overwritten'
}
Say '## D. a message written inside a loop and overwritten after it'
Say ''
'@

SubRx @'
  if ($closes.Groups[1].Value -match 'say\(') {
    $dHits++
    Say ("  line " + (LineOf $fm.Index) + " : " + $fname + " says something inside a loop and says something else after it")
  }
}
Say ''
'@ @'
  if ($closes.Groups[1].Value -match 'say\(') {
    $dSeen++
    if ($dCleared.ContainsKey($fname)) {
      Say ("  (cleared) line " + (LineOf $fm.Index) + " : " + $fname + " - " + $dCleared[$fname])
    } else {
      $dHits++
      Say ("  line " + (LineOf $fm.Index) + " : " + $fname + " says something inside a loop and says something else after it")
    }
  }
}
Say ''
Say ("  " + $dSeen + " found, " + ($dSeen - $dHits) + " already read and cleared, " + $dHits + " to read")
Say ''
'@

SubRx @'
Write-Output ('LINT  dials-never-read=' + $aHits + '  banned-words=' + $bHits + '  unstamped-migrations=' + $cHits + '  overwritten-lines=' + $dHits)
'@ @'
Write-Output ('LINT  dials-never-read=' + $aHits + '  banned-words=' + $bHits + '  unstamped-migrations=' + $cHits + '  overwritten-lines=' + $dHits + ' (' + ($dSeen - $dHits) + ' cleared)')
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
