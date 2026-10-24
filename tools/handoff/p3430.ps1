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

# RAID HUD TEXT KEEPS ITS I DOTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(typeof G.beaconT==='number'&&G.beaconT>0) ctx.globalAlpha=0.6;
'@ @'
if(typeof G.beaconT==='number'&&G.beaconT>0) ctx.globalAlpha=0.7;   // v28.xx (cw-h103fix): the critic found 60 percent too faint to read the rounds, so 70;
'@

SubRx @'
  ctx.clearRect(0,0,W,H);
  gfxqVignette();
'@ @'
  ctx.clearRect(0,0,W,H);
  if(ctx.textRendering!=='geometricPrecision') ctx.textRendering='geometricPrecision';   // v28.xx (cw-h103fix), the critic on screens 21 and 61 ('run Info', 'In cover': a capital letter): the small i of the condensed face lost its dot to hinting at 1080p and read as a capital I; unhinted text keeps the dot
  gfxqVignette();
'@

SubRx @'
var VER='34.29';
'@ @'
var VER='34.30';
'@

$pat = "(?m)^  now:'v34\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.30: Small i letters in the raid HUD show their dot again. The ammo card fades less while the extraction ship is coming. Check 34.30 fails on v34.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
