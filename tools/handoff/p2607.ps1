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

# LIGHTER SIEGE AT EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function siegeBase(GR){ return 5+7*GR; }
'@ @'
// v26.xx (siegelite), HIS NOTE (2026-10-13), after a raid he enjoyed ("that last game felt really good overall"): "maybe too many bots at
// extract but thats it". Then, on how the haul sizes the siege: "enemy multipler due tyo haul size should be marginal and/or cappeeed",
// and "no cap should be like an extra 5 enemies". Balancing is allowed (his ruling of 2026-10-02). WHAT WAS WRONG: the siege was
// 5 + 7 x greed machines at the Standard dial (3 to 7 at the shipped Light dial), arriving one every 12.6 s at a light haul down to one
// every 5.7 s at a full one, and the arcade wave director dropped its own packs (2 to 6 bodies, bigger with the score) at the ring on top
// of it, so a high score met 15 machines in the 30 s wait. WHAT IT IS NOW: THE SIEGE IS A FLAT BASE PLUS A CAPPED SHARE FOR THE HAUL.
// SIEGE_FLAT is the base and SIEGE_HAUL_CAP the most a full haul can add on top of it, both counted in machines AT THE SHIPPED DIAL
// (SIEGE_DIAL, the 0.6 Light setting), so a retune is one number and siegeVol still scales the whole thing from there. The arrival
// interval barely moves with the haul (SIEGE_IV less SIEGE_IV_HAUL x greed, in Standard seconds). siegeBase stays "the size at the
// Standard dial" for its four readers (the arrival ceiling, the pull ceiling, a linked window's copy and the settings rows). While any
// ring is called the wave director holds its spawns (siegeCalled). Nothing here draws from the seeded stream.
var SIEGE_FLAT=1.6, SIEGE_HAUL_CAP=5, SIEGE_DIAL=0.6, SIEGE_IV=6.4, SIEGE_IV_HAUL=2.0;
function siegeBase(GR){ return (SIEGE_FLAT+SIEGE_HAUL_CAP*clamp(GR,0,1))/SIEGE_DIAL; }
function siegeIvOf(GR){ return SIEGE_IV-SIEGE_IV_HAUL*clamp(GR,0,1); }
// Is any ring called right now, from the call through the 30 s boarding window? beaconT is a number from the call until the window
// closes and null otherwise.
function siegeCalled(){
  var i, b;
  if(!G||!G.zones) return false;
  for(i=0;i<G.zones.length;i++){ b=G.zones[i].beaconT; if(b!==null&&b!==undefined) return true; }
  return false;
}
'@

SubRx @'
  var siegeIv=(8-4.6*GR)/_sv85, siegeCap=Math.round(siegeBase(GR)*_sv85);
'@ @'
  var siegeIv=siegeIvOf(GR)/_sv85, siegeCap=Math.round(siegeBase(GR)*_sv85);
'@

SubRx @'
    iv=(8-4.6*GR)/sv; cap=Math.round(siegeBase(GR)*sv);
'@ @'
    iv=siegeIvOf(GR)/sv; cap=Math.round(siegeBase(GR)*sv);
'@

SubRx @'
  WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0);
'@ @'
  // v26.xx (siegelite), HIS NOTE (2026-10-13): "maybe too many bots at extract". A CALLED RING HOLDS THE WAVE DIRECTOR. The packs landed 770
  // to 1,060 from him at the ring on top of the siege (a high score met 10 wave bodies and 5 siege machines in the 30 s wait). From the
  // call to the end of the boarding window nothing new spawns and the clock stands still, so the first pack after a missed window is
  // the one that was due. Both modes: DEMO and CAREER run this same tick.
  if(siegeCalled()) return 0;
  WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0);
'@

SubRx @'
  G.waveT=(G.waveT||0)+dt;
'@ @'
  if((G.arcade||G.career)&&siegeCalled()) return;   // v26.xx (siegelite): reinforcements hold while a ring is called, as the packs do (arcadeWaveTick)
  G.waveT=(G.waveT||0)+dt;
'@

SubRx @'
var VER='26.06';
'@ @'
var VER='26.07';
'@

$pat = "(?m)^  now:'v26\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.07: Calling extraction brings fewer machines: a flat base plus a few more for a big haul (at most 5), and new waves hold off until the ship has gone or the window has closed. Check 26.07 fails on v26.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
