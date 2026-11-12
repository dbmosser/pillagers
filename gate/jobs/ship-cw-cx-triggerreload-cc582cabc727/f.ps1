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

if ($s.Contains("  {v:'37.71',what:")) { throw "check 37.71 is in the fixture already" }

SubRx @'
  {v:'37.70',what:
'@ @'
  {v:'37.71',what:'held single-shot guns repeat, shotguns load usable shells on their sound schedule, and only fresh loaded fire cuts reloads, on keys and RT in both local seats',
   run:function(){
     var kk=keys,mm=Object.assign({},mouse),nk=Object.assign({},NET),pk=Object.assign({},PAD),cp=Object.assign({},CFG),ik=Object.assign({},INDEV),rk=Object.assign({},RUMBLE),
         ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),nf=netPadFocused,np=netSamePost,fw=fireWeapon,pm=P.padmap,ps=P.padSticks,pa=P.p2Auto,
         g,p,side,ix,i,j,w,tag,bad=[],shots=0,pads,base,ammo0,stamp,kind;
     function ok(v,s){if(!v)bad.push(tag+': '+s);}
     function pd(n){var b=[];for(var q=0;q<17;q++)b.push({pressed:false,value:0});return {connected:true,index:n,id:'Xbox trigger reload',mapping:'standard',axes:[0,0,0,0],buttons:b,timestamp:1};}
     function poll(down){pads[ix].buttons[7]={pressed:down,value:down?1:0};pads[ix].timestamp++;pollPad();}
     function step(dt){g.t+=dt;updatePlayer(dt);}
     function reset(w,a,r){
       keys={};mouse.down=false;mouse.right=false;PAD.on=false;PAD.mx=0;PAD.my=0;PAD.afire=0;
       pads[0].buttons[7]={pressed:false,value:0};pads[1].buttons[7]={pressed:false,value:0};
       p.wep=cloneObj(w);p.sec=null;p.swapped=false;p.drawRef=p.wep;p.drawT=0;p.drawLen=0;p.ammo=a;p.reserve=r;p.reloading=0;p.rlTot=0;p.rlArm=0;p.shTot=0;p.shN=0;p.shIn=0;
       p.hand=null;p.prep=null;p.prepA=null;p.healQ=0;p.cooking=false;p.cookT=0;p.cookKind=null;p.hp=100;p.maxhp=100;p.iv=9999;
       p.downed=false;p.dying=false;p.specOut=false;p.roll=0;p.rollWet=false;p.rollCd=0;p.jam=0;p.stam=100;p.stamLock=0;p.stamRelease=0;p.shotSprintRelease=false;
       p.ads=false;p.trigYield=0;p.fired=false;p.dryTold=0;p.lastShot=-1e9;p.meleeAt=-99;p.wm=null;p.stimT=0;p.spin=0;p.arStk=0;p.arBonus=0;p.arHot=0;p.arGun=null;p.arMul=1;
       g.bag=[];g.pouch={smoke:0,decoy:0,frag:0,trip:0};g.hot=0;g.hotAssign={0:'gun_'+gunBase(p.wep.id)};g.hotAuto={};g.hotPruned={};
       g.wheel=null;g.sprintOn=false;g.sprinting=false;g.shWas=false;g.crouchTog=false;g.pwr=null;g.bullets=[];shots=0;rlfxStop();
     }
     function arm(){keys={KeyR:true};step(0.001);keys={};ok(p.reloading>0,'R did not start reload');}
     function half(){reset(WEAPONS.shotgun,0,50);arm();tickReload(1.2);ok(p.ammo===4&&p.reserve===46,'half shotgun '+p.ammo+'/'+p.reserve);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';__topClear();
       g.ents=[];g.zones=[];g.mapFirst=0;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.sim=false;g.t=10;
       CFG.xfPix=0;CFG.autoRel=1;CFG.sprintTgl=0;NET.on=false;P.p2Auto=0;P.padmap=null;P.padSticks='';
       netPadFocused=function(){return true;};netSamePost=function(){return true;};pads=[pd(0),pd(1)];navigator.getGamepads=function(){return pads;};
       fireWeapon=function(sh){if(sh===p)shots++;return fw.apply(this,arguments);};
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.role=side?'join':'host';NET.seat=side;NET.pair='cx-triggerreload';NET.padIx=-1;NET.padOther=-1;
         NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;NET.afHost=0;ix=side?0:1;tag=NET.same;
         padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;
         PAD.rtHeld=false;PAD.ltHeld=false;PAD.firing=0;PAD.adsing=0;PAD.afire=0;
         reset(WEAPONS.pistol,12,0);mouse.down=true;for(i=0;i<60;i++)step(1/60);
         ok(12-p.ammo>=3&&shots===12-p.ammo,'held pistol '+shots+' shots / '+(12-p.ammo)+' rounds');
         reset(WEAPONS.fists,0,0);mouse.down=true;for(i=0;i<60;i++)step(1/60);ok(shots===1,'held bare hands swung '+shots+' times');
         reset(WEAPONS.pistol,12,0);g.bag=['frag','frag'];g.hotAssign[4]='frag';g.hot=4;base=g.tel.thr.frag||0;
         mouse.down=true;for(i=0;i<15;i++)step(1/60);
         ok(p.cooking&&p.cookKind==='frag'&&(g.tel.thr.frag||0)===base+1&&shots===0,'held frag did not cook exactly one grenade');
         reset(WEAPONS.rifle,5,60);arm();mouse.down=true;step(0.001);
         ok(p.reloading===0&&p.rlTot===0&&p.rlArm===0&&p.ammo===4&&p.reserve===60,'fresh rifle cancel '+p.reloading+'/'+p.ammo+'/'+p.reserve);
         reset(WEAPONS.rifle,5,60);arm();p.lastShot=g.t*1000;mouse.down=true;step(0.001);
         ok(p.reloading===0&&p.ammo===5&&shots===0,'cooldown delayed cancellation or fired early');
         reset(WEAPONS.lmg,5,60);arm();mouse.down=true;step(0.001);ok(p.reloading===0&&p.ammo===5&&shots===0,'MG spin blocked cancel or fired early');
         reset(WEAPONS.rifle,0,60);arm();mouse.down=true;step(0.001);ok(p.reloading>0&&p.ammo===0&&p.reserve===60,'empty fresh pull cut reload');
         reset(WEAPONS.rifle,5,60);arm();p.fired=true;mouse.down=true;step(0.001);ok(p.reloading>0&&p.ammo===5,'old hold cut reload');
         half();mouse.down=false;step(0.001);base=g.bullets.length;mouse.down=true;step(0.001);
         ok(p.reloading===0&&p.ammo===3&&p.reserve===46&&g.bullets.length-base===6&&p.shTot===0,'loaded shells did not fire six pellets on fresh cancel');
         reset(WEAPONS.rifle,0,50);arm();tickReload(p.wep.reload/2000);ok(p.ammo===0&&p.reserve===50,'rifle loaded at midpoint');
         reset(WEAPONS.shotgun,0,50);mouse.down=true;step(0.001);for(i=0;i<72;i++)step(1/60);
         ok(p.reloading>0&&p.ammo===4&&p.reserve===46&&shots===0,'dry held trigger cut shell reload after first shell');
         half();stamp=p.padReloadN||0;keys={};activeReloadTick(p);keys={KeyR:true};ok(activeReloadTick(p),'shotgun active reload did not hit');keys={};
         ok(p.reloading<=0&&p.ammo===7&&p.reserve===43&&p.arBonus===1&&p.shTot===0&&(p.padReloadN||0)===stamp+1,'active reload did not finish remaining shells');
         reset(WEAPONS.shotgun,6,50);arm();tickReload(p.wep.reload*0.44/1000);ok(p.ammo===6,'single top-up arrived before 45 percent');
         tickReload(p.wep.reload*0.011/1000);ok(p.ammo===7&&p.reserve===49&&p.reloading>0,'single top-up missed 45 percent or shortened total time');
         stamp=p.padReloadN||0;tickReload(p.reloading/1000+0.001);ok(p.shTot===0&&(p.padReloadN||0)===stamp+1,'shell-only completion missed end stamp');
         reset(forgeApply(cloneObj(WEAPONS.shotgun),1,''),0,50);arm();tickReload(p.wep.reload/2000);
         base=0;for(j=0;j<p.wep.mag;j++)if(0.5>=(p.wep.mag>1?0.1+0.75*j/(p.wep.mag-1):0.45))base++;
         ok(p.ammo===base&&p.reserve===50-base,'forged shotgun did not load shells');
         half();p.roll=0.38;p.rollDir={x:1,y:0};step(0.001);ok(p.reloading===0&&p.shTot===0&&p.ammo===4&&p.reserve===46,'roll lost shells or kept shell clock');
         half();p.sec=cloneObj(WEAPONS.pistol);p.secAmmo=3;swapGuns();ok(p.reloading===0&&p.shTot===0&&p.secAmmo===4&&p.reserve===46,'swap lost shells or kept shell clock');
         half();p.iv=0;p.hp=20;p.revived=false;damagePlayer(999,'sentry','probe',p.x-2,p.y);
         ok(p.downed&&p.reloading===0&&p.shTot===0&&p.ammo===4&&p.reserve===46,'down lost shells or kept shell clock');
         reset(WEAPONS.shotgun,0,50);g.sim=true;p.reloading=p.wep.reload;tickReload(p.wep.reload/2000);
         ok(p.ammo===0&&p.reserve===50,'bot sim gained partial shells');tickReload(p.wep.reload/2000+0.001);ok(p.ammo===7&&p.reserve===43,'bot sim reload changed');g.sim=false;
         reset(WEAPONS.pistol,12,0);poll(false);step(0.001);poll(true);ok(PAD.ix===ix&&mouse.down,'wrong RT mapping');
         for(i=0;i<60;i++){poll(true);step(1/60);}ok(12-p.ammo>=3&&shots===12-p.ammo,'RT held pistol did not repeat');
         poll(false);step(0.001);reset(WEAPONS.rifle,5,60);arm();poll(true);step(0.001);
         ok(p.reloading===0&&p.ammo===4&&p.reserve===60,'fresh RT did not cancel and fire');poll(false);step(0.001);
       }
       return bad.length?bad.slice(0,25).join('; '):null;
     }finally{
       fireWeapon=fw;netPadFocused=nf;netSamePost=np;
       if(p){p.downed=false;p.dying=false;p.prep=null;p.prepA=null;p.healQ=0;p.hand=null;p.cooking=false;p.reloading=0;p.shTot=0;}if(g)g.sim=false;rlfxStop();
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(_e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(CFG,cp);Object.assign(INDEV,ik);Object.assign(RUMBLE,rk);P.padmap=pm;P.padSticks=ps;P.p2Auto=pa;keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'37.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
