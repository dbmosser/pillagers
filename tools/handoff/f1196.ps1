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

# v11.96 CHECK, inserted before the v11.95 entry. A stack of six Bandages is
# put on key 3 through the real planPut and must pack three with an x3 on the
# plan cell; a single Medkit on key 4 packs one and shows no count; a stack
# he already packed two of keeps its two.
SubRx @'
  {v:'11.95',what:'an armoury gun drags like an item: dropped on a belt key it leaves the rack for the stash, is packed and bound, and a gun on the figure takes the key alone (his order of 2026-09-06)',
'@ @'
  {v:'11.96',what:'a belt key on a stack packs half the stack and the plan cell shows the count; a single item packs one; a count already packed is kept (his order of 2026-09-06)',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__showScreen)) return 'SKIP: this fixture cannot enter the floor';
     if(typeof planPut!=='function'||typeof packedCount!=='function'||typeof renderHub!=='function') return 'SKIP: no belt plan in this build';
     var bad=[], P2=__P(), keep={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),hot:P2.hotAssign,tab:P2.stashTab};
     try{
       __topClear(); __runPrep(); __cleanProfile();
       G=null; __showScreen('hub'); __hubEnter();
       P2.stash=['bandage','bandage','bandage','bandage','bandage','bandage','medkit','plate','plate','plate']; P2.kit=[]; P2.hotAssign={}; P2.stashTab='all'; saveProfile();
       var w1=planPut(2,'bandage'); if(w1) bad.push('key 3 refused the Bandages: '+w1);
       if(packedCount('bandage')!==3) bad.push('a stack of six Bandages on a key packed '+packedCount('bandage')+', not three');
       var w2=planPut(3,'medkit'); if(w2) bad.push('key 4 refused the Medkit: '+w2);
       if(packedCount('medkit')!==1) bad.push('one Medkit on a key packed '+packedCount('medkit'));
       P2.kit.push('plate','plate');   // two plates he packed by hand
       var w3=planPut(4,'plate'); if(w3) bad.push('key 5 refused the plates: '+w3);
       if(packedCount('plate')!==2) bad.push('a stack he had packed two of was changed to '+packedCount('plate'));
       renderHub();
       var c3=document.querySelector('#hotplanwrap [data-plan="2"]'), c4=document.querySelector('#hotplanwrap [data-plan="3"]');
       if(!c3||!c4) bad.push('control: the plan cells did not render');
       else {
         if(!/x3/.test(c3.textContent)) bad.push('key 3 does not show x3 (shows "'+c3.textContent.trim()+'")');
         if(/x1\b/.test(c4.textContent)) bad.push('key 4 shows a count for a single Medkit');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ P2.stash=keep.stash; P2.kit=keep.kit; P2.hotAssign=keep.hot||{}; P2.stashTab=keep.tab; try{ saveProfile(); renderHub(); }catch(_r){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.95',what:'an armoury gun drags like an item: dropped on a belt key it leaves the rack for the stash, is packed and bound, and a gun on the figure takes the key alone (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
