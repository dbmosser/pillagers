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

# FROM THE 2026-09-06 READ-ONLY IN-RAID AUDIT (P2 WRONG STATE, verified by
# reading at v12.20): tryExtractTick runs tickExtractPoints first, whose
# mirror block hands the pointer and the clock to the ring that carries the
# beacon, and then, on the same frame, "if(z&&z.open) G.active=z" hands the
# pointer to whatever open ring the player is standing in, with no beacon
# test. So while the ship was inbound to ring A, standing in open ring B made
# B the active ring: the banner named B, the pointer swung to B, and the
# seconds it showed were still A's, because the mirror had just written them.
# The ring you stand in now wins only when it carries the beacon, or when no
# ring does; the ring you called keeps the pointer.
SubRx @'
  if(z&&z.open) G.active=z;
  else if(!G.active||!G.active.open){
'@ @'
  // v12.25: THE RING YOU CALLED KEEPS THE POINTER. Standing in a second open ring
  // used to make it the active one: the banner named it, the pointer swung to it,
  // and the seconds it showed were still the other ring's, because the mirror in
  // tickExtractPoints hands the clock to the beacon ring and this line ran after
  // it on the same frame. The ring you stand in wins only when it carries the
  // beacon, or when no ring does (2026-09-06 in-raid audit).
  var _zBeacon=!!(z&&z.beaconT!==null&&z.beaconT!==undefined);
  var _aBeacon=!!(G.active&&G.active.open&&G.active.beaconT!==null&&G.active.beaconT!==undefined);
  if(z&&z.open&&(_zBeacon||!_aBeacon)) G.active=z;
  else if(!G.active||!G.active.open){
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE RING YOU CALLED KEEPS THE POINTER. Standing in a second open ring while the ship is inbound no longer swings the banner and the arrow to the ring you are in.',
'@

# STAMPS.
SubRx @'
var VER='12.24';
'@ @'
var VER='12.25';
'@
SubRx @'
var WHATSNEW_VER='12.24';
'@ @'
var WHATSNEW_VER='12.25';
'@
$cnt=([regex]::Matches($s,"now:'v12\.24:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.24 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.24:[^']*'",{ param($m) "now:'v12.25: in-raid audit: standing in a second open ring while the ship was inbound to another made the second ring the active one, so the banner and the pointer named a ring no ship was coming to, with the seconds of the ring you had called. The ring you stand in wins the pointer only when it carries the beacon or no ring does. Check 12.25 calls a beacon at one ring, stands the player in another open ring, ticks, and requires the called ring to stay active with its clock; and with no beacon anywhere requires the ring stood in to win; fails on v12.24.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
