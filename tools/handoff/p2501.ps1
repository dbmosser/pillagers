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

# THE LOCK-ON IS ONE LOW SIREN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        // v23.xx, HIS ANSWERS (2026-10-12), answer 34 a: "machine beeps". A MACHINE BEEPS WHEN IT LOCKS ON. The stinger above plays
        // once in five seconds for the whole map, and only the sentry, the crawler and the Crier sound their alarm, so a Warden, a
        // Howler or a Bulwark turning on him made no sound of its own. Every machine (anything that is not a person) now gives a
        // short rising double beep where it stands the moment it acquires him: once per machine in three seconds, a quarter second
        // apart across the map, within 760. Sound only: nothing is drawn from a seeded stream.
        if(e.state!=='chase'&&!G.sim&&killWord(e)===' DESTROYED'&&!e.merc&&dist(e,p)<760&&!(typeof e.beepAt==='number'&&e.beepAt>(G.t||0)-3)&&!(typeof G.beepAt==='number'&&G.beepAt>(G.t||0)-0.25)){ e.beepAt=G.t||0; G.beepAt=G.t||0; sfx('lockon',e.x,e.y); }
'@ @'
        // v24.xx (machsiren): a machine locking on is heard through the one lock-on siren (tickMachSiren), not through a beep of its own here.
'@

SubRx @'
  } else if(type==='lockon'){
    // v23.xx (his answer 34 a): a machine locks on. Two short square pips through a band, the second higher (1.6 then 2.15 kHz),
    // a target-acquired chirp that reads as a machine and not as the clock or the menu.
    for(var lki=0;lki<2;lki++){
      var lkt=t+lki*.085, lko=a.createOscillator(), lkf=a.createBiquadFilter(), lkg=a.createGain();
      lko.type='square'; lko.frequency.setValueAtTime(lki?2150:1600,lkt);
      lkf.type='bandpass'; lkf.frequency.value=lki?2150:1600; lkf.Q.value=3;
      lkg.gain.setValueAtTime(.0001,lkt); lkg.gain.linearRampToValueAtTime(.05*vol,lkt+.006);
      lkg.gain.setValueAtTime(.05*vol,lkt+.05); lkg.gain.exponentialRampToValueAtTime(.001,lkt+.07);
      lko.connect(lkf); lkf.connect(lkg); lkg.connect(OUT); lko.start(lkt); lko.stop(lkt+.08);
    }
  } else if(type==='clocktick'){
'@ @'
  } else if(type==='clocktick'){
'@

SubRx @'
  servo:'mach',skitter:'mach',drone:'mach',hydraul:'mach',dish:'mach',stepHeavy:'mach',seen:'mach',alarm:'mach',lockon:'mach',
'@ @'
  servo:'mach',skitter:'mach',drone:'mach',hydraul:'mach',dish:'mach',stepHeavy:'mach',seen:'mach',alarm:'mach',
'@

SubRx @'
// =================================================== MACHINE VOICES
'@ @'
// v24.xx (machsiren), HIS ORDER 2026-10-12: "whichever robot is beeping, it sounds annoying when they get together and the beeping is
// inconsistent, needs to be more of a low siren". THE LOCK-ON IS ONE LOW SIREN. v24.59 gave every machine its own short high double
// beep where it stood the moment it locked on, a quarter second apart across the map, so a room of machines turning at once was a
// scatter of chirps that never came out the same twice. Now the window holds one siren voice: a soft low wail (a triangle tone through
// a lowpass, swept from 215 up to 365 Hz and back on a fixed 1.4 s period) that runs while at least one machine within 760 is on you
// (chasing you; in co-op a machine chasing the nearest player, so each window hears the machines on its own player). However many there
// are it stays one voice; with more of them it runs a little faster (1.2 s with six) and a little louder. It sits toward the nearest of
// them (left or right, and muffled behind a wall), fades in and out over about a third of a second, and stops when none is on you, when
// the raid ends, under the pause box, in the burn and in the death beat; if nothing drives it for a fifth of a second it fades by
// itself. Cosmetic only: no seeded draw, no game state, nothing under G.sim.
var MSIREN={v:null,n:0,on:0,per:0,lvl:0,x:0,y:0,made:0};
var MSIREN_R=760, MSIREN_F0=290, MSIREN_DEP=75, MSIREN_PER=[1.4,1.2], MSIREN_LVL=0.045;
function machSirenLocked(e,p){
  if(!e||!p||e.state!=='chase'||!(e.hp>0)||e.merc||e.friendly||e.neutral||killWord(e)!==' DESTROYED') return false;
  if(dist(e,p)>=MSIREN_R) return false;
  if(typeof NET==='object'&&NET&&NET.on&&typeof netTargetFor==='function'){ try{ if(netTargetFor(e)!==p) return false; }catch(_nt){} }
  return true;
}
function machSirenVoice(a,out){
  var v={out:out,offAt:-1};
  v.o=a.createOscillator(); v.o.type='triangle'; v.o.frequency.value=MSIREN_F0;
  v.lfo=a.createOscillator(); v.lfo.type='sine'; v.lfo.frequency.value=1/MSIREN_PER[0];
  v.dep=a.createGain(); v.dep.gain.value=MSIREN_DEP;
  v.lp=a.createBiquadFilter(); v.lp.type='lowpass'; v.lp.frequency.value=950; v.lp.Q.value=0.5;
  v.wall=a.createBiquadFilter(); v.wall.type='lowpass'; v.wall.frequency.value=8000; v.wall.Q.value=0.7;
  v.g=a.createGain(); v.g.gain.value=0;
  v.pn=a.createStereoPanner?a.createStereoPanner():null;
  v.lfo.connect(v.dep); v.dep.connect(v.o.frequency);
  v.o.connect(v.lp); v.lp.connect(v.wall); v.wall.connect(v.g);
  if(v.pn){ v.g.connect(v.pn); v.pn.connect(out); } else v.g.connect(out);
  v.o.start(); v.lfo.start();
  return v;
}
function machSirenDrop(){
  var v=MSIREN.v; MSIREN.v=null; if(!v) return false;
  try{ v.o.stop(); v.lfo.stop(); }catch(_s){}
  try{ if(v.pn) v.pn.disconnect(); else v.g.disconnect(); }catch(_d){}
  return true;
}
function machSirenOff(){
  var v=MSIREN.v, t;
  MSIREN.n=0; MSIREN.on=0; MSIREN.lvl=0;
  if(!v||!AC) return false;
  t=AC.currentTime;
  try{ v.g.gain.cancelScheduledValues(t); v.g.gain.setTargetAtTime(0,t,0.1); }catch(_o){ try{ v.g.gain.value=0; }catch(_p){} }
  if(v.offAt<0) v.offAt=t+0.8;
  else if(t>v.offAt) machSirenDrop();   // faded out: the next lock-on starts a fresh voice, so it starts the same way every time
  return true;
}
function tickMachSiren(dt){
  var p=G&&G.player, i, e, d, n=0, near=null, nd=1e9, a, out, v, t, k, per, lv, pl;
  if(!G||G.sim||!p||!G.ents||G.over||G.paused||G.nuking||(G.deathBeat!==undefined&&G.deathBeat!==null)||G.goT>0||p.specOut||(typeof NET==='object'&&NET&&NET.specTick)){ if(MSIREN.v||MSIREN.on) machSirenOff(); return false; }
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!machSirenLocked(e,p)) continue; n++; d=dist(e,p); if(d<nd){ nd=d; near=e; } }
  if(!n){ if(MSIREN.v||MSIREN.on) machSirenOff(); return true; }
  MSIREN.n=n;
  a=ac(); if(!a) return false;
  out=sndBus('mach'); if(!out) return false;
  if(MSIREN.v&&MSIREN.v.out!==out) machSirenDrop();
  if(!MSIREN.v){ try{ MSIREN.v=machSirenVoice(a,out); MSIREN.made++; }catch(_b){ MSIREN.v=null; return false; } }
  v=MSIREN.v; v.offAt=-1;
  k=Math.min(n,6);
  per=MSIREN_PER[0]-(MSIREN_PER[0]-MSIREN_PER[1])*(k-1)/5;
  lv=MSIREN_LVL*(1+0.08*(k-1))*(0.7+0.3*clamp(1-nd/MSIREN_R,0,1));
  pl=sndPlace(near.x,near.y);
  t=a.currentTime;
  try{
    v.lfo.frequency.setTargetAtTime(1/per,t,0.25);
    v.wall.frequency.setTargetAtTime(pl.lp||8000,t,0.08);
    if(v.pn) v.pn.pan.setTargetAtTime(clamp((near.x-p.x)/520*(pl.panK||1),-1,1),t,0.08);
    v.g.gain.cancelScheduledValues(t);
    v.g.gain.setTargetAtTime(0,t+0.2,0.1);   // the dead man: undriven for a fifth of a second (a hidden tab, a menu), it fades by itself
    v.g.gain.setTargetAtTime(lv,t,0.1);
  }catch(_s){}
  MSIREN.on=1; MSIREN.per=per; MSIREN.lvl=lv; MSIREN.x=near.x; MSIREN.y=near.y;
  return true;
}// =================================================== MACHINE VOICES
'@

SubRx @'
  else if(G._ambDuck){ G._ambDuck=0; }
'@ @'
  else if(G._ambDuck){ G._ambDuck=0; }
  try{ tickMachSiren(dt); }catch(_ms){}   // v24.xx (machsiren): the one lock-on siren, every raid frame
'@

SubRx @'
  if(SND_OCC_N){ SND_OCC={}; SND_OCC_N=0; }   // v23.73 (his #45): what the walls hide is asked again each frame
'@ @'
  if(SND_OCC_N){ SND_OCC={}; SND_OCC_N=0; }   // v23.73 (his #45): what the walls hide is asked again each frame
  if(typeof MSIREN==='object'&&MSIREN.v&&!(G&&!G.over&&!G.sim&&!G.paused)) machSirenOff();   // v24.xx (machsiren): no lock-on siren off a live raid
'@

SubRx @'
var VER='25.00';
'@ @'
var VER='25.01';
'@

$pat = "(?m)^  now:'v25\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.01: When machines lock on to you, you now hear one low siren that wails while they are on you, the same every time however many there are, instead of a scatter of beeps. Check 25.01 fails on v25.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
