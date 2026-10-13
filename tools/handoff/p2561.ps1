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

# EVERY MACHINE DIES WITH ITS OWN NOISE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function impactMat(a,OUT,type,mat,vol,t){
'@ @'
// robotdeaths, HIS ORDER (2026-10-12): "all robots should have a distinct destruction noise for when they are killed". A machine
// died in silence: the round that killed it made the same metal or armour tick as every other hit, a kill of yours added the
// marker ding in your own ears, and a machine killed by a charge, a Howler shell or another machine made no sound at all, so with
// your eyes closed a Sentry, a Warden and the Overseer going down were the same nothing. Now each kind has its own destruction
// noise, built like the punchy guns (a transient, a body and a tail), placed where it died (distance, pan and the wall lowpass, as
// every positioned sound is), on the impact bus under the master limiter:
// - SENTRY: its servo seizing and grinding down, a sharp electrical pop and thump, tinkling debris.
// - CRAWLER: its small legs skittering out and slowing, then a light crunch.
// - CRIER: its alarm wailing down and wavering, cut off by a crackle.
// - LISTENER: its dish feedback whine climbing, then snapping off.
// - HOWLER: its growl choking down into a burst.
// - BULWARK: its armour plates clanging down, one, two, three, and the hull hitting the ground.
// - PILLBOX: the turret detonating and the shell left ringing.
// - WARDEN: a deep hydraulic groan, then a heavy metal collapse.
// - THE OVERSEER: the biggest sound in the game, a long layered blast with a falling tone and a rain of debris, about two seconds,
//   and it pulls the bed down as a blast does.
// Small machines play under a gunshot and finish inside 1.2 s, the big ones sit near a gunshot. Never a voice and never a hum.
// Played once, from the death itself (machDieKind names the sound), never in a bot raid; noise is filled from Math.random inside
// the buffers only, never from the raid dice, and nothing here touches game state.
var MDIE_KINDS={sentry:1,crawler:1,snitch:1,listener:1,choir:1,warden:1,overseer:1,bulwark:1,howler:1};
SND_CAT.mdie='imp';
function machDieKind(e){
  if(!e||!MDIE_KINDS[e.kind]||e.kind==='overseer') return '';
  return (e.kind==='warden'&&(e.boss||e.name===BOSS_NAME))?'overseer':e.kind;
}
function machDie(a,OUT,kind,vol,t){
  var k=String(kind||''), i, o, q;
  if(!MDIE_KINDS[k]) return false;
  function nz(dur,pw,ft,f0,f1,qq,gv,at,sp){
    var len=Math.max(64,Math.round(dur*a.sampleRate)), nb=a.createBuffer(1,len,a.sampleRate), nc=nb.getChannelData(0), j, ns, nf, ng;
    for(j=0;j<len;j++) nc[j]=(sp&&Math.random()>sp)?0:(Math.random()*2-1)*Math.pow(1-j/len,pw);
    ns=a.createBufferSource(); ns.buffer=nb;
    nf=a.createBiquadFilter(); nf.type=ft; nf.frequency.setValueAtTime(f0,at); if(f1&&f1!==f0) nf.frequency.exponentialRampToValueAtTime(f1,at+dur); nf.Q.value=qq;
    ng=a.createGain(); ng.gain.value=gv*vol;
    ns.connect(nf); nf.connect(ng); ng.connect(OUT); ns.start(at); ns.stop(at+dur+0.01);
    return ns;
  }
  // mode 0: struck and decaying; 1: held, then cut; 2: swelling, then cut
  function tn(ty,f0,f1,dur,gv,at,lp,mode){
    var to=a.createOscillator(), tg=a.createGain(), dst=OUT, tf;
    to.type=ty; to.frequency.setValueAtTime(f0,at); to.frequency.exponentialRampToValueAtTime(Math.max(1,f1),at+dur);
    tg.gain.value=0.0001;
    if(mode===2){ tg.gain.setValueAtTime(gv*vol*0.15,at); tg.gain.linearRampToValueAtTime(gv*vol,at+dur); tg.gain.exponentialRampToValueAtTime(0.0005,at+dur+0.006); }
    else if(mode===1){ tg.gain.setValueAtTime(gv*vol,at); tg.gain.linearRampToValueAtTime(gv*vol*0.7,at+dur); tg.gain.exponentialRampToValueAtTime(0.0005,at+dur+0.01); }
    else { tg.gain.setValueAtTime(gv*vol,at); tg.gain.exponentialRampToValueAtTime(0.0005,at+dur+0.01); }
    if(lp){ tf=a.createBiquadFilter(); tf.type='lowpass'; tf.frequency.value=lp; tf.Q.value=0.8; tf.connect(OUT); dst=tf; }
    to.connect(tg); tg.connect(dst); to.start(at); to.stop(at+dur+0.03);
    return to;
  }
  function wob(osc,rate,depth,at,dur){
    var lf=a.createOscillator(), lg=a.createGain();
    lf.type='sine'; lf.frequency.value=rate; lg.gain.value=depth;
    lf.connect(lg); lg.connect(osc.frequency); lf.start(at); lf.stop(at+dur+0.03);
  }
  if(k==='sentry'){
    tn('sawtooth',380,70,0.26,0.045,t,1800,1);                        // the servo seizing, grinding down
    nz(0.05,1.2,'highpass',2400,0,0.7,0.14,t+0.24);                    // the electrical pop
    tn('square',1500,260,0.05,0.05,t+0.24);
    tn('sine',150,48,0.16,0.12,t+0.24);                                // the thump
    q=[[0.31,3300],[0.38,4400],[0.46,2750],[0.56,3900],[0.69,3050]];   // tinkling debris
    for(i=0;i<q.length;i++) tn('triangle',q[i][1],q[i][1]*0.96,0.07,0.024-i*0.003,t+q[i][0]);
  } else if(k==='crawler'){
    q=[0,0.03,0.065,0.105,0.15,0.2];                                    // the legs skittering out, slowing
    for(i=0;i<q.length;i++) nz(0.014,2,'bandpass',2600-i*150,0,6,0.06-i*0.007,t+q[i]);
    nz(0.11,1.6,'bandpass',950,500,1.1,0.13,t+0.25);                   // a light crunch
    nz(0.06,2.4,'highpass',3200,0,0.7,0.05,t+0.25);
    tn('square',280,110,0.06,0.03,t+0.25,900);
  } else if(k==='snitch'){
    o=tn('square',1150,280,0.5,0.04,t,2400,1); wob(o,9,80,t,0.5);      // the alarm wailing down, wavering
    nz(0.16,0.7,'highpass',3000,0,0.7,0.08,t+0.5);                      // cut by a crackle
    nz(0.05,2,'bandpass',1200,0,2,0.07,t+0.5);
    tn('sine',200,80,0.08,0.05,t+0.5);
  } else if(k==='listener'){
    tn('sine',2600,3500,0.42,0.05,t,0,2); tn('sine',2645,3570,0.42,0.035,t,0,2);   // the dish feedback whine climbing, beating
    nz(0.025,1,'highpass',4200,0,0.7,0.14,t+0.42);                      // snapping off
    tn('triangle',900,180,0.09,0.06,t+0.42);
    tn('sine',140,60,0.1,0.06,t+0.42);
  } else if(k==='howler'){
    o=tn('sawtooth',105,62,0.36,0.07,t,650,1); wob(o,23,18,t,0.36);    // the growl, choking
    tn('sawtooth',109,48,0.36,0.05,t,500,1);
    nz(0.42,1.8,'lowpass',1500,280,0.8,0.24,t+0.36);                    // into a burst
    nz(0.05,1.5,'highpass',2000,0,0.7,0.07,t+0.36);
    tn('sine',120,36,0.3,0.16,t+0.36);
  } else if(k==='bulwark'){
    q=[[0,430,710,0.075],[0.15,370,615,0.07],[0.31,320,530,0.065]];     // the armour plates clanging down
    for(i=0;i<q.length;i++){ tn('triangle',q[i][1],q[i][1]*0.97,0.34,q[i][3],t+q[i][0]); tn('triangle',q[i][2],q[i][2]*0.97,0.26,q[i][3]*0.6,t+q[i][0]); nz(0.03,2.5,'bandpass',2200,0,1.5,0.07,t+q[i][0]); }
    tn('sine',95,42,0.22,0.15,t+0.31);                                  // and the hull on the ground
    nz(0.2,2,'lowpass',420,0,0.8,0.1,t+0.31);
  } else if(k==='choir'){
    nz(0.45,2,'lowpass',900,240,0.8,0.27,t);                            // the turret detonating
    nz(0.04,1.4,'highpass',2400,0,0.7,0.1,t);
    tn('sine',115,36,0.3,0.18,t);
    tn('triangle',1020,1005,1.05,0.035,t+0.05); tn('triangle',1530,1512,0.85,0.022,t+0.05); tn('sine',2380,2360,0.6,0.012,t+0.05);   // the shell left ringing
  } else if(k==='warden'){
    tn('sawtooth',78,36,0.55,0.09,t,380,1);                             // a deep hydraulic groan
    nz(0.5,0.6,'bandpass',1400,700,1.2,0.035,t);
    nz(0.5,1.9,'lowpass',520,180,0.8,0.26,t+0.5);                       // a heavy metal collapse
    tn('sine',78,28,0.42,0.2,t+0.5);
    tn('triangle',255,248,0.45,0.06,t+0.55); tn('triangle',405,396,0.35,0.04,t+0.55);
    tn('triangle',205,200,0.4,0.05,t+0.74); tn('triangle',330,324,0.3,0.035,t+0.74);
  } else {
    // THE OVERSEER
    if(vol>0.2){ sndDuck('amb',0.35,0.8); sndDuck('mach',0.6,0.8); sndDuck('foley',0.7,0.8); }
    nz(1.3,1.6,'lowpass',2200,180,0.7,0.32,t);                          // the blast
    nz(0.06,1.2,'highpass',2000,0,0.7,0.14,t);
    tn('sine',92,24,1.2,0.26,t);
    tn('sawtooth',620,55,1.7,0.05,t+0.05,1500);                         // the falling tone
    nz(0.8,1.8,'lowpass',600,160,0.8,0.2,t+0.38);                       // a second blast
    tn('sine',70,26,0.6,0.16,t+0.38);
    nz(1.3,0.5,'highpass',2600,1800,0.7,0.09,t+0.7,0.006);              // the debris rain
    q=[[0.8,3600],[0.95,2900],[1.12,4100],[1.3,3300],[1.5,2600],[1.72,3800],[1.95,3000]];
    for(i=0;i<q.length;i++) tn('triangle',q[i][1],q[i][1]*0.95,0.08,0.02,t+q[i][0]);
    tn('triangle',240,232,0.5,0.05,t+1.0); tn('triangle',380,370,0.4,0.035,t+1.0);
  }
  return true;
}
function impactMat(a,OUT,type,mat,vol,t){
'@

SubRx @'
  } else if(type==='hit'&&impactMat(a,OUT,'hit',arguments[3],vol,t)){
'@ @'
  } else if(type==='mdie'&&machDie(a,OUT,arguments[3],vol,t)){
    // robotdeaths (his order 2026-10-12): every machine kind dies with its own noise (machDie)
  } else if(type==='hit'&&impactMat(a,OUT,'hit',arguments[3],vol,t)){
'@

SubRx @'
      deathAnimAdd(e);   // v17.47: his pick 29, the death animation
'@ @'
      if(!G.sim&&machDieKind(e)) sfx('mdie',e.x,e.y,machDieKind(e));   // robotdeaths (his order 2026-10-12): each machine kind dies with its own noise
      deathAnimAdd(e);   // v17.47: his pick 29, the death animation
'@

SubRx @'
var VER='25.60';
'@ @'
var VER='25.61';
'@

$pat = "(?m)^  now:'v25\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.61: Every machine now dies with its own noise, from the Crawler crunch to the Overseer blast. Check 25.61 fails on v25.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
