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

# v12.82 CHECK, inserted before the v12.81 entry.
#
# THE FIRST VERSION OF THIS CHECK WAS THROWN AWAY AND THIS IS WHY. It tried to
# prove the restore by taking the kit, deploying, dying and reading the profile,
# and it skipped on every fixture: by the time the death ran there was no stash
# and no kit left to restore, so it never reached the thing it was testing. Three
# repairs did not move it. The defect does not need a raid to show itself, so
# this one never deploys: it stages the snapshot by hand, calls the real handoff
# TWICE, and looks at what survives. Deterministic, and it repeats.
SubRx @'
  {v:'12.81',what:'the downed screen stops offering a surrender it will not take: with an extraction waiting on the point he is lying in, the row says so and the key is refused as it always was, while in every other downed state the prompt is drawn and the hold runs (2026-09-07 audit)',
'@ @'
  {v:'12.82',what:'committing the kit twice does not wipe what was kept aside: the items, the tactical belt plan and the gun slot all survive a second commit, so taking the freebie kit at the stash and then going up no longer destroys the death restore, while a commit with nothing kept aside still takes what is in the kit (his v6.88 spec, found again 2026-09-09)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof commitKit!=='function') return 'SKIP: this build has no kit handoff to drive';
     var bad=[], P2=__P();
     var keep={kit:(P2.kit||[]).slice(),saved:P2.kitSaved,before:P2.kitBeforeFree,
               hotB:P2.hotBeforeFree,gunB:P2.gunBeforeFree,hot:P2.hotAssign,
               gun:P2._gunSlot,free:P2.freeKit,chosen:P2.kitChosen};
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // Two plain items and a gun, taken off the tables rather than named.
       var owned=[], gunId=null, k;
       for(k in ITEMS){ if(!ITEMS[k]||ITEMS[k].use==='gun') continue; if(owned.length<2) owned.push(k); else break; }
       for(k in WEAPONS){ if(WEAPONS[k]&&k!=='fists'&&WEAPONS[k].mag){ gunId=k; break; } }
       if(owned.length<2||!gunId) return 'SKIP: this build has too few items or guns to stage a loadout';
       // EXACTLY WHAT THE STASH BUTTON LEAVES BEHIND when he takes the kit: the
       // kit emptied and all three parts of the loadout kept aside.
       function stage(){
         P2.freeKit=1; P2.kit=[]; P2.kitBeforeFree=null; P2.hotBeforeFree=null; P2.gunBeforeFree=null;
         var h={}; h['0']=owned[0]; h['1']=owned[1];
         P2.kitSaved={kit:owned.slice(),hot:h,gun:gunId};
       }
       stage();
       if(!commitKit()) return 'SKIP: the kit handoff refused to run on a staged snapshot';
       var after1={n:(P2.kitBeforeFree||[]).length,hot:P2.hotBeforeFree?1:0,gun:P2.gunBeforeFree||null};
       if(after1.n!==2) return 'SKIP: the first commit did not keep the items aside ('+after1.n+'), so there is nothing here to lose';
       // THE FINDING: quick ascent commits, and so does the staging path, so a
       // second commit is ordinary play and not a contrived state.
       commitKit();
       var after2={n:(P2.kitBeforeFree||[]).length,hot:P2.hotBeforeFree?1:0,gun:P2.gunBeforeFree||null};
       if(after2.n!==after1.n)
         bad.push('committing the kit a second time threw away the loadout he had kept aside: the item list went from '+after1.n+' to '+after2.n+', and quick ascent commits and so does the staging path, so taking the freebie kit at the stash and then going up left the death restore with nothing at all to give back');
       if(after1.hot&&!after2.hot)
         bad.push('the tactical belt plan kept aside for the restore was thrown away by the second commit');
       if(after1.gun&&after2.gun!==after1.gun)
         bad.push('the gun slot kept aside for the restore was thrown away by the second commit');
       // CONTROL: with nothing kept aside, a commit still takes whatever is in
       // the kit, so the guard has not frozen the handoff for everybody.
       P2.freeKit=1; P2.kitSaved=null; P2.kitBeforeFree=null;
       P2.hotBeforeFree=null; P2.gunBeforeFree=null; P2.kit=owned.slice();
       commitKit();
       if((P2.kitBeforeFree||[]).length!==2)
         bad.push('control: with nothing kept aside a commit no longer takes what is in the kit, so the guard has frozen the handoff rather than protecting it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.kit=keep.kit; P2.kitSaved=keep.saved; P2.kitBeforeFree=keep.before;
            P2.hotBeforeFree=keep.hotB; P2.gunBeforeFree=keep.gunB; P2.hotAssign=keep.hot;
            P2._gunSlot=keep.gun; P2.freeKit=keep.free; P2.kitChosen=keep.chosen; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.81',what:'the downed screen stops offering a surrender it will not take: with an extraction waiting on the point he is lying in, the row says so and the key is refused as it always was, while in every other downed state the prompt is drawn and the hold runs (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
