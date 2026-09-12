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

# FINDING 8 OF THE 2026-09-11 AUDIT, and it costs him the whole backpack.
#
# WHAT HAPPENS. He calls extraction A and it is still inbound, so the pointer stays
# on A. A pillager has called ring C and C has already landed; riding out on someone
# else's call is intended play. He crosses to C, is dropped inside that ring with his
# self-revive already spent, and the screen goes to the downed overlay.
#
# WHAT THE OVERLAY SAYS IS THE OPPOSITE OF WHAT WOULD SAVE HIM. Holding E for 1.4
# seconds boards him at C with the full backpack, and the pull code finds the ring by
# the ring he is lying in, so it works. But every readout measures him against A, far
# away, still inbound. So there is no HOLD E TO EXTRACT: the overlay falls through to
# a line with no verb in it at all, "Nearest extraction is 0m away". The world-space
# [E] EXTRACT label that would have told him is suppressed while downed. And
# surrenderBlocked measures A too, so it says nothing is blocked and the overlay
# prints HOLD [SPACE] TO SURRENDER. Holding SPACE for 1.5 seconds kills him and loses
# everything, and SPACE is the only key named anywhere on that screen.
#
# WHY. The guard and the verb read the global pointer instead of the ring he is
# actually in. That is the exact rule v8.61 already settled for the pull itself: a
# pull belongs to the ring you are standing in. v12.81 exists so that "a hand resting
# on the space bar must not throw away a full bag in the one situation where being
# down ends well", and with two live beacons that guard was inert while the game
# offered the losing action and hid the winning one.
#
# THE FIX IS ONE RESOLVER, USED BY BOTH. standingRing walks the zones the way the
# pull does and falls back to the pointer when he is in none, so a single beacon
# behaves exactly as before and the multi-beacon case stops lying to him.
SubRx @'
function surrenderBlocked(){
  var p=G&&G.player; if(!p) return false;
  return !!(G.active&&G.beaconT!==null&&G.beaconT!==undefined&&G.beaconT<=0&&
    G.shipHold!==null&&G.shipHold!==undefined&&dist(p,G.active)<G.active.r);
}
'@ @'
// v12.94, audit finding 8: THE RING HE IS LYING IN, NOT THE ONE HE POINTED AT.
// The same scan the pull uses since v8.61, because the pull will board him at the
// ring he is inside whatever the pointer says, and every readout that disagreed
// with it was telling him the losing thing. Falls back to the pointer when he is
// in no ring at all, so the single-beacon case is unchanged in every particular.
function standingRing(){
  var p=G&&G.player; if(!p) return null;
  if(G.zones) for(var zi=0;zi<G.zones.length;zi++){
    var Z=G.zones[zi];
    if(Z.open!==false&&dist(p,Z)<Z.r) return Z;
  }
  return G.active||null;
}
// Whether that ring has a ship on the ground with a window still running, which is
// the state in which holding E ends the raid well.
function ringLanded(z){
  return !!(z&&z.beaconT!==null&&z.beaconT!==undefined&&z.beaconT<=0&&
            typeof z.hold==='number'&&z.hold>0);
}
function surrenderBlocked(){
  var p=G&&G.player; if(!p) return false;
  var z=standingRing();
  return !!(z&&ringLanded(z)&&dist(p,z)<z.r);
}
'@

SubRx @'
  function downedVerb(){
    if(G.over||G.beaconT===null||!G.active) return null;
    var _sd=(G.beaconT<=0&&G.shipHold!==null&&G.shipHold!==undefined);
    var _ir=dist(p,G.active)<G.active.r;
'@ @'
  function downedVerb(){
    // v12.94: the ring he is lying in owns this too. Reading the pointer meant a
    // man down inside a landed ring he had not called himself was shown no verb at
    // all, while the pull would have taken him.
    var _dz=(typeof standingRing==='function')?standingRing():G.active;
    if(G.over||!_dz) return null;
    if((_dz.beaconT===null||_dz.beaconT===undefined)&&(G.beaconT===null||!G.active)) return null;
    var _sd=(typeof ringLanded==='function')?ringLanded(_dz)
            :(_dz.beaconT<=0&&G.shipHold!==null&&G.shipHold!==undefined);
    var _ir=dist(p,_dz)<_dz.r;
'@

SubRx @'
    if((dist(p,G.active)-G.active.r)<=300)
      return {msg:'CRAWL TO THE RING',
              sub:_sd?('Extraction closes in '+fmtMS(Math.max(0,Math.ceil(G.shipHold)))):'Extraction inbound',
              col:'#ff5a4a'};
'@ @'
    if((dist(p,_dz)-_dz.r)<=300)
      return {msg:'CRAWL TO THE RING',
              sub:_sd?('Extraction closes in '+fmtMS(Math.max(0,Math.ceil(_dz.hold)))):'Extraction inbound',
              col:'#ff5a4a'};
'@

# NEW IN.
SubRx @'
  'THE LAST-MINUTE WARNINGS KNOW YOU ALREADY CALLED A RIDE.
'@ @'
  'GOING DOWN INSIDE A LANDED EXTRACTION SHOWS YOU THE WAY OUT, EVEN IF SOMEBODY ELSE CALLED IT. If you had one of your own still inbound, the downed screen measured that one instead: no HOLD E TO EXTRACT, no verb at all, and it offered you the surrender that ends the raid and loses the backpack. Holding E there would have carried you out with everything.',
  'THE LAST-MINUTE WARNINGS KNOW YOU ALREADY CALLED A RIDE.
'@

# STAMPS.
SubRx @'
var VER='12.93';
'@ @'
var VER='12.94';
'@
SubRx @'
var WHATSNEW_VER='12.93';
'@ @'
var WHATSNEW_VER='12.94';
'@
$cnt=([regex]::Matches($s,"now:'v12\.93:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.93 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.93:[^']*'",{ param($m) "now:'v12.94: finding 8 of the 2026-09-11 audit, and it costs him the whole backpack. He calls extraction A and it is still inbound, so the pointer stays on A; a pillager has called ring C and C has already landed, and riding out on somebody else call is intended play. He crosses to C, is dropped inside that ring with his self-revive already spent, and the screen goes to the downed overlay. What the overlay says is the opposite of what would save him: holding E for 1.4 seconds boards him at C with the full backpack, and the pull code finds the ring by the one he is lying in, so it works, but every readout measures him against A, far away and still inbound, so there is no HOLD E TO EXTRACT and the overlay falls through to a line with no verb in it at all, nearest extraction is 0m away. The world-space E EXTRACT label that would have told him is suppressed while downed, and surrenderBlocked measures A too, so it says nothing is blocked and the overlay prints HOLD SPACE TO SURRENDER; holding SPACE for 1.5 seconds kills him and loses everything, and SPACE is the only key named anywhere on that screen. The guard and the verb read the global pointer instead of the ring he is actually in, which is the exact rule v8.61 already settled for the pull itself, that a pull belongs to the ring you are standing in, and v12.81 exists so a hand resting on the space bar must not throw away a full bag in the one situation where being down ends well, which with two live beacons was inert while the game offered the losing action and hid the winning one. The fix is one resolver used by both: standingRing walks the zones the way the pull does and falls back to the pointer when he is in none, so the single-beacon case is unchanged in every particular and the multi-beacon case stops lying to him. Check 12.94 stages two rings, one his and still inbound and one landed that he did not call, lays him down inside the landed one with his revive spent, and requires the overlay to name the extract verb and the surrender to be blocked, with controls that a single landed ring he called himself still behaves exactly as v12.81 left it and that lying outside every ring still offers the surrender; fails on v12.93.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
