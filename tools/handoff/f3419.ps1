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

if ($s.Contains("  {v:'34.19',what:")) { throw "check 34.19 is in the fixture already" }

SubRx @'
  {v:'34.18',what:
'@ @'
  {v:'34.19',what:'fashion tiles show rank by top bar thickness, not only colour (2.79 a)',
   run:function(){
     var host=document.getElementById('appavatarpicker'), tmp=null;
     if(!host){ host=tmp=document.createElement('div'); host.id='appavatarpicker'; document.body.appendChild(host); }
     var w=[];
     try{
       ['common','uncommon','rare','elite','gold'].forEach(function(r){
         var t=document.createElement('div'); t.className='costile'; t.setAttribute('data-rar',r); host.appendChild(t);
         w.push(parseFloat(getComputedStyle(t).borderTopWidth)); host.removeChild(t);
       });
     } finally { if(tmp) document.body.removeChild(tmp); }
     for(var i=1;i<w.length;i++) if(!(w[i]>w[i-1])) return 'bar widths do not grow with rank: '+w.join(',');
     return null; }},
  {v:'34.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
