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

if ($s.Contains("  {v:'35.27',what:")) { throw "check 35.27 is in the fixture already" }

SubRx @'
  {v:'35.26',what:
'@ @'
  {v:'35.27',what:'cw-reloadstack, his order 2026-10-27 (make the active reload stack but it gets harder each time): each active reload in a row adds to the bonus (x1.15, x1.25, x1.35), the sweet spot narrows each time, a miss or a reload left to run out starts the chain over, and the ring, the bar and X on a pad follow the narrower spot',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     if(typeof activeReloadTick!=='function'||typeof AR_A!=='number'||typeof reloadBarDraw!=='function'||typeof fireWeapon!=='function') return 'SKIP: no active reload in this fixture';
     var bad=[], g=null, p=null, all=null, oWep, oAmmo, oRes, oMx, oMy, d0, d1, d2, d3, dA, dB, h, i, a, cap=[], rects=[], proto=CanvasRenderingContext2D.prototype, oArc=proto.arc, oFR=proto.fillRect,
         a0=-1.5708+6.2832*AR_A, a1=-1.5708+6.2832*AR_B, am=-1.5708+6.2832*(AR_A+AR_B)/2, nar=0, wid=0, zw=[], zw0, ct=null, gp, padUsed=false, kNG=navigator.getGamepads,
         hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kPAD=null, xm1, xm2, padHit;
     function press(){ keys['KeyR']=true; __sim(0.016); keys['KeyR']=false; __sim(0.001); }
     function start(){ p.ammo=2; p.reserve=60; p.reloading=0; p.arBonus=0; p.rlTot=0; p.hand=false; press(); return p.reloading>0&&p.rlTot>0; }
     function tapAt(fr){ p.reloading=p.rlTot*(1-fr)+16; press(); return !(p.reloading>0); }   // the press frame takes 16 ms off first; true: the press landed an active reload
     function hitAt(fr){ if(!start()) return null; return tapAt(fr); }
     function runOut(){ var n=0; if(!start()) return false; while(p.reloading>0&&n<600){ __sim(0.016); n++; } return !(p.reloading>0); }
     function shot(){ var b; g.bullets.length=0; fireWeapon(p,p.wep,p.x+100,p.y,true); b=g.bullets[g.bullets.length-1]; g.bullets.length=0; return b?b.dmg:NaN; }
     function near(x,y){ return Math.abs(x-y)<0.006; }
     function x3(d){ return 'x'+(d/d0).toFixed(3); }
     function mkpad(down){ var bt=[], q, dn; for(q=0;q<17;q++){ dn=down.indexOf(q)>=0; bt.push({pressed:dn,value:dn?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function poll(down){ padUsed=true; gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     function padClr(){ PAD.prev=[]; PAD.xWas=false; PAD.xMode=null; PAD.xAfterTrade=0; PAD.xNearN=null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oMx=mouse.x; oMy=mouse.y;
       p.wep=cloneObj(WEAPONS.pistol); keys={}; mouse.down=false;
       // ONE: the claim. Three active reloads in a row, each in the middle of the spot, give more each time
       if(!runOut()) return 'SKIP: staging: a reload left alone did not run out';
       d0=shot();
       h=[hitAt(0.51),null,null]; d1=shot(); h[1]=hitAt(0.51); d2=shot(); h[2]=hitAt(0.51); d3=shot();
       if(!(h[0]&&h[1]&&h[2])) bad.push('ONE control: a press in the middle of the sweet spot did not land ('+h.join(',')+')');
       if(!near(d1/d0,1.15)) bad.push('ONE control: the first active reload gives '+x3(d1)+', not x1.15');
       if(!(d2>d1+0.01)) bad.push('ONE: two active reloads in a row give '+x3(d2)+' on the second, no more than the first ('+x3(d1)+')');
       else if(!near(d2/d0,1.25)||!near(d3/d0,1.35)) bad.push('ONE: the stack reads '+x3(d2)+' then '+x3(d3)+', not x1.25 then x1.35');
       // TWO: the second spot is narrower. A press at 0.431 of the reload lands on a fresh chain (inside 0.42 to 0.60) and misses on the second
       if(!runOut()) bad.push('TWO: a reload left alone did not run out');
       dA=shot(); if(!near(dA/d0,1)) bad.push('TWO: a reload left to run out kept a bonus ('+x3(dA)+')');
       if(!hitAt(0.431)) bad.push('TWO control: a fresh chain did not take a press at 0.431 of the reload, inside the old sweet spot');
       else if(hitAt(0.431)) bad.push('TWO: the second sweet spot is no narrower: a press at 0.431 of the reload landed again');
       else { if(!tapAt(0.51)) bad.push('TWO: after the miss a press in the middle did not land'); dB=shot(); if(!near(dB/d0,1.15)) bad.push('TWO: a miss did not start the chain over: the next active reload gives '+x3(dB)+', not x1.15'); }
       // THREE: a reload left to run out starts the chain over
       h=[hitAt(0.51),null]; dA=shot(); runOut(); h[1]=hitAt(0.51); dB=shot();
       if(!(h[0]&&h[1])) bad.push('THREE control: a press in the middle did not land ('+h.join(',')+')');
       if(!near(dA/d0,1.25)) bad.push('THREE: the active reload after the restart gives '+x3(dA)+', not x1.25');
       if(!near(dB/d0,1.15)) bad.push('THREE: a reload left to run out did not start the chain over: the next one gives '+x3(dB)+', not x1.15');
       // FOUR: with two in the chain the ring and the bar draw the narrower spot
       hitAt(0.51);
       if(!start()) bad.push('FOUR: staging: R did not start a reload');
       else {
         p.reloading=p.rlTot*0.8; mouse.x=W/2; mouse.y=H/2;
         proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
         try{ render2D(0); drawHUD(); } finally { proto.arc=oArc; }
         for(i=0;i<cap.length;i++){ a=cap[i]; if(a.length<5) continue;
           if(Math.abs(a[3]-a0)<0.002&&Math.abs(a[4]-a1)<0.002) wid++;
           else if(a[3]>a0+0.02&&a[4]<a1-0.02&&Math.abs((a[3]+a[4])/2-am)<0.01) nar++; }
         if(!nar||wid) bad.push('FOUR: the reload ring drew '+wid+' full sweet spots and '+nar+' narrower ones ('+cap.length+' arcs)');
         proto.fillRect=function(x,y,w,hh){ rects.push([w,String(this.fillStyle)]); return oFR.apply(this,arguments); };
         try{ reloadBarDraw(W/2,H/2,p); } finally { proto.fillRect=oFR; }
         for(i=0;i<rects.length;i++) if(rects[i][1]==='#e83a2c') zw.push(rects[i][0]);
         zw0=Math.round(LH(88)*(AR_B-AR_A));
         if(zw.length!==1||!(zw[0]<zw0-2)) bad.push('FOUR: the red zone on the reload bar is '+zw.join('/')+' wide, not narrower than '+zw0);
         p.reloading=0; p.rlTot=0;   // cut short: the chain stays at two
       }
       // FIVE: X on a pad, next to a box: outside the narrower spot it still searches, in the middle it lands the third in a row
       if(typeof pollPad==='function'&&typeof PAD!=='undefined'){
         kPAD={on:PAD.on,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand,aimA:PAD.aimA};
         for(i=0;i<g.containers.length;i++){ if(!g.containers[i].opened){ ct=g.containers[i]; break; } }
         if(ct){ ct.x=p.x+12; ct.y=p.y; }
         keys={}; mouse.down=false; p.hand=null; p.jam=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.nearDown=null;
         padClr(); poll([]); updatePlayer(0.016);
         if(ct&&g.nearContainer){
           keys={}; p.ammo=2; p.reserve=60; p.reloading=p.wep.reload; p.rlTot=0; activeReloadTick(p);
           p.reloading=p.rlTot*(1-0.445); padClr(); poll([2]); xm1=PAD.xMode; keys={}; padClr(); poll([]); keys={};
           p.reloading=p.rlTot*(1-0.51); padClr(); poll([2]); xm2=PAD.xMode; activeReloadTick(p); padHit=!(p.reloading>0)&&p.arBonus===1; keys={}; padClr(); poll([]); keys={};
           if(xm2!=='KeyR'||!padHit) bad.push('FIVE control: on a pad next to a box, X in the middle of the spot did not land the active reload ('+xm2+')');
           if(xm1!=='KeyE') bad.push('FIVE: on a pad next to a box, X at 0.445 of the reload, outside the narrower spot, read '+xm1+', not the search');
           dA=shot(); if(padHit&&!near(dA/d0,1.35)) bad.push('FIVE: on a pad the third active reload in a row gives '+x3(dA)+', not x1.35');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       proto.arc=oArc; proto.fillRect=oFR;
       try{ if(padUsed){ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; } }catch(_n){}
       try{ if(kPAD){ padClr(); PAD.on=kPAD.on; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.aimA=kPAD.aimA; if(typeof padRelease==='function') padRelease(); } }catch(_p){}
       try{ keys={}; mouse.down=false; if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.reloading=0; p.arBonus=0; p.rlTot=0; p.arStk=0; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'35.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
