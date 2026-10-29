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

if ($s.Contains("  {v:'36.27',what:")) { throw "check 36.27 is in the fixture already" }

SubRx @'
  {v:'36.26',what:
'@ @'
  {v:'36.27',what:'steady hand and beast mode: own credited kills add 1% to 15, real rounds multiply all three, damage and gun resets, five-second expiry, both seats and no sim',
   run:function(){
     if(typeof dmgStreakKill!=='function'||typeof dmgStreakMul!=='function')return 'damage streak statuses are missing';
     var g,p,side,mode,i,base,e,partner,oldP,words=[],ft=ctx.fillText,kk=keys,mm=mouse.down,saved={},nk=['on','role','seat','same','upSeed','entMap','entDead'],serial=900000;
     function near(a,b){return Math.abs(a-b)<0.000001;}
     function shot(){g.bullets.length=0;fireWeapon(p,p.wep,p.x+200,p.y,true);var b=g.bullets[g.bullets.length-1];g.bullets.length=0;return b?b.dmg:NaN;}
     function clear(){p.shStk=0;p.bmStk=0;p.bmUntil=0;p.arBonus=0;p.arStk=0;p.hp=100;p.armor=0;p.iv=0;p.arcSh=0;p.downed=false;p.dying=false;p.specOut=false;}
     function credit(mine,air){
       if(side){
         var id=++serial;NET.entMap[id]={kind:'crawler',x:p.x+250,y:p.y,hp:0};
         if(netKillTake({state:'in'},{seat:mine?1:2,k:'crawler',id:id})!==(mine?'kill':'ignored'))throw Error('join credit routing failed');
       }else{
         var b=mkCrawler(p.x+250,p.y);b.hp=air?1:0;b.elite=0;b.affix=null;b.byPlayer=!!mine;b.bySeat=mine?0:1;g.ents=[b];
         if(air)airBlast({pts:[{x:b.x,y:b.y}]},0);
         updateEnts(0);if(g.ents.indexOf(b)>=0)throw Error('host death was not processed');
       }
     }
     function status(id){statusLive(p);for(var j=0;j<STATUSL.length;j++)if(STATUSL[j].id===id)return STATUSL[j];return null;}
     function require(ok,msg){if(!ok)throw Error((mode?'arcade ':'career ')+(side?'p2: ':'p1: ')+msg);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       for(i=0;i<nk.length;i++)saved[nk[i]]=NET[nk[i]];
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.sim=false;g.over=false;g.paused=false;g.bagOpen=false;g.mapOpen=false;g.hotZone=null;g.pwr=null;keys={};mouse.down=false;
       for(mode=0;mode<2;mode++)for(side=0;side<2;side++){
         g.arcade=!!mode;g.ents=[];g.t=10;NET.on=!!side;NET.role=side?'join':'host';NET.seat=side?1:0;NET.same=side?'p2':'host';NET.upSeed=g.seed>>>0;NET.entMap={};NET.entDead={};
         p.wep=cloneObj(WEAPONS.pistol);p.hand=null;p.reloading=0;p.ammo=5;clear();base=shot();require(base>0,'no control round');
         credit(false,false);require(!p.shStk&&!p.bmStk,'partner kill raised local stacks');
         for(i=0;i<3;i++)credit(true,false);
         require(p.shStk===3&&p.bmStk===3,'three kills did not give three stacks');
         p.bmStk=0;require(near(shot()/base,1.03),'steady hand round is not x1.03');
         damagePlayer(5,'fire','fire',p.x+100,p.y);require(p.shStk===0,'fire damage kept steady hand');
         clear();p.armor=100;credit(true,false);damagePlayer(5,'blast','blast',p.x+100,p.y);require(p.shStk===0&&p.armor<100,'armour hit kept steady hand');
         clear();credit(true,false);g.pwr={act:{shield:10}};damagePlayer(5,'blast','blast',p.x+100,p.y);require(p.shStk===0&&p.hp===100,'shield hit kept steady hand');g.pwr=null;
         clear();for(i=0;i<4;i++){if(i)g.t+=2;credit(true,false);}
         require(p.bmStk===4,'four kills two seconds apart did not give beast mode 4');
         p.shStk=0;require(near(shot()/base,1.04),'beast mode round is not x1.04');
         e=status('bm');require(e&&e.on&&e.nm==='beast mode +4%'&&e.v==='5s'&&near(e.f,1),'beast mode name, seconds or ring disagrees');
         g.t+=2;e=status('bm');require(e.on&&e.v==='3s'&&near(e.f,0.6),'beast mode clock did not shrink');
         g.t+=3.1;dmgStreakTick(p);require(p.bmStk===0&&near(shot()/base,1),'5.1 seconds did not expire beast mode');
         credit(true,false);g.t+=5;credit(true,false);require(p.bmStk===1,'kill at expiry did not start a new chain at one');
         var bm=p.bmStk,until=p.bmUntil;arSetHeldGun(p,cloneObj(WEAPONS.pistol));require(p.shStk===0&&p.bmStk===bm&&p.bmUntil===until,'gun swap did not clear only steady hand');
         credit(true,false);arSetHeldGun(p,p.wep);require(p.shStk===1,'no-op gun selection cleared steady hand');
         for(i=0;i<20;i++)credit(true,false);require(p.shStk===15&&p.bmStk===15,'stacks did not stop at 15');
         p.arBonus=1;p.arMul=1.15;p.arGun=p.wep;p.ammo=5;require(near(shot()/base,1.15*1.15*1.15),'three damage bonuses did not multiply');
         words=[];ctx.fillText=function(t){words.push(String(t).toLowerCase());return ft.apply(this,arguments);};
         try{drawStatusIcons();}finally{ctx.fillText=ft;}
         require(words.indexOf('steady hand +15%')>=0&&words.indexOf('beast mode +15%')>=0&&words.indexOf('5s')>=0,'status names or countdown were not drawn');
         partner=Object.assign({},p);partner.wep=cloneObj(WEAPONS.rifle);arSetHeldGun(partner,WEAPONS.fists);dmgStreakHurt(partner,5);
         require(p.shStk===15&&p.bmStk===15&&partner.shStk===0,'another pillager reset this window');
         clear();if(!side){credit(true,true);require(p.shStk===1&&p.bmStk===1,'air strike kill did not count');}
         clear();p.shStk=3;p.bmStk=4;p.bmUntil=g.t+5;g.sim=true;
         dmgStreakKill(p,'crawler');dmgStreakHurt(p,5);arSetHeldGun(p,WEAPONS.fists);g.t+=6;dmgStreakTick(p);
         require(p.shStk===3&&p.bmStk===4&&dmgStreakMul(p)===1,'sim ran a streak rule');g.sim=false;
       }
       return null;
     }finally{
       ctx.fillText=ft;keys=kk;mouse.down=mm;if(g){g.sim=false;if(oldP)g.player=oldP;}for(i=0;i<nk.length;i++)NET[nk[i]]=saved[nk[i]];
       try{if(p){p.shStk=0;p.bmStk=0;p.arBonus=0;}__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'36.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
