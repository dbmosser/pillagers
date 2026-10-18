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

# NO STRONGHOLD OVER THE FORGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    cx=b.x+b.w/2; cy=b.y+b.h/2;
    if(Math.hypot(cx-p.x,cy-p.y)<650||flowZoneNear(cx,cy,260+Math.max(b.w,b.h)/2)) continue;
'@ @'
    cx=b.x+b.w/2; cy=b.y+b.h/2;
    if(Math.hypot(cx-p.x,cy-p.y)<650||flowZoneNear(cx,cy,260+Math.max(b.w,b.h)/2)) continue;
    if(G.forge&&G.forge.x>b.x-70&&G.forge.x<b.x+b.w+70&&G.forge.y>b.y-70&&G.forge.y<b.y+b.h+70) continue;   // v28.xx (cw-shforge), CLOUD HUNT 2026-10-15 (cloud-raid-shforge): never a stronghold over the Forge, it sat out of reach behind the shut gate
'@

SubRx @'
var VER='29.08';
'@ @'
var VER='29.09';
'@

$pat = "(?m)^  now:'v29\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.09: A stronghold is no longer a building with the Forge in it. Check 29.09 fails on v29.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
