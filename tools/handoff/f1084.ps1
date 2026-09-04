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
  {v:'10.83',what:'the map screen marks the buildings that have fallen, and marks nothing else',
'@ @'
  {v:'10.84',what:'a machine standing inside a building can work out a route to somebody outside it, and opening those doorways did not move the world',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot build a map';
     var bad=[];
     for(var mi=0;mi<2;mi++){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(), p=g.player, B=g.map.buildings, nm=(mi===0?'COLD STORAGE':'THE COLD MILE');
       var cw=null,i;
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ cw=g.ents[i]; break; }
       if(!cw) return 'SKIP: no crawler on this map to drive';
       g.ents.length=0; g.ents.push(cw);
       // The target has to be OPEN GROUND, or a failure says the target was
       // unreachable rather than the building being a box.
       function openAt(x,y){
         if(x<120||y<120) return false;
         var W=g.map.walls,k;
         for(k=0;k<W.length;k++){ var w=W[k]; if(x>w.x-34&&x<w.x+w.w+34&&y>w.y-34&&y<w.y+w.h+34) return false; }
         for(k=0;k<B.length;k++){ var b2=B[k]; if(x>b2.x-34&&x<b2.x+b2.w+34&&y>b2.y-34&&y<b2.y+b2.h+34) return false; }
         return true;
       }
       var trapped=[], tested=0;
       for(var q=0;q<B.length;q++){
         var bd=B[q];
         if(bd.w<120||bd.h<120) continue;
         var tx=0,ty=0,ok=false,cand=[[bd.x-210,bd.y+bd.h/2],[bd.x+bd.w+210,bd.y+bd.h/2],
                                       [bd.x+bd.w/2,bd.y-210],[bd.x+bd.w/2,bd.y+bd.h+210]];
         for(i=0;i<cand.length&&!ok;i++) if(openAt(cand[i][0],cand[i][1])){ tx=cand[i][0]; ty=cand[i][1]; ok=true; }
         if(!ok) continue;                      // nowhere clear to stand: not this check's question
         p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
         cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2;
         cw.state='chase'; cw.alert=3; cw.cd=0; cw.tx=tx; cw.ty=ty;
         cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
         var t0=performance.now(), got=false;
         // WAITING IS NOT FAILING: the route search is rationed to one a frame
         // for the whole map and a body that has just searched waits 2.6 to 3.8
         // seconds. The stale flags are cleared every step so the only thing
         // measured is whether the router can answer at all.
         for(var f=0;f<12;f++){
           cw.pathT=0; cw.pathGoal=null; cw.pathFail=false;
           __loop(t0+f*16.7); p.x=tx; p.y=ty;
           if(cw.path&&cw.path.length) got=true;
         }
         tested++;
         if(!got) trapped.push(q);
       }
       if(!tested) return 'SKIP: no building on '+nm+' had open ground to stand outside it';
       // THE BUDGET EACH MAP HAS EARNED. v10.83 read 4 and 15 here. Asserting a
       // zero this build has not reached would fail the build that improved it;
       // the moment somebody makes it worse this says so by name.
       var budget=(mi===0)?3:8;
       if(trapped.length>budget)
         bad.push(nm+': '+trapped.length+' of '+tested+' buildings are boxes a machine cannot route out of, against the '+budget+' this build measured ['+trapped.slice(0,8).join(',')+']');
       // CONTROL ONE: the doorways were recorded and cells were really opened.
       if(!(g.map.doors&&g.map.doors.length)) bad.push('control: '+nm+' recorded no doorways at all');
       else if(!(g.map.navD&&g.map.navD.opened)) bad.push('control: '+nm+' has '+g.map.doors.length+' doorways and opened 0 cells');
       // CONTROL TWO, AND IT IS THE ONE THAT CAUGHT MY FIRST CUT OF THIS FIX.
       // The routing grid must be a SEPARATE object from the one the map fills
       // itself with. Carving map.nav moved what got placed, counts unchanged
       // and the scene different, and only a sprite check noticed.
       if(g.map.navD===g.map.nav) bad.push('control: '+nm+' routes on the same grid the map places from, so opening a door moves the contents of the world');
       else if(g.map.nav&&g.map.navD){
         var same=0,dif=0,bi;
         for(bi=0;bi<g.map.nav.blk.length;bi++){ if(g.map.nav.blk[bi]!==g.map.navD.blk[bi]) dif++; else same++; }
         if(!dif) bad.push('control: '+nm+' has two identical grids, so nothing was opened after all');
       }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.83',what:'the map screen marks the buildings that have fallen, and marks nothing else',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
