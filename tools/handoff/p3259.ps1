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

# THE HOSTILES PLATE MATCHES THE EXTRACT BANNER WIDTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function extRowPlate(s,x,y,R){
  var w=hudRawW(s)+LH(24)*R, h=LH(26)*R, px=Math.round(x-w/2), py=Math.round(y-LH(19)*R);
  hudPanel(px,py,w,h,0.9,true);
  return {x:px,y:py,w:w,h:h};
}

'@ @'
function extRowPlate(s,x,y,R,minW){
  // v32.xx (cw-hostcol), the critic on screen 37: the plate was a narrower pill touching the banner. It takes the banner width (minW) and sits 8 px under it, one column.
  var w=Math.max(hudRawW(s)+LH(24)*R,minW||0), h=LH(22)*R, px=Math.round(x-w/2), py=Math.round(y-LH(16)*R);
  hudPanel(px,py,w,h,0.9,true);
  return {x:px,y:py,w:w,h:h};
}

'@

SubRx @'
  var _exBan=_exBelt-LH(48)*_exR;   // the headline above it

'@ @'
  var _exBan=_exBelt-LH(62)*_exR;   // the headline above it; v32.xx (cw-hostcol) 14 px higher so the hostiles plate has an 8 px gap under it
  var _exBW=0;   // width of the banner plate, shared with the hostiles plate under it

'@

SubRx @'
    if(!holding) extBanPlate(_exS,W/2,_exBan,_exR);   // v32.xx (cw-extscrim)

'@ @'
    if(!holding) _exBW=extBanPlate(_exS,W/2,_exBan,_exR).w;   // v32.xx (cw-extscrim)

'@

SubRx @'
        extRowPlate(_exH,W/2,_exRow,_exR);   // v32.xx (cw-hostplate)

'@ @'
        extRowPlate(_exH,W/2,_exRow,_exR,_exBW);   // v32.xx (cw-hostplate), cw-hostcol

'@

SubRx @'
var VER='32.58';
'@ @'
var VER='32.59';
'@

$pat = "(?m)^  now:'v32\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.59: The hostiles closing in plate is as wide as the extract countdown plate, with a gap between them. Check 32.59 fails on v32.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
