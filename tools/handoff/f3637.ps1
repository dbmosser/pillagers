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

if ($s.Contains("  {v:'36.37',what:")) { throw "check 36.37 is in the fixture already" }

SubRx @'
  {v:'36.36',what:
'@ @'
  {v:'36.37',what:'cw-cx-hotbar9: ten drawn keys 1-9 and 0, digit 9 draws a gun and uses a wheel item dragged to 9, pad reaches 9, and old key 0 saves migrate once in place',
   run:function(){
     var g,p,sl,c,i,w,bi,an,rec=[],oFT=CanvasRenderingContext2D.prototype.fillText,oldP,saveKey=SKEY,stage='prepare';
     function count(k){ return g.bag.filter(function(x){ return x===k; }).length; }
     function press(k){ raidKey(k,false,null); keys[k]=false; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       oldP=JSON.parse(JSON.stringify(P));
       if(HOTBAR_N!==10||GUNKEYS!==10) return 'the hotbar does not have ten assignable cells';
       stage='direct old plan migration';
       var legacy={credits:900,beltV:5,hotAssign:{0:'gun_pistol',8:'gun_rocket'},hotBeforeFree:{8:'medkit'},kitSaved:{hot:[null,null,null,null,null,null,null,null,'plate']},gunKeys:['energy','smg','rifle','carbine','lmg','shotgun','sniper','pistol','rocket']};
       hotbarProfileTen(legacy);
       if(legacy.hotAssign[9]!=='gun_rocket'||legacy.hotAssign[8]!==undefined||legacy.hotAssign[0]!=='gun_pistol'||legacy.hotBeforeFree[9]!=='medkit'||legacy.kitSaved.hot[9]!=='plate'||legacy.kitSaved.hot.length!==10) return 'old nine-cell assignments did not keep key 0';
       legacy.hotAssign[8]='bandage'; hotbarProfileTen(legacy);
       if(legacy.hotAssign[8]!=='bandage'||legacy.hotAssign[9]!=='gun_rocket') return 'the migration ran twice';
       if(legacy.gunKeys[8]!==null||legacy.gunKeys[9]!=='rocket'||legacy.gunKeys[0]!=='energy') return 'the saved class order moved';
       var loaded=JSON.parse(JSON.stringify(oldP)); delete loaded.hotbarV; loaded.beltV=5; loaded.hotAssign={8:'gun_rocket'}; loaded.hotBeforeFree={8:'medkit'}; loaded.kitSaved={kit:[],hot:{8:'bandage'}};
       stage='real profile load';
       __applyLoaded(loaded);
       if(!P.hotAssign||P.hotAssign[9]!=='gun_rocket'||P.hotAssign[8]!==undefined) return 'the real profile loader did not keep the old key 0 assignment on 0';
       if(!P.kitSaved||!P.kitSaved.hot||P.kitSaved.hot[9]!=='bandage'||P.kitSaved.hot[8]!==undefined) return 'the real profile loader did not keep the set-aside plan on key 0';
       if(P.hotBeforeFree!==null) return 'the real profile loader retained an ended raid plan';
       P.gunKeys=undefined;
       if(gunClassKey('rocket')!==9) return 'the default rocket class left key 0';
       P.weapons=['carbine','shotgun']; P.equipped='carbine'; P.equippedSec='shotgun'; P.hotAssign={};
       stage='raid belt drawing';
       __deploy({kit:['bandage','medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.trade=null; g.drag=null; g.wheel=null; keys={}; mouse.down=false;
       if(pauseOpen) togglePauseBox(false); syncPause();
       sl=hotbarSlots(); if(sl.length!==10||!sl[8].vacant) return 'the new key 9 did not start empty';
       CanvasRenderingContext2D.prototype.fillText=function(t,x,y){ rec.push({s:String(t),x:x,y:y}); return oFT.apply(this,arguments); };
       try{ __frame(0.016); }finally{ CanvasRenderingContext2D.prototype.fillText=oFT; }
       if(!g.hotCells||g.hotCells.length!==10) return 'the raid belt did not draw ten cells';
       for(i=0;i<10;i++){
         c=g.hotCells[i];
         if(slotKeyName(i)!==String((i+1)%10)||slotKeyCode(i)!=='Digit'+((i+1)%10)||!rec.some(function(r){return r.s===slotKeyName(i)&&r.x>=c.x&&r.x<c.x+c.w&&r.y>=c.y&&r.y<c.y+c.h;})) return 'missing drawn digit '+((i+1)%10)+' in its own cell';
       }
       stage='raid gun digit keys';
       g.hotAssign={0:'gun_carbine',8:'gun_shotgun'}; g.hotAuto={}; press('Digit1'); press('Digit9'); if(!p.wep||p.wep.id!=='shotgun'||heldGunCell(hotbarSlots())!==8) return '9 did not select its gun';
       g.hotAssign[9]='gun_shotgun'; delete g.hotAssign[8]; press('Digit1'); press('Digit0'); if(p.wep.id!=='shotgun'||heldGunCell(hotbarSlots())!==9) return '0 did not keep the last cell';
       __frame(0.016); c=g.hotCells[8];
       stage='wheel item drag to 9';
       mouse.x=W/2; mouse.y=H/2; keys.KeyQ=true; press('KeyQ'); keys.KeyQ=true; w=g.wheel;
       if(!w) return 'no wheel to drag from';
       bi=-1; for(i=0;i<w.list.length;i++) if(w.list[i].k==='bandage') bi=i;
       if(bi<0) return 'no carried bandage on wheel';
       an=-Math.PI/2+bi*Math.PI*2/w.list.length; mouse.x=w.mx+Math.cos(an)*220; mouse.y=w.my+Math.sin(an)*220; updatePlayer(0.016);
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
       if(!g.drag||g.drag.key!=='bandage') return 'wheel bandage did not start dragging';
       mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
       keys.KeyQ=false; updatePlayer(0.016);
       if(g.hotAssign[8]!=='bandage'||count('bandage')!==1) return 'drag onto 9 failed or spent the bandage';
       stage='item selection and use on 9';
       press('Digit9'); if(!p.hand||p.hand.k!=='bandage'||p.hand.slot!==8) return '9 did not take out its dragged item';
       p.hp=30; p.hand.t=0; mouse.down=false; handTick(p,0.016); mouse.down=true; handTick(p,0.016); mouse.down=false;
       if(count('bandage')!==0&&!p.prep) return 'the trigger did not use the bandage selected by 9';
       p.hand=null; p.prep=null; p.healQ=0; g.bag.push('bandage'); g.hot=9;
       stage='pad walk to 9';
       beltStep(-1); if(!p.hand||p.hand.slot!==8) return 'pad belt walk skipped the item on 9';
       p.hand=null; p.prep=null; g.hotAssign={8:'gun_carbine'}; g.hotAuto={}; press('Digit9'); if(p.wep.id!=='carbine') return '9 did not draw the pinned gun';
       __endRaid('abandon'); __topClear(); __cleanProfile();
       stage='Undercroft floor belt';
       __hubEnter(); __cfg({hubBelt:1}); for(i=0;i<4;i++) __loop(performance.now()+i*17);
       var hb=__hubBelt(); if(!hb||!hb.cells||hb.cells.length!==10) return 'Undercroft floor did not draw ten cells';
       stage='stash digit 9 and plan cells';
       var hub=document.getElementById('hub'); renderHub(); hub.classList.add('on'); P.stash=['medkit']; P.kit=[]; P.hotAssign={}; INVHOVER='medkit';
       document.dispatchEvent(new KeyboardEvent('keydown',{key:'9',code:'Digit9',bubbles:true,cancelable:true})); INVHOVER=null;
       if(P.hotAssign[8]!=='medkit') return 'stash digit 9 did not bind the new cell';
       renderHub(); if(document.querySelectorAll('#hotplanwrap [data-plan]').length!==10) return 'stash did not draw ten plan cells';
       if(keysBind('KeyR','Digit9')!==false) return '9 can still be rebound away from the hotbar';
       if(SKEY!==saveKey) return 'the save key changed';
       return null;
     }catch(e){
       return stage+': '+String(e&&e.stack||e);
     }finally{
       CanvasRenderingContext2D.prototype.fillText=oFT; INVHOVER=null; keys={}; mouse.down=false;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
       if(oldP) P=oldP; if(typeof KEYS==='object') KEYS.inv=null;
     }
   }},
  {v:'36.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
