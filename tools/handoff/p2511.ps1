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

# NO HUM UNDER THE RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sndMixTick(dt){
  if(typeof SND_LOOPS!=='undefined'&&SND_LOOPS&&!(G&&!G.over&&!G.sim)) sndLoopsOff();   // v24.73 (his #45): no machine hum outside a raid
'@ @'
function sndMixTick(dt){
'@

SubRx @'
// An ambient bed, so silence has a floor for a noise to cut through. Two detuned
// low oscillators plus filtered noise, all running continuously and only ever
// changed by gain, which costs nothing per frame. The filter opens and the pitch
// lifts as something gets close to you, so the room itself tells you a machine
// is hunting before you can see it.
function voxGrunt(hard){
'@ @'
// An ambient bed, so silence has a floor for a noise to cut through. Looped,
// filtered noise (room tone, with the rain above it), running continuously and
// only ever changed by gain, which costs nothing per frame. The filter opens and
// the bed swells as something gets close to you, so the room itself tells you a
// machine is hunting before you can see it. Since nohum there is no tone in it.
function voxGrunt(hard){
'@

SubRx @'
var AMB=null;
function ambience(){
  var a=ac(); if(!a||AMB) return AMB;
  var out=sndBus('amb'); if(!out) return null;
  var g=a.createGain(); g.gain.value=0; g.connect(out);
  var lp=a.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=220; lp.Q.value=.7;
  lp.connect(g);
  var o1=a.createOscillator(); o1.type='sine'; o1.frequency.value=54;
  var o2=a.createOscillator(); o2.type='sine'; o2.frequency.value=81.5;
  var og=a.createGain(); og.gain.value=.5; o1.connect(og); o2.connect(og); og.connect(lp);
  // a few seconds of noise on a loop, for wind and room tone
  var n=a.createBuffer(1,a.sampleRate*3,a.sampleRate),nd=n.getChannelData(0);
  for(var i=0;i<nd.length;i++) nd[i]=(Math.random()*2-1)*.35;
  var ns=a.createBufferSource(); ns.buffer=n; ns.loop=true;
  var ng=a.createGain(); ng.gain.value=.30; ns.connect(ng); ng.connect(lp);
  // Weather layer: its own noise voice ABOVE the lowpass, brighter than room
  // tone, so rain reads as rain and not as more rumble. Gain driven per frame.
  var wn=a.createBufferSource(); wn.buffer=n; wn.loop=true; wn.playbackRate.value=1.7;
  var wf=a.createBiquadFilter(); wf.type='bandpass'; wf.frequency.value=2600; wf.Q.value=.6;
  var wg=a.createGain(); wg.gain.value=0;
  wn.connect(wf); wf.connect(wg); wg.connect(out);
  // Dread layer: a very low sine that rises as the Warden closes. Horror is a
  // frequency you feel before you place it.
  var dr=a.createOscillator(); dr.type='sine'; dr.frequency.value=36;
  var dg=a.createGain(); dg.gain.value=0;
  dr.connect(dg); dg.connect(out);
  try{ o1.start(); o2.start(); ns.start(); wn.start(); dr.start(); }catch(e){}
  AMB={g:g,lp:lp,o1:o1,o2:o2,base:54,wg:wg,dg:dg};
  return AMB;
}
// Called once a frame. threat is 0 when nothing is near and 1 when something is
// on top of you, and it drives the whole bed.
function tickAmbience(dt,threat,alive,dread){
  var A=ambience(); if(!A) return;
  var a=ac(); if(!a) return;
  var target=alive?(0.16+0.30*threat):0;
  var t=a.currentTime;
  try{
    A.g.gain.setTargetAtTime(target,t,0.45);
    A.lp.frequency.setTargetAtTime(200+900*threat,t,0.5);
    A.o1.frequency.setTargetAtTime(A.base*(1+0.16*threat),t,0.8);
    A.o2.frequency.setTargetAtTime(A.base*1.5*(1+0.16*threat),t,0.8);
    if(A.wg){
      var wxr=(typeof wx==='function'&&wx())?wx().rain||0:0;
      A.wg.gain.setTargetAtTime(alive?wxr*0.045:0,t,1.2);
    }
    if(A.dg) A.dg.gain.setTargetAtTime(alive?(dread||0)*0.22:0,t,0.6);
  }catch(e){}
}
// v10.85, HIS NOTE: the bed is the only sound in the game with no stop, by
// design, and tickAmbience above is the only thing that drives its gain. It runs
// inside the raid branch of the frame loop and nowhere else, so when a raid ends
// the gain simply stops being written and those five voices hold their last
// level for as long as the page is open. This is what cuts them.
// A COUNTER, not a boolean: a check with no audio context cannot hear the gain
// go down, but it can prove this was reached once per ending and never during
// ordinary play.
var AMBOFF=0;
function ambienceOff(){
  AMBOFF++;
  var A=AMB; if(!A) return false;
  var a=ac(); if(!a) return false;
  var t=a.currentTime;
  try{
    // cancelScheduledValues first, or the ramp tickAmbience set on the last raid
    // frame keeps pulling the gain back up after this one is written.
    A.g.gain.cancelScheduledValues(t);  A.g.gain.setTargetAtTime(0,t,0.12);
    if(A.wg){ A.wg.gain.cancelScheduledValues(t); A.wg.gain.setTargetAtTime(0,t,0.12); }
    if(A.dg){ A.dg.gain.cancelScheduledValues(t); A.dg.gain.setTargetAtTime(0,t,0.12); }
  }catch(e){}
  return true;
}
'@ @'
var AMB=null;
// nohum, HIS NOTE (2026-10-12): "random hums as 'ambiance' don't sound good". The bed held two sine drones at 54 and 81.5 Hz
// (their pitch lifting as something closed on you) and a 36 Hz dread sine that rose as the Warden came near, three tones that
// ran for the whole raid. All three are gone. What is left is not a tone: the looped room-tone noise through the lowpass, which
// still opens and swells as something gets close, and the rain layer above it. The machines keep their one-shot cues.
function ambience(){
  var a=ac(); if(!a||AMB) return AMB;
  var out=sndBus('amb'); if(!out) return null;
  var g=a.createGain(); g.gain.value=0; g.connect(out);
  var lp=a.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=220; lp.Q.value=.7;
  lp.connect(g);
  // a few seconds of noise on a loop, for wind and room tone
  var n=a.createBuffer(1,a.sampleRate*3,a.sampleRate),nd=n.getChannelData(0);
  for(var i=0;i<nd.length;i++) nd[i]=(Math.random()*2-1)*.35;
  var ns=a.createBufferSource(); ns.buffer=n; ns.loop=true;
  var ng=a.createGain(); ng.gain.value=.30; ns.connect(ng); ng.connect(lp);
  // Weather layer: its own noise voice ABOVE the lowpass, brighter than room
  // tone, so rain reads as rain and not as more rumble. Gain driven per frame.
  var wn=a.createBufferSource(); wn.buffer=n; wn.loop=true; wn.playbackRate.value=1.7;
  var wf=a.createBiquadFilter(); wf.type='bandpass'; wf.frequency.value=2600; wf.Q.value=.6;
  var wg=a.createGain(); wg.gain.value=0;
  wn.connect(wf); wf.connect(wg); wg.connect(out);
  try{ ns.start(); wn.start(); }catch(e){}
  AMB={g:g,lp:lp,wg:wg};
  return AMB;
}
// Called once a frame. threat is 0 when nothing is near and 1 when something is
// on top of you, and it drives the whole bed. dread (the Warden closing) is still
// passed by the frame loop but no longer drives anything: its 36 Hz tone is gone (nohum).
function tickAmbience(dt,threat,alive,dread){
  var A=ambience(); if(!A) return;
  var a=ac(); if(!a) return;
  var target=alive?(0.16+0.30*threat):0;
  var t=a.currentTime;
  try{
    A.g.gain.setTargetAtTime(target,t,0.45);
    A.lp.frequency.setTargetAtTime(200+900*threat,t,0.5);
    if(A.wg){
      var wxr=(typeof wx==='function'&&wx())?wx().rain||0:0;
      A.wg.gain.setTargetAtTime(alive?wxr*0.045:0,t,1.2);
    }
  }catch(e){}
}
// v10.85, HIS NOTE: the bed is the only sound in the game with no stop, by
// design, and tickAmbience above is the only thing that drives its gain. It runs
// inside the raid branch of the frame loop and nowhere else, so when a raid ends
// the gain simply stops being written and those five voices hold their last
// level for as long as the page is open. This is what cuts them.
// (nohum: two voices now, the room-tone noise and the rain.)
// A COUNTER, not a boolean: a check with no audio context cannot hear the gain
// go down, but it can prove this was reached once per ending and never during
// ordinary play.
var AMBOFF=0;
function ambienceOff(){
  AMBOFF++;
  var A=AMB; if(!A) return false;
  var a=ac(); if(!a) return false;
  var t=a.currentTime;
  try{
    // cancelScheduledValues first, or the ramp tickAmbience set on the last raid
    // frame keeps pulling the gain back up after this one is written.
    A.g.gain.cancelScheduledValues(t);  A.g.gain.setTargetAtTime(0,t,0.12);
    if(A.wg){ A.wg.gain.cancelScheduledValues(t); A.wg.gain.setTargetAtTime(0,t,0.12); }
  }catch(e){}
  return true;
}
'@

SubRx @'
// v24.73, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible, punchy arcade): MACHINES YOU CANNOT SEE HUM. A machine
// hunting you out of sight spoke only in short one-shots every second or two, so between them the ear lost it, and nothing said
// whether it was looking for you or already on you. Now the three nearest machines within 900 that are searching or on you and that
// you cannot see each hold a running voice of their own: a sentry is a pulsing servo whine, a crawler a fast rattle, a warden a deep
// hydraulic throb, a snitch a wavering drone tone, a listener a slow sweeping dish, a howler a low growl, a bulwark a tread rumble.
// Searching is slow and quiet; on you it runs faster and louder. Behind a wall it is muffled, and it sits left or right where the
// machine is. The voices fade in and out over about a third of a second and are reassigned four times a second, and they go silent
// when the raid ends. The one-shots are unchanged. Cosmetic only: no seeded draw, no game state, nothing under G.sim.
var MACH_LOOP={
  sentry:  {o1:'sawtooth',f1:140,o2:'',f2:0,nz:0,bp:900,q:3,lfo:[3,7],amp:0.45,pit:0,lvl:0.05},
  crawler: {o1:'',f1:0,o2:'',f2:0,nz:1,bp:2600,q:1.2,lfo:[9,16],amp:0.5,pit:0,lvl:0.05},
  warden:  {o1:'sine',f1:48,o2:'sawtooth',f2:96,nz:0,bp:420,q:0.8,lfo:[0.6,1.4],amp:0.35,pit:0,lvl:0.07},
  snitch:  {o1:'triangle',f1:420,o2:'',f2:0,nz:0,bp:900,q:1,lfo:[5,9],amp:0.15,pit:18,lvl:0.035},
  listener:{o1:'triangle',f1:900,o2:'',f2:0,nz:0,bp:1000,q:1.5,lfo:[0.5,1.2],amp:0.1,pit:200,lvl:0.035},
  howler:  {o1:'sawtooth',f1:70,o2:'',f2:0,nz:0.6,bp:600,q:0.9,lfo:[2,5],amp:0.45,pit:0,lvl:0.06},
  bulwark: {o1:'square',f1:55,o2:'',f2:0,nz:0,bp:350,q:0.9,lfo:[4,8],amp:0.5,pit:0,lvl:0.06}
};
var MACH_LOOP_N=3, MACH_LOOP_R=900, SND_LOOPS=null;
function machLoopMode(e){
  if(!e) return '';
  if(e.state==='chase'||e.state==='alarm'||e.state==='hunt') return 'fight';
  if(e.state==='investigate'||(e.alert||0)>0.5) return 'search';
  return '';
}
function machLoopSlot(a,out){
  var s={e:null,kind:'',mode:'',lvl:0}, n=4096, b, c, i;
  s.g=a.createGain(); s.g.gain.value=0;
  s.lp=a.createBiquadFilter(); s.lp.type='lowpass'; s.lp.frequency.value=8000; s.lp.Q.value=0.7;
  s.bp=a.createBiquadFilter(); s.bp.type='bandpass'; s.bp.frequency.value=900; s.bp.Q.value=1;
  s.tr=a.createGain(); s.tr.gain.value=0.6;
  s.o1=a.createOscillator(); s.m1=a.createGain(); s.m1.gain.value=0;
  s.o2=a.createOscillator(); s.m2=a.createGain(); s.m2.gain.value=0;
  b=a.createBuffer(1,n,a.sampleRate); c=b.getChannelData(0); for(i=0;i<n;i++) c[i]=Math.random()*2-1;
  s.nz=a.createBufferSource(); s.nz.buffer=b; s.nz.loop=true; s.mn=a.createGain(); s.mn.gain.value=0;
  s.lfo=a.createOscillator(); s.lfo.type='sine'; s.lfo.frequency.value=3; s.la=a.createGain(); s.la.gain.value=0; s.lpit=a.createGain(); s.lpit.gain.value=0;
  s.pn=a.createStereoPanner?a.createStereoPanner():null;
  s.o1.connect(s.m1); s.m1.connect(s.bp); s.o2.connect(s.m2); s.m2.connect(s.bp); s.nz.connect(s.mn); s.mn.connect(s.bp);
  s.bp.connect(s.tr); s.tr.connect(s.lp); s.lp.connect(s.g);
  if(s.pn){ s.g.connect(s.pn); s.pn.connect(out); } else s.g.connect(out);
  s.lfo.connect(s.la); s.la.connect(s.tr.gain); s.lfo.connect(s.lpit); s.lpit.connect(s.o1.frequency);
  s.o1.start(); s.o2.start(); s.nz.start(); s.lfo.start();
  return s;
}
function machLoopSet(s,c,a){
  var t=a.currentTime, K, f, lv, p=G&&G.player;
  if(!c){ if(s.e||s.lvl>0){ s.e=null; s.kind=''; s.mode=''; s.lvl=0; try{ s.g.gain.cancelScheduledValues(t); s.g.gain.setTargetAtTime(0,t,0.1); }catch(_z){} } return; }
  K=MACH_LOOP[c.e.kind];
  if(s.kind!==c.e.kind){
    s.kind=c.e.kind;
    if(K.o1){ s.o1.type=K.o1; s.o1.frequency.value=K.f1; s.m1.gain.value=0.5; } else s.m1.gain.value=0;
    if(K.o2){ s.o2.type=K.o2; s.o2.frequency.value=K.f2; s.m2.gain.value=0.4; } else s.m2.gain.value=0;
    s.mn.gain.value=K.nz||0;
    s.bp.frequency.value=K.bp; s.bp.Q.value=K.q;
    s.tr.gain.value=1-K.amp; s.la.gain.value=K.amp; s.lpit.gain.value=K.pit||0;
  }
  s.e=c.e; s.mode=c.m;
  f=K.lfo[c.m==='fight'?1:0];
  try{ s.lfo.frequency.setTargetAtTime(f,t,0.08); }catch(_f){ s.lfo.frequency.value=f; }
  lv=K.lvl*(c.m==='fight'?1:0.55)*clamp(1.15-c.d/MACH_LOOP_R,0.15,1);
  s.lvl=lv;
  try{ s.lp.frequency.setTargetAtTime(c.occ?1000:8000,t,0.08); }catch(_l){ s.lp.frequency.value=c.occ?1000:8000; }
  if(s.pn&&p){ try{ s.pn.pan.setTargetAtTime(clamp((c.e.x-p.x)/520,-1,1),t,0.08); }catch(_p){} }
  try{ s.g.gain.cancelScheduledValues(t); s.g.gain.setTargetAtTime(lv,t,0.1); }catch(_g){ s.g.gain.value=lv; }
}
function sndLoopsOff(){
  if(!SND_LOOPS) return false;
  var a=AC, i;
  for(i=0;i<SND_LOOPS.slots.length;i++){ try{ if(a) machLoopSet(SND_LOOPS.slots[i],null,a); }catch(_o){} }
  SND_LOOPS.t=0;
  return true;
}
function tickMachLoops(dt){
  if(!G||G.sim||!G.player||!G.ents) return false;
  if(G.over){ sndLoopsOff(); return false; }
  var a=ac(); if(!a) return false;
  var out=sndBus('mach'), p=G.player, c=[], i, j, e, d, m, s, pick, used=[];
  if(!out) return false;
  if(!SND_LOOPS||SND_LOOPS.out!==out){
    if(SND_LOOPS) sndLoopsOff();
    try{ SND_LOOPS={slots:[],t:0,out:out}; for(i=0;i<MACH_LOOP_N;i++) SND_LOOPS.slots.push(machLoopSlot(a,out)); }catch(_b){ SND_LOOPS=null; return false; }
  }
  SND_LOOPS.t-=(isFinite(dt)&&dt>0)?dt:0;
  if(SND_LOOPS.t>0) return true;
  SND_LOOPS.t=0.25;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!MACH_LOOP[e.kind]||!(e.hp>0)) continue;
    m=machLoopMode(e); if(!m) continue;
    d=Math.sqrt((e.x-p.x)*(e.x-p.x)+(e.y-p.y)*(e.y-p.y)); if(d>MACH_LOOP_R) continue;
    try{ if(canSee(p.x,p.y,p.face,e.x,e.y,G.vseg||G.map.segs)) continue; }catch(_cs){ continue; }
    c.push({e:e,d:d,m:m,occ:(G.map&&G.map.segs)?(losClear(p.x,p.y,e.x,e.y,G.map.segs)?0:1):0});
  }
  c.sort(function(x,y){ return x.d-y.d; });
  c=c.slice(0,MACH_LOOP_N);
  // a voice already on a machine that is still wanted keeps it, so a voice never jumps between two machines it is already playing
  for(i=0;i<SND_LOOPS.slots.length;i++){
    s=SND_LOOPS.slots[i]; pick=null;
    for(j=0;j<c.length;j++) if(c[j].e===s.e&&used.indexOf(j)<0){ pick=j; break; }
    if(pick!==null){ used.push(pick); s.keep=1; machLoopSet(s,c[pick],a); } else s.keep=0;
  }
  for(i=0;i<SND_LOOPS.slots.length;i++){
    s=SND_LOOPS.slots[i];
    if(s.keep) continue;
    pick=null; for(j=0;j<c.length;j++) if(used.indexOf(j)<0){ pick=j; break; }
    if(pick!==null){ used.push(pick); machLoopSet(s,c[pick],a); } else machLoopSet(s,null,a);
  }
  return true;
}
var VOICE_BUDGET=0;
'@ @'
// nohum, HIS NOTE (2026-10-12): "random hums as 'ambiance' don't sound good". The v24.73 running voices for machines out of
// sight (a servo whine, a hydraulic throb, a drone tone, a dish sweep, a growl, a tread rumble, each held on an oscillator for
// as long as the machine hunted you) are removed whole, with their per-frame tick and their stop. A machine out of sight is
// heard again only through its one-shot cues (servo, skitter, hydraulics, dish, footsteps, alarms, the lock-on beep).
var VOICE_BUDGET=0;
'@

SubRx @'
      tickMachineVoices(dt);
      tickMachLoops(dt);   // v24.73 (his #45): the machines you cannot see hum
'@ @'
      tickMachineVoices(dt);
'@

SubRx @'
var VER='25.10';
'@ @'
var VER='25.11';
'@

$pat = "(?m)^  now:'v25\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.11: The low hums under the raid are gone: no drones, no dread tone and no running machine voices, only the room noise, rain and the machine cues. Check 25.11 fails on v25.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
