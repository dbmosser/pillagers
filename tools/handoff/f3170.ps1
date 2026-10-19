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

if ($s.Contains("  {v:'31.70',what:")) { throw "check 31.70 is in the fixture already" }

SubRx @'
  {v:'31.69',what:
'@ @'
  {v:'31.70',what:'the stash gun key and item wheel names are at the 16px label size and the build stamp is gone from the stash header',
   run:function(){
     if(!window.__hubEnter||!window.__station) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], els, i, el, fs, vl;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       el=document.querySelector('#kitsetup .kst span');
       if(!el) return 'SKIP: no gun keys drawn';
       fs=parseFloat(getComputedStyle(el).fontSize);
       if(!(fs>=15.5)) bad.push('the gun key names are '+fs+'px, under the 16px floor');
       fs=parseFloat(getComputedStyle(document.querySelector('#kitsetup .ksreset')).fontSize);
       if(!(fs>=15.5)) bad.push('the reset buttons are '+fs+'px');
       vl=document.getElementById('verlabel');
       if(vl&&getComputedStyle(vl).display!=='none') bad.push('the build stamp still shows in the stash header');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ var hb=document.getElementById('hub'); if(hb) hb.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
