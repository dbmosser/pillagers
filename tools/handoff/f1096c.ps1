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

# ---- THE ARMED ABANDON, asserted on purpose now rather than caught by accident.
SubRx @'
         if(rj.indexOf('CHARACTER')>=0) bad.push('the raid pause box offers to go back to the character screen mid-raid: '+rj);
       }
       togglePauseBox(false);
'@ @'
         if(rj.indexOf('CHARACTER')>=0) bad.push('the raid pause box offers to go back to the character screen mid-raid: '+rj);
       }
       // THE PRIMED ABANDON, which this check found on the full corpus rather
       // than alone: Abandon run does not abandon, it ARMS, and until v10.96 the
       // only thing that disarmed it was pressing Resume. Close with Escape while
       // it is armed and the next opening had a live YES, ABANDON THIS RUN
       // sitting under the pointer, one click from ending the raid.
       var _ab=document.getElementById('abandonbtn'), _ca=document.getElementById('confirmabandon');
       if(_ab&&_ca){
         _ab.click();                                   // arm it, the way he would
         var armed=(window.getComputedStyle(_ca).display!=='none');
         if(!armed) bad.push('control: pressing Abandon run did not arm the confirm, so the leak cannot be tested');
         else {
           togglePauseBox(false);                       // close it the way Escape does
           togglePauseBox(true);                        // and come back
           if(window.getComputedStyle(_ca).display!=='none')
             bad.push('a primed YES, ABANDON THIS RUN survives the pause box closing, so reopening it puts one click between him and the end of the raid');
           if((_ab.textContent||'').toUpperCase().indexOf('KEEP PLAYING')>=0)
             bad.push('the abandon button is still reading NO, KEEP PLAYING on a freshly opened pause box');
         }
       }
       togglePauseBox(false);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
