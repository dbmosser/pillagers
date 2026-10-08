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

if ($s.Contains("  {v:'18.73',what:")) { throw "check 18.73 is in the fixture already" }

SubRx @'
  {v:'18.72',what:
'@ @'
  {v:'18.73',what:'the title step cards are solid: ASCEND, PILLAGE and EXTRACT have a dark fill the Undercroft does not show through',
   run:function(){
     var c=document.querySelector('#title .tcard'), bi, m, a;
     if(!c) return 'SKIP: no title step cards here';
     bi=getComputedStyle(c).backgroundImage||'';
     m=(/rgba?\(([^)]*)\)/).exec(bi);
     if(!m) return 'the step card has no fill ('+bi.slice(0,60)+')';
     a=m[1].split(','); a=(a.length>3)?parseFloat(a[3]):1;
     return (a>=0.8)?null:('the step cards are see-through (fill '+a+')'); }},
  {v:'18.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
