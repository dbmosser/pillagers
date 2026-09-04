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
  {v:'10.54',what:'the OUTFIT rack exists, each suit repaints the whole figure and hides the coat colour, an unowned suit changes nothing, and the Depot lists the slot',
'@ @'
  {v:'10.55',what:'footprints follow ground covered: evenly spaced in the open at a walk and a sprint, none while pinned against a wall, none inside a wall',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__loop)) return 'SKIP: this build cannot run the live loop';
     __startRaid({seed:4242,mapIx:0});
     if(!G||!G.player||!G.map) return 'no raid';
     var p=G.player, K=keys;
     for(var k in K) K[k]=false;
     var keep={x:p.x,y:p.y,tog:G.sprintTog,stam:p.stam,printAcc:p.printAcc,decals:G.decals};
     function mine(){ return G.decals.filter(function(d){ return d.print&&d.mine; }); }
     function inWall(x,y){ var W=G.map.walls; for(var i=0;i<W.length;i++){ var w=W[i]; if(x>w.x&&x<w.x+w.w&&y>w.y&&y<w.y+w.h) return true; } return false; }
     function clearOf(x,y,r){ var W=G.map.walls; for(var i=0;i<W.length;i++){ var w=W[i]; if(x+r>w.x&&x-r<w.x+w.w&&y+r>w.y&&y-r<w.y+w.h) return false; } return true; }
     // A stretch of open floor: scan right from a wall-free spot for 260 units of clearance.
     function openSpot(){
       var W=G.map.walls;
       for(var t=0;t<4000;t++){
         var x=200+((t*977)%(WORLD_W-400)), y=200+((t*613)%(WORLD_H-400));
         var ok=true; for(var s=0;s<=260&&ok;s+=20) if(!clearOf(x+s,y,16)||inWater(x+s,y)) ok=false;
         if(ok) return {x:x,y:y};
       }
       return null;
     }
     var t=performance.now();
     function run(frames){ for(var i=0;i<frames;i++){ t+=16.7; __loop(t); } }
     try{
       var sp=openSpot(); if(!sp) return 'SKIP: no 260 unit open stretch found on this map';
       // 1. A walk across open ground: prints evenly spaced.
       G.decals=[]; p.x=sp.x; p.y=sp.y; p.printAcc=0; p.stam=100; G.sprintTog=false;
       K['KeyD']=true; run(70); K['KeyD']=false;
       var pw=mine(), gaps=[];
       for(var i=1;i<pw.length;i++) gaps.push(Math.hypot(pw[i].x-pw[i-1].x,pw[i].y-pw[i-1].y));
       if(pw.length<2) bad.push('a 70 frame walk left '+pw.length+' prints');
       for(i=0;i<gaps.length;i++) if(gaps[i]<48||gaps[i]>64){ bad.push('walking prints are '+gaps[i].toFixed(1)+' apart, not about 56'); break; }
       // 2. A sprint across open ground: the same spacing.
       G.decals=[]; p.x=sp.x; p.y=sp.y; p.printAcc=0; p.stam=100; G.sprintTog=true;
       K['KeyD']=true; run(45); K['KeyD']=false;
       var ps=mine(), gs=[];
       for(i=1;i<ps.length;i++) gs.push(Math.hypot(ps[i].x-ps[i-1].x,ps[i].y-ps[i-1].y));
       if(ps.length<2) bad.push('a 45 frame sprint left '+ps.length+' prints');
       for(i=0;i<gs.length;i++) if(gs[i]<48||gs[i]>64){ bad.push('sprinting prints are '+gs[i].toFixed(1)+' apart, not about 56'); break; }
       // 3. Pinned against a wall, sprinting into it: no prints, and none inside the wall.
       // A wall that actually stops him: tried, not assumed, because a window,
       // a door or a piece of furniture is in the same list and lets him through.
       var wall=null; var W=G.map.walls;
       for(i=0;i<W.length&&!wall;i++){
         var w=W[i];
         if(!(w.h>=40&&w.w>=8&&clearOf(w.x-40,w.y+w.h/2,14)&&!inWater(w.x-40,w.y+w.h/2))) continue;
         p.x=w.x-p.r-0.5; p.y=w.y+w.h/2; G.sprintTog=false; p.stam=100;
         var tx=p.x; K['KeyD']=true; run(6); K['KeyD']=false;
         if(Math.abs(p.x-tx)<1) wall=w;
       }
       if(!wall) return 'SKIP: no wall on this map stops him from the left';
       G.decals=[]; p.x=wall.x-p.r-0.5; p.y=wall.y+wall.h/2; p.printAcc=0; p.stam=100; G.sprintTog=true;
       var x0=p.x; K['KeyD']=true; run(120); K['KeyD']=false; G.sprintTog=false;
       var pp=mine();
       if(Math.abs(p.x-x0)>1) bad.push('he was not pinned: moved '+(p.x-x0).toFixed(1));
       else if(pp.length>1) bad.push('pinned against a wall, sprinting into it for 120 frames, he stamped '+pp.length+' prints under himself');
       for(i=0;i<pp.length;i++) if(inWall(pp[i].x,pp[i].y)){ bad.push('a print was stamped inside a wall'); break; }
     } finally {
       for(var k2 in K) K[k2]=false;
       p.x=keep.x; p.y=keep.y; G.sprintTog=keep.tog; p.stam=keep.stam; p.printAcc=keep.printAcc; G.decals=keep.decals;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.54',what:'the OUTFIT rack exists, each suit repaints the whole figure and hides the coat colour, an unowned suit changes nothing, and the Depot lists the slot',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
