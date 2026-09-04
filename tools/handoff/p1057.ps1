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
# ============ unique and crisp like a triple-A game". Footsteps, the second
# ============ family. The audit: the player's five surfaces replayed the same
# ============ waveform every step, dead centre, on a fixed clock; the machines
# ============ and pillagers had two recipes between them with no surface at
# ============ all, so a pillager on plate steel and one in the woods stepped
# ============ identically. Now every step is heel then sole, left and right
# ============ alternate in the ear, the surface adds its own tell (grit on
# ============ stone, a creak on boards, the ring on steel, a rustle in leaves,
# ============ a splash and a drip in water), a sprint lands harder and a
# ============ crouch softer, the clock breathes, and the machines and the
# ============ pillagers walk on the same five surfaces you do.

# 1. The player's step: stance and side ride along, the clock breathes.
SubRx @'
var PSTEP=0;
'@ @'
var PSTEP=0,PSIDE=0;   // v10.57: PSIDE alternates left and right in the ear
'@
SubRx @'
  var bsh=G.pBush,surf=bsh?'leaf':surfAt(p.x,p.y);
  blip('foot',crouch?540:(G.sprinting?0:180),0,surf);
'@ @'
  var bsh=G.pBush,surf=bsh?'leaf':surfAt(p.x,p.y);
  // v10.57: left, right, left, a little off centre each way, and the stance
  // tells the generator how hard the foot lands.
  PSIDE=PSIDE?0:1;
  blip('foot',crouch?540:(G.sprinting?0:180),PSIDE?0.16:-0.16,surf,crouch?'crouch':(G.sprinting?'sprint':'walk'));
'@
SubRx @'
  PSTEP=G.sprinting?0.31:(crouch?0.64:0.45);
}
'@ @'
  PSTEP=(G.sprinting?0.31:(crouch?0.64:0.45))*(0.93+Math.random()*0.14);   // v10.57: the clock breathes
}
'@

# 2. The step recipe: heel then sole, the surface's own tell, the stance, jitter.
SubRx @'
    var F=SF[arguments[3]]||SF.stone;
    var bf=a.createBuffer(1,F.len,a.sampleRate),cf=bf.getChannelData(0);
    for(var iF=0;iF<F.len;iF++) cf[iF]=(Math.random()*2-1)*Math.pow(1-iF/F.len,F.dec);
    var sfS=a.createBufferSource(); sfS.buffer=bf;
    var ff=a.createBiquadFilter(); ff.type='lowpass';
    ff.frequency.value=F.lp; ff.Q.value=F.q;
    var gf=a.createGain(); gf.gain.value=F.g*vol;
    sfS.connect(ff); ff.connect(gf); gf.connect(OUT); sfS.start(t);
    if(F.body){
      var bo=a.createOscillator(),bg=a.createGain();
      bo.type='sine'; bo.frequency.setValueAtTime(F.body,t);
      bo.frequency.exponentialRampToValueAtTime(F.body*0.55,t+.09);
      bg.gain.setValueAtTime(.035*vol,t); bg.gain.exponentialRampToValueAtTime(.001,t+.11);
      bo.connect(bg); bg.connect(OUT); bo.start(t); bo.stop(t+.12);
    }
    if(F.ring){
      var ro=a.createOscillator(),rg=a.createGain();
      ro.type='triangle'; ro.frequency.setValueAtTime(1240+Math.random()*260,t);
      rg.gain.setValueAtTime(.020*vol,t); rg.gain.exponentialRampToValueAtTime(.001,t+.22);
      ro.connect(rg); rg.connect(OUT); ro.start(t); ro.stop(t+.23);
    }
'@ @'
    var F=SF[arguments[3]]||SF.stone;
    // v10.57: the stance and a little jitter. A sprint lands harder and
    // longer, a crouch is a touch; nothing replays the identical step twice.
    var ST=arguments[4]||'walk';
    var FJ=1+(Math.random()*2-1)*0.08, FJ2=1+(Math.random()*2-1)*0.08;
    var stG=ST==='sprint'?1.35:(ST==='crouch'?0.7:(ST==='heavy'?1.5:1));
    var stD=ST==='sprint'?0.85:(ST==='crouch'?1.25:1);
    // the heel: a short soft tap ahead of the sole
    var hb=a.createBuffer(1,260,a.sampleRate),hc=hb.getChannelData(0);
    for(var ih=0;ih<260;ih++) hc[ih]=(Math.random()*2-1)*Math.pow(1-ih/260,3);
    var hs=a.createBufferSource(); hs.buffer=hb;
    var hf=a.createBiquadFilter(); hf.type='lowpass'; hf.frequency.value=F.lp*0.7*FJ; hf.Q.value=F.q;
    var hg=a.createGain(); hg.gain.value=F.g*vol*stG*0.45*FJ2;
    hs.connect(hf); hf.connect(hg); hg.connect(OUT); hs.start(t);
    // the sole
    var bf=a.createBuffer(1,F.len,a.sampleRate),cf=bf.getChannelData(0);
    for(var iF=0;iF<F.len;iF++) cf[iF]=(Math.random()*2-1)*Math.pow(1-iF/F.len,F.dec*stD);
    var sfS=a.createBufferSource(); sfS.buffer=bf;
    var ff=a.createBiquadFilter(); ff.type='lowpass';
    ff.frequency.value=F.lp*FJ; ff.Q.value=F.q;
    var gf=a.createGain(); gf.gain.value=F.g*vol*stG*FJ2;
    sfS.connect(ff); ff.connect(gf); gf.connect(OUT); sfS.start(t+.045);
    if(F.body){
      var bo=a.createOscillator(),bg=a.createGain();
      bo.type='sine'; bo.frequency.setValueAtTime(F.body*FJ,t+.045);
      bo.frequency.exponentialRampToValueAtTime(F.body*0.55*FJ,t+.135);
      bg.gain.setValueAtTime(.035*vol*stG,t+.045); bg.gain.exponentialRampToValueAtTime(.001,t+.155);
      bo.connect(bg); bg.connect(OUT); bo.start(t+.045); bo.stop(t+.165);
    }
    if(F.ring){
      var ro=a.createOscillator(),rg=a.createGain();
      ro.type='triangle'; ro.frequency.setValueAtTime(1240+Math.random()*260,t+.045);
      rg.gain.setValueAtTime(.020*vol*stG,t+.045); rg.gain.exponentialRampToValueAtTime(.001,t+.265);
      ro.connect(rg); rg.connect(OUT); ro.start(t+.045); ro.stop(t+.275);
    }
    // the surface's own tell, after the sole
    var SU=arguments[3]||'stone';
    if(SU==='stone'){
      // grit: a bright short scatter as the sole settles
      var gb=a.createBuffer(1,420,a.sampleRate),gc=gb.getChannelData(0);
      for(var ig=0;ig<420;ig++) gc[ig]=(Math.random()*2-1)*Math.pow(1-ig/420,1.6);
      var gsrc=a.createBufferSource(); gsrc.buffer=gb;
      var gfh=a.createBiquadFilter(); gfh.type='highpass'; gfh.frequency.value=3000*FJ;
      var ggn=a.createGain(); ggn.gain.value=.018*vol*stG;
      gsrc.connect(gfh); gfh.connect(ggn); ggn.connect(OUT); gsrc.start(t+.07);
    } else if(SU==='wood'&&Math.random()<0.3){
      // one board in three creaks under the weight
      var wo=a.createOscillator(),wg=a.createGain();
      wo.type='sawtooth'; wo.frequency.setValueAtTime(190*FJ,t+.06); wo.frequency.exponentialRampToValueAtTime(140*FJ,t+.16);
      var wf=a.createBiquadFilter(); wf.type='lowpass'; wf.frequency.value=900;
      wg.gain.setValueAtTime(.0001,t); wg.gain.linearRampToValueAtTime(.022*vol*stG,t+.09); wg.gain.exponentialRampToValueAtTime(.001,t+.19);
      wo.connect(wf); wf.connect(wg); wg.connect(OUT); wo.start(t+.06); wo.stop(t+.2);
    } else if(SU==='leaf'){
      // a rustle: a second crackle behind the first
      var lb=a.createBuffer(1,1400,a.sampleRate),lc=lb.getChannelData(0);
      for(var il=0;il<1400;il++) lc[il]=(Math.random()*2-1)*Math.pow(1-il/1400,1.4)*(Math.random()<0.35?1:0.2);
      var ls=a.createBufferSource(); ls.buffer=lb;
      var lf=a.createBiquadFilter(); lf.type='highpass'; lf.frequency.value=2400*FJ;
      var lg=a.createGain(); lg.gain.value=.03*vol*stG;
      ls.connect(lf); lf.connect(lg); lg.connect(OUT); ls.start(t+.09);
    } else if(SU==='water'){
      // the splash, then a drip
      var sb=a.createBuffer(1,2200,a.sampleRate),sc2=sb.getChannelData(0);
      for(var isp=0;isp<2200;isp++) sc2[isp]=(Math.random()*2-1)*Math.pow(1-isp/2200,1.2);
      var ssp=a.createBufferSource(); ssp.buffer=sb;
      var sfp=a.createBiquadFilter(); sfp.type='bandpass'; sfp.frequency.value=2400*FJ; sfp.Q.value=0.8;
      var sgp=a.createGain(); sgp.gain.value=.05*vol*stG;
      ssp.connect(sfp); sfp.connect(sgp); sgp.connect(OUT); ssp.start(t+.05);
      var dro=a.createOscillator(),drg=a.createGain();
      dro.type='triangle'; dro.frequency.setValueAtTime(1800*FJ,t+.22); dro.frequency.exponentialRampToValueAtTime(900*FJ,t+.30);
      drg.gain.setValueAtTime(.0001,t); drg.gain.setValueAtTime(.014*vol,t+.22); drg.gain.exponentialRampToValueAtTime(.001,t+.32);
      dro.connect(drg); drg.connect(OUT); dro.start(t+.22); dro.stop(t+.34);
    }
'@

# 3. The machines and the pillagers walk on the same ground you do.
SubRx @'
  var heavy=(stepSoundFor(best.kind)==='stepHeavy');
  blip(heavy?'stepHeavy':'step',ear.d*1.35,ear.pan);
  STEP_T=(heavy?0.62:0.44)*(best.state==='chase'?0.72:1);
'@ @'
  var heavy=(stepSoundFor(best.kind)==='stepHeavy');
  // v10.57: the surface under THEM, through the same five-surface step you
  // walk with; a heavy keeps its low clank and takes the surface's tell on top.
  var bsurf=surfAt(best.x,best.y);
  if(heavy) blip('stepHeavy',ear.d*1.35,ear.pan,bsurf);
  else blip('foot',ear.d*1.35,ear.pan,bsurf,best.state==='chase'?'sprint':'walk');
  STEP_T=(heavy?0.62:0.44)*(best.state==='chase'?0.72:1)*(0.92+Math.random()*0.16);
'@
SubRx @'
    if(hv){
      var oh=a.createOscillator(),gh=a.createGain();
      oh.type='sine'; oh.frequency.setValueAtTime(96,t); oh.frequency.exponentialRampToValueAtTime(48,t+.10);
      gh.gain.setValueAtTime(.05*vol,t); gh.gain.exponentialRampToValueAtTime(.001,t+.12);
      oh.connect(gh); gh.connect(OUT); oh.start(t); oh.stop(t+.13);
    }
'@ @'
    if(hv){
      var oh=a.createOscillator(),gh=a.createGain();
      oh.type='sine'; oh.frequency.setValueAtTime(96,t); oh.frequency.exponentialRampToValueAtTime(48,t+.10);
      gh.gain.setValueAtTime(.05*vol,t); gh.gain.exponentialRampToValueAtTime(.001,t+.12);
      oh.connect(gh); gh.connect(OUT); oh.start(t); oh.stop(t+.13);
      // v10.57: the surface's tell under a heavy: plate rings, boards knock,
      // water splashes, leaves crackle.
      var HSU=arguments[3]||'stone';
      if(HSU==='metal'){
        var hr=a.createOscillator(),hrg=a.createGain();
        hr.type='triangle'; hr.frequency.setValueAtTime(980+Math.random()*200,t);
        hrg.gain.setValueAtTime(.03*vol,t); hrg.gain.exponentialRampToValueAtTime(.001,t+.3);
        hr.connect(hrg); hrg.connect(OUT); hr.start(t); hr.stop(t+.31);
      } else if(HSU==='wood'){
        var hw=a.createOscillator(),hwg=a.createGain();
        hw.type='sine'; hw.frequency.setValueAtTime(150,t); hw.frequency.exponentialRampToValueAtTime(80,t+.1);
        hwg.gain.setValueAtTime(.05*vol,t); hwg.gain.exponentialRampToValueAtTime(.001,t+.13);
        hw.connect(hwg); hwg.connect(OUT); hw.start(t); hw.stop(t+.14);
      } else if(HSU==='water'||HSU==='leaf'){
        var hb2=a.createBuffer(1,2000,a.sampleRate),hc2=hb2.getChannelData(0);
        for(var ih2=0;ih2<2000;ih2++) hc2[ih2]=(Math.random()*2-1)*Math.pow(1-ih2/2000,1.3);
        var hs2=a.createBufferSource(); hs2.buffer=hb2;
        var hf2=a.createBiquadFilter(); hf2.type=HSU==='water'?'bandpass':'highpass'; hf2.frequency.value=HSU==='water'?2200:2600;
        var hg2=a.createGain(); hg2.gain.value=.05*vol;
        hs2.connect(hf2); hf2.connect(hg2); hg2.connect(OUT); hs2.start(t+.03);
      }
    }
'@

SubRx @'
var VER='10.56';
'@ @'
var VER='10.57';
'@
SubRx @'
  now:'v10.56: every gun has its own voice. The Magnum and the Longshot no longer borrow the Auto Rifle, the guns that sounded alike do not, no two shots are the same, and reloads, the bolt going home and an empty gun make a sound at all.',
'@ @'
  now:'v10.57: footsteps. Heel then sole, left and right in the ear, the ground under you adds its own tell (grit, a creaking board, ringing plate, a rustle, a splash and a drip), a sprint lands harder and a crouch softer, and the machines and the pillagers now walk on the same five surfaces you do.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
