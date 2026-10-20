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

if ($s.Contains("  {v:'32.60',what:")) { throw "check 32.60 is in the fixture already" }

SubRx @'
  {v:'32.59',what:
'@ @'
  {v:'32.60',what:'a better copy of the held gun upgrades immediately; worse copies cannot replace it; Magnum takes the Scav Pistol class key',
   run:function(){
     var g,p,found,oldAmmo,oldGun,slot,ret;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();__topClear();p=g.player;p.roll=0;
       g.arcade=true;g.career=false;g.bag=[];g.stowQ={};g.stowAmmo={};p.swapped=false;p.wep=beltGunField('rifle');p.wepIssued=false;p.wepFromArmory=false;p.ammo=7;p.sec=WEAPONS.fists;p.secAmmo=0;p.secIssued=true;p.secFromArmory=false;g.hotAssign={2:'gun_rifle'};g.hotAuto={2:1};g.hot=2;oldGun=p.wep;
       found=beltGunField('rifle');found.dmg*=1.2;found.qRank=2;found.q='fine';oldAmmo=p.ammo;
       ret=arcadeGunLoot({},'gun_rifle',ITEMS.gun_rifle,found);
       if(p.wep.dmg!==found.dmg||p.wep.qRank!==2||p.ammo!==oldAmmo||g.hot!==2||g.hotAssign[2]!=='gun_rifle')return 'DEMO did not upgrade the held copy on its key with its rounds';
       if(g.bag.filter(function(k){return k==='gun_rifle';}).length!==1)return 'the replaced copy was not kept exactly once';
       if(!g.stowQ.rifle||g.stowQ.rifle.length!==1||g.stowQ.rifle[0].qRank!==oldGun.qRank||g.stowQ.rifle[0].dmg!==oldGun.dmg)return 'the replaced copy lost its quality';
       if(gunClassUpgrade({},'gun_rifle',ITEMS.gun_rifle,beltGunField('rifle'))!==null||p.wep.qRank!==2)return 'a worse copy replaced the upgraded gun';
       g.arcade=false;g.career=true;found=beltGunField('rifle');found.dmg*=1.4;found.qRank=3;
       g.bag.push('gun_rifle');gunQPush(found);autoBelt('gun_rifle',1,{found:found});
       if(p.wep.dmg!==found.dmg||p.ammo!==oldAmmo)return 'CAREER lost immediate better-copy upgrades';
       p.wep=beltGunField('pistol');p.wepIssued=true;p.ammo=5;p.sec=beltGunField('rifle');p.secAmmo=4;
       g.hotAssign={0:'gun_pistol',2:'gun_rifle'};g.hotAuto={0:1,2:1};g.hot=0;g.bag=[];
       found=beltGunField('magnum');g.arcade=true;g.career=false;
       ret=arcadeGunLoot({},'gun_magnum',ITEMS.gun_magnum,found);
       if(p.wep.id!=='magnum'||g.hotAssign[0]!=='gun_magnum'||g.hot!==0||p.ammo!==5)return 'Magnum did not replace the Scav Pistol on its key';
       return null;
     }finally{try{__endRaid('abandon');}catch(e){}__topClear();}
   }},
  {v:'32.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
