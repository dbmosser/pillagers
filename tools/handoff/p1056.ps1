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

# ============ HIS NOTE, 2026-09-03 about 19:40: "also work on improving sound
# ============ whenever you get a chance -- guns, footsteps, robots, etc --
# ============ everything should sound unique and crisp like a triple-A game".
# ============ Guns first. The audit found sixteen guns sharing eleven voices:
# ============ the Magnum and the Longshot had no entry and fell back to the
# ============ Auto Rifle, three pairs differed only by a lowpass corner, every
# ============ shot replayed the identical waveform, and no reload, dry pull
# ============ or bolt made any sound at all. Every gun has its own voice now:
# ============ a crack (noise, its own length, highpass and lowpass), a body (a
# ============ pitched thump with its own start and fall), and for the big guns
# ============ a tail (the room answering) and the action cycling after the
# ============ shot. Six percent of jitter per shot on brightness, body and
# ============ level, so no two shots are the same. Reloads click out and in,
# ============ the bolt goes home when a reload finishes, and an empty gun clicks.

# 1. The voice table and the generator.
SubRx @'
    var FV={
      pistol:{len:1700,lp:2600,g:.13,decay:3.6},
      tacker:{len:1700,lp:2400,g:.13,decay:3.6},
      smg:{len:1500,lp:2100,g:.11,decay:4.0},
      sputter:{len:1500,lp:2000,g:.11,decay:4.0},
      chatter:{len:1900,lp:2200,g:.12,decay:3.8},
      carbine:{len:2000,lp:2300,g:.13,decay:3.6},
      rifle:{len:2600,lp:0,g:.16,decay:3.2},
      dmr:{len:5200,lp:1400,g:.20,decay:2.4,thump:1},
      shotgun:{len:4200,lp:900,g:.22,decay:2.2,thump:1},
      scuttle:{len:4200,lp:950,g:.20,decay:2.2,thump:1},
      lmg:{len:2400,lp:1500,g:.15,decay:2.9},
      // The Whisper is a cough, not a crack: short, heavily filtered, quiet.
      whisper:{len:900,lp:900,g:.07,decay:4.2},
      lance:{len:6400,lp:1200,g:.24,decay:2.0,thump:1}
    };
    var V=FV[arguments[3]]||FV.rifle;
    var b=a.createBuffer(1,V.len,a.sampleRate),c=b.getChannelData(0);
    for(var i=0;i<V.len;i++) c[i]=(Math.random()*2-1)*Math.pow(1-i/V.len,V.decay);
    var s=a.createBufferSource(); s.buffer=b;
    var f=a.createBiquadFilter(); f.type='lowpass';
    f.frequency.value=V.lp||(650+1900*vol);
    var g=a.createGain(); g.gain.value=V.g*vol;
    s.connect(f); f.connect(g); g.connect(OUT); s.start(t);
    if(V.thump){
      var to=a.createOscillator(),tg=a.createGain();
      to.type='sine'; to.frequency.setValueAtTime(120,t); to.frequency.exponentialRampToValueAtTime(45,t+.12);
      tg.gain.setValueAtTime(.14*vol,t); tg.gain.exponentialRampToValueAtTime(.001,t+.16);
      to.connect(tg); tg.connect(OUT); to.start(t); to.stop(t+.18);
    }
'@ @'
    // v10.56, his note: unique and crisp. Every gun its own crack (len, hp, lp,
    // decay), its own body (a pitched thump f0 to f1 over d), and where it
    // earns it a tail (the room answering) and the action cycling afterwards.
    // The Magnum and the Longshot had no voice and borrowed the rifle's.
    var FV={
      pistol: {len:1700,lp:2600,hp:300,g:.13,decay:3.6,body:{f0:200,f1:70,d:.09,g:.10,type:'sine'}},
      tacker: {len:1300,lp:3400,hp:600,g:.12,decay:4.4,body:{f0:260,f1:110,d:.06,g:.07,type:'triangle'}},
      smg:    {len:1500,lp:2100,hp:200,g:.11,decay:4.0,body:{f0:170,f1:80,d:.07,g:.08,type:'sine'}},
      sputter:{len:1200,lp:1600,hp:150,g:.11,decay:4.6,body:{f0:130,f1:60,d:.06,g:.09,type:'square'},rattle:1},
      chatter:{len:1900,lp:2200,hp:250,g:.12,decay:3.8,body:{f0:190,f1:75,d:.08,g:.09,type:'sine'}},
      carbine:{len:2000,lp:2300,hp:220,g:.13,decay:3.6,body:{f0:210,f1:80,d:.08,g:.10,type:'sine'}},
      rifle:  {len:2600,lp:0,hp:180,g:.16,decay:3.2,body:{f0:180,f1:60,d:.10,g:.12,type:'sine'}},
      dmr:    {len:5200,lp:1400,hp:120,g:.20,decay:2.4,body:{f0:120,f1:45,d:.12,g:.14,type:'sine'},bolt:1},
      magnum: {len:4800,lp:1100,hp:80,g:.24,decay:2.0,body:{f0:95,f1:38,d:.16,g:.20,type:'sine'},tail:1},
      sniper: {len:7600,lp:1000,hp:60,g:.26,decay:1.8,body:{f0:80,f1:32,d:.22,g:.22,type:'sine'},tail:1,bolt:1},
      shotgun:{len:4200,lp:900,hp:100,g:.22,decay:2.2,body:{f0:120,f1:45,d:.12,g:.14,type:'sine'},pump:1},
      scuttle:{len:3200,lp:1300,hp:200,g:.20,decay:2.6,body:{f0:150,f1:60,d:.09,g:.11,type:'triangle'},pump:1},
      lmg:    {len:2400,lp:1500,hp:160,g:.15,decay:2.9,body:{f0:150,f1:60,d:.09,g:.11,type:'sine'}},
      // The Whisper is a cough, not a crack: short, heavily filtered, quiet.
      whisper:{len:900,lp:900,hp:200,g:.07,decay:4.2,body:{f0:140,f1:90,d:.05,g:.03,type:'sine'}},
      lance:  {len:6400,lp:1200,hp:60,g:.24,decay:2.0,body:{f0:90,f1:34,d:.20,g:.20,type:'sine'},tail:1}
    };
    var V=FV[arguments[3]]||FV.rifle;
    // No two shots alike: six percent of jitter, rolled per shot, on the
    // brightness and the body, and separately on the level.
    var J=1+(Math.random()*2-1)*0.06, J2=1+(Math.random()*2-1)*0.06;
    var b=a.createBuffer(1,V.len,a.sampleRate),c=b.getChannelData(0);
    for(var i=0;i<V.len;i++) c[i]=(Math.random()*2-1)*Math.pow(1-i/V.len,V.decay);
    var s=a.createBufferSource(); s.buffer=b;
    var fh=a.createBiquadFilter(); fh.type='highpass'; fh.frequency.value=(V.hp||120)*J;
    var f=a.createBiquadFilter(); f.type='lowpass';
    f.frequency.value=(V.lp||(650+1900*vol))*J;
    var g=a.createGain(); g.gain.value=V.g*vol*J2;
    s.connect(fh); fh.connect(f); f.connect(g); g.connect(OUT); s.start(t);
    if(V.body){
      var to=a.createOscillator(),tg=a.createGain();
      to.type=V.body.type||'sine';
      to.frequency.setValueAtTime(V.body.f0*J,t); to.frequency.exponentialRampToValueAtTime(V.body.f1*J,t+V.body.d);
      tg.gain.setValueAtTime(V.body.g*vol*J2,t); tg.gain.exponentialRampToValueAtTime(.001,t+V.body.d+.04);
      to.connect(tg); tg.connect(OUT); to.start(t); to.stop(t+V.body.d+.06);
    }
    if(V.tail){
      // the room answering a big gun: a longer, darker wash under the crack
      var tl=Math.round(V.len*1.6),tb=a.createBuffer(1,tl,a.sampleRate),tc=tb.getChannelData(0);
      for(var ti=0;ti<tl;ti++) tc[ti]=(Math.random()*2-1)*Math.pow(1-ti/tl,1.4);
      var ts=a.createBufferSource(); ts.buffer=tb;
      var tf=a.createBiquadFilter(); tf.type='lowpass'; tf.frequency.value=420*J;
      var tgn=a.createGain(); tgn.gain.value=V.g*vol*.35;
      ts.connect(tf); tf.connect(tgn); tgn.connect(OUT); ts.start(t+.01);
    }
    if(V.bolt||V.pump){
      // the action cycling after the shot: one click for a bolt, two for a pump
      var ck=V.pump?[.28,.42]:[.25],cfq=V.pump?1400:2400;
      for(var ci=0;ci<ck.length;ci++){
        var cb=a.createBuffer(1,300,a.sampleRate),cc2=cb.getChannelData(0);
        for(var cj=0;cj<300;cj++) cc2[cj]=(Math.random()*2-1)*Math.pow(1-cj/300,2);
        var cs=a.createBufferSource(); cs.buffer=cb;
        var cfl=a.createBiquadFilter(); cfl.type='bandpass'; cfl.frequency.value=cfq; cfl.Q.value=3;
        var cg=a.createGain(); cg.gain.value=.08*vol;
        cs.connect(cfl); cfl.connect(cg); cg.connect(OUT); cs.start(t+ck[ci]);
      }
    }
    if(V.rattle){
      // a second, lighter crack a hair behind the first: the Sputter sputters
      var rl2=Math.round(V.len*.6),rb2=a.createBuffer(1,rl2,a.sampleRate),rc2=rb2.getChannelData(0);
      for(var ri2=0;ri2<rl2;ri2++) rc2[ri2]=(Math.random()*2-1)*Math.pow(1-ri2/rl2,V.decay);
      var rs2=a.createBufferSource(); rs2.buffer=rb2;
      var rf2=a.createBiquadFilter(); rf2.type='lowpass'; rf2.frequency.value=(V.lp||1600)*.8*J;
      var rg2=a.createGain(); rg2.gain.value=V.g*vol*.6;
      rs2.connect(rf2); rf2.connect(rg2); rg2.connect(OUT); rs2.start(t+.012);
    }
'@

# 2. Three voices that did not exist: the magazine out and in, the bolt going
#    home, and the click of an empty gun.
SubRx @'
    if(type==='shot'){
    // Weapon voices. One generator, one table: every family gets its own
'@ @'
    if(type==='reload'){
    // v10.56: the magazine out, a bright click, then in, a duller thock.
    var rlb=a.createBuffer(1,420,a.sampleRate),rlc=rlb.getChannelData(0);
    for(var rli=0;rli<420;rli++) rlc[rli]=(Math.random()*2-1)*Math.pow(1-rli/420,2.2);
    var rls=a.createBufferSource(); rls.buffer=rlb;
    var rlf=a.createBiquadFilter(); rlf.type='bandpass'; rlf.frequency.value=2600; rlf.Q.value=3;
    var rlg=a.createGain(); rlg.gain.value=.10*vol;
    rls.connect(rlf); rlf.connect(rlg); rlg.connect(OUT); rls.start(t);
    var rlo=a.createOscillator(),rlog=a.createGain();
    rlo.type='triangle'; rlo.frequency.setValueAtTime(320,t+.14); rlo.frequency.exponentialRampToValueAtTime(120,t+.20);
    rlog.gain.setValueAtTime(.0001,t); rlog.gain.setValueAtTime(.12*vol,t+.14); rlog.gain.exponentialRampToValueAtTime(.001,t+.24);
    rlo.connect(rlog); rlog.connect(OUT); rlo.start(t+.14); rlo.stop(t+.26);
    }
    if(type==='reloadin'){
    // v10.56: the bolt going home when the reload finishes: a click and a short thud.
    var rib=a.createBuffer(1,300,a.sampleRate),ric=rib.getChannelData(0);
    for(var rii=0;rii<300;rii++) ric[rii]=(Math.random()*2-1)*Math.pow(1-rii/300,1.8);
    var ris=a.createBufferSource(); ris.buffer=rib;
    var rif=a.createBiquadFilter(); rif.type='bandpass'; rif.frequency.value=1900; rif.Q.value=2.4;
    var rig=a.createGain(); rig.gain.value=.11*vol;
    ris.connect(rif); rif.connect(rig); rig.connect(OUT); ris.start(t);
    var rio=a.createOscillator(),riog=a.createGain();
    rio.type='sine'; rio.frequency.setValueAtTime(220,t); rio.frequency.exponentialRampToValueAtTime(90,t+.06);
    riog.gain.setValueAtTime(.10*vol,t); riog.gain.exponentialRampToValueAtTime(.001,t+.09);
    rio.connect(riog); riog.connect(OUT); rio.start(t); rio.stop(t+.1);
    }
    if(type==='dry'){
    // v10.56: an empty gun: one dull click and nothing else, which is the point.
    var dyb=a.createBuffer(1,220,a.sampleRate),dyc=dyb.getChannelData(0);
    for(var dyi=0;dyi<220;dyi++) dyc[dyi]=(Math.random()*2-1)*Math.pow(1-dyi/220,2.6);
    var dys=a.createBufferSource(); dys.buffer=dyb;
    var dyf=a.createBiquadFilter(); dyf.type='bandpass'; dyf.frequency.value=1400; dyf.Q.value=4;
    var dyg=a.createGain(); dyg.gain.value=.09*vol;
    dys.connect(dyf); dyf.connect(dyg); dyg.connect(OUT); dys.start(t);
    }
    if(type==='shot'){
    // Weapon voices. One generator, one table: every family gets its own
'@

# 3. Where they play: every reload start, the reload finishing, the dry pull.
SubRx @'
      var take=Math.min(p.wep.mag-p.ammo,p.reserve);
      p.ammo+=take; p.reserve-=take; say('Reloaded');
'@ @'
      var take=Math.min(p.wep.mag-p.ammo,p.reserve);
      p.ammo+=take; p.reserve-=take; say('Reloaded');
      if(!G.sim) blip('reloadin');   // v10.56: the bolt goes home
'@
SubRx @'
  if(keys['KeyR']&&p.reloading<=0&&p.ammo<p.wep.mag&&p.reserve>0){ p.reloading=p.wep.reload*buzzSlow(); T.reloads++; }
'@ @'
  if(keys['KeyR']&&p.reloading<=0&&p.ammo<p.wep.mag&&p.reserve>0){ p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blip('reload'); }   // v10.56
'@
SubRx @'
  if(mouse.down&&p.reloading<=0&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0){
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++;
'@ @'
  if(mouse.down&&p.reloading<=0&&p.wep.mag>0&&p.ammo<=0&&p.reserve>0&&!p.downed&&p.jam<=0){
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blip('reload');   // v10.56
'@
SubRx @'
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim) say('Reloading...');
        } else if(p.reserve<=0&&!p.fired) say('Out of ammo.');
'@ @'
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim){ say('Reloading...'); blip('reload'); }   // v10.56
        } else if(p.reserve<=0&&!p.fired){ say('Out of ammo.'); if(!G.sim) blip('dry'); }   // v10.56: an empty gun clicks
'@

SubRx @'
var VER='10.55';
'@ @'
var VER='10.56';
'@
SubRx @'
  now:'v10.55: footprints follow the ground you actually cover, one every 56 units after the wall push, so sprinting into a wall no longer piles prints under you at a spot you could not stand.',
'@ @'
  now:'v10.56: every gun has its own voice. The Magnum and the Longshot no longer borrow the Auto Rifle, the guns that sounded alike do not, no two shots are the same, and reloads, the bolt going home and an empty gun make a sound at all.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
