$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# A HIT CLOSES THE MAP AND THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(p.iv>0) return;
  padRumble(Math.min(1,0.3+amt/40)
'@ @'
  if(p.iv>0) return;
  // v21.76, HIS NOTES (2026-10-09): "if player has the map open and takes damage, map should auto close" and "same for backpack".
  // A hit that lands shuts the map and the backpack, so the fight is on screen the moment it reaches you. A drag in the backpack is
  // dropped where it started, as ESC drops it. Live play only: the bot never opens either.
  if(!G.sim&&(G.mapOpen||G.bagOpen)){ G.mapOpen=false; G.mapCur=null; if(G.bagOpen){ G.bagOpen=false; G.drag=null; } }
  padRumble(Math.min(1,0.3+amt/40)
'@

SubRx @'
var VER='21.75';
'@ @'
var VER='21.76';
'@

$pat = "(?m)^  now:'v21\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.76: Taking a hit now closes the map and the backpack, so you see the fight at once. Check 21.76 fails on v21.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
