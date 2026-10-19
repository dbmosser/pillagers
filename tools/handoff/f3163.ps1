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

if ($s.Contains("  {v:'31.63',what:")) { throw "check 31.63 is in the fixture already" }

SubRx @'
  {v:'31.62',what:
'@ @'
  {v:'31.63',what:'Settings section tabs are a left rail beside the rows, not a strip over them',
   run:function(){
     var bad=[], sj, bs, row, a, b, pw, wr, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       openSettings('display');
       sj=document.querySelector('#setlist .setjump .sj'); bs=document.querySelectorAll('#setlist .setjump button');
       row=document.querySelector('#setlist .row:not(.setjump) > button'); wr=document.getElementById('setwrap');
       if(!sj||!bs.length||!row) bad.push('no tabs or rows');
       else{
         if(getComputedStyle(sj).flexDirection!=='column') bad.push('tabs are not a column: '+getComputedStyle(sj).flexDirection);
         a=bs[0].getBoundingClientRect(); b=row.parentNode.getBoundingClientRect();
         if(a.right>b.left+2) bad.push('first tab right '+Math.round(a.right)+' passes the rows left '+Math.round(b.left));
         if(bs.length>1 && bs[1].getBoundingClientRect().top<=a.bottom-2) bad.push('tabs are not stacked');
         if(a.height<20) bad.push('tab height '+a.height);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
