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

# THE FORGE: ELEMENT EFFECTS AND SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(e.parley>0) f|=2097152; if(e.blind>0) f|=4194304;
'@ @'
  if(e.parley>0) f|=2097152; if(e.blind>0) f|=4194304;
  if(e.burnT>0) f|=8388608; if(e.stunT>0) f|=16777216; if(e.chillT>0) f|=33554432; if(e.frozenT>0) f|=67108864; if(e.corrT>0) f|=134217728;   // v23.xx (forge8): THE FORGE statuses, so player 2 sees them
'@

SubRx @'
e.parley=(f&2097152)?1:0; e.blind=(f&4194304)?1:0;
'@ @'
e.parley=(f&2097152)?1:0; e.blind=(f&4194304)?1:0;
  e.burnT=(f&8388608)?0.3:0; e.stunT=(f&16777216)?0.3:0; e.chillT=(f&33554432)?0.3:0; e.frozenT=(f&67108864)?0.3:0; e.corrT=(f&134217728)?0.3:0;   // v23.xx (forge8): drawn here, run by the host only
'@

SubRx @'
  G.arcFx={x1:e.x,y1:e.y,x2:best.x,y2:best.y,t:0};
'@ @'
  elemArcFx(e.x,e.y,best.x,best.y,1);   // v23.xx (forge8): the arc line, on every window
'@

SubRx @'
  if(m.k==='d'&&m.d&&m.d.length>=4){   // v16.22: a damage number one of the party put up
'@ @'
  if(m.k==='a'&&m.a&&m.a.length>=4){   // v23.xx (forge8): a shock arc the host drew
    a=m.a; if(isFinite(a[0])&&isFinite(a[1])&&isFinite(a[2])&&isFinite(a[3])) elemArcFx(+a[0],+a[1],+a[2],+a[3],0);
    return 'fx:a';
  }
  if(m.k==='d'&&m.d&&m.d.length>=4){   // v16.22: a damage number one of the party put up
'@

SubRx @'
String(b.tint||'#ffd48a').slice(0,9)]};
'@ @'
String(b.tint||'#ffd48a').slice(0,9),b.el?1:0]};   // v23.xx (forge8): 1 for an elemental round, drawn wider
'@

SubRx @'
tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1});
'@ @'
tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1,elw:a[6]?1:0});
'@

SubRx @'
wc.strokeStyle=b.tint; wc.lineWidth=2;
'@ @'
wc.strokeStyle=b.tint; wc.lineWidth=(b.el||b.elw)?3:2;   // v23.xx (forge8): an elemental tracer is wider, in its colour
'@

SubRx @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
'@ @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
  try{ drawElemFx(dt); }catch(_gef){}   // v23.xx (forge8): THE FORGE, flames, arcs, frost, ice and acid on the bodies
'@

SubRx @'
  G.elemAny=1; seat=seat|0;
'@ @'
  G.elemAny=1; seat=seat|0;
  if(!G.sim) elemSnd(e,el);   // v23.xx (forge8): the impact sound and sparks, once per target every 0.15 s
'@

SubRx @'
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
'@ @'
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
      if(!G.sim){ sfx('elFreeze',e.x,e.y); spark(e.x,e.y-10,'#ffffff',10,200); }   // v23.xx (forge8): the crack of the freeze
'@

SubRx @'
function elemAbsorb(e){ return (armorById(e.rig).absorb||0)*((e.corrT>0)?0.5:1); }
'@ @'
function elemAbsorb(e){ return (armorById(e.rig).absorb||0)*((e.corrT>0)?0.5:1); }
// v23.xx, THE FORGE (2026-10-12), forge8: WHAT THE ELEMENTS LOOK AND SOUND LIKE, on both windows. All cosmetic: fxn and fxr only,
// never the seeded stream, never in the sim. On the body that was hit, at the aim point or on the character, never a screen tint
// (his rule: 2.5D is not FPS). The host mirrors five status bits to player 2 (netEntFlags), sends each shock arc as a cosmetic fx
// word, and every window draws the same effects from the same fields. FIRE: flame tongues licking up the body, embers and a warm
// glow, a smoke trail on a panicking pillager. SHOCK: a jagged arc to the chained body, small arcs crawling over a stunned machine.
// CRYO: a pale rim and frost while chilled, a translucent ice block while frozen. ACID: green drips. Elemental tracers are wider.
// A forged gun glows at the hands, gold for MK II and the element colour for MK III, and player 2's state word carries fk and el so
// each window sees the other's glow. Sounds: elFire, elShock, elCryo, elAcid on impact (one per target every 0.15 s) and elFreeze.
function elemSnd(e,el){
  var t;
  if(!G||G.sim||!e||!ELEM[el]) return false;
  t=G.t||0;
  if(e.elSndT!==undefined&&t>=e.elSndT&&t-e.elSndT<0.15) return false;
  e.elSndT=t;
  sfx(ELEM[el].snd,e.x,e.y);
  spark(e.x,e.y-8,ELEM[el].c,6,170);
  return true;
}
function elemArcFx(x1,y1,x2,y2,send){
  var i, m;
  if(!G||G.sim||!isFinite(x1)||!isFinite(y1)||!isFinite(x2)||!isFinite(y2)) return false;
  G.arcs=G.arcs||[];
  if(G.arcs.length<24) G.arcs.push({x1:x1,y1:y1,x2:x2,y2:y2,t:0,life:0.14});
  if(send&&typeof NET==='object'&&NET&&NET.on&&netUpShared()){
    m={t:'fx',k:'a',s:NET.seat,a:[Math.round(x1),Math.round(y1),Math.round(x2),Math.round(y2)]};
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  }
  return true;
}
function elemBodyH(e){ return (e.kind==='raider'||e.kind==='stray'||e.kind==='peddler')?34:Math.max(14,(e.r||14)*1.4+6); }
function elemFlame(x,y,w,h){
  wc.beginPath(); wc.moveTo(x-w,y);
  wc.quadraticCurveTo(x-w*0.7,y-h*0.55,x,y-h);
  wc.quadraticCurveTo(x+w*0.7,y-h*0.55,x+w,y);
  wc.closePath(); wc.fill();
}
function drawElemFx(dt){
  var L, i, e, k, j, t, n=0, r, H, x0, h, a, pts, ph, ang;
  if(!G||G.sim) return 0;
  dt=(isFinite(dt)&&dt>0)?Math.min(dt,0.1):0; t=G.t||0;
  if(G.arcs&&G.arcs.length){
    wc.save(); wc.globalCompositeOperation='lighter'; wc.lineJoin='round'; wc.lineCap='round';
    for(i=G.arcs.length-1;i>=0;i--){
      a=G.arcs[i]; a.t+=dt; if(a.t>=a.life){ G.arcs.splice(i,1); continue; }
      pts=[[a.x1,a.y1-14]];
      for(j=1;j<7;j++) pts.push([a.x1+(a.x2-a.x1)*j/7+fxn(-7,7),a.y1+(a.y2-a.y1)*j/7-14+fxn(-7,7)]);
      pts.push([a.x2,a.y2-14]);
      wc.globalAlpha=clamp(1-a.t/a.life,0,1);
      for(k=0;k<2;k++){
        wc.strokeStyle=k?'#ffffff':ELEM.shock.c; wc.lineWidth=k?1.2:3.5;
        wc.beginPath(); wc.moveTo(pts[0][0],pts[0][1]);
        for(j=1;j<pts.length;j++) wc.lineTo(pts[j][0],pts[j][1]);
        wc.stroke();
      }
      gfxEmit((a.x1+a.x2)/2,(a.y1+a.y2)/2-14,40,ELEM.shock.c,0.6);
      n++;
    }
    wc.restore();
  }
  L=G.ents;
  for(i=0;i<L.length;i++){
    e=L[i];
    if(!(e.burnT>0||e.stunT>0||e.chillT>0||e.frozenT>0||e.corrT>0)) continue;
    if((e.hp<=0&&!e.downed)||e.finished||e.gone||!isFinite(e.x)||!isFinite(e.y)) continue;
    r=e.r||14; H=elemBodyH(e);
    wc.save();
    if(e.burnT>0){
      wc.globalCompositeOperation='lighter';
      for(k=0;k<4;k++){
        x0=e.x+(k-1.5)*r*0.42+Math.sin(t*7+k*2.1)*2;
        h=H*(0.62+0.28*Math.sin(t*13+k*1.7));
        wc.globalAlpha=0.5; wc.fillStyle=ELEM.fire.c; elemFlame(x0,e.y-2,5.5,h);
        wc.globalAlpha=0.65; wc.fillStyle='#ffc04a'; elemFlame(x0,e.y-2,2.6,h*0.6);
      }
      if(fxr()<dt*10) spark(e.x+fxn(-r*0.5,r*0.5),e.y-H*0.5,'#ffb040',1,70);
      if(e.panicT>0&&fxr()<dt*14&&G.puffs) G.puffs.push({x:e.x+fxn(-4,4),y:e.y-4,t:0,life:0.6,c:'#3b3632',r:10});
      gfxEmit(e.x,e.y-H*0.5,r*2.6,'#ff6a2a',0.55);
      n++;
    }
    if(e.stunT>0){
      wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.9; wc.strokeStyle='#bfe0ff'; wc.lineWidth=1.4;
      for(k=0;k<2;k++){
        ang=fxn(0,6.283); wc.beginPath();
        for(j=0;j<5;j++){ var rr2=r*0.95+fxn(-3,3), aa=ang+j*0.45; if(j) wc.lineTo(e.x+Math.cos(aa)*rr2,e.y-H*0.45+Math.sin(aa)*rr2*0.7); else wc.moveTo(e.x+Math.cos(aa)*rr2,e.y-H*0.45+Math.sin(aa)*rr2*0.7); }
        wc.stroke();
      }
      gfxEmit(e.x,e.y-H*0.45,r*2,ELEM.shock.c,0.45);
      n++;
    }
    if(e.frozenT>0){
      wc.globalCompositeOperation='source-over'; wc.globalAlpha=1;
      var bw=r+5, top=e.y-H-7, bot=e.y+4;
      wc.fillStyle='rgba(185,232,255,.36)'; wc.strokeStyle='rgba(255,255,255,.85)'; wc.lineWidth=1.5;
      wc.beginPath(); wc.moveTo(e.x-bw,bot); wc.lineTo(e.x-bw-2,top+6); wc.lineTo(e.x-bw*0.4,top); wc.lineTo(e.x+bw*0.5,top+2);
      wc.lineTo(e.x+bw+2,top+8); wc.lineTo(e.x+bw,bot); wc.closePath(); wc.fill(); wc.stroke();
      wc.strokeStyle='rgba(255,255,255,.55)'; wc.lineWidth=1;
      wc.beginPath(); wc.moveTo(e.x-bw*0.55,top+6); wc.lineTo(e.x-bw*0.2,bot-6); wc.stroke();
      gfxEmit(e.x,e.y-H*0.5,r*2.2,ELEM.cryo.c,0.5);
      n++;
    } else if(e.chillT>0){
      wc.globalCompositeOperation='source-over'; wc.globalAlpha=0.6; wc.strokeStyle=ELEM.cryo.c; wc.lineWidth=2;
      wc.beginPath(); wc.ellipse(e.x,e.y-H*0.45,r+3,H*0.55+3,0,0,6.2832); wc.stroke();
      wc.fillStyle='#ffffff'; wc.globalAlpha=0.85;
      for(k=0;k<5;k++){ ph=k*1.257+t*0.6; wc.fillRect(e.x+Math.cos(ph)*(r+1)-1,e.y-H*0.45+Math.sin(ph*1.3)*H*0.45-1,2,2); }
      n++;
    }
    if(e.corrT>0){
      wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.22; wc.fillStyle=ELEM.acid.c;
      wc.beginPath(); wc.ellipse(e.x,e.y-H*0.45,r+1,H*0.5,0,0,6.2832); wc.fill();
      wc.globalCompositeOperation='source-over';
      for(k=0;k<3;k++){
        ph=(t*1.4+k*0.37)%1;
        wc.globalAlpha=0.85*(1-ph); wc.fillStyle=ELEM.acid.c;
        wc.beginPath(); wc.ellipse(e.x+(k-1)*r*0.5,e.y-H*0.7+ph*(H*0.7+6),1.7,2.8,0,0,6.2832); wc.fill();
      }
      n++;
    }
    wc.restore();
  }
  return n;
}
function forgeGlow(x,y,face,w,down){
  var fk=(w&&(w.fk===1||w.fk===2))?w.fk:0, c, hx, hy, r, gr, a, s;
  if(!fk||down||!G||G.sim||!isFinite(x)||!isFinite(y)) return false;
  c=(fk===2&&w.el&&ELEM[w.el])?ELEM[w.el].c:FORGE_GOLD;
  face=isFinite(face)?face:0; s=Math.sin((G.t||0)*9.42);
  hx=x+Math.cos(face)*12; hy=y-10+Math.sin(face)*4;
  a=0.6+0.25*s; r=11+2*s;
  wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=a;
  gr=wc.createRadialGradient(hx,hy,0,hx,hy,r); gr.addColorStop(0,c); gr.addColorStop(1,'rgba(0,0,0,0)');
  wc.fillStyle=gr; wc.beginPath(); wc.arc(hx,hy,r,0,6.2832); wc.fill();
  wc.restore();
  gfxEmit(hx,hy,r*1.8,c,0.5*a);
  return true;
}
'@

SubRx @'
  } else if(type==='pickGun'){
'@ @'
  } else if(type==='elFire'){
    // v23.xx (forge8): a short whoosh with a crackle in it
    var efl=Math.floor(a.sampleRate*0.24), efb=a.createBuffer(1,efl,a.sampleRate), efc=efb.getChannelData(0);
    for(var efi=0;efi<efl;efi++) efc[efi]=(Math.random()*2-1)*Math.pow(1-efi/efl,1.5)*((Math.random()<0.03)?2.4:1);
    var efs=a.createBufferSource(); efs.buffer=efb;
    var eff=a.createBiquadFilter(); eff.type='lowpass'; eff.frequency.setValueAtTime(700,t); eff.frequency.exponentialRampToValueAtTime(2800,t+.2);
    var efg=a.createGain(); efg.gain.value=.15*vol;
    efs.connect(eff); eff.connect(efg); efg.connect(OUT); efs.start(t);
  } else if(type==='elShock'){
    // v23.xx (forge8): a sawtooth sweep from 1.2 kHz down to 200 Hz
    var eso=a.createOscillator(), esg=a.createGain(); eso.type='sawtooth';
    eso.frequency.setValueAtTime(1200,t); eso.frequency.exponentialRampToValueAtTime(200,t+.12);
    esg.gain.setValueAtTime(.06*vol,t); esg.gain.exponentialRampToValueAtTime(.001,t+.13);
    eso.connect(esg); esg.connect(OUT); eso.start(t); eso.stop(t+.14);
  } else if(type==='elCryo'){
    // v23.xx (forge8): two glassy sines
    [2200,3300].forEach(function(F,ix){
      var eco=a.createOscillator(), ecg=a.createGain(), t0=t+ix*0.03; eco.type='sine'; eco.frequency.setValueAtTime(F,t0);
      ecg.gain.setValueAtTime(.04*vol,t0); ecg.gain.exponentialRampToValueAtTime(.001,t0+.22);
      eco.connect(ecg); ecg.connect(OUT); eco.start(t0); eco.stop(t0+.24);
    });
  } else if(type==='elFreeze'){
    // v23.xx (forge8): the crack of a freeze, a bright snap over a low knock
    var ezl=Math.floor(a.sampleRate*0.09), ezb=a.createBuffer(1,ezl,a.sampleRate), ezc=ezb.getChannelData(0);
    for(var ezi=0;ezi<ezl;ezi++) ezc[ezi]=(Math.random()*2-1)*Math.pow(1-ezi/ezl,3);
    var ezs=a.createBufferSource(); ezs.buffer=ezb;
    var ezf=a.createBiquadFilter(); ezf.type='highpass'; ezf.frequency.value=2500;
    var ezg=a.createGain(); ezg.gain.value=.16*vol;
    ezs.connect(ezf); ezf.connect(ezg); ezg.connect(OUT); ezs.start(t);
    var ezo=a.createOscillator(), ezog=a.createGain(); ezo.type='sine';
    ezo.frequency.setValueAtTime(140,t); ezo.frequency.exponentialRampToValueAtTime(60,t+.12);
    ezog.gain.setValueAtTime(.10*vol,t); ezog.gain.exponentialRampToValueAtTime(.001,t+.14);
    ezo.connect(ezog); ezog.connect(OUT); ezo.start(t); ezo.stop(t+.15);
  } else if(type==='elAcid'){
    // v23.xx (forge8): a hiss, band passed at 3 kHz
    var eal=Math.floor(a.sampleRate*0.25), eab=a.createBuffer(1,eal,a.sampleRate), eac=eab.getChannelData(0);
    for(var eai=0;eai<eal;eai++) eac[eai]=(Math.random()*2-1)*Math.pow(1-eai/eal,1.2);
    var eas=a.createBufferSource(); eas.buffer=eab;
    var eaf=a.createBiquadFilter(); eaf.type='bandpass'; eaf.frequency.value=3000; eaf.Q.value=1.5;
    var eag=a.createGain(); eag.gain.value=.10*vol;
    eas.connect(eaf); eaf.connect(eag); eag.connect(OUT); eas.start(t);
  } else if(type==='pickGun'){
'@

SubRx @'
  if(G.arcade&&p.arcSh) msg.sh=1;   // v23.30 (arcade9): only while shielded
'@ @'
  if(G.arcade&&p.arcSh) msg.sh=1;   // v23.30 (arcade9): only while shielded
  if(p.wep&&(p.wep.fk===1||p.wep.fk===2)){ msg.fk=p.wep.fk; if(p.wep.fk===2&&p.wep.el&&ELEM[p.wep.el]) msg.el=p.wep.el; }   // v23.xx (forge8): the forged gun in hand, for his glow
'@

SubRx @'
  if(up&&(m.sh||g.sh)) g.sh=m.sh?1:0;   // v23.30 (arcade9): the teammate spawn shield
'@ @'
  if(up&&(m.sh||g.sh)) g.sh=m.sh?1:0;   // v23.30 (arcade9): the teammate spawn shield
  if(up){ g.fk=(m.fk===1||m.fk===2)?m.fk:0; g.el=(g.fk===2&&typeof m.el==='string'&&ELEM[m.el])?m.el:''; }   // v23.xx (forge8): his forged gun
'@

SubRx @'
    if(lk) out.lk=lk;
'@ @'
    if(lk) out.lk=lk;
    if(up&&g.fk){ out.fk=g.fk; if(g.el) out.el=g.el; }   // v23.xx (forge8)
'@

SubRx @'
         rl:(p.reloading>0&&p.wep.reload)?clamp(1-p.reloading/p.wep.reload,0,1):0});
      if(pWet){
'@ @'
         rl:(p.reloading>0&&p.wep.reload)?clamp(1-p.reloading/p.wep.reload,0,1):0});
      try{ forgeGlow(p.x,p.y,p.face,p.wep,p.downed||p.hp<=0); }catch(_fg){}   // v23.xx (forge8): a forged gun glows at the hands
      if(pWet){
'@

SubRx @'
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);   // v23.30 (arcade9)
'@ @'
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);   // v23.30 (arcade9)
    if(g.fk) forgeGlow(g.x,g.y,g.f,{fk:g.fk,el:g.el},g.dn);   // v23.xx (forge8): his forged gun glows too
'@

SubRx @'
var VER='25.48';
'@ @'
var VER='25.49';
'@

$pat = "(?m)^  now:'v25\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.49: Elemental hits now show flames, arcs, frost, ice and acid, and a forged gun glows. Check 25.49 fails on v25.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
