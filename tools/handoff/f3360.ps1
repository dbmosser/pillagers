$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'33.60',what:")) { throw "check 33.60 is in the fixture already" }

SubRx @'
  {v:'33.59',what:
'@ @'
  {v:'33.60',what:'cw-cx-pixground (86b): THE PIXEL GROUND. With the pixel look on, the same bake runs into a half size canvas (rr position identical, 4242 fingerprint held), an open floor sample of 64x64 art pixels holds at most 8 colours (over 20 before), no chunk step takes over 4 ms, the whole bake is under 1.5 s, and with the look off the canvas is full size',
   run:function(){
     if(typeof pixGroundFinish!=='function'||typeof PIXG!=='object') return 'no half density ground (pixGroundFinish)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var seen='', bad=[], map, g0, g1, r0, r1, tb, ws=[], d, rects, i, tries, best, sm, q, buildR, fp, mi, mode, streams={}, fps={}, oldPix=CFG.xfPix;
     function open(x,y,s){   // v28.xx (cw-cx-pixground):  a window of open floor: the same district at the corners and the middle, no wall, building, road, water or wood inside it
       var k, b2, ok=true, ds=[[0,0],[s,0],[0,s],[s,s],[s/2,s/2]];
       for(k=0;k<ds.length;k++){ q=map.districtAt?map.districtAt(x+ds[k][0],y+ds[k][1]):3; if(q===undefined) q=3; if(k===0) d=q; else if(q!==d) return false; }
       for(k=0;k<rects.length;k++){ b2=rects[k]; if(b2.w===undefined) continue; if(x<b2.x+b2.w+40&&x+s>b2.x-40&&y<b2.y+b2.h+40&&y+s>b2.y-40){ ok=false; break; } }
       return ok;
     }
     function colours(cv,x,y,s){   // v28.xx (cw-cx-pixground):  the colours in a window of a canvas, x,y,s in that canvas's own pixels
       var im=cv.getContext('2d').getImageData(x,y,s,s).data, m={}, k, n=0;
       for(k=0;k<im.length;k+=4){ var key=im[k]*65536+im[k+1]*256+im[k+2]; if(!m[key]){ m[key]=1; n++; } }
       seen=Object.keys(m).slice(0,16).map(function(z){ return (+z).toString(16); }).join(',');
       return n;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       map=__state().map;
       rects=map.buildings.concat(map.walls||[],map.roadRects||[],map.water||[],map.woods||[],map.plats||[],map.ramps||[],map.roadDashes||[]);
       CFG.xfPix=0; RNGS=1234567; g0=bakeGround(map); r0=RNGS;
       if(g0.width!==WORLD_W||g0.height!==WORLD_H) bad.push('xfPix 0 gives a '+g0.width+'x'+g0.height+' ground, not '+WORLD_W+'x'+WORLD_H);
       CFG.xfPix=1; RNGS=1234567; tb=pixNow(); g1=bakeGround(map); r1=RNGS;
       if(g1.getContext('2d').getTransform().a!==1) bad.push('queued ground retains a bake transform');
       if(r1!==r0) bad.push('the seeded stream moved: '+r0+' with the look off, '+r1+' with it on');
       if(g1.width!==Math.ceil(WORLD_W/PIX_ENV)||g1.height!==Math.ceil(WORLD_H/PIX_ENV)) bad.push('xfPix 1 gives a '+g1.width+'x'+g1.height+' ground, not half of '+WORLD_W+'x'+WORLD_H);
       g1=pixGroundFinish(g1);
       if(g1.getContext('2d').getTransform().a!==1) bad.push('finished ground retains a bake transform');
       if(PIXG.maxMs>4) bad.push('one chunk step took '+PIXG.maxMs.toFixed(1)+' ms (over 4; phase ms '+JSON.stringify(PIXG.slow)+'; initial raster '+PIXG.rasterMs.toFixed(1)+' ms)');
       if(pixNow()-tb>1500) bad.push('the whole bake took '+Math.round(pixNow()-tb)+' ms (over 1500)');
       // v28.xx (cw-cx-pixground):  one open window per district present on this map
       for(tries=0;tries<4;tries++) ws[tries]=null;
       for(var y=200;y<WORLD_H-300;y+=64) for(var x=200;x<WORLD_W-300;x+=64) if(open(x,y,128)&&!ws[d]) ws[d]=[x,y];
       sm=0;
       for(i=0;i<4;i++) if(ws[i]){
         sm++;
         q=colours(g1,ws[i][0]/2,ws[i][1]/2,64);
         if(q>8) bad.push('district '+i+': '+q+' colours in a 64x64 open floor sample at '+ws[i]+' (over 8): '+seen);
         tries=colours(g0,ws[i][0],ws[i][1],128);
         if(tries<=20) bad.push('district '+i+': the control window holds only '+tries+' colours with the look off, so the sample cannot tell');
       }
       if(!sm) bad.push('no open floor window found to sample');
       // v28.xx (cw-cx-pixground):  a stamp lands on the half density floor, also far out on the map, and stays on the art grid
       if(gfxHook('scar')){
         G.ground=g1;
         if(!scarStamp('scorch',WORLD_W-61,WORLD_H-61,{r:12})) bad.push('a scar at the far corner was refused by the half density floor');
       }
       // v28.xx (cw-cx-pixground):  Real seed-4242 raids in both sectors, both switch positions: stream and full fingerprints agree.
       g0.width=1; g0=null; g1=null;
       for(mi=0;mi<2;mi++) for(mode=0;mode<2;mode++){
         __endRaid('abandon'); __topClear(); __cleanProfile(); __resetCfg(); __pinDefaults(0); CFG.xfPix=mode;
         __deploy({kit:[],safe:null,mapIx:mi,seed:4242}); keys={};
         if(G.sim) bad.push('the build is simulated');
         fp=netUpFp(G); buildR=RNGS;
         if(!fp||fp.e!==[85,374][mi]||fp.c!==[165,593][mi]) bad.push('sector '+mi+' mode '+mode+': '+netUpFpText(fp));
         if(!mode){ streams[mi]=buildR; fps[mi]=fp; }
         else if(streams[mi]!==buildR||!netUpFpSame(fps[mi],fp)) bad.push('sector '+mi+': the pixel switch changed the raid stream or fingerprint');
         if(G.ground.width!==Math.ceil(WORLD_W/(mode?PIX_ENV:1))||G.ground.height!==Math.ceil(WORLD_H/(mode?PIX_ENV:1))) bad.push('sector '+mi+' mode '+mode+': wrong ground dimensions');
         if(mode&&G.ground._pg){
           var T=G.ground._pg, ch=PIXG.ch*PIX_ENV, px=Math.floor(G.player.x/ch), py=Math.floor(G.player.y/ch);
           if(!T.done[py*T.nx+px]) bad.push('sector '+mi+': spawn tile was not ready before the first frame');
         }
       }
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel ground check: '+String(err&&err.message||err);
     } finally {
       CFG.xfPix=oldPix;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
     } }},
  {v:'33.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
