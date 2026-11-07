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

# HEALING SLOWS AND BIG HITS INTERRUPT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SPEED_FLOOR=46;
'@ @'
var SPEED_FLOOR=46;
// v28.xx (cw-cx-healrisk): his g-2 "Half speed" and g-5 "Only a big hit stops it" (10-25).
const HEAL_MOVE=0.5;
'@

SubRx @'
function damagePlayer(amt,src,srcName,sx,sy){
'@ @'
// v28.xx (cw-cx-healrisk): shared incoming-hit threshold, before difficulty, kid mode and armour.
const BIG_HIT=30;
function bigHit(a){ return a>=BIG_HIT; }
function damagePlayer(amt,src,srcName,sx,sy){
  var amt0=amt; // v28.xx (cw-cx-healrisk): retain the incoming blow before every damage cut.
'@

SubRx @'
  p.hitAge=0; p.hitDX=(typeof sx==='number'&&isFinite(sx))?((p.x>=sx)?1:-1):0;   // v32.xx (cw-playerstates), a12 B: the white flash is timed from the hit and the recoil goes away from the shot
'@ @'
  p.hitAge=0; p.hitDX=(typeof sx==='number'&&isFinite(sx))?((p.x>=sx)?1:-1):0;   // v32.xx (cw-playerstates), a12 B: the white flash is timed from the hit and the recoil goes away from the shot
  // v28.xx (cw-cx-healrisk): a landed big hit spends the medical wind-up; plates and flowing heals continue.
  if(p.hp>0&&p.prep&&bigHit(amt0)){ p.prep=null; if(!G.sim) say('heal interrupted','warn'); }
'@

SubRx @'
mg===0||p.downed||p.ads||p.stam<=2||p.stamLock||p.stamRelease||p.shotSprintRelease
'@ @'
mg===0||p.downed||p.ads||p.prep||p.stam<=2||p.stamLock||p.stamRelease||p.shotSprintRelease
'@

SubRx @'
mg===0||p.downed||p.ads||p.stam<=2||p.stamLock||p.stamRelease)
'@ @'
mg===0||p.downed||p.ads||p.prep||p.stam<=2||p.stamLock||p.stamRelease)
'@

SubRx @'
if(_shHeld&&mg>0&&G.crouchTog&&!p.downed&&p.stam>2
'@ @'
if(_shHeld&&mg>0&&G.crouchTog&&!p.downed&&!p.prep&&p.stam>2
'@

SubRx @'
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
'@ @'
var sprint=_shHeld&&p.stam>2&&!p.stamLock&&!p.stamRelease&&!crouch&&mg>0;
  if(p.prep) sprint=false; // v28.xx (cw-cx-healrisk): medical wind-ups, including teammate aid, never sprint.
'@

SubRx @'
  if(p.ads) spd*=.62;
'@ @'
  if(p.ads) spd*=.62;
  if(p.prep) spd*=HEAL_MOVE; // v28.xx (cw-cx-healrisk): only the medical wind-up, before the existing speed floor.
'@

SubRx @'
var VER='37.48';
'@ @'
var VER='37.49';
'@

$pat = "(?m)^  now:'v37\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.49: Medical wind-ups move at half speed without sprint. A landed incoming hit of 30 or more cancels the wind-up and spends the item. Plates and flowing heals keep their rules. Check 37.49 fails on v37.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
