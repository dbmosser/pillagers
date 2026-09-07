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

# v12.27 CHECK, inserted before the v12.26 entry. On the stash screen a key is
# left on Bandage from the last raid with none packed and three in the stash;
# the plan cell must say 0; a pointer drop of a Bandage from the stash onto the
# backpack column (the real dropzone handler) must leave a visible count, name
# the key and show the x-count; the same drop with no key bound must still
# pack one copy (control); and in a raid a spent Bandage key must say so.
SubRx @'
  {v:'12.26',what:'taking the freebie kit at the stash and then confirming FREEBIE KIT at the lift keeps the packing kept aside, and a run that ends dead gives it back (his note of 2026-09-07: the whole loadout did not come back)',
'@ @'
  {v:'12.27',what:'a stash drop onto the backpack for an item bound to a key with nothing packed lands on that key with a count and words, a bound key with nothing packed shows a 0 on the plan, and a spent belt key in a raid says No Bandage left (his note of 2026-09-07: bandages did not come over)',
   run:function(){
     if(!(window.__P&&window.__hubEnter&&window.__showScreen&&window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot reach the stash screen and a raid';
     if(typeof renderHub!=='function'||typeof packedCount!=='function'||typeof useHot!=='function'||typeof hotbarSlots!=='function') return 'SKIP: this build has no belt plan to measure';
     var bad=[], P2=__P(), keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:JSON.parse(JSON.stringify(P2.hotAssign||{})),freeKit:P2.freeKit};
     function zeroOn(cell){ var sp=cell.querySelectorAll('span'), i; for(i=0;i<sp.length;i++) if((sp[i].textContent||'').trim()==='0') return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       keys={}; __showScreen('hub'); __hubEnter();
       // A key left on Bandage by the last raid (dropDeadKeys keeps it while the stash has one), nothing packed, three in the stash.
       P2.stash=['bandage','bandage','bandage','wire']; P2.kit=[]; P2.hotAssign={2:'bandage'}; P2.freeKit=0; saveProfile();
       renderHub();
       var hub=document.getElementById('hub'); if(hub) hub.classList.add('on');
       // (B) the plan cell for key 3 says 0.
       var cell=document.querySelector('#hub [data-plan="2"]');
       if(!cell) bad.push('staging: no plan cell for key 3 on the stash screen');
       else if(!zeroOn(cell)) bad.push('the plan cell for key 3, set to Bandage with none packed, shows no 0');
       // (A) the drop, through the real pointer dropzone handler.
       var col=document.getElementById('kitcol');
       if(!col||typeof col.__grabDrop!=='function') return 'SKIP: the backpack column takes no pointer drop';
       HUBSAY=''; col.__grabDrop('bandage','stash');
       var nb=packedCount('bandage'), kn=document.getElementById('kitn'), shown=kn?parseInt(kn.textContent,10):-1;
       if(nb<1) bad.push('the drop packed nothing');
       if(!(shown>0)) bad.push('after the drop the backpack column shows '+shown+' items: the Bandage vanished into the key');
       if(!/key 3/.test(HUBSAY||'')) bad.push('the drop said "'+(HUBSAY||'')+'" and not which key took it');
       var c2=document.querySelector('#hub [data-plan="2"]');
       if(c2&&nb>1&&(c2.textContent||'').indexOf('x'+nb)<0) bad.push('the plan cell does not show x'+nb+' after the drop (it reads "'+(c2.textContent||'').trim()+'")');
       // CONTROL: the same drop with no key bound packs one copy, as it always has.
       P2.kit=[]; P2.hotAssign={}; saveProfile(); renderHub(); col.__grabDrop('wire','stash');
       if(packedCount('wire')!==1) bad.push('control: a drop with no key bound packed '+packedCount('wire')+' copies, not one');
       if(hub) hub.classList.remove('on');
       // (C) in a raid, a key on a Bandage with none in the bag says so.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       g.hotAssign={2:'bandage'}; g.hotAuto={}; g.bag=[]; g.msg=''; g.hot=2;
       var sl=hotbarSlots(), s2=sl[2];
       if(!(s2&&s2.assigned&&s2.itemKey==='bandage')) bad.push('staging: belt cell 3 is not the assigned Bandage cell (kind '+(s2&&s2.kind)+')');
       useHot();
       if(!/No Bandage left/.test(g.msg||'')) bad.push('a spent Bandage key said "'+(g.msg||'')+'", not No Bandage left');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot; P2.freeKit=keep.freeKit;
       try{ saveProfile(); }catch(_s){}
       try{ var hb2=document.getElementById('hub'); if(hb2) hb2.classList.remove('on'); }catch(_h){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.26',what:'taking the freebie kit at the stash and then confirming FREEBIE KIT at the lift keeps the packing kept aside, and a run that ends dead gives it back (his note of 2026-09-07: the whole loadout did not come back)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
