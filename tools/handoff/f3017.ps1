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

if ($s.Contains("  {v:'30.17',what:")) { throw "check 30.17 is in the fixture already" }

SubRx @'
  {v:'30.16',what:
'@ @'
  {v:'30.17',what:'the Settings detail pane and its focus look name the first row in view after the list scrolls, not a row off screen',
   run:function(){
     var bad=[], sl, d, k, rows, i, a, c, m, vis=null, nm='', padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings('display');
       sl=document.getElementById('setlist'); d=document.getElementById('setdetail');
       if(!sl||!d){ bad.push('no list or pane'); }
       else{
         sl.scrollTop=Math.floor(sl.scrollHeight/2);
         if(typeof window.__setDetailSync==='function') window.__setDetailSync();
         a=sl.getBoundingClientRect(); rows=sl.querySelectorAll('.row');
         for(i=0;i<rows.length;i++){ c=rows[i].getBoundingClientRect(); m=(c.top+c.bottom)/2; if(m>=a.top&&m<=a.bottom&&rows[i].querySelector('div > b')&&!/opacity:\s*\.7/.test(rows[i].getAttribute('style')||'')){ vis=rows[i]; break; } }
         k=d.querySelector('.sdk'); nm=k?k.textContent:'';
         if(sl.scrollTop<5) bad.push('the list did not scroll');
         else if(!vis) bad.push('no row in view');
         else if(nm!==vis.querySelector('div > b').textContent) bad.push('the pane names "'+nm+'" but the first row in view is "'+vis.querySelector('div > b').textContent+'"');
         else if(!vis.classList.contains('dshow')) bad.push('the row in view does not wear the focus look');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
