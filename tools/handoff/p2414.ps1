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

# SCREEN SHAKE FOLLOWS THE FIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.shake=Math.max(G.shake,4+7*_sev);

'@ @'
  // v23.xx, HIS ANSWERS (2026-10-12), answer 38: screen shake "light to strong depending on damage taken and frequency of incoming
  // damage". The size of the hit already set it; how often hits come in did not, so the fifth round of a burst shook the screen no
  // more than one stray round. hurtHeat is the damage still coming in: every hit adds its amount, and it fades by e every 0.9 s
  // (worked out from the time of the last hit, so nothing runs per frame). The shake is the hit's own size, a little lighter than
  // before at the bottom so a graze is a nudge, times up to 1.7 when 45 or more damage landed in the last second or so; capped at 24.
  // Cosmetic only: the shake draws from the cosmetic stream in render2D, so no seeded draw moves.
  var _hh=(typeof p.hurtHeat==='number'&&typeof p.hurtHeatAt==='number')?p.hurtHeat*Math.exp(-Math.max(0,(G.t||0)-p.hurtHeatAt)/0.9):0;
  p.hurtHeat=_hh+amt; p.hurtHeatAt=G.t||0;
  G.shake=Math.max(G.shake,Math.min(24,(2.5+7*_sev)*(1+0.7*clamp(_hh/45,0,1))));

'@

SubRx @'
var VER='24.13';
'@ @'
var VER='24.14';
'@

$pat = "(?m)^  now:'v24\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.14: Screen shake now grows with the size of each hit and how fast the hits are coming. Check 24.14 fails on v24.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
