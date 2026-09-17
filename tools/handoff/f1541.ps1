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
  {v:'15.40',what:
'@ @'
  {v:'15.41',what:'with Bare Hands up the reticle never says it is empty or out of ammo: carrying one gun and pressing key 2 brings Bare Hands up with the corner reading MELEE and R starting no reload, and the drawn reticle carries neither the empty warning with the gun rounds in reserve nor the no ammo warning with none, while back on key 1 the gun with an empty magazine still carries both (hud audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof ctx==='undefined'||typeof hotbarSlots!=='function'||typeof setHot!=='function'||typeof hotSel!=='function'||typeof updatePlayer!=='function') return 'SKIP: no HUD draw, tactical belt or player update in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof W!=='number'||typeof H!=='number'||!WEAPONS.fists||WEAPONS.fists.mag!==0) return 'SKIP: no keys, mouse, screen size or Bare Hands without a magazine in this build';
     var bad=[], g=null, p=null, keep=null, keepMouse=null, keepHot=0, texts=[], sl, realFT=null, ownFT=false;
     var OWN=Object.prototype.hasOwnProperty;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Assembled, never written whole, so only the drawn reticle can hold them.
     var EMPTY='EMP'+'TY - R', DRY='NO '+'AMMO';
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // Every string one drawn HUD hands to fillText, before any text edit; null on a throw.
     function drawn(){ texts.length=0; try{ drawHUD(); }catch(_h){ return null; } return texts.slice(); }
     function has(d,t){ for(var i=0;i<d.length;i++) if(d[i]===t) return true; return false; }
     function held(){ return p.wep?(p.wep.id+' (magazine '+p.wep.mag+') with '+p.ammo+' loaded and '+p.reserve+' in reserve'):'nothing'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim) return 'SKIP: no live raid';
       p=g.player;
       keep={wep:p.wep,ammo:p.ammo,sec:p.sec,secAmmo:p.secAmmo,wepIssued:p.wepIssued,secIssued:p.secIssued,wepFromArmory:p.wepFromArmory,secFromArmory:p.secFromArmory,
             swapped:p.swapped,reserve:p.reserve,reloading:p.reloading,jam:p.jam,roll:p.roll,x:p.x,y:p.y,vx:p.vx,vy:p.vy,fired:p.fired,lastShot:p.lastShot,swapT:p.swapT};
       keepMouse={x:mouse.x,y:mouse.y,down:mouse.down}; keepHot=G.hot;
       clearKeys(); mouse.down=false; mouse.x=Math.round(W/2); mouse.y=Math.round(H/2);
       p.downed=false; p.dying=false; p.roll=0; p.jam=0; p.reloading=0; g.paused=false; g.bagOpen=false; g.mapOpen=false; g.drag=null;
       // One gun in his hands and Bare Hands in the second slot, the way a raid starts with one gun carried.
       if(!(p.wep&&p.wep.mag>0&&p.sec&&p.sec.id==='fists')){
         if(!(WEAPONS.pistol&&WEAPONS.pistol.mag>0)) return 'SKIP: the raid did not start with one gun and Bare Hands, and there is no pistol to hand him here';
         var w={}, wk; for(wk in WEAPONS.pistol) w[wk]=WEAPONS.pistol[wk];
         p.wep=w; p.wepIssued=false; p.wepFromArmory=false;
         p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
       }
       p.swapped=false; G.hot=0; p.ammo=p.wep.mag; p.reserve=37;
       sl=hotbarSlots();
       // CONTROL: key 1 is the gun in his hands and key 2 is Bare Hands, a real gun cell and not the vacant one.
       if(!(sl[0]&&sl[0].kind==='gun'&&sl[0].inHand&&sl[0].icon===p.wep.id)) return 'SKIP: key 1 is not the gun in his hands here';
       if(!(sl[1]&&sl[1].kind==='gun'&&!sl[1].vacant&&sl[1].icon==='fists')) return 'SKIP: key 2 is not Bare Hands here';
       ownFT=OWN.call(ctx,'fillText'); realFT=ctx.fillText;
       ctx.fillText=function(t){ texts.push(String(t)); return realFT.apply(this,arguments); };
       // CONTROL, THE GUN EMPTY: with nothing loaded the drawn reticle says so with rounds in reserve, and says the other with none.
       p.ammo=0;
       var d0=drawn();
       if(d0===null) return 'SKIP: drawing the HUD threw here';
       if(!has(d0,EMPTY)) return 'SKIP: holding '+held()+' the drawn HUD did not carry '+EMPTY+' with the mouse mid-screen, so the reticle cannot be read here';
       p.reserve=0;
       var d1=drawn();
       if(d1===null||!has(d1,DRY)) return 'SKIP: holding '+held()+' the drawn HUD did not carry '+DRY+', so the reticle cannot be read here';
       // Key 2, the way the number key takes it: Bare Hands come up over the gun.
       p.ammo=p.wep.mag; p.reserve=37;
       setHot(1);
       // CONTROL: Bare Hands in his hands with nothing loaded, the gun rounds still in reserve and key 2 lit.
       if(!(p.wep&&p.wep.id==='fists'&&p.wep.mag===0&&p.ammo<=0&&p.reserve===37&&p.reloading<=0&&p.jam<=0&&hotSel()===1)) return 'SKIP: key 2 did not bring Bare Hands up over the gun here (holding '+held()+', key '+(hotSel()+1)+' lit)';
       // CONTROL: R starts no reload with Bare Hands up, so a reticle telling him to press it is wrong.
       keys['KeyR']=true;
       updatePlayer(1/60);
       clearKeys();
       if(p.reloading>0) return 'SKIP: R started a reload with Bare Hands up here';
       if(!(p.wep&&p.wep.id==='fists'&&p.reserve===37)) return 'SKIP: Bare Hands did not stay up through a frame here (holding '+held()+')';
       var d2=drawn();
       if(d2===null) return 'SKIP: drawing the HUD with Bare Hands up threw here';
       // THE FIX: no empty warning with Bare Hands up and the gun rounds in reserve.
       if(has(d2,EMPTY)) bad.push('with Bare Hands up on key 2, holding '+held()+', the drawn reticle said '+EMPTY+' though R started no reload');
       // CONTROL: the corner names Bare Hands as melee, so the frame read is the Bare Hands frame.
       if(!has(d2,'MELEE')) return skip('with Bare Hands up the drawn HUD corner did not read MELEE here');
       // THE FIX: and no out of ammo warning once the reserve is gone.
       p.reserve=0;
       var d3=drawn();
       if(d3===null) return skip('drawing the HUD with Bare Hands up and no reserve threw here');
       if(has(d3,DRY)) bad.push('with Bare Hands up on key 2, holding '+held()+', the drawn reticle said '+DRY+' though the corner read MELEE and the punch needs no rounds');
       // CONTROL: back on key 1 the gun with an empty magazine still carries both warnings, so the gun was not silenced.
       setHot(0);
       if(!(p.wep&&p.wep.id!=='fists'&&p.wep.mag>0)) return skip('key 1 did not bring the gun back up here (holding '+held()+')');
       p.ammo=0; p.reserve=37; p.reloading=0; p.jam=0;
       var d4=drawn();
       if(d4===null) return skip('drawing the HUD back on the gun threw here');
       if(!has(d4,EMPTY)) bad.push('back on key 1 holding '+held()+' the drawn reticle no longer said '+EMPTY);
       p.reserve=0;
       var d5=drawn();
       if(d5===null) return skip('drawing the HUD back on the gun with no reserve threw here');
       if(!has(d5,DRY)) bad.push('back on key 1 holding '+held()+' the drawn reticle no longer said '+DRY);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFT){ if(ownFT) ctx.fillText=realFT; else delete ctx.fillText; } }catch(_t){}
       try{ clearKeys(); if(keepMouse){ mouse.x=keepMouse.x; mouse.y=keepMouse.y; mouse.down=keepMouse.down; } }catch(_k){}
       try{ if(p&&keep){ for(var kp in keep) p[kp]=keep[kp]; G.hot=keepHot; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
