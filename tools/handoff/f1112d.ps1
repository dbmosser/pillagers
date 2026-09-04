$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# On a build with no walk test the hook answers with the sight test, which is
# exactly what that build did, so the check reports the defect by name instead
# of throwing "walkClear is not defined".
SubRx @'
window.__walk=function(ax,ay,bx,by){
  return {see:losClear(ax,ay,bx,by,G.map.segs),walk:walkClear(ax,ay,bx,by)};
};
'@ @'
window.__walk=function(ax,ay,bx,by){
  var see=losClear(ax,ay,bx,by,G.map.segs);
  var walk=(typeof walkClear==='function')?walkClear(ax,ay,bx,by):see;
  return {see:see,walk:walk};
};
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
