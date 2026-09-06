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

# HIS NOTE, 2026-09-05 in-run at 71 s: "lightning shouldn't strike inside
# buildings". The storm (v6.87) rolls a strike point 180 to 800 units from
# the player in any direction and clamps it to the world; nothing asked
# whether that point was under a roof, so a strike could telegraph and land
# inside a shed he was looting. A point inside a building is now walked to
# its nearest wall and set outside it, by the crier's own deterministic step
# (v9.04), so no new random draw is made and the seeded stream is unchanged.
SubRx @'
    var sx=clamp(p.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(p.y+Math.sin(ang)*rad,80,WORLD_H-80);
    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0});
'@ @'
    var sx=clamp(p.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(p.y+Math.sin(ang)*rad,80,WORLD_H-80);
    // v11.56, HIS NOTE: "lightning shouldn't strike inside buildings". A point
    // under a roof is walked out through its nearest wall (the crier's own
    // deterministic step, no random draw), up to three times in case it
    // lands in a neighbour.
    for(var _sk=0;_sk<3;_sk++){
      var _sb=buildingAtPt(G.map,sx,sy);
      if(!_sb) break;
      var _so=outOfBuilding(_sb,sx,sy,40);
      sx=clamp(_so.x,80,WORLD_W-80); sy=clamp(_so.y,80,WORLD_H-80);
    }
    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0});
'@

# STAMPS.
SubRx @'
var VER='11.55';
'@ @'
var VER='11.56';
'@
SubRx @'
var WHATSNEW_VER='11.55';
'@ @'
var WHATSNEW_VER='11.56';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'LIGHTNING NO LONGER STRIKES INSIDE A BUILDING. A strike that would have landed under a roof lands just outside its nearest wall instead.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.55:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.55 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.55:[^']*'",{ param($m) "now:'v11.56: HIS NOTE of 2026-09-05, lightning should not strike inside buildings. The storm rolled a point 180 to 800 units from the player with no roof test. A point inside a building is walked out through its nearest wall by outOfBuilding (deterministic, no new random draw), up to three times. Check 11.56 stands the player in a building under a forced storm, spawns sixty strike points, requires none inside a building and at least twenty spawned; fails on the v11.55 fixture where some land indoors. Not moved: the blast radius, which still reaches through a wall.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
