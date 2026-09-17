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
    oc2.connect(gc2); gc2.connect(OUT); oc2.start(t); oc2.stop(t+.27);
  } else if(type==='alarm'){
'@ @'
    oc2.connect(gc2); gc2.connect(OUT); oc2.start(t); oc2.stop(t+.27);
  } else if(type==='clockwarn'){
    // v15.24, HIS NOTE: "i got kileld by the timer and i never got any type of sound warning". THE RAID CLOCK HAS A VOICE OF
    // ITS OWN. The clock warnings borrowed the alarm below, a 0.3 s saw at 0.06 that every machine and pillager also plays
    // when it raises an alarm, so a warning in a fight sounded like one more machine. Three rising square sweeps, 0.3 s apart
    // over 0.9 s, at twice that level and centred: nothing else in the game climbs like this, so it cannot pass for a machine.
    for(var cwi=0;cwi<3;cwi++){
      var cwt=t+cwi*.3, cwo=a.createOscillator(), cwf=a.createBiquadFilter(), cwg=a.createGain();
      cwo.type='square';
      cwo.frequency.setValueAtTime(520,cwt); cwo.frequency.exponentialRampToValueAtTime(1040,cwt+.24);
      cwf.type='lowpass'; cwf.frequency.value=2600;
      cwg.gain.setValueAtTime(.12*vol,cwt); cwg.gain.setValueAtTime(.12*vol,cwt+.2);
      cwg.gain.exponentialRampToValueAtTime(.001,cwt+.27);
      cwo.connect(cwf); cwf.connect(cwg); cwg.connect(OUT); cwo.start(cwt); cwo.stop(cwt+.28);
    }
  } else if(type==='clocktick'){
    // v15.24, HIS NOTE: each of the last ten seconds on the raid clock. One short high square knock, so the count down is
    // heard without looking at the clock.
    var cko=a.createOscillator(),ckg=a.createGain();
    cko.type='square'; cko.frequency.setValueAtTime(1320,t);
    ckg.gain.setValueAtTime(.09*vol,t); ckg.gain.exponentialRampToValueAtTime(.001,t+.09);
    cko.connect(ckg); ckg.connect(OUT); cko.start(t); cko.stop(t+.1);
  } else if(type==='alarm'){
'@
SubRx @'
function outHint(urgent){
  // v12.93, audit finding 7: A LIVE BEACON OWNS THIS SENTENCE. Everything below
'@ @'
// v15.24, HIS NOTE: "i got kileld by the timer and i never got any type of sound warning". THE RAID CLOCK WARNINGS, moved
// here out of the loop. They played blip('alarm'), the sound a machine or a pillager makes when it raises an alarm, so they
// were lost in any fight, and the last ten seconds made no sound at all. They now play the clock siren, and each of the last
// ten seconds ticks, with TEN SECONDS said at ten. A mark also fires when the clock CROSSES it (prev above it, now at or below
// it) where it used to fire only when the whole second EQUALLED it. The loop caps a frame at 0.05 s, so a live frame cannot
// skip a whole second today; the crossing test means nothing that ever moves the clock further can skip a warning either.
// prev is the clock at the end of the last raid frame, now is the clock after this one. On the first frame of a raid there is
// no prev, and it is taken as one whole second above now, which keeps the old rule of warning when a raid starts on a mark.
// The words are the lines the loop said before, unchanged. Called once per raid frame from loop; the bot sim never calls it.
function tickClockWarn(prev,now){
  if(!G) return;
  if(typeof prev!=='number') prev=Math.ceil(now)+1;
  G.warnPrev=now;
  if(!(prev>now)) return;
  var MARKS=[300,240,180,120,60,30], tlNow=0, i;
  // The latest mark crossed speaks. A real frame never crosses two.
  for(i=0;i<MARKS.length;i++) if(prev>MARKS[i]&&MARKS[i]>=now) tlNow=MARKS[i];
  if(tlNow===30){ say('THIRTY SECONDS. '+outHint(1)); blip('clockwarn'); }
  else if(tlNow>0){
    say((tlNow/60)+' minute'+(tlNow===60?'':'s')+' left.'+(tlNow<=180?('  '+outHint(0)):''));
    blip('clockwarn');
  }
  var tick=0;
  for(i=10;i>=1;i--) if(prev>i&&i>=now) tick=i;
  if(tick){
    if(prev>10&&10>=now) say('TEN SECONDS. '+outHint(1));
    blip('clocktick');
  }
}
function outHint(urgent){
  // v12.93, audit finding 7: A LIVE BEACON OWNS THIS SENTENCE. Everything below
'@
SubRx @'
    var tlNow=Math.ceil(G.timeLeft);
    if(G.lastWarn===undefined) G.lastWarn=-1;
    if(tlNow!==G.lastWarn){
      var warned=false;
      if(tlNow===30){ say('THIRTY SECONDS. '+outHint(1)); warned=true; }
      else if(tlNow>0&&tlNow<=300&&tlNow%60===0){
        say((tlNow/60)+' minute'+(tlNow===60?'':'s')+' left.'+(tlNow<=180?('  '+outHint(0)):''));
        warned=true;
      }
      if(warned){ blip('alarm'); }
      G.lastWarn=tlNow;
    }
'@ @'
    // v15.24, HIS NOTE: killed by the timer with no sound warning. The clock warnings are in tickClockWarn beside outHint.
    // They fired when the whole second EQUALLED a mark and played the machine alarm; they now fire when the clock crosses a
    // mark, play a clock siren of their own, and tick through the last ten seconds.
    tickClockWarn(G.warnPrev,G.timeLeft);
'@
SubRx @'
var VER='15.23';
'@ @'
var VER='15.24';
'@

$pat = "(?m)^  now:'v15\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.24: THE RAID CLOCK WARNS IN ITS OWN VOICE. His note: killed by the timer with no sound warning. The minute warnings and the thirty second warning played the short quiet alarm a machine or a pillager makes when it raises an alarm, so in a fight they sounded like one more machine, and the last ten seconds made no sound before the site burned. They now play a louder rising siren of their own, each of the last ten seconds ticks with TEN SECONDS said at ten, and a warning fires when the clock crosses its mark rather than only when a whole second lands on it. No timings change. Check 15.24 steps live frames over thirty seconds, over a jump from 31.2 to 28.9 and over ten seconds, and reads the siren level; it fails on v15.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
