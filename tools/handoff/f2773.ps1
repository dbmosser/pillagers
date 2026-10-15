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

if ($s.Contains("  {v:'27.73',what:")) { throw "check 27.73 is in the fixture already" }

SubRx @'
  {v:'27.72',what:
'@ @'
  {v:'27.73',what:'cloud-menus-settings-chip-on-open: opening Settings lights the chip of the section in view, not the last one',
   run:function(){
     if(typeof openSettings!=='function'||typeof setSecSpy!=='function'||typeof SETSEC==='undefined') return 'SKIP: this fixture has no Settings section chips';
     var bad=[], md=document.getElementById('settingsmodal'), host, lit, now;
     if(!md) return 'SKIP: no Settings window';
     function litNow(){ return [].filter.call(host.querySelectorAll('.setjump button'),function(b){ return b.classList.contains('on'); }).map(function(b){ return b.getAttribute('data-sec'); }); }
     try{
       __topClear(); md.classList.remove('on');
       openSettings();
       host=document.getElementById('setlist');
       if(!host||!md.classList.contains('on')) return 'SKIP: Settings did not open';
       if(!host.querySelector('.setjump button')) return 'SKIP: no section chips drawn';
       if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout';
       lit=litNow();
       now=setSecSpy(host);
       if(!now) return 'SKIP: no section head is in view';
       if(lit.length!==1||lit[0]!==now) bad.push('on opening Settings the lit chip was '+(lit.join(',')||'none')+' where the section in view is '+now);
       if(host.scrollTop===0&&now!==SETSEC[0]) bad.push('at the top of the list the section in view read '+now+', not '+SETSEC[0]);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ md.classList.remove('on'); }catch(_m){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'27.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
