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

# THE FOLLOWER TURNED TOO EARLY. A waypoint counted as reached at 30 units, and
# 30 units from a waypoint just outside a door is still inside the door, so the
# body turned for the next waypoint with the jamb beside it and walked into it.
# Traced on building 8 under the body sized grid: waypoint 2680,1256 outside a
# door 2655 to 2719, the crawler at 2685,1226 turned west for 2504,1256 and
# stood against the west jamb at 2670,1238 for the rest of the trial. A
# waypoint is done at 10 units, or at 30 when the body can go straight to the
# next one. navBody 0 restores the plain 30.
SubRx @'
    while(e.pathI<e.path.length-1&&dist(e,e.path[e.pathI])<30) e.pathI++;
    var _fwp=e.path[e.pathI];
'@ @'
    while(e.pathI<e.path.length-1){ var _dwf=dist(e,e.path[e.pathI]);
      if(_dwf<10||(_dwf<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
    var _fwp=e.path[e.pathI];
'@
SubRx @'
  while(e.pathI<e.path.length-1&&dist(e,e.path[e.pathI])<30) e.pathI++;
  var wp=e.path[e.pathI];
'@ @'
  // v11.15: done at 10, or at 30 when the body can go straight to the next
  // waypoint. At 30 alone a body just short of a door turned for the next
  // waypoint with the jamb beside it and walked into the jamb.
  while(e.pathI<e.path.length-1){ var _dw=dist(e,e.path[e.pathI]);
    if(_dw<10||(_dw<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
  var wp=e.path[e.pathI];
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
