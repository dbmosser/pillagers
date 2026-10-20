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

if ($s.Contains("  {v:'32.53',what:")) { throw "check 32.53 is in the fixture already" }

SubRx @'
  {v:'32.52',what:
'@ @'
  {v:'32.53',what:'the pre-raid map draws its zone names at 20 px, shrinking to no less than 14, and its exit and keyed room names at 18',
   run:function(){
     if(typeof sectorPreviewDraw!=='function') return 'SKIP: no sector map';
     var s=String(sectorPreviewDraw), bad=[];
     if(s.indexOf('fs=20,')<0) bad.push('zone names do not start at 20 px');
     if(s.indexOf('fs>14&&')<0) bad.push('zone names can shrink below 14 px');
     if(s.indexOf("'600 18px '+FF; c.textAlign='center'")<0) bad.push('exit names are not 18 px');
     if(s.indexOf("'600 18px '+FF; c.textAlign='right'")<0) bad.push('keyed room names are not 18 px');
     return bad.length?bad.join('; '):null; }},
  {v:'32.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
