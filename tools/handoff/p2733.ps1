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

# ALERTS HAVE A STING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function alertShow(m,k,o,now){
'@ @'
// v27.33 (alert2), HIS ORDER (2026-10-14): the alert lane is "one at a time, short, with its sting". An alert had its callers' own sounds,
// and a good many had none, so a siege, a clock warning or an event could come in without a sound at all. Each alert that takes the lane
// now plays a short sting of its rank on the sting bus (the same bus as the medals): a low double pulse for a crit, two falling square
// notes for a warn, two rising triangle notes for an extraction or good news. Quiet, and under any sound the caller has. An alert
// refreshed in place, or the same line said again, takes the lane once and stings once. Sound only: no state moves.
var ALERTSND={
  crit:[[0,196,196,0.1,'sawtooth',0.035],[0.12,196,196,0.1,'sawtooth',0.035],[0.24,147,147,0.3,'sawtooth',0.04]],
  warn:[[0,330,330,0.09,'square',0.022],[0.1,262,262,0.2,'square',0.022]],
  ext:[[0,659,659,0.08,'triangle',0.03],[0.07,880,880,0.18,'triangle',0.03]]
};
function alertSting(k){ if(!G||G.sim||!ALERTSND[k]) return false; return styTone(ALERTSND[k]); }
function alertShow(m,k,o,now){
  try{ alertSting(k); }catch(_asg){}   // v27.33 (alert2): its sting
'@

SubRx @'
var VER='27.32';
'@ @'
var VER='27.33';
'@

$pat = "(?m)^  now:'v27\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.33: Each alert that takes the lane now plays a short sting of its rank. Check 27.33 fails on v27.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
