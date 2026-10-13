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

if ($s.Contains("  {v:'25.03',what:")) { throw "check 25.03 is in the fixture already" }

SubRx @'
  {v:'25.02',what:
'@ @'
  {v:'25.03',what:'his #50 (UI redesign ui5q2a, the title backdrop): the title glass blurs the Undercroft floor and closes to near black at the edges, so the floor rectangle does not show',
   run:function(){
     var t=document.getElementById('title'); if(!t) return 'no #title';
     var was=t.classList.contains('on'); if(!was) t.classList.add('on');
     try{
       var cs=getComputedStyle(t), bf=(cs.backdropFilter||cs.webkitBackdropFilter||'')+'';
       if(bf.indexOf('blur')<0) return 'the title glass does not blur the floor ('+bf+')';
       if((cs.backgroundImage+'').indexOf('0.95')<0) return 'the title glass does not close to near black at the edges';
       return null;
     } finally { if(!was) t.classList.remove('on'); } }},
  {v:'25.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
