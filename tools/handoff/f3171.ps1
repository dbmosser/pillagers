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

if ($s.Contains("  {v:'31.71',what:")) { throw "check 31.71 is in the fixture already" }

SubRx @'
  {v:'31.70',what:
'@ @'
  {v:'31.71',what:'Settings focus row has the bar and no ring, the detail pane is wide, and the pause box puts feedback and what is new side by side',
   run:function(){
     var bad=[], r, sh, d, fb, wn, a, a1, a2, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       openSettings('display');
       try{ window.__setDetailSync(); }catch(_s){}
       r=document.querySelector('#setlist .row.dshow'); d=document.getElementById('setdetail');
       if(!r) bad.push('no focus row'); else{ sh=getComputedStyle(r).boxShadow; if(/ 1px 0px 0px 0px inset|0px 0px 0px 1px inset/.test(sh)) bad.push('focus row has a ring: '+sh); }
       if(!d||d.getBoundingClientRect().width<=500) bad.push('detail pane is '+(d?Math.round(d.getBoundingClientRect().width):0)+' wide');
       document.getElementById('settingsmodal').classList.remove('on');
       document.body.classList.remove('padon');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()||__state().over) return 'SKIP: no live raid';
       togglePauseBox(true); pauseFrameFit();
       fb=document.getElementById('fbbtn'); wn=document.getElementById('wnbtn'); a=document.getElementById('abandonbtn');
       if(!fb||!wn||!fb.offsetWidth||!wn.offsetWidth) bad.push('feedback or what is new is missing');
       else{
         a1=fb.getBoundingClientRect(); a2=wn.getBoundingClientRect();
         if(Math.abs(a1.top-a2.top)>2) bad.push('feedback and what is new are not on one row ('+Math.round(a1.top)+' vs '+Math.round(a2.top)+')');
         if(a1.height>44) bad.push('feedback is '+Math.round(a1.height)+' tall');
       }
       if(a&&a.offsetHeight>44) bad.push('abandon is '+a.offsetHeight+' tall');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ togglePauseBox(false); }catch(_t){} try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
