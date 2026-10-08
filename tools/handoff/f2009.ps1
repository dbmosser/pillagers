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

if ($s.Contains("  {v:'20.09',what:")) { throw "check 20.09 is in the fixture already" }

SubRx @'
  {v:'20.08',what:
'@ @'
  {v:'20.09',what:'the Undercroft crowd has builds: in 300 rolled looks there are Broad and Curved people, and a crowd member is drawn in the build rolled',
   run:function(){
     if(typeof hubRollLook!=='function') return 'SKIP: no crowd roller here';
     var bad=[], n={}, i, lk;
     for(i=0;i<300;i++){ lk=hubRollLook(); n[lk.build||'none']=(n[lk.build||'none']||0)+1; }
     if(!n.curved||!n.broad) bad.push('no Broad or Curved in 300 crowd looks ('+JSON.stringify(n)+')');
     return bad.length?bad.join('; '):null; }},
  {v:'20.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
