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

# v12.77 CHECK, inserted before the v12.76 entry. It presses the real button,
# runs the real handoff, and kills him for real, because the whole defect lives
# in what one function passes to another. Two controls: a key bound to something
# he no longer owns must still be dropped, which is the rule the item list has
# always followed, and a clean extraction must restore nothing, so the restore
# stays tied to dying rather than firing on every raid.
SubRx @'
  {v:'12.76',what:'how far he died from extraction is measured to the nearest way out and not to the ring the raid nominated, so the death card agrees with the compass he followed all raid and with the closest-approach line printed under it, while a death beside the nominated ring itself still reports exactly what it always did (2026-09-08 first-hour audit, my own half-done fix from v8.58)',
'@ @'
  {v:'12.77',what:'dying with the freebie kit gives back the tactical belt plan and the gun slot along with the items, since all three were kept aside when he took the kit, while a key bound to something he no longer owns is still dropped and a clean extraction still restores nothing (2026-09-08 first-hour audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof commitKit!=='function') return 'SKIP: this build has no kit handoff to drive';
     var fk=document.querySelector('.fkbtn');
     if(!fk) return 'SKIP: this build has no freebie kit button to press';
     var bad=[], P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:P2.hotAssign,gun:P2._gunSlot,free:P2.freeKit,log:(P2.log||[]).slice()};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // Two things he owns and one he does not, so the filter has something to
       // bite on that could not have come from the staging by accident.
       var owned=[], notOwned=null, k;
       for(k in ITEMS){ if(!ITEMS[k]||ITEMS[k].use==='gun') continue;
         if(owned.length<2) owned.push(k); else { notOwned=k; break; } }
       if(owned.length<2||!notOwned) return 'SKIP: this build has too few plain items to stage a belt plan';
       var gunId=null;
       for(k in WEAPONS){ if(WEAPONS[k]&&k!=='fists'&&WEAPONS[k].mag){ gunId=k; break; } }
       function stage(planSecond){
         P2.freeKit=0;
         P2.stash=owned.slice();
         P2.kit=owned.slice();
         P2.hotAssign={}; P2.hotAssign['0']=owned[0]; P2.hotAssign['1']=planSecond;
         P2._gunSlot=gunId;
         saveProfile();
         try{ fk.onclick(); }catch(_c){ return 'the freebie kit button threw'; }
         if(!P2.freeKit) return 'the freebie kit button did not take the kit';
         if(!commitKit()) return 'the kit handoff refused to run';
         return null;
       }
       function dieAndRead(){
         __deploy({kit:[],mapIx:0,seed:4242});
         var g=__state(); if(!g||!g.player) return null;
         g.player.downed=false; g.player.hp=1;
         __endRaid('dead');
         return {hot:P2.hotAssign||{}, gun:P2._gunSlot||null, kit:(P2.kit||[]).slice()};
       }
       // THE FINDING: everything he had bound comes back with the items.
       var e1=stage(owned[1]);
       if(e1) return 'SKIP: '+e1;
       if(P2.hotAssign&&P2.hotAssign['0']) return 'SKIP: taking the kit did not clear the belt plan, so there is nothing here to lose';
       var r1=dieAndRead();
       if(!r1) return 'SKIP: no raid to die in';
       if(r1.kit.length<2) return 'SKIP: the items themselves did not come back, so this build restores nothing at all';
       if(r1.hot['0']!==owned[0]||r1.hot['1']!==owned[1])
         bad.push('he bound two tactical belt keys, took the freebie kit and died, and the game told him his loadout had been restored: the items came back and the keys did not, so a first-time player who used the gesture the game teaches him gets his gear back in a backpack with every key he had set now blank and nothing saying so');
       if(gunId&&r1.gun!==gunId)
         bad.push('the gun slot he had chosen before taking the kit did not come back either, and it was kept aside at the same moment the items were');
       // CONTROL ONE: a key pointing at something he no longer owns is a dead
       // key, and the item list has always dropped those.
       var e2=stage(notOwned);
       if(e2) return 'SKIP: '+e2;
       var r2=dieAndRead();
       if(r2&&r2.hot&&r2.hot['1']===notOwned)
         bad.push('control: a belt key bound to something he does not own came back anyway, so the plan now points at an item he is not carrying');
       // CONTROL TWO: walking out is not a death, and restores nothing.
       var e3=stage(owned[1]);
       if(e3) return 'SKIP: '+e3;
       __deploy({kit:[],mapIx:0,seed:4242});
       var g3=__state(); if(g3&&g3.player){ g3.player.downed=false; g3.player.hp=100; __endRaid('extract'); }
       if(P2.hotAssign&&P2.hotAssign['0']===owned[0])
         bad.push('control: a clean extraction put the pre-kit belt plan back as well, so the restore is firing on every raid rather than on the death it was written for');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot; P2._gunSlot=keep.gun;
            P2.freeKit=keep.free; P2.log=keep.log; P2.kitSaved=null; P2.kitBeforeFree=null; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.76',what:'how far he died from extraction is measured to the nearest way out and not to the ring the raid nominated, so the death card agrees with the compass he followed all raid and with the closest-approach line printed under it, while a death beside the nominated ring itself still reports exactly what it always did (2026-09-08 first-hour audit, my own half-done fix from v8.58)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
