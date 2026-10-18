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

if ($s.Contains("  {v:'30.15',what:")) { throw "check 30.15 is in the fixture already" }

SubRx @'
  {v:'30.14',what:
'@ @'
  {v:'30.15',what:'the Settings key-hint line is 20px and the list fade is 24px',
   run:function(){
     var bad=[], m, fs, mk, l, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings('display');
       m=document.getElementById('settingsmodal');
       if(!m) bad.push('no settings modal');
       else{
         fs=parseFloat(getComputedStyle(m,'::after').fontSize);
         if(!(fs>=19.5)) bad.push('the key hint is '+fs+'px');
         l=document.getElementById('setlist');
         mk=l?(getComputedStyle(l).webkitMaskImage||getComputedStyle(l).maskImage||''):'';
         if(mk.indexOf('calc(100% - 24px)')<0 && mk.indexOf('calc(100% - 24')<0) bad.push('the list fade is not 24px: '+mk.slice(0,160));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
