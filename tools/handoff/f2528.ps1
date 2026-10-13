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

if ($s.Contains("  {v:'25.28',what:")) { throw "check 25.28 is in the fixture already" }

SubRx @'
  {v:'25.27',what:
'@ @'
  {v:'25.28',what:'his #50 (UI redesign ui5q2j): the room behind a window (Wirt, the Last Pour, every .modal) is blurred, so its station signs do not read as words',
   run:function(){
     var m=document.getElementById('gamblemodal')||document.querySelector('.modal');
     if(!m) return 'SKIP: no window here';
     var cs=getComputedStyle(m), bf=(cs.backdropFilter||cs.webkitBackdropFilter||'')+'';
     return bf.indexOf('blur')>=0?null:('the room behind a window is not blurred ('+bf+')'); }},
  {v:'25.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
