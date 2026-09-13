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

# v13.31 CHECK, inserted before the v13.29 entry (v13.30 was a harness build).
#
# ON THE PLAY PATH: it draws the sector page through renderSector, the same call the
# lift's E act makes, and reads the kit box the player actually sees before the loadout
# question. The first attempt at this build drew the ascent check screen directly,
# which nothing in the game opens, and passed for that reason alone.
SubRx @'
  {v:'13.29',what:'the welcome pack goes to the stash: both guns land there as gun items, nothing is added to the armoury, nothing is equipped for him, and every row in the window says to your stash (his ruling of 2026-09-13)',
'@ @'
  {v:'13.31',what:'the sector page the lift opens tells a player with nothing equipped that he has a gun of his own in his stash and how to take it, Equip as your gun, and only when his stash holds a gun (the pack guns wait there since his ruling)',
   run:function(){
     if(typeof renderSector!=='function') return 'SKIP: this fixture cannot draw the sector page';
     var K=document.getElementById('sectorkit'); if(!K) return 'SKIP: this build has no sector kit box';
     if(!ITEMS.gun_smg||!WEAPONS.smg) return 'SKIP: this build has no stash gun item to stage';
     var bad=[];
     var keep={equipped:P.equipped,equippedSec:P.equippedSec,weapons:(P.weapons||[]).slice(),stash:(P.stash||[]).slice(),kit:(P.kit||[]).slice(),freeKit:P.freeKit};
     var needle=['Equip','as','your','gun'].join(' ');
     function boxText(){ try{ renderSector(); }catch(_s){} return String(K.textContent||''); }
     try{
       // ONE: nothing equipped, and a pack gun waiting in the stash.
       P.freeKit=0; P.equipped='fists'; P.equippedSec='none'; P.weapons=['pistol']; P.kit=[]; P.stash=['gun_smg','bandage'];
       var a=boxText();
       if(!a) return 'SKIP: the sector page drew an empty kit box';
       if(a.indexOf(needle)<0)
         bad.push('a player with nothing equipped and a gun of his own in his stash is told only that he goes up with an issued gun, on the last screen before the lift ['+a.slice(0,140)+']');

       // TWO: nothing equipped and no gun in the stash either.
       P.stash=['bandage'];
       var b=boxText();
       if(b.indexOf(needle)>=0)
         bad.push('a player with no gun in his stash is told to equip one from it, so he goes looking for a gun that is not there');

       // THREE: a gun equipped, with another in the stash. He is not going up with a loaner.
       P.equipped='pistol'; P.stash=['gun_smg'];
       var c=boxText();
       if(c.indexOf(needle)>=0)
         bad.push('a player who already has a gun equipped is told to equip one from his stash');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P.equipped=keep.equipped; P.equippedSec=keep.equippedSec; P.weapons=keep.weapons; P.stash=keep.stash; P.kit=keep.kit; P.freeKit=keep.freeKit; saveProfile(); }catch(_r){}
       try{ renderSector(); }catch(_rs){}
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
