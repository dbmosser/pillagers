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

# FLASHES AND MACHINE EYES LIGHT THE GROUND IN THEIR OWN COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
put(wspr,F.x,F.y,frr,2*a*.9*fr);
'@ @'
put(gfxLightSpr(F.c||'#ffc27a','map'),F.x,F.y,frr,2*a*.9*fr);   // v34.73 (cw-flashlight): the flash lights the ground in the colour it already stores (his 10-12 graphics list)
'@

SubRx @'
put(wspr,E.x,E.y,er,2*a*.34);
'@ @'
put(gfxLightSpr(E.kind==='raider'?'#ff8a6a':'#ff4a32','map'),E.x,E.y,er,2*a*.34);   // v34.73 (cw-flashlight): the same red as the eye glow
'@

SubRx @'
put(wspr,az.x,az.y,k,2*a*(inb?.62:.30));
'@ @'
put(gfxLightSpr('#4de3d0','map'),az.x,az.y,k,2*a*(inb?.62:.30));   // v34.73 (cw-flashlight): the beacon throws teal
'@

SubRx @'
var VER='34.79';
'@ @'
var VER='34.80';
'@

$pat = "(?m)^  now:'v34\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.80: At night blasts, shots, hunting machines and the beacon light the ground in their own colour. Check 34.80 fails on v34.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
