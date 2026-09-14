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

SubRx @'
  if(b.dataset.armed){ P.log=[]; P.lastSim=null; delete b.dataset.armed; b.textContent='Clear recorder'; saveProfile(); renderHub();
'@ @'
  // v14.50, report audit finding 6: CLEAR RECORDER CLEARS THE CRASHES AND FLOOR NOTES TOO. It emptied the run log and the last
  // sim, but the fresh report still listed every old crash, and floor notes for runs that were gone: the old fault read as
  // a live one, the mistake the v1.90 note warns about.
  if(b.dataset.armed){ P.log=[]; P.lastSim=null; P.crashes=[]; P.floorNotes=[]; delete b.dataset.armed; b.textContent='Clear recorder'; saveProfile(); renderHub();
'@
SubRx @'
var VER='14.49';
'@ @'
var VER='14.50';
'@

$pat = "(?m)^  now:'v14\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.50: CLEAR RECORDER CLEARS OLD CRASHES AND FLOOR NOTES TOO. It emptied the run log, but the fresh report still listed every old crash and floor notes for runs that were gone, so an old fault read as a live one. Both are now cleared with the log. Check 14.50 clicks Clear recorder twice with an old crash and an old floor note in place; it fails on v14.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
