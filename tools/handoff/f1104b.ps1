$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ---- A TIMER A CHECK CANNOT SEE IS A TIMER THAT RELOADS THE TAB MID CORPUS.
# ---- The reload is armed rather than fired, on purpose, so the profile write
# ---- lands first. The check asserts the ARMING, and cancels the timer, or four
# ---- hundred milliseconds later it would take the whole run with it.
SubRx @'
       if(!reloaded) bad.push('the restore did not reload, so the Undercroft is still showing the old character');
'@ @'
       if(typeof RESTORE_RELOAD==='undefined')
         bad.push('nothing records whether the restore reloads, so the Undercroft may still be showing the old character');
       else if(!RESTORE_RELOAD)
         bad.push('the restore did not arm a reload, so the Undercroft is still showing the old character');
       // AND THE TIMER DIES HERE. It is armed for four hundred milliseconds and
       // would otherwise fire in the middle of whatever check runs next.
       try{ if(typeof RESTORE_TIMER!=='undefined'&&RESTORE_TIMER){ clearTimeout(RESTORE_TIMER); RESTORE_TIMER=null; } }catch(_ct){}
'@
SubRx @'
     var reloaded=0, realReload=null;
'@ @'
     var realReload=null;
'@
SubRx @'
       try{ window.location.reload=function(){ reloaded++; }; }catch(_lr){ realReload=null; }
'@ @'
       try{ window.location.reload=function(){}; }catch(_lr){ realReload=null; }
'@
SubRx @'
       if(realReload) try{ window.location.reload=realReload; }catch(_rr){}
'@ @'
       try{ if(typeof RESTORE_TIMER!=='undefined'&&RESTORE_TIMER){ clearTimeout(RESTORE_TIMER); RESTORE_TIMER=null; } }catch(_ct2){}
       try{ if(typeof RESTORE_RELOAD!=='undefined') RESTORE_RELOAD=0; }catch(_rz){}
       if(realReload) try{ window.location.reload=realReload; }catch(_rr){}
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
