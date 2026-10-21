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

# ONE PIXEL WALK BOB (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var PXB={W:36,H:50,AX:19,AY:51,PV:22,TARGET:50};
'@ @'
var PXB={W:36,H:50,AX:19,AY:51,PV:20,TARGET:50}; /* v28.xx (cw-cx-pixpose): the pixel shoulder uses the existing 20 world unit muzzle height */
'@

SubRx @'
  bob=moving?Math.round(Math.abs(Math.sin(ph))*(sprint?3.6:2.6)):(((((G&&G.t)||0)*0.8)|0)&1);
'@ @'
  bob=pxBob(ph,moving); /* v28.xx (cw-cx-pixpose): his a11 B bounce, one art pixel at the existing stride and breath timings */
'@

SubRx @'
function pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v28.xx (cw-cx-pixpose): quantize the old stride and breath phases to two heights, without changing their clocks or the planted feet.
function pxBob(ph,moving){ return Math.round(moving?Math.abs(Math.sin(ph)):(Math.sin(ph*0.35)+1)*0.5); }
function pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
var VER='33.71';
'@ @'
var VER='33.72';
'@

$pat = "(?m)^  now:'v33\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.72: The pixel torso breathes and bobs between two adjacent pixel rows. The gun shoulder is back at the existing muzzle height. Check 33.72 fails on v33.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
