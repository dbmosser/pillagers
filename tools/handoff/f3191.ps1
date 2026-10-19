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

if ($s.Contains("  {v:'31.91',what:")) { throw "check 31.91 is in the fixture already" }

SubRx @'
  {v:'31.90',what:
'@ @'
  {v:'31.91',what:'cw-iceslide, his order (2026-10-19): the frost fog of a cryo barrel is ice (a pillager keeps his momentum, steers slowly, glides on with no input, and a wall still stops him), off the ice a turn is at once, and neither the fog nor the cryo blast hurts him',
   run:function(){
     if(typeof BRL_POOL!=='object'||typeof brlBlast!=='function'||typeof updatePlayer!=='function') return 'SKIP: no cryo barrel in this build';
     var bad=[], g=null, p=null, spot=null, wspot=null, i, j, x, y, v, vN, vI, n0, x1, hp0, B, cr, last=0, oSfx=sfx, oRnd=Math.random, rnd=0, oW=wc, oIce=null, nIce=0, ops={o:0,ell:0,fill:0,img:0}, fake={};
     function need(ok,msg){ if(!ok&&bad.length<10) bad.push(msg); }
     function reset(){
       keys={}; mouse.down=false; p.x=spot.x; p.y=spot.y; p.hp=100; p.armor=0; p.iv=0; p.roll=0; p.rollCd=0; p.downed=false; p.dying=false; p.specOut=false;
       p.autoJog=false; p.stimT=0; p.ads=false; p.kickT=0; p.vx=0; p.vy=0; p.stam=100; p.stamLock=0; p.stamRelease=0; g.crouchTog=false; g.bfire=[]; g.brl.length=0; g.ents.length=0;
       if(typeof iceStop==='function') iceStop(p);
     }
     function ice(r){ g.bfire=[{x:spot.x,y:spot.y,r:r||300,t:1,life:60,by:-1,bt:0,k:'cryo'}]; }
     function hold(k,steps){ var s, x0; keys={}; if(k) keys[k]=true; for(s=0;s<steps;s++){ x0=p.x; updatePlayer(0.02); last=(p.x-x0)/0.02; } return last; }
     function dry(xa,xb,y){ var k; for(k=xa;k<=xb;k+=45) if(inWater(k,y)||inWaterDeep(k,y,11)) return false; return true; }
     function laneOk(x,y,half){ return x-half-30>40&&x+half+30<WORLD_W-40&&y>60&&y<WORLD_H-60&&walkClearR(x-half,y,x+half,y,16)&&losClear(x,y,x+half,y,g.map.segs)&&losClear(x,y,x-half,y,g.map.segs)&&dry(x-half,x+half,y); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       __topClear(); g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.trade=null; g.forgeUI=null; g.wheel=null; g.ents.length=0; g.brl.length=0;
       // THE SHEET: drawn with a fake canvas (no random draw, nothing once the fog is spent), and in a real frame under the bodies
       if(typeof brlIceDraw!=='function') bad.push('there is no ice sheet to draw under the frost fog');
       else {
         ['save','restore','beginPath','moveTo','lineTo','stroke','fillRect'].forEach(function(nm){ fake[nm]=function(){ ops.o++; }; });
         fake.ellipse=function(){ ops.ell++; }; fake.fill=function(){ ops.fill++; }; fake.drawImage=function(){ ops.img++; };
         try{
           wc=fake; Math.random=function(){ rnd++; return oRnd(); };
           brlIceDraw({x:500,y:500,r:96,t:1,life:5,by:-1,bt:0,k:'cryo'});
           need(ops.ell>=5&&ops.fill>=3&&ops.img>=1&&ops.o>=20,'the ice sheet is a thin drawing ('+JSON.stringify(ops)+')');
           ops.o=ops.ell=ops.fill=ops.img=0; brlIceDraw({x:500,y:500,r:96,t:5,life:5,by:-1,bt:0,k:'cryo'});
           need(ops.o+ops.ell+ops.fill+ops.img===0,'the ice sheet is still drawn when the fog is spent');
           ops.o=ops.ell=ops.fill=ops.img=0; brlIceDraw({x:500,y:500,r:96,t:4.5,life:5,by:-1,bt:0,k:'cryo'});
           need(ops.ell>=5,'the ice sheet is gone before the last second of the fog');
         }catch(de){ bad.push('drawing the ice sheet threw: '+(de&&de.message||de)); }
         wc=oW; Math.random=oRnd;
         need(rnd===0,'the ice sheet drew '+rnd+' random numbers');
         if(typeof __frame==='function'&&(typeof __vpAlive!=='function'||__vpAlive())){
           g.bfire=[{x:p.x+30,y:p.y+20,r:96,t:1,life:60,by:-1,bt:0,k:'cryo'}]; oIce=brlIceDraw; brlIceDraw=function(Q){ nIce++; return oIce.apply(this,arguments); };
           try{ __frame(0.016); __frame(0.016); }catch(fe){ bad.push('a frame with the ice under the frost fog threw: '+(fe&&fe.message||fe)); }
           brlIceDraw=oIce; g.bfire=[];
           need(nIce>=1,'a real frame drew no ice sheet under the fog ('+nIce+')');
         }
       }
       for(j=-14;j<=14&&!spot;j++) for(i=-14;i<=14;i++){ x=p.x+i*64; y=p.y+j*64; if(laneOk(x,y,270)){ spot={x:x,y:y}; break; } }
       if(!spot) return 'SKIP: staging: no clear lane near the start';
       // CONTROL: on bare ground the same input turns him at once
       reset(); vN=hold('KeyD',40); need(vN>60,'staging: he does not walk right on bare ground ('+vN+')');
       v=hold('KeyA',2); need(v<-0.9*vN,'control: on bare ground a turn is not at once ('+v.toFixed(0)+' against '+vN.toFixed(0)+')');
       // ON ICE: faster than a run, and the first 0.24 s of a turn leaves him still going the old way; the turn about takes between 0.3 and 1.2 s
       reset(); ice(300); vI=hold('KeyD',40);
       need(vI>1.1*vN&&vI<1.4*vN,'on the ice his top speed is '+vI.toFixed(0)+', a run is '+vN.toFixed(0)+' (1.1 to 1.4 times wanted)');
       keys={KeyA:true}; n0=-1;
       for(i=0;i<80;i++){
         x=p.x; updatePlayer(0.02); v=(p.x-x)/0.02;
         if(i===11) need(v>0,'on the ice 0.24 s of holding left had already turned him round ('+v.toFixed(0)+')');
         if(n0<0&&v<-0.05*vN) n0=i+1;
       }
       need(n0>=15&&n0<=60,'on the ice a turn about took '+(n0<0?'longer than 1.6':(n0*0.02).toFixed(2))+' s, not 0.3 to 1.2 s');
       need(v<-vN,'on the ice he never got up to speed the other way ('+v.toFixed(0)+')');
       // NO INPUT: he glides on (half a second later he is still at most of his speed and has covered ground)
       reset(); ice(300); vI=hold('KeyD',40); x1=p.x; v=hold(null,25);
       need(v>0.6*vI&&p.x-x1>40,'on the ice, with no input, he did not glide on ('+v.toFixed(0)+' of '+vI.toFixed(0)+', '+(p.x-x1).toFixed(0)+' units)');
       // OFF THE ICE: the momentum is gone within 0.32 s
       reset(); ice(300); hold('KeyD',40); g.bfire=[]; v=hold('KeyA',16);
       need(v<-0.9*vN,'the momentum stayed after the ice ended: 0.32 s later he moves at '+v.toFixed(0)+' (a run is '+(-vN).toFixed(0)+')');
       // A WALL still stops him: a spot with a wall 160 to 420 units to the right
       for(j=-14;j<=14&&!wspot;j++) for(i=-14;i<=14;i++){ x=spot.x+i*64; y=spot.y+j*64; if(x>100&&x<WORLD_W-100&&y>100&&y<WORLD_H-100&&walkClearR(x-100,y,x+160,y,16)&&!walkClearR(x,y,x+420,y,16)&&losClear(x,y,x+160,y,g.map.segs)&&dry(x-100,x+160,y)){ wspot={x:x,y:y}; break; } }
       if(wspot){
         reset(); p.x=wspot.x; p.y=wspot.y; g.bfire=[{x:wspot.x,y:wspot.y,r:600,t:1,life:60,by:-1,bt:0,k:'cryo'}]; hold('KeyD',120);
         need(p.x>wspot.x+60,'staging: he did not slide toward the wall ('+(p.x-wspot.x).toFixed(0)+')');
         need(walkClear(wspot.x,wspot.y,p.x,p.y),'a slide went through a wall (he ended '+(p.x-wspot.x).toFixed(0)+' units on)');
       }
       // NO HARM: two seconds in the fog, and the blast itself, cost him nothing; the machine beside the barrel is still frozen
       reset(); hp0=p.hp; g.bfire=[{x:p.x,y:p.y,r:96,t:1,life:5,by:-1,bt:0,k:'cryo'}];
       for(i=0;i<20;i++) brlTick(0.1);
       need(p.hp===hp0,'standing in the frost fog for 2 s cost him '+(hp0-p.hp)+' health');
       reset(); hp0=p.hp; sfx=function(){};
       cr=mkCrawler(p.x+90,p.y); cr.hp=cr.maxhp=900; cr.state='patrol'; cr.alert=0; g.ents.push(cr);
       B={id:901,x:p.x+40,y:p.y,hp:BRL_HP,fuse:-1,by:-1,gone:0,k:'cryo'}; g.brl.push(B); brlBlast(B);
       need(B.gone&&p.hp===hp0,'the cryo blast 40 units away cost him '+(hp0-p.hp)+' health');
       need(g.bfire.length===1&&g.bfire[0].k==='cryo','the cryo blast left '+g.bfire.length+' fogs');
       need(cr.frozenT>0,'the cryo blast no longer freezes a machine beside it');
       return bad.length?bad.slice(0,8).join('; '):null;
     }catch(e){ return 'threw: '+(e&&e.stack||e); }
     finally{
       sfx=oSfx; wc=oW; Math.random=oRnd; try{ if(oIce) brlIceDraw=oIce; }catch(_i){}
       keys={}; try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'31.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
