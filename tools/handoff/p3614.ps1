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

# WORLD MARKERS SHARE ONE LABEL STYLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _cg=_ctq[_cq]; wc.font=FS(_cg.f||TYPE.head);
'@ @'
      var _cg=_ctq[_cq]; wc.font=_cg.cache?uiFont('label',Math.max(1,hudRes())/WTX.z):FS(_cg.f||TYPE.head); // v28.xx (cw-cx-worldchips): cache and extraction labels share the 16px screen label size.
'@

SubRx @'
      var _cp=_cg.cache?8:2, _cx=_cg.x, _ch=_ca+_cd+_cp*2;
'@ @'
      // v28.xx (cw-cx-worldchips): a cache label has a 32px minimum panel, matching the extraction chip; reserve the full panel for the overlap test.
      var _cp=_cg.cache?Math.max(8*Math.max(1,hudRes())/WTX.z,(32*Math.max(1,hudRes())/WTX.z-_ca-_cd)/2):2, _cx=_cg.x, _ch=_ca+_cd+_cp*2;
'@

SubRx @'
function extEdgeArrow(E){
  var hr=Math.max(1,hudRes()), p=G.player, ps, ox=W/2, oy=H/2, a0, lab, f=hudFS(TYPE.head), tw, bw, bh, k, s, a=0, cx=0, cy=0, ok=false, mx, rx, ry, i, B, L=[], col='#4de3d0', ar, ux, uy, tx, ty;
  EXTARROW.on=0;
  if(!E||!E.za||!E.z||!G) return false;
  ps=p?w2s(p.x,0,p.y):null; if(ps){ ox=ps.x; oy=ps.y; }
  a0=Math.atan2(E.sy-oy,E.sx-ox);
  lab=extLetter(E.z).toLowerCase()+' '+metres(E.d)+'m';
  mx=LH(6)*hr; ar=LH(8)*hr;
  ctx.save();
  try{
    ctx.font=f; tw=ctx.measureText(TX(lab)).width; bw=Math.round(tw+LH(16)*hr); bh=Math.round(msgPx(f)*1.5);
    // what it keeps off: every HUD panel and edge stack as last drawn, the gun card corner, the teammate rows, the feed, the pickup stack's column even while it is
    // empty, and the clock with the pill
    for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    for(k in EDGEBOX){ B=EDGEBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) L.push(NETTEAMBOX);
    if(G.cornerBox) L.push(G.cornerBox);
    // v28.xx (cw-cx-tagstack): the CEO cache-name P0: give the chip its own space beside this frame's world labels, including the arrow and margin.
    if(WLTEXT.g===G) for(i=0;i<WLTEXT.boxes.length;i++) L.push(WLTEXT.boxes[i]);
    if(typeof FEEDBOX==='object'&&FEEDBOX&&FEEDBOX.on&&FEEDBOX.w>0) L.push(FEEDBOX);
    L.push({x:W-LH(250)*hr,y:Math.round(H*0.5),w:LH(250)*hr,h:H});
    L.push({x:W/2-LH(170)*hr,y:0,w:LH(340)*hr,h:LH(130)*hr});
    var hit=function(x0,y0){ var j, b; for(j=0;j<L.length;j++){ b=L[j]; if(x0+bw/2+ar*2+mx>b.x&&x0-bw/2-ar*2-mx<b.x+b.w&&y0+bh/2+ar+mx>b.y&&y0-bh/2-ar-mx<b.y+b.h) return true; } return false; };
    rx=W/2-bw/2-ar*2-LH(16)*hr; ry=H/2-bh/2-ar-LH(16)*hr;
    for(s=1;s>=0.55&&!ok;s-=0.15) for(i=0;i<29&&!ok;i++){ a=a0+((i&1)?1:-1)*Math.ceil(i/2)*0.06; cx=W/2+Math.cos(a)*rx*s; cy=H/2+Math.sin(a)*ry*s; if(!hit(cx,cy)) ok=true; }
    if(!ok){ cx=W/2+Math.cos(a0)*rx*0.55; cy=H/2+Math.sin(a0)*ry*0.55; }
    cx=Math.round(cx); cy=Math.round(cy);
    hudPlate(Math.round(cx-bw/2),Math.round(cy-bh/2),bw,bh,null,HUDC.plate);
    ctx.textAlign='center'; ctx.fillStyle=col;
    hudText(lab,cx,Math.round(cy+msgPx(f)*0.36));
    // the arrow just outside the plate on the side of the exit, pointing at it
    ux=cx+Math.cos(a0)*(bw/2+ar*1.2); uy=cy+Math.sin(a0)*(bh/2+ar*0.9);
    tx=ux+Math.cos(a0)*ar; ty=uy+Math.sin(a0)*ar;
    ctx.beginPath(); ctx.moveTo(tx,ty);
    ctx.lineTo(ux+Math.cos(a0+2.3)*ar*0.9,uy+Math.sin(a0+2.3)*ar*0.9);
    ctx.lineTo(ux+Math.cos(a0-2.3)*ar*0.9,uy+Math.sin(a0-2.3)*ar*0.9);
    ctx.closePath(); ctx.fillStyle=col; ctx.fill(); ctx.lineWidth=Math.max(1.5,1.5*hr); ctx.strokeStyle=HUDC.ink; ctx.lineJoin='round'; ctx.stroke();
    EXTARROW.on=1; EXTARROW.x=cx-bw/2; EXTARROW.y=cy-bh/2; EXTARROW.w=bw; EXTARROW.h=bh; EXTARROW.t=lab;
  } finally { ctx.restore(); }
  return true;
}
'@ @'
// v28.xx (cw-cx-worldchips): the critic on cache pictures asked for matching panels and label sizes. Keep teal on the exit arrow; the name and distance read in cream.
function extEdgeArrow(E){
  var hr=Math.max(1,hudRes()), p=G.player, ps, ox=W/2, oy=H/2, a0, lab, f=uiFont('label',hr), tw, bw, bh, k, s, a=0, cx=0, cy=0, ok=false, mx, rx, ry, i, B, L=[], col='#4de3d0', ar, ux, uy, tx, ty;
  EXTARROW.on=0;
  if(!E||!E.za||!E.z||!G) return false;
  ps=p?w2s(p.x,0,p.y):null; if(ps){ ox=ps.x; oy=ps.y; }
  a0=Math.atan2(E.sy-oy,E.sx-ox);
  lab=extLetter(E.z).toLowerCase()+' '+metres(E.d)+'m';
  mx=LH(6)*hr; ar=LH(8)*hr;
  ctx.save();
  try{
    ctx.font=f; tw=ctx.measureText(TX(lab)).width; bw=Math.round(tw+LH(16)*hr); bh=Math.round(32*hr);
    // what it keeps off: every HUD panel and edge stack as last drawn, the gun card corner, the teammate rows, the feed, the pickup stack's column even while it is
    // empty, and the clock with the pill
    for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    for(k in EDGEBOX){ B=EDGEBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) L.push(NETTEAMBOX);
    if(G.cornerBox) L.push(G.cornerBox);
    // v28.xx (cw-cx-tagstack): the CEO cache-name P0: give the chip its own space beside this frame's world labels, including the arrow and margin.
    if(WLTEXT.g===G) for(i=0;i<WLTEXT.boxes.length;i++) L.push(WLTEXT.boxes[i]);
    if(typeof FEEDBOX==='object'&&FEEDBOX&&FEEDBOX.on&&FEEDBOX.w>0) L.push(FEEDBOX);
    L.push({x:W-LH(250)*hr,y:Math.round(H*0.5),w:LH(250)*hr,h:H});
    L.push({x:W/2-LH(170)*hr,y:0,w:LH(340)*hr,h:LH(130)*hr});
    var hit=function(x0,y0){ var j, b; for(j=0;j<L.length;j++){ b=L[j]; if(x0+bw/2+ar*2+mx>b.x&&x0-bw/2-ar*2-mx<b.x+b.w&&y0+bh/2+ar+mx>b.y&&y0-bh/2-ar-mx<b.y+b.h) return true; } return false; };
    rx=W/2-bw/2-ar*2-LH(16)*hr; ry=H/2-bh/2-ar-LH(16)*hr;
    for(s=1;s>=0.55&&!ok;s-=0.15) for(i=0;i<29&&!ok;i++){ a=a0+((i&1)?1:-1)*Math.ceil(i/2)*0.06; cx=W/2+Math.cos(a)*rx*s; cy=H/2+Math.sin(a)*ry*s; if(!hit(cx,cy)) ok=true; }
    if(!ok){ cx=W/2+Math.cos(a0)*rx*0.55; cy=H/2+Math.sin(a0)*ry*0.55; }
    cx=Math.round(cx); cy=Math.round(cy);
    uiPanel(ctx,Math.round(cx-bw/2),Math.round(cy-bh/2),bw,bh,null);
    ctx.textAlign='center'; ctx.fillStyle=UIC.tx_1;
    hudText(lab,cx,Math.round(cy+msgPx(f)*0.36));
    // the arrow just outside the plate on the side of the exit, pointing at it
    ux=cx+Math.cos(a0)*(bw/2+ar*1.2); uy=cy+Math.sin(a0)*(bh/2+ar*0.9);
    tx=ux+Math.cos(a0)*ar; ty=uy+Math.sin(a0)*ar;
    ctx.beginPath(); ctx.moveTo(tx,ty);
    ctx.lineTo(ux+Math.cos(a0+2.3)*ar*0.9,uy+Math.sin(a0+2.3)*ar*0.9);
    ctx.lineTo(ux+Math.cos(a0-2.3)*ar*0.9,uy+Math.sin(a0-2.3)*ar*0.9);
    ctx.closePath(); ctx.fillStyle=col; ctx.fill(); ctx.lineWidth=Math.max(1.5,1.5*hr); ctx.strokeStyle=HUDC.ink; ctx.lineJoin='round'; ctx.stroke();
    EXTARROW.on=1; EXTARROW.x=cx-bw/2; EXTARROW.y=cy-bh/2; EXTARROW.w=bw; EXTARROW.h=bh; EXTARROW.t=lab;
  } finally { ctx.restore(); }
  return true;
}
'@

SubRx @'
var VER='36.13';
'@ @'
var VER='36.14';
'@

$pat = "(?m)^  now:'v36\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.14: Cache and extraction markers share one readable label size and panel style. The exit arrow stays teal. Check 36.14 fails on v36.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
