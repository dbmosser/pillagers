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

SubRx @'
function elapsed(){
  if(!G) return 0;
  if(CFG.raidSec<=0) return G.t||0;
'@ @'
// v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The raid timer dial in the tuning console is marked
// NEXT RAID, but every live reader of the clock asked CFG.raidSec, which the console, Reset all and a preset all write at once.
// On a raid built with the clock OFF (timeLeft 0), moving that dial to any number, or Reset all, or a preset, made the first
// unpaused frame read an expired clock: the site burned, he went down and came back empty. The other way, a running 540 raid
// moved to OFF stopped its clock and froze the closing rings. G.raidLen is set once, in buildRaid beside timeLeft, and nothing
// changes it after, so it says whether THIS raid has a clock. CFG.raidSec is asked only when no raid carries one.
function raidClockOn(){ return (G&&typeof G.raidLen==='number')?G.raidLen>0:CFG.raidSec>0; }
function elapsed(){
  if(!G) return 0;
  if(!raidClockOn()) return G.t||0;
'@
SubRx @'
      say('Pulled. Inbound '+fmtMS(CFG.extractWait)+
          ((CFG.raidSec>0&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':', then hold E to extract.')+   // v12.24: not with the clock OFF
'@ @'
      // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The pull line asks this raid, not the dial, so a
      // dial moved mid-raid cannot warn of a clock the raid does not have, or stay quiet about one it does.
      say('Pulled. Inbound '+fmtMS(CFG.extractWait)+
          ((raidClockOn()&&G.timeLeft<CFG.extractWait)?'. The raid clock runs out first.':', then hold E to extract.')+   // v12.24: not with the clock OFF
'@
SubRx @'
z.hold=(CFG.raidSec>0)?Math.min(30,Math.max(3,G.timeLeft-1)):30;   // v12.24: with the clock OFF (v9.35) there is nothing to run out; timeLeft sits at 0 and used to read as one second left, so extraction left after three
'@ @'
    // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The 30 second window asks this raid, not the dial:
    // a raid with no clock moved to 540 mid-raid read its resting 0 as time running out and gave a three second window.
z.hold=(raidClockOn())?Math.min(30,Math.max(3,G.timeLeft-1)):30;   // v12.24: with the clock OFF (v9.35) there is nothing to run out; timeLeft sits at 0 and used to read as one second left, so extraction left after three
'@
SubRx @'
    if(CFG.raidSec>0&&z.hold>G.timeLeft) z.hold=Math.max(0.5,G.timeLeft);
'@ @'
    // v15.14, dials audit finding 6: and the clamp to the clock left asks the same raid, for the same reason.
    if(raidClockOn()&&z.hold>G.timeLeft) z.hold=Math.max(0.5,G.timeLeft);
'@
SubRx @'
  var _noClk=(CFG.raidSec<=0);
'@ @'
  // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The readout counts up only on a raid built with no
  // clock; a dial moved mid-raid used to flip a running countdown into a count up, and a count up into a negative countdown.
  var _noClk=!raidClockOn();
'@
SubRx @'
    if(CFG.raidSec>0) G.timeLeft-=dt;
'@ @'
    // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. This asked the NEXT RAID dial live, so a raid built
    // with the clock OFF started counting down from zero the frame the console closed, and a running clock moved to OFF stopped.
    if(raidClockOn()) G.timeLeft-=dt;
'@
SubRx @'
    if(_boarding&&CFG.raidSec>0&&G.timeLeft<0) G.timeLeft=0;
    if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking&&!_boarding&&(G.sim||G.beaconT!==null)){
      // Sim, or a beacon already called: end exactly as before.
      G.timeLeft=0; G.tel.deathKiller='timer'; G.player.pendKiller='timer'; endRaid('dead');
    } else if(CFG.raidSec>0&&G.timeLeft<=0&&!G.nuking&&!_boarding){
'@ @'
    // v15.14, dials audit finding 6: AND ONLY A CLOCK THE RAID HAS CAN RUN OUT. These asked the dial too, so on that same frame a
    // raid with no clock found 0 minus a frame, burned the site and downed him (with a beacon called it ended dead at once).
    if(_boarding&&raidClockOn()&&G.timeLeft<0) G.timeLeft=0;
    if(raidClockOn()&&G.timeLeft<=0&&!G.nuking&&!_boarding&&(G.sim||G.beaconT!==null)){
      // Sim, or a beacon already called: end exactly as before.
      G.timeLeft=0; G.tel.deathKiller='timer'; G.player.pendKiller='timer'; endRaid('dead');
    } else if(raidClockOn()&&G.timeLeft<=0&&!G.nuking&&!_boarding){
'@
SubRx @'
var VER='15.13';
'@ @'
var VER='15.14';
'@

$pat = "(?m)^  now:'v15\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.14: A RAID KEEPS THE CLOCK IT STARTED WITH. The raid timer dial in the tuning console says NEXT RAID, but a running raid read it live, so on a raid with the clock off, moving that dial, Reset all or a preset started burning the site on the next frame and killed you, and moving a running clock to off stopped it. The raid now asks the clock it was built with for the countdown, the burn, the HUD readout, the run length and the extraction window. Check 15.14 ascends with the clock off, moves the dial to 540 through the console and steps the raid; it fails on v15.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
