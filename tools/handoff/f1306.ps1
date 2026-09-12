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

# v13.06 CHECK, inserted before the v13.05 entry.
#
# IT ASSERTS THE TRUE THING, WHICH IS THE POINT OF THE BUILD. The removed field claimed
# to protect the gun slot across the freebie kit. What is really true is that taking
# the kit never touches the gun he owns or the one in his hands, because the raid
# ignores both while the kit is on. That is what should have been asserted all along.
#
# AND IT ASSERTS THE FIELD IS GONE, which is the arm that fails on the previous
# fixture. A removal has no behaviour change to control on, and dressing one up would
# be worse than saying so: the honest control for a deletion is that the thing is
# deleted, plus proof that what it pretended to do still holds.
SubRx @'
  {v:'13.05',what:'the Undercroft floor and the raid HUD paint his wording too
'@ @'
  {v:'13.06',what:'taking the freebie kit leaves the gun he owns and the gun in his hands exactly as they were, and no gun-slot field survives the round trip, because that field was written in five places, read in none, and described in two builds as if it did something (found reading the freebie kit for his 2026-09-11 note)',
   run:function(){
     if(!(window.__P&&window.__startRaid&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot start a raid';
     if(typeof commitKit!=='function') return 'SKIP: this build has no kit handoff to drive';
     var bad=[], P2=__P();
     var keep={w:(P2.weapons||[]).slice(),eq:P2.equipped,eq2:P2.equippedSec,free:P2.freeKit,
               kit:(P2.kit||[]).slice(),saved:P2.kitSaved,chosen:P2.kitChosen,hot:P2.hotAssign,
               slot:P2._gunSlot,stash:(P2.stash||[]).slice()};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // A gun he owns and is holding, taken off the table rather than named.
       var gun=null,wk;
       for(wk in WEAPONS) if(WEAPONS[wk]&&wk!=='fists'&&WEAPONS[wk].mag){ gun=wk; break; }
       if(!gun) return 'SKIP: this build has no gun to own';
       P2.weapons=[gun]; P2.equipped=gun; P2.equippedSec='none';
       P2.kit=[]; P2.hotAssign={}; P2.kitSaved=null; P2.kitChosen=0; P2.freeKit=1;
       // A profile saved by an older build can carry the dead field already, which is
       // not this build fault and not what is being asserted. Clear it first, so what
       // is measured is whether anything WRITES it during the round trip.
       try{ delete P2._gunSlot; }catch(_dg){}
       P2.freeKit=0;
       saveProfile();
       // THE REAL BUTTON, not a flag set by hand. The stash freebie button is one of
       // the two places the dead field was written, so driving the flag instead of the
       // button would leave this arm asserting nothing at all on either build.
       if(typeof renderFreeKit==='function'){
         try{ renderFreeKit(); }catch(_rf){}
         var fb=document.querySelector('.fkbtn');
         if(fb&&fb.onclick) fb.onclick();
       }
       if(!P2.freeKit){ P2.freeKit=1; }
       commitKit();
       __startRaid({mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.freeKit) return 'SKIP: the raid did not take the freebie kit, so there is nothing here to protect';
       if(P2.equipped!==gun)
         bad.push('taking the freebie kit changed the gun in his hands from '+gun+' to '+P2.equipped+', when the kit is supposed to be issued gear that leaves his own alone');
       if((P2.weapons||[]).indexOf(gun)<0)
         bad.push('taking the freebie kit took the '+gun+' out of his armoury, and he owns it');
       g.player.downed=false; __endRaid('extract');
       if(P2.equipped!==gun)
         bad.push('coming back from a freebie-kit raid left him holding '+P2.equipped+' rather than the '+gun+' he went up owning');
       if((P2.weapons||[]).indexOf(gun)<0)
         bad.push('coming back from a freebie-kit raid lost the '+gun+' from his armoury');
       // THE FIELD ITSELF. This is the arm that fails on the previous fixture: a
       // deletion has no behaviour to control on, so the control is the deletion.
       if(P2._gunSlot!==undefined)
         bad.push('a gun-slot field is still being written on the profile, and nothing in the game reads it: what he goes up armed with comes from the gun he has equipped, so the field is a claim with nothing behind it and two builds have described it as if it did something');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ P2.weapons=keep.w; P2.equipped=keep.eq; P2.equippedSec=keep.eq2; P2.freeKit=keep.free;
            P2.kit=keep.kit; P2.kitSaved=keep.saved; P2.kitChosen=keep.chosen; P2.hotAssign=keep.hot;
            P2.stash=keep.stash;
            if(keep.slot===undefined){ try{ delete P2._gunSlot; }catch(_d){} } else P2._gunSlot=keep.slot;
            saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.05',what:'the Undercroft floor and the raid HUD paint his wording too
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
