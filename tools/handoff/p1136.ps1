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

# A FRAG DRAGGED THE PEDDLER, THE STRAY AND DOWNED MEN INTO CHASE. explodeFrag
# set e.state='chase' and overwrote e.tx/e.ty on every entity in the blast,
# with no guard. The Peddler's tx/ty ARE his pitch, so a charge near his stall
# relocated the stall to the blast and left him chasing for the rest of the
# raid; a downed pillager stood back up into a chase. The damage and the
# notoriety (his v8.30 ruling that a frag can kill and aggro a neutral) stay;
# only the stand-up-and-chase is guarded.
SubRx @'
      if(e.state!=='alarm'){
        e.state='chase'; e.alert=2.5;
        if(_fMine){ e.tx=p.x; e.ty=p.y; } else { e.tx=f.x; e.ty=f.y; }
      }
'@ @'
      // v11.36: a blast does not stand a bystander or a downed man up into a
      // chaser. The Peddler and the Stray are fixtures (the Peddler's tx/ty ARE
      // his pitch, so overwriting them moved his stall to the blast), and a
      // downed pillager is out until he bleeds or is picked up. They keep the
      // damage and the notoriety above; they just do not give chase.
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed){
        e.state='chase'; e.alert=2.5;
        if(_fMine){ e.tx=p.x; e.ty=p.y; } else { e.tx=f.x; e.ty=f.y; }
      }
'@

# STAMPS.
SubRx @'
var VER='11.35';
'@ @'
var VER='11.36';
'@
SubRx @'
var WHATSNEW_VER='11.35';
'@ @'
var WHATSNEW_VER='11.36';
'@
SubRx @'
  'THE LIGHTNING WARNING RING LANDS WHERE THE BOLT WILL. In a storm, the ring that shows where the next strike hits was drawn in the wrong place, off screen almost always, so the strike arrived with no warning. It sits on the ground now, closing as the strike nears.',
'@ @'
  'A GRENADE NO LONGER SENDS THE PEDDLER CHASING YOU. A charge that went off near the Peddler used to make him abandon his stall and chase, for the rest of the raid, and move his stall to where you stood. He stays put now, and a downed pillager stays down.',
  'THE LIGHTNING WARNING RING LANDS WHERE THE BOLT WILL. In a storm, the ring that shows where the next strike hits was drawn in the wrong place, off screen almost always, so the strike arrived with no warning. It sits on the ground now, closing as the strike nears.',
'@
SubRx @'
  now:'v11.35: the storm strike warning ring was drawn in screen space with world coordinates. Its comment claimed world space; the block ran after the screen-space flash and never wrapped itself in the camera transform the pings block uses, so the ring sat at raw screen pixels of a world point up to the map size, off screen almost always, and its radius was not zoom-scaled. His v6.87 telegraph did not appear where the 62-damage bolt lands. Wrapped in scale(Z)/translate now, on the ground like the rings. From the rendering agent; reproduced by tracing the arc transform.',
'@ @'
  now:'v11.36: explodeFrag set state chase and overwrote tx/ty on every entity in the blast with no guard, so a charge near the Peddler made him abandon his stall and chase for the rest of the raid, moving his pitch (which IS his tx/ty) to the blast, and a downed pillager stood up into a chase. Reproduced: a frag by the stall took the Peddler from idle to chase. The chase now skips the Peddler, the Stray and downed men; the damage and the v8.30 notoriety stay. From the combat agent.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
