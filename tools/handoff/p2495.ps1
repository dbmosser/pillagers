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

# A MINIMAP IN THE CORNER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function drawHUD(){
'@ @'
}
// v24.xx (minimap1), HIS ORDER (2026-10-12): "add minimap". A MINIMAP IN THE TOP RIGHT CORNER OF THE RAID HUD. North up like the
// sector map, MMSPAN (1000) world units across around you at the game's own scale, on a graphite plate with a thin amber edge and
// the top left corner cut like every HUD panel. The walls, buildings, water and trees are painted ONCE per raid into an offscreen
// canvas at the minimap's own scale (mmBake, the bake pattern of v18.15), and each frame draws one clipped piece of it, so a frame
// costs the same handful of calls in an empty yard and in a packed street. You are the amber arrow in the middle, pointing where
// you face. It sits under the credits readout (and the notes line under it), and the CONDITIONS panel starts under it now, so the
// two never overlap; the kill feed already follows that panel. It grows with the screen (hudRes) like the rest of the HUD. The
// bake is redone only when the map or the pixel scale changes (a new raid, a resize). Cosmetic: no seeded draw and no game state.
var MMSPAN=1000, MMAP={cv:null,map:null,bs:0,bakes:0,box:null,ops:0};
function mmRect(){
  var R=hudRes(), s=Math.round(216*R), T=G&&G.tel, top;
  top=Math.ceil(topRightBottom()+8+((T&&T.notes&&T.notes.length)?LH(20):0));
  top=Math.max(Math.round(16*R),top);
  return {x:Math.round(W-16*R-s),y:top,w:s,h:s};
}
function mmBottom(){ var b=MMAP.box; return b?(b.y+b.h):0; }
function mmPath(c,r,cut){ c.beginPath(); c.moveTo(r.x+cut,r.y); c.lineTo(r.x+r.w,r.y); c.lineTo(r.x+r.w,r.y+r.h); c.lineTo(r.x,r.y+r.h); c.lineTo(r.x,r.y+cut); c.closePath(); }
function mmBake(bs){
  var m=G.map, ww=WORLD_W, wh=WORLD_H, cv2, c, i, q, d, gx, mn=1.3/bs;
  cv2=document.createElement('canvas'); cv2.width=Math.max(1,Math.ceil(ww*bs)); cv2.height=Math.max(1,Math.ceil(wh*bs));
  c=cv2.getContext('2d'); if(!c) return null;
  c.setTransform(bs,0,0,bs,0,0);
  c.fillStyle='#111315'; c.fillRect(0,0,ww,wh);
  // the streets a shade up from the yards, so the way through reads at a glance
  c.fillStyle='#1b1f22';
  for(i=0;i<(m.roadRects||[]).length;i++){ q=m.roadRects[i]; c.fillRect(q.x,q.y,q.w,q.h); }
  // a faint 250 unit grid, so movement shows even in an open yard
  c.strokeStyle='rgba(239,233,220,.04)'; c.lineWidth=1/bs; c.beginPath();
  for(gx=250;gx<ww;gx+=250){ c.moveTo(gx,0); c.lineTo(gx,wh); }
  for(gx=250;gx<wh;gx+=250){ c.moveTo(0,gx); c.lineTo(ww,gx); }
  c.stroke();
  // buildings: a lit floor with a faint wash of their district colour, so inside and outside never read alike
  for(i=0;i<(m.buildings||[]).length;i++){
    q=m.buildings[i];
    c.fillStyle=q.ruined?'#1d2124':'#2c3236'; c.fillRect(q.x,q.y,q.w,q.h);
    d=DISTRICTS[q.d];
    if(!q.ruined&&d&&typeof d.wallTop==='string'&&d.wallTop.length===7){ c.fillStyle=hexA(d.wallTop,.12); c.fillRect(q.x,q.y,q.w,q.h); }
  }
  c.fillStyle='rgba(64,132,164,.6)';
  for(i=0;i<(m.water||[]).length;i++){ q=m.water[i]; c.fillRect(q.x,q.y,q.w,q.h); }
  c.fillStyle='rgba(78,104,80,.45)';
  for(i=0;i<(m.bushes||[]).length;i++){ q=m.bushes[i]; if(!(q.r>0)) continue; c.beginPath(); c.arc(q.x,q.y,Math.max(mn,q.r*0.8),0,6.2832); c.fill(); }
  for(i=0;i<(m.walls||[]).length;i++){
    q=m.walls[i];
    if(q.furn) continue;
    if(q.tree){ c.fillStyle='rgba(78,104,80,.6)'; c.beginPath(); c.arc(q.x+q.w/2,q.y+q.h/2,Math.max(mn*1.5,(q.canopy||q.w)*0.5),0,6.2832); c.fill(); continue; }
    c.fillStyle=q.door?'rgba(164,171,175,.35)':((q.wreck||q.ruin||q.ledge)?'#626a6e':'#b4babd');
    c.fillRect(q.x,q.y,Math.max(mn,q.w),Math.max(mn,q.h));
  }
  MMAP.bakes++;
  return cv2;
}
function drawMinimap(){
  var p=G&&G.player, r, R, sc, bs, cut, x0, y0, ax, ay, bx, by, cx, cy;
  MMAP.box=null; MMAP.ops=0;
  if(!p||G.sim||!G.map||!(W>0)||!(H>0)) return 0;
  r=mmRect(); R=hudRes(); sc=r.w/MMSPAN; cut=Math.round(10*R);
  bs=Math.min(sc*Math.max(1,DPRH||1),4096/Math.max(WORLD_W,WORLD_H));
  if(!MMAP.cv||MMAP.map!==G.map||Math.abs(MMAP.bs-bs)>1e-6){ MMAP.cv=mmBake(bs); MMAP.map=G.map; MMAP.bs=bs; }
  ctx.save();
  mmPath(ctx,r,cut); ctx.fillStyle='rgba(11,12,13,.92)'; ctx.fill(); MMAP.ops++;
  ctx.clip();
  x0=p.x-MMSPAN/2; y0=p.y-MMSPAN/2;
  ax=Math.max(0,x0); ay=Math.max(0,y0); bx=Math.min(WORLD_W,x0+MMSPAN); by=Math.min(WORLD_H,y0+MMSPAN);
  if(MMAP.cv&&bx>ax&&by>ay){
    ctx.drawImage(MMAP.cv,ax*bs,ay*bs,(bx-ax)*bs,(by-ay)*bs,r.x+(ax-x0)*sc,r.y+(ay-y0)*sc,(bx-ax)*sc,(by-ay)*sc); MMAP.ops++;
  }
  // you: an amber arrow, ink edged, pointing where you face
  cx=r.x+r.w/2; cy=r.y+r.h/2;
  ctx.translate(cx,cy); ctx.rotate(p.face||0);
  ctx.beginPath(); ctx.moveTo(9*R,0); ctx.lineTo(-6*R,6*R); ctx.lineTo(-3*R,0); ctx.lineTo(-6*R,-6*R); ctx.closePath();
  ctx.lineJoin='round'; ctx.lineWidth=2.5*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=UIC.acc; ctx.fill(); MMAP.ops+=2;
  ctx.restore();
  // the frame: a hairline amber edge, and N at the top
  ctx.save();
  mmPath(ctx,{x:r.x+0.5,y:r.y+0.5,w:r.w-1,h:r.h-1},Math.max(0,cut-0.5));
  ctx.strokeStyle='rgba(245,183,59,.62)'; ctx.lineWidth=Math.max(1,R); ctx.stroke(); MMAP.ops++;
  ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=HUDC.dim;
  hudText('N',cx,r.y+Math.round(15*R)); MMAP.ops+=2;
  ctx.restore();
  MMAP.box=r;
  return 1;
}
function drawHUD(){
'@

SubRx @'
  ctx.save(); hudZoomIn('cond',W,0);
'@ @'
  try{ drawMinimap(); }catch(_mm){ MMAP.box=null; }   // v24.xx (minimap1): his "add minimap", top right, before CONDITIONS so it can start below it
  ctx.save(); hudZoomIn('cond',W,0);
'@

SubRx @'
    by=Math.max(by,Math.ceil((topRightBottom()+8+((T.notes&&T.notes.length)?LH(20):0))/_cz));   // v12.05: and under the notes-logged line when there is one
'@ @'
    by=Math.max(by,Math.ceil((topRightBottom()+8+((T.notes&&T.notes.length)?LH(20):0))/_cz));   // v12.05: and under the notes-logged line when there is one
    if(MMAP.box) by=Math.max(by,Math.ceil((mmBottom()+Math.round(10*hudRes()))/_cz));   // v24.xx (minimap1): and under the minimap
'@

SubRx @'
var VER='24.94';
'@ @'
var VER='24.95';
'@

$pat = "(?m)^  now:'v24\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.95: A minimap in the top right corner shows the street around you. Check 24.95 fails on v24.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
