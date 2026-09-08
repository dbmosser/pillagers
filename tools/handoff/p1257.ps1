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

# FROM THE 2026-09-06 READ-ONLY IN-RAID AUDIT (P2). This is the last finding of
# that run that is still live.
#
# The game keeps ONE pointer at "the extraction that matters", and it is set by
# standing in a ring. Walk into any other open ring while your own extraction is
# inbound and the pointer moves to the one under your feet, which has nothing
# coming. From that moment the banner names the wrong ring, the middle of the
# screen offers you a hold over a ring with nothing arriving, the approach pings
# and the last-seconds warning go quiet because they are watching the ring you
# are standing in, and holding E there starts a FRESH call while the one you
# already paid for lands somewhere else and leaves without you. A man on the
# floor has his surrender refused against the wrong ring too, which is the guard
# v12.47 gave words to.
#
# It needs no deliberate double call. A pillager can open a second ring himself.
SubRx @'
  if(z&&z.open) G.active=z;
'@ @'
  // v12.57, 2026-09-06 in-raid audit: STANDING SOMEWHERE DOES NOT STEAL THE
  // POINTER FROM AN EXTRACTION THAT IS ALREADY RUNNING. This line adopts the
  // ring under his feet, which is right when nothing is happening and wrong the
  // moment something is: walking through another open ring while his own
  // extraction was inbound moved the pointer to a ring with nothing coming, and
  // then the banner, the middle of the screen, the approach pings, the
  // last-seconds warning and the surrender guard were all watching the wrong
  // door while the one he paid for left without him. A ring with a live
  // countdown or a window still running keeps the pointer; CALLING moves it,
  // which is below, because that is a choice he made rather than a place he
  // walked through.
  var _aLive=(G.active&&((G.active.beaconT!==null&&G.active.beaconT!==undefined)||
              (G.active.hold!==undefined&&G.active.hold!==null&&G.active.hold>0)));
  if(z&&z.open&&(!_aLive||z===G.active)) G.active=z;
'@

SubRx @'
      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
'@ @'
      G.active=z;   // v12.57: calling it MOVES the pointer, which standing in it no longer does
      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
'@

# NEW IN.
SubRx @'
  'Q MOVES THE BELT AS WELL AS YOUR HAND. Choosing a different grenade used to leave the tactical belt highlighting the cell you were no longer holding, so the caption named one grenade and the trigger threw another.',
'@ @'
  'Q MOVES THE BELT AS WELL AS YOUR HAND. Choosing a different grenade used to leave the tactical belt highlighting the cell you were no longer holding, so the caption named one grenade and the trigger threw another.',
  'WALKING THROUGH ANOTHER EXTRACTION POINT NO LONGER ABANDONS YOUR OWN. The game follows one point at a time, and standing in a second open one used to move everything onto it: the banner, the prompt, the approach pings and the last-seconds warning, while the extraction you had already called left without you.',
'@

# STAMPS.
SubRx @'
var VER='12.56';
'@ @'
var VER='12.57';
'@
SubRx @'
var WHATSNEW_VER='12.56';
'@ @'
var WHATSNEW_VER='12.57';
'@
$cnt=([regex]::Matches($s,"now:'v12\.56:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.56 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.56:[^']*'",{ param($m) "now:'v12.57: the last live finding of the 2026-09-06 read-only in-raid audit (P2). The game keeps ONE pointer at the extraction that matters, and it was set by standing in a ring. Walk into any other open ring while your own extraction is inbound and the pointer moved to the one under your feet, which has nothing coming: from that moment the banner named the wrong ring, the middle of the screen offered a hold over a ring with nothing arriving, the approach pings and the last-seconds warning went quiet because they were watching the ring he was standing in, and holding E there started a FRESH call while the one he had already paid for landed somewhere else and left without him. A man on the floor had his surrender refused against the wrong ring too, which is the guard v12.47 gave words to. It needs no deliberate double call, because a pillager can open a second ring himself. A ring with a live countdown or a window still running now keeps the pointer, and CALLING moves it, which is a choice he made rather than a place he walked through. Check 12.57 calls one point, walks him into a second open one, and requires the pointer, the countdown and the ring the warning watches to all still be the one he called; a control with nothing running requires the pointer to follow him as it always has, and a third arm requires a deliberate call at the second point to move it; fails on v12.56.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
