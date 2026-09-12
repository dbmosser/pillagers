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

# CHECK 12.26 WENT RED ON v12.87 AND IT IS RIGHT TO: it asserts the spec he has
# just reversed. It was built to his note of 2026-09-07, that the whole loadout
# did not come back, and his note of 2026-09-11 says it must not come back at all.
# A check that encodes a retired spec is repaired, not obeyed, and the build is not
# reverted for it.
#
# WHAT IT STILL PROVES IS THE HALF THAT DID NOT CHANGE. Steps one and two are the
# valuable part: taking the kit at the stash and then answering FREEBIE KIT again
# at the lift must not destroy the record of what he had packed. That record is
# what the death card is built from to tell him where his gear went, so it matters
# more now, not less. Only the three assertions about what comes BACK are rewritten.
SubRx @'
  {v:'12.26',what:'taking the freebie kit at the stash and then confirming FREEBIE KIT at the lift keeps the packing kept aside, and a run that ends dead gives it back (his note of 2026-09-07: the whole loadout did not come back)',
'@ @'
  {v:'12.26',what:'taking the freebie kit at the stash and then confirming FREEBIE KIT at the lift keeps the record of what he had packed, and a run that ends dead leaves that gear in his stash with an empty backpack and belt and a card that says so (his note of 2026-09-07 built it, his note of 2026-09-11 reversed what comes back)',
'@

SubRx @'
       var kit=(P2.kit||[]).slice().sort().join(',');
       if(kit!=='decoy,smoke,wire') bad.push('after the death the backpack holds ['+kit+'], not the three items packed before the freebie kit');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');
       if(txt.indexOf('have been restored')<0) bad.push('the card does not say the loadout was restored');
'@ @'
       // v12.87, HIS NOTE 2026-09-11: the loadout does NOT come back. It stays in
       // the stash and he arrives with an empty backpack and belt. The record the
       // steps above protect is what the card is built from to tell him where his
       // gear went, so it matters more now rather than less.
       var kit=(P2.kit||[]).slice().sort().join(',');
       if(kit!=='') bad.push('after the death the backpack holds ['+kit+'] rather than nothing, so he reaches the Undercroft already packed');
       var _nk=0,_hk; for(_hk in (P2.hotAssign||{})) if(P2.hotAssign[_hk]) _nk++;
       if(_nk) bad.push('after the death '+_nk+' tactical belt key'+(_nk===1?'':'s')+' is still bound, so the belt he went up with came back down with him');
       var _in=0,_wn,_want=['smoke','decoy','wire'];
       for(_wn=0;_wn<_want.length;_wn++) if((P2.stash||[]).indexOf(_want[_wn])>=0) _in++;
       if(_in!==3) bad.push('the three items he had packed before the freebie kit are not in his stash after the death: '+_in+' of 3 are there');
       var txt=''; try{ txt=((document.getElementById('outcome')||{}).innerText||'').replace(/\s+/g,' '); }catch(_t){}
       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');
       if(txt.indexOf('in your stash')<0) bad.push('the card does not tell him where the gear he had packed before the freebie kit went');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
