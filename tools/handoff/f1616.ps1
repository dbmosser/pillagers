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

if ($s.Contains("  {v:'16.16',what:")) { throw "check 16.16 is in the fixture already" }

SubRx @'
  {v:'16.15',what:
'@ @'
  {v:'16.16',what:'plain game language, the larger pass: the rewritten lines are in the build, the rulebook versions are gone,',
   run:function(){
     var src='', bad=[], i, OLD, NEW;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     OLD=['No throwable you carry is on your','No legs left to roll with','Auto-jog arms from a standstill','Type what to call them first','Everyone with the','Point at an item in the stash, then press','Let go too soon','Hold it down for a second','Linked. Saying hello to the host'];
     NEW=['No throwable on your tactical belt.','Too tired to roll.','Stop first, then tap CAPS to auto-jog.','Enter a name first.','Released too early. Hold for one second.','Hold for one second to confirm.','Connected. Joining the host.'];
     for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the old line with "'+OLD[i]+'" is still in the build');
     for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the line "'+NEW[i]+'" is missing');
     return bad.length?bad.join('; '):null; }},
  {v:'16.15',what:
'@


SubRx @'
     if(!/extracted, minus everything you carried in/.test(html)) bad.push('the card does not explain itself');
'@ @'
     if(!/extracted minus value carried in/.test(html)) bad.push('the card does not explain itself');
'@

SubRx @'
       if(!said.some(function(t){ return /destroyed\. It has stopped listening/.test(t); })) bad.push('the Pillbox death line does not say destroyed (said: '+said.join(' | ').slice(0,90)+')');
'@ @'
       if(!said.some(function(t){ return /destroyed\. It dropped a cache/.test(t); })) bad.push('the Pillbox death line does not say destroyed (said: '+said.join(' | ').slice(0,90)+')');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
