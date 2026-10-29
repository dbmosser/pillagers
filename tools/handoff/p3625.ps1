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

# ACTIVE RELOAD: 5% A STACK, 15% AT MOST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var AR_A=0.42, AR_B=0.60, AR_BONUS=1.15;
// v35.xx (cw-reloadstack), HIS ORDER (2026-10-27): "make the active reload stack but it gets harder each time". THE ACTIVE RELOAD STACKS. Each active reload in a row adds AR_STEP
// to the bonus of the next magazine (x1.15, x1.25, x1.35, x1.45, then x1.55 from AR_STK_MAX on), and each one narrows the next sweet spot around its middle by AR_NARROW (18, 13.5,
// 10.1, 7.6, then 5.7 percent of the reload). A press outside the sweet spot, or a reload left to run out on its own, starts the chain over and the spot is wide again.
// v28.xx (cw-cx-reloadswitch): changing the held gun also ends the chain, including a swap that cuts a reload short. Each pillager owns their own chain.
var AR_STEP=0.10, AR_STK_MAX=5, AR_NARROW=0.75;
'@ @'
var AR_A=0.42, AR_B=0.60, AR_BONUS=1.05;
// v28.xx (cw-cx-reload5pct), HIS WORDS (2026-10-29): "active reload should only give an extra 5% of damage per stack for a total of 15%".
// v28.xx (cw-cx-reload5pct): successive magazines pay x1.05, x1.10, then x1.15 at the three-stack cap. AR_NARROW still narrows the sweet spot
// around its middle (18, 13.5, then 10.1 percent of the reload); it stops narrowing at the third stack. A miss or a reload left to run out resets the chain.
// v28.xx (cw-cx-reloadswitch): changing the held gun also ends the chain, including a swap that cuts a reload short. Each pillager owns their own chain.
var AR_STEP=0.05, AR_STK_MAX=3, AR_NARROW=0.75;
'@

SubRx @'
  'COMBAT FEEL. Heavy rounds stop what they hit and the Lance kicks. R again in the bright part of the reload ring finishes it, +15% damage. The Support MG spins up.',
'@ @'
  'COMBAT FEEL. Heavy rounds stop what they hit and the Lance kicks. R again in the bright part of the reload ring finishes it, +5% damage a stack, +15% max. The Support MG spins up.',
'@

SubRx @'
var VER='36.24';
'@ @'
var VER='36.25';
'@

$pat = "(?m)^  now:'v36\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.25: active reload adds 5% a stack, 15% at most Check 36.25 fails on v36.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
