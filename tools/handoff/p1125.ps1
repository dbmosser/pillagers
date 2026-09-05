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

# THE DIAL. engageNear is the radius around the player inside which a pillager
# is allowed to fight at all: machines and rival crews alike. 600 is the world
# as shipped since v2.49 and stays the default under his no-balancing order;
# 0 lifts the gate everywhere, for his ruling.
SubRx @'
raiderFeud:1,raiderCrews:2,windows:1,
'@ @'
raiderFeud:1,raiderCrews:2,engageNear:600,windows:1,
'@

# SITE ONE: the ordered merc's engagement.
SubRx @'
  var p=G.player,mth=null,mtd=280;
  if(dist(e,p)<600)
  for(var mm=0;mm<G.ents.length;mm++){
'@ @'
  var p=G.player,mth=null,mtd=280;
  if(CFG.engageNear===0||dist(e,p)<CFG.engageNear)
  for(var mm=0;mm<G.ents.length;mm++){
'@

# SITE TWO: the feud, and the stale reason above it.
SubRx @'
// The 600 unit window around the player stays, and it is not a style choice:
// G.vseg only caches walls near the player, so losClear is only ANSWERABLE there.
// Beyond it raiders would trade shots through buildings. It also means feuds
// happen where they can be seen, which is the half of this that is worth having.
'@ @'
// The 600 unit window around the player was justified here as "G.vseg only
// caches walls near the player, so losClear is only answerable there". That
// stopped being true long ago: refreshVseg sets G.vseg to the WHOLE map's
// segments (plus smoke), so a sight test is answerable anywhere. v11.25: the
// window is CFG.engageNear, 600 as shipped, 0 lifts it; measured with the far
// seat of the pillager scorecard, a pillager out of the player's sight never
// fires a round in a whole raid while the machines fire 88 at him.
'@
SubRx @'
  var p=G.player;
  if(dist(e,p)>=600) return false;
'@ @'
  var p=G.player;
  if(CFG.engageNear!==0&&dist(e,p)>=CFG.engageNear) return false;
'@

# SITE THREE: the looting pillager's machine and rival picker.
SubRx @'
      // vseg only caches walls near the player, so LOS answers are only valid
      // there. Gated to 600, which is also the only place the fight can be seen.
      var mth=null,mtd=280;
      if(dist(e,p)<600)
'@ @'
      // Was gated to 600 units of the player on the claim that vseg only caches
      // walls near him; G.vseg is the whole map (refreshVseg), so the claim was
      // stale. v11.25: CFG.engageNear, 600 as shipped, 0 lifts the gate.
      var mth=null,mtd=280;
      if(CFG.engageNear===0||dist(e,p)<CFG.engageNear)
'@

# STAMPS.
SubRx @'
var VER='11.24';
'@ @'
var VER='11.25';
'@
SubRx @'
var WHATSNEW_VER='11.24';
'@ @'
var WHATSNEW_VER='11.25';
'@
SubRx @'
  'THE SCORECARD CAN WATCH THE CREWS FEUD TOO. Rival crews only pick fights within sight of you, by design, so the scorecard now has a seat in the middle of the map as well as one outside it. Checked: they do shoot each other where you can see it.',
'@ @'
  'FOUND: PILLAGERS OUT OF YOUR SIGHT NEVER FIRE BACK. A rule from the earliest builds only lets a pillager fight within 600 units of you, on a reason that stopped being true long ago. Out of your sight the machines shoot them and they never shoot back: zero rounds in a whole raid. Nothing changes yet; the switch and the numbers are on the board for a ruling.',
  'THE SCORECARD CAN WATCH THE CREWS FEUD TOO. Rival crews only pick fights within sight of you, by design, so the scorecard now has a seat in the middle of the map as well as one outside it. Checked: they do shoot each other where you can see it.',
'@
SubRx @'
  now:'v11.24: a correction to v11.23 and a second vantage point. v11.23 read zero pillager-on-pillager deaths off the raid with the player parked out of the world and called the feud system dead; feuds fire only within 600 units of the player, by design, because line of sight is only answerable near him. Parked in the middle of the map instead, rival crews shoot each other: hits, downs and deaths in one raid at peace with the machines. The scorecard hook takes a park option now, and a check holds the feud dial to that.',
'@ @'
  now:'v11.25: the 600 unit gate on pillager fighting is a rotted rule. Every site where a pillager may shoot a machine or a rival is gated to 600 units of the player, on the comment that the wall cache only covers that far; it covers the whole map. Machines hunt pillagers anywhere. Measured: out of the player sight a pillager fires zero rounds in a whole raid while the machines fire 88, and 33 of 40 die. New dial engageNear, 600 as shipped so nothing moves before the beta, 0 lifts it; both arms measured for his ruling.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
