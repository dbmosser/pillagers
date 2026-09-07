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

# v12.26 CHECK, inserted before the v12.25 entry. The freebie kit is taken at
# the stash through the real button, the lift question is opened and answered
# FREEBIE KIT for real (ascendNow stood in for by commitKit alone, so the raid
# can be started the way check 12.03 starts it), and the list kept for the
# restore must still be the three items packed; then the raid ends dead and
# the backpack must hold them again, with the card saying so.
SubRx @'
  {v:'12.25',what:'the corner credits and XP readout and the floor answer line carry the window zoom: at 4K and 1440p they follow the monitor and the Text size setting like every window, and at 1080p the readout still clears the stash top row and the raid CONDITIONS box (his note of 2026-09-07)',
'@ @'
  {v:'12.26',what:'taking the freebie kit at the stash and then confirming FREEBIE KIT at the lift keeps the packing kept aside, and a run that ends dead gives it back (his note of 2026-09-07: the whole loadout did not come back)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot start a raid';
     if(typeof askKit!=='function'||typeof commitKit!=='function'||typeof renderFreeKit!=='function'||typeof ascendNow!=='function') return 'SKIP: this fixture cannot reach the lift question';
     var bad=[], P2=__P();
     var keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P2.hotAssign||{})),freeKit:P2.freeKit,kitSaved:P2.kitSaved,kbf:P2.kitBeforeFree,chosen:P2.kitChosen,drop:(P2.dropKit||[]).slice(),weapons:(P2.weapons||[]).slice(),eq:P2.equipped,safe:P2.safe,gun:P2._gunSlot};
     var _asc=ascendNow, alt=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       keys={}; __showScreen('hub'); __hubEnter();
       // DISTINCTIVE: three items no fallback packs together, one of them on a key.
       P2.stash=['smoke','decoy','wire','medkit','bandage']; P2.kit=['smoke','decoy','wire']; P2.hotAssign={3:'smoke'}; P2.safe=null;
       P2.freeKit=0; P2.kitSaved=null; P2.kitBeforeFree=null; P2.kitChosen=0; P2.weapons=['pistol']; P2.equipped='fists'; saveProfile();
       // STEP ONE: the stash button takes the freebie kit, for real.
       renderFreeKit(); var fb=document.querySelector('.fkbtn');
       if(!fb||!fb.onclick) return 'SKIP: the freebie kit button was not drawn';
       fb.onclick();
       if(!P2.freeKit) bad.push('staging: the stash button did not take the kit');
       if(!(P2.kitSaved&&P2.kitSaved.kit&&P2.kitSaved.kit.length===3)) bad.push('staging: the stash button did not keep the three items aside');
       // STEP TWO: the lift asks, and he answers FREEBIE KIT again.
       askKit(); alt=ASKALT;
       if(typeof alt!=='function') return 'SKIP: the lift question offers no FREEBIE KIT answer';
       ascendNow=function(){ commitKit(); };
       alt();
       ascendNow=_asc;
       // THE FINDING: on v12.25 the answer re-snapshotted the emptied kit, so nothing was kept.
       var kb=(P2.kitBeforeFree||[]).slice().sort().join(',');
       if(kb!=='decoy,smoke,wire') bad.push('after FREEBIE KIT at the lift the packing kept for the restore is ['+kb+'], not the three items packed at the stash');
       // THE RUN ENDS DEAD: the real restore path.
       __startRaid({mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.freeKit) bad.push('control: the raid did not take the free kit');
       if(g){ g.player.downed=false; __endRaid('dead'); }
       var kit=(P2.kit||[]).slice().sort().join(',');
       if(kit!=='decoy,smoke,wire') bad.push('after the death the backpack holds ['+kit+'], not the three items packed before the freebie kit');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');
       if(txt.indexOf('have been restored')<0) bad.push('the card does not say the loadout was restored');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       ascendNow=_asc;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}
       P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot; P2.freeKit=keep.freeKit; P2.kitSaved=keep.kitSaved; P2.kitBeforeFree=keep.kbf; P2.kitChosen=keep.chosen; P2.dropKit=keep.drop; P2.weapons=keep.weapons; P2.equipped=keep.eq; P2.safe=keep.safe; P2._gunSlot=keep.gun;
       try{ saveProfile(); }catch(_s){} try{ renderFreeKit(); }catch(_rf){}
       try{ var am=document.getElementById('askmodal'); if(am) am.classList.remove('on'); }catch(_am){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.25',what:'the corner credits and XP readout and the floor answer line carry the window zoom: at 4K and 1440p they follow the monitor and the Text size setting like every window, and at 1080p the readout still clears the stash top row and the raid CONDITIONS box (his note of 2026-09-07)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
