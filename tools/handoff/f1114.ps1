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
  {v:'11.13',what:'the Undercroft crowd never wears the ghost mask or the Spartan helmet, and still dresses from the rest of the rack',
'@ @'
  {v:'11.14',what:'no piece of furniture sits in a doorway, and a machine inside a building can walk out of the door it routes through',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot build a map';
     var bad=[], D=__movers.dist, i, j;
     // A doorway is PLUGGED when the longest clear run across its gap, with
     // furniture within 40 units of the wall on either side counted, is under
     // the 30 units a body needs.
     function plugged(g){ var W=g.map.walls,Ds=g.map.doors,n=0,furn=0;
       for(i=0;i<W.length;i++) if(W[i].furn) furn++;
       for(i=0;i<Ds.length;i++){ var d=Ds[i],h=d.w>=d.h;
         var ex=h?{x:d.x,y:d.y-40,w:d.w,h:d.h+80}:{x:d.x-40,y:d.y,w:d.w+80,h:d.h}, iv=[];
         for(j=0;j<W.length;j++){ var w=W[j]; if(!w.furn) continue;
           if(w.x<ex.x+ex.w&&w.x+w.w>ex.x&&w.y<ex.y+ex.h&&w.y+w.h>ex.y)
             iv.push(h?[Math.max(d.x,w.x),Math.min(d.x+d.w,w.x+w.w)]:[Math.max(d.y,w.y),Math.min(d.y+d.h,w.y+w.h)]); }
         if(!iv.length) continue;
         iv.sort(function(a,b){ return a[0]-b[0]; });
         var lo=h?d.x:d.y,hi=h?d.x+d.w:d.y+d.h,cur=lo,best=0;
         for(j=0;j<iv.length;j++){ if(iv[j][0]>cur) best=Math.max(best,iv[j][0]-cur); cur=Math.max(cur,iv[j][1]); }
         best=Math.max(best,hi-cur);
         if(best<30) n++; }
       return {plugged:n,doors:Ds.length,furn:furn,ents:g.ents.length,cont:(g.containers||[]).length}; }
     var NM=['COLD STORAGE','THE COLD MILE'], on=[], off=[], mi;
     for(mi=0;mi<2;mi++){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnDoor:0});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242}); off.push(plugged(__state()));
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnDoor:1});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242}); on.push(plugged(__state()));
       // THE FINDING. Measured on v11.13: 11 of 37 and 35 of 151.
       if(on[mi].plugged>0) bad.push(NM[mi]+': '+on[mi].plugged+' of '+on[mi].doors+' doorways still hold furniture leaving under 30 units of clear run');
       // CONTROL ONE: the old placement must still show the fault, or this A/B
       // is two copies of the same thing.
       var floor=(mi===0)?8:25;
       if(off[mi].plugged<floor) bad.push('control: with furnDoor off '+NM[mi]+' has only '+off[mi].plugged+' plugged doorways against the '+(mi===0?11:35)+' measured, so the dial does not restore the old placement');
       // CONTROL TWO: the world did not move. The rule draws no random number,
       // so the entity count is the same either way.
       if(on[mi].ents!==off[mi].ents) bad.push(NM[mi]+': entities '+off[mi].ents+' to '+on[mi].ents+', so the rule drew a random number and moved the world');
       // CONTROL THREE: pieces slide, they are not simply thrown away.
       if(on[mi].furn<off[mi].furn*0.8) bad.push(NM[mi]+': furniture fell from '+off[mi].furn+' to '+on[mi].furn+', more than a fifth lost, so pieces are being dropped where they should slide');
     }
     // AND THE DOOR CAN BE WALKED. The crawler in building 8 on COLD STORAGE,
     // whose doorway held a 36 by 26 piece, must now reach a player outside.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({furnDoor:1,winWalk:1});
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(),p=g.player,B=g.map.buildings,cw=null;
     for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ cw=g.ents[i]; break; }
     if(!cw) return 'SKIP: no crawler on COLD STORAGE to drive';
     g.ents.length=0; g.ents.push(cw);
     var bd=B[8];
     if(!bd||[bd.x,bd.y,bd.w,bd.h].join(',')!=='2520,900,380,340') bad.push('building 8 on COLD STORAGE is not the 2520,900,380,340 this was traced on');
     else {
       var tx=bd.x-210, ty=bd.y+bd.h/2;
       p.x=tx; p.y=ty; p.iv=99; p.hp=100; p.downed=0;
       cw.x=bd.x+bd.w/2; cw.y=bd.y+bd.h/2; cw.path=null; cw.pathFail=false; cw.pathT=0; cw.pathGoal=null;
       var t0=performance.now(), best=1e9;
       for(var f=0;f<600;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var dd=D(cw,p); if(dd<best) best=dd; }
       // MEASURED before this build: 241 with the old routing and 273 with
       // v11.12, never closer, at seven seconds and at thirty.
       if(best>60) bad.push('the crawler in building 8 got no closer than '+best.toFixed(0)+' units in ten seconds, so its doorway is still not walkable');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.13',what:'the Undercroft crowd never wears the ghost mask or the Spartan helmet, and still dresses from the rest of the rack',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
