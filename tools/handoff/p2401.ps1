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

# PLAYER 2S BEST SHOT LANDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  d=+m.dmg; if(!isFinite(d)||d<=0||d>600) return 'bad';
'@ @'
  // v23.xx, THE FORGE design (2026-10-12), forge1: the Longshot does 170 since v21.66, so player 2's round into a Choir's DORSAL
  // SPINE is 170 x 3.6 = 612 and the 600 cap threw it away while his screen showed it. A forged MK II Longshot (221 x 3.6 = 796,
  // 995 with the acid machine bonus) would be lost every time. The cap is 1500: above every real hit, still far below a broken number.
  d=+m.dmg; if(!isFinite(d)||d<=0||d>1500) return 'bad';
'@

SubRx @'
var VER='24.00';
'@ @'
var VER='24.01';
'@

$pat = "(?m)^  now:'v24\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.01: Player 2 Longshot rounds into a Choir weak point land on the host again. Check 24.01 fails on v24.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
