$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE: THE RESIZE GRIP HAS NOWHERE TO DRAG TO.
# ============
# ============ "corner drag to size for lower right corner needs to be in lower
# ============ left side, otherwise there's nowhere to drag to increase size",
# ============ 2026-09-04.
# ============
# ============ REPRODUCED, every panel measured at 1920x1080:
# ============   gear    right edge 8 pixels from the screen edge, bottom 5
# ============   cond    right edge 17 pixels from the screen edge
# ============   body    1374 to the right, legend 1445, raiders 1529
# ============ The grip has always been the panel's bottom-RIGHT corner, so on
# ============ the gear panel it sits 8 pixels from the edge of the monitor. The
# ============ resize is driven by how much further the pointer gets from the
# ============ opposite corner, so with 8 pixels of travel there is effectively
# ============ no way to make that panel bigger. That is his note exactly.
# ============
# ============ THE RULE, in his words: the grip goes on the corner that faces
# ============ INTO the screen. A panel pinned to the right edge grips on its
# ============ left; everything else is unchanged, because a grip that moved on
# ============ panels with room would be a change for its own sake.
# ============
# ============ ONE FUNCTION DECIDES, and all four places ask it: the mousedown
# ============ that starts a resize, the drag that sizes it, the drawing of the
# ============ little diagonals, and the cursor shape. They disagreeing is how a
# ============ grip ends up looking like it is somewhere it is not.
SubRx @'
function hudGripS(){ return LH(20); }
'@ @'
function hudGripS(){ return LH(20); }
// v10.91, HIS NOTE: WHICH CORNER THE GRIP LIVES ON. The panel is sized by how
// far the pointer gets from the corner OPPOSITE the grip, so a grip with no room
// to travel is a panel that cannot grow. A panel whose right edge is against the
// side of the screen grips on its LEFT instead, and is sized from its top-right.
// Everything with room keeps the bottom-right corner every window has used for
// this since before he was born.
// Returns the grip corner and the anchor it is measured from.
function hudGrip(HB){
  var gs=hudGripS();
  var Wv=(typeof W==='number'&&W>0)?W:(window.innerWidth||1920);
  var left=((HB.x+HB.w)>(Wv-gs-10));
  return left
    ? {x:HB.x, y:HB.y+HB.h, ax:HB.x+HB.w, ay:HB.y, left:true,  gs:gs}
    : {x:HB.x+HB.w, y:HB.y+HB.h, ax:HB.x, ay:HB.y, left:false, gs:gs};
}
// Is the pointer on that grip. One reader, so the click, the cursor and the
// drawing can never disagree about where it is.
function hudOnGrip(HB,mx,my){
  var G2=hudGrip(HB);
  var x0=G2.left?G2.x:(G2.x-G2.gs), x1=G2.left?(G2.x+G2.gs):G2.x;
  return mx>=x0&&mx<=x1&&my>=G2.y-G2.gs&&my<=G2.y;
}
'@

# ---- 1. the mousedown that starts a resize
SubRx @'
        if(HUDZ[hk]!==undefined){
          var _gs=hudGripS();
          var _gx=HB2.x+HB2.w,_gy=HB2.y+HB2.h;
          if(mouse.x>=_gx-_gs&&mouse.x<=_gx&&mouse.y>=_gy-_gs&&mouse.y<=_gy){
            // The diagonal from the panel origin to the pointer IS the size, so
            // the panel tracks the corner under his hand rather than a guess.
            HUDRESIZE={id:hk,z0:hudUserZ(hk),
              d0:Math.max(8,Math.hypot(mouse.x-HB2.x,mouse.y-HB2.y)),
              ox:HB2.x,oy:HB2.y};
            blip('pick');
            return;
          }
        }
'@ @'
        if(HUDZ[hk]!==undefined){
          if(hudOnGrip(HB2,mouse.x,mouse.y)){
            // The diagonal from the ANCHOR corner to the pointer IS the size, so
            // the panel tracks the corner under his hand rather than a guess.
            // v10.91: the anchor is whichever corner the grip is not.
            var _ga=hudGrip(HB2);
            HUDRESIZE={id:hk,z0:hudUserZ(hk),
              d0:Math.max(8,Math.hypot(mouse.x-_ga.ax,mouse.y-_ga.ay)),
              ox:_ga.ax,oy:_ga.ay};
            blip('pick');
            return;
          }
        }
'@

# ---- 2. the drawing of the diagonals
SubRx @'
      var gx=GB.x+GB.w, gy=GB.y+GB.h;
      var hot=(HUDRESIZE&&HUDRESIZE.id===gk)||
              (mouse.x>=gx-gs&&mouse.x<=gx&&mouse.y>=gy-gs&&mouse.y<=gy);
'@ @'
      // v10.91: the corner that faces into the screen, which on a panel pinned
      // to the right edge is its left one.
      var _GG=hudGrip(GB), gx=_GG.x, gy=_GG.y, _gL=_GG.left;
      var hot=(HUDRESIZE&&HUDRESIZE.id===gk)||hudOnGrip(GB,mouse.x,mouse.y);
'@
SubRx @'
        ctx.moveTo(gx-f,gy-2); ctx.lineTo(gx-2,gy-f);
'@ @'
        // Mirrored when the grip is on the left, or the strokes would point out
        // of the panel instead of into its corner.
        if(_gL){ ctx.moveTo(gx+f,gy-2); ctx.lineTo(gx+2,gy-f); }
        else   { ctx.moveTo(gx-f,gy-2); ctx.lineTo(gx-2,gy-f); }
'@

# ---- 3. the cursor shape
SubRx @'
    if(HUDZ[k]!==undefined&&!hudOff(k).c){
      var _gk=hudGripS();
      if(mx>=HB.x+HB.w-_gk&&mx<=HB.x+HB.w&&my>=HB.y+HB.h-_gk&&my<=HB.y+HB.h)
        return {id:k,part:'grip'};
    }
'@ @'
    if(HUDZ[k]!==undefined&&!hudOff(k).c){
      if(hudOnGrip(HB,mx,my)) return {id:k,part:'grip'};
    }
'@

SubRx @'
var VER='10.90';
'@ @'
var VER='10.91';
'@
SubRx @'
  now:'v10.90: the text collision in the lower right, your screenshot. EXTRACTION - OPEN is a world label drawn at the ring, and the gun name under it is HUD text pinned to the corner that nothing knew was there. The corner now measures itself and world labels lift clear of it.',
'@ @'
  now:'v10.91: the resize grip had nowhere to drag to, your note. The gear panel sits 8 pixels from the right of the screen and its grip was in that corner, so there was no room to make it bigger. A panel pinned to the right edge grips on its LEFT now and is sized from its top-right corner.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE RESIZE GRIP MOVES TO THE SIDE THAT HAS ROOM. A panel against the right edge of the screen had its drag corner jammed into that edge with eight pixels of travel, so it could not be made bigger. Those panels grip on their left now.',
'@
SubRx @'
var WHATSNEW_VER='10.89';
'@ @'
var WHATSNEW_VER='10.91';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
