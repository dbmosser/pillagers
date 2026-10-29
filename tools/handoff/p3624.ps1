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

# EXTRACT QUIET MIDDLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var XALARM_LEN=4;   // v33.35 (cw-xalarmshort), HIS ORDER (2026-10-20): "extraction siren is intrusive, it doesn't need to go off the entire time, just for maybe 4 seconds when the extraction is first called, and 4 seconds before the extraction actually starts". Seconds of siren at each end of the wait; replaces the whole-time loop of answer 41
'@ @'
var XALARM_LEN=3;   // v28.xx (cw-cx-extractquiet), his 10-28 order: "just the first 3 and the last 3 seconds. should attract enemies the entire time though".
// v28.xx (cw-cx-extractquiet): sound only; the siege ping, pull and arrival clocks below never read this gate. Tail keeps a cue out of the quiet middle.
function extWaitSoundOn(z,tail){
  return !!(G&&!G.sim&&CFG.xAlarm!==0&&z&&z.beaconT>0&&((z.alarmAge||0)+(tail||0)<=XALARM_LEN||z.beaconT<=XALARM_LEN));
}
// v28.xx (cw-cx-extractquiet): an extraction alert may wait in the queue past the opening sound window. Its words still show on time.
function extAlertSoundOn(m,k,o){
  if(!(o&&(o.key==='xcall'||o.key==='siege'))&&!(k==='ext'&&/^extract(?:ion)?\b/i.test(String(m)))) return true;
  var z=G&&G.active;
  return CFG.xAlarm!==0&&(!(z&&z.beaconT>0)||extWaitSoundOn(z,0.3));
}
'@

SubRx @'
    // v27.xx (xalarm), HIS ANSWER 41: THE LOW ALARM LOOPS through the extraction countdown, the wait for the ship and the boarding hold alike
    // (a ring is called from the call until its beacon is cleared). Only the ring you called, never the bot sim, and the dial CFG.xAlarm 0 mutes it.
    if(!G.sim&&z===G.active&&CFG.xAlarm!==0){
      z.alarmAge=(z.alarmAge||0)+dt;   // v33.35 (cw-xalarmshort): siren only in the first XALARM_LEN s after the call and the last XALARM_LEN s before the ship arrives (beaconT 0); none while the ship holds
      var _xaOn=(z.beaconT>0&&(z.alarmAge<=XALARM_LEN||z.beaconT<=XALARM_LEN));
      if(z.alarmT===undefined||!_xaOn) z.alarmT=XALARM_GAP;
      z.alarmT+=dt;
      if(_xaOn&&z.alarmT>=XALARM_GAP){ z.alarmT=0; blip('xalarm'); }
    }
    // THE APPROACH IS AUDIBLE NOW. A ping whose interval shrinks from 2.2s at
    // the moment of the call to 0.55s as the ship arrives, so the wait has a
    // pulse and you can hear how close it is with your eyes on the tree line
    // instead of on the timer.
    if(z.beaconT>0&&!G.sim&&z===G.active){
      var _fr=clamp(1-z.beaconT/Math.max(1,CFG.extractWait),0,1);
      var _iv=2.2-1.65*_fr;
      z.pingT=(z.pingT||0)+dt;
      if(z.pingT>=_iv){ z.pingT=0; sfxHere('inbound',z.x,z.y); }   // v11.59: marks itself
    }
    z.beaconT-=dt;
'@ @'
    // v28.xx (cw-cx-extractquiet): both local windows hear only the opening and approach. Age advances even with the dial muted or another ring selected.
    z.alarmAge=(z.alarmAge||0)+dt;
    var _xaOn=extWaitSoundOn(z,1);
    if(z.alarmT===undefined||!_xaOn) z.alarmT=XALARM_GAP;
    z.alarmT+=dt;
    if(z===G.active&&_xaOn&&z.alarmT>=XALARM_GAP){ z.alarmT=0; blip('xalarm'); }
    // v28.xx (cw-cx-extractquiet): the sonar ping was the sound running through the entire middle; it shares the same sound-only gate now.
    if(z===G.active&&extWaitSoundOn(z,0.46)){
      var _fr=clamp(1-z.beaconT/Math.max(1,CFG.extractWait),0,1);
      var _iv=2.2-1.65*_fr;
      z.pingT=(z.pingT||0)+dt;
      if(z.pingT>=_iv){ z.pingT=0; sfxHere('inbound',z.x,z.y); }
    } else z.pingT=0;
    z.beaconT-=dt;
'@

SubRx @'
  try{ alertSting(k); }catch(_asg){}   // v27.33 (alert2): its sting
'@ @'
  try{ if(extAlertSoundOn(m,k,o)) alertSting(k); }catch(_asg){}   // v28.xx (cw-cx-extractquiet): delayed extract/siege callouts obey the audio windows too.
'@

SubRx @'
    {
      z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null; z.pullN=0; z.pinged=0;
'@ @'
    {
      z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null; z.pullN=0; z.pinged=0;
      z.alarmAge=0; z.alarmT=undefined; z.pingT=0;   // v28.xx (cw-cx-extractquiet): a fresh call starts fresh sound clocks.
'@

SubRx @'
            z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null; z.pullN=0; z.pinged=0;
'@ @'
            z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null; z.pullN=0; z.pinged=0;
            z.alarmAge=0; z.alarmT=undefined; z.pingT=0;   // v28.xx (cw-cx-extractquiet): a pillager call uses the same sound windows.
'@

SubRx @'
      blip('beacon');
'@ @'
      if(CFG.xAlarm!==0) blip('beacon');   // v28.xx (cw-cx-extractquiet): mute the call tones with the extract dial.
'@

SubRx @'
      blip('alarm');
'@ @'
      if(CFG.xAlarm!==0) blip('alarm');   // v28.xx (cw-cx-extractquiet): enemy wake-up above stays unconditional.
'@

SubRx @'
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=_cg; Z.pullN=0; Z.pinged=0;
'@ @'
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=_cg; Z.pullN=0; Z.pinged=0;
  Z.alarmAge=0; Z.alarmT=undefined; Z.pingT=0;   // v28.xx (cw-cx-extractquiet): same opening window for a teammate call.
'@

SubRx @'
  blip('beacon'); say('EXTRACTION CALLED','ext',{key:'xcall',sub:String(netSeatName(peer.seat)||'Teammate').toUpperCase()+' \u00b7 EXTRACT '+extLetter(Z)});   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice
'@ @'
  if(CFG.xAlarm!==0) blip('beacon'); say('EXTRACTION CALLED','ext',{key:'xcall',sub:String(netSeatName(peer.seat)||'Teammate').toUpperCase()+' \u00b7 EXTRACT '+extLetter(Z)});   // v22.38 (R13)   // v22.xx (tr3fixc): the shooter voice
'@

SubRx @'
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=(a[4]===null)?undefined:a[4];
'@ @'
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=(a[4]===null)?undefined:a[4];
    Z.alarmAge=(a[1]===null)?0:Math.max(0,CFG.extractWait-(+a[1]||0));   // v28.xx (cw-cx-extractquiet): a late world snapshot cannot replay the opening sound in player 2.
'@

SubRx @'
      if(dist(p,z)<1400){ sfxHere('touchdown',z.x,z.y); sfxHere('alarm',z.x,z.y);   // v11.59: mark themselves
'@ @'
      if(dist(p,z)<1400){ if(CFG.xAlarm!==0){ sfxHere('touchdown',z.x,z.y); sfxHere('alarm',z.x,z.y); }   // v28.xx (cw-cx-extractquiet): preserve landing sounds outside the wait, with the same mute dial.
'@

SubRx @'
    if(!G.sim&&z===G.active&&z.hold<=8&&z.hold>0&&Math.ceil(z.hold)!==Math.ceil(_hPrev)){
'@ @'
    if(!G.sim&&CFG.xAlarm!==0&&z===G.active&&z.hold<=8&&z.hold>0&&Math.ceil(z.hold)!==Math.ceil(_hPrev)){   // v28.xx (cw-cx-extractquiet): preserve landed last-call warnings, respecting mute.
'@

SubRx @'
var VER='36.23';
'@ @'
var VER='36.24';
'@

$pat = "(?m)^  now:'v36\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.24: Extract siren and sonar sound only in the first and last 3 seconds of the wait. Enemy attraction stays continuous in both windows. Check 36.24 fails on v36.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
