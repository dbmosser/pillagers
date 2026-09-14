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

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 2: THE RAID CLOCK KILLED A BOARDING HOLD THE
# WINDOW HAD ACCEPTED. Holding E in a landed ring takes 1.4 seconds, longer with a slowing drink,
# and v11.98 keeps the window alive for as long as he keeps pulling. But the frame loop tests the
# raid clock before updatePlayer runs, so when the clock reached zero with a ship down and the
# pull at 1.3 of 1.4, it ended the raid as a death by the timer: the whole backpack and his
# armoury guns lost, standing in a landed ring with E held. A ship landing in the last seconds
# made the whole last 1.4 seconds a dead zone. Now a hold already running in a landed ring
# is let finish: the clock rests at zero, the pull completes or is released, and a released
# pull meets the clock on the next frame exactly as before.
SubRx @'
    if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking&&(G.sim||G.beaconT!==null)){
'@ @'
    // v13.79, downed and extraction audit: a boarding hold already running in a landed ring
    // finishes. The clock rests at zero while he pulls; let go, and the next frame ends it.
    var _bz=standingRing(), _boarding=!!(_bz&&ringLanded(_bz)&&(_bz.pullT||0)>0&&dist(G.player,_bz)<_bz.r);
    if(_boarding&&CFG.raidSec>0&&G.timeLeft<0) G.timeLeft=0;
    if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking&&!_boarding&&(G.sim||G.beaconT!==null)){
'@
SubRx @'
    } else if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking){
'@ @'
    } else if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking&&!_boarding){
'@
SubRx @'
var VER='13.78';
'@ @'
var VER='13.79';
'@

$pat = "(?m)^  now:'v13\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.79: THE CLOCK LETS A BOARDING HOLD FINISH. Downed and extraction audit of 2026-09-14, finding 2: the frame loop tests the raid clock before updatePlayer, so a hold E already running in a landed ring was ended as a death by the timer when the clock reached zero at 1.3 of 1.4, losing the backpack and the guns while standing in the ring. While a hold is running in a landed ring the clock now rests at zero and the pull finishes or is released; a released pull meets the clock the next frame as before. Check 13.79 holds E in a landed ring with one second left and requires an extraction, with five seconds left as the control; it fails on v13.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
