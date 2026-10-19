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

if ($s.Contains("  {v:'31.61',what:")) { throw "check 31.61 is in the fixture already" }

SubRx @'
  {v:'31.60',what:
'@ @'
  {v:'31.61',what:'Rebind callout is the raised fill, idle key caps have a quiet border, the detail strip is the panel fill',
   run:function(){
     var bad=[], kn, kb, sd, bg, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       keysOpen(false); kn=document.getElementById('keysnote'); kb=document.querySelector('#keyslist .keybtn');
       if(!kn||!kb) bad.push('no keys note or cap');
       else{
         kn.className='wait'; kn.textContent='press a key for sprint';
         bg=getComputedStyle(kn).backgroundColor;
         if(bg.replace(/\s/g,'')!=='rgb(30,34,37)') bad.push('callout fill is '+bg);
         bg=getComputedStyle(kb).borderTopColor;
         if(bg.replace(/\s/g,'')!=='rgb(46,51,55)') bad.push('idle key cap border is '+bg);
       }
       try{ document.getElementById('keysmodal').classList.remove('on'); }catch(_k){}
       openSettings('display'); sd=document.getElementById('setdetail');
       if(!sd) bad.push('no detail strip');
       else{ bg=getComputedStyle(sd).backgroundColor; if(bg.replace(/\s/g,'')!=='rgb(22,25,27)') bad.push('detail strip fill is '+bg); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
