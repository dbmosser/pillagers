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

# THE VEST NO LONGER DARKENS THE CARRIER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(_PC) drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig),_SCH);
  var _VID=OUTF?'vestplate':(st.hero?cosWorn('vest'):(st.vest||'vestplate'));   // v28.13 (cosm4)
  if(_PC&&_VID!=='vestplate'&&!(OUTF&&OUTF.norig)) drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl);   // v23.xx (spr15): the plate carrier, not stripes
  else {
'@ @'
  // v28.26 (cosm4fix), found by the older check 24.08 (spr15) on a run of the appearance checks: THE VEST HAD BROKEN THE PLATE CARRIER'S ELSE. The vest line sat between
  // the plate carrier and the else that paints the old dark chest band for bodies that are not in one, so on every build since the vest every body wearing
  // the default plate carrier (Plate Carrier, no vest picked) was painted with the dark band across the chest as well. The vest now goes inside the carrier's own
  // branch and the else is the else of the carrier again.
  if(_PC){
    drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig),_SCH);
    var _VID=OUTF?'vestplate':(st.hero?cosWorn('vest'):(st.vest||'vestplate'));   // v28.13 (cosm4)
    if(_VID!=='vestplate'&&!(OUTF&&OUTF.norig)) drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl);   // v23.xx (spr15): the plate carrier, not stripes
  }
  else {
'@

SubRx @'
var VER='28.25';
'@ @'
var VER='28.26';
'@

$pat = "(?m)^  now:'v28\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.26: The default plate carrier is lit again; the vest build had put a dark band across every chest. Check 28.26 fails on v28.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
