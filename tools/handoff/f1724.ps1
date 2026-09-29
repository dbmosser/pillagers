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

if ($s.Contains("  {v:'17.24',what:")) { throw "check 17.24 is in the fixture already" }

SubRx @'
  {v:'17.23',what:
'@ @'
  {v:'17.24',what:'with the game open in two tabs on one save, a tab whose save the other tab has written since stops saving and shows a card with RELOAD, so its old copy never wipes what the other tab banked',
   run:function(){
     if(typeof saveProfile!=='function'||typeof SKEY!=='string'||typeof StorageEvent!=='function') return 'SKIP: this build has no save key to test';
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     var raw0=null, other=null, otherStr='', got=null, bad=[], st0=(typeof SAVE_STALE!=='undefined')?SAVE_STALE:null, card;
     try{
       raw0=localStorage.getItem(SKEY);
       // CONTROL: this tab saves as ever while nobody else has written the save.
       saveProfile();
       got=localStorage.getItem(SKEY);
       try{ got=JSON.parse(got); }catch(e){ got=null; }
       if(!got||got.credits!==P.credits) return 'SKIP: staging: a save from this tab did not reach the save key';
       // The other tab extracts with a haul and saves it: credits no run of this tab could bank.
       other=JSON.parse(JSON.stringify(P)); other.credits=(P.credits||0)+777331; other.runs=(P.runs||0)+1;
       otherStr=JSON.stringify(other);
       localStorage.setItem(SKEY,otherStr);
       window.dispatchEvent(new StorageEvent('storage',{key:SKEY,oldValue:raw0,newValue:otherStr,storageArea:localStorage}));
       // This tab, still holding the old copy, closes its backpack: a save.
       saveProfile();
       if(localStorage.getItem(SKEY)!==otherStr) bad.push('after another tab saved a haul, a save from this tab wrote its old copy over the key and the haul was gone');
       card=document.getElementById('stalesave');
       if(!card) bad.push('nothing told the player the save was changed in another tab');
       else if(!card.querySelector('button')) bad.push('the card saying the save was changed in another tab has no RELOAD button');
     } finally {
       try{ card=document.getElementById('stalesave'); if(card&&card.parentNode) card.parentNode.removeChild(card); }catch(e){}
       if(st0!==null) SAVE_STALE=st0;
       try{ if(raw0===null) localStorage.removeItem(SKEY); else localStorage.setItem(SKEY,raw0); }catch(e){}
       try{ saveProfile(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
