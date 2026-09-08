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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2), specced from the source.
#
# Loaded rounds live in exactly two places, the primary count and the secondary
# count, and the backpack holds a bare key string with nowhere for a number to
# live. So a gun that went into the backpack left its magazine nowhere at all:
# thirty loaded rounds simply stopped existing. Taking it back out handed it
# half a magazine conjured from nothing, which does not come out of the reserve.
# Both halves are wrong and they point opposite ways: stow a full gun and lose
# the load, stow an empty one and gain half a magazine, over and over.
#
# The queue below is per gun id because that is exactly as precise as the
# backpack itself: it holds keys, not instances, so two identical rifles in
# there are already indistinguishable and first in, first out is the truest
# answer available. A gun FOUND in the field has no entry and still comes back
# on half a magazine, which is his rule and is not touched here.
SubRx @'
function bagHeldGun(slot){
'@ @'
// v12.42, 2026-09-07 audit: A STOWED GUN KEEPS ITS ROUNDS. Loaded rounds live
// only in p.ammo and p.secAmmo, and the backpack holds a bare key string with
// nowhere for a number, so a gun put in the bag left its magazine nowhere at
// all and came back with a fresh half magazine that no reserve paid for. Stow a
// full gun and the load vanished; stow an empty one and half a magazine
// appeared, as often as you liked. The rounds ride here between the two verbs.
// Per gun id, because the bag holds keys and not instances: two identical
// rifles in there are already indistinguishable, so first in first out is the
// truest answer that exists. A gun FOUND in the field has no entry and still
// comes back on half a magazine, which is his rule and is untouched.
function stowRounds(id,n){
  var m=(G.stowAmmo=G.stowAmmo||{});
  (m[id]=m[id]||[]).push(Math.max(0,n|0));
}
function takeRounds(id,mag){
  var m=G.stowAmmo, q=m&&m[id];
  if(q&&q.length) return Math.min(mag,Math.max(0,q.shift()|0));
  return Math.ceil(mag/2);
}
function bagHeldGun(slot){
'@

SubRx @'
  G.bag.push('gun_'+g.id);
'@ @'
  G.bag.push('gun_'+g.id);
  stowRounds(g.id,isHand?p.ammo:p.secAmmo);   // v12.42: the load goes with it
'@

SubRx @'
    else G.bag.push('gun_'+oldW.id);
'@ @'
    else { G.bag.push('gun_'+oldW.id); stowRounds(oldW.id,toSec?p.secAmmo:p.ammo); }   // v12.42: and the displaced gun keeps its load too
'@

SubRx @'
            G.bag.push('gun_'+p.wep.id);
'@ @'
            G.bag.push('gun_'+p.wep.id);
            stowRounds(p.wep.id,p.ammo);   // v12.42: the gun a field pickup displaces keeps its load
'@

SubRx @'
  if(toSec){ p.sec=g; p.secAmmo=Math.ceil(g.mag/2); p.secIssued=false; p.secFromArmory=false; }
  else { p.wep=g; p.ammo=Math.ceil(g.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; }
'@ @'
  // v12.42: what it came in with, if this is a gun that was stowed; half a
  // magazine only for one found in the field, which is the rule in the README.
  var _rd=takeRounds(gk,g.mag);
  if(toSec){ p.sec=g; p.secAmmo=_rd; p.secIssued=false; p.secFromArmory=false; }
  else { p.wep=g; p.ammo=_rd; p.wepIssued=false; p.wepFromArmory=false; p.reloading=0; }
'@

# NEW IN.
SubRx @'
  'AN EMPTY CELL SPENDS NOTHING FROM ANOTHER CELL. The G key on a cell you had nothing in used to quietly walk to the next grenade you did have and throw that one, while the belt still named the cell you pressed. It names what is missing and puts your gun up. Q still cycles.',
'@ @'
  'AN EMPTY CELL SPENDS NOTHING FROM ANOTHER CELL. The G key on a cell you had nothing in used to quietly walk to the next grenade you did have and throw that one, while the belt still named the cell you pressed. It names what is missing and puts your gun up. Q still cycles.',
  'A GUN YOU STOW KEEPS ITS ROUNDS. Putting a gun in your backpack used to throw away the magazine in it, and taking one back out handed you half a magazine that no reserve paid for. A gun you find in the field still comes up on half a magazine.',
'@

# STAMPS.
SubRx @'
var VER='12.41';
'@ @'
var VER='12.42';
'@
SubRx @'
var WHATSNEW_VER='12.41';
'@ @'
var WHATSNEW_VER='12.42';
'@
$cnt=([regex]::Matches($s,"now:'v12\.41:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.41 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.41:[^']*'",{ param($m) "now:'v12.42: 2026-09-07 audit (P2). Loaded rounds live in exactly two places, the primary count and the secondary count, and the backpack holds a bare key string with nowhere for a number to live. So a gun that went into the backpack left its magazine nowhere at all: thirty loaded rounds stopped existing. Taking it back out handed it half a magazine conjured from nothing, which no reserve paid for. Both halves are wrong and they point opposite ways: stow a full gun and lose the load, stow an empty one and gain half a magazine, as often as you like. The rounds now ride between the two verbs in a queue kept per gun id, which is exactly as precise as the backpack itself, since it holds keys and not instances and two identical rifles in there are already indistinguishable. Three doors put a gun in the backpack and all three now carry its load: the belt drag, the swap that displaces a gun, and the field pickup that stows the gun in your hands. A gun FOUND in the field has no entry and still comes back on half a magazine, which is his rule and does not move. Check 12.42 measures loaded plus reserve as one conserved number across a stow and an equip, on a full gun and on an empty one, and controls that a gun found in the field still arrives on half a magazine; fails on v12.41.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
