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

# PIXEL BODY KEEPS ITS SWING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(slk&&pxIsSet(slk.clothes)){
'@ @'
if(slk){   // v28.xx (cw-pixmelee) I3: a plain look keeps its pixel body in a swing or punch too (was: only the three full sets); the hand is the skin ramp
'@

SubRx @'
hand=lk.clothes==='skeleton'?PXS_BONE[1]:(lk.clothes==='trooper'?PXS_DARK[1]:PXS_PALE[1]);
'@ @'
hand=lk.clothes==='skeleton'?PXS_BONE[1]:(lk.clothes==='trooper'?PXS_DARK[1]:(lk.clothes==='android'?PXS_PALE[1]:(lk.bot===2?PXB_GOLD.skin[1]:(PIXRAMPS.skins[lk.skin]||PIXRAMPS.skins.fair)[1])));   // v28.xx (cw-pixmelee) I3: plain looks use the skin ramp
'@

SubRx @'
var fam='setmelee|'+lk.clothes+'|'+(crow?1:0),sp=
'@ @'
var fam='setmelee|'+lk.clothes+'|'+hand+'|'+(crow?1:0),sp=
'@

SubRx @'
var VER='34.71';
'@ @'
var VER='34.72';
'@

$pat = "(?m)^  now:'v34\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.72: A crowbar swing or punch keeps the pixel body on every look. Check 34.72 fails on v34.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
