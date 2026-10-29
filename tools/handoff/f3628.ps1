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

if ($s.Contains("  {v:'36.28',what:")) { throw "check 36.28 is in the fixture already" }

SubRx @'
  {v:'36.27',what:
'@ @'
  {v:'36.28',what:'switching to a rifle starts a 0.825 s draw, cannot fire before zero, and shows switching for the real draw in both seats; reload cancel and chain break survive',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid))return 'SKIP: this fixture cannot deploy';
     var g,p,side,mode,i,k,before,kk=keys,mm=Object.assign({},mouse),nk=Object.assign({},NET),pk=Object.assign({},PAD),bad=[];
     function ok(v,msg){if(!v)bad.push((side?'p2':'host')+'/'+mode+': '+msg);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol','gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.sim=false;g.ents=[];g.bag=[];g.bagOpen=false;g.mapOpen=false;g.mapFirst=0;g.paused=false;g.trade=null;g.wheel=null;g.forgeUI=null;
       NET.on=false;PAD.on=false;PAD.afire=0;PAD.firing=false;keys={};mouse.down=false;
       for(side=0;side<2;side++)for(mode=0;mode<2;mode++){
         NET.same=side?'p2':'host';p.wep=cloneObj(WEAPONS.pistol);p.sec=cloneObj(WEAPONS.rifle);p.ammo=8;p.secAmmo=20;p.reserve=60;
         p.wepIssued=false;p.secIssued=false;p.wepFromArmory=false;p.secFromArmory=false;p.swapped=false;
         g.hot=heldGunCell(hotbarSlots());if(g.hot<0)return 'cannot stage held pistol hotbar slot';
         p.hand=null;p.downed=false;p.dying=false;p.roll=0;p.iv=999;p.jam=0;p.cooking=false;p.trigYield=false;
         p.drawRef=p.wep;p.drawT=0;p.drawLen=0;p.arStk=2;p.arBonus=1.1;p.arGun=p.wep;p.arHot=1;p.reloading=1000;p.rlTot=1000;p.rlArm=1;
         if(mode===0){ok(swapGuns(),'swap refused');}
         else{var slots=hotbarSlots(),ix=-1;for(i=0;i<slots.length;i++)if(slots[i].kind==='gun'&&!slots[i].inHand&&slots[i].icon==='rifle')ix=i;
           if(ix<0)return 'cannot stage stowed rifle hotbar slot';setHot(ix);}
         ok(p.wep.id==='rifle','rifle did not come up');
         ok(p.reloading===0&&p.rlTot===0&&p.rlArm===0,'swap retained reload');
         ok(p.arStk===0&&p.arBonus===0&&p.arGun==null,'swap retained active reload chain');
         drawTick(p,0);ok(Math.abs(p.drawT-0.825)<1e-9&&Math.abs(p.drawLen-0.825)<1e-9,'rifle draw starts at '+p.drawT+' instead of 0.825');
         if(bad.length)return bad.join('; ');
         before=p.ammo;p.lastShot=-1e9;p.fired=false;mouse.down=true;
         for(i=0;i<82;i++){g.t+=0.01;updatePlayer(0.01);ok(p.ammo===before,'gun fired before draw reached zero at '+((i+1)*0.01).toFixed(2)+' s');}
         ok(p.drawT>0&&p.drawT<0.006,'rifle draw did not last 0.825 s');
         ok(playerStatus().indexOf('SWITCHING GUNS')>=0,'switch status ended before draw');
         g.t+=0.01;updatePlayer(0.01);ok(p.drawT===0&&p.ammo===before-1,'rifle did not fire as draw reached zero');
         ok(playerStatus().indexOf('SWITCHING GUNS')<0,'switch status survived draw');mouse.down=false;
       }
       var want={pistol:0.38,magnum:0.525,smg:0.6,carbine:0.75,rifle:0.825,shotgun:0.9,sniper:1.275,lmg:1.5,lance:1.5,rocket:1.5};
       for(k in want)if(Math.abs(drawTime({id:k,mag:1})-want[k])>1e-9)bad.push(k+': wrong draw time');
       if(drawTime({id:'fixture_unknown',mag:1})!==0.75||drawTime(WEAPONS.fists)!==0||drawTime(null)!==0)bad.push('wrong fallback or melee draw time');
       return bad.length?bad.join('; '):null;
     }finally{
       mouse.down=false;keys={};try{__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();
       Object.assign(NET,nk);Object.assign(PAD,pk);keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'36.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
