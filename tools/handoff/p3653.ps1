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

# ONE MARK GLYPH IN ALL THREE VIEWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingLabel(lbl,x,y,r){
'@ @'
function netPingLabel(lbl,x,y,r,spot){
'@

SubRx @'
  by=clamp(y<132*r?y+48*r:y-88*r,32*r,H-24*r);top=by-24*r;
'@ @'
  by=clamp(spot?(y<64*r?y+40*r:y-24*r):(y<132*r?y+48*r:y-88*r),32*r,H-24*r);top=by-24*r;
  if(spot){ctx.strokeStyle=UIC.tx_1;ctx.lineWidth=r;ctx.beginPath();ctx.moveTo(x,y+(by>y?12:-12)*r);ctx.lineTo(x,by>y?top:top+32*r);ctx.stroke();} // v28.xx (cw-cx-markread): 4px leader between the shared glyph and its plate.
'@

SubRx @'
    ctx.save(); ctx.globalAlpha=0.55+0.45*Math.abs(Math.sin(now/180));
    ctx.strokeStyle=c; ctx.lineWidth=2.5*r;
    ctx.beginPath(); ctx.moveTo(x,y-LH(12)*r); ctx.lineTo(x+LH(9)*r,y); ctx.lineTo(x,y+LH(12)*r); ctx.lineTo(x-LH(9)*r,y); ctx.closePath(); ctx.stroke();
    ctx.restore();
'@ @'
    // v28.xx (cw-cx-markread): the same 24px filled spot diamond and dark backing in the raid, minimap and map.
    if(p.spot) colourCueGlyph(ctx,'place',x,y,2.4*r,c);
    else {
      ctx.save(); ctx.globalAlpha=0.55+0.45*Math.abs(Math.sin(now/180));
      ctx.strokeStyle=c; ctx.lineWidth=2.5*r;
      ctx.beginPath(); ctx.moveTo(x,y-LH(12)*r); ctx.lineTo(x+LH(9)*r,y); ctx.lineTo(x,y+LH(12)*r); ctx.lineTo(x-LH(9)*r,y); ctx.closePath(); ctx.stroke();
      ctx.restore();
    }
'@

SubRx @'
    netPingLabel(lbl,x,y,r);   // v28.xx (cw-cx-pingread): 16px bone text, shared plate and a clear gap above the target.
'@ @'
    if(p.spot&&p.s===NET.seat)lbl='mark  \u00b7  '+metres(dist(G.player,p))+'m';
    netPingLabel(lbl,x,y,r,!!p.spot);   // v28.xx (cw-cx-markread): attach the spot label; target names keep their safe body gap.
'@

SubRx @'
      ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832);
      ctx.moveTo(s.x-8*R,s.y); ctx.lineTo(s.x-2*R,s.y); ctx.moveTo(s.x+2*R,s.y); ctx.lineTo(s.x+8*R,s.y);
      ctx.moveTo(s.x,s.y-8*R); ctx.lineTo(s.x,s.y-2*R); ctx.moveTo(s.x,s.y+2*R); ctx.lineTo(s.x,s.y+8*R); ctx.stroke(); MMAP.ops++;
'@ @'
      if(G.waypoint.spot){colourCueGlyph(ctx,'place',s.x,s.y,2.4*R,netMarkColour(NET.seat));MMAP.ops+=3;}
      else {
        ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832);
        ctx.moveTo(s.x-8*R,s.y); ctx.lineTo(s.x-2*R,s.y); ctx.moveTo(s.x+2*R,s.y); ctx.lineTo(s.x+8*R,s.y);
        ctx.moveTo(s.x,s.y-8*R); ctx.lineTo(s.x,s.y-2*R); ctx.moveTo(s.x,s.y+2*R); ctx.lineTo(s.x,s.y+8*R); ctx.stroke(); MMAP.ops++;
      }
'@

SubRx @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,2*R,ctx.fillStyle);MMAP.ops+=3; // v28.xx (cw-cx-pingmerge): 24px target, 28px dark backing at 1080p.
'@ @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,(q.spot?2.4:2)*R,ctx.fillStyle);MMAP.ops+=3; // v28.xx (cw-cx-markread): spot glyph matches both larger views.
'@

SubRx @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,2*Math.max(1,hudRes()),p.pl?'#ff8a3c':netMarkColour(p.s)); // v28.xx (cw-cx-onemark): the same seat colour in all three views.
'@ @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,(p.spot?2.4:2)*Math.max(1,hudRes()),p.pl?'#ff8a3c':netMarkColour(p.s)); // v28.xx (cw-cx-markread): shared spot glyph.
    if(p.spot)netPingLabel('mark',px,py,Math.max(1,hudRes()),true);
'@

SubRx @'
  if(G.waypoint&&(!G.waypoint.at||G.waypoint.spot)){
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc; mapIcon(wpx,wpy,12*_MZ);   // v21.41 (W-D4): the waypoint at the map zoom
    ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx,wpy,7*_MZ,0,6.2832); ctx.stroke();
    ctx.lineWidth=_MZ;
    ctx.beginPath();
    ctx.moveTo(wpx-11*_MZ,wpy); ctx.lineTo(wpx-3*_MZ,wpy);
    ctx.moveTo(wpx+3*_MZ,wpy);  ctx.lineTo(wpx+11*_MZ,wpy);
    ctx.moveTo(wpx,wpy-11*_MZ); ctx.lineTo(wpx,wpy-3*_MZ);
    ctx.moveTo(wpx,wpy+3*_MZ);  ctx.lineTo(wpx,wpy+11*_MZ);
    ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_1; ctx.textAlign='center';
    ctx.fillText('mark',wpx,wpy-14*_MZ); ctx.textAlign='left';
  }
'@ @'
  if(G.waypoint&&(!G.waypoint.at||G.waypoint.spot)){
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc; mapIcon(wpx,wpy,12*_MZ);
    if(G.waypoint.spot){
      colourCueGlyph(ctx,'place',wpx,wpy,2.4*Math.max(1,hudRes()),netMarkColour(NET.seat));
      netPingLabel('mark',wpx,wpy,Math.max(1,hudRes()),true);
    } else {
      // v28.xx (cw-cx-markread): legacy map callers keep the old ring until they enter the shared mark setter.
      ctx.strokeStyle=netMarkColour(NET.seat); ctx.lineWidth=2*_MZ;
      ctx.beginPath(); ctx.arc(wpx,wpy,7*_MZ,0,6.2832); ctx.stroke();
      ctx.lineWidth=_MZ;
      ctx.beginPath();
      ctx.moveTo(wpx-11*_MZ,wpy); ctx.lineTo(wpx-3*_MZ,wpy);
      ctx.moveTo(wpx+3*_MZ,wpy); ctx.lineTo(wpx+11*_MZ,wpy);
      ctx.moveTo(wpx,wpy-11*_MZ); ctx.lineTo(wpx,wpy-3*_MZ);
      ctx.moveTo(wpx,wpy+3*_MZ); ctx.lineTo(wpx,wpy+11*_MZ);
      ctx.stroke();
      ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_1; ctx.textAlign='center';
      ctx.fillText('mark',wpx,wpy-14*_MZ); ctx.textAlign='left';
    }
  }
'@

SubRx @'
var VER='36.52';
'@ @'
var VER='36.53';
'@

$pat = "(?m)^  now:'v36\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.53: Spot marks share one filled diamond across the raid and both maps, with a nearby label. Check 36.53 fails on v36.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
