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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2), specced from the source. THIS IS THE
# REMAINING HALF OF HIS 2026-09-06 NOTE, and my own v12.00 entry named it as not
# verified.
#
# The Howler blast has three gates and none of them is a wall. It asks how far
# away you are, whether you are already down, and whether the shell burst on a
# roof over your head. A shell that lands in the STREET has no roof, so that
# gate is inert, and the blast then reaches 90 units in every direction through
# anything at all. Duck into a building with the shell already in the air and it
# lands where it was aimed, outside; standing forty units inside a solid wall you
# lose about twenty health through masonry, with the hit ring pointing at a burst
# you cannot see.
#
# The frag blast four lines above tests the line of sight for exactly this, for
# the player and for every entity. That is the game's own rule. The Howler never
# had it.
SubRx @'
  if(dp<R&&!p.downed&&!(_onRoof&&underSameRoof(_roof,p.x,p.y)))
    damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
'@ @'
  // v12.49, 2026-09-07 audit: A BLAST STOPS AT A WALL, which is the rule the
  // frag four lines above has always followed. The three gates here were the
  // distance, being down already, and the v10.63 roof, and that roof gate is
  // inert whenever the shell lands in the open, so a burst in the street reached
  // ninety units through masonry: duck inside with a shell already in the air
  // and it lands where it was aimed, outside, and takes about twenty health off
  // a man standing forty units behind a solid wall, with the hit ring pointing
  // at something he cannot see. The roof rule is untouched and still does its
  // own job, which is a shell landing ON a building sparing the room below.
  if(dp<R&&!p.downed&&!(_onRoof&&underSameRoof(_roof,p.x,p.y))&&
     losClear(SH.tx,SH.ty,p.x,p.y,G.map.segs))
    damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
'@

SubRx @'
    if(de<R+e.r){
'@ @'
    // v12.49: and the same rule for everyone else in the street, as the frag
    // already does for them. A wall that stops it reaching him stops it
    // reaching a pillager sheltering behind the same wall.
    if(de<R+e.r&&losClear(SH.tx,SH.ty,e.x,e.y,G.map.segs)){
'@

# NEW IN.
SubRx @'
  'ONE WORD PER THING, ON THIS CARD TOO. Five older entries here still used words you retired: the extraction called a vehicle in three places, and the tactical belt called by its old name in one. They use your words now, and a check holds the whole card to the list from here on.',
'@ @'
  'ONE WORD PER THING, ON THIS CARD TOO. Five older entries here still used words you retired: the extraction called a vehicle in three places, and the tactical belt called by its old name in one. They use your words now, and a check holds the whole card to the list from here on.',
  'A HOWLER SHELL NO LONGER REACHES THROUGH A WALL. A shell bursting in the street took about twenty health off you standing well inside a building, with the hit ring pointing at something you could not see. Walls stop the blast now, exactly as they stop a frag.',
'@

# STAMPS.
SubRx @'
var VER='12.48';
'@ @'
var VER='12.49';
'@
SubRx @'
var WHATSNEW_VER='12.48';
'@ @'
var WHATSNEW_VER='12.49';
'@
$cnt=([regex]::Matches($s,"now:'v12\.48:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.48 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.48:[^']*'",{ param($m) "now:'v12.49: 2026-09-07 audit (P2), the remaining half of his 2026-09-06 note, and my own v12.00 entry named it as not verified. The Howler blast had three gates and none of them was a wall: how far away you are, whether you are already down, and whether the shell burst on a roof over your head. A shell landing in the STREET has no roof, so that gate is inert, and the blast then reached ninety units in every direction through anything at all. Duck into a building with a shell already in the air and it lands where it was aimed, outside; standing forty units inside a solid wall you lost about twenty health through masonry, with the hit ring pointing at a burst you could not see. The frag blast four lines above tests the line of sight for exactly this, for the player and for every entity, so this is the game agreeing with itself rather than a new rule. The roof rule is untouched and still does its own job. Honestly: buildings now protect you from a Howler the way they always looked as though they did, which makes cover worth more than it was. Check 12.49 finds a solid stretch of a real building wall, bursts a shell seventy units outside it and requires the man forty units inside to lose nothing, with two controls: the same shell with him standing in the open the other side must hurt, and a pillager behind the same wall must be spared too; fails on v12.48.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
