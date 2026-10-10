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

# THE SPINE SHOT LANDS FOR PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  d=+m.dmg; if(!isFinite(d)||d<=0||d>400) return 'bad';
'@ @'
  // v22.24, from the whole-game bug hunt of 2026-10-08 (K35): THE BEST SHOT IN THE GAME LANDS FOR PLAYER 2 TOO. A shot word over
  // 400 was thrown away as junk, but a Longshot round into a Choir's DORSAL SPINE is 115 x 3.6 = 414, so the host dropped it while
  // player 2's screen showed the 414. The cap is 600 now: above every real hit (the next best is a Sentry vent at 391), still far
  // below a broken number.
  d=+m.dmg; if(!isFinite(d)||d<=0||d>600) return 'bad';
'@

SubRx @'
var VER='22.23';
'@ @'
var VER='22.24';
'@

$pat = "(?m)^  now:'v22\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.24: In co-op, a Longshot into the DORSAL SPINE of a Choir now lands for player 2 too. Check 22.24 fails on v22.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
