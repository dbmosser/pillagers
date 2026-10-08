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

# A MOVED MAP LABEL STAYS ON THE MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G2.slice().sort(function(a,b){ return (b.p-a.p)||(a.i-b.i); }).forEach(function(g){
'@ @'
  // v19.31, seen on the 4K map screenshot (2026-10-08): a label moved off a clash could be moved anywhere, so RECEIVING APRON went up
  // past the SECTOR MAP line and half off the top of the screen. A moved label now stays on the screen and below the header line.
  var _bT=0, _bW=(ctx&&ctx.canvas)?ctx.canvas.width:1e9, _bH=(ctx&&ctx.canvas)?ctx.canvas.height:1e9;  G2.slice().sort(function(a,b){ return (b.p-a.p)||(a.i-b.i); }).forEach(function(g){
'@

SubRx @'
    if(g.p===9){ placed.push(g.r); g.dx=0; g.dy=0; out.push(g); return; }
'@ @'
    if(g.p===9){ placed.push(g.r); g.dx=0; g.dy=0; out.push(g); if(hdrY!==null&&g.items.some(function(L){ return L.y<=hdrY+2; })) _bT=Math.max(_bT,g.r.b); return; }
'@

SubRx @'
    for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(!hits(r))
'@ @'
    for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(r.t<_bT||r.b>_bH||r.l<0||r.r>_bW) continue; if(!hits(r))
'@

SubRx @'
var VER='19.30';
'@ @'
var VER='19.31';
'@

$pat = "(?m)^  now:'v19\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.31: Zone names on the sector map never end up above the map or off the screen. Check 19.31 fails on v19.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
