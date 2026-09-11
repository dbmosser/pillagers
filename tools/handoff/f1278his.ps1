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

# v12.78 CHECK, inserted before the v12.77 entry. It drives the real loot grant
# three times on one raid: two real guns in his hands, the Scav Pistol in his
# hands, and an empty second slot. No death, no clock, nothing timed, so it is
# repeatable. The guns are taken off the weapon table by tier rather than named,
# so renaming one moves the check with it.
SubRx @'
  {v:'12.77',what:'the price of walking out is the price he actually pays: with nothing banked the confirm button quotes no fine and the line afterwards announces none, while a character who has the XP still reads the full price and still pays exactly it (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.78',what:'a gun he chose is not swapped out behind his back: with a real weapon in each hand a better find goes to the backpack and both hands are untouched, while the Scav Pistol is still always booted for something better and an empty second slot still takes it (his note, after a live round)',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof grantLoot!=='function'||typeof WTIER==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: this build has no loot grant to drive';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to pull in';
       if(g.sim) return 'SKIP: this raid is a sim, where the grant does not equip';
       var p=g.player, k, it;
       // The found gun, and two REAL guns to hold, taken off the table by tier so
       // that naming nothing here keeps this honest if a gun is renamed.
       var topK=null, topT=-1, midA=null, midB=null;
       for(k in ITEMS){ it=ITEMS[k];
         if(!it||!it.gk||!WEAPONS[it.gk]) continue;
         var t=(WTIER[it.gk]||0);
         if(t>topT){ topT=t; topK=k; }
       }
       if(!topK) return 'SKIP: this build has no gun items to pull';
       for(k in WEAPONS){ if(k==='fists'||k==='pistol') continue;
         if(!WEAPONS[k]||!WEAPONS[k].mag) continue;
         if((WTIER[k]||0)>=topT) continue;
         if(!midA) midA=k; else if(!midB){ midB=k; break; }
       }
       if(!midA||!midB) return 'SKIP: this build has too few ordinary guns to fill both hands';
       if(!WEAPONS.pistol) return 'SKIP: this build has no Scav Pistol to boot';
       function pull(hand,sec){
         p.wep=WEAPONS[hand]; p.ammo=WEAPONS[hand].mag||0; p.wepIssued=false; p.wepFromArmory=false;
         p.sec=sec?WEAPONS[sec]:WEAPONS.fists; p.secAmmo=sec?(WEAPONS[sec].mag||0):0;
         p.secIssued=false; p.secFromArmory=false;
         g.bag=[]; p.downed=false;
         grantLoot({x:p.x+20,y:p.y+20,c:'#ffffff',loot:[topK]},[topK]);
         return {hand:p.wep&&p.wep.id, sec:p.sec&&p.sec.id, bagged:(g.bag||[]).indexOf(topK)>=0};
       }
       // THE FINDING: a real gun in each hand. Neither may move.
       var A=pull(midA,midB);
       if(A.hand!==midA)
         bad.push('a gun he chose was taken out of his hands by a pickup: he was holding '+midA+' with '+midB+' on his back and the find replaced the one in his hands, mid raid, on nothing more than a tier comparison he was never asked about');
       if(A.sec!==midB)
         bad.push('the pickup took the second slot while a real gun was in it: '+midB+' was replaced without being asked');
       if(!A.bagged)
         bad.push('with both hands full the find did not go to the backpack either, so it is not anywhere he can choose it from');
       // THE SCAV PISTOL IS THE STARTER AND IS ALWAYS BOOTED.
       var B=pull('pistol',midB);
       if(B.hand==='pistol')
         bad.push('the Scav Pistol kept his hands against a better gun, and the starter is meant to be the one thing a find always replaces');
       // CONTROL: an empty second slot still takes it, or this check would pass on
       // a build that had simply stopped equipping anything at all.
       var C=pull(midA,null);
       if(C.sec!==(ITEMS[topK]&&ITEMS[topK].gk))
         bad.push('control: an empty second slot no longer takes a found gun, so pickups equip nothing at all now');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.77',what:'the price of walking out is the price he actually pays: with nothing banked the confirm button quotes no fine and the line afterwards announces none, while a character who has the XP still reads the full price and still pays exactly it (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
