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

# ---- The map screen's own projection, so a check can ask what colour a given
# ---- building was painted on it. Nothing else can: mapProj lives inside the
# ---- game and the map is drawn straight onto the HUD canvas with no record of
# ---- what went where.
SubRx @'
window.__lockedOf=function(mi){ try{ return (FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; }catch(e){ return []; } };
'@ @'
window.__lockedOf=function(mi){ try{ return (FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; }catch(e){ return []; } };
// v10.83: open the map screen, draw it, and hand back the projection so a check
// can look up the pixel a named building was painted at.
window.__mapShot=function(){
  if(!G||!G.map) return null;
  var was=G.mapOpen; G.mapOpen=true;
  try{ render2D(0); drawHUD(); }catch(e){}
  var P2=mapProj();
  G.mapOpen=was;
  return {sc:P2.sc,ox:P2.ox,oy:P2.oy};
};
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
