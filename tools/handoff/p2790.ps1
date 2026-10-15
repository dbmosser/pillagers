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

# A LOW ALARM THROUGH THE EXTRACTION COUNTDOWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickExtractPoints(dt){
'@ @'
var XALARM_GAP=1.8;   // v27.xx (xalarm): seconds between throbs of the extraction alarm
function tickExtractPoints(dt){
'@

SubRx @'
    if(z.beaconT===null||z.beaconT===undefined) continue;
    // THE APPROACH IS AUDIBLE NOW
'@ @'
    if(z.beaconT===null||z.beaconT===undefined){ z.alarmT=undefined; continue; }
    // v27.xx (xalarm), HIS ANSWER 41: THE LOW ALARM LOOPS through the extraction countdown, the wait for the ship and the boarding hold alike
    // (a ring is called from the call until its beacon is cleared). Only the ring you called, never the bot sim, and the dial CFG.xAlarm 0 mutes it.
    if(!G.sim&&z===G.active&&CFG.xAlarm!==0){
      if(z.alarmT===undefined) z.alarmT=XALARM_GAP;
      z.alarmT+=dt;
      if(z.alarmT>=XALARM_GAP){ z.alarmT=0; blip('xalarm'); }
    }
    // THE APPROACH IS AUDIBLE NOW
'@

SubRx @'
} else if(type==='inbound'){
'@ @'
} else if(type==='xalarm'){
    // v27.xx (xalarm), HIS ANSWER 41 (2026-10-13): "i don't know about music but maybe some sort of low alarm?" during the extraction countdown.
    // A QUIET LOW ALARM, not music: one slow two-tone throb (about 124 Hz, then 93 Hz) through a low pass, a sawtooth underneath so a laptop
    // speaker can play it, under a second long, at a level well under the ship ping. tickExtractPoints plays it again every 1.8 seconds from
    // the call until the ring is no longer called, so it loops through the whole countdown and the boarding hold.
    var ox1=a.createOscillator(), gx1=a.createGain(), fx1=a.createBiquadFilter();
    ox1.type='sawtooth'; fx1.type='lowpass'; fx1.frequency.value=360; fx1.Q.value=0.7;
    ox1.frequency.setValueAtTime(124,t); ox1.frequency.setValueAtTime(93,t+.46);
    gx1.gain.setValueAtTime(.001,t); gx1.gain.linearRampToValueAtTime(.032*vol,t+.06);
    gx1.gain.setValueAtTime(.032*vol,t+.40); gx1.gain.linearRampToValueAtTime(.0015,t+.46);
    gx1.gain.linearRampToValueAtTime(.032*vol,t+.52); gx1.gain.setValueAtTime(.032*vol,t+.86); gx1.gain.exponentialRampToValueAtTime(.001,t+.98);
    ox1.connect(fx1); fx1.connect(gx1); gx1.connect(OUT); ox1.start(t); ox1.stop(t+1.0);
  } else if(type==='inbound'){
'@

SubRx @'
var VER='27.89';
'@ @'
var VER='27.90';
'@

$pat = "(?m)^  now:'v27\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.90: A quiet low alarm now throbs through the extraction countdown. Check 27.90 fails on v27.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
