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

# GOOD RELOAD NOISES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v13.83, combat audit: the player's reload clock, in one place so the roll branch runs it too.
function tickReload(dt){
  var p=G.player;
  if(p.reloading>0){
    p.reloading-=dt*1000;
'@ @'
// v25.52, HIS ORDER 2026-10-12 (about 21:10): "add good reload noises". A RELOAD YOU CAN HEAR, STEP BY STEP. Every gun played the
// same v10.56 noise click and thock in the first quarter second of a reload that runs 1.3 to 4.0 seconds, then nothing until a
// second click when the rounds went in: the Support MG was silent for three seconds, and a shotgun loaded like a magazine. Now each
// gun class plays the recorded foley of the v25.52 bank, timed against its OWN reload clock: the magazine out the moment it starts,
// the new one seating three quarters of the way through, and the charging handle, slide or bolt on the frame the rounds go in, ONLY
// when the gun was empty (a reload with a round still chambered skips the rack, as in CoD). A shotgun pushes one shell for every
// shell it takes and racks the pump when it was empty; the Longshot opens and closes its bolt; the Magnum swings its cylinder out,
// drops the brass, takes a speedloader and shuts; the Support MG opens the cover, swaps the box, lays the belt and slams the cover;
// the Meridian Lance vents its cell, seats a new one, whines up and pings ready. The steps are fractions of the reload this gun
// started with (perk, buzz and the Forge MK II included), played from tickReload as the clock crosses them, never booked ahead on
// the audio clock: a reload cut short by a swap, a draw or going down plays nothing more (and the Lance whine is cut). The party
// hears yours where you stand (foley). Cosmetic only: no seeded draw, nothing under G.sim, no game state (RLFX is sound bookkeeping).
var RLFX={on:false,p:null,w:null,tot:0,st:[],i:0,dry:false,hum:null};
// the steps of one reload: f the fraction of the reload clock (1 = the frame the rounds go in), r the bank clip (~ a synth), o options
function reloadPlan(w,dry,n){
  var id=(w&&w.id)||'', S=[], k;
  function a(f,r,o){ S.push({f:f,r:r,o:o||{}}); }
  if(id==='shotgun'||id==='scuttle'){
    a(0,'boltLatch',{rate:1.35,g:0.55});   // the loading gate
    for(k=0;k<n;k++) a(n>1?0.1+0.75*k/(n-1):0.45,'shellIn');   // one shell for every shell taken, 10 to 85 percent
    if(dry) a(1,'pump');
  } else if(id==='magnum'){
    a(0,'boltLatch',{rate:1.15});   // the cylinder swings out
    a(0.22,'magOut',{rate:0.8});   // the ejector and the brass
    a(0.72,'pistolSeat',{rate:0.9});   // the speedloader
    a(1,'boltLatch',{rate:0.9});   // the cylinder shuts
  } else if(id==='sniper'){
    a(0,'boltLatch',{rate:0.85});   // bolt up and back
    a(0.18,'rifleMagOut');
    a(0.75,'magIn',{rate:0.9});
    a(1,'boltLatch',{rate:0.8}); a(1,'boltLatch',{rate:1.05});   // bolt forward, then down
  } else if(id==='lance'){
    a(0,'injector',{rate:0.75}); a(0,'boltLatch',{rate:1.25,g:0.7});   // the spent cell vents and drops
    a(0.62,'lmgClack',{rate:1.25});   // a new cell seats
    a(0.66,'~whine');   // and charges
    a(1,'~ping'); a(1,'boltLatch',{rate:1.4,g:0.6});
  } else if(id==='lmg'){
    a(0,'boltLatch',{rate:0.9});   // the top cover opens
    a(0.22,'lmgClack',{rate:1.1});   // the box comes off
    a(0.48,'lmgClack',{rate:0.9});   // the new box goes on
    a(0.66,'magIn',{rate:0.8});   // the belt is laid
    a(0.84,'boltLatch',{rate:0.75});   // the cover slams
    if(dry) a(1,'rifleCharge',{rate:0.85});
  } else if(id==='rifle'||id==='chatter'||id==='carbine'||id==='dmr'){
    a(0,'rifleMagOut',{rate:id==='dmr'?0.92:1});
    a(0.75,'magIn',{rate:id==='dmr'?0.85:0.92});
    if(dry) a(1,'rifleCharge',{rate:id==='dmr'?0.82:1});
  } else if(id==='smg'||id==='sputter'||id==='whisper'){
    a(0,'magOut',{rate:1.08});
    a(0.75,'magIn',{rate:1.08});
    if(dry) a(1,'rifleCharge',{rate:1.18});
  } else {   // the Scav Pistol, the Tacker and any gun added later
    a(0,'magOut');
    a(0.75,'pistolSeat');
    if(dry) a(1,'slideRack');
  }
  return S;
}
// a reload starts: called where p.reloading is set, with the gun still empty or not
function reloadFoley(p){
  if(!p||!p.wep||(G&&G.sim)||!(p.reloading>0)) return;
  rlfxStop();
  RLFX.on=true; RLFX.p=p; RLFX.w=p.wep; RLFX.tot=p.reloading; RLFX.dry=!(p.ammo>0); RLFX.i=0;
  RLFX.st=reloadPlan(p.wep,RLFX.dry,Math.max(0,Math.min((p.wep.mag||0)-(p.ammo||0),p.reserve||0)));
  rlfxPlay(0);
}
// every step up to fraction f that has not played; a frame that owes two spaces them 70 ms apart
function rlfxPlay(f){
  var k=0, s, o, q;
  while(RLFX.i<RLFX.st.length&&RLFX.st[RLFX.i].f<=f){
    s=RLFX.st[RLFX.i++]; o={gap:0};
    for(q in s.o) o[q]=s.o[q];
    if(k>0) o.at=0.07*k;
    if(RLFX.w&&RLFX.w.id==='whisper') o.g=(o.g===undefined?1:o.g)*0.7;   // the quiet gun reloads quietly
    k++;
    if(s.r==='~whine') rlfxWhine(Math.max(0.1,RLFX.tot*(1-s.f)/1000));
    else if(s.r==='~ping') rlfxPing(o.at||0);
    else if(typeof foley==='function') foley(s.r,undefined,undefined,o);
  }
}
// the Lance charging: a filtered saw rising to the end of the reload, cut by rlfxStop
function rlfxWhine(sec){
  var a, out, t, o, f, g;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  a=ac(); if(!a) return; out=sndBus('gun'); if(!out) return;
  try{
    t=a.currentTime; o=a.createOscillator(); f=a.createBiquadFilter(); g=a.createGain();
    o.type='sawtooth'; o.frequency.setValueAtTime(180,t); o.frequency.exponentialRampToValueAtTime(1150,t+sec);
    f.type='lowpass'; f.frequency.value=1700; f.Q.value=1.2;
    g.gain.setValueAtTime(0.0001,t); g.gain.linearRampToValueAtTime(0.035,t+Math.min(0.2,sec*0.5)); g.gain.linearRampToValueAtTime(0.06,t+sec);
    g.gain.linearRampToValueAtTime(0.0001,t+sec+0.04);
    o.connect(f); f.connect(g); g.connect(out); o.start(t); o.stop(t+sec+0.06);
    RLFX.hum={o:o,g:g};
  }catch(e){}
}
function rlfxPing(at){
  var a, out, t, o, g;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  a=ac(); if(!a) return; out=sndBus('gun'); if(!out) return;
  try{
    t=a.currentTime+(at||0); o=a.createOscillator(); g=a.createGain();
    o.type='sine'; o.frequency.setValueAtTime(1760,t);
    g.gain.setValueAtTime(0.0001,t); g.gain.linearRampToValueAtTime(0.09,t+0.005); g.gain.exponentialRampToValueAtTime(0.001,t+0.22);
    o.connect(g); g.connect(out); o.start(t); o.stop(t+0.24);
  }catch(e){}
}
// the reload is over (done or cut short): nothing more plays, and a whine still rising is cut
function rlfxStop(){
  var h=RLFX.hum, a, t;
  RLFX.on=false; RLFX.hum=null;
  if(!h) return;
  try{ a=ac(); t=a?a.currentTime:0; h.g.gain.cancelScheduledValues(t); h.g.gain.setValueAtTime(h.g.gain.value,t); h.g.gain.linearRampToValueAtTime(0.0001,t+0.04); h.o.stop(t+0.06); }catch(e){}
}
// v13.83, combat audit: the player's reload clock, in one place so the roll branch runs it too.
function tickReload(dt){
  var p=G.player, fx=!G.sim&&RLFX.on&&RLFX.p===p&&RLFX.w===p.wep&&RLFX.tot>0;   // v25.52 (his reload order): this reload has its steps
  if(p.reloading>0){
    p.reloading-=dt*1000;
    if(fx&&p.reloading>0) rlfxPlay(1-p.reloading/RLFX.tot);   // v25.52: the steps the clock crossed this frame
'@

SubRx @'
      if(!G.sim) blipMine('reloadin');   // v10.56: the bolt goes home
    }
  }
}
'@ @'
      if(!G.sim){ if(fx) rlfxPlay(1); else blipMine('reloadin'); }   // v10.56: the bolt goes home; v25.52: the last step of the gun (the rack only when it was empty)
      if(fx) rlfxStop();
    }
  } else if(RLFX.on&&RLFX.p===p) rlfxStop();   // v25.52: cut short (a swap, a draw, going down): nothing more plays
}
'@

SubRx @'
  if(keys['KeyR']&&p.reloading<=0&&p.ammo<p.wep.mag&&p.reserve>0){ p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blipMine('reload'); }   // v10.56
'@ @'
  if(keys['KeyR']&&p.reloading<=0&&p.ammo<p.wep.mag&&p.reserve>0){ p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) reloadFoley(p); }   // v10.56; v25.52 (his reload order): the magazine out, then the steps
'@

SubRx @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blipMine('reload');
'@ @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) reloadFoley(p);   // v25.52 (his reload order)
'@

SubRx @'
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim) blipMine('reload');
'@ @'
          p.reloading=p.wep.reload; T.reloads++;
          if(!G.sim) reloadFoley(p);   // v25.52 (his reload order)
'@

SubRx @'
var VER='25.51';
'@ @'
var VER='25.52';
'@

$pat = "(?m)^  now:'v25\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.52: Each gun class now reloads in recorded steps timed to its own reload (magazine out, magazine in, and the rack only when empty), shells one by one, bolt, cylinder, belt and cell, and a cut reload stops. Check 25.52 fails on v25.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
