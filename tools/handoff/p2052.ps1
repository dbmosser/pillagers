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

# NO STRIKES THROUGH WALLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(dist(sh,_me)>wep.rng+_me.r) continue;
        var _ma=Math.atan2(_me.y-sh.y,_me.x-sh.x);
        if(Math.abs(Math.atan2(Math.sin(_ma-base),Math.cos(_ma-base)))>0.9) continue;
'@ @'
        if(dist(sh,_me)>wep.rng+_me.r) continue;
        var _ma=Math.atan2(_me.y-sh.y,_me.x-sh.x);
        if(Math.abs(Math.atan2(Math.sin(_ma-base),Math.cos(_ma-base)))>0.9) continue;
        // v20.52, from the whole-game bug hunt of 2026-10-08 (H3): NO STRIKE THROUGH A WALL. The reach was measured centre to
        // centre with nothing in between, so a machine or a pillager just the other side of a building wall or a locked room
        // wall took the blow, sparked, turned on you, and a peaceful pillager in the next room charged you for it. A blow now
        // needs the same clear line a round needs (the map's own walls, so smoke and glass do not stop it), as the crawler and
        // Listener bites already do (v8.59).
        if(!losClear(sh.x,sh.y,_me.x,_me.y,G.map.segs)) continue;
'@

SubRx @'
var VER='20.51';
'@ @'
var VER='20.52';
'@

$pat = "(?m)^  now:'v20\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.52: Bare-hand strikes no longer hit through walls. Check 20.52 fails on v20.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
