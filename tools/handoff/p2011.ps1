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

# ARMOUR FITS A CURVED BODY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle=INK; rrF(bx2-1,ty-20.5,bw2+2,10.2,2.6);
    wc.fillStyle=aMid; rrF(bx2,ty-19.6,bw2,8.4,2);
    wc.fillStyle=aHi; wc.fillRect(bx2+1,ty-19.6,bw2-2,2);
    wc.fillStyle=aLo; wc.fillRect(bx2+1,ty-13.2,bw2-2,1.8);
'@ @'
    if(_BLD==='curved'){
      // v20.11, from the build design review (2026-10-08): the plate was a box that hid a Curved waist and chest. On Curved it is cut
      // to her outline, and the chest is moulded into the steel, riding the same spring as the cloth one (v20.02).
      var _cx=x+leanX, _mb=ty-18.0+(_JG.c||0);
      wc.save(); buildPath(_cx,ty,BUILD_CURVED,0.6); wc.clip();
      wc.fillStyle=INK; wc.fillRect(_cx-12,ty-20.5,24,10.2);
      wc.restore();
      wc.save(); buildPath(_cx,ty,BUILD_CURVED,-0.4); wc.clip();
      wc.fillStyle=aMid; wc.fillRect(_cx-12,ty-19.6,24,8.4);
      wc.fillStyle=aHi; wc.fillRect(_cx-12,ty-19.6,24,2);
      wc.fillStyle=aLo; wc.fillRect(_cx-12,ty-13.2,24,1.8);
      wc.beginPath(); wc.ellipse(_cx-2.8,_mb+1.0,2.9,2.3,0,0,6.2832); wc.ellipse(_cx+2.8,_mb+1.0,2.9,2.3,0,0,6.2832); wc.fill();
      wc.fillStyle=aHi; wc.beginPath(); wc.ellipse(_cx-2.8,_mb,2.6,2.0,0,0,6.2832); wc.ellipse(_cx+2.8,_mb,2.6,2.0,0,0,6.2832); wc.fill();
      wc.restore();
    } else {    wc.fillStyle=INK; rrF(bx2-1,ty-20.5,bw2+2,10.2,2.6);
    wc.fillStyle=aMid; rrF(bx2,ty-19.6,bw2,8.4,2);
    wc.fillStyle=aHi; wc.fillRect(bx2+1,ty-19.6,bw2-2,2);
    wc.fillStyle=aLo; wc.fillRect(bx2+1,ty-13.2,bw2-2,1.8);
    }
'@

SubRx @'
var VER='20.10';
'@ @'
var VER='20.11';
'@

$pat = "(?m)^  now:'v20\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.11: Armour plates follow a Curved figure instead of boxing it in. Check 20.11 fails on v20.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
