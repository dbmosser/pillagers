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

if ($s.Contains("  {v:'31.67',what:")) { throw "check 31.67 is in the fixture already" }

SubRx @'
  {v:'31.66',what:
'@ @'
  {v:'31.67',what:'Keys table spans the card and settings steppers box only the row in focus',
   run:function(){
     var bad=[], kl, kc, bt, rows, i, idle=0, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       openSettings('display');
       bt=document.querySelectorAll('#setlist .row:not(.setjump) > button'); 
       for(i=0;i<bt.length;i++){ if(bt[i].matches(':hover')||bt[i].parentNode.matches(':focus-within')||bt[i].classList.contains('padfocus')) continue; if(getComputedStyle(bt[i]).borderTopColor!=='rgba(0, 0, 0, 0)') idle++; }
       if(idle>0) bad.push(idle+' idle steppers still boxed');
       document.getElementById('settingsmodal').classList.remove('on');
       keysOpen();
       kl=document.getElementById('keyslist'); kc=document.getElementById('keysmodal');
       if(!kl||!kc) bad.push('no keys window');
       else{
         var w=kl.getBoundingClientRect().width, cw=kc.getBoundingClientRect().width;
         if(w<cw*0.8) bad.push('keys list '+Math.round(w)+' of card '+Math.round(cw));
         var ks=kl.querySelector('.keysec'); if(ks && getComputedStyle(ks).boxShadow==='none') bad.push('section has no accent tab');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ['settingsmodal','keysmodal'].forEach(function(n){ var q=document.getElementById(n); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
