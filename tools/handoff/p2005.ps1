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

# OUTFITS FIT THE BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle='#14161b'; wc.fillRect(_jx,ty-21.4,1.4,10); wc.fillRect(_jx+11.6,ty-21.4,1.4,10);
'@ @'
    // v20.05, seen on the 4K FASHION outfit screenshots (2026-10-08): on a Curved body the panels hung outside the narrow waist; on
    // Broad and Curved they now run down the body's own sides.
    if(_BLD){ wc.save(); buildPath(x+leanX,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.clip(); wc.beginPath(); wc.rect(x+leanX-12,ty-21.4,24,10); wc.clip(); buildPath(x+leanX,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.strokeStyle='#14161b'; wc.lineWidth=2.8; wc.stroke(); wc.restore(); }
    else { wc.fillStyle='#14161b'; wc.fillRect(_jx,ty-21.4,1.4,10); wc.fillRect(_jx+11.6,ty-21.4,1.4,10); }
'@

SubRx @'
      wc.fillRect(_ox-0.5,ty-22,1,11); wc.fillRect(_ox-6.5,ty-16.6,13,1);
'@ @'
      if(_BLD){ wc.save(); buildPath(_ox,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.clip(); wc.fillRect(_ox-0.5,ty-22,1,11); wc.fillRect(_ox-10,ty-16.6,20,1); wc.restore(); }   // v20.05: the seams stay on the build's body
      else { wc.fillRect(_ox-0.5,ty-22,1,11); wc.fillRect(_ox-6.5,ty-16.6,13,1); }
'@

SubRx @'
      wc.fillRect(_ox-6.5,ty-22,2.4,3.2); wc.fillRect(_ox+4.1,ty-22,2.4,3.2);
'@ @'
      if(_BLD){ var _sw=(_BLD==='broad')?8.9:6.1; wc.fillRect(_ox-_sw,ty-22,2.4,3.2); wc.fillRect(_ox+_sw-2.4,ty-22,2.4,3.2); }   // v20.05: the bare shoulders sit on the build's shoulders
      else { wc.fillRect(_ox-6.5,ty-22,2.4,3.2); wc.fillRect(_ox+4.1,ty-22,2.4,3.2); }
'@

SubRx @'
  wc.fillStyle=(_BLD==='curved')?'#c25a6c':'#8a5c46';
'@ @'
  wc.fillStyle=(_BLD==='curved'&&!(OUTF&&/^(skeleton|robot|trooper)$/.test(OUTF.mark)))?'#c25a6c':'#8a5c46';   // v20.05: not on a skull, a robot or a helmet
'@

SubRx @'
var VER='20.04';
'@ @'
var VER='20.05';
'@

$pat = "(?m)^  now:'v20\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.05: Every outfit sits right on Broad and Curved bodies. Check 20.05 fails on v20.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
