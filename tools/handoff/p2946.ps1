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

# THE HEAVY FUEL CAN AND SHIN GUARDS ARE CHIPPED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle='#5a2418'; wc.fillRect(bx-0.6,ty-19.6,1.2,2.4);
'@ @'
    wc.fillStyle='#5a2418'; wc.fillRect(bx-0.6,ty-19.6,1.2,2.4);
    // v28.xx (cw-heavygear), art build step b (char-art-build-brief): "chipped paint edges and colour-panel stripes on armour ... chunkier ... packs". The Heavy fuel can gets a scheme colour panel stripe and three bare steel paint chips, all inside the old outline.
    wc.fillStyle=A; wc.fillRect(bx-3.2,ty-14.9,6.4,0.9);
    wc.fillStyle='#dfe6ec'; wc.fillRect(bx-3.0,ty-19.0,1.2,0.9); wc.fillRect(bx+1.9,ty-18.4,1.2,0.9); wc.fillRect(bx+1.0,ty-12.9,1.4,0.8);
'@

SubRx @'
wc.fillStyle=_SCH?_SCH.a:'#c8a24a'; wc.fillRect(x-6.0+swing2*.5,ty-6.6-liftB*.5,3.6,0.9); wc.fillRect(x+2.2+swing*.5,ty-6.6-liftA*.5,3.6,0.9);
'@ @'
wc.fillStyle=_SCH?_SCH.a:'#c8a24a'; wc.fillRect(x-6.0+swing2*.5,ty-6.6-liftB*.5,3.6,0.9); wc.fillRect(x+2.2+swing*.5,ty-6.6-liftA*.5,3.6,0.9);
    // v28.xx (cw-heavygear), art build step b (char-art-build-brief): "chipped paint edges ... on armour". The Heavy shin guards are scuffed: two bare steel chips on each plate, inside the old outline.
    wc.fillStyle='#dfe6ec'; wc.fillRect(x-5.8+swing2*.5,ty-8.4-liftB*.5,1.2,0.8); wc.fillRect(x-3.6+swing2*.5,ty-7.6-liftB*.5,1.2,0.8); wc.fillRect(x+2.4+swing*.5,ty-7.6-liftA*.5,1.2,0.8); wc.fillRect(x+4.6+swing*.5,ty-8.4-liftA*.5,1.2,0.8);
'@

SubRx @'
var VER='29.45';
'@ @'
var VER='29.46';
'@

$pat = "(?m)^  now:'v29\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.46: The Heavy fuel can and shin guards now show chipped paint and a colour stripe. Check 29.46 fails on v29.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
