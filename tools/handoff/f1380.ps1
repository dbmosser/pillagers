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
  {v:'13.79',what:
'@ @'
  {v:'13.80',what:'the dead do nothing in the death fade: a belt key pressed during the fade does not equip the backpack gun over the armoury rifle, so the death still takes the rifle, as it does with no key pressed, and a punch in the fade is refused (combat and player state audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof killPlayer!=='function'||typeof raidKey!=='function'||typeof meleeStrike!=='function'||!WEAPONS.rifle||!WEAPONS.magnum||!ITEMS.gun_smg) return 'SKIP: no death beat or guns in this build';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),st:(P2.stash||[]).slice(),eq:P2.equipped,es:P2.equippedSec,cr:P2.credits};
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     function land(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       g.ents.length=0; p.downed=false; p.dying=false; p.iv=0;
       P2.weapons=['rifle','magnum']; P2.equipped='rifle'; P2.equippedSec='magnum';
       p.wep=copyW('rifle'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=true;
       p.sec=copyW('magnum'); p.secAmmo=p.sec.mag; p.secIssued=false; p.secFromArmory=true; p.swapped=false;
       g.bag=['gun_smg']; g.hotAssign={4:'gun_smg'}; g.hotAuto={};
       return g;
     }
     function die(press){
       var g=land(); if(!g) return null;
       killPlayer('crawler');
       if(!(g.deathBeat>0)) return {skip:'killPlayer opened no death beat'};
       if(press){ raidKey('Digit5',false,null); var K=__keysRef(); K['Digit5']=false; }
       __endRaid('dead');
       return {rifle:P2.weapons.indexOf('rifle')>=0};
     }
     try{
       // THE FINDING: the backpack gun's belt key pressed in the fade.
       var A=die(true);
       if(A===null) return 'SKIP: no live raid';
       if(A.skip) return 'SKIP: '+A.skip;
       if(A.rifle) bad.push('pressing a belt key in the death fade swapped the armoury rifle out of the hand, so the death did not take it');
       // CONTROL: no key, the death takes the rifle.
       var B=die(false);
       if(B&&!B.skip&&B.rifle) bad.push('control: with no key pressed the death did not take the armoury rifle, so this check cannot see the loss');
       // AND: a punch in the fade is refused.
       var g=land();
       if(g){
         killPlayer('crawler'); g.player.meleeAt=undefined;
         if(meleeStrike()) bad.push('F in the death fade still threw a punch');
         __endRaid('dead');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ P2.weapons=keep.w; P2.stash=keep.st; P2.equipped=keep.eq; P2.equippedSec=keep.es; P2.credits=keep.cr; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
