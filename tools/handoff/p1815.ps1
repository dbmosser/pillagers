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

# THE WALLS BAKE THEIR WEATHERING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function render2D(dt){
'@ @'
// v18.15, AAA CHECK after his report of 2026-10-03 (frame rate lag while running into new ground): THE WALLS BAKE THEIR
// WEATHERING. Every wall face was repainted from scratch every frame: rain streaks, damp line, crack, bitten roofline and
// stains, thirty to forty small fills per wall and three to four thousand a frame in a built-up street (measured: 3,650
// fillRect calls a frame at the spawn, 4,270 walking south into the houses). The face of a wall is a pure function of its
// position (grit), so it is painted once into a small sprite the first time it comes into view and drawn in one call after
// that. The sprite is painted at the screen scale, so it is as sharp as the live paint was. Sprites are kept for the walls
// seen lately (320 at most, the oldest quarter dropped when full) and all dropped when the map, the time of day, the decay
// setting or the screen scale changes. A door and a window are painted live as before; so is a wall when baking is off
// (CFG.wallBake 0). Nothing about what is painted changed: wallPaint is the old block, moved.
var WALLSPR={m:{},n:0,key:'',max:320,tick:0};
function wallSpriteScale(){ var z=1; try{ z=ZOOM()*(DPR||1); }catch(_z){ z=1; } return Math.max(1,Math.min(2,Math.round(z))); }
function wallPaint(c,wl2,d3,LIFT){
  c.fillStyle=dcol(d3,'wall');
  c.fillRect(wl2.x,wl2.y+wl2.h-LIFT,wl2.w,LIFT);
  c.fillStyle=dcol(d3,'wallTop');
  c.fillRect(wl2.x,wl2.y-LIFT,wl2.w,wl2.h);
  if(CFG.decay!==0){
    var _fy=wl2.y+wl2.h-LIFT, _g, _st;
    // REGULARITY WAS THE BUG IN THE FIRST CUT OF THIS. Stepping the wall at a
    // fixed interval and only varying WHETHER a mark appears gives you marks
    // on a grid, and a grid reads as tiling, which reads as a surface someone
    // manufactured and fitted. The opposite of the note. So the step itself
    // is jittered as well as the presence, and nothing here lines up with
    // anything else on the wall.
    // RAIN STREAKS. Water runs off a roof and carries the dirt down with it,
    // and on a building nobody has washed since before anyone alive was born
    // that is the single most legible mark of age.
    c.fillStyle='rgba(14,11,9,.30)';
    for(_g=grit(wl2.x,wl2.y)*9;_g<wl2.w;_g+=4+grit(wl2.x+_g,wl2.y)*17){
      var _r1=grit(wl2.x+_g|0,wl2.y+1);
      if(_r1>0.42) c.fillRect(wl2.x+_g,_fy,0.8+_r1*1.8,LIFT*(0.30+_r1*0.66));
    }
    // THE DAMP LINE. Ground water wicks up masonry and rots the bottom of it.
    // Ragged along its top edge on purpose: a straight band would read as a
    // painted skirting, which is maintenance, which is the opposite of this.
    c.fillStyle='rgba(26,30,22,.34)';
    for(_g=0;_g<wl2.w;_g+=3+grit(wl2.x+_g,wl2.y+9)*8){
      var _r2=grit(wl2.x+_g|0,wl2.y+9);
      _st=Math.min(3+_r2*8,wl2.w-_g);
      c.fillRect(wl2.x+_g,_fy+LIFT-LIFT*0.30*(0.35+_r2),_st,LIFT*0.30*(0.35+_r2));
    }
    // ONE CRACK, on roughly a third of walls. Every wall cracked is noise;
    // a third of them cracked is a neighbourhood that has been left alone.
    var _r3=grit(wl2.x,wl2.y+3);
    if(_r3>0.66&&wl2.w>18){
      var _cx=wl2.x+wl2.w*(0.2+_r3*0.55), _cs=(_r3>0.83)?1:-1;
      c.fillStyle='rgba(12,10,8,.50)';
      for(_g=0;_g<LIFT;_g+=2) c.fillRect(_cx+_cs*(_g*0.22),_fy+_g,1.2,2);
    }
    // THE ROOFLINE IS THE SILHOUETTE and it was a perfectly straight bar
    // across the full width. A parapet that has shed chunks is what tells
    // you, from across the map and without reading any detail, that nobody
    // has been up there. Bites of varying width at varying spacing, cut into
    // the back edge of the top face.
    c.fillStyle='rgba(28,24,20,.50)';
    for(_g=grit(wl2.x,wl2.y+21)*7;_g<wl2.w;_g+=5+grit(wl2.x+_g,wl2.y+21)*22){
      var _r4=grit(wl2.x+_g|0,wl2.y+22);
      if(_r4>0.46){ _st=Math.min(3+_r4*10,wl2.w-_g);
        c.fillRect(wl2.x+_g,wl2.y-LIFT,_st,1.2+_r4*2.6); }
    }
    // STAINING ON THE ROOF, dark rather than light. A pale patch on a pale
    // roof face reads as a fitted tile; a dark one reads as something that
    // has been sitting there. Long, thin, and never the same size twice.
    c.fillStyle='rgba(38,42,30,.16)';
    for(_g=0;_g<wl2.w;_g+=9+grit(wl2.x+_g,wl2.y+33)*30){
      var _r5=grit(wl2.x+_g|0,wl2.y+34);
      if(_r5>0.40){ _st=Math.min(6+_r5*26,wl2.w-_g);
        c.fillRect(wl2.x+_g,wl2.y-LIFT+2+wl2.h*_r5*0.62,_st,1.6+_r5*3.4); }
    }
  }
  // Warm top lip and two ink creases instead of a cold white outline. Two
  // 1px fills rather than a strokeRect on purpose: a full rectangle draws
  // visible vertical seams where wall segments of one building abut.
  c.fillStyle='rgba(232,214,186,.10)';
  c.fillRect(wl2.x,wl2.y-LIFT,wl2.w,1.2);
  c.fillStyle='rgba(18,14,12,.55)';
  c.fillRect(wl2.x,wl2.y+wl2.h-LIFT,wl2.w,1);
  c.fillRect(wl2.x,wl2.y+wl2.h-1,wl2.w,1);
}
function wallSprite(wl2,d3,LIFT){
  var ss, gk, k, e, w, h, cv2, c2, ks, i;
  if(CFG.wallBake===0||!wl2||!(wl2.w>0&&wl2.h>0)) return null;
  ss=wallSpriteScale();
  gk=String(G&&G.seed)+'|'+(isDay()?'d':'n')+'|'+(CFG.decay!==0?1:0)+'|'+ss;
  if(WALLSPR.key!==gk){ WALLSPR.m={}; WALLSPR.n=0; WALLSPR.key=gk; }
  k=wl2.x+','+wl2.y+','+wl2.w+','+wl2.h+','+LIFT+','+d3;
  WALLSPR.tick++;
  e=WALLSPR.m[k];
  if(e){ e.t=WALLSPR.tick; return e; }
  w=Math.ceil(wl2.w*ss)+2; h=Math.ceil((wl2.h+LIFT)*ss)+2;
  if(w*h>4e6) return null;
  cv2=document.createElement('canvas'); cv2.width=w; cv2.height=h; c2=cv2.getContext('2d'); if(!c2) return null;
  c2.setTransform(ss,0,0,ss,1,1); c2.translate(-wl2.x,-(wl2.y-LIFT));
  wallPaint(c2,wl2,d3,LIFT);
  if(WALLSPR.n>=WALLSPR.max){
    ks=Object.keys(WALLSPR.m); ks.sort(function(a,b){ return WALLSPR.m[a].t-WALLSPR.m[b].t; });
    for(i=0;i<ks.length/4;i++){ delete WALLSPR.m[ks[i]]; WALLSPR.n--; }
  }
  e={c:cv2,ss:ss,t:WALLSPR.tick}; WALLSPR.m[k]=e; WALLSPR.n++;
  return e;
}
function render2D(dt){
'@

SubRx @'
      wc.fillStyle=dcol(d3,'wall');
      wc.fillRect(wl2.x,wl2.y+wl2.h-LIFT,wl2.w,LIFT);
      wc.fillStyle=dcol(d3,'wallTop');
      wc.fillRect(wl2.x,wl2.y-LIFT,wl2.w,wl2.h);
      if(CFG.decay!==0){
        var _fy=wl2.y+wl2.h-LIFT, _g, _st;
        // REGULARITY WAS THE BUG IN THE FIRST CUT OF THIS. Stepping the wall at a
        // fixed interval and only varying WHETHER a mark appears gives you marks
        // on a grid, and a grid reads as tiling, which reads as a surface someone
        // manufactured and fitted. The opposite of the note. So the step itself
        // is jittered as well as the presence, and nothing here lines up with
        // anything else on the wall.
        // RAIN STREAKS. Water runs off a roof and carries the dirt down with it,
        // and on a building nobody has washed since before anyone alive was born
        // that is the single most legible mark of age.
        wc.fillStyle='rgba(14,11,9,.30)';
        for(_g=grit(wl2.x,wl2.y)*9;_g<wl2.w;_g+=4+grit(wl2.x+_g,wl2.y)*17){
          var _r1=grit(wl2.x+_g|0,wl2.y+1);
          if(_r1>0.42) wc.fillRect(wl2.x+_g,_fy,0.8+_r1*1.8,LIFT*(0.30+_r1*0.66));
        }
        // THE DAMP LINE. Ground water wicks up masonry and rots the bottom of it.
        // Ragged along its top edge on purpose: a straight band would read as a
        // painted skirting, which is maintenance, which is the opposite of this.
        wc.fillStyle='rgba(26,30,22,.34)';
        for(_g=0;_g<wl2.w;_g+=3+grit(wl2.x+_g,wl2.y+9)*8){
          var _r2=grit(wl2.x+_g|0,wl2.y+9);
          _st=Math.min(3+_r2*8,wl2.w-_g);
          wc.fillRect(wl2.x+_g,_fy+LIFT-LIFT*0.30*(0.35+_r2),_st,LIFT*0.30*(0.35+_r2));
        }
        // ONE CRACK, on roughly a third of walls. Every wall cracked is noise;
        // a third of them cracked is a neighbourhood that has been left alone.
        var _r3=grit(wl2.x,wl2.y+3);
        if(_r3>0.66&&wl2.w>18){
          var _cx=wl2.x+wl2.w*(0.2+_r3*0.55), _cs=(_r3>0.83)?1:-1;
          wc.fillStyle='rgba(12,10,8,.50)';
          for(_g=0;_g<LIFT;_g+=2) wc.fillRect(_cx+_cs*(_g*0.22),_fy+_g,1.2,2);
        }
        // THE ROOFLINE IS THE SILHOUETTE and it was a perfectly straight bar
        // across the full width. A parapet that has shed chunks is what tells
        // you, from across the map and without reading any detail, that nobody
        // has been up there. Bites of varying width at varying spacing, cut into
        // the back edge of the top face.
        wc.fillStyle='rgba(28,24,20,.50)';
        for(_g=grit(wl2.x,wl2.y+21)*7;_g<wl2.w;_g+=5+grit(wl2.x+_g,wl2.y+21)*22){
          var _r4=grit(wl2.x+_g|0,wl2.y+22);
          if(_r4>0.46){ _st=Math.min(3+_r4*10,wl2.w-_g);
            wc.fillRect(wl2.x+_g,wl2.y-LIFT,_st,1.2+_r4*2.6); }
        }
        // STAINING ON THE ROOF, dark rather than light. A pale patch on a pale
        // roof face reads as a fitted tile; a dark one reads as something that
        // has been sitting there. Long, thin, and never the same size twice.
        wc.fillStyle='rgba(38,42,30,.16)';
        for(_g=0;_g<wl2.w;_g+=9+grit(wl2.x+_g,wl2.y+33)*30){
          var _r5=grit(wl2.x+_g|0,wl2.y+34);
          if(_r5>0.40){ _st=Math.min(6+_r5*26,wl2.w-_g);
            wc.fillRect(wl2.x+_g,wl2.y-LIFT+2+wl2.h*_r5*0.62,_st,1.6+_r5*3.4); }
        }
      }
      // Warm top lip and two ink creases instead of a cold white outline. Two
      // 1px fills rather than a strokeRect on purpose: a full rectangle draws
      // visible vertical seams where wall segments of one building abut.
      wc.fillStyle='rgba(232,214,186,.10)';
      wc.fillRect(wl2.x,wl2.y-LIFT,wl2.w,1.2);
      wc.fillStyle='rgba(18,14,12,.55)';
      wc.fillRect(wl2.x,wl2.y+wl2.h-LIFT,wl2.w,1);
      wc.fillRect(wl2.x,wl2.y+wl2.h-1,wl2.w,1);
'@ @'
      // v18.15: the face comes off a baked sprite when there is one (wallSprite); the live paint is the same block, in wallPaint
      var _ws=wallSprite(wl2,d3,LIFT);
      if(_ws) wc.drawImage(_ws.c,0,0,_ws.c.width,_ws.c.height,wl2.x-1/_ws.ss,wl2.y-LIFT-1/_ws.ss,_ws.c.width/_ws.ss,_ws.c.height/_ws.ss);
      else wallPaint(wc,wl2,d3,LIFT);
'@

SubRx @'
var VER='18.14';
'@ @'
var VER='18.15';
'@

$pat = "(?m)^  now:'v18\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.15: Walls are painted once and reused instead of being repainted every frame, which was most of the drawing cost in a built-up street. Check 18.15 fails on v18.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
