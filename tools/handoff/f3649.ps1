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

if ($s.Contains("  {v:'36.49',what:")) { throw "check 36.49 is in the fixture already" }

SubRx @'
  {v:'36.48',what:
'@ @'
  {v:'36.49',what:'heals and plates cancel reloads and block manual/empty reloads; every cancelled reload loses the active chain, for both local seats',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid fixture';
     var g,p,side,i,k,ix,tag,sl,bad=[],kk=keys,mm=Object.assign({},mouse),nk=Object.assign({},NET),pk=Object.assign({},PAD),cp=Object.assign({},CFG),hh=Object.assign({},HHOLD);
     function ok(v,s){if(!v)bad.push(tag+': '+s);}
     function reset(){
       keys={};mouse.down=false;PAD.on=false;PAD.mx=0;PAD.my=0;
       p.wep=cloneObj(WEAPONS.rifle);p.drawRef=p.wep;p.drawT=0;p.drawLen=0;p.ammo=2;p.reserve=60;p.reloading=0;p.rlTot=0;p.rlArm=0;
       p.hand=null;p.prep=null;p.prepA=null;p.healQ=0;p.healRate=0;p.healCap=undefined;p.healHi=0;p.healLo=undefined;p.cooking=false;
       p.hp=30;p.maxhp=100;p.armor=0;p.armorCap=60;p.downed=false;p.dying=false;p.specOut=false;p.roll=0;p.rollWet=false;p.rollCd=0;p.jam=0;
       p.iv=999;p.stam=100;p.stamLock=0;p.stamRelease=0;p.shotSprintRelease=false;p.ads=false;p.trigYield=0;p.fired=false;p.lastShot=-1e9;
       g.bag=['bandage','medkit','plate','stim'];g.hot=0;g.hotAssign={0:'gun_rifle',6:'bandage',7:'medkit',8:'plate',9:'bandage'};g.hotAuto={};g.hotPruned={};g.msel='bandage';
       g.wheel=null;g.sprintOn=false;g.sprinting=false;g.shWas=false;g.crouchTog=false;HHOLD.arm=0;
       p.arStk=2;p.arBonus=1;p.arGun=p.wep;p.arMul=1.1;p.arHot=0;
     }
     function arm(){keys={KeyR:true};updatePlayer(0.001);keys={};ok(p.reloading>0,'R did not stage a reload');p.arStk=2;p.arBonus=1;p.arHot=1;reloadFoley(p);}
     function cut(s){ok(p.reloading===0&&p.rlTot===0&&p.rlArm===0,s+' retained the reload clock');ok(p.arStk===0&&p.arBonus===0&&p.arHot===0,s+' kept the chain');ok(!RLFX.on,s+' kept reload sound');}
     function blocked(s){
       keys={KeyR:true};mouse.down=false;updatePlayer(0.001);ok(!(p.reloading>0),s+' allowed R');
       keys={};p.ammo=0;p.fired=false;p.trigYield=0;mouse.down=true;updatePlayer(0.001);ok(!(p.reloading>0),s+' allowed empty trigger');
       mouse.down=false;keys={};
     }
     function belt(key,cell){
       reset();arm();raidKey(key,false,null);keys={};cut(key+' draw');ok(p.hand&&p.hand.k===cell,key+' did not take item out');
       if(p.hand){p.hand.t=0;mouse.down=false;handTick(p,0);mouse.down=true;handTick(p,0);mouse.down=false;}
       ok(cell==='plate'?!!p.prepA:!!p.prep,key+' did not start medical');blocked(key);
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle','gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.ents=[];g.zones=[];g.mapFirst=0;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.t=10;NET.on=false;
       CFG.autoRel=1;CFG.sprintTgl=0;CFG.healPrep=1.5;CFG.armorPrep=2;
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.role=side?'join':'host';NET.seat=side;tag=NET.same;
         belt('Digit7','bandage');belt('Digit8','medkit');belt('Digit9','plate');belt('Digit0','bandage');
         // v28.xx (cw-cx-reloadmedical): H has no live medical picker after wheel4; exercise its shared use door with an assigned bandage cell.
         reset();arm();ok(useBeltHeal(6),'belt heal did not start');cut('belt heal');ok(!!p.prep,'belt heal did not start wind-up');blocked('bandage wind-up');
         tickPrep(2);ok(p.healQ>0,'bandage did not start healing');blocked('running heal');
         tickHeal(100);keys={KeyR:true};updatePlayer(0.001);keys={};ok(p.reloading>0,'R stayed blocked after healing');
         reset();arm();quickPlate();cut('quick plate');ok(!!p.prepA,'quick plate did not start');blocked('plate wind-up');
         tickPrep(3);keys={KeyR:true};updatePlayer(0.001);keys={};ok(p.reloading>0,'R stayed blocked after plate');
         reset();arm();beltInstant(6);cut('instant bandage');ok(!!p.prep,'instant bandage did not start');
         reset();arm();beltInstant(8);cut('instant plate');ok(!!p.prepA,'instant plate did not start');
         reset();arm();handTake('medkit');cut('wheel draw');ok(wheelHeal('medkit')&&p.prep,'wheel heal did not start');
         reset();g.hot=5;arm();beltStep(1);cut('pad medical pick');ok(p.hand&&p.hand.k==='bandage','pad bumper did not take bandage out');
         reset();arm();mouse.down=true;var before=p.ammo;updatePlayer(0.001);cut('fire');ok(p.ammo===before-1,'fire cancel did not fire a real round');
         reset();p.wep=cloneObj(WEAPONS.shotgun);p.drawRef=p.wep;arm();mouse.down=true;before=p.ammo;updatePlayer(0.001);cut('shotgun fire');ok(p.ammo===before-1,'shotgun fire cancel did not shoot');
         reset();arm();p.roll=0.38;p.rollDir={x:1,y:0};updatePlayer(0.001);cut('roll');
         reset();arm();keys={ShiftLeft:true,KeyW:true};updatePlayer(0.001);keys={};ok(g.sprinting,'no sprint staged');cut('sprint');
         reset();arm();p.sec=cloneObj(WEAPONS.pistol);p.secAmmo=3;swapGuns();cut('swap');
         reset();arm();p.iv=0;p.hp=20;p.revived=false;damagePlayer(999,'sentry','probe',p.x-2,p.y);ok(p.downed,'no down staged');cut('down');
         reset();arm();useStim(g.bag.indexOf('stim'));ok(p.reloading>0,'stim cancelled reload');
         reset();p.ammo=0;arm();mouse.down=true;updatePlayer(0.001);ok(p.reloading>0,'empty trigger cut its own reload');
         reset();arm();p.reloading=1;p.arBonus=0;p.arHot=0;tickReload(0.002);ok(p.ammo>2&&p.arStk===0,'ordinary reload did not finish normally');
         reset();arm();p.rlTot=p.wep.reload;p.reloading=p.rlTot*0.49;p.rlArm=1;keys={KeyR:true};ok(activeReloadTick(p)&&p.arStk===3&&p.arBonus===1,'active reload was treated as cancellation');keys={};
       }
       return bad.length?bad.slice(0,20).join('; '):null;
     }finally{
       if(p){p.downed=false;p.prep=null;p.prepA=null;p.healQ=0;p.hand=null;p.arStk=0;p.arBonus=0;p.reloading=0;}rlfxStop();
       try{__endRaid('abandon');}catch(_e){}__topClear();
       Object.assign(NET,nk);Object.assign(PAD,pk);Object.assign(CFG,cp);Object.assign(HHOLD,hh);keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'36.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
