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

# THE SECTOR MAP MARKER TAGS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapLabel(txt,x,y,col,font){
  ctx.font=font||FS(TYPE.label);
  var w=ctx.measureText(txt).width+6,h=LH(11),ty=y;
'@ @'
function mapLabel(txt,x,y,col,font){
  // v19.63, seen on the 4K map scan (2026-10-08): every other word on the sector map grows with the screen, but these marker tags
  // (CACHE, ENCAMPMENT, the locked rooms, KEY) kept their 1080p size at 4K. They use the screen-grown font, and their callers lift them
  // off their markers by the map's own zoom (_MZ).
  ctx.font=font||hudFS(TYPE.label);
  var w=ctx.measureText(txt).width+6,h=LH(11)*Math.max(1,(typeof hudRes==='function')?hudRes():1),ty=y;
'@

SubRx @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-15,'#e6b4ff');
'@ @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-15*_MZ,'#e6b4ff');
'@

SubRx @'
    mapLabel('ENCAMPMENT',cqx,cqy-14,'#ff8a76');
'@ @'
    mapLabel('ENCAMPMENT',cqx,cqy-14*_MZ,'#ff8a76');
'@

SubRx @'
lqx+lqw/2,lqy-6,LKM.open?
'@ @'
lqx+lqw/2,lqy-6*_MZ,LKM.open?
'@

SubRx @'
      mapLabel('KEY',ikx,iky-9,'#ffc04a');
'@ @'
      mapLabel('KEY',ikx,iky-9*_MZ,'#ffc04a');
'@

SubRx @'
    mapLabel('INTEL LIVE',ox+52,oy+14,'#4de3d0');
'@ @'
    mapLabel('INTEL LIVE',ox+52*_MZ,oy+14*_MZ,'#4de3d0');
'@

SubRx @'
var VER='19.62';
'@ @'
var VER='19.63';
'@

$pat = "(?m)^  now:'v19\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.63: At 4K the CACHE and locked room tags on the sector map are full size. Check 19.63 fails on v19.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
