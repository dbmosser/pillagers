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

if ($s.Contains("  {v:'36.23',what:")) { throw "check 36.23 is in the fixture already" }

SubRx @'
  {v:'36.22',what:
'@ @'
  {v:'36.23',what:'switching guns ends only the local active reload chain immediately, hides its status, and the next hit starts at x1 in both windows',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid))return 'SKIP: this fixture cannot deploy';
     var g,p,side,bad=[],kk=keys,mm=mouse.down,nk={on:NET.on,same:NET.same};
     function entry(q){statusLive(q);for(var i=0;i<STATUSL.length;i++)if(STATUSL[i].id==='ar')return STATUSL[i];return null;}
     function start(){keys={};p.hand=null;p.ammo=2;p.reserve=60;p.reloading=p.wep.reload;p.rlTot=0;p.rlArm=0;activeReloadTick(p);}
     function hit(){start();p.reloading=p.rlTot*0.49;keys.KeyR=true;var ok=activeReloadTick(p);keys={};return ok;}
     function chain(){p.arStk=0;p.arBonus=0;if(!hit()||!hit()||p.arStk!==2)throw Error('cannot stage x2');}
     function cleared(label){var e=entry(p);if(p.arStk!==0||p.arBonus!==0||p.arGun!=null||(e&&e.on))bad.push(NET.same+': '+label+' kept chain, bonus, gun or status');}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.sim=false;g.over=false;g.paused=false;g.bagOpen=false;g.mapOpen=false;NET.on=false;keys={};mouse.down=false;
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';p.wep=cloneObj(WEAPONS.pistol);p.sec=cloneObj(WEAPONS.rifle);p.secAmmo=5;p.downed=false;p.dying=false;p.roll=0;
         p.wepIssued=false;p.secIssued=false;p.wepFromArmory=false;p.secFromArmory=false;
         chain();var a=p.wep,b=p.sec,e=entry(p);if(!e||!e.on||e.nm!=='active reload x2')throw Error('cannot stage x2 status');
         if(!swapGuns()||p.wep!==b)throw Error('cannot switch to gun B');cleared('switch to B');
         if(!swapGuns()||p.wep!==a)throw Error('cannot switch back to A');cleared('switch back to A');
         if(!hit())throw Error('cannot stage next active reload');e=entry(p);
         if(p.arStk!==1||!e||!e.on||e.nm!=='active reload x1'||e.v!=='+15% damage')bad.push(NET.same+': next hit did not restart at x1');
         chain();start();if(!swapGuns())throw Error('cannot cancel reload by switching');cleared('cancelled reload');
         if(p.reloading!==0||p.rlTot!==0)bad.push(NET.same+': switch kept the old reload');
         if(bad.length)return bad.join('; ');
         chain();var partner=Object.assign({},p);partner.wep=cloneObj(WEAPONS.smg);partner.sec=cloneObj(WEAPONS.shotgun);partner.secAmmo=2;
         g.player=partner;try{if(!swapGuns())throw Error('cannot switch partner gun');}finally{g.player=p;}
         e=entry(p);if(p.arStk!==2||!p.arBonus||!e||!e.on||e.nm!=='active reload x2')bad.push(NET.same+': partner switch cleared local chain');
         if(partner.arStk!==0||partner.arBonus!==0||partner.arGun!=null)bad.push(NET.same+': partner retained own chain');
         // v28.xx (cw-cx-reloadswitch): a no-op selection is not a switch; a different copy of the same gun is.
         arSetHeldGun(p,p.wep);if(p.arStk!==2)bad.push(NET.same+': selecting held gun cleared chain');
         arSetHeldGun(p,cloneObj(p.wep));cleared('different copy of same gun');
         chain();arSetHeldGun(p,WEAPONS.fists);cleared('switch to melee');arSetHeldGun(p,a);cleared('return from melee');
         chain();p.sec=cloneObj(WEAPONS.shotgun);g.bag=['gun_smg'];
         if(!equipFromBag(0,2))throw Error('cannot equip stowed gun');
         if(p.arStk!==2||!p.arBonus)bad.push(NET.same+': stowed equip cleared held chain');
         g.bag=['gun_rifle'];if(!equipFromBag(0,1))throw Error('cannot equip held gun');cleared('bag equip');
         chain();p.sec=WEAPONS.fists;p.secAmmo=0;
         if(!bagHeldGun(p.swapped?'gunB':'gunA'))throw Error('cannot stow held gun');cleared('stow held gun');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       if(g&&p)g.player=p;NET.on=nk.on;NET.same=nk.same;keys=kk;mouse.down=mm;
       try{if(p){p.arStk=0;p.arBonus=0;p.arGun=null;}__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'36.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
