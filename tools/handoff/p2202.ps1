$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A LATE JOINER IS TIMED FROM WHEN HE CAME UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ck==='swift') return elapsed()<=180;
'@ @'
  // v22.02, from the whole-game bug hunt of 2026-10-08 (K12): A LATE JOINER IS TIMED FROM WHEN HE CAME UP. A teammate who joins a
  // raid in progress takes the host clock (netLateApply), so elapsed() counts the minutes before he came up. v17.64 moved his run
  // length and his abandon fee to runElapsed(), but four places still read the host clock: this contract, the abandon confirm,
  // the instant quit test and the time on his run card. All four read his own time now. For anyone who did not join late the
  // two clocks are the same, so solo and a party that went up together are unchanged.
  if(ck==='swift') return runElapsed()<=180;
'@

SubRx @'
  var el=elapsed();
  if(how==='abandon'&&el<1.5
'@ @'
  var el=runElapsed();   // v22.02 (K12): his own time, so a late joiner who quits at once is an instant quit
  if(how==='abandon'&&el<1.5
'@

SubRx @'
  var _tsec=Math.round(elapsed()), _tm=
'@ @'
  // v22.02 (K12): the time on the card is his own, as the run record (dur) already is
  var _tsec=Math.round(runElapsed()), _tm=
'@

SubRx @'
  if(G&&!G.over&&elapsed()>60){
'@ @'
  if(G&&!G.over&&runElapsed()>60){   // v22.02 (K12): his own time, as the button label says (free this early)
'@

SubRx @'
var VER='22.01';
'@ @'
var VER='22.02';
'@

$pat = "(?m)^  now:'v22\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.02: In co-op, a teammate who joins late is timed from when he came up, for contracts, the abandon fee and his run card. Check 22.02 fails on v22.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
