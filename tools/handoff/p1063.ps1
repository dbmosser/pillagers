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

# ============ HIS NOTE, 2026-09-03 about 19:40: "everything should sound
# ============ unique and crisp". The fourth family: the one chirp that did
# ============ seventy jobs. The audit found 'pick', a single sine from 660 to
# ============ 1180, playing for a loot pickup, a door opening, a heal, a gun
# ============ swap, a hotbar assign, a self-revive, a pedestal sale and every
# ============ menu click in the Undercroft. Opening a door and clicking a shop
# ============ button were the same sound. Now a door has a latch and a hinge,
# ============ a heal has a wrapper tearing and a soft rising pair, a menu click
# ============ is a dry tick, and the chirp is left to what it was written for:
# ============ picking something up. And sfx('cache'), which named no recipe and
# ============ played nothing at the Depot's buy tiles, rings up a sale.

# 1. A menu click is a tick, not a chirp: routed here so the forty hub sites
#    need no edit, and a raid's pickups keep the chirp.
SubRx @'
  var MJ=1+(Math.random()*2-1)*0.06;   // v10.62: six percent of jitter for the machine voices and the deaths
'@ @'
  var MJ=1+(Math.random()*2-1)*0.06;   // v10.62: six percent of jitter for the machine voices and the deaths
  if(type==='pick'&&!G) type='ui';       // v10.63: no raid means a menu, and a menu click is a tick
'@

# 2. Four voices: the door, the heal, the menu tick, the sale.
SubRx @'
  } else if(type==='pick'){
    var o2=a.createOscillator(),g4=a.createGain();
'@ @'
  } else if(type==='door'){
    // v10.63: a latch, then the hinge: a click and a short low creak.
    var dlb=a.createBuffer(1,300,a.sampleRate),dlc=dlb.getChannelData(0);
    for(var dli=0;dli<300;dli++) dlc[dli]=(Math.random()*2-1)*Math.pow(1-dli/300,2);
    var dls=a.createBufferSource(); dls.buffer=dlb;
    var dlf=a.createBiquadFilter(); dlf.type='bandpass'; dlf.frequency.value=1800*MJ; dlf.Q.value=3;
    var dlg=a.createGain(); dlg.gain.value=.09*vol;
    dls.connect(dlf); dlf.connect(dlg); dlg.connect(OUT); dls.start(t);
    var dho=a.createOscillator(),dhg=a.createGain(),dhf=a.createBiquadFilter();
    dho.type='sawtooth'; dho.frequency.setValueAtTime(220*MJ,t+.05); dho.frequency.exponentialRampToValueAtTime(150*MJ,t+.32);
    dhf.type='lowpass'; dhf.frequency.value=700;
    dhg.gain.setValueAtTime(.0001,t); dhg.gain.linearRampToValueAtTime(.05*vol,t+.09); dhg.gain.exponentialRampToValueAtTime(.001,t+.36);
    dho.connect(dhf); dhf.connect(dhg); dhg.connect(OUT); dho.start(t+.05); dho.stop(t+.38);
  } else if(type==='heal'){
    // v10.63: the wrapper tearing, then a soft rising pair.
    var hwb=a.createBuffer(1,900,a.sampleRate),hwc=hwb.getChannelData(0);
    for(var hwi=0;hwi<900;hwi++) hwc[hwi]=(Math.random()*2-1)*Math.pow(1-hwi/900,1.4);
    var hws=a.createBufferSource(); hws.buffer=hwb;
    var hwf=a.createBiquadFilter(); hwf.type='highpass'; hwf.frequency.value=2500;
    var hwg=a.createGain(); hwg.gain.value=.04*vol;
    hws.connect(hwf); hwf.connect(hwg); hwg.connect(OUT); hws.start(t);
    [[520,.06],[660,.16]].forEach(function(HN){
      var hno=a.createOscillator(),hng=a.createGain();
      hno.type='sine'; hno.frequency.setValueAtTime(HN[0]*MJ,t+HN[1]);
      hng.gain.setValueAtTime(.05*vol,t+HN[1]); hng.gain.exponentialRampToValueAtTime(.001,t+HN[1]+.16);
      hno.connect(hng); hng.connect(OUT); hno.start(t+HN[1]); hno.stop(t+HN[1]+.18);
    });
  } else if(type==='ui'){
    // v10.63: a menu click: one dry tick and a tiny thock under it.
    var uio=a.createOscillator(),uig=a.createGain();
    uio.type='square'; uio.frequency.setValueAtTime(1400,t);
    uig.gain.setValueAtTime(.035,t); uig.gain.exponentialRampToValueAtTime(.001,t+.025);
    uio.connect(uig); uig.connect(OUT); uio.start(t); uio.stop(t+.03);
    var utb=a.createBuffer(1,200,a.sampleRate),utc=utb.getChannelData(0);
    for(var uti=0;uti<200;uti++) utc[uti]=(Math.random()*2-1)*Math.pow(1-uti/200,3);
    var uts=a.createBufferSource(); uts.buffer=utb;
    var utf=a.createBiquadFilter(); utf.type='lowpass'; utf.frequency.value=900;
    var utg=a.createGain(); utg.gain.value=.05;
    uts.connect(utf); utf.connect(utg); utg.connect(OUT); uts.start(t);
  } else if(type==='cache'){
    // v10.63: a sale rung up: two bright notes and a drawer. This name was
    // called at the Depot's buy tiles since v9.99 and matched nothing.
    [[1046,0],[1568,.07]].forEach(function(CN){
      var cno=a.createOscillator(),cng=a.createGain();
      cno.type='triangle'; cno.frequency.setValueAtTime(CN[0],t+CN[1]);
      cng.gain.setValueAtTime(.06,t+CN[1]); cng.gain.exponentialRampToValueAtTime(.001,t+CN[1]+.18);
      cno.connect(cng); cng.connect(OUT); cno.start(t+CN[1]); cno.stop(t+CN[1]+.2);
    });
    var cdb=a.createBuffer(1,1200,a.sampleRate),cdc=cdb.getChannelData(0);
    for(var cdi=0;cdi<1200;cdi++) cdc[cdi]=(Math.random()*2-1)*Math.pow(1-cdi/1200,2.4);
    var cds=a.createBufferSource(); cds.buffer=cdb;
    var cdf=a.createBiquadFilter(); cdf.type='lowpass'; cdf.frequency.value=600;
    var cdg=a.createGain(); cdg.gain.value=.06;
    cds.connect(cdf); cdf.connect(cdg); cdg.connect(OUT); cds.start(t+.16);
  } else if(type==='pick'){
    var o2=a.createOscillator(),g4=a.createGain();
'@

# 3. The door and the heal ask for their own voices.
SubRx @'
      say(doorNear.name+' is open.'); blip('pick'); ping(p.x,p.y,340,false,false,'player','move');
'@ @'
      say(doorNear.name+' is open.'); blip('door'); ping(p.x,p.y,340,false,false,'player','move');   // v10.63: a door, not a pickup
'@
SubRx @'
  G.bag.splice(idx,1); startPrep('heal',k); blip('pick');
'@ @'
  G.bag.splice(idx,1); startPrep('heal',k); blip('heal');   // v10.63: a heal, not a pickup
'@

SubRx @'
var VER='10.62';
'@ @'
var VER='10.63';
'@
SubRx @'
  now:'v10.62: the machines. Each kind dies in its own way, where nothing died out loud before; a round landing on plate ticks and a round landing on a man thuds, instead of both sounding like you being hit; the Bulwark has a voice; and every machine voice jitters so it never repeats itself exactly.',
'@ @'
  now:'v10.63: one chirp did seventy jobs. A door has a latch and a hinge now, a heal a wrapper and a soft pair, a menu click a dry tick, a sale at the Depot rings up, and the chirp is left to picking things up.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
