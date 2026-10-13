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

# MACHINES YOU CANNOT SEE HUM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var VOICE_BUDGET=0;
function tickMachineVoices(dt){
'@ @'
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
function tickMachineVoices(dt){
'@

SubRx @'
      tickMachineVoices(dt);
'@ @'
      tickMachineVoices(dt);
      tickMachLoops(dt);   // v24.73 (his #45): the machines you cannot see hum
'@

SubRx @'
function sndMixTick(dt){
'@ @'
function sndMixTick(dt){
  if(typeof SND_LOOPS!=='undefined'&&SND_LOOPS&&!(G&&!G.over&&!G.sim)) sndLoopsOff();   // v24.73 (his #45): no machine hum outside a raid
'@

SubRx @'
var VER='24.72';
'@ @'
var VER='24.73';
'@

$pat = "(?m)^  now:'v24\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.73: Machines hunting you out of sight now keep up a running sound, faster and louder when they are on you. Check 24.73 fails on v24.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
