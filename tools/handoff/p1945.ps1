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

# HIS OWN MAP MARKER STAYS ON TOP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _pmz=(typeof _MZ==='number'&&_MZ>0)?_MZ:1;
  var _pmx=ox+p.x*sc, _pmy=oy+p.y*sc;
  ctx.fillStyle='rgba(255,192,74,.18)';
'@ @'
  var _pmz=(typeof _MZ==='number'&&_MZ>0)?_MZ:1;
  var _pmx=ox+p.x*sc, _pmy=oy+p.y*sc;
  // v19.45, from the review (2026-10-08): since v19.02 the labels are drawn after this whole pass, so they printed over his own
  // marker and the party dots, the two things his Q23 says are never lost. The marker and the dots are handed to drawMapOverlay
  // to draw after the labels (MAPLAST), with the transform they would have had here.
  var _pmDraw=function(){
  ctx.fillStyle='rgba(255,192,74,.18)';
'@

SubRx @'
  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
'@ @'
  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  };
  if(MAPLAST){ MAPLAST.push({fn:_pmDraw,m:ctx.getTransform(),ga:ctx.globalAlpha}); } else _pmDraw();
'@

SubRx @'
function drawMapOverlay(){
  var had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), prev=ctx.fillText, Q=[], hdrY=null, done=false;
'@ @'
var MAPLAST=null;   // v19.45: what drawMapOverlayRaw hands back to be drawn on top of the labels
function drawMapOverlay(){
  var had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), prev=ctx.fillText, Q=[], hdrY=null, done=false;
  MAPLAST=[];
'@

SubRx @'
    if(!done){ Q.forEach(function(L){ ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){} ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga; (had?prev:CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x,L.y); ctx.restore(); }); }
  }
}
'@ @'
    if(!done){ Q.forEach(function(L){ ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){} ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga; (had?prev:CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x,L.y); ctx.restore(); }); }
    var _ml=MAPLAST; MAPLAST=null;
    if(_ml) _ml.forEach(function(D){ ctx.save(); try{ ctx.setTransform(D.m); ctx.globalAlpha=D.ga; D.fn(); }catch(_md){} ctx.restore(); });
  }
}
'@

SubRx @'
var VER='19.44';
'@ @'
var VER='19.45';
'@

$pat = "(?m)^  now:'v19\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.45: On the sector map your own marker and your teammate are always on top of the writing. Check 19.45 fails on v19.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
