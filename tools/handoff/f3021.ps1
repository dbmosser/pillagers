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

if ($s.Contains("  {v:'30.21',what:")) { throw "check 30.21 is in the fixture already" }

SubRx @'
  {v:'30.20',what:
'@ @'
  {v:'30.21',what:'the Settings section label rows show no text (the tab already says it) yet the Display chip still jumps to its rows',
   run:function(){
     var bad=[], sl, hd, chip, n, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings();
       sl=document.getElementById('setlist'); hd=document.getElementById('setsec_DISPLAY'); chip=document.querySelector('.setjump button[data-sec="DISPLAY"]');
       if(!sl||!hd||!chip){ bad.push('no list, Display head or chip'); }
       else{
         n=hd.getBoundingClientRect().height;
         if(n>4) bad.push('the Display label row is '+Math.round(n)+'px tall, it should be a bare anchor');
         chip.click();
         if(sl.scrollTop<5) bad.push('the Display chip did not scroll the list');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
