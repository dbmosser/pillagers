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

# v12.43 CHECK, inserted before the v12.42 entry. It drives the real keys and
# the real frame loop, the only driver that moves the player and lays a mark,
# using the same four-direction harness as the shipped v12.33 check so a wall on
# one side cannot decide the answer. The control runs FIRST: a plain sprint on
# dry land must lay marks, or the two zeroes after it prove nothing at all. The
# wading arm counts only the frames he is actually still in the water, and if it
# cannot be staged the whole check reports as a SKIP naming what was and was not
# measured, because half a check is not a pass.
SubRx @'
  {v:'12.42',what:'a gun that goes through the backpack keeps its magazine: loaded plus reserve is conserved across a stow and an equip, on a full gun and on an empty one, so stowing no longer throws the load away and re-equipping no longer conjures half a magazine, while a gun found in the field still arrives on half a magazine (2026-09-07 audit)',
'@ @'
  {v:'12.43',what:'holding the sprint key while aiming, or while wading, lays no scent behind a man who is not sprinting, so nothing hunts him along a trail he never made; a plain sprint on dry land still lays one (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot deploy and drive the player';
     if(typeof inWaterDeep!=='function') return 'SKIP: this build has no deep water to wade in';
     var bad=[], noWade=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, k;
       if(!g||!p) return 'SKIP: no live raid to run in';
       g.ents.length=0;                       // nobody to interrupt the run
       var K=__keys(), dirs=['KeyW','KeyS','KeyD','KeyA'];
       var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
       var keepTs=lastTs, homeX=p.x, homeY=p.y;
       var INSET=(CFG.wadeInset===undefined?11:CFG.wadeInset);
       function wet(x,y){ return !!inWaterDeep(x,y,INSET); }
       function mineCount(){ var c=0,j; for(j=0;j<g.prints.length;j++) if(g.prints[j].mine) c++; return c; }
       function reset(){
         for(k in K) delete K[k];
         p.downed=false; p.iv=99; p.stam=100; p.stamLock=0; p.stamRelease=0;
         p.ads=false; p.roll=0; g.crouchTog=false; g.prints=[];
       }
       // A RUN IN ONE DIRECTION with the sprint key down. mustWade stops counting
       // the moment he walks out of the water, so a mark laid on dry land can
       // never be read as a mark laid while wading.
       function run(dir,ads,n,mustWade){
         var sx=p.x, sy=p.y, frames=0, left=false;
         K[dir]=1; K.ShiftLeft=1;
         for(i=0;i<n;i++){
           if(mustWade&&!wet(p.x,p.y)){ left=true; break; }
           p.stam=100; p.stamLock=0; p.stamRelease=0; if(ads) p.ads=true;
           clk+=16.7; __loop(clk); frames++;
         }
         for(k in K) delete K[k];
         return {ran:Math.sqrt((p.x-sx)*(p.x-sx)+(p.y-sy)*(p.y-sy)),mine:mineCount(),frames:frames,left:left};
       }
       // THE CONTROL FIRST, on dry land with no aim: this is what a sprint is
       // supposed to do, and without it the zeroes after it prove nothing.
       var ctl=null, used=null, di;
       for(di=0;di<dirs.length;di++){
         p.x=homeX; p.y=homeY; reset();
         if(wet(p.x,p.y)) continue;
         ctl=run(dirs[di],false,180,false); used=dirs[di];
         if(ctl.ran>=250&&ctl.mine>=3) break;
       }
       if(!ctl||ctl.ran<250||ctl.mine<3) return 'SKIP: three seconds of plain sprint moved him '+Math.round(ctl?ctl.ran:0)+' units and laid '+((ctl&&ctl.mine)||0)+' marks in every direction, so he is boxed in and there is no trail to measure here';
       // THE FINDING, AIMING. Same key, same direction, aim held down.
       p.x=homeX; p.y=homeY; reset();
       var A=run(used,true,180,false);
       if(A.ran<20) bad.push('staging: with the aim held he covered only '+Math.round(A.ran)+' units, so this arm never walked anywhere');
       else if(A.mine>0) bad.push('holding the sprint key while AIMING laid '+A.mine+' scent marks over '+Math.round(A.ran)+' units, and everything on patrol within 170 units follows that scent, so he is hunted along a trail he never made at the speed he is slowest');
       // THE FINDING, WADING. He is PLACED in deep water for this one, which is a
       // placement and not a walk, and it is said plainly in the design entry.
       var wx=-1, wy=-1, sc, cx, cy, W=g.map.cols*g.map.cw, H=g.map.rows*g.map.ch;
       for(sc=0;sc<6000&&wx<0;sc++){
         cx=60+((sc*137)%Math.max(120,W-120));
         cy=60+((sc*271)%Math.max(120,H-120));
         if(wet(cx,cy)) { wx=cx; wy=cy; }
       }
       if(wx<0) noWade='no deep water was found anywhere on this map and seed';
       else{
         p.x=wx; p.y=wy; reset();
         if(!wet(p.x,p.y)) noWade='he would not stand in the water that was found';
         else{
           var B=run(used,false,180,true);
           if(B.frames<20) noWade='he was out of the water again after '+B.frames+' frames, which is too few to lay a mark either way';
           else if(B.mine>0) bad.push('holding the sprint key while WADING laid '+B.mine+' scent marks in '+B.frames+' frames of water, and everything on patrol within 170 units follows that scent, so he is hunted along a trail he never made at the slowest he ever moves');
         }
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.ads=false; g2.player.iv=0; } }catch(_a){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     if(bad.length) return bad.join('; ');
     // HALF A CHECK IS NOT A PASS.
     if(noWade) return 'SKIP: the aiming half passed, but '+noWade+', so the wading half is not measured here';
     return null; }},
  {v:'12.42',what:'a gun that goes through the backpack keeps its magazine: loaded plus reserve is conserved across a stow and an equip, on a full gun and on an empty one, so stowing no longer throws the load away and re-equipping no longer conjures half a magazine, while a gun found in the field still arrives on half a magazine (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
