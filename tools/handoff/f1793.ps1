$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'17.93',what:")) { throw "check 17.93 is in the fixture already" }

SubRx @'
  {v:'17.92',what:
'@ @'
  {v:'17.93',what:'player 2 picks a character: the second window takes a numbered save that is never the one player 1 has open, the old hidden player 2 save moves into a free slot once, the pick is stable, and the saves list knows which save the other window holds',
   run:function(){
     if(typeof p2SlotPick!=='function'||typeof slotBlocked!=='function') return 'player 2 plays one hidden save';
     var bad=[], L=localStorage, p1=p1SlotNow(), ptr0=null, old0=null, k, k2, made=[], same0=NET.same, i;
     try{ ptr0=L.getItem(p2PtrKey()); old0=L.getItem('salvagerun:profile:p2'); }catch(_r){}
     try{
       L.removeItem(p2PtrKey()); L.setItem('salvagerun:profile:p2',JSON.stringify({pname:'KID',credits:5,xp:1,runs:2}));
       for(i=1;i<=8;i++) if(!slotHas(String(i))) made.push(String(i));
       k=p2SlotPick();
       if(k===p1) bad.push('player 2 was given the save player 1 has open ('+k+')');
       if(!/^[1-8]$/.test(k)) bad.push('player 2 was given '+k);
       else{
         if(String(L.getItem(slotKeyOf(k))||'').indexOf('KID')<0) bad.push('the old hidden save did not move into slot '+k);
         if(L.getItem('salvagerun:profile:p2')) bad.push('the old hidden save was left behind');
         if(L.getItem(p2PtrKey())!==k) bad.push('the player 2 pointer reads '+L.getItem(p2PtrKey())+', not '+k);
         k2=p2SlotPick(); if(k2!==k) bad.push('the pick moved from '+k+' to '+k2);
         L.setItem(p2PtrKey(),p1); k2=p2SlotPick(); if(k2===p1) bad.push('a pointer at player 1 save was followed');
         NET.same='host'; L.setItem(p2PtrKey(),k); if(!slotBlocked(k)) bad.push('the host list does not know player 2 holds slot '+k);
         if(slotBlocked(p1)) bad.push('the host list blocks its own slot');
         NET.same=null; if(slotBlocked(k)) bad.push('with no pair the list still blocks slot '+k);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       NET.same=same0;
       try{ for(i=0;i<made.length;i++){ if(L.getItem(slotKeyOf(made[i]))&&String(L.getItem(slotKeyOf(made[i]))).indexOf('KID')>=0) L.removeItem(slotKeyOf(made[i])); } }catch(_c1){}
       try{ if(ptr0===null) L.removeItem(p2PtrKey()); else L.setItem(p2PtrKey(),ptr0); if(old0===null) L.removeItem('salvagerun:profile:p2'); else L.setItem('salvagerun:profile:p2',old0); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
