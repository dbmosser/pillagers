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

# YOUR HIRE NO LONGER HIDES ENEMY FOOTSTEPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(e.kind==='snitch') continue;          // it hovers, it has its own noise
'@ @'
    if(e.kind==='snitch') continue;          // it hovers, it has its own noise
    // v20.85, from the whole-game bug hunt of 2026-10-08 (H54): YOUR HIRE IS NOT A FOOTSTEP IN THE DARK. One body gets a step, the
    // nearest one moving, and a hire on FOLLOW walks 120 to 200 behind you whenever you walk, so every step went to him and a
    // crawler or pillager behind a wall made no sound at all. A hire, the survivor and the Peddler are not what this listens
    // for; the nearest machine or pillager on the move gets the step. Steps time off Math.random, never the seeded stream.
    if(e.merc||e.friendly||e.neutral||e.kind==='peddler'||e.kind==='stray') continue;
'@

SubRx @'
var VER='20.84';
'@ @'
var VER='20.85';
'@

$pat = "(?m)^  now:'v20\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.85: With a hire following you, you can hear enemy footsteps again. Check 20.85 fails on v20.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
