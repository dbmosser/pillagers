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

# A CONTROLLER SEES WHERE THE MAP MARKER GOES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
'@ @'
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  // v22.00, from the whole-game bug hunt of 2026-10-08 (K10): THE CONTROLLER MAP CURSOR IS DRAWN. Since v16.47 the right stick
  // moves a cursor across the open map and a tap of D-UP places the marker there, but nothing drew that cursor: the only pointer
  // on the map was the mouse arrow, wherever the real mouse sat, so a pad player placed his marker blind. A ring and a cross now
  // show where it will land, after the labels like the marker above. G.mapCur is set only by the right stick and is cleared when
  // the map shuts, so a mouse player never sees it.
  if(G.mapCur){
    var _mcx=ox+G.mapCur.x*sc, _mcy=oy+G.mapCur.y*sc;
    var _mcP=function(){
      ctx.beginPath(); ctx.arc(_mcx,_mcy,9*_pmz,0,6.2832);
      ctx.moveTo(_mcx-16*_pmz,_mcy); ctx.lineTo(_mcx-5*_pmz,_mcy); ctx.moveTo(_mcx+5*_pmz,_mcy); ctx.lineTo(_mcx+16*_pmz,_mcy);
      ctx.moveTo(_mcx,_mcy-16*_pmz); ctx.lineTo(_mcx,_mcy-5*_pmz); ctx.moveTo(_mcx,_mcy+5*_pmz); ctx.lineTo(_mcx,_mcy+16*_pmz);
      ctx.stroke();
    };
    ctx.strokeStyle='#120e0c'; ctx.lineWidth=4.5*_pmz; _mcP();   // an ink edge, so it never disappears into a gold block
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_pmz; _mcP();
    ctx.lineWidth=1;
  }
'@

SubRx @'
  ctx.fillText(G.waypoint?'CLICK set waypoint
'@ @'
  ctx.fillText(padOn()?'R STICK move marker  \u00b7  D-UP place marker':G.waypoint?'CLICK set waypoint
'@

SubRx @'
var VER='21.99';
'@ @'
var VER='22.00';
'@

$pat = "(?m)^  now:'v21\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.00: On a controller the sector map now shows where your marker will land, and says R STICK and D-UP. Check 22.00 fails on v21.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
