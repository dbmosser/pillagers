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

# ELITE INTEL HAS A SHAPE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.beginPath(); ctx.arc(ox+IEE.x*sc,oy+IEE.y*sc,3.4*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): at the map zoom
'@ @'
      // v28.xx (cw-cx-inteltriangle), his 2.79 a: elite intel has a triangle as well as its purple colour.
      var eliteX=ox+IEE.x*sc, eliteY=oy+IEE.y*sc;
      ctx.beginPath(); ctx.moveTo(eliteX,eliteY-5*_MZ); ctx.lineTo(eliteX+4.5*_MZ,eliteY+4*_MZ); ctx.lineTo(eliteX-4.5*_MZ,eliteY+4*_MZ); ctx.closePath(); ctx.fill();
      ctx.save(); ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=1.5*_MZ; ctx.stroke(); ctx.restore();
'@

SubRx @'
var VER='34.01';
'@ @'
var VER='34.02';
'@

$pat = "(?m)^  now:'v34\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.02: Map intel elites use a purple triangle with a cream edge, readable without colour. Check 34.02 fails on v34.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
