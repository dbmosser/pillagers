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

if ($s.Contains("  {v:'32.61',what:")) { throw "check 32.61 is in the fixture already" }

SubRx @'
  {v:'32.60',what:
'@ @'
  {v:'32.61',what:'an exhausted held gun selects the next loaded belt gun and names it; reserve, items and empty guns never trigger a bad switch',
   run:function(){
     if(typeof autoEmptyGun!=='function')return 'no automatic switch from an exhausted gun';
     var g,p,ss=say,lines=[],u=updatePlayer;
     function setup(){
       p.wep=beltGunField('pistol');p.sec=beltGunField('rifle');p.ammo=0;p.reserve=0;p.secAmmo=0;p.hand=null;p.roll=0;p.reloading=0;p.downed=false;p.dying=false;p.cooking=null;p.wepIssued=false;p.secIssued=false;p.wepFromArmory=false;p.secFromArmory=false;p.swapped=false;
       g.bag=['gun_smg'];g.stowAmmo={smg:[3]};g.stowQ={};g.hotAssign={0:'gun_pistol',1:'gun_smg',2:'gun_rifle'};g.hotAuto={0:1,1:1,2:1};g.hot=0;g.bagOpen=false;g.mapOpen=false;g.wheel=null;g.trade=null;g.forgeUI=null;g.searching=null;g.paused=false;lines=[];
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol','gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();__topClear();p=g.player;g.mapFirst=false;g.ents=[];say=function(s){lines.push(String(s));};
       for(var mode=0;mode<2;mode++){
         setup();g.arcade=!!mode;g.career=!mode;
         if(!autoEmptyGun()||p.wep.id!=='smg'||p.ammo!==3||g.hot!==1)return 'did not choose the next loaded backpack gun, mode '+mode;
         if(lines.length!==1||lines[0].toLowerCase()!==(p.wep.name+' equipped').toLowerCase())return 'the automatic switch did not name its gun exactly once';
         autoEmptyGun();if(lines.length!==1)return 'loaded gun repeated the callout';
         setup();p.reserve=10;if(autoEmptyGun()||p.wep.id!=='pistol')return 'switched despite usable reserve';
         setup();p.hand={kind:'heal'};if(autoEmptyGun())return 'an exhausted item forced the gun up';
         setup();g.stowAmmo.smg=[0];if(autoEmptyGun()||p.wep.id!=='pistol'||lines.length)return 'switched to an empty gun';
         setup();g.bag=[];p.secAmmo=4;if(!autoEmptyGun()||p.wep.id!=='rifle'||p.ammo!==4)return 'did not skip the empty belt cell for the loaded stowed gun';
         if(lines.length!==1||lines[0]!==p.wep.name.toLowerCase())return 'the stowed switch did not name its gun exactly once';
       }
       setup();g.arcade=false;g.career=false;g.t=12;mouse.down=false;keys={};updatePlayer(0);
       if(p.wep.id!=='smg')return 'the real player update does not switch with the trigger released';
       return null;
     }finally{say=ss;try{__endRaid('abandon');}catch(e){}__topClear();}
   }},
  {v:'32.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
