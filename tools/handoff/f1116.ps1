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
  {v:'11.15',what:'the route grid is padded for the body that walks it, so a crawler with a route out of a building walks it, through the middle of the door and clear of the corners',
'@ @'
  {v:'11.16',what:'a route through a doorway keeps clear of the walls behind it, not only the door frame, so a machine cutting through a building next door is not sent into a partition',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot build a map';
     var bad=[], D=__movers.dist;
     // One crawler in the middle of a building, the player on open ground
     // inside the world outside it, the chase held on, a fresh deploy per trial.
     function drive(mi,bIx,doorClear,frames,rectWant){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({doorClear:doorClear});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(),p=g.player,B=g.map.buildings,W=g.map.walls,cw=null,u, WW=g.map.cols*g.map.cw, HH=g.map.rows*g.map.ch;
       for(u=0;u<g.ents.length;u++) if(g.ents[u].kind==='crawler'){ cw=g.ents[u]; break; }
       if(!cw) return {err:'no crawler to drive on map '+mi};
       g.ents.length=0; g.ents.push(cw);
       var bd=B[bIx]; if(!bd) return {err:'map '+mi+' has no building '+bIx};
       if([bd.x,bd.y,bd.w,bd.h].join(',')!==rectWant) return {err:'building '+bIx+' on map '+mi+' is ['+[bd.x,bd.y,bd.w,bd.h].join(',')+'] and not the '+rectWant+' this was traced on'};
       function openAt(x,y){ if(x<120||y<120||x>WW-120||y>HH-120) return false; var q;
         for(q=0;q<W.length;q++){ var w=W[q]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(q=0;q<B.length;q++){ var b=B[q]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
       var cand=[[bd.x-210,bd.y+bd.h/2],[bd.x+bd.w+210,bd.y+bd.h/2],[bd.x+bd.w/2,bd.y-210],[bd.x+bd.w/2,bd.y+bd.h+210]], tx=0,ty=0,ok=false;
       for(u=0;u<cand.length&&!ok;u++) if(openAt(cand[u][0],cand[u][1])){ tx=cand[u][0]; ty=cand[u][1]; ok=true; }
       if(!ok) return {err:'building '+bIx+' on map '+mi+' has no open ground outside it'};
       p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
       cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2; cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
       var t0=performance.now(), best=1e9, exitF=-1;
       for(var f=0;f<frames;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var d=D(cw,p); if(d<best) best=d;
         if(exitF<0&&!(cw.x>bd.x&&cw.x<bd.x+bd.w&&cw.y>bd.y&&cw.y<bd.y+bd.h)) exitF=f; }
       return {best:best,exitF:exitF,opened:g.map.navD?g.map.navD.opened:-1};
     }
     // THE TRACED CASE: building 20 on THE COLD MILE, routed out through the
     // building next door, whose west door has a partition one unit behind the
     // cells the old carve opened.
     var on=drive(1,20,1,900,'3380,3130,300,220');
     if(on.err) return 'SKIP: '+on.err;
     if(on.best>60) bad.push('the crawler out of building 20 on THE COLD MILE got no closer than '+on.best.toFixed(0)+' units in fifteen seconds'+(on.exitF<0?' and never left the building':''));
     // CONTROL ONE: the old carve must still show the fault. Measured 313 at
     // fifteen seconds, standing at 3000,3178.
     var off=drive(1,20,0,900,'3380,3130,300,220');
     if(off.err) return 'SKIP: '+off.err;
     if(off.best<150) bad.push('control: with doorClear off the crawler out of building 20 got to '+off.best.toFixed(0)+' units, so the old carve does not show the fault this build is for');
     // CONTROL TWO: the strict pass opens fewer cells than the old rule.
     if(!(on.opened<off.opened)) bad.push('control: the route grid opens '+on.opened+' door cells with the strict pass and '+off.opened+' without, so the pass rejects nothing');
     // GUARD: a building that delivered before still does. Building 8 on COLD
     // STORAGE, out of the door at frame 66 and on the player at 34.
     var g8=drive(0,8,1,600,'2520,900,380,340');
     if(g8.err) return 'SKIP: '+g8.err;
     if(g8.best>60) bad.push('guard: the crawler in building 8 on COLD STORAGE, which reached the player at 34 units before this build, now gets no closer than '+g8.best.toFixed(0));
     return bad.length?bad.join('; '):null; }},
  {v:'11.15',what:'the route grid is padded for the body that walks it, so a crawler with a route out of a building walks it, through the middle of the door and clear of the corners',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
