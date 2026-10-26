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

# THE MINIMAP FOLDS ON ITS CHEVRON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawMinimap(){
  var p=G&&G.player, r, R, sc, bs, cut, x0, y0, ax, ay, bx, by, cx, cy;
  MMAP.box=null; MMAP.ops=0;
  if(!p||G.sim||!G.map||!(W>0)||!(H>0)) return 0;
  if(!mmShown()) return 0;   // v24.xx (minimap3): the Settings row, the map, the backpack, the end cards and the Undercroft
  r=mmRect(); R=hudRes(); sc=r.w/mmSpan(); cut=Math.round(10*TRG.z);   // v26.xx (settings7): MINIMAP ZOOM; v30.xx (cw-trcol): the corner is cut like the panels beside it
  bs=Math.min(sc*Math.max(1,DPRH||1),4096/Math.max(WORLD_W,WORLD_H));
  if(!MMAP.cv||MMAP.map!==G.map||Math.abs(MMAP.bs-bs)>1e-6){ MMAP.cv=mmBake(bs); MMAP.map=G.map; MMAP.bs=bs; }
'@ @'
// v28.xx (cw-mmfold), HIS NOTE (2026-10-25): "make it so the mini map is cut off by defauolt and also make it where it is minimizable". Off by default holds since v33.36 (cw-mmoff); this is the fold.
// The minimap folds on the same chevron as run info, the pillager board and the keys list (HUDBOX.mmap, P.hud.mmap.c, the mousedown fold toggle, the hudHit pointer).
// The strip and the chevron are laid out in the run info panel's own zoom space about the top right corner, so the folded minimap is the folded run info plate:
// the same height, type and chevron, and the chevron sits on the same spot open and folded, so the second click lands where the first one did.
// The Settings MINIMAP row stays the one place that turns it on and sizes it; the fold never writes CFG.mmSz or the row.
function mmFoldBox(r){
  var z=(HUDZ.cond||1)*hudRes()*hudUserZ('cond'), bx, by, bw, bh;
  if(!(z>0)) z=1;
  bx=W-(W-r.x)/z; by=r.y/z; bw=r.w/z; bh=16+LH(13);
  return {z:z,x:bx,y:by,w:bw,h:bh,yb:by+8+LH(8),tg:{x:bx+bw-LH(20),y:by,w:LH(20),h:bh}};
}
function drawMinimap(){
  var p=G&&G.player, r, R, sc, bs, cut, x0, y0, ax, ay, bx, by, cx, cy, f, t;
  MMAP.box=null; MMAP.ops=0;
  delete HUDBOX.mmap;   // v28.xx (cw-mmfold): a hidden minimap (off in Settings, the map or the backpack open, the end cards, the Undercroft) leaves no box to take a click
  if(!p||G.sim||!G.map||!(W>0)||!(H>0)) return 0;
  if(!mmShown()) return 0;   // v24.xx (minimap3): the Settings row, the map, the backpack, the end cards and the Undercroft
  r=mmRect(); R=hudRes(); sc=r.w/mmSpan(); cut=Math.round(10*TRG.z);   // v26.xx (settings7): MINIMAP ZOOM; v30.xx (cw-trcol): the corner is cut like the panels beside it
  bs=Math.min(sc*Math.max(1,DPRH||1),4096/Math.max(WORLD_W,WORLD_H));
  if(!MMAP.cv||MMAP.map!==G.map||Math.abs(MMAP.bs-bs)>1e-6){ MMAP.cv=mmBake(bs); MMAP.map=G.map; MMAP.bs=bs; }
  f=mmFoldBox(r);   // v28.xx (cw-mmfold): the fold comes after the bake above, so a folded minimap is still baked at the raid start and the first unfold does not stall a frame
  if(hudOff('mmap').c){   // v28.xx (cw-mmfold): folded, a slim strip with its name and the chevron; the run info panel and the goals hang off MMAP.box, so they move up under it
    ctx.save(); hudZoomIn('cond',W,0);
    hudPanel(f.x,f.y,f.w,f.h,undefined,1);
    ctx.font=FS(TYPE.label); ctx.textAlign='left'; ctx.textBaseline='alphabetic'; ctx.fillStyle=HUDC.text;
    ctx.fillText('minimap',f.x+8,f.yb);
    hudChev(f.x+f.w-8,f.yb,false);
    ctx.restore();
    HUDBOX.mmap=hudZoomRect('cond',W,0,{x:f.x,y:f.y,w:f.w,h:f.h,tg:f.tg});
    MMAP.box={x:HUDBOX.mmap.x,y:HUDBOX.mmap.y,w:HUDBOX.mmap.w,h:HUDBOX.mmap.h};
    MMAP.ops+=3;
    return 1;
  }
'@

SubRx @'
  try{ mmMarks(r,sc,R); }catch(_mk){ ctx.globalAlpha=1; ctx.textAlign='left'; ctx.textBaseline='alphabetic'; }   // v24.xx (minimap2): the markers, under your arrow
'@ @'
  // v28.xx (cw-mmfold): open, the fold tab in the top right corner: one LH(20) square in the run info zoom, the panel colour, on the spot the folded strip draws its chevron.
  // It is drawn here, under the markers, so an edge arrow, its badge or a machine in that corner still shows on top of it; the chevron goes on last, after the frame.
  // This square is the whole click box (HUDBOX.mmap below): what you click is what you see, and the map around it lets a shot through as before.
  t=hudZoomRect('cond',W,0,{x:f.tg.x,y:f.tg.y,w:f.tg.w,h:LH(20)});
  ctx.fillStyle='rgba(17,19,21,.88)'; ctx.fillRect(t.x,t.y,t.w,t.h); MMAP.ops++;
  try{ mmMarks(r,sc,R); }catch(_mk){ ctx.globalAlpha=1; ctx.textAlign='left'; ctx.textBaseline='alphabetic'; }   // v24.xx (minimap2): the markers, under your arrow
'@

SubRx @'
  ctx.restore();
  MMAP.box=r;
  return 1;
}
'@ @'
  ctx.restore();
  // v28.xx (cw-mmfold): the open chevron on the fold tab, over the frame. Only the tab takes a click: the map under it never did, and a shot over it still goes through.
  // The minimap is fixed in the column, so it has no drag bar (hudHit and the mousedown skip it).
  ctx.save(); hudZoomIn('cond',W,0); hudChev(f.x+f.w-8,f.yb,true); ctx.restore(); MMAP.ops++;
  HUDBOX.mmap={x:t.x,y:t.y,w:t.w,h:t.h,tg:{x:t.x,y:t.y,w:t.w,h:t.h}};
  MMAP.box=r;
  return 1;
}
'@

SubRx @'
    if(inRect(hudBar(HB),mx,my)) return {id:k,part:'bar'};
'@ @'
    if(k!=='mmap'&&inRect(hudBar(HB),mx,my)) return {id:k,part:'bar'};   // v28.xx (cw-mmfold): the minimap is fixed in the column, it has no drag bar
'@

SubRx @'
        if(inRect(hudBar(HB2),mouse.x,mouse.y)){
'@ @'
        if(hk!=='mmap'&&inRect(hudBar(HB2),mouse.x,mouse.y)){   // v28.xx (cw-mmfold): the minimap is fixed in the column, never dragged
'@

SubRx @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@ @'
  if(HUDBOX.mmap){ var _mmh=HUDBOX.mmap; delete HUDBOX.mmap; HUDBOX.mmap=_mmh; }   // v28.xx (cw-mmfold): the minimap is drawn first and every panel over it, so its box is tried last: run info, the keys list or the pillager board dragged over its fold tab keep their own clicks
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@

SubRx @'
var VER='34.87';
'@ @'
var VER='34.88';
'@

$pat = "(?m)^  now:'v34\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.88: The minimap has a fold arrow on a small dark tab in its top right corner, like run info. Click it and the minimap shrinks to a thin minimap strip and run info slides up. Click it again to get the map back. Turn the minimap on in Settings first. Watch for: the arrow being easy to see over the map, a shot fired over the minimap next to the tab still going off, and an objective arrow in that corner drawn over the tab. Check 34.88 fails on v34.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
