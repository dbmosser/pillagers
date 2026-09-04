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

SubRx @'
window.__navPath=function(nav,sx,sy,tx,ty){ return navPath(nav,sx,sy,tx,ty); };
'@ @'
window.__navPath=function(nav,sx,sy,tx,ty){ return navPath(nav,sx,sy,tx,ty); };
window.__walk=function(ax,ay,bx,by){
  return {see:losClear(ax,ay,bx,by,G.map.segs),walk:walkClear(ax,ay,bx,by)};
};
window.__wins=function(){
  var W=G.map.walls,o=[],i;
  for(i=0;i<W.length;i++) if(W[i].win) o.push({x:W[i].x,y:W[i].y,w:W[i].w,h:W[i].h});
  return {wins:o,wsegs:(G.map.wsegs?G.map.wsegs.length:-1),grid:!!G.wingrid};
};
'@

SubRx @'
  {v:'11.11',what:'a friend arriving on a fresh profile
'@ @'
  {v:'11.12',what:'a machine that can see you through a window does not try to walk through it, and comes out of the door instead',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__walk&&window.__wins))
       return 'SKIP: this fixture has no walk test';
     var bad=[], D=__movers.dist, i, k;
     // PART ONE, GEOMETRY, and it needs no simulation at all. Either side of a
     // window: you can SEE across it and you can NOT WALK across it.
     __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), WA=g.map.walls, wi=__wins();
     if(wi.wsegs<=0) bad.push('the map kept no window segments at all, so nothing can test a window');
     if(!wi.grid) bad.push('the raid built no window grid, so every walk test is a scan of the whole list');
     // A probe point has to be in the clear, or the ray is answering about some
     // other wall and the window is not the thing being measured.
     function clearOf(x,y,skip){
       for(var q=0;q<WA.length;q++){ var w=WA[q]; if(w===skip) continue;
         if(x>w.x-20&&x<w.x+w.w+20&&y>w.y-20&&y<w.y+w.h+20) return false; }
       return true;
     }
     var tested=0, seeFail=0, walkFail=0, pairs=[];
     for(i=0;i<WA.length&&tested<6;i++){
       var w=WA[i]; if(!w.win) continue;
       var vert=w.h>w.w, ax,ay,bx,by;
       if(vert){ ax=w.x-40; ay=w.y+w.h/2; bx=w.x+w.w+40; by=ay; }
       else    { ax=w.x+w.w/2; ay=w.y-40; bx=ax; by=w.y+w.h+40; }
       if(!clearOf(ax,ay,w)||!clearOf(bx,by,w)) continue;
       var r=__walk(ax,ay,bx,by);
       if(!r.see) seeFail++;
       if(r.walk) walkFail++;
       pairs.push([ax,ay,bx,by]);
       tested++;
     }
     if(tested<3) return 'SKIP: only '+tested+' windows on COLD STORAGE have clear ground on both sides';
     if(seeFail) bad.push(seeFail+' of '+tested+' windows cannot be seen through, so the sight geometry has stopped skipping windows and this whole build is pointless');
     if(walkFail) bad.push(walkFail+' of '+tested+' windows report that a body can walk straight through them, which is what a machine believed when it walked into one and stood there');
     // CONTROL ONE: a line in the open must pass BOTH tests, or the walk test is
     // simply refusing everything and the zero above means nothing.
     var op=null;
     for(i=0;i<40&&!op;i++){
       var ox=600+i*97, oy=1400;
       if(clearOf(ox,oy,null)&&clearOf(ox+120,oy,null)) op=[ox,oy,ox+120,oy];
     }
     if(!op) bad.push('control: no open line could be found to prove the walk test says yes to anything');
     else { var ro=__walk(op[0],op[1],op[2],op[3]);
       if(!ro.see||!ro.walk) bad.push('control: an open line 120 units long reads see='+ro.see+' walk='+ro.walk+', so the walk test refuses everything'); }
     // CONTROL TWO: the dial. With winWalk off the walk test must agree with the
     // sight test on every window, which is the old game exactly.
     __cfg({winWalk:0});
     var agreed=0;
     for(i=0;i<pairs.length;i++){ var pr=pairs[i], r0=__walk(pr[0],pr[1],pr[2],pr[3]);
       if(r0.walk===r0.see) agreed++; }
     if(agreed!==pairs.length) bad.push('control: with winWalk off only '+agreed+' of '+pairs.length+' windows read the old way, so the dial does not turn the fix off and the arms below are not what they claim');
     __cfg({winWalk:1});
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
  {v:'11.11',what:'a friend arriving on a fresh profile
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
