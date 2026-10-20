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

if ($s.Contains("  {v:'32.17',what:")) { throw "check 32.17 is in the fixture already" }

SubRx @'
  {v:'32.16',what:
'@ @'
  {v:'32.17',what:'the stash header has no dash subtitle and a 32px title',
   run:function(){
     var bad=[];
     try{
       var b=document.querySelector('#hub .toprow .brand'), s=b&&b.nextElementSibling;
       if(!b) bad.push('no brand'); else {
         if(parseFloat(getComputedStyle(b).fontSize)<31.5) bad.push('title is '+getComputedStyle(b).fontSize);
         if(s&&getComputedStyle(s).display!=='none') bad.push('subtitle displays'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
