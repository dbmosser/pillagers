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

# HARNESS REPAIR with v12.06. The fixture boots with the title screen on and
# nothing in the runner ever dismissed it: __runPrep and __hubEnter left it up,
# and four checks (8.84, 8.95, 8.96, 9.32) pressed I on the floor under it and
# passed only because the floor answered keys behind the title, which is the
# leak v12.06 closes. On the v12.06 corpus all four went red on a fresh load
# and passed alone after a later check had happened to switch the title off.
# A player dismisses the boot title before he ever stands on the floor; the
# runner now does the same, once at corpus start and again on every entry to
# the floor. Checks that measure the title switch it on themselves.
SubRx @'
window.__hubEnter=function(){ showScreen('hub'); return !!HB; };
'@ @'
window.__hubEnter=function(){ showScreen('hub'); var _t=document.getElementById('title'); if(_t) _t.classList.remove('on'); return !!HB; };   // v12.06: the floor is past the title, and since v12.06 a title left up blocks every floor key
'@
SubRx @'
window.__runPrep=function(){
  try{ if(window.__pinDPR) __pinDPR(1); }catch(e){}
'@ @'
window.__runPrep=function(){
  try{ if(window.__pinDPR) __pinDPR(1); }catch(e){}
  try{ var _bt=document.getElementById('title'); if(_bt) _bt.classList.remove('on'); }catch(e){}   // v12.06: the boot title is dismissed, as a player does before the floor
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
