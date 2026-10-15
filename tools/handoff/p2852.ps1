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

# A ROLL NO LONGER HOLDS UP THE GUN YOU ARE DRAWING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
'@ @'
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
    drawTick(p,dt);   // v28.52 (cloud-feel-draw-roll), CLOUD HUNT 2026-10-15: and the draw clock too (it runs below this return), so a roll does not add 0.38 s to a draw
'@

SubRx @'
var VER='28.51';
'@ @'
var VER='28.52';
'@

$pat = "(?m)^  now:'v28\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.52: Rolling while you draw a gun no longer makes the draw take longer. Check 28.52 fails on v28.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
