$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ---- A CONTROL MUST TEST COVERAGE, NOT MY CHOICE OF WORD. This asked for the
# ---- exact phrase "machine moving", so on the old build, which says "robot
# ---- moving", it fired twice and read as if something were broken when the key
# ---- covered that case perfectly well. It accepts either word now.
SubRx @'
     var need=['machine moving','machine firing','pillager moving','pillager firing'];
     for(i=0;i<need.length;i++) if(joined.indexOf(need[i])<0)
       bad.push('control: the sound key no longer explains '+need[i]);
'@ @'
     var need=[['machine moving','robot moving'],['machine firing','robot firing'],
               ['pillager moving'],['pillager firing']];
     for(i=0;i<need.length;i++){
       var have=false;
       for(j=0;j<need[i].length;j++) if(joined.indexOf(need[i][j])>=0) have=true;
       if(!have) bad.push('control: the sound key no longer explains '+need[i][0]);
     }
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
