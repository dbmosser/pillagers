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
window.__navPath=function(nav,sx,sy,tx,ty,r){ return navPath(nav,sx,sy,tx,ty,r); };
'@

SubRx @'
  {v:'11.14',what:'no piece of furniture sits in a doorway, and a machine inside a building can walk out of the door it routes through',
'@ @'
  {v:'11.15',what:'the route grid is padded for the body that walks it, so a crawler with a route out of a building walks it, through the middle of the door and clear of the corners',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot build a map';
     var bad=[], D=__movers.dist, c;
     // One crawler in the middle of a building, the player on open ground
     // outside it, the chase held on. Fresh deploy per trial, always: a shared
     // deploy with the clock restarted carries the wall hug from one trial into
     // the next, which is how v11.12 reported two buildings freed that were not.
     function drive(bIx,navBody,frames,rectWant){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({navBody:navBody});
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(),p=g.player,B=g.map.buildings,W=g.map.walls,cw=null,u;
       for(u=0;u<g.ents.length;u++) if(g.ents[u].kind==='crawler'){ cw=g.ents[u]; break; }
       if(!cw) return {err:'no crawler on COLD STORAGE to drive'};
       g.ents.length=0; g.ents.push(cw);
       var bd=B[bIx]; if(!bd) return {err:'COLD STORAGE has no building '+bIx};
       if([bd.x,bd.y,bd.w,bd.h].join(',')!==rectWant) return {err:'building '+bIx+' is ['+[bd.x,bd.y,bd.w,bd.h].join(',')+'] and not the '+rectWant+' this was traced on'};
       function openAt(x,y){ if(x<120||y<120) return false; var q;
         for(q=0;q<W.length;q++){ var w=W[q]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(q=0;q<B.length;q++){ var b=B[q]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
       var cand=[[bd.x-210,bd.y+bd.h/2],[bd.x+bd.w+210,bd.y+bd.h/2],[bd.x+bd.w/2,bd.y-210],[bd.x+bd.w/2,bd.y+bd.h+210]], tx=0,ty=0,ok=false;
       for(u=0;u<cand.length&&!ok;u++) if(openAt(cand[u][0],cand[u][1])){ tx=cand[u][0]; ty=cand[u][1]; ok=true; }
       if(!ok) return {err:'building '+bIx+' has no open ground outside it'};
       p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
       cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2; cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
       var t0=performance.now(), best=1e9, exitF=-1;
       for(var f=0;f<frames;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var d=D(cw,p); if(d<best) best=d;
         if(exitF<0&&!(cw.x>bd.x&&cw.x<bd.x+bd.w&&cw.y>bd.y&&cw.y<bd.y+bd.h)) exitF=f; }
       return {best:best,exitF:exitF,opened:g.map.navD?g.map.navD.opened:-1};
     }
     // THE TWO TRACED. 15: a pull grazing a partition end at 3216,1960. 18: a
     // door waypoint one unit inside the jamb at 2728,2696.
     var CASES=[[15,'2980,1760,380,340'],[18,'2260,2520,460,300']], onOpened=-1, offOpened=-1;
     for(c=0;c<CASES.length;c++){
       var on=drive(CASES[c][0],15,900,CASES[c][1]);
       if(on.err) return 'SKIP: '+on.err;
       if(on.exitF<0) bad.push('the crawler in building '+CASES[c][0]+' never left it in fifteen seconds, with a route out');
       else if(on.best>60) bad.push('the crawler in building '+CASES[c][0]+' left at frame '+on.exitF+' and got no closer than '+on.best.toFixed(0)+' units in fifteen seconds');
       onOpened=on.opened;
       // CONTROL: the old grid must still show the fault. Measured: neither
       // crawler leaves its building in fifteen seconds; ten is asked for here.
       var off=drive(CASES[c][0],0,600,CASES[c][1]);
       if(off.err) return 'SKIP: '+off.err;
       if(off.exitF>=0) bad.push('control: with navBody off the crawler in building '+CASES[c][0]+' walks out anyway at frame '+off.exitF+', so the old grid does not show the fault this build is for');
       offOpened=off.opened;
     }
     // CONTROL TWO: the dial really changes the route grid.
     if(onOpened===offOpened) bad.push('control: the route grid opens '+onOpened+' door cells with the dial on and off alike, so the dial does not build a different grid');
     // GUARD: a building that already delivered its crawler still does.
     // Building 8, out of the door at frame 108 and on the player at 34.
     var g8=drive(8,15,600,'2520,900,380,340');
     if(g8.err) return 'SKIP: '+g8.err;
     if(g8.best>60) bad.push('guard: the crawler in building 8, which reached the player at 34 units before this build, now gets no closer than '+g8.best.toFixed(0));
     return bad.length?bad.join('; '):null; }},
  {v:'11.14',what:'no piece of furniture sits in a doorway, and a machine inside a building can walk out of the door it routes through',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
