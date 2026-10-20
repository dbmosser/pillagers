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

if ($s.Contains("  {v:'32.41',what:")) { throw "check 32.41 is in the fixture already" }

SubRx @'
  {v:'32.40',what:
'@ @'
  {v:'32.41',what:'terms intro is one short line, rows 76px, names 20px, sign buttons 104x48',
   run:function(){
     var bad=[];
     try{
       var tm=document.getElementById('termsmodal'), m=tm&&tm.querySelector('.msub');
       if(!m||m.textContent.length>70) bad.push('terms intro long: '+(m&&m.textContent.length));
       renderTerms();
       var row=tm.querySelector('#termslist .row'), b=row&&row.querySelector('b'), bt=row&&row.querySelector('button'), d=row&&row.querySelector('.nm div');
       if(!row) bad.push('no row');
       else{
         if(getComputedStyle(row).minHeight!=='76px') bad.push('row min '+getComputedStyle(row).minHeight);
         if(parseFloat(getComputedStyle(b).fontSize)<20) bad.push('name '+getComputedStyle(b).fontSize);
         if(parseFloat(getComputedStyle(d).fontSize)<16) bad.push('line '+getComputedStyle(d).fontSize);
         if(getComputedStyle(bt).minWidth!=='104px') bad.push('btn minw '+getComputedStyle(bt).minWidth);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
