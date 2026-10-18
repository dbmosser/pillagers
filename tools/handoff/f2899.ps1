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

if ($s.Contains("  {v:'28.99',what:")) { throw "check 28.99 is in the fixture already" }

SubRx @'
  {v:'28.98',what:
'@ @'
  {v:'28.99',what:'cw-windup: the Support MG spin-up whirr and the Meridian Lance charge whine and ready ping are sent to the teammate (player 2 sending here) and played by his window where you stand, without touching his own spin or reload sound; letting go cuts his copy (one at a time, so a tap-tap never stacks); the active reload ping stays your own',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netFxNoise!=='function'||typeof spinTick!=='function'||typeof rlfxPlay!=='function'||typeof reloadFoley!=='function'||typeof activeReloadTick!=='function'||!WEAPONS.lmg||!WEAPONS.lance) return 'SKIP: no arcade, guns or pair channel in this fixture';
     var oSpk=spkPlay, bad=[], g=null, p=null, NK={}, k, staged=false, oS=netSend, oSF=netSendFast, oB=netBroadcast, rs=say, oP=rlfxPing, oAc=ac, oBus=sndBus, lf0=LMGSPIN.far, rf0=RLFX.far, gains=[], fake, g1, g2, PK={}, pf=['wep','ammo','reserve','reloading','drawT','jam','spin','cooking','hand','rlTot','rlArm','arBonus','arGun','x','y'], q, i, n, hum0, hum1, rq;
     function prm(){ return {value:0,setValueAtTime:function(v){ this.value=v; },linearRampToValueAtTime:function(){},exponentialRampToValueAtTime:function(){},cancelScheduledValues:function(){ this.cut=(this.cut||0)+1; }}; }
     fake={currentTime:0,
       createOscillator:function(){ return {type:'',frequency:prm(),connect:function(){},start:function(){},stop:function(){}}; },
       createBiquadFilter:function(){ return {type:'',frequency:prm(),Q:prm(),connect:function(){}}; },
       createGain:function(){ var n={gain:prm(),connect:function(){}}; gains.push(n.gain); return n; }};
     function tags(){ return (NET.fxQ||[]).map(function(r){ return r[0]; }).join(','); }
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; mouse.down=false;
       for(i=0;i<pf.length;i++) PK[pf[i]]=p[pf[i]];
       for(k in NET) NK[k]=NET[k];
       staged=true;
       ac=function(){ return fake; }; spkPlay=function(){ var gn=prm(); gains.push(gn); return {g:{gain:gn},o:{stop:function(){}}}; }; sndBus=function(){ return {connect:function(){}}; };   // a stand-in audio device, so the sounds are made and can be cut
       LMGSPIN.hum=null; LMGSPIN.far=null; RLFX.far=null;
       say=function(){}; netSendFast=function(){ return true; }; netSend=function(){ return true; }; netBroadcast=function(){ return 1; };
       NET.on=true; NET.max=4; NET.specG=null; NET.specTick=null; NET.fxIn=false; NET.up=[]; NET.upSeed=g.seed>>>0;
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}];
       if(!netUpShared()) return 'SKIP: the staged pair is not a shared raid';
       // the Support MG winds up
       NET.fxQ=[]; p.wep=cloneObj(WEAPONS.lmg); p.ammo=60; p.reloading=0; p.drawT=0; p.jam=0; p.spin=0; p.cooking=0; p.hand=null;
       mouse.down=true; spinTick(p,1/60); spinTick(p,1/60); mouse.down=false; spinTick(p,1/60);
       q=tags(); if(!(/(^|,)f:~whirr(,|$)/).test(q)) bad.push('a Support MG spin-up sent no whirr to the teammate (queue: '+(q||'empty')+')');
       if(!(/(^|,)f:~whirrx(,|$)/).test(q)) bad.push('letting go after a short tap sent no cut of the whirr (queue: '+(q||'empty')+')');
       // the Meridian Lance reloads
       NET.fxQ=[]; rlfxStop(); p.wep=cloneObj(WEAPONS.lance); p.ammo=0; p.reserve=9; p.reloading=p.wep.reload; reloadFoley(p);
       for(i=0;i<400&&p.reloading>0;i++) tickReload(1/60);
       q=tags();
       if(!(/(^|,)f:~whine(,|$)/).test(q)) bad.push('a Lance reload sent no charge whine (queue: '+(q||'empty')+')');
       if(!(/(^|,)f:~ping(,|$)/).test(q)) bad.push('a Lance reload sent no ready ping (queue: '+(q||'empty')+')');
       for(i=0;i<(NET.fxQ||[]).length;i++) if(NET.fxQ[i][0]==='f:~whine'&&!(+NET.fxQ[i][3]>0)) bad.push('the whine went without its length: '+JSON.stringify(NET.fxQ[i]));
       rlfxStop();
       // the active reload ping is his own cue: nothing goes to the teammate
       n=0; rlfxPing=function(){ n++; return oP.apply(this,arguments); };
       p.wep=cloneObj(WEAPONS.pistol||WEAPONS.lmg); p.ammo=0; p.reserve=30; p.reloading=1000; p.rlTot=0; p.arBonus=0;
       keys={}; activeReloadTick(p); p.reloading=500; NET.fxQ=[]; keys['KeyR']=true;
       rq=activeReloadTick(p); keys={};
       rlfxPing=oP;
       if(!rq) return 'SKIP: the staged active reload did not land (ok '+rq+', pings '+n+')';
       q=tags(); if((/f:~/).test(q)) bad.push('the active reload ping went to the teammate (queue: '+q+')');
       // his window plays one where you stand, and his own spin and reload sound are untouched
       if(typeof synthAt!=='function') bad.push('no synthAt: the teammate window has nothing to play a whirr, whine or ping with');
       else {
         hum0=LMGSPIN.hum; hum1=RLFX.hum;
         try{
           gains.length=0; synthAt('whirr',p.x+50,p.y,''); g1=gains[0]; gains.length=0; synthAt('whirr',p.x+50,p.y,''); g2=gains[0];
           if(!g1||!g2||!LMGSPIN.far) bad.push('a teammate whirr made no sound to hold');
           else { if(!g1.cut) bad.push('a second teammate whirr left the first one playing (they stack)'); if(g2.cut||LMGSPIN.far.g.gain!==g2) bad.push('the live teammate whirr is not the newest one'); }
           synthAt('whirrx',p.x+50,p.y,'');
           if(LMGSPIN.far) bad.push('a whirr cut left the teammate whirr held');
           if(g2&&!g2.cut) bad.push('a whirr cut did not fade the teammate whirr');
           if(LMGSPIN.hum!==hum0) bad.push('a teammate whirr changed his own spin sound');
           synthAt('whine',p.x+50,p.y,'0.80'); synthAt('ping',p.x+50,p.y,''); synthAt('whine',p.x,p.y,'x');
           if(!RLFX.far) bad.push('a teammate whine made no sound to hold');
           synthAt('whinex',p.x+50,p.y,''); if(RLFX.far) bad.push('a whine cut left the teammate whine held');
           ac=function(){ return null; }; synthAt('whirr',p.x+50,p.y,''); synthAt('whine',p.x+50,p.y,'1'); synthAt('ping',p.x+50,p.y,'');   // no audio device: nothing throws
         }catch(e1){ bad.push('synthAt threw: '+e1); }
         if(LMGSPIN.hum!==hum0) bad.push('a teammate sound changed his own spin sound');
         if(RLFX.hum!==hum1) bad.push('a teammate whine changed his own reload sound');
       }
     }catch(e){ bad.push('threw: '+(e&&e.stack||e)); }
     finally{
       try{ rlfxStop(); lmgWhirrStop(); }catch(_s0){}
       rlfxPing=oP; ac=oAc; spkPlay=oSpk; sndBus=oBus; LMGSPIN.far=lf0; RLFX.far=rf0; netSend=oS; netSendFast=oSF; netBroadcast=oB; say=rs; mouse.down=false; keys={};
       try{ rlfxStop(); lmgWhirrStop(); }catch(_s){}
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p) for(i=0;i<pf.length;i++) p[pf[i]]=PK[pf[i]];
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'28.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
