$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ---- 1. ONE TABLE OF FLOORS, so the numbers can be read, shared and challenged
# ---- instead of sitting as bare constants inside four different checks.
SubRx @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
'@ @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
// v10.79: THE FLOORS THREE DRAWING CHECKS REST ON, in one place and with the
// reading each was measured against. Before today they were 0, 0, 20 and 3,
// which is not a floor, it is "is it non-zero": a search bar reduced to a single
// pixel, a noise ring reduced to a fifth and a prompt whose pulse had fallen to
// a ninth all passed. Measured at 1920x1080, DPR 1, seed 4242, map 0, each floor
// set at half its live reading so a halved feature is still caught.
//   bar   1319 px, the search bar appearing and disappearing
//   prog  1319 px, the same bar filling from empty to half
//   ring   120 px, one noise ring at the frame it is born, its weakest moment
//   pulse 25.7 %,  the standing extract prompt breathing
// A check reads these through __FLOORS so v10.79 can hold them to account. If
// the drawing legitimately changes, MEASURE AGAIN and move the number here.
window.__FLOORS={bar:600,prog:600,ring:60,pulse:12,
  live:{bar:1319,prog:1319,ring:120,pulse:25.7}};
'@

# ---- 2. v8.99: two guards that accepted one pixel.
SubRx @'
     var barPx=diff(D,E);
     if(barPx<=0) bad.push('the container bar is not drawn at all, even for one he walked away from');
'@ @'
     var barPx=diff(D,E);
     // v10.79: was barPx<=0, which a one pixel bar cleared. Measured 1319.
     var _fl=(window.__FLOORS||{bar:0,prog:0});
     if(barPx<_fl.bar) bad.push('the container bar moved only '+barPx+' pixels, under the '+_fl.bar+' a drawn bar has to clear');
'@

SubRx @'
     if(diff(F,Gs)<=0) bad.push('control: a half searched container shows no progress at all');
'@ @'
     var _pg=diff(F,Gs);
     // v10.79: was <=0. A bar that filled by one pixel between empty and half
     // full passed, which is not a bar anybody can read. Measured 1319.
     if(_pg<_fl.prog) bad.push('control: a half searched container fills by only '+_pg+' pixels, under the '+_fl.prog+' a readable bar has to clear');
'@

# ---- 3. v9.07: the ring. 20 against a measured 120.
SubRx @'
     if(heardPix<20) bad.push('the ring changed only '+heardPix+' pixels, so nothing was actually drawn');
'@ @'
     // v10.79: the floor was 20 against a measured 120, so a ring drawn at a
     // fifth of itself passed. This is the ring at the frame it is born, which
     // is the smallest it ever is, so the floor is deliberately half of that.
     var _rf=(window.__FLOORS||{ring:20}).ring;
     if(heardPix<_rf) bad.push('the ring changed only '+heardPix+' pixels, under the '+_rf+' a drawn ring has to clear');
'@

# ---- 4. v9.08: the control that the standing prompt still pulses. 3 against 25.7.
SubRx @'
       else if(up.pct<3) bad.push('control: the standing prompt stopped pulsing too, swing '+up.pct.toFixed(1)+' percent');
'@ @'
       // v10.79: the floor was 3 percent against a measured 25.7, so a pulse
       // that had faded to a ninth of itself still counted as pulsing.
       else if(up.pct<(window.__FLOORS||{pulse:3}).pulse) bad.push('control: the standing prompt barely pulses, swing '+up.pct.toFixed(1)+' percent, under '+(window.__FLOORS||{pulse:3}).pulse);
'@

# ---- 5. THE NEW CHECK. It measures the same four signals live and then holds
# ---- the floors to account: each floor must be under the live reading (so the
# ---- build passes honestly) AND above a quarter of it (so a badly degraded
# ---- feature is refused). On a v10.78 fixture there is no __FLOORS, the
# ---- fallback supplies the OLD numbers, and all four quarter-strength
# ---- assertions fire, which is the control this build needs.
SubRx @'
  {v:'10.78',what:'no window pushes its own contents past its own box with nothing able to scroll to them, and the Depot can still reach SURPRISE ME and its three saved looks',
'@ @'
  {v:'10.79',what:'the drawing checks refuse a trace of a thing as proof the thing is there: every floor sits under the live reading and above a quarter of it',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     if(!(window.__deploy&&window.__frame&&window.__noise&&window.__audio)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[];
     // THE FALLBACK IS THE OLD NUMBERS ON PURPOSE. Without __FLOORS this check
     // must still say what the build before it was accepting, rather than skip.
     var F=window.__FLOORS||{bar:0,prog:0,ring:20,pulse:3};
     var live={};
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0);
     // --- the container search bar, and the same bar filling
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0; g.player.iv=99;
     var ct=null, ci;
     for(ci=0;ci<g.containers.length;ci++) if((g.containers[ci].loot||[]).length>=3){ ct=g.containers[ci]; break; }
     if(!ct) return 'SKIP: no container with three items on this seed';
     g.player.x=ct.x; g.player.y=ct.y+10; __zoom.set(6,true);
     ct.prog=ct.time*0.5; ct.opened=false;
     var cvw=document.getElementById('cv'); if(!cvw) return 'SKIP: no world canvas';
     var c2=cvw.getContext('2d');
     function shot(){ __frame(0); return c2.getImageData(0,0,cvw.width,cvw.height).data; }
     function diff8(a,b){ var d=0; for(var q=0;q<a.length;q+=4){ if(Math.abs(a[q]-b[q])+Math.abs(a[q+1]-b[q+1])+Math.abs(a[q+2]-b[q+2])>8) d++; } return d; }
     g.searching=null; var S0=shot(); g.searching=ct; var S1=shot(); g.searching=null; var S2=shot();
     live.bar=diff8(S1,S2);
     ct.prog=0; var S3=shot(); ct.prog=ct.time*0.5; var S4=shot();
     live.prog=diff8(S3,S4);
     __zoom.set(1,true);
     // --- the noise ring at the frame it is born
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g2=__state(), p2=g2.player; g2.ents.length=0; p2.iv=99; p2.face=Math.PI/2;
     for(var nf=0;nf<6;nf++) __loop(performance.now()+nf*16.7);
     p2.face=Math.PI/2;
     function snapW(){ __frame(0); return c2.getImageData(0,0,1920,1080).data; }
     function diffE(a,b){ var d=0; for(var i=0;i<a.length;i+=4) if(a[i]!==b[i]||a[i+1]!==b[i+1]||a[i+2]!==b[i+2]) d++; return d; }
     __noise.clear();
     var NB=snapW();
     if(diffE(NB,snapW())!==0) return 'SKIP: two identical redraws differ, no pixel reading here means anything';
     var NX=p2.x, NY=p2.y-260, cm=__cam?__cam():null;
     if(cm&&(NX<cm.x||NX>cm.x+1920||NY<cm.y||NY>cm.y+1080)) return 'SKIP: the noise lands outside the camera, pixels prove nothing';
     __audio.sfx('shot',NX,NY,'rifle');
     live.ring=diffE(NB,snapW());
     __noise.clear();
     // --- the standing extract prompt breathing
     var hc=document.getElementById('hcv');
     if(hc){
       __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g3=__state(), p3=g3.player; g3.ents.length=0;
       p3.downed=0; p3.revived=1; p3.iv=99;
       var z3=g3.zones&&g3.zones[0];
       if(z3){
         g3.active=z3; z3.open=true; p3.x=z3.x; p3.y=z3.y;
         for(var sf=0;sf<4;sf++) __loop(performance.now()+sf*16.7);
         g3.shipHold=8; g3.beaconT=0;
         var hx=hc.getContext('2d');
         function mean(x,y,w,h){ __frame(0); var d=hx.getImageData(x,y,w,h).data,su=0;
           for(var i=0;i<d.length;i+=4) su+=(d[i]+d[i+1]+d[i+2])/3*(d[i+3]/255); return su/(d.length/4); }
         var t3=g3.timeLeft, vs=[];
         for(var k3=0;k3<12;k3++){ g3.timeLeft=t3+k3*0.15; vs.push(mean(700,375,520,55)); }
         g3.timeLeft=t3;
         var mn3=Math.min.apply(null,vs), mx3=Math.max.apply(null,vs);
         live.pulse=mx3>0.01?((mx3-mn3)/mx3*100):0;
       }
     }
     // --- AND NOW THE FLOORS ARE JUDGED AGAINST WHAT WAS ACTUALLY MEASURED.
     var names={bar:'the container search bar',prog:'the search bar filling',ring:'a noise ring',pulse:'the standing extract prompt pulse'};
     var units={bar:' pixels',prog:' pixels',ring:' pixels',pulse:' percent'};
     var keys=['bar','prog','ring','pulse'], kk;
     for(kk=0;kk<keys.length;kk++){
       var k=keys[kk], lv=live[k], fl=F[k];
       if(lv===undefined) continue;
       var shown=(k==='pulse')?lv.toFixed(1):Math.round(lv);
       // 1. the build has to clear its own floor, or the floor is simply wrong
       if(lv<fl) bad.push(names[k]+' reads '+shown+units[k]+', under its own floor of '+fl);
       // 2. AND THE FLOOR HAS TO MEAN SOMETHING. A quarter of the live reading is
       //    a feature anybody would call broken on sight; if that still clears the
       //    floor then the floor is decoration, which is what v8.99, v9.07 and
       //    v9.08 were carrying until today.
       else if(lv*0.25>=fl) bad.push(names[k]+' reads '+shown+units[k]+' and its floor is only '+fl+', so a quarter of it would still pass');
     }
     // 3. CONTROL: the readings must not all be zero, which would satisfy nothing
     //    above by accident if a deploy silently failed.
     if(!(live.bar>0&&live.ring>0)) bad.push('control: nothing was drawn at all, bar '+live.bar+' ring '+live.ring+', so this check measured a blank screen');
     return bad.length?bad.join('; '):null; }},
  {v:'10.78',what:'no window pushes its own contents past its own box with nothing able to scroll to them, and the Depot can still reach SURPRISE ME and its three saved looks',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
