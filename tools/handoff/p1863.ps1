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

# EVERY STATION NAME SITS ON ITS PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _lyP=s3.labelBelow?(s3.y+s3.r+4):(s3.y-56), _lyT=_lyP+10;
    wc.fillRect(s3.x-tw/2-5,_lyP,tw+10,13);
    // v10.93: opaque. This was rgba(160,172,184,.75).
    wc.fillStyle=on?s3.c:'#cfd8e2';
    // v6.73: keep the name inside the room. Centred text on a station near a wall used
    // to have its first letters cut off by the edge of the floor.
    var _lw2=wc.measureText(s3.label).width, _lx2=s3.x;
    var _lm2=34;                         // the 20 unit shell wall, plus a little air
    if(_lw2<HUBW-_lm2*2){
      if(_lx2-_lw2/2<_lm2)       _lx2=_lm2+_lw2/2;
      if(_lx2+_lw2/2>HUBW-_lm2)  _lx2=HUBW-_lm2-_lw2/2;
    }
'@ @'
    var _lyP=s3.labelBelow?(s3.y+s3.r+4):(s3.y-56), _lyT=_lyP+10;
    // v6.73: keep the name inside the room. Centred text on a station near a wall used
    // to have its first letters cut off by the edge of the floor.
    var _lw2=wc.measureText(s3.label).width, _lx2=s3.x;
    var _lm2=34;                         // the 20 unit shell wall, plus a little air
    if(_lw2<HUBW-_lm2*2){
      if(_lx2-_lw2/2<_lm2)       _lx2=_lm2+_lw2/2;
      if(_lx2+_lw2/2>HUBW-_lm2)  _lx2=HUBW-_lm2-_lw2/2;
    }
    // v18.63, SEEN ON THE UNDERCROFT SCREENSHOT (2026-10-07): THE PLATE SITS UNDER THE NAME. It was laid at the station's x before a
    // name near a wall was pushed inward (v6.73), so a bare strip of plate stuck out beside SHOP, CRAFT, AND HIRE and WIRT THE
    // GAMBLER, and it was 13 units tall, which at the label size covered only the lower half of the letters. It is now drawn where
    // the name is and as tall as its letters.
    var _lmx=wc.measureText(s3.label), _lAsc=Math.max(8,_lmx.actualBoundingBoxAscent||9), _lDsc=Math.max(2,_lmx.actualBoundingBoxDescent||3);
    wc.fillRect(_lx2-tw/2-5,_lyT-_lAsc-3,tw+10,_lAsc+_lDsc+6);
    // v10.93: opaque. This was rgba(160,172,184,.75).
    wc.fillStyle=on?s3.c:'#cfd8e2';
'@

SubRx @'
      wc.fillText('***EXPERIMENTAL***',_lx2,s3.y-35);
'@ @'
      var _eAsc=Math.max(6,wc.measureText('***EXPERIMENTAL***').actualBoundingBoxAscent||7);   // v18.63: below the name's plate, never into it (it printed across THE LAST POUR)
      wc.fillText('***EXPERIMENTAL***',_lx2,Math.max(s3.y-35,_lyT+_lDsc+3+_eAsc+2));
'@

SubRx @'
var VER='18.62';
'@ @'
var VER='18.63';
'@

$pat = "(?m)^  now:'v18\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.63: Station names on the Undercroft floor sit cleanly on their plates, and THE LAST POUR warning no longer prints over its name. Check 18.63 fails on v18.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
