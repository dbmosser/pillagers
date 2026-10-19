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

if ($s.Contains("  {v:'31.59',what:")) { throw "check 31.59 is in the fixture already" }

SubRx @'
  {v:'31.58',what:
'@ @'
  {v:'31.59',what:'Keys callout is as wide as the table, scrollbars are 8px, Settings rows share one height',
   run:function(){
     var bad=[], kl, kn, rows, i, hs={}, ks=0, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       keysOpen(false); kl=document.getElementById('keyslist'); kn=document.getElementById('keysnote');
       if(!kl||!kn) bad.push('no keys list or note');
       else{
         kn.className='wait'; kn.textContent='press a key for sprint';
         if(Math.abs(kn.getBoundingClientRect().width-kl.getBoundingClientRect().width)>2) bad.push('the keys note is '+Math.round(kn.getBoundingClientRect().width)+' wide against the table '+Math.round(kl.getBoundingClientRect().width));
       }
       try{ document.getElementById('keysmodal').classList.remove('on'); }catch(_k){}
       openSettings('display');
       rows=document.querySelectorAll('#setlist .row:not(.setjump)');
       if(rows.length<4) bad.push('too few settings rows');
       for(i=0;i<rows.length;i++){ if(rows[i].offsetHeight>0) hs[Math.round(rows[i].getBoundingClientRect().height)]=1; }
       for(i in hs) ks++;
       if(ks!==1) bad.push('settings rows have '+ks+' different heights: '+Object.keys(hs).join(','));
       var sl=document.getElementById('setlist'); if(sl && sl.offsetWidth-sl.clientWidth>0 && sl.offsetWidth-sl.clientWidth<8) bad.push('settings scrollbar is '+(sl.offsetWidth-sl.clientWidth)+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
