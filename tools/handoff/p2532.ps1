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

# A KEY AT ITS DOOR SOUNDS LIKE A LOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function doorKeyIx(door){
'@ @'
// v25.32 (usefoleyf), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". A KEY AT ITS DOOR SOUNDS
// LIKE A LOCK. Spending a key or a Vault Keycard at a locked door played the menu chirp, and the heavy door itself made no sound.
// Now (the v25.20 bank) the card swipes and the reader beeps twice in your ears, then at the door the bolts throw and the heavy
// door grinds open; an arcade vault door is lower, longer and heavier and ends on the slab seating. The door sounds are placed at
// the door (earsOf, through-the-wall muffle) and your teammates hear them there. Cosmetic only: no seeded draw, nothing under
// G.sim, no game state.
function doorFoley(D){
  if((G&&G.sim)||typeof foley!=='function'||!D) return false;
  var big=!!(G.arcade&&D.arc), x=D.doorX, y=D.doorY;
  foley('pickup',null,null,{rate:1.8,g:0.5,dur:0.1,local:1});
  foley('keyBeep',null,null,{at:0.08});
  foley('keyBeep',null,null,{at:0.2,rate:1.12,gap:0,local:1});
  if(isFinite(x)&&isFinite(y)){
    foley('boltLatch',x,y,{at:0.22,rate:big?0.6:0.8,g:big?1.2:1});
    foley('doorHeavy',x,y,{at:0.3,rate:big?0.7:0.95,g:big?1.25:1});
    if(big) foley('lmgClack',x,y,{at:0.9,rate:0.6,g:1});
  }
  return true;
}
function doorKeyIx(door){
'@

SubRx @'
      say((doorNear.name+' open').toUpperCase(),'obj',_vop); blip('pick'); ping(
'@ @'
      say((doorNear.name+' open').toUpperCase(),'obj',_vop); if(!doorFoley(doorNear)) blip('pick'); ping(
'@

SubRx @'
var VER='25.31';
'@ @'
var VER='25.32';
'@

$pat = "(?m)^  now:'v25\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.32: A key or keycard at a locked door now swipes and beeps, then the bolts throw and the heavy door opens. Check 25.32 fails on v25.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
