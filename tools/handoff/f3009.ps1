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

if ($s.Contains("  {v:'30.09',what:")) { throw "check 30.09 is in the fixture already" }

SubRx @'
  {v:'30.08',what:
'@ @'
  {v:'30.09',what:'the Settings pane names the row, the stepper arrows are 28px and the first section label that repeats the tab is hidden',
   run:function(){
     var bad=[], d, k, a, h, i, bs, fs=null, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings('display');
       if(typeof window.__setDetailSync==='function') window.__setDetailSync();
       d=document.getElementById('setdetail'); k=d&&d.querySelector('.sdk');
       if(!d) bad.push('no detail pane');
       else if(k&&getComputedStyle(k).display==='none') bad.push('the detail pane hides the row name');
       bs=document.querySelectorAll('#setlist .row > button');
       for(i=0;i<bs.length;i++){ a=getComputedStyle(bs[i],'::before'); if(a.content&&a.content!=='none'&&a.content!=='normal'&&bs[i].offsetParent){ fs=parseFloat(a.fontSize); break; } }
       if(fs===null) bad.push('no stepper arrow found');
       else if(fs<27) bad.push('the stepper arrows are '+fs+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
