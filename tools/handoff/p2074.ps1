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

# THE FULL CONTROLS LIST CLEARS THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawLegend(){
'@ @'
function drawLegend(fz){   // v20.74 (H40): fz is the zoom the full list is drawn at, so it can stop above the belt as seen on the screen
'@

SubRx @'
    drawLegend();
'@ @'
    drawLegend(G.legendOn===2?_fz:1);   // v20.74 (H40): the full list is told its zoom
'@

SubRx @'
  var top=Math.max(8,H-(LH(70)+LH(20))-boxH);
'@ @'
  var top=Math.max(8,H-(LH(70)+LH(20))-boxH);
  // v20.74, from the whole-game bug hunt of 2026-10-08 (H40): THE FULL LIST STOPS ABOVE THE BELT AS IT IS DRAWN NOW. The reserve above
  // is the belt of v8.48; since v8.81 the belt sizes itself and its caption sits higher, so at 1080p the plate covered the top of the
  // caption and the dark strip behind it, and H  hide sat on the strip. The bottom now comes from the belt cells drawn this frame and
  // the caption over them, through the zoom this list is drawn at, with a small gap. It only ever moves the list up.
  var _hc0=(G&&G.hotCells&&G.hotCells.length&&state!=='hub')?G.hotCells[0]:null, _lfz=(typeof fz==='number'&&fz>0)?fz:1, _cpx, _cap;
  if(_hc0&&_hc0.w>0){
    _cpx=parseFloat(((/([\d.]+)px/).exec(String(beltCapFS(_hc0.w)))||[0,11])[1])||11;
    _cap=Math.round(_hc0.y-LH(6)-_cpx*0.95)-LH(4);
    top=Math.max(8,Math.min(top,Math.floor(H-(H-_cap)/_lfz)-boxH-4));
  }
'@

SubRx @'
var VER='20.73';
'@ @'
var VER='20.74';
'@

$pat = "(?m)^  now:'v20\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.74: The full controls list (H twice) no longer covers the line over the belt. Check 20.74 fails on v20.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
