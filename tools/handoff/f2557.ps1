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

if ($s.Contains("  {v:'25.57',what:")) { throw "check 25.57 is in the fixture already" }

SubRx @'
  {v:'25.56',what:
'@ @'
  {v:'25.57',what:'forge12: a gun forged MK III cryo and extracted is kept on the armoury model and comes up forged on the next deploy, a forged gun carried out in the backpack is kept too, a death loses it with the armoury gun, an abandon keeps an older forge and never writes this raid, and a bad saved record is dropped on load',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__applyLoaded||!window.__P||typeof forgeApply!=='function') return 'SKIP: no raid, loader or forge model here';
     if(typeof forgeBank!=='function'||typeof forgeSweep!=='function') return 'no kept upgrades (forgeBank, forgeSweep)';
     var bad=[], snap=null, q, g, p, f;
     function base(){
       q=__P(); q.autoExport=false;
       q.weapons=['pistol']; q.equipped='pistol'; q.equippedSec='none'; q.forged={};
       q.stash=[]; q.kit=[]; q.hotAssign={}; q.safe=null; q.dropKit=[]; q.kitChosen=0; q.devKit=0;
       q.kitSaved=null; q.kitBeforeFree=null; q.hotBeforeFree=null; q.gunBeforeFree=null; q.freeKit=0; delete q.raidSpliced; q.gunPiled=[];
     }
     function up(){ __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player; return !!(g&&!g.over&&p); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       // ONE: a field rifle forged MK III cryo in hand, extracted
       base(); saveProfile();
       if(!up()) return 'SKIP: no live raid';
       p.sec=forgeApply(rollFieldGun('rifle'),2,'cryo'); p.secAmmo=10; p.secIssued=false; p.secFromArmory=false;
       p.downed=false; p.hp=100;
       __endRaid('extract');
       q=__P(); f=q.forged&&q.forged.rifle;
       if(q.weapons.indexOf('rifle')<0) bad.push('control: the extracted rifle did not reach the armoury');
       if(!f||f.fk!==2||f.el!=='cryo') bad.push('the extracted MK III cryo rifle was not kept ('+JSON.stringify(f||null)+')');
       q.equipped='rifle'; q.equippedSec='none'; saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no second raid';
       if(!p.wep||p.wep.id!=='rifle'||p.wep.el!=='cryo'||p.wep.fk!==2||String(p.wep.name).indexOf('MK III')<0) bad.push('the next deploy came up with '+(p.wep&&p.wep.name)+' el '+(p.wep&&p.wep.el));
       if(!p.wepFromArmory) bad.push('the forged armoury gun is not marked as from the armoury');
       // TWO: abandon with a forge bought this raid keeps the older record
       p.wep=forgeApply(p.wep,2,'fire');
       __endRaid('abandon');
       f=__P().forged&&__P().forged.rifle;
       if(!f||f.fk!==2||f.el!=='cryo') bad.push('an abandon changed the kept forge ('+JSON.stringify(f||null)+')');
       // THREE: death loses it with the armoury gun
       if(!up()) return bad.length?bad.join('; '):'SKIP: no third raid';
       p.downed=false; p.hp=100;
       __endRaid('dead');
       q=__P();
       if(q.weapons.indexOf('rifle')>=0) bad.push('control: the rifle carried from the armoury survived the death');
       if(q.forged&&q.forged.rifle) bad.push('the forge of a gun lost in a death was kept');
       // FOUR: a forged gun carried out in the backpack
       base(); saveProfile();
       if(!up()) return bad.length?bad.join('; '):'SKIP: no fourth raid';
       g.bag.push('gun_dmr'); gunQPush(forgeApply(WEAPONS.dmr,1));
       p.downed=false; p.hp=100;
       __endRaid('extract');
       f=__P().forged&&__P().forged.dmr;
       if(__P().weapons.indexOf('dmr')<0) bad.push('control: the backpack Marksman Rifle did not reach the armoury');
       if(!f||f.fk!==1) bad.push('a MK II carried out in the backpack was not kept ('+JSON.stringify(f||null)+')');
       // FIVE: a bad saved record is dropped on load
       q=JSON.parse(JSON.stringify(__P()));
       q.weapons=['pistol','rifle','smg']; q.stash=[];
       q.forged={rifle:{fk:2,el:'bogus'},smg:{fk:9},pistol:{fk:1,el:'acid'},lance:{fk:2,el:'fire'},nope:{fk:1}};
       __applyLoaded(q);
       f=__P().forged||{};
       if(f.rifle||f.smg||f.lance||f.nope) bad.push('a bad saved forge record survived the load ('+JSON.stringify(f)+')');
       if(!f.pistol||f.pistol.fk!==1||f.pistol.el) bad.push('a good MK II record was not kept clean through the load ('+JSON.stringify(f.pistol||null)+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
