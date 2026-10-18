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

if ($s.Contains("  {v:'29.78',what:")) { throw "check 29.78 is in the fixture already" }

SubRx @'
  {v:'29.77',what:
'@ @'
  {v:'29.78',what:'Settings: a hub toast is hidden while the Settings window is open',
   run:function(){
     if(typeof openSettings!=='function') return 'SKIP: no Settings here';
     var bad=[], t, made=false, cs;
     try{
       t=document.getElementById('hubtoast');
       if(!t){ t=document.createElement('div'); t.id='hubtoast'; t.textContent='Test'; document.body.appendChild(t); made=true; }
       openSettings('display');
       cs=getComputedStyle(t);
       if(cs.visibility!=='hidden') bad.push('the hub toast is '+cs.visibility+' over the open Settings window');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ if(made&&t.parentNode) t.parentNode.removeChild(t); }catch(_m){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
