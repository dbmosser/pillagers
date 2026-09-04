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

# ============ HIS NOTE, 2026-09-03 about 19:40: "guns, footsteps, robots, etc
# ============ -- everything should sound unique and crisp". The machines, the
# ============ third family. The audit: no machine or pillager had a death
# ============ sound at all (a clank, and only when the body fell more than 620
# ============ units away); a bullet landing on a machine played the same hit
# ============ as a bullet landing on you; the Bulwark had no voice; and every
# ============ idle voice replayed the same frequencies every time. Now each
# ============ kind dies in its own way, a hit on plate ticks and a hit on a man
# ============ thuds, the Bulwark grinds, and every voice jitters six percent.

# 1. The jitter, rolled once per call.
SubRx @'
  var vol=d===undefined?1:Math.max(0,1-d/900); if(vol<=.02) return;
  var t=a.currentTime;
'@ @'
  var vol=d===undefined?1:Math.max(0,1-d/900); if(vol<=.02) return;
  var t=a.currentTime;
  var MJ=1+(Math.random()*2-1)*0.06;   // v10.62: six percent of jitter for the machine voices and the deaths
'@

# 2. Three voices that did not exist: a death per kind, a hit on plate, a hit on a man, and the Bulwark's grind.
SubRx @'
  } else if(type==='servo'){
    // A servo sweep: a filtered tone that slides across, with a mechanical tick
'@ @'
  } else if(type==='die'){
    // v10.62: each kind dies in its own way. Nothing here had a sound before.
    var DK=arguments[3]||'crawler';
    if(DK==='raider'){
      // a man: a hard grunt cut short, then the fall
      var dro=a.createOscillator(),drg=a.createGain(),drf=a.createBiquadFilter();
      dro.type='sawtooth'; dro.frequency.setValueAtTime(140*MJ,t); dro.frequency.exponentialRampToValueAtTime(60*MJ,t+.22);
      drf.type='lowpass'; drf.frequency.value=800;
      drg.gain.setValueAtTime(.10*vol,t); drg.gain.exponentialRampToValueAtTime(.001,t+.26);
      dro.connect(drf); drf.connect(drg); drg.connect(OUT); dro.start(t); dro.stop(t+.28);
      var dfb=a.createBuffer(1,2400,a.sampleRate),dfc=dfb.getChannelData(0);
      for(var dfi=0;dfi<2400;dfi++) dfc[dfi]=(Math.random()*2-1)*Math.pow(1-dfi/2400,2.2);
      var dfs=a.createBufferSource(); dfs.buffer=dfb;
      var dff=a.createBiquadFilter(); dff.type='lowpass'; dff.frequency.value=300;
      var dfg=a.createGain(); dfg.gain.value=.09*vol;
      dfs.connect(dff); dff.connect(dfg); dfg.connect(OUT); dfs.start(t+.30);
    } else if(DK==='crawler'){
      // a squeal cut short, and the legs crackling out
      var cqo=a.createOscillator(),cqg=a.createGain(),cqf=a.createBiquadFilter();
      cqo.type='sawtooth'; cqo.frequency.setValueAtTime(1900*MJ,t); cqo.frequency.exponentialRampToValueAtTime(600*MJ,t+.18);
      cqf.type='bandpass'; cqf.frequency.value=2200; cqf.Q.value=3;
      cqg.gain.setValueAtTime(.06*vol,t); cqg.gain.exponentialRampToValueAtTime(.001,t+.2);
      cqo.connect(cqf); cqf.connect(cqg); cqg.connect(OUT); cqo.start(t); cqo.stop(t+.22);
      for(var cli=0;cli<4;cli++){
        var clb=a.createBuffer(1,340,a.sampleRate),clc=clb.getChannelData(0);
        for(var clj=0;clj<340;clj++) clc[clj]=(Math.random()*2-1)*Math.pow(1-clj/340,5.5);
        var cls=a.createBufferSource(); cls.buffer=clb;
        var clf=a.createBiquadFilter(); clf.type='highpass'; clf.frequency.value=1700;
        var clg=a.createGain(); clg.gain.value=.03*vol;
        cls.connect(clf); clf.connect(clg); clg.connect(OUT); cls.start(t+.2+cli*.07+Math.random()*.02);
      }
    } else if(DK==='sentry'){
      // the servo winding down, then the clank of it settling
      var swo=a.createOscillator(),swg=a.createGain(),swf=a.createBiquadFilter();
      swo.type='sawtooth'; swo.frequency.setValueAtTime(420*MJ,t); swo.frequency.exponentialRampToValueAtTime(90*MJ,t+.5);
      swf.type='lowpass'; swf.frequency.value=900;
      swg.gain.setValueAtTime(.07*vol,t); swg.gain.exponentialRampToValueAtTime(.001,t+.52);
      swo.connect(swf); swf.connect(swg); swg.connect(OUT); swo.start(t); swo.stop(t+.54);
      var sko=a.createOscillator(),skg=a.createGain();
      sko.type='square'; sko.frequency.setValueAtTime(1080*MJ,t+.5);
      skg.gain.setValueAtTime(.03*vol,t+.5); skg.gain.exponentialRampToValueAtTime(.001,t+.58);
      sko.connect(skg); skg.connect(OUT); sko.start(t+.5); sko.stop(t+.6);
      var stb=a.createBuffer(1,2000,a.sampleRate),stc=stb.getChannelData(0);
      for(var sti=0;sti<2000;sti++) stc[sti]=(Math.random()*2-1)*Math.pow(1-sti/2000,2.4);
      var sts=a.createBufferSource(); sts.buffer=stb;
      var stf=a.createBiquadFilter(); stf.type='lowpass'; stf.frequency.value=260;
      var stg=a.createGain(); stg.gain.value=.09*vol;
      sts.connect(stf); stf.connect(stg); stg.connect(OUT); sts.start(t+.52);
    } else if(DK==='snitch'){
      // the drone dropping out of the air, and the pop
      var sno=a.createOscillator(),sng=a.createGain();
      sno.type='triangle'; sno.frequency.setValueAtTime(880*MJ,t); sno.frequency.exponentialRampToValueAtTime(110*MJ,t+.6);
      sng.gain.setValueAtTime(.05*vol,t); sng.gain.exponentialRampToValueAtTime(.001,t+.62);
      sno.connect(sng); sng.connect(OUT); sno.start(t); sno.stop(t+.64);
      var spb=a.createBuffer(1,300,a.sampleRate),spc=spb.getChannelData(0);
      for(var spi=0;spi<300;spi++) spc[spi]=(Math.random()*2-1)*Math.pow(1-spi/300,1.5);
      var sps=a.createBufferSource(); sps.buffer=spb;
      var spf=a.createBiquadFilter(); spf.type='highpass'; spf.frequency.value=1500;
      var spg=a.createGain(); spg.gain.value=.08*vol;
      sps.connect(spf); spf.connect(spg); spg.connect(OUT); sps.start(t+.6);
    } else if(DK==='warden'||DK==='bulwark'){
      // the hydraulics letting go, then something very heavy hitting the ground
      var whb=a.createBuffer(1,9000,a.sampleRate),whc=whb.getChannelData(0);
      for(var whi=0;whi<9000;whi++) whc[whi]=(Math.random()*2-1)*Math.pow(1-whi/9000,1.2);
      var whs=a.createBufferSource(); whs.buffer=whb;
      var whf=a.createBiquadFilter(); whf.type='bandpass'; whf.frequency.value=1200*MJ; whf.Q.value=.6;
      var whg=a.createGain(); whg.gain.value=.07*vol;
      whs.connect(whf); whf.connect(whg); whg.connect(OUT); whs.start(t);
      var wlo=a.createOscillator(),wlg=a.createGain();
      wlo.type='sine'; wlo.frequency.setValueAtTime(70*MJ,t); wlo.frequency.exponentialRampToValueAtTime(28*MJ,t+.5);
      wlg.gain.setValueAtTime(.16*vol,t); wlg.gain.exponentialRampToValueAtTime(.001,t+.55);
      wlo.connect(wlg); wlg.connect(OUT); wlo.start(t); wlo.stop(t+.58);
      var wtb=a.createBuffer(1,4000,a.sampleRate),wtc=wtb.getChannelData(0);
      for(var wti=0;wti<4000;wti++) wtc[wti]=(Math.random()*2-1)*Math.pow(1-wti/4000,2);
      var wts=a.createBufferSource(); wts.buffer=wtb;
      var wtf=a.createBiquadFilter(); wtf.type='lowpass'; wtf.frequency.value=200;
      var wtg=a.createGain(); wtg.gain.value=.14*vol;
      wts.connect(wtf); wtf.connect(wtg); wtg.connect(OUT); wts.start(t+.45);
    } else if(DK==='listener'){
      // the dish spinning down to a stop
      var lso=a.createOscillator(),lsg=a.createGain(),lsf=a.createBiquadFilter();
      lso.type='sawtooth'; lso.frequency.setValueAtTime(1400*MJ,t); lso.frequency.exponentialRampToValueAtTime(200*MJ,t+.7);
      lsf.type='bandpass'; lsf.frequency.value=1500; lsf.Q.value=3;
      lsg.gain.setValueAtTime(.06*vol,t); lsg.gain.exponentialRampToValueAtTime(.001,t+.72);
      lso.connect(lsf); lsf.connect(lsg); lsg.connect(OUT); lso.start(t); lso.stop(t+.74);
      var lko=a.createOscillator(),lkg=a.createGain();
      lko.type='square'; lko.frequency.setValueAtTime(760,t+.72);
      lkg.gain.setValueAtTime(.025*vol,t+.72); lkg.gain.exponentialRampToValueAtTime(.001,t+.78);
      lko.connect(lkg); lkg.connect(OUT); lko.start(t+.72); lko.stop(t+.8);
    } else {
      // anything else: a flat crunch
      var gdb=a.createBuffer(1,3000,a.sampleRate),gdc=gdb.getChannelData(0);
      for(var gdi=0;gdi<3000;gdi++) gdc[gdi]=(Math.random()*2-1)*Math.pow(1-gdi/3000,2.6);
      var gds=a.createBufferSource(); gds.buffer=gdb;
      var gdf=a.createBiquadFilter(); gdf.type='lowpass'; gdf.frequency.value=900*MJ;
      var gdg=a.createGain(); gdg.gain.value=.08*vol;
      gds.connect(gdf); gdf.connect(gdg); gdg.connect(OUT); gds.start(t);
    }
  } else if(type==='hitm'){
    // v10.62: a round landing on plate: a bright tick and a short ping
    var hmb=a.createBuffer(1,260,a.sampleRate),hmc=hmb.getChannelData(0);
    for(var hmi=0;hmi<260;hmi++) hmc[hmi]=(Math.random()*2-1)*Math.pow(1-hmi/260,2.4);
    var hms=a.createBufferSource(); hms.buffer=hmb;
    var hmf=a.createBiquadFilter(); hmf.type='highpass'; hmf.frequency.value=2500*MJ;
    var hmg=a.createGain(); hmg.gain.value=.09*vol;
    hms.connect(hmf); hmf.connect(hmg); hmg.connect(OUT); hms.start(t);
    var hpo=a.createOscillator(),hpg=a.createGain();
    hpo.type='triangle'; hpo.frequency.setValueAtTime(1800*MJ,t); hpo.frequency.exponentialRampToValueAtTime(900*MJ,t+.09);
    hpg.gain.setValueAtTime(.05*vol,t); hpg.gain.exponentialRampToValueAtTime(.001,t+.12);
    hpo.connect(hpg); hpg.connect(OUT); hpo.start(t); hpo.stop(t+.14);
  } else if(type==='hitr'){
    // v10.62: a round landing on a man: a dull thud, nothing bright in it
    var hrb=a.createBuffer(1,900,a.sampleRate),hrc=hrb.getChannelData(0);
    for(var hri=0;hri<900;hri++) hrc[hri]=(Math.random()*2-1)*Math.pow(1-hri/900,3);
    var hrs=a.createBufferSource(); hrs.buffer=hrb;
    var hrf=a.createBiquadFilter(); hrf.type='lowpass'; hrf.frequency.value=500*MJ;
    var hrg=a.createGain(); hrg.gain.value=.10*vol;
    hrs.connect(hrf); hrf.connect(hrg); hrg.connect(OUT); hrs.start(t);
    var hto=a.createOscillator(),htg=a.createGain();
    hto.type='sine'; hto.frequency.setValueAtTime(140*MJ,t); hto.frequency.exponentialRampToValueAtTime(70*MJ,t+.08);
    htg.gain.setValueAtTime(.08*vol,t); htg.gain.exponentialRampToValueAtTime(.001,t+.1);
    hto.connect(htg); htg.connect(OUT); hto.start(t); hto.stop(t+.12);
  } else if(type==='grind'){
    // v10.62: the Bulwark, which had no voice: a slow low grind of plate on
    // plate, with a click when it stops. Hunting, it grinds faster and twice.
    var gnH=arguments[3]?1:0;
    var gno=a.createOscillator(),gng=a.createGain(),gnf=a.createBiquadFilter();
    gno.type='sawtooth'; gno.frequency.setValueAtTime((gnH?78:55)*MJ,t); gno.frequency.linearRampToValueAtTime((gnH?92:62)*MJ,t+(gnH?.3:.5));
    gnf.type='lowpass'; gnf.frequency.value=gnH?420:300; gnf.Q.value=2;
    gng.gain.setValueAtTime(.001,t); gng.gain.linearRampToValueAtTime((gnH?.09:.06)*vol,t+.08); gng.gain.exponentialRampToValueAtTime(.001,t+(gnH?.34:.56));
    gno.connect(gnf); gnf.connect(gng); gng.connect(OUT); gno.start(t); gno.stop(t+(gnH?.36:.58));
    var gnk=gnH?[.3,.42]:[.5];
    for(var gki=0;gki<gnk.length;gki++){
      var gko=a.createOscillator(),gkg=a.createGain();
      gko.type='square'; gko.frequency.setValueAtTime(640*MJ,t+gnk[gki]);
      gkg.gain.setValueAtTime(.03*vol,t+gnk[gki]); gkg.gain.exponentialRampToValueAtTime(.001,t+gnk[gki]+.06);
      gko.connect(gkg); gkg.connect(OUT); gko.start(t+gnk[gki]); gko.stop(t+gnk[gki]+.08);
    }
  } else if(type==='servo'){
    // A servo sweep: a filtered tone that slides across, with a mechanical tick
'@

# 3. The idle voices jitter.
SubRx @'
    var f0=hn?300:190,f1=hn?520:260;
'@ @'
    var f0=(hn?300:190)*MJ,f1=(hn?520:260)*MJ;   // v10.62: jitter
'@
SubRx @'
    sf.type='bandpass'; sf.frequency.value=hn?900:620; sf.Q.value=6;
'@ @'
    sf.type='bandpass'; sf.frequency.value=(hn?900:620)*MJ; sf.Q.value=6;
'@
SubRx @'
    d1.frequency.value=hn3?880:660; d2.frequency.value=(hn3?880:660)*1.007;
'@ @'
    d1.frequency.value=(hn3?880:660)*MJ; d2.frequency.value=(hn3?880:660)*1.007*MJ;   // v10.62: jitter
'@
SubRx @'
    var hf=a.createBiquadFilter(); hf.type='bandpass'; hf.frequency.value=1500; hf.Q.value=.8;
'@ @'
    var hf=a.createBiquadFilter(); hf.type='bandpass'; hf.frequency.value=1500*MJ; hf.Q.value=.8;   // v10.62: jitter
'@
SubRx @'
    ho.type='sine'; ho.frequency.setValueAtTime(64,t);
'@ @'
    ho.type='sine'; ho.frequency.setValueAtTime(64*MJ,t);
'@
SubRx @'
      so2.frequency.setValueAtTime(420,t);
'@ @'
      so2.frequency.setValueAtTime(420*MJ,t);   // v10.62: jitter
'@
SubRx @'
      var kf=a.createBiquadFilter(); kf.type='bandpass'; kf.frequency.value=760; kf.Q.value=9;
'@ @'
      var kf=a.createBiquadFilter(); kf.type='bandpass'; kf.frequency.value=760*MJ; kf.Q.value=9;   // v10.62: jitter
'@

# 4. The Bulwark has a voice.
SubRx @'
  listener:{v:'dish',    idle:[3.4,5.2], hunt:[0.8,1.2], far:820},
'@ @'
  listener:{v:'dish',    idle:[3.4,5.2], hunt:[0.8,1.2], far:820},
  bulwark: {v:'grind',   idle:[2.4,3.8], hunt:[1.2,1.8], far:760},   // v10.62: it had no voice at all
'@

# 5. Where the deaths and the hits play.
SubRx @'
      spark(e.x,e.y,e.kind==='raider'?'#c8452f':'#ffc04a',22,300);
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
      G.ents.splice(i,1); continue;
'@ @'
      sfx('die',e.x,e.y,e.kind);   // v10.62: each kind dies in its own way
      spark(e.x,e.y,e.kind==='raider'?'#c8452f':'#ffc04a',22,300);
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
      G.ents.splice(i,1); continue;
'@
SubRx @'
              sfx("hit",en.x,en.y); hit=true; break;
'@ @'
              sfx(en.kind==='raider'?'hitr':'hitm',en.x,en.y,en.kind); hit=true; break;   // v10.62: plate ticks, a man thuds
'@

SubRx @'
var VER='10.57';
'@ @'
var VER='10.62';
'@
SubRx @'
  now:'v10.57: footsteps. Heel then sole, left and right in the ear, the ground under you adds its own tell (grit, a creaking board, ringing plate, a rustle, a splash and a drip), a sprint lands harder and a crouch softer, and the machines and the pillagers now walk on the same five surfaces you do.',
'@ @'
  now:'v10.62: the machines. Each kind dies in its own way, where nothing died out loud before; a round landing on plate ticks and a round landing on a man thuds, instead of both sounding like you being hit; the Bulwark has a voice; and every machine voice jitters so it never repeats itself exactly.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
