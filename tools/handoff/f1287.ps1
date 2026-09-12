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

# v12.87 CHECK, inserted before the v12.86 entry.
#
# IT RUNS A REAL RAID AND ENDS IT, TWICE, because the rule is about what he finds
# when he gets back down and the only honest way to read that is to go up and
# come back. Once dead, once abandoned; extracting is a separate contract and is
# not touched here.
#
# THE SETUP IS WHAT THE STASH BUTTON ACTUALLY LEAVES: his own packing kept aside
# and the loadout emptied. Both arms fail on v12.86, where the loadout comes back
# full, and neither can pass by skipping.
#
# v12.82 IS AMENDED IN THE SAME PATCH, not deleted. It asserts that a second
# commit does not wipe what was kept aside, which is still true and still worth
# holding; only its wording claimed the snapshot exists to re-equip him, and it
# now exists so the card can tell him where his gear went.
SubRx @'
  {v:'12.86',what:'every way of replacing the whole profile finishes in one place
'@ @'
  {v:'12.87',what:'you come back down with an empty backpack and belt: dying leaves nothing packed and no belt key bound, and leaves the gear you had before the freebie kit sitting in your stash, and walking out of a raid does the same (HIS NOTE 2026-09-11 and his clarification the same day, which REVERSE the v6.88 and v12.82 restore)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&typeof commitKit==='function'))
       return 'SKIP: this fixture cannot start a raid';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),eq:P2.equipped,free:P2.freeKit,kit:(P2.kit||[]).slice(),
               chosen:P2.kitChosen,stash:(P2.stash||[]).slice(),safe:P2.safe,
               kbf:P2.kitBeforeFree,hbf:P2.hotBeforeFree,gbf:P2.gunBeforeFree,
               hot:P2.hotAssign,gun:P2._gunSlot,saved:P2.kitSaved};
     try{
       var owned=[],k;
       for(k in ITEMS){ if(!ITEMS[k]||ITEMS[k].use==='gun') continue; if(owned.length<2) owned.push(k); else break; }
       if(owned.length<2) return 'SKIP: this build has too few items to pack a loadout';
       // EXACTLY WHAT THE STASH BUTTON LEAVES BEHIND when he takes the freebie
       // kit: the loadout emptied, his own packing kept aside, and the items
       // still sitting in the stash because the freebie kit commits nothing.
       function endWith(how){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         P2.stash=owned.slice(); P2.kit=[]; P2.safe=null; P2.freeKit=1; P2.kitChosen=0;
         P2.hotAssign={}; P2._gunSlot=null;
         P2.kitBeforeFree=null; P2.hotBeforeFree=null; P2.gunBeforeFree=null;
         // Two belt keys bound to those two items, because his rule says the
         // belt is part of the loadout and v12.86 put the plan back as well.
         var h={}; h['0']=owned[0]; h['1']=owned[1];
         P2.kitSaved={kit:owned.slice(),hot:h,gun:null};
         saveProfile();
         if(!commitKit()) return 'SKIP: the kit handoff refused to run on a staged loadout';
         if((P2.kitBeforeFree||[]).length!==2)
           return 'SKIP: the kit handoff did not keep his packing aside, so there is nothing here that could come back';
         __startRaid({mapIx:0,seed:4242});
         var g=__state(); if(g&&g.player) g.player.downed=false;
         __endRaid(how);
         return null;
       }
       var s1=endWith('dead');
       if(s1) return s1;
       if((P2.kit||[]).length)
         bad.push('dying puts '+P2.kit.length+' item'+(P2.kit.length===1?'':'s')+' straight back into his backpack, so he reaches the Undercroft already packed and the raid he just lost costs him nothing to look at');
       var nk=0,kk; for(kk in (P2.hotAssign||{})) if(P2.hotAssign[kk]) nk++;
       if(nk)
         bad.push('dying leaves '+nk+' tactical belt key'+(nk===1?'':'s')+' still bound, so the belt he went up with comes back down with him');
       var back=0,i;
       for(i=0;i<owned.length;i++) if((P2.stash||[]).indexOf(owned[i])>=0) back++;
       if(back!==2)
         bad.push('the gear he had packed before the freebie kit is not in his stash after a death: '+back+' of 2 are there, so it went nowhere rather than back to the stash');
       var s2=endWith('abandon');
       if(s2) return s2;
       if((P2.kit||[]).length)
         bad.push('walking out of a raid puts '+P2.kit.length+' item'+(P2.kit.length===1?'':'s')+' back into his backpack, so abandoning costs him nothing either');
       var nk2=0; for(kk in (P2.hotAssign||{})) if(P2.hotAssign[kk]) nk2++;
       if(nk2)
         bad.push('walking out leaves '+nk2+' tactical belt key'+(nk2===1?'':'s')+' still bound');
       var back2=0;
       for(i=0;i<owned.length;i++) if((P2.stash||[]).indexOf(owned[i])>=0) back2++;
       if(back2!==2)
         bad.push('the gear he had packed is not in his stash after walking out: '+back2+' of 2 are there');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}
       try{ P2.weapons=keep.w; P2.equipped=keep.eq; P2.freeKit=keep.free; P2.kit=keep.kit;
            P2.kitChosen=keep.chosen; P2.stash=keep.stash; P2.safe=keep.safe;
            P2.kitBeforeFree=keep.kbf; P2.hotBeforeFree=keep.hbf; P2.gunBeforeFree=keep.gbf;
            P2.hotAssign=keep.hot; P2._gunSlot=keep.gun; P2.kitSaved=keep.saved; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.86',what:'every way of replacing the whole profile finishes in one place
'@

# v12.82 STILL HOLDS, and its wording is corrected rather than its assertions.
# What it proves is that a second commit does not wipe the snapshot; what the
# snapshot is FOR changed at v12.87, from re-equipping him to telling him where
# his gear went.
SubRx @'
  {v:'12.82',what:'committing the kit twice does not wipe what was kept aside: the items, the tactical belt plan and the gun slot all survive a second commit, so taking the freebie kit at the stash and then going up no longer destroys the death restore, while a commit with nothing kept aside still takes what is in the kit (his v6.88 spec, found again 2026-09-09)',
'@ @'
  {v:'12.82',what:'committing the kit twice does not wipe what was kept aside: the items, the tactical belt plan and the gun slot all survive a second commit, so taking the freebie kit at the stash and then going up still leaves a record of what he had packed, while a commit with nothing kept aside still takes what is in the kit (found 2026-09-09; since v12.87 that record tells him his gear is in the stash rather than putting it back on him)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
