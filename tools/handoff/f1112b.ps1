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

# THE BEHAVIOUR HALF ASSERTED SOMETHING THAT IS NOT TRUE. A crawler in building
# 8 cannot reach the player with or without this fix, because a 36 by 26 piece
# of furniture sits inside its 64 unit doorway and leaves 10 and 17 units either
# side of it for a 30 unit body. That is a second defect and the next build.
# What THIS build proves is the route: the old game pulled the string tight
# through the window, the fix keeps the corner out of the door.
SubRx @'
     // PART TWO, THE BEHAVIOUR, which is what he would actually see. A crawler
     // is put in the middle of a building with a window facing the player, the
     // player stands outside, and the chase is held on so the only question
     // asked is whether it can walk there.
     function run(bIx,winWalk){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({winWalk:winWalk});
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var gg=__state(), p=gg.player, B=gg.map.buildings, cw=null, q;
       for(q=0;q<gg.ents.length;q++) if(gg.ents[q].kind==='crawler'){ cw=gg.ents[q]; break; }
       if(!cw) return null;
       gg.ents.length=0; gg.ents.push(cw);
       var bd=B[bIx];
       if(!bd) return null;
       var tx=bd.x-210, ty=bd.y+bd.h/2;
       p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
       cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2;
       cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
       var t0=performance.now(), best=1e9, start=D(cw,p);
       for(var f=0;f<520;f++){
         cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var d=D(cw,p); if(d<best) best=d;
       }
       return {near:best,start:start,rect:[bd.x,bd.y,bd.w,bd.h]};
     }
     // The seed fingerprint of the building this was measured on. If the map
     // moves, this says so by name rather than quietly testing somewhere else.
     var on=run(8,1);
     if(!on) return 'SKIP: no crawler to drive on COLD STORAGE';
     if(on.rect.join(',')!=='2520,900,380,340')
       bad.push('building 8 on COLD STORAGE is now ['+on.rect.join(',')+'] and not the 2520,900,380,340 this was measured on, so the window it is about may not be there');
     var off=run(8,0);
     // MEASURED: 255 units away with the old rule, against a start of 400.
     if(!(off&&off.near>180))
       bad.push('control: with winWalk off the crawler in building 8 got to '+(off?off.near.toFixed(0):'?')+' units, so the old game does not show the fault and this build proves nothing');
     if(!(on.near<80))
       bad.push('a crawler in building 8 with a window facing the player got no closer than '+on.near.toFixed(0)+' units in nine seconds, from a start of '+on.start.toFixed(0)+', so it is still walking into the glass instead of out of the door');
     return bad.length?bad.join('; '):null; }},
'@ @'
     // PART TWO, THE ROUTE, and it needs no simulation either. From the middle
     // of a building to a player outside it, the old game pulled the string
     // tight through any window it could see across, so the route was a
     // straight line into the glass. With the fix the same query keeps the
     // corner that takes the body out of the door. One deploy per map and the
     // dial flipped between the two queries, since the string-pull reads it live.
     function dev(pts,cx,cy,tx,ty){ var m=0,dx=tx-cx,dy=ty-cy,L=Math.hypot(dx,dy);
       for(var q=0;q<pts.length;q++){ var t=((pts[q].x-cx)*dx+(pts[q].y-cy)*dy)/(L*L);
         var px=cx+dx*t,py=cy+dy*t,dd=Math.hypot(pts[q].x-px,pts[q].y-py); if(dd>m) m=dd; }
       return m; }
     function scan(mi){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var gg=__state(),B=gg.map.buildings,WW=gg.map.walls,changed=0,b8=null,q,z;
       function openAt(x,y){ if(x<120||y<120) return false;
         for(z=0;z<WW.length;z++){ var w=WW[z]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(z=0;z<B.length;z++){ var b=B[z]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
       for(q=0;q<B.length;q++){ var bd=B[q]; if(bd.w<120||bd.h<120) continue;
         var cand=[[bd.x-210,bd.y+bd.h/2],[bd.x+bd.w+210,bd.y+bd.h/2],[bd.x+bd.w/2,bd.y-210],[bd.x+bd.w/2,bd.y+bd.h+210]];
         var tx=0,ty=0,ok=false;
         for(z=0;z<cand.length&&!ok;z++) if(openAt(cand[z][0],cand[z][1])){ tx=cand[z][0]; ty=cand[z][1]; ok=true; }
         if(!ok) continue;
         var cx=bd.x+bd.w/2, cy=bd.y+bd.h/2;
         __cfg({winWalk:0}); var r0=__navPath(gg.map.navD,cx,cy,tx,ty);
         __cfg({winWalk:1}); var r1=__navPath(gg.map.navD,cx,cy,tx,ty);
         if(!r0||!r1) continue;
         var d0=dev(r0,cx,cy,tx,ty), d1=dev(r1,cx,cy,tx,ty);
         if(d1-d0>60) changed++;
         if(mi===0&&q===8) b8={rect:[bd.x,bd.y,bd.w,bd.h],n0:r0.length,d0:d0,n1:r1.length,d1:d1};
       }
       __cfg({winWalk:1});
       return {changed:changed,b8:b8};
     }
     var m0=scan(0), m1=scan(1);
     // The building this was traced on, by its seed fingerprint, so a moved map
     // says so by name rather than quietly testing somewhere else.
     if(!m0.b8) bad.push('building 8 on COLD STORAGE had no open ground outside it, so the traced case could not be run');
     else {
       if(m0.b8.rect.join(',')!=='2520,900,380,340')
         bad.push('building 8 on COLD STORAGE is now ['+m0.b8.rect.join(',')+'] and not the 2520,900,380,340 this was traced on');
       // CONTROL THREE: the old game must still show the fault. With winWalk off
       // the route is the straight line into the glass: two points, no corner.
       if(!(m0.b8.n0===2&&m0.b8.d0<30))
         bad.push('control: with winWalk off the route out of building 8 has '+m0.b8.n0+' points and a corner of '+m0.b8.d0.toFixed(0)+' units, so the old game no longer walks into the window and this build proves nothing');
       if(!(m0.b8.n1>=3&&m0.b8.d1>60))
         bad.push('the route out of building 8 with the fix has '+m0.b8.n1+' points and a corner of '+m0.b8.d1.toFixed(0)+' units, so it is still the straight line through the window and not the way out of the door');
     }
     // MEASURED: 1 of 13 on COLD STORAGE and 6 of 59 on THE COLD MILE were a
     // line through a window and are a real route now.
     if(m0.changed<1) bad.push('no route on COLD STORAGE changed shape, so the fix touches nothing there');
     if(m1.changed<4) bad.push('only '+m1.changed+' routes on THE COLD MILE changed shape against the 6 measured');
     // PART THREE, THE GUARD: a crawler that could reach the player before this
     // build must still reach him. Building 14 on COLD STORAGE, measured at 34
     // units both ways, so a fix that broke ordinary chasing shows here.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({winWalk:1});
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g3=__state(),p3=g3.player,B3=g3.map.buildings,cw=null;
     for(i=0;i<g3.ents.length;i++) if(g3.ents[i].kind==='crawler'){ cw=g3.ents[i]; break; }
     if(!cw) return 'SKIP: no crawler to drive on COLD STORAGE';
     g3.ents.length=0; g3.ents.push(cw);
     var b14=B3[14];
     if(!b14) bad.push('COLD STORAGE has no building 14');
     else {
       var W3=g3.map.walls;
       function open3(x,y){ if(x<120||y<120) return false;
         for(k=0;k<W3.length;k++){ var w3=W3[k]; if(x>w3.x-34&&x<w3.x+w3.w+34&&y>w3.y-34&&y<w3.y+w3.h+34) return false; }
         for(k=0;k<B3.length;k++){ var bb=B3[k]; if(x>bb.x-34&&x<bb.x+bb.w+34&&y>bb.y-34&&y<bb.y+bb.h+34) return false; }
         return true; }
       var c14=[[b14.x-210,b14.y+b14.h/2],[b14.x+b14.w+210,b14.y+b14.h/2],[b14.x+b14.w/2,b14.y-210],[b14.x+b14.w/2,b14.y+b14.h+210]];
       var tx3=0,ty3=0,ok3=false;
       for(k=0;k<c14.length&&!ok3;k++) if(open3(c14[k][0],c14[k][1])){ tx3=c14[k][0]; ty3=c14[k][1]; ok3=true; }
       if(!ok3) bad.push('building 14 on COLD STORAGE has no open ground outside it, so the guard could not run');
       else {
         p3.x=tx3; p3.y=ty3; p3.iv=99; p3.hp=100; p3.downed=0;
         cw.x=b14.x+b14.w/2; cw.y=b14.y+b14.h/2; cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
         var t0=performance.now(), best=1e9;
         for(var f=0;f<420;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx3; cw.ty=ty3;
           __loop(t0+f*16.7); p3.x=tx3; p3.y=ty3; p3.hp=100; p3.iv=99;
           var dd3=D(cw,p3); if(dd3<best) best=dd3; }
         if(best>60) bad.push('guard: the crawler in building 14, which reached the player at 34 units before this build, now gets no closer than '+best.toFixed(0));
       }
     }
     return bad.length?bad.join('; '):null; }},
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
