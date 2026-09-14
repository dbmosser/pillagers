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
  {v:'13.86',what:
'@ @'
  {v:'13.87',what:'a found gun in slot 2 bags the gun it replaces: a field Scav Pistol held in slot 2 goes into the backpack when a found SMG takes the slot, while an empty slot 2 simply takes the SMG (searching and loot audit 2026-09-14, finding 5)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof openContainer!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||!WEAPONS.tacker||!WEAPONS.pistol||!ITEMS.gun_smg) return 'SKIP: no crates or starter guns in this build';
     var bad=[];
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       g.ents.length=0; g.hotZone=null; g.hotAssign={}; g.hotAuto={}; g.stowAmmo={};
       p.downed=false; p.iv=99; p.swapped=false;
       function arm(secGun){
         g.bag=[];
         p.wep=copyW('tacker'); p.ammo=p.wep.mag; p.wepIssued=true; p.wepFromArmory=false;
         if(secGun){ p.sec=copyW('pistol'); p.secAmmo=12; p.secIssued=false; p.secFromArmory=false; }
         else { p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; }
       }
       function find(){ var box=setLoot(mkContainer(p.x+6,p.y+6,'crate'),['gun_smg']); g.containers.push(box); openContainer(box,['gun_smg']); }
       function held(id){ return (p.wep&&p.wep.id===id)||(p.sec&&p.sec.id===id); }
       // CONTROL FIRST: an empty slot 2 takes the SMG.
       arm(false); find();
       if(!(p.sec&&p.sec.id==='smg')) return 'SKIP: a found SMG did not go to an empty slot 2, so the displacing branch is not reached here';
       // THE FINDING: a field Scav Pistol in slot 2.
       arm(true); find();
       if(!held('smg')) return 'SKIP: the found SMG was not equipped over the pistol';
       if(!held('pistol')&&g.bag.indexOf('gun_pistol')<0) bad.push('a found SMG took slot 2 and the field Scav Pistol held there is in neither hand nor the backpack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
