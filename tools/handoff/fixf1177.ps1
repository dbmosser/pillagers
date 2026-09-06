$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Mirrors fixchk1177.ps1 into the f1177 draft, so the record matches the tree.
$f = 'C:\claudecode\dark raiders\tools\handoff\f1177.ps1'
$s = [IO.File]::ReadAllText($f)
function Rep([string]$old, [string]$new) {
  $c = ([regex]::Matches($script:s, [regex]::Escape($old))).Count
  if ($c -ne 1) { throw "anchor matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s = $script:s.Replace($old, $new)
}
Rep "     var bad=[], k;" "     var bad=[], k, snap=null;"
Rep "       CFG.fragR=DEF.fragR;   // the game reads CFG; the blast is measured at the shipped default" ("       snap=JSON.stringify(__P());   // the loader below replaces the profile; it is put back at the end" + [Environment]::NewLine + "       CFG.fragR=DEF.fragR;   // the game reads CFG; the blast is measured at the shipped default")
Rep "     finally{ __topClear(); __cleanProfile(); __resetCfg(); }" "     finally{ try{ if(snap) __applyLoaded(JSON.parse(snap)); }catch(_rs){} __topClear(); __cleanProfile(); __resetCfg(); }"
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'f1177 draft updated'
