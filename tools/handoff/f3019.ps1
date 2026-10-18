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

if ($s.Contains("  {v:'30.19',what:")) { throw "check 30.19 is in the fixture already" }

SubRx @'
  {v:'30.18',what:
'@ @'
  {v:'30.19',what:'after a tab chip jump the Settings detail pane names the first row below the sticky tab strip, not a row hidden under it',
   run:function(){
     var bad=[], sl, d, k, rows, i, a, c, m, t, bar, vis=null, nm='', chip, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings();
       sl=document.getElementById('setlist'); d=document.getElementById('setdetail');
       chip=document.querySelector('.setjump button[data-sec="DISPLAY"]');
       if(!sl||!d||!chip){ bad.push('no list, pane or Display chip'); }
       else{
         chip.click();
         if(typeof window.__setDetailSync==='function') window.__setDetailSync();
         a=sl.getBoundingClientRect(); bar=sl.querySelector('.setjump'); t=a.top+(bar?bar.getBoundingClientRect().height:0); rows=sl.querySelectorAll('.row');
         for(i=0;i<rows.length;i++){ c=rows[i].getBoundingClientRect(); m=(c.top+c.bottom)/2; if(m>=t&&m<=a.bottom&&rows[i].querySelector('div > b')&&!/opacity:\s*\.7/.test(rows[i].getAttribute('style')||'')){ vis=rows[i]; break; } }
         k=d.querySelector('.sdk'); nm=k?k.textContent:'';
         if(sl.scrollTop<5) bad.push('the list did not scroll');
         else if(!vis) bad.push('no row in view');
         else if(nm!==vis.querySelector('div > b').textContent) bad.push('the pane names "'+nm+'" but the first row below the strip is "'+vis.querySelector('div > b').textContent+'"');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
