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

# v12.85 CHECK, inserted before the v12.84 entry.
#
# IT MUST NOT LET THE PAGE RELOAD. The handler under test ends with a timed
# location.reload, which is right for a player and fatal here: a reload mid
# corpus throws away the run and every result after this row. window.setTimeout
# is swallowed for the length of the press and put straight back, so the reload
# is scheduled onto a timer that never fires.
#
# IT MUST NOT LEAVE HIS SAVE BEHIND EITHER. The whole point of the handler is
# that it writes the stored profile, so both keys are read before and written
# back in a finally, whatever happens in between.
#
# THE ARM THAT FAILS ON v12.84 is the button existing at all when there is
# something to go back to. On the previous build the row renders one button and
# getElementById returns nothing, which is the defect stated as a test.
SubRx @'
  {v:'12.84',what:'equipping a gun from the backpack says what became of the gun it replaced: an issued loaner says it was left behind and a gun he owns says it went back to the armoury, both surviving the line about what he is now holding, while equipping over an empty hand says exactly what it always said (found by tools/lint.ps1, the v12.73 class in a second place)',
'@ @'
  {v:'12.85',what:'restoring a backup can be undone, which the Settings row has been promising since v8.75: with a kept profile behind it the row offers UNDO and pressing it puts that profile back into the save, pressing it again would return him to where he was, and with nothing kept the button is not offered at all and the handler refuses (2026-09-11 audit)',
   run:function(){
     if(typeof renderSettings!=='function') return 'SKIP: this fixture cannot render the Settings rows';
     if(typeof SKEY!=='string') return 'SKIP: this fixture has no save key to read';
     var KEY='salvagerun:profile'+':prerestore', bad=[];
     var keepPre=null, keepSave=null;
     try{ keepPre=localStorage.getItem(KEY); keepSave=localStorage.getItem(SKEY); }
     catch(_k){ return 'SKIP: this fixture cannot read storage'; }
     var oST=window.setTimeout;
     try{
       __topClear();
       // NOTHING KEPT: the row must not offer a way back that leads nowhere.
       try{ localStorage.removeItem(KEY); }catch(_r){}
       renderSettings();
       if(document.getElementById('set_unrestore'))
         bad.push('the row offers UNDO when there is no kept profile behind it, so pressing it would do nothing at all');
       // SOMETHING KEPT: the way back is offered, and it works.
       var was={credits:777,runs:3,xp:0,stash:[],weapons:[],kit:[]};
       try{ localStorage.setItem(KEY,JSON.stringify(was)); }catch(_w){}
       renderSettings();
       var btn=document.getElementById('set_unrestore');
       if(!btn){
         bad.push('the Settings row promises the profile he is on is kept in case he picked the wrong file, and gives him no way to get it back: the outgoing save is written to a key nothing in the game reads, so a wrong restore is final');
       } else {
         // The handler reloads the page on a timer, which would end this run, so
         // the timer is swallowed for the length of the press and put back below.
         window.setTimeout=function(){ return 0; };
         try{ btn.onclick(); } finally { window.setTimeout=oST; }
         var now=null;
         try{ now=JSON.parse(localStorage.getItem(SKEY)||'null'); }catch(_n){}
         if(!now||now.credits!==777||now.runs!==3)
           bad.push('pressing UNDO did not put the kept profile back: the save now reads '+(now?('credits '+now.credits+' and '+now.runs+' runs'):'nothing at all')+' rather than the 777 and 3 runs it was holding');
         var back=null;
         try{ back=JSON.parse(localStorage.getItem(KEY)||'null'); }catch(_b){}
         if(!back||typeof back.credits!=='number')
           bad.push('control: after going back there is nothing to go back to, so a second press would strand him instead of returning him to where he just was');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       window.setTimeout=oST;
       try{ if(keepPre===null) localStorage.removeItem(KEY); else localStorage.setItem(KEY,keepPre); }catch(_f){}
       try{ if(keepSave===null) localStorage.removeItem(SKEY); else localStorage.setItem(SKEY,keepSave); }catch(_f2){}
       try{ renderSettings(); }catch(_f3){}
       try{ __topClear(); }catch(_f4){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.84',what:'equipping a gun from the backpack says what became of the gun it replaced: an issued loaner says it was left behind and a gun he owns says it went back to the armoury, both surviving the line about what he is now holding, while equipping over an empty hand says exactly what it always said (found by tools/lint.ps1, the v12.73 class in a second place)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
