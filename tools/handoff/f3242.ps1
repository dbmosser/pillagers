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

if ($s.Contains("  {v:'32.42',what:")) { throw "check 32.42 is in the fixture already" }

SubRx @'
  {v:'32.41',what:
'@ @'
  {v:'32.42',what:'terms intro hidden, bonus figure 32px, sign nothing 200x48',
   run:function(){
     var bad=[];
     try{
       var tm=document.getElementById('termsmodal'), m=tm.querySelector('.msub');
       if(getComputedStyle(m).display!=='none') bad.push('intro shows');
       renderTerms();
       var vl=tm.querySelector('#termslist .vl');
       if(!vl||parseFloat(getComputedStyle(vl).fontSize)<32) bad.push('bonus '+(vl&&getComputedStyle(vl).fontSize));
       var c=document.getElementById('termsclear');
       if(getComputedStyle(c).minWidth!=='200px') bad.push('clear minw '+getComputedStyle(c).minWidth);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
