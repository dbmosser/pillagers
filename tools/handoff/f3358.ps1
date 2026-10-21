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

if ($s.Contains("  {v:'33.58',what:")) { throw "check 33.58 is in the fixture already" }

SubRx @'
  {v:'33.57',what:
'@ @'
  {v:'33.58',what:'cw-pixbody (86c): with the pixel look on a plain pillager is baked pixel layers: a standing one costs at most 8 canvas calls, the 27 looks are 27 different sprites about 50 px tall with the soles on the foot point, a bot wears only the red ramp with angry brows and red eyes, the pixel muzzle sits on the vector muzzle at all 32 aim steps, a forced throw still draws a body, and no frame reads pixels back',
   run:function(){
     if(typeof pixDrawOp!=='function'||typeof pixBodyCell!=='function'||typeof pxBuildGun!=='function') return 'no pixel pillager (pixDrawOp, pixBodyCell, pxBuildGun)';
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__gfxCount&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], g, i, h, k, c, n, seen={}, cell, d, mnY, mxY, x, y, f0, f1, b0, b1, e0, cnt, cntOn, cntOff, tries, st, keep=null, saved=false, OK={}, FR={}, off={}, col, redN, brow, reye, fb, fe, bu, bd, fu, fd, a, nm, kk, id, D, ext, fl, sg, ang, spr, sc2, t, mxp, myp, hit, dx, dy, gi, step, ok1, GL=['rifle','smg','pistol'];
     var names=['fillRect','strokeRect','clearRect','fill','stroke','arc','ellipse','drawImage','fillText','strokeText','save','restore','setTransform','rotate','translate','scale','beginPath','getTransform','createRadialGradient','createLinearGradient','getImageData','putImageData'];
     function fnv(data){ var q=2166136261, j; for(j=0;j<data.length;j++){ q^=data[j]; q=Math.imul(q,16777619)>>>0; } return q; }
     function px(canvas){ return canvas.getContext('2d').getImageData(0,0,canvas.width,canvas.height).data; }
     function hexOf(dd,ii){ return '#'+((1<<24)+(dd[ii]<<16)+(dd[ii+1]<<8)+dd[ii+2]).toString(16).slice(1); }
     function addAll(set,arr){ var j; for(j=0;j<arr.length;j++) set[arr[j]]=1; }
     function body(s,mode,face,tr){   // draws one body, trying a few frames so the bake budget lets every layer in; true when it came out in pixels
       var j, before=PIX.bodies;
       for(j=0;j<(tr||14)&&PIX.bodies===before;j++){ pixFrame(); drawOp(600,500,face||0,0,'#242832',0,0,mode,0,s); }
       return PIX.bodies>before;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       // the 27 looks: 27 different sprites, about 50 px tall, the lowest row on the foot point
       for(h=0;h<3;h++) for(k=0;k<3;k++) for(c=0;c<3;c++){
         nm=PXB_HEADS[h]+'/'+PXB_SKINS[k]+'/'+PXB_CLOTHS[c];
         cell=pixBodyCell(PXB_HEADS[h],PXB_SKINS[k],PXB_CLOTHS[c],0,0,0); d=px(cell); n=fnv(d);
         if(seen[n]) bad.push(nm+' is the same sprite as '+seen[n]); else seen[n]=nm;
         mnY=1e9; mxY=-1;
         for(y=0;y<cell.height;y++) for(x=0;x<cell.width;x++) if(d[(y*cell.width+x)*4+3]){ if(y<mnY) mnY=y; if(y>mxY) mxY=y; }
         if(Math.abs((mxY-mnY+1)-PXB.TARGET)>2) bad.push(nm+' is '+(mxY-mnY+1)+' px tall, wanted '+PXB.TARGET+' within 2');
         if(mxY!==PXB.AY) bad.push(nm+' lowest row is '+mxY+', not the foot anchor row '+PXB.AY);
       }
       if(Object.keys(seen).length!==27) bad.push('only '+Object.keys(seen).length+' different looks of 27');
       // a pillager bot: every clothes pixel in the red ramp, angry brows, red eyes; a friendly body has none of those
       for(a in PXB_REDS){ if(typeof PXB_REDS[a]==='string') OK[PXB_REDS[a]]=1; else addAll(OK,PXB_REDS[a]); }
       addAll(OK,PIXRAMPS.skins.fair); addAll(OK,PXB_HAIR); addAll(OK,PXB_BOOT); OK[PIX_INK]=1; OK['#1c1622']=1;
       for(a in PXB_EYE) OK[PXB_EYE[a]]=1;
       for(a in PXB_RAMP) for(kk in PXB_RAMP[a]){ if(typeof PXB_RAMP[a][kk]==='string') FR[PXB_RAMP[a][kk]]=1; else addAll(FR,PXB_RAMP[a][kk]); }
       for(a in OK) delete FR[a];
       bd=px(pxBuildUpper({head:'hood',skin:'fair',clothes:'heavy',bot:1,mir:0,pup:0,arms:1,lamp:'',band:''}).c);
       fd=px(pxBuildUpper({head:'hood',skin:'fair',clothes:'heavy',bot:0,mir:0,pup:0,arms:1,lamp:'',band:''}).c);
       redN=0; brow=0; reye=0; fb=0; fe=0;
       for(i=0;i<bd.length;i+=4){
         if(!bd[i+3]) continue; col=hexOf(bd,i);
         if(!OK[col]) off[col]=1;
         if(FR[col]) off[col]=1;
         if(col===PXB_REDS.coat[1]||col===PXB_REDS.coat[2]||col===PXB_REDS.gear[1]||col===PXB_REDS.pack[1]) redN++;
         if(col===PXB_EYE.brow) brow++;
         if(col===PXB_EYE.red) reye++;
       }
       for(i=0;i<fd.length;i+=4){ if(!fd[i+3]) continue; col=hexOf(fd,i); if(col===PXB_EYE.brow) fb++; if(col===PXB_EYE.red) fe++; }
       if(Object.keys(off).length) bad.push('a bot wears colours outside the red ramp: '+Object.keys(off).slice(0,5).join(' '));
       if(redN<150) bad.push('a bot has only '+redN+' red clothes pixels');
       if(brow<8) bad.push('a bot has '+brow+' brow pixels, wanted 8 or more');
       if(reye<2) bad.push('a bot has '+reye+' red eye pixels');
       if(fb||fe) bad.push('a friendly body has bot marks ('+fb+' brow, '+fe+' red eye pixels)');
       // the pixel muzzle sits on the vector muzzle at all 32 aim steps
       sc2=document.createElement('canvas').getContext('2d');
       for(gi=0;gi<GL.length;gi++){
         id=GL[gi]; D=GUNDEF[id]; if(!D){ bad.push('no gun '+id); continue; }
         ext=D.pist?2:0;
         for(step=0;step<32;step++){
           ang=step*Math.PI/16; fl=Math.cos(ang)<0?-1:1; sg=fl;
           sc2.setTransform(1,0,0,1,0,0); sc2.rotate(ang); sc2.scale(1,sg); sc2.scale(GUNK,GUNK); t=sc2.getTransform().transformPoint(new DOMPoint(D.tip+ext,D.by));
           spr=pxBuildGun(id,0,'','',step,fl,'#80603c','#eeb08a',ext,0);
           if(Math.hypot(spr.mx-t.x,spr.my-t.y)>1) bad.push(id+' step '+step+' muzzle is '+Math.hypot(spr.mx-t.x,spr.my-t.y).toFixed(2)+' off the vector muzzle');
           d=px(spr.c); mxp=Math.round(spr.ax+spr.mx); myp=Math.round(spr.ay+spr.my); hit=0;
           for(dy=-3;dy<=3;dy++) for(dx=-3;dx<=3;dx++){ x=mxp+dx; y=myp+dy; if(x>=0&&y>=0&&x<spr.c.width&&y<spr.c.height&&d[(y*spr.c.width+x)*4+3]) hit=1; }
           if(!hit) bad.push(id+' step '+step+' has no gun pixels near its muzzle');
         }
       }
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       st={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       // a standing pillager with a gun: at most 8 canvas calls
       if(!body(st,'',0,16)) bad.push('the hero was not drawn in pixels');
       for(i=0;i<4;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',0,st); }
       b0=PIX.bodies;
       cnt=__gfxCount([wc],names,function(){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',0,st); });
       if(PIX.bodies!==b0+1) bad.push('the counted body was not drawn in pixels');
       n=cnt.total-(cnt.calls.getTransform||0);   // draw calls; the transform reads (the rim and ground helpers ask for it) draw nothing
       if(n>8) bad.push('a standing pillager cost '+n+' canvas draw calls, wanted 8 or fewer ('+JSON.stringify(cnt.calls)+')');
       // 8 aim directions, crouch, empty hands and the roll all come out in pixels; armour, a hit, fists, a set and the downed body stay vector
       for(i=0;i<8;i++) if(!body(st,'',i*Math.PI/4,16)) bad.push('aim direction '+i+' was not drawn in pixels');
       if(!body(st,'crouch',0.3)) bad.push('the crouch was not drawn in pixels');
       if(!body(st,'none',2.8)) bad.push('empty hands were not drawn in pixels');
       if(!body(st,'roll',0.5)) bad.push('the roll was not drawn in pixels');
       st.moving=true; if(!body(st,'',0.4)) bad.push('the walk was not drawn in pixels'); st.sprint=true; if(!body(st,'',0.4)) bad.push('the sprint was not drawn in pixels'); st.moving=false; st.sprint=false;
       [['armour',{bulk:1},''],['a hit',{hurt:0.4},''],['fists',{},'fist'],['the downed body',{},'down'],['a set',{hero:0,outfit:'outskeleton'},''],['the peddler',{hero:0,outfit:'outpeddler'},'none']].forEach(function(q){
         var s2={}, z; for(z in st) s2[z]=st[z]; for(z in q[1]) s2[z]=q[1][z]; if(q[1].hero===0) delete s2.own;
         b0=PIX.bodies; for(z=0;z<4;z++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,q[2],0,s2); }
         if(PIX.bodies!==b0) bad.push(q[0]+' was drawn in pixels but is still the vector body');
       });
       // a forced throw still draws a body, and is counted and logged
       keep=pixDrawOp; e0=PIX.errs; g.drawErr=null;
       pixDrawOp=function(){ throw new Error('forced'); };
       try{ cnt=__gfxCount([wc],names,function(){ drawOp(600,500,0,0,'#242832',0,0,'',0,st); }); }
       finally{ pixDrawOp=keep; keep=null; }
       if(PIX.errs<=e0) bad.push('a forced throw was not counted');
       if(!g.drawErr||String(g.drawErr).indexOf('forced')<0) bad.push('a forced throw was not logged as the render fault');
       if(cnt.total<20) bad.push('a forced throw drew no vector body ('+cnt.total+' calls)');
       g.drawErr=null; if(g.tel) g.tel.drawErr=null;
       wc.restore(); saved=false;
       f1=pixFaults();
       // no frame reads pixels back after the warm-up (60 frames, against the same frames with the pixel look off)
       for(i=0;i<190;i++) __frame(0.016);
       b1=PIX.bodies;
       cntOn=__gfxCount([wc,ctx,lx2,fx2],['getImageData','putImageData'],function(){ for(var j=0;j<60;j++) __frame(0.016); });
       if(PIX.bodies-b1<30) bad.push('only '+(PIX.bodies-b1)+' pixel bodies in 60 frames');
       CFG.xfPix=0;
       cntOff=__gfxCount([wc,ctx,lx2,fx2],['getImageData','putImageData'],function(){ for(var j=0;j<60;j++) __frame(0.016); });
       CFG.xfPix=1;
       if(cntOn.total>cntOff.total) bad.push('the pixel look read pixels back in '+cntOn.total+' calls over 60 frames, '+cntOff.total+' without it');
       if(g.drawErr) bad.push('render fault: '+g.drawErr);
       if(pixFaults()>f1) bad.push('the pixel paths logged '+(pixFaults()-f1)+' fault(s) in the raid frames');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel body check: '+String(err&&err.message||err);
     } finally {
       if(keep) pixDrawOp=keep;
       if(saved){ try{ wc.restore(); }catch(_r){} }
       CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
