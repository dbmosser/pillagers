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

# v11.95 CHECK, inserted before the v11.94 entry. On the stash screen with a
# pistol on the figure and an SMG in the rack, the SMG rack cell must be a
# drag source, and its drop on belt key 4 through the real drop handler must
# move it out of the armoury into the stash, pack it and bind the key; the
# figure pistol dropped on key 6 must take the key and stay on the figure.
SubRx @'
  {v:'11.94',what:'the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, and the self-revive says one per raid (his three wording notes of 2026-09-06)',
'@ @'
  {v:'11.95',what:'an armoury gun drags like an item: dropped on a belt key it leaves the rack for the stash, is packed and bound, and a gun on the figure takes the key alone (his order of 2026-09-06)',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__showScreen)) return 'SKIP: this fixture cannot enter the floor';
     if(typeof planPut!=='function'||typeof renderHub!=='function') return 'SKIP: no belt plan in this build';
     var bad=[], P2=__P(), keep={weapons:(P2.weapons||[]).slice(),equipped:P2.equipped,equippedSec:P2.equippedSec,stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:P2.hotAssign,tab:P2.stashTab};
     try{
       __topClear(); __runPrep(); __cleanProfile();
       G=null; __showScreen('hub'); __hubEnter();
       P2.weapons=['pistol','smg']; P2.equipped='pistol'; P2.equippedSec='none'; P2.stash=['bandage']; P2.kit=[]; P2.hotAssign={}; P2.stashTab='gun'; saveProfile();
       renderHub();
       var cell=null, cells=document.querySelectorAll('.cell'), i;
       for(i=0;i<cells.length;i++){ if((cells[i].title||'').indexOf(WEAPONS.smg.name)===0&&/Yours/.test(cells[i].title||'')){ cell=cells[i]; break; } }
       if(!cell) bad.push('control: no rack cell for the SMG');
       else if(cell.style.cursor!=='grab') bad.push('the rack cell for the SMG is not draggable');
       // ONE: the SMG dropped on key 4 leaves the rack, enters the stash, is packed and bound.
       var plan=document.querySelector('#hotplanwrap [data-plan="3"]');
       if(!plan||typeof plan.__grabDrop!=='function') bad.push('control: key 4 on the belt plan is not a drop target');
       else {
         plan.__grabDrop('gun_smg','rack');
         if((P2.hotAssign||{})[3]!=='gun_smg') bad.push('the SMG did not land on key 4 (plan '+JSON.stringify(P2.hotAssign||{})+')');
         if(P2.stash.indexOf('gun_smg')<0) bad.push('the SMG is not in the stash as an item');
         if((P2.kit||[]).indexOf('gun_smg')<0) bad.push('the SMG is not packed');
         if(P2.weapons.indexOf('smg')>=0) bad.push('the SMG is still in the armoury as well');
       }
       // TWO: the pistol on the figure takes key 6 and stays on the figure.
       var plan2=document.querySelector('#hotplanwrap [data-plan="5"]');
       if(!plan2||typeof plan2.__grabDrop!=='function') bad.push('control: key 6 on the belt plan is not a drop target');
       else {
         plan2.__grabDrop('gun_pistol','rack');
         if((P2.hotAssign||{})[5]!=='gun_pistol') bad.push('the figure pistol did not take key 6 (plan '+JSON.stringify(P2.hotAssign||{})+')');
         if(P2.weapons.indexOf('pistol')<0||P2.equipped!=='pistol') bad.push('the figure pistol left the figure');
         if(P2.stash.indexOf('gun_pistol')>=0) bad.push('the figure pistol was copied into the stash');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.weapons=keep.weapons; P2.equipped=keep.equipped; P2.equippedSec=keep.equippedSec; P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot||{}; P2.stashTab=keep.tab; try{ saveProfile(); renderHub(); }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.94',what:'the Crier names itself when its alarm goes out, the Pillbox says destroyed when it dies, and the self-revive says one per raid (his three wording notes of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
