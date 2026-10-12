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

if ($s.Contains("  {v:'23.81',what:")) { throw "check 23.81 is in the fixture already" }

SubRx @'
  {v:'23.80',what:
'@ @'
  {v:'23.81',what:'the what is new card never lists the same line twice (the Tripwire Mine line went in twice)',
   run:function(){
     if(typeof WHATSNEW==='undefined') return 'SKIP: this build has no what is new card';
     var seen={}, bad=[], i, s;
     for(i=0;i<WHATSNEW.length;i++){ s=String(WHATSNEW[i]); if(seen[s]) bad.push('line '+i+' repeats line '+seen[s].i+': '+s.slice(0,40)); else seen[s]={i:i}; }
     if(String(WHATSNEW[0]).indexOf('THIS IS AN'+' ALPHA')!==0) bad.push('the card no longer opens with the alpha line');
     return bad.length?bad.join('; '):null; }},
  {v:'23.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
