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

# BARE HUD TEXT GETS THE OUTLINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillStyle=(o&&o.col)||HUDC.text; ctx.fillText(t,x,y);
'@ @'
  // v22.xx, the raid text rewrite (R44): the prompt line carries the ink outline as well as its plate (2 x hudRes on the screen,
  // under whatever scale the caller has put it, so hudAtIn does not double it).
  var _pa=Math.abs((ctx.getTransform?ctx.getTransform().a:1)||1)/((typeof DPR==='number'&&DPR>0)?DPR:1);
  ctx.fillStyle=(o&&o.col)||HUDC.text; hudText(t,x,y,2*Math.max(1,(typeof hudRes==='function')?hudRes():1)/Math.max(0.25,_pa));
'@

SubRx @'
  ctx.fillText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk);
'@ @'
  // v22.xx, the raid text rewrite (R44): BARE HUD TEXT GETS THE OUTLINE. HIS ORDER (2026-10-09): the raid text reads like a shooter HUD,
  // where every word reads on any ground. The clock, the compass, the extraction band lines, the REVIVING word, the Crier countdown
  // and the party ping, Waypoint and arrow labels were filled with no outline and no plate, so over snow, a lit street or a fire they
  // washed out. Each now goes through hudText: a 2 x hudRes ink stroke with round joins, then the same fill. No shadowBlur (frame
  // cost); about twenty strokes a frame at most. The words, colours and places are unchanged.
  hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk);
'@

SubRx @'
    ctx.fillText(_lbl+' '+metres(zd)+'m',W/2,_yCmp);
'@ @'
    hudText(_lbl+' '+metres(zd)+'m',W/2,_yCmp);
'@

SubRx @'
    ctx.fillText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);   // v16.30, his word: inbound
'@ @'
    hudText(holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s'),W/2,_exBan);   // v16.30, his word: inbound
'@

SubRx @'
      ctx.fillText(metres(_ed)+'m',W/2+14*_exR,_exRow);
'@ @'
      hudText(metres(_ed)+'m',W/2+14*_exR,_exRow);
'@

SubRx @'
        ctx.fillText(inbound+' converging on the ring',W/2,_exRow);
'@ @'
        hudText(inbound+' converging on the ring',W/2,_exRow);
'@

SubRx @'
    ctx.fillStyle='#4de3d0'; ctx.fillText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION',W/2,_exRow);   // v22.66 (R24): the key in brackets, as every prompt
'@ @'
    ctx.fillStyle='#4de3d0'; hudText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION',W/2,_exRow);   // v22.66 (R24): the key in brackets, as every prompt
'@

SubRx @'
ctx.fillStyle='#4de3d0'; ctx.fillText('REVIVING',_rs.x,_rs.y-14);
'@ @'
ctx.fillStyle='#4de3d0'; hudText('REVIVING',_rs.x,_rs.y-14,2);
'@

SubRx @'
      ctx.fillText('CRIER '+left.toFixed(1)+'s',s.x,s.y-LH(22)*_cr);
'@ @'
      hudText('CRIER '+left.toFixed(1)+'s',s.x,s.y-LH(22)*_cr);
'@

SubRx @'
      ctx.fillText('CRIER '+left.toFixed(1)+'s',_lx,_ly);
'@ @'
      hudText('CRIER '+left.toFixed(1)+'s',_lx,_ly);
'@

SubRx @'
  ctx.fillText(nm+'  '+d+'m'+(g.dn?'  DOWN':''),clamp(ax-Math.cos(a)*LH(30)*r,LH(40)*r,W-LH(40)*r),clamp(ay-Math.sin(a)*LH(22)*r,LH(14)*r,H-LH(8)*r));
'@ @'
  hudText(nm+'  '+d+'m'+(g.dn?'  DOWN':''),clamp(ax-Math.cos(a)*LH(30)*r,LH(40)*r,W-LH(40)*r),clamp(ay-Math.sin(a)*LH(22)*r,LH(14)*r,H-LH(8)*r));
'@

SubRx @'
    ctx.fillText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'m',clamp(x,LH(70)*r,W-LH(70)*r),y-LH(18)*r); ctx.textAlign='left';
'@ @'
    hudText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'m',clamp(x,LH(70)*r,W-LH(70)*r),y-LH(18)*r); ctx.textAlign='left';
'@

SubRx @'
    ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; ctx.fillText(lbl,clamp(x,LH(60)*r,W-LH(60)*r),y-LH(16)*r); ctx.textAlign='left';
'@ @'
    ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; hudText(lbl,clamp(x,LH(60)*r,W-LH(60)*r),y-LH(16)*r); ctx.textAlign='left';
'@

SubRx @'
var VER='22.94';
'@ @'
var VER='22.95';
'@

$pat = "(?m)^  now:'v22\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.95: The raid clock, compass, extraction lines and party marks now have a dark outline, so they read over any ground. Check 22.95 fails on v22.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
