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

# ============ HIS TWO NOTES, 2026-09-03 about 21:40 and 21:45, with pictures:
# ============ "walls don't need to be transparent when player is on the far
# ============ side of them, that looks goofy, wall should just be in front of
# ============ or behind player", and "this glitch still happening in undercroft
# ============ where pillager bots randomly get caught on wlals".
# ============
# ============ They are one fault. Every wall in this game is PAINTED 26 units
# ============ above the rectangle it collides with (14 for a small one), so the
# ============ strip of floor just north of a wall is floor you can stand on and
# ============ also floor the wall is painted over. Anyone standing there is
# ============ swallowed. The see-through ghost (v9.27, v10.51, v10.59) was a
# ============ workaround for the player: paint him again, faded, on top. He has
# ============ now seen it and does not want it.
# ============
# ============ Measured on v10.59 before touching anything: over 1,200 steps of
# ============ the Undercroft, bodies stood inside a wall's painted rectangle
# ============ 1,821 times out of 19,200 samples, 8 of the 15 bodies, and every
# ============ one of those moments had the wall painting over the body. One
# ============ post holder stood inside the south wall's picture permanently.
# ============
# ============ So: in the Undercroft nobody may stand inside a wall's PICTURE,
# ============ which is the rectangle it actually paints, and with nobody
# ============ standing there nothing needs to be transparent. The ghost stays
# ============ in the file behind its dial, which now defaults to off.

# 1. The dial that turns walls transparent is off.
SubRx @'
,seeThrough:1,
'@ @'
,seeThrough:0,
'@

# 2. What a wall actually paints: its top face is drawn from y-L, and its front
#    face reaches y+h, so the picture is the collider grown upward by the lift.
SubRx @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }
'@ @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }
// v10.60, his note: a body standing in the strip a wall PAINTS over is swallowed
// by it, which is what "caught on walls" looks like. This is that strip: the
// collider grown upward by the same lift the wall is drawn with. Bodies down here
// collide with the picture, so nobody can ever be inside one.
function hubDrawn(ws){
  var out=[];
  for(var i=0;i<ws.length;i++){
    var w=ws[i], L=(w.w<=60&&w.h<=60)?14:26;
    out.push({x:w.x,y:w.y-L,w:w.w,h:w.h+L,d:w.d,src:w});
  }
  return out;
}
'@

# 3. The room keeps both lists, places its people against the pictures, and
#    starts nobody inside one.
SubRx @'
  return {walls:w,segs:segs,stations:stations,lights:lights,
    crowd:buildHubCrowd(stations,w),
    player:{x:590,y:400,r:11,face:-1.5708,bob:0,moving:false},
    near:null,t:0,eLock:false};
'@ @'
  // v10.60: dwalls is what the walls PAINT; everyone down here collides with that
  // rather than with the smaller rectangle underneath it.
  var dw=hubDrawn(w);
  var cr=buildHubCrowd(stations,dw);
  for(var ci2=0;ci2<cr.length;ci2++){
    var bb=cr[ci2];
    if(!(bb.r>0)) bb.r=13;
    // The room's own box reaches into the south wall's picture, so the clamp
    // goes first and the push gets the last word.
    bb.x=clamp(bb.x,34,HUBW-34); bb.y=clamp(bb.y,34,HUBH-34);
    collide(bb,dw);
    // A post holder walks back to where he was put, so his home moves with him.
    if(bb.post){ bb.px=bb.x; bb.py=bb.y; }
  }
  return {walls:w,dwalls:dw,segs:segs,stations:stations,lights:lights,
    crowd:cr,
    player:{x:590,y:400,r:11,face:-1.5708,bob:0,moving:false},
    near:null,t:0,eLock:false};
'@

# 4. Every body in the room, every move: the operator walking, rolling and
#    standing, the errand walk, the walk home, the shove and the hired man.
SubRx @'
      p.x+=_rd.x*_rl2/_rsn; p.y+=_rd.y*_rl2/_rsn;
      collide(p,HB.walls);
'@ @'
      p.x+=_rd.x*_rl2/_rsn; p.y+=_rd.y*_rl2/_rsn;
      collide(p,HB.dwalls);   // v10.60: the picture, not the collider under it
'@
SubRx @'
    p.face=Math.atan2(my,mx);
    collide(p,HB.walls);
'@ @'
    p.face=Math.atan2(my,mx);
    collide(p,HB.dwalls);   // v10.60
'@
SubRx @'
      c.x+=dx/dd*sp*dt; c.y+=dy/dd*sp*dt;
      collide(c,HB.walls);
'@ @'
      c.x+=dx/dd*sp*dt; c.y+=dy/dd*sp*dt;
      collide(c,HB.dwalls);   // v10.60
'@
SubRx @'
        c.x+=hdx/hd*hs; c.y+=hdy/hd*hs;
'@ @'
        c.x+=hdx/hd*hs; c.y+=hdy/hd*hs;
        collide(c,HB.dwalls);   // v10.60: the walk home goes round the counter, not through it
'@
SubRx @'
            _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
'@ @'
            _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
            collide(_A2,HB.dwalls); collide(_B2,HB.dwalls);   // v10.60: a shove never lands anyone in a wall
'@
SubRx @'
          if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; }
'@ @'
          if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; collide(_c,HB.dwalls); }   // v10.60
'@

# 5. THE SECOND CROWD BUILD. Coming down to the floor rebuilds the people, and
#    that call passed the colliders and skipped the placement pass, so every
#    visit after the first put them back inside the pictures. One shared helper
#    now, so a third caller cannot get this wrong either.
SubRx @'
  var dw=hubDrawn(w);
  var cr=buildHubCrowd(stations,dw);
  for(var ci2=0;ci2<cr.length;ci2++){
    var bb=cr[ci2];
    if(!(bb.r>0)) bb.r=13;
    // The room's own box reaches into the south wall's picture, so the clamp
    // goes first and the push gets the last word.
    bb.x=clamp(bb.x,34,HUBW-34); bb.y=clamp(bb.y,34,HUBH-34);
    collide(bb,dw);
    // A post holder walks back to where he was put, so his home moves with him.
    if(bb.post){ bb.px=bb.x; bb.py=bb.y; }
  }
'@ @'
  var dw=hubDrawn(w);
  var cr=hubCrowdClear(stations,dw);
'@
SubRx @'
function hubDrawn(ws){
'@ @'
// v10.60: the only way the crowd is ever built. It places them against the
// PICTURES and then pushes anyone the room's own box put back inside one.
function hubCrowdClear(stations,dw){
  var cr=buildHubCrowd(stations,dw);
  for(var i=0;i<cr.length;i++){
    var b=cr[i];
    if(!(b.r>0)) b.r=13;
    // The room's box reaches into the south wall's picture, so the clamp goes
    // first and the push gets the last word.
    b.x=clamp(b.x,34,HUBW-34); b.y=clamp(b.y,34,HUBH-34);
    collide(b,dw);
    // A post holder walks back to where he was put, so his home moves with him.
    if(b.post){ b.px=b.x; b.py=b.y; }
  }
  return cr;
}
function hubDrawn(ws){
'@
SubRx @'
    else HB.crowd=buildHubCrowd(HB.stations,HB.walls);
'@ @'
    else HB.crowd=hubCrowdClear(HB.stations,HB.dwalls||hubDrawn(HB.walls));   // v10.60: the pictures, and placed clear of them
'@

# 6. The room's walking box reaches into the south wall's picture, so wherever a
#    position is clamped the push has to run again afterwards or the clamp puts
#    a body straight back inside the wall. Measured: without this, people were
#    still inside a picture 540 times in 1,200 steps.
SubRx @'
    p.bob+=dt*18;
    p.x=clamp(p.x,26,HUBW-26); p.y=clamp(p.y,26,HUBH-26);
    p.moving=true;
'@ @'
    p.bob+=dt*18;
    p.x=clamp(p.x,26,HUBW-26); p.y=clamp(p.y,26,HUBH-26);
    collide(p,HB.dwalls);   // v10.60: the clamp can push him into the south wall's picture
    p.moving=true;
'@
SubRx @'
    p.x=clamp(p.x,26,HUBW-26); p.y=clamp(p.y,26,HUBH-26);
  } else p.bob+=dt*1.2;
'@ @'
    p.x=clamp(p.x,26,HUBW-26); p.y=clamp(p.y,26,HUBH-26);
    collide(p,HB.dwalls);   // v10.60
  } else p.bob+=dt*1.2;
'@
SubRx @'
      c.x=clamp(c.x,34,HUBW-34); c.y=clamp(c.y,34,HUBH-34);
'@ @'
      c.x=clamp(c.x,34,HUBW-34); c.y=clamp(c.y,34,HUBH-34);
      collide(c,HB.dwalls);   // v10.60
'@

SubRx @'
var VER='10.59';
'@ @'
var VER='10.60';
'@
SubRx @'
  now:'v10.59: behind a wall you look like yourself, faded, instead of turning into a light-blue cutout. Your coat, your racks, your stance and your gun, seen through the wall.',
'@ @'
  now:'v10.60: walls are solid again. Nothing goes see-through when you stand behind it, and in the Undercroft nobody can stand inside the part of a wall that is painted, which is what was catching the people down there on the counters and the piers.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
