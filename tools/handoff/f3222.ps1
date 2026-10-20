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

if ($s.Contains("  {v:'32.22',what:")) { throw "check 32.22 is in the fixture already" }

SubRx @'
  {v:'32.21',what:
'@ @'
  {v:'32.22',what:'party intro is one short line, sector hint lines hidden, party text 18px',
   run:function(){
     var bad=[];
     try{
       var pm=document.getElementById('partymodal'), m=pm&&pm.querySelector('.msub');
       if(!m||m.textContent.length>60) bad.push('party intro long: '+(m&&m.textContent.length));
       var t=document.getElementById('partytrade');
       if(!t||t.textContent.length>80) bad.push('trade line long');
       ['condhint','wxhint'].forEach(function(id){ var e=document.getElementById(id);
         if(!e) bad.push('no '+id); else if(getComputedStyle(e).display!=='none') bad.push(id+' displays'); });
       var fs=m?parseFloat(getComputedStyle(m).fontSize):0;
       if(fs<18) bad.push('party msub '+fs+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
