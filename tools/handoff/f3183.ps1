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

if ($s.Contains("  {v:'31.83',what:")) { throw "check 31.83 is in the fixture already" }

SubRx @'
  {v:'31.82',what:
'@ @'
  {v:'31.83',what:'stash pays in career and demo: one E buys MK II without a panel, MK III chooses an element, score stays whole, old cash fields cannot cap stalls or appear in packing',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim&&window.__applyLoaded)) return 'missing raid or save loader';
     var g,p,f,host,bad=[],said=[],sounds=[],blips=[],pings=[],saves=[],realSay=say,realSnd=sndUi,realBlip=blip,realPing=ping,realSave=saveProfile;
     var keep=JSON.stringify(P),oldMine=ARCADE.mine,oldArc=false,netSame=NET.same,realPads=navigator.getGamepads,ownPads=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),held=false;
     function tick(n){ for(var j=0;j<n;j++) __sim(0.05); }
     function atGun(mk,credits,score){
       keys={}; mouse.down=false; g.forgeUI=null; g.forgeLock=0; g.trade=null; g.nearPed=null;
       p.x=f.x; p.y=f.y; p.vx=0; p.vy=0; p.downed=false; p.reloading=0;
       p.wep=forgeApply(Object.assign({},WEAPONS.rifle),mk); p.ammo=10; p.wepIssued=true;
       P.credits=credits; g.cs=g.cs||{}; g.cs.s=score; g.cs.b={kill:score};
       ARCADE.mine=score; said=[]; sounds=[]; blips=[]; pings=[]; saves=[];
     }
     function ePress(){ keys.KeyE=true; tick(6); keys.KeyE=false; tick(2); }
     function pads(){
       var b=[],i; for(i=0;i<17;i++) b.push({pressed:i===2&&held,value:i===2&&held?1:0});
       return [{connected:true,id:'Xbox Controller',index:0,buttons:b,axes:[0,0,0,0],mapping:'standard'}];
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.credits=10000; P.takeCash=1; P.takeCashRaid=1;
       __applyLoaded(JSON.parse(JSON.stringify(P)));
       if(P.credits!==10000) bad.push('loading an old cash save changed its bank');
       if('takeCash' in P||'takeCashRaid' in P) bad.push('loading kept retired cash fields');
       P.stash=['bandage','bandage','smoke','core']; P.kit=[]; P.freeKit=0; P.kitPick='mine'; P.intel=0;
       renderSector(); host=document.getElementById('sectorpack');
       if(!host||host.style.display==='none') return 'no MY LOADOUT pack row';
       if(host.querySelector('[data-cash],[data-cashchip]')) bad.push('the cash stepper remains');
       if(!host.querySelector('[data-core]')||!host.querySelector('[data-pk="bandage"]')) bad.push('packing lost its items or data core');
       host.querySelector('[data-pa="all"]').click();
       if(packedCount('bandage')!==2||P.credits!==10000) bad.push('pack all changed the bank or lost items');
       host.querySelector('[data-pa="none"]').click();
       if(packedCount('bandage')!==0||P.credits!==10000) bad.push('clear changed the bank or kept items');
       __topClear();
       P.takeCash=1; P.takeCashRaid=1; P.stash=[]; P.kit=[]; P.dropKit=[]; P.kitChosen=0; P.mapIx=0; pendSeed=4242;
       document.getElementById('sectordeploy').click();
       g=__state(); if(!g||g.over||g.sim) return 'no live raid';
       oldArc=g.arcade; g.arcade=false; g.ents=[]; g.containers=[];
       g.bagOpen=false; g.mapOpen=false; g.mapFirst=false; g.paused=false; g.wheel=null;
       p=g.player; f=g.forge; if(!f) return 'no forge';
       p.hp=100000; p.maxhp=100000; p.iv=99;
       say=function(m){ said.push(String(m).toLowerCase()); };
       sndUi=function(k){ sounds.push(k); };
       blip=function(k){ blips.push(k); };
       ping=function(x,y,r){ pings.push(r); };
       saveProfile=function(){ saves.push(P.credits); return realSave.apply(this,arguments); };
       atGun(0,10000,0); ePress();
       if(p.wep.fk!==1||P.credits!==7500||g.cs.s!==0||g.forgeUI) bad.push('career E did not buy MK II from 10000 stash at zero score');
       if(g.cs.b.forge||g.cs.b.kill!==0) bad.push('forge changed the score ledger');
       if(saves.indexOf(7500)<0) bad.push('forge did not save the purchase');
       if(!g.gunCard||!g.gunCard.w||g.gunCard.w.fk!==1||g.gunCard.route.indexOf('$2,500')<0) bad.push('no priced MK II gun card');
       if(said.indexOf('gun upgraded')<0||blips.indexOf('forge')<0||pings.indexOf(700)<0) bad.push('missing upgrade callout, sound or 700 ping');
       atGun(0,1000,9000); ePress();
       if(p.wep.fk||P.credits!==1000||g.forgeUI||g.cs.s!==9000) bad.push('poor stash purchased using score');
       if(said.indexOf('need $2,500')<0||sounds.indexOf('deny')<0) bad.push('poor stash did not deny with dollar price');
       atGun(0,10000,0); g.arcade=true; ePress();
       if(p.wep.fk!==1||P.credits!==7500||ARCADE.mine!==0||g.forgeUI) bad.push('demo E did not use the stash while keeping score');
       g.arcade=false; atGun(1,10000,1234); ePress();
       if(!g.forgeUI||g.forgeUI.n!==4||P.credits!==10000) bad.push('MK III did not open its four unpaid choices');
       else {
         raidKey('Digit3',false,null); keys.Digit3=false;
         if(p.wep.fk!==2||p.wep.el!=='cryo'||P.credits!==4000||g.cs.s!==1234||g.cs.b.kill!==1234||g.cs.b.forge||g.forgeUI) bad.push('MK III did not buy the chosen element from stash only');
       }
       atGun(1,1000,9000); ePress();
       if(g.forgeUI||P.credits!==1000||p.wep.fk!==1||said.indexOf('need $6,000')<0) bad.push('unaffordable MK III opened or changed the gun');
       atGun(0,10000,0);
       NET.same=false; P.padmap={};
       PAD.on=false; PAD.prev=[]; PAD.held={}; PAD.xAfterTrade=0; PAD.xWas=false; PAD.prevMap=null; PAD.mSpent=null;
       navigator.getGamepads=pads; held=false; pollPad(); tick(1); held=true; pollPad(); tick(6);
       if(p.wep.fk!==1||P.credits!==7500||g.forgeUI) bad.push('pad X did not buy MK II instantly');
       held=false; pollPad();
       if(ownPads) navigator.getGamepads=realPads; else delete navigator.getGamepads;
       keys={}; g.trade={x:p.x,y:p.y,stock:[{k:'scrap',price:400,sold:false}]}; P.credits=5000;
       pedBuy(0);
       if(!g.trade.stock[0].sold||P.credits!==4600) bad.push('old takeCash 1 still capped the stall 400 purchase');
       if(g.cash!=null) bad.push('deploy created a carried cash wallet');
       return bad.length?bad.join('; '):null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       say=realSay; sndUi=realSnd; blip=realBlip; ping=realPing; saveProfile=realSave;
       if(ownPads) navigator.getGamepads=realPads; else delete navigator.getGamepads;
       try{ PAD.on=false; PAD.prev=[]; PAD.held={}; padRelease(); }catch(_p){}
       keys={}; mouse.down=false;
       try{ if(g){ g.arcade=oldArc; g.forgeUI=null; } __endRaid('abandon'); }catch(_e){}
       NET.same=netSame; ARCADE.mine=oldMine; __topClear(); __applyLoaded(JSON.parse(keep)); saveProfile();
     } }},
  {v:'31.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
