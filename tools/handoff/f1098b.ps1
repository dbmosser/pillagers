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

# ==== MY OWN CHECK RELOADED THE PAGE AND SWITCHED HIS SAVE SLOT. Pressing every
# ==== button on the character screen includes NEW PILLAGER, which writes a new
# ==== active slot to storage and reloads the tab. It killed the corpus run
# ==== mid-flight and left the pointer on slot 4.
# ==== A check may press a button that ends a raid. It may not press one that
# ==== navigates, and it may not write to the slot pointer at all, because that
# ==== pointer decides which save boots and it is the one key in this game that
# ==== has never been allowed to move. Both are named and skipped, the pointer is
# ==== put back whatever happens, and a control requires the skip list to have
# ==== actually found them.
SubRx @'
       var btns=ti.querySelectorAll('button'), pressed=0;
       for(var i=0;i<btns.length;i++){
         var b=btns[i], id=b.id||'';
         if(id==='titlestart'||id==='titlefs') continue;      // one leaves the screen, one needs a real gesture
         if(b.getAttribute('data-del')) continue;             // arms a deletion
         if(id==='delgo') continue;                           // erases a save
         try{ b.click(); pressed++; }catch(e){ bad.push('pressing '+(id||'a button')+' on the character screen threw: '+e.message); }
       }
'@ @'
       // SKIP:  titlestart leaves the screen, titlefs needs a real user gesture,
       //        DELETE arms an erase, delgo performs it, and NEW PILLAGER writes
       //        the active slot pointer and RELOADS THE TAB.
       var SKIP={titlestart:1,titlefs:1,delgo:1,newgame:1};
       var btns=ti.querySelectorAll('button'), pressed=0, found={};
       for(var i=0;i<btns.length;i++){
         var b=btns[i], id=b.id||'';
         if(SKIP[id]){ found[id]=1; continue; }
         if(b.getAttribute('data-del')) continue;             // arms a deletion
         try{ b.click(); pressed++; }catch(e){ bad.push('pressing '+(id||'a button')+' on the character screen threw: '+e.message); }
       }
       // CONTROL: the two dangerous ones have to have been on the screen and
       // skipped. If the ids ever change, this check would start pressing them.
       if(!found.newgame) bad.push('control: the new pillager button was not found by the name this check skips it under, so it may have been pressed');
       if(!found.titlestart) bad.push('control: the start button was not found by the name this check skips it under');
'@
# ---- and the slot pointer is put back no matter what happened above
SubRx @'
     var keepName=prof.pname, keepRuns=prof.runs, wasOn=ti.classList.contains('on');
'@ @'
     var keepName=prof.pname, keepRuns=prof.runs, wasOn=ti.classList.contains('on');
     // THE ONE KEY THAT MAY NOT MOVE. It decides which save boots, and a check
     // that leaves it pointing somewhere else has changed his character.
     var keepSlot=null; try{ keepSlot=localStorage.getItem('salvagerun:activeSlot'); }catch(_ls){}
'@
SubRx @'
       window.removeEventListener('error',onErr);
       prof.pname=keepName; prof.runs=keepRuns;
'@ @'
       window.removeEventListener('error',onErr);
       try{ if(keepSlot===null) localStorage.removeItem('salvagerun:activeSlot');
            else localStorage.setItem('salvagerun:activeSlot',keepSlot); }catch(_ls2){}
       prof.pname=keepName; prof.runs=keepRuns;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
