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

# NO BURNING BODIES THROUGH WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if((e.hp<=0&&!e.downed)||e.finished||e.gone||!isFinite(e.x)||!isFinite(e.y)) continue;
    r=e.r||14; H=elemBodyH(e);
'@ @'
    if((e.hp<=0&&!e.downed)||e.finished||e.gone||!isFinite(e.x)||!isFinite(e.y)) continue;
    if(!e.seen) continue;   // v28.xx (cw-elemseen), job 127 pictures: in sight only, like the body (VIS). Flames, arcs, ice and their glow drew through walls and fog for any burning, shocked or frozen body
    r=e.r||14; H=elemBodyH(e);
'@

SubRx @'
var VER='34.86';
'@ @'
var VER='34.87';
'@

$pat = "(?m)^  now:'v34\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.87: Burning, shocked and frozen bodies you cannot see no longer show flames, ice or glow through walls and fog. Watch for: flames appearing at the same moment the body does as you round a corner. Check 34.87 fails on v34.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
