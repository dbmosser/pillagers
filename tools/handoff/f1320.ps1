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

# v13.20 CHECK, inserted before the v13.19 entry.
#
# IT STUBS reportEmbedded RATHER THAN THE FRAME. window.self and window.top
# cannot be assigned, so the only honest way to test the embedded arm is to stub
# the one function that makes the decision, which is why that function exists.
#
# IT WATCHES FOR AN ANCHOR CLICK. The old code claimed success by setting a
# string; the thing that actually matters is whether a download was attempted at
# all. So the check counts anchor clicks rather than trusting the string, which
# is the same mistake in miniature that the build itself is fixing.
#
# TWO ARMS: embedded must not claim a save, and NOT embedded must still save, or
# the fix has taken the feedback path away from the one place it works.
SubRx @'
  {v:'13.19',what:'a roll refused for stamina says so out loud instead of reading as a dead key, a roll that can happen stays silent, and holding the key does not repeat the line (his report of 2026-09-12)',
'@ @'
  {v:'13.20',what:'a run report does not claim to have been saved on a page that cannot save files: embedded says so and points at Copy report, and a normal page still downloads (the game is hosted in an itch iframe, which has no allow-downloads)',
   run:function(){
     if(typeof downloadExport!=='function') return 'SKIP: this fixture cannot reach the report saver';
     if(typeof reportEmbedded!=='function')
       return 'this build cannot tell whether it is running inside somebody else page, so on itch it claims every run report was saved to a file while the frame silently refuses the download and the whole feedback path is lost without a word';
     var bad=[];
     var _re=reportEmbedded, _last=P.lastReport, clicks=0;
     var _ac=HTMLAnchorElement.prototype.click;
     try{
       // COUNT REAL DOWNLOAD ATTEMPTS. The string the old code set is exactly
       // what could not be trusted, so it is not what this leans on.
       HTMLAnchorElement.prototype.click=function(){
         if(this.hasAttribute('download')) clicks++;
         return _ac.apply(this,arguments);
       };

       // ARM ONE: inside somebody else page.
       reportEmbedded=function(){ return true; };
       P.lastReport=null; clicks=0;
       downloadExport();
       if(clicks>0)
         bad.push('the game still tries to download the report from inside an embedded page, where the click does nothing and throws nothing, so the run is thrown away');
       if(P.lastReport==='downloaded')
         bad.push('the game records the report as downloaded from a page that cannot save files, so every friend playing on itch is told their run was saved when it was not, and that is the entire feedback path today');
       if(!P.lastReport)
         bad.push('an embedded save records nothing at all, so there is no way to tell afterwards that the report never left');

       // ARM TWO: a normal page must still save, or the fix has taken the
       // feedback path away from the one place it actually works.
       reportEmbedded=function(){ return false; };
       P.lastReport=null; clicks=0;
       downloadExport();
       if(clicks===0)
         bad.push('a normal page no longer saves the report to a file at all, so the fix removed the feedback path instead of repairing it');
       if(P.lastReport!=='downloaded')
         bad.push('a normal page saves the report and does not record it, so nothing downstream can tell the run was handed over');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ HTMLAnchorElement.prototype.click=_ac; }catch(_a){}
       try{ reportEmbedded=_re; }catch(_r){}
       try{ P.lastReport=_last; }catch(_l){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.19',what:'a roll refused for stamina says so out loud instead of reading as a dead key, a roll that can happen stays silent, and holding the key does not repeat the line (his report of 2026-09-12)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
