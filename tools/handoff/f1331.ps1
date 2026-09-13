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

# v13.31 CHECK, inserted before the v13.29 entry (v13.30 was a harness build with no
# check of its own).
#
# IT DRAWS THE REAL ASCENT SCREEN through renderStage and reads the warning it wrote,
# for a player with no gun equipped: once with a gun in his stash, where the line must
# name Equip as your gun, and once with none, where naming it would send him looking
# for a gun that is not there. The profile fields it sets are put back in finally.
SubRx @'
  {v:'13.29',what:'the welcome pack goes to the stash: both guns land there as gun items, nothing is added to the armoury, nothing is equipped for him, and every row in the window says to your stash (his ruling of 2026-09-13)',
'@ @'
  {v:'13.31',what:'the ascent screen tells a player going up with no gun of his own how to take one from his stash, Equip as your gun, and only when his stash holds a gun (the pack guns wait there since his ruling)',
   run:function(){
     if(typeof renderStage!=='function') return 'SKIP: this fixture cannot draw the ascent screen';
     var W=document.getElementById('stagewarn'); if(!W) return 'SKIP: this build has no ascent warning';
     if(!ITEMS.gun_smg||!WEAPONS.smg) return 'SKIP: this build has no stash gun item to stage';
     var bad=[];
     var keep={equipped:P.equipped,equippedSec:P.equippedSec,weapons:(P.weapons||[]).slice(),stash:(P.stash||[]).slice(),kit:(P.kit||[]).slice(),freeKit:P.freeKit};
     function warnText(){ try{ renderStage(); }catch(_s){} return (W.style.display==='none')?'':String(W.textContent||''); }
     try{
       // ONE: no gun equipped, and a pack gun waiting in the stash.
       P.freeKit=0; P.equipped='fists'; P.equippedSec='none'; P.weapons=['pistol']; P.kit=[]; P.stash=['gun_smg','bandage'];
       var a=warnText();
       if(!a) return 'SKIP: the ascent screen drew no warning for a player with no gun equipped';
       if(a.indexOf('Equip as your gun')<0)
         bad.push('a player going up with no gun of his own, with a gun waiting in his stash, is not told how to take it: the obvious click packs it as loot and a loaner goes in his hands ['+a+']');

       // TWO: no gun equipped and no gun in the stash either.
       P.stash=['bandage'];
       var b=warnText();
       if(b.indexOf('Equip as your gun')>=0)
         bad.push('a player with no gun anywhere in his stash is told to equip one from it, so he goes looking for a gun that is not there');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P.equipped=keep.equipped; P.equippedSec=keep.equippedSec; P.weapons=keep.weapons; P.stash=keep.stash; P.kit=keep.kit; P.freeKit=keep.freeKit; saveProfile(); }catch(_r){}
       try{ var sm=document.getElementById('stagemodal'); if(sm) sm.classList.remove('on'); }catch(_m){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.29',what:'the welcome pack goes to the stash: both guns land there as gun items, nothing is added to the armoury, nothing is equipped for him, and every row in the window says to your stash (his ruling of 2026-09-13)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
