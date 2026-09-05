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

# THE STORM STRIKE WARNING RING WAS DRAWN IN SCREEN SPACE WITH WORLD
# COORDINATES. Its comment says "World space, so it sits on the ground", but
# the block ran after the screen-space flash fillRect and never wrapped itself
# in the camera transform the way the pings block two hundred lines up does
# (wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy)). So wc.arc(_S.x,_S.y,...)
# put the ring at raw screen pixels of a world coordinate up to WORLD_W/H, off
# screen almost always, and STRIKE_R was not scaled by zoom. His v6.87
# telegraph did not appear where the 62-damage bolt lands. Wrap it, like the
# rings.
SubRx @'
  if(G.strikes&&G.strikes.length){
    for(var _si=0;_si<G.strikes.length;_si++){
'@ @'
  if(G.strikes&&G.strikes.length){
    wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);   // v11.35: on the ground, like the rings
    for(var _si=0;_si<G.strikes.length;_si++){
'@
SubRx @'
      }
    }
  }
  if(WX.lightning){
    G.lightning-=dt;
'@ @'
      }
    }
    wc.restore();
  }
  if(WX.lightning){
    G.lightning-=dt;
'@

# STAMPS.
SubRx @'
var VER='11.34';
'@ @'
var VER='11.35';
'@
SubRx @'
var WHATSNEW_VER='11.34';
'@ @'
var WHATSNEW_VER='11.35';
'@
SubRx @'
  'THE PAUSE SCREEN KEY LINE READS RIGHT. Two phrases I changed by mistake are back: E interact and CTRL / C crouch toggle. No change you would notice beyond those two words.',
'@ @'
  'THE LIGHTNING WARNING RING LANDS WHERE THE BOLT WILL. In a storm, the ring that shows where the next strike hits was drawn in the wrong place, off screen almost always, so the strike arrived with no warning. It sits on the ground now, closing as the strike nears.',
  'THE PAUSE SCREEN KEY LINE READS RIGHT. Two phrases I changed by mistake are back: E interact and CTRL / C crouch toggle. No change you would notice beyond those two words.',
'@
SubRx @'
  now:'v11.34: my own regression, caught by the full corpus. Rewriting the pause key line at v11.26 I changed "E interact" to "E search / call for extraction" and "crouch toggle" to "crouch on/off"; check v10.41 reads his words off the pause box and requires those two phrases, and the batched checks from v11.26 on never ran it, so the red shipped eight builds. Both phrases are back. Lesson: a build that edits a player-facing string a shipped check reads must run that check, or the full corpus.',
'@ @'
  now:'v11.35: the storm strike warning ring was drawn in screen space with world coordinates. Its comment claimed world space; the block ran after the screen-space flash and never wrapped itself in the camera transform the pings block uses, so the ring sat at raw screen pixels of a world point up to the map size, off screen almost always, and its radius was not zoom-scaled. His v6.87 telegraph did not appear where the 62-damage bolt lands. Wrapped in scale(Z)/translate now, on the ground like the rings. From the rendering agent; reproduced by tracing the arc transform.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
