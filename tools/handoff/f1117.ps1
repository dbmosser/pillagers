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
  {v:'11.16',what:'a route through a doorway keeps clear of the walls behind it, not only the door frame, so a machine cutting through a building next door is not sent into a partition',
'@ @'
  {v:'11.17',what:'the doorways inside buildings are recorded and kept clear of furniture, so every building interior has a route in from its own front door',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot build a map';
     var bad=[], D=__movers.dist, NM=['COLD STORAGE','THE COLD MILE'];
     // A building is SEALED INSIDE when no route on the route grid runs from
     // just inside any of its own front doors to its centre.
     function survey(mi,dial){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(),B=g.map.buildings,Ds=g.map.doors,nd=g.map.navD,sealed=[],tested=0,q,u;
       for(q=0;q<B.length;q++){ var bd=B[q]; if(bd.w<120||bd.h<120) continue;
         var doors=[]; for(u=0;u<Ds.length;u++){ var dd=Ds[u]; if(dd.x>=bd.x-1&&dd.x<=bd.x+bd.w+1&&dd.y>=bd.y-1&&dd.y<=bd.y+bd.h+1) doors.push(dd); }
         if(!doors.length) continue;
         var cx=bd.x+bd.w/2, cy=bd.y+bd.h/2, ok=false;
         for(u=0;u<doors.length&&!ok;u++){ var d=doors[u], h=d.w>=d.h, top=(h?d.y:d.x)<=(h?bd.y:bd.x)+1;
           var ix=h?d.x+32:(top?d.x+16+30:d.x-30), iy=h?(top?d.y+16+30:d.y-30):d.y+32;
           if(__navPath(nd,ix,iy,cx,cy,0)) ok=true; }
         tested++; if(!ok) sealed.push(q); }
       return {tested:tested,sealed:sealed,idoors:(g.map.idoors?g.map.idoors.length:-1),ents:g.ents.length,cont:(g.containers||[]).length};
     }
     var on=[survey(0,1),survey(1,1)], off=[survey(0,0),survey(1,0)], mi;
     for(mi=0;mi<2;mi++){
       // THE FINDING. Measured on v11.16: 0 of 20 and 5 of 84, buildings 32, 33, 37, 38 and 74.
       if(on[mi].sealed.length) bad.push(NM[mi]+': '+on[mi].sealed.length+' of '+on[mi].tested+' building interiors have no route in from their own front door ['+on[mi].sealed.join(',')+']');
       // CONTROL ONE: the map records its interior doorways at all.
       if(on[mi].idoors<1) bad.push(NM[mi]+': the map records no interior doorways, so nothing can keep furniture out of them');
       // CONTROL TWO: the world did not move. No random number is drawn.
       if(on[mi].ents!==off[mi].ents||on[mi].cont!==off[mi].cont) bad.push(NM[mi]+': entities or containers moved between the arms, '+off[mi].ents+'/'+off[mi].cont+' to '+on[mi].ents+'/'+on[mi].cont+', so the rule drew a random number');
     }
     // CONTROL THREE: the old placement must still show the fault on the mile.
     if(off[1].sealed.length<4) bad.push('control: with furnIDoor off THE COLD MILE has only '+off[1].sealed.length+' sealed interiors against the 5 measured, so the dial does not restore the old placement');
     // AND A BODY GETS OUT. Building 32 on the mile by its fingerprint: a crawler
     // in its middle must leave and reach a player on open ground outside.
     function drive(dial,frames){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnIDoor:dial});
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       var g=__state(),p=g.player,B=g.map.buildings,W=g.map.walls,cw=null,u, WW=g.map.cols*g.map.cw, HH=g.map.rows*g.map.ch;
       for(u=0;u<g.ents.length;u++) if(g.ents[u].kind==='crawler'){ cw=g.ents[u]; break; }
       if(!cw) return {err:'no crawler on THE COLD MILE to drive'};
       g.ents.length=0; g.ents.push(cw);
       var bd=B[32]; if(!bd) return {err:'THE COLD MILE has no building 32'};
       if([bd.x,bd.y,bd.w,bd.h].join(',')!=='8126,2260,320,250') return {err:'building 32 on THE COLD MILE is ['+[bd.x,bd.y,bd.w,bd.h].join(',')+'] and not the 8126,2260,320,250 this was measured on'};
       function openAt(x,y){ if(x<120||y<120||x>WW-120||y>HH-120) return false; var q;
         for(q=0;q<W.length;q++){ var w=W[q]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(q=0;q<B.length;q++){ var b=B[q]; if(x>b.x-34&&x<b.x+b.w+34&&y>b.y-34&&y<b.y+b.h+34) return false; }
         return true; }
       var cand=[[bd.x-210,bd.y+bd.h/2],[bd.x+bd.w+210,bd.y+bd.h/2],[bd.x+bd.w/2,bd.y-210],[bd.x+bd.w/2,bd.y+bd.h+210]], tx=0,ty=0,ok=false;
       for(u=0;u<cand.length&&!ok;u++) if(openAt(cand[u][0],cand[u][1])){ tx=cand[u][0]; ty=cand[u][1]; ok=true; }
       if(!ok) return {err:'building 32 has no open ground outside it'};
       p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
       cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2; cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
       var t0=performance.now(), best=1e9, exitF=-1;
       for(var f=0;f<frames;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var d=D(cw,p); if(d<best) best=d;
         if(exitF<0&&!(cw.x>bd.x&&cw.x<bd.x+bd.w&&cw.y>bd.y&&cw.y<bd.y+bd.h)) exitF=f; }
       return {best:best,exitF:exitF};
     }
     var w1=drive(1,900);
     if(w1.err) return 'SKIP: '+w1.err;
     if(w1.best>60) bad.push('the crawler in the middle of building 32 got no closer than '+w1.best.toFixed(0)+' units to a player outside in fifteen seconds'+(w1.exitF<0?' and never left the building':''));
     var w0=drive(0,600);
     if(w0.err) return 'SKIP: '+w0.err;
     if(w0.exitF>=0) bad.push('control: with furnIDoor off the crawler in building 32 walks out anyway at frame '+w0.exitF+', so the old placement does not seal it and this build proves nothing');
     return bad.length?bad.join('; '):null; }},
  {v:'11.16',what:'a route through a doorway keeps clear of the walls behind it, not only the door frame, so a machine cutting through a building next door is not sent into a partition',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
