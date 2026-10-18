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

if ($s.Contains("  {v:'31.39',what:")) { throw "check 31.39 is in the fixture already" }

SubRx @'
  {v:'31.38',what:
'@ @'
  {v:'31.39',what:'the Keys list shows lower case words: no first-letter capital, and key caps have no bevel',
   run:function(){
     var bad=[], b, k, cs, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       keysOpen(false);
       b=document.querySelector('#keyslist .row b'); k=document.querySelector('#keyslist .keybtn');
       if(!b) bad.push('no key row');
       else{ cs=getComputedStyle(b,'::first-letter'); if(cs.textTransform==='uppercase') bad.push('the first letter of a key action is still upper case'); }
       if(k && getComputedStyle(k).boxShadow!=='none') bad.push('the key cap still has a bevel: '+getComputedStyle(k).boxShadow);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
