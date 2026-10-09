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

# MAP TAGS STAY INSIDE THE MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.font=font||hudFS(TYPE.label);
  var w=ctx.measureText(txt).width+6,h=LH(11)*Math.max(1,(typeof hudRes==='function')?hudRes():1),ty=y;
'@ @'
  ctx.font=font||hudFS(TYPE.label);
  var w=ctx.measureText(txt).width+6,h=LH(11)*Math.max(1,(typeof hudRes==='function')?hudRes():1),ty=y;
  // v21.05, from the whole-game bug hunt of 2026-10-08 (V-D3), seen on the 4K map screenshot: A MARKER TAG STAYS INSIDE THE MAP FRAME.
  // A tag is centred on its marker, so a locked room by the edge of the sector printed FOREMAN OFFICE - LOCKED and BLAST FREEZER -
  // LOCKED across the frame line and out past the map. A tag that would cross the frame slides along to sit just inside it; one
  // nowhere near the edge is drawn where it always was.
  var _mpF=mapProj(), _fL=_mpF.ox+w/2, _fR=_mpF.ox+WORLD_W*_mpF.sc-w/2;
  if(_fR>_fL) x=clamp(x,_fL,_fR);
'@

SubRx @'
var VER='21.04';
'@ @'
var VER='21.05';
'@

$pat = "(?m)^  now:'v21\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.05: Locked room and cache tags on the sector map no longer run over the map border. Check 21.05 fails on v21.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
