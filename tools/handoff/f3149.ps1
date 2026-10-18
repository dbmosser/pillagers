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

if ($s.Contains("  {v:'31.49',what:")) { throw "check 31.49 is in the fixture already" }

SubRx @'
  {v:'31.48',what:
'@ @'
  {v:'31.49',what:'Settings: the key hint ends at the X edge; the pause report box wears the button type; abandon has no box',
   run:function(){
     var bad=[], sm, cs, pf, ab, a, pl, pr, cw, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       pf=document.getElementById('pausefb'); ab=document.getElementById('abandonbtn');
       if(!pf||!ab) bad.push('pause parts missing');
       else{
         if(getComputedStyle(pf).fontWeight!=='600') bad.push('the report box is not weight 600: '+getComputedStyle(pf).fontWeight);
         if(getComputedStyle(ab).borderTopColor.replace(/\s/g,'')!=='rgba(0,0,0,0)') bad.push('abandon still has a box: '+getComputedStyle(ab).borderTopColor);
       }
       openSettings('display');
       sm=document.getElementById('settingsmodal'); cs=getComputedStyle(sm);
       a=parseFloat(getComputedStyle(sm,'::after').width); pl=parseFloat(cs.paddingLeft); pr=parseFloat(cs.paddingRight); cw=sm.clientWidth-pl-pr;
       if(!(Math.abs(a-cw)<3)) bad.push('the key hint is '+a+' wide, the card content is '+cw);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
