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

# HIS ORDER, 2026-09-06 about 14:20: "if extraction is open to extract and
# the 30 second extraction counter is counting down and player starts
# extracting before it finishes, then player should still be able to extract
# even if counter hits zero so long as player started holding E before
# counter hit zero". The boarding window shut on the frame it reached zero
# and wiped the pull with it. A pull already in progress now finishes: the
# window holds at its last instant while E is held inside the ring, and the
# moment the hold is released the window shuts as before.
SubRx @'
    if(z.hold<=0){
      z.beaconT=null; z.hold=null; z.pullT=null;
      if(z===G.active){ G.beaconT=null; G.shipHold=null; }
'@ @'
    // v11.98, HIS ORDER: a hold that began before the window shut finishes.
    // The pull is cleared the frame E is released (tryExtractTick), so the
    // window can outlive its clock only for as long as he keeps pulling.
    if(z.hold<=0&&(z.pullT||0)>0&&dist(p,z)<z.r) z.hold=0.01;
    if(z.hold<=0){
      z.beaconT=null; z.hold=null; z.pullT=null;
      if(z===G.active){ G.beaconT=null; G.shipHold=null; }
'@

# STAMPS.
SubRx @'
var VER='11.97';
'@ @'
var VER='11.98';
'@
SubRx @'
var WHATSNEW_VER='11.97';
'@ @'
var WHATSNEW_VER='11.98';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A HOLD YOU STARTED BEFORE THE EXTRACTION WINDOW SHUT FINISHES: keep holding E and the ship waits for you; let go and it is gone.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.97:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.97 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.97:[^']*'",{ param($m) "now:'v11.98: HIS ORDER of 2026-09-06, a hold started before the boarding window shut must still extract. The window held at its last instant while a pull is in progress inside the ring; releasing E shuts it as before. Check 11.98 opens the window with half a second left, starts a pull, steps past zero with E held and requires the raid to end EXTRACTED; and calls the ship from the edge of the ring (70 of 78) to show a call works anywhere inside; fails on v11.97.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
