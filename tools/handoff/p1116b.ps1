$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# MY BUG, measured: both arms identical. The strict pass counted only cells it
# newly opened, so a door whose clear cells were already open in the base grid
# counted as opening nothing and the fallback undid the pass. A cell that is
# already open is a door cell too. On the mile door at 2960,3167 the partition
# at 2976,3193 runs into the doorway from inside and leaves 26 units above it
# and 22 below, neither wide enough for a body, so with the pass honoured the
# door is a dead end on the route grid and the crawler goes round instead of
# standing in it.
SubRx @'
      for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
        var id=j*gw+k;
        if(!b[id]) continue;
        var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
        if(jamb>0){
          if(_dh){ if(cx<D.x+jamb||cx>D.x+D.w-jamb) continue; }
          else { if(cy<D.y+jamb||cy>D.y+D.h-jamb) continue; }
        }
'@ @'
      for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
        var id=j*gw+k;
        var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
        if(jamb>0){
          if(_dh){ if(cx<D.x+jamb||cx>D.x+D.w-jamb) continue; }
          else { if(cy<D.y+jamb||cy>D.y+D.h-jamb) continue; }
        }
        if(!b[id]){ _got++; continue; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
