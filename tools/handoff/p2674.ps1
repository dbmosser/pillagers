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

# AIR STRIKE PLATE AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  z=Math.max(1,hudRes()); q=ZOOM(); R=AIR.R*q; ar=AIR.spread*q+R*0.4;
'@ @'
  z=Math.max(1,hudRes()); q=ZOOM(); R=AIR.R*q; ar=AIR.spread*q+R*0.4;
  var U=function(v){ return LH(v)*z; };   // v26.xx (flow2b): the HUD size the raid status uses, so the plate grows with the screen as the text does
'@

SubRx @'
hudText('AIR STRIKE',s.x,s.y-ar-LH(24));
'@ @'
hudText('AIR STRIKE',s.x,s.y-ar-U(24));
'@

SubRx @'
' CALL     G CANCEL',s.x,s.y-ar-LH(8));
'@ @'
' CALL     G CANCEL',s.x,s.y-ar-U(8));
'@

SubRx @'
    c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-LH(130);
    bw=LH(200); bh=LH(28); x=Math.round(W/2+LH(16)); y=Math.round(c0-LH(112));
'@ @'
    c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-U(130);
    bw=U(200); bh=U(28); x=Math.round(W/2+U(16)); y=Math.round(c0-U(112));
'@

SubRx @'
hudText('AIR STRIKE',x+LH(12),y+Math.round(bh*0.64));
'@ @'
hudText('AIR STRIKE',x+U(12),y+Math.round(bh*0.64));
'@

SubRx @'
    bx=x+LH(96); bwid=bw-LH(96)-LH(48); by=Math.round(y+bh*0.5-LH(3));
'@ @'
    bx=x+U(96); bwid=bw-U(96)-U(48); by=Math.round(y+bh*0.5-U(3));
'@

SubRx @'
c.fillStyle='rgba(255,255,255,.12)'; c.fillRect(bx,by,bwid,LH(6));
'@ @'
c.fillStyle='rgba(255,255,255,.12)'; c.fillRect(bx,by,bwid,U(6));
'@

SubRx @'
'#ff8a3c'; c.fillRect(bx,by,bwid*fl,LH(6));
'@ @'
'#ff8a3c'; c.fillRect(bx,by,bwid*fl,U(6));
'@

SubRx @'
    if(rdy) hudKey('G',x+bw-LH(46),y+Math.round(bh*0.7),LH(8),LH(32));
'@ @'
    if(rdy) hudKey('G',x+bw-U(46),y+Math.round(bh*0.7),U(8),U(32));
'@

SubRx @'
hudText(Math.floor(fl*100)+'%',x+bw-LH(10),y+Math.round(bh*0.64)); }
'@ @'
hudText(Math.floor(fl*100)+'%',x+bw-U(10),y+Math.round(bh*0.64)); }
'@

SubRx @'
var VER='26.73';
'@ @'
var VER='26.74';
'@

$pat = "(?m)^  now:'v26\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.74: The air strike meter plate now grows with the screen, so it fits at 4K. Check 26.74 fails on v26.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
