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
# v11.46: window.__nav is overwritten later in this file by a {reachable,free}
# object, so the canSee on the earlier __nav never reaches a check. A distinct
# name that nothing else claims.
SubRx @'
window.__wnseen=function(v){ if(v!==undefined) WNSEEN=v; return WNSEEN; };
'@ @'
window.__wnseen=function(v){ if(v!==undefined) WNSEEN=v; return WNSEEN; };
window.__see=function(){ return canSee.apply(null,arguments); };
'@
SubRx @'
     if(!(window.__deploy&&window.__state&&window.__rawStep&&window.__nav&&__nav.canSee)) return 'SKIP: this fixture cannot stage a line-of-sight shot';
'@ @'
     if(!(window.__deploy&&window.__state&&window.__rawStep&&window.__see)) return 'SKIP: this fixture cannot stage a line-of-sight shot';
'@
SubRx @'
       var sees=null; try{ sees=!!__nav.canSee(R.x,R.y,R.face,p.x,p.y,g.vseg,Math.max(R.rng||0,600),R.cone,100); }catch(e2){ sees=null; }
'@ @'
       var sees=null; try{ sees=!!__see(R.x,R.y,R.face,p.x,p.y,g.vseg,Math.max(R.rng||0,600),R.cone,100); }catch(e2){ sees=null; }
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
