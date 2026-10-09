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

# A WEAK POINT HIT SAYS WEAK SPOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
label(en.x,en.y-Math.round(en.r*1.3),WK.name+'  x'+WK.mult,WK.c,0,true);
'@ @'
label(en.x,en.y-Math.round(en.r*1.3),'WEAK SPOT',WK.c,0,true);   /* v21.64, HIS NOTE (2026-10-09): OPTIC 2X read as a scope, not a weak point; it says WEAK SPOT, in the weak point colour */
'@

SubRx @'
var VER='21.63';
'@ @'
var VER='21.64';
'@

$pat = "(?m)^  now:'v21\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.64: Hitting an enemy weak point now flashes WEAK SPOT instead of OPTIC 2X. Check 21.64 fails on v21.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
