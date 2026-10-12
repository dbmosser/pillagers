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

# BULLETS MARK THE WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wallMark(w,x,y,ux,uy){ return gfxHook('wall'); }   // D: bullet marks painted into the wall sprite
'@ @'
// v23.xx (gfx25), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 7, shot detail. BULLETS MARK THE
// WALLS. A round that died on a wall left a spark and nothing else, so a wall you had been trading fire across looked untouched.
// A round travelling north that stops on the south face of a plain wall (the face the camera sees) now leaves a chipped hole in
// that face at about gun height: a dark core, a pale chipped rim and a few flecks, shaped by a hash of where it hit. The mark is
// painted straight into the wall baked sprite (WALLSPR), so it costs nothing a frame, and it is kept per wall (the last 24 on a
// wall, 1500 across the raid) so a rebaked sprite (a new time of day, a new screen scale) paints them back. Doors, windows, trees,
// wrecks, ruins, furniture and kerbs take no marks; a wall drawn live (wall baking off) shows none. Render only: no seeded draw.
var WALLMK=(typeof WeakMap==='function')?new WeakMap():null, WALLMKQ=[];
function wallMarkPaint(c,mk){
  var i, a, d, s=mk.s;
  c.fillStyle='rgba(225,212,190,.22)'; c.beginPath(); c.ellipse(mk.x+0.4,mk.y-0.3,2.7,2.2,0,0,6.2832); c.fill();
  c.fillStyle='rgba(12,9,8,.86)'; c.beginPath(); c.ellipse(mk.x,mk.y,1.55,1.3,0,0,6.2832); c.fill();
  c.fillStyle='rgba(16,12,10,.55)';
  for(i=0;i<3;i++){ a=grit(s+i*31,s+i*17)*6.2832; d=2+grit(s+i*53,s+i*7)*1.8; c.fillRect(mk.x+Math.cos(a)*d-0.4,mk.y+Math.sin(a)*d*0.8-0.4,0.8,0.8); }
}
function wallMarksPaint(c,w){
  var Lm=WALLMK&&WALLMK.get(w), i;
  if(!Lm||!Lm.length) return 0;
  for(i=0;i<Lm.length;i++) wallMarkPaint(c,Lm[i]);
  return Lm.length;
}
function wallMark(w,x,y,ux,uy){   // the hook: true when it took the event (a mark or not), false when off
  if(!gfxHook('wall')) return false;
  try{ wallMarkAdd(w,x,y,ux,uy); }catch(_wma){}
  return true;
}
function wallMarkAdd(w,x,y,ux,uy){
  if(!w||!WALLMK) return null;
  if(w.tree||w.ruin||w.wreck||w.furn||w.win||w.door||w.ledge) return null;
  if(!(uy<-0.15)||!(y>=w.y+w.h-4)) return null;   // south faces only: a round going north that stopped on the face the camera sees
  var LIFT=w.lift||((w.w<=60&&w.h<=60)?14:26), Lm=WALLMK.get(w), s, mk, k, e, c, old, j;
  if(!(LIFT>=8)||!(w.w>=6)) return null;
  if(WALLMKQ.length&&WALLMKQ[WALLMKQ.length-1].g!==G) WALLMKQ.length=0;
  if(!Lm){ Lm=[]; WALLMK.set(w,Lm); }
  s=((Math.round(x)*73856093)^(Math.round(y)*19349663)^((WALLMKQ.length+1)*83492791))>>>0;
  mk={x:clamp(x+(grit(s,7)-0.5)*2,w.x+2,w.x+w.w-2),y:w.y+w.h-clamp(12+(grit(s,11)-0.5)*8,3,LIFT-3),s:s,w:w,g:G};
  Lm.push(mk); if(Lm.length>24) Lm.shift();
  WALLMKQ.push(mk);
  if(WALLMKQ.length>1500){ old=WALLMKQ.shift(); j=(WALLMK.get(old.w)||[]).indexOf(old); if(j>=0) WALLMK.get(old.w).splice(j,1); }
  for(k in WALLSPR.m){
    e=WALLSPR.m[k];
    if(!e||e.w!==w||!e.c) continue;
    c=e.c.getContext('2d'); if(!c) continue;
    c.save(); c.setTransform(e.ss,0,0,e.ss,1,1); c.translate(-w.x,-(w.y-e.lift));
    try{ wallMarkPaint(c,mk); } finally { c.restore(); }
  }
  return mk;
}
'@

SubRx @'
  wallPaint(c2,wl2,d3,LIFT);
'@ @'
  wallPaint(c2,wl2,d3,LIFT);
  try{ wallMarksPaint(c2,wl2); }catch(_wmp){}   // v23.xx (gfx25): and the bullet marks this wall has taken
'@

SubRx @'
  e={c:cv2,ss:ss,t:WALLSPR.tick}; WALLSPR.m[k]=e; WALLSPR.n++;
'@ @'
  e={c:cv2,ss:ss,t:WALLSPR.tick,w:wl2,lift:LIFT}; WALLSPR.m[k]=e; WALLSPR.n++;   // v23.xx (gfx25): w and lift let a new bullet mark paint into this sprite in place
'@

SubRx @'
var VER='24.37';
'@ @'
var VER='24.38';
'@

$pat = "(?m)^  now:'v24\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.38: Rounds that hit a wall now leave bullet holes in it for the rest of the raid. Check 24.38 fails on v24.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
