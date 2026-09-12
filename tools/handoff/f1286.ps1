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

# v12.86 CHECK, inserted before the v12.85 entry.
#
# THE ARM THAT FAILS ON v12.85 is the UNDO press. There the handler reloads on a
# bare timer: nothing records that a reload is coming and nothing can call it off.
# Here it arms the v11.04 handles, so the check reads RESTORE_RELOAD, cancels the
# timer and puts the flag back, and the page stays where it is.
#
# IT DOES NOT TRY TO DRIVE THE FILE PICKER. A script may not put a file into a
# file input, so the path the audit complained about cannot be pressed from here.
# What CAN be asserted is the thing that makes it correct: that there is one place
# a restore finishes, that all three paths end in it, and that it arms the reload.
SubRx @'
  {v:'12.85',what:'restoring a backup can be undone
'@ @'
  {v:'12.86',what:'every way of replacing the whole profile finishes in one place and arms the same reload the v11.04 restore-code path uses: it is armed rather than fired and leaves a handle that can cancel it, and pressing UNDO arms it too instead of reloading on a timer nothing can see (audit finding 2, 2026-09-11, widened)',
   run:function(){
     if(typeof renderSettings!=='function') return 'SKIP: this fixture cannot render the Settings rows';
     if(typeof RESTORE_RELOAD==='undefined') return 'SKIP: this fixture has no restore-reload flag to read';
     var KEY='salvagerun:profile'+':prerestore', bad=[];
     var keepPre=null;
     try{ keepPre=localStorage.getItem(KEY); }catch(_k){ return 'SKIP: this fixture cannot read storage'; }
     try{
       __topClear();
       // ONE PLACE A RESTORE FINISHES. Boot re-applies five things once the
       // profile exists: the saved zoom, the stash layout, the game options, the
       // menu zoom and the contracts. A restore runs none of them, so the floor
       // stays drawn from the profile that is gone unless the page comes back.
       if(typeof finishRestore!=='function'){
         bad.push('a restore ends its own way in each of the three places that do one, and none of them re-applies what boot applies once the profile exists, so the stash grid, the saved zoom, the game options and the contracts all still belong to the profile he just replaced');
       } else {
         RESTORE_RELOAD=0; RESTORE_TIMER=null;
         finishRestore('Test.');
         if(RESTORE_RELOAD!==1)
           bad.push('finishing a restore left the reload flag at '+RESTORE_RELOAD+' rather than armed, so either nothing is coming or it has already gone');
         if(RESTORE_TIMER===null||typeof RESTORE_TIMER==='undefined')
           bad.push('the reload is coming with no handle to call it off, so anything driving a restore has to let the page go');
         try{ clearTimeout(RESTORE_TIMER); }catch(_c1){}
         RESTORE_TIMER=null; RESTORE_RELOAD=0;
       }
       // THE SAME ARMING FROM THE BUTTON.
       try{ localStorage.setItem(KEY,JSON.stringify({credits:777,runs:3,xp:0,stash:[],weapons:[],kit:[]})); }catch(_w){}
       renderSettings();
       var btn=document.getElementById('set_unrestore');
       if(!btn){
         bad.push('control: the Settings row offers no way back at all, so this build is older than the undo itself');
       } else {
         RESTORE_RELOAD=0; RESTORE_TIMER=null;
         try{ btn.onclick(); }catch(_p){ bad.push('pressing UNDO threw: '+(_p&&_p.message||_p)); }
         var armed=RESTORE_RELOAD;
         try{ clearTimeout(RESTORE_TIMER); }catch(_c2){}
         RESTORE_TIMER=null; RESTORE_RELOAD=0;
         if(armed!==1)
           bad.push('pressing UNDO reloads the page on a timer nothing records and nothing can cancel: the flag stayed at '+armed+', so a harness driving it has no way to stop the page going');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearTimeout(RESTORE_TIMER); }catch(_f0){}
       try{ RESTORE_TIMER=null; RESTORE_RELOAD=0; }catch(_f1){}
       try{ if(keepPre===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY,keepPre); }catch(_f2){}
       try{ renderSettings(); }catch(_f3){}
       try{ __topClear(); }catch(_f4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.85',what:'restoring a backup can be undone
'@

# v12.85 now arms the shared flag through the stub, so it is put back rather than
# left reading that a restore is under way when none is.
SubRx @'
     finally{
       window.setTimeout=oST;
       try{ if(keepPre===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY,keepPre); }catch(_f){}
'@ @'
     finally{
       window.setTimeout=oST;
       // v12.86: the press now arms the shared reload flag, and the stub above
       // swallowed its timer, so the flag is put back rather than left telling
       // the next check that a restore is under way.
       try{ if(typeof RESTORE_RELOAD!=='undefined'){ RESTORE_RELOAD=0; RESTORE_TIMER=null; } }catch(_fr){}
       try{ if(keepPre===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY,keepPre); }catch(_f){}
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
