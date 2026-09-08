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

# v12.32 CHECK, inserted before the v12.31 entry. He is sprinted NORTH through
# the real keys and the real loop until both trails have filled, and then one
# frame is drawn with fillRect watched. A scent mark has a signature no other
# mark shares: two 3 by 5 rectangles. On the shipped build his own marks paint
# and the count is high; with the fix it is zero. The zero is proved to be a
# real zero and not a broken ruler by a control arm: one mark belonging to a
# pillager, right where he is standing, must still paint.
SubRx @'
  {v:'12.31',what:'the bench button says to hold it, a real mouse click on it says so and spends nothing, letting go early says so, and a synthetic click and a full hold still craft (his note of 2026-09-07: the crafting bar does not work and nothing can be crafted)',
'@ @'
  {v:'12.32',what:'sprinting lays one trail of boot prints and not two: his own scent marks are no longer painted over his real footprints, a pillager marks still paint, and the scent list itself still fills for the trackers that smell it (his note of 2026-09-07: many footprints while running vertically)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame&&window.__keys&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and drive the player';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be drawn';
     var bad=[], proto=CanvasRenderingContext2D.prototype, oFR=proto.fillRect, marks=0, watch=false;
     proto.fillRect=function(x,y,w,h){ if(watch&&w===3&&h===5) marks++; return oFR.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       g.ents.length=0;                       // nobody to interrupt the run
       p.downed=false; p.iv=99; p.stam=100; p.stamLock=0; p.stamRelease=0; p.ads=false;
       g.crouchTog=false; g.decals.length=0; g.prints=[];
       // SPRINT NORTH, through the real keys and the real loop, which is the only
       // driver that moves the player and lays either trail.
       // NORTH FIRST, because his note is about running up the screen, then the
       // other three, because the drop may have a wall on that side; the fix is
       // the same trail whichever way he runs. Stamina is topped up each frame:
       // the subject is the trail, and a stamina lock half way through would
       // measure the stamina bar instead.
       var K=__keys(), dirs=['KeyW','KeyS','KeyD','KeyA'], ran=0, used=null, sx, sy, di, t0;
       for(di=0;di<dirs.length&&ran<250;di++){
         for(var k in K) delete K[k];
         g.prints=[]; g.decals.length=0; p.stamLock=0; p.stamRelease=0;
         K[dirs[di]]=1; K.ShiftLeft=1;
         sx=p.x; sy=p.y; t0=performance.now();
         for(i=0;i<180;i++){ p.stam=100; __loop(t0+i*16.7); }
         for(var k2 in K) delete K[k2];
         ran=Math.sqrt((p.x-sx)*(p.x-sx)+(p.y-sy)*(p.y-sy)); used=dirs[di];
       }
       if(ran<250) return 'SKIP: three seconds of sprint moved him only '+Math.round(ran)+' units in any of the four directions, so he is boxed in and laid no trail here';
       var mine=0; for(i=0;i<g.prints.length;i++) if(g.prints[i].mine) mine++;
       if(mine<3) return 'SKIP: a 3 second sprint '+used+' over '+Math.round(ran)+' units laid only '+mine+' scent marks, so there is nothing to measure here';
       var realPrints=0; for(i=0;i<g.decals.length;i++) if(g.decals[i].print&&g.decals[i].mine) realPrints++;
       if(realPrints<2) bad.push('staging: the sprint laid only '+realPrints+' real boot prints, so the trail under test is not there');
       // ARM ONE, THE FINDING: his own scent marks must paint nothing.
       marks=0; watch=true; __frame(0.016); watch=false;
       if(marks>0) bad.push('a sprint painted '+marks+' scent marks over his own boot prints, which is the second trail he sees');
       // CONTROL: the counter can see a mark, so the zero above is a real zero.
       g.prints.push({x:p.x+2,y:p.y+2,t:0});   // no mine flag: a pillager left it, right where he stands
       marks=0; watch=true; __frame(0.016); watch=false;
       if(marks<2) bad.push('control: a pillager mark at his feet painted '+marks+' rectangles, so this check cannot see a mark at all and its zero proves nothing');
       // AND THE LIST ITSELF IS UNTOUCHED, so every tracker that smells it is untouched.
       var mine2=0; for(i=0;i<g.prints.length;i++) if(g.prints[i].mine) mine2++;
       if(mine2!==mine) bad.push('the scent list changed size on the draw side ('+mine+' to '+mine2+'), so something that smells it would behave differently');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       watch=false; proto.fillRect=oFR;
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.31',what:'the bench button says to hold it, a real mouse click on it says so and spends nothing, letting go early says so, and a synthetic click and a full hold still craft (his note of 2026-09-07: the crafting bar does not work and nothing can be crafted)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
