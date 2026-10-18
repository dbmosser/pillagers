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

if ($s.Contains("  {v:'29.96',what:")) { throw "check 29.96 is in the fixture already" }

SubRx @'
  {v:'29.95',what:
'@ @'
  {v:'29.96',what:'the pause card has a header X that resumes, the Settings row the pane names shows focus, the Keys list fades at its foot',
   run:function(){
     var bad=[], pb=document.getElementById('pausebox'), h3, hr, xr, x, row, cs, kl, mk, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return 'SKIP: no live raid';
       togglePauseBox(true); pauseFrameFit();
       h3=pb.querySelector('h3'); x=document.getElementById('pausex');
       if(!x||!x.offsetWidth) bad.push('the pause card has no header X');
       else {
         hr=h3.getBoundingClientRect(); xr=x.getBoundingClientRect();
         if(Math.abs(xr.right-hr.right)>3) bad.push('the X is '+Math.round(xr.right-hr.right)+'px off the title rule edge');
         if(xr.top<hr.top-40||xr.top>hr.top+8) bad.push('the X sits '+Math.round(xr.top-hr.top)+'px from the title top');
         if(xr.width<40) bad.push('the X is only '+Math.round(xr.width)+'px wide');
         x.click();
         if(pb.offsetHeight>0) bad.push('the X did not resume');
       }
     } finally { try{ togglePauseBox(false); }catch(_t){} document.body.classList.toggle('padon',padWas); }
     try{
       openSettings('display'); try{ window.__setDetailSync(); }catch(_s){}
       row=document.querySelector('#setlist .row.dshow');
       if(!row) bad.push('no Settings row wears the focus look');
       else { row.style.transition='none'; cs=getComputedStyle(row); if(cs.backgroundColor==='rgba(0, 0, 0, 0)') bad.push('the shown row has no raised fill'); if(cs.boxShadow==='none') bad.push('the shown row has no amber edge'); }
       document.getElementById('settingsmodal').classList.remove('on'); try{ __topClear(); }catch(_c){}
       keysOpen(false); kl=document.getElementById('keyslist'); cs=kl?getComputedStyle(kl):null;
       mk=cs?(cs.webkitMaskImage||cs.maskImage||'none'):'none';
       if(!/gradient/.test(mk)) bad.push('the Keys list has no fade at its foot');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
