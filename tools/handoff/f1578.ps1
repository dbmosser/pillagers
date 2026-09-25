$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
if ($s.Contains("  {v:'15.78',what:")) { throw "check 15.78 is in the fixture already" }
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # the checks round this anchor are LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# Check 15.78. Synchronous, as the fixture runner (__regress and __regressBg) does not await a promise a check returns, and it
# never opens a window, makes a channel, makes a connection or makes a sound: the fixture blocks the audio context, so a
# recording stand-in is put in AC for the length of the check (as checks 10.58 and 9.68 do) and the real bus(), verb(),
# tickMusic() and the real blip (_realBlip, under the fixture stub) build their nodes on it; the channel between windows is a
# stand-in that records what is posted, and the words are fed to the real netSameOnMsg. Everything is put back in finally.
# The live half between two real windows is the sound step of RUN SAME MACHINE in tools/nettest.html.
SubRx @'
  {v:'15.77',what:
'@ @'
  {v:'15.78',what:'in a same machine mode world sound comes from one window only: one master gain sits between everything the game plays (BUS with the room reverb fed from it, the reverb return, the music) and the speakers; the host defaults to SOUND ON with the gain at 1, the player 2 window to SOUND OFF with the gain at 0 while every schedule keeps running (a blip and the music still start their voices behind the gain and the context is never suspended); the SOUND row in the PARTY window shows only in a same machine mode, reads the switch, a press flips it at once, keeps it under its own key and tells the other window, the other window word updates the note and a word from another pair is ignored; the nodes a host made on the title before the pick move behind the gain at the pick, still feeding the room reverb; the real same machine pick (window, code maker and channel stood in) and the real player 2 boot read the kept switch and tell the other window, a ready is answered with it, ready still the last word of the boot; END THE PARTY puts the gain back to 1; outside a same machine mode the world connects straight to the destination with no gain added, one node fewer than inside, and nothing suspended; the seeded stream never moves (multiplayer build 5)',
   run:function(){
     // THE MUTE IS THERE. Without it both windows on one PC play every sound and everything is heard twice, so the old build fails here rather than skips.
     if(typeof NET==='undefined'||!NET||typeof netSndOut!=='function'||typeof netSndInit!=='function'||typeof netSndSet!=='function'||typeof netSndToggle!=='function'||
        typeof netSndRoute!=='function'||typeof netSndRelease!=='function'||typeof netSndView!=='function'||typeof netSameOnMsg!=='function'||
        !document.getElementById('partysnd')||!document.getElementById('partysndbtn')||!document.getElementById('partysndnote')||typeof NET.sndOn!=='boolean')
       return 'this build has no master gain and no SOUND row in the PARTY window (no netSndOut, netSndInit or netSndSet), so two windows on one PC both play every sound and everything is heard twice';
     if(typeof bus!=='function'||typeof verb!=='function'||typeof tickMusic!=='function'||typeof musicWanted!=='function'||typeof renderParty!=='function'||typeof netReset!=='function'||
        typeof netSamePick!=='function'||typeof netSameBootP2!=='function'||typeof netHost!=='function'||typeof netSupported!=='function'||typeof _realBlip!=='function'||
        typeof MUS==='undefined'||!MUS||typeof AC==='undefined'||typeof BUS==='undefined'||typeof REV==='undefined') return 'this build has no sound chain under the mute';
     if(NET.same||NET.on) return 'SKIP: a party is on in this copy, and the check stands in for both windows';
     var bad=[], rng0=null, i;
     var _s2=say2, keepAC=AC, keepBUS=BUS, keepREV=REV, keepPAN=PAN_OK, keepMus={}, keepSim=(G?G.sim:null), keepNet=null, oMW=musicWanted;
     var KH='salvagerun:samesound:host', KP='salvagerun:samesound:p2', lsWas=null, PAIR='zqxsndpair1';
     var oOpen=window.open, hadBC=('BroadcastChannel' in window), oBC=window.BroadcastChannel, oH=netHost, oStart=NET.start, spied=false, chans=[];
     // A stand-in channel class for the real pick and the real player 2 boot: records what is posted. Never a real channel.
     function BC(name){ this.name=String(name); this.posted=[]; this.onmessage=null; this.closed=false; chans.push(this); }
     BC.prototype.postMessage=function(m){ this.posted.push(m); };
     BC.prototype.close=function(){ this.closed=true; };
     function lastOf(list,t){ var q, o=null; for(q=0;q<list.length;q++) if(list[q]&&list[q].t===t) o=list[q]; return o; }
     function spy(){ spied=true; window.open=function(){ return {closed:false}; }; window.BroadcastChannel=BC; netHost=function(){ return {then:function(){}}; }; NET.start=function(){}; }
     function unspy(){ if(!spied) return; spied=false; window.open=oOpen; if(hadBC) window.BroadcastChannel=oBC; else { try{ delete window.BroadcastChannel; }catch(_db){ window.BroadcastChannel=undefined; } } netHost=oH; NET.start=oStart; }
     var g=function(id){ return document.getElementById(id); };
     function ls(k){ try{ return localStorage.getItem(k); }catch(e){ return null; } }
     function txt(el){ return String((el&&el.textContent)||'').replace(/\s+/g,' ').replace(/^ | $/g,''); }
     function shown(el){ return !!el&&el.style.display!=='none'; }
     function js(o){ return JSON.stringify(o); }
     function closeAll(){ [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); }); }
     // A recording stand-in for the audio context: every node keeps the list of what it connects to (one entry per target,
     // as the browser keeps one connection per pair), disconnect(x) throws when x is not there (as the browser does), and
     // every start is written down, so a voice scheduled behind the gain can be counted.
     function fake(){
       var L=[], made={gain:0,osc:0}, a;
       function param(v){ var o={value:v}; ['setValueAtTime','exponentialRampToValueAtTime','linearRampToValueAtTime','setTargetAtTime','cancelScheduledValues'].forEach(function(m){ o[m]=function(){ return o; }; }); return o; }
       function node(kind){
         var o={kind:kind,out:[]};
         o.connect=function(x){ if(x&&o.out.indexOf(x)<0) o.out.push(x); return x; };
         o.disconnect=function(x){ var q; if(x===undefined){ o.out=[]; return; } q=o.out.indexOf(x); if(q<0) throw new Error('InvalidAccessError: not connected'); o.out.splice(q,1); };
         o.start=function(t){ L.push({kind:kind,at:t}); }; o.stop=function(){};
         return o;
       }
       a={currentTime:5,sampleRate:48000,state:'running',destination:node('dest'),log:L,made:made,susp:0,res:0,
         suspend:function(){ a.susp++; a.state='suspended'; },resume:function(){ a.res++; a.state='running'; },
         createGain:function(){ var o=node('gain'); o.gain=param(1); made.gain++; return o; },
         createOscillator:function(){ var o=node('osc'); o.type='sine'; o.frequency=param(440); o.detune=param(0); made.osc++; return o; },
         createBiquadFilter:function(){ var o=node('flt'); o.type='lowpass'; o.frequency=param(350); o.Q=param(1); return o; },
         createStereoPanner:function(){ var o=node('pan'); o.pan=param(0); return o; },
         createDelay:function(){ var o=node('dly'); o.delayTime=param(0); return o; },
         createBuffer:function(ch,len){ return {length:len,getChannelData:function(){ return new Float32Array(len); }}; },
         createBufferSource:function(){ var o=node('src'); o.buffer=null; o.loop=false; o.playbackRate=param(1); return o; },
         createConvolver:function(){ var o=node('conv'); o.buffer=null; o.normalize=true; return o; },
         createDynamicsCompressor:function(){ var o=node('comp'); o.threshold=param(-24); o.knee=param(30); o.ratio=param(12); o.attack=param(0.003); o.release=param(0.25); return o; },
         createWaveShaper:function(){ var o=node('ws'); o.curve=null; o.oversample=''; return o; }};
       return a;
     }
     function has(list,x){ return !!list&&list.indexOf(x)>=0; }
     function started(a){ var c=0, q; for(q=0;q<a.log.length;q++) if(a.log[q].kind==='osc'||a.log[q].kind==='src') c++; return c; }
     // A fresh window: no node made yet.
     function fresh(){ BUS=null; REV=null; PAN_OK=true; MUS.g=null; MUS.lp=null; MUS.next=0; MUS.step=0; MUS.trk=null; NET.sndG=null; NET.sndAc=null; }
     // The stand-in channel between windows: records what is posted. Never a real channel.
     var ch={posted:[],closed:false,onmessage:null,postMessage:function(m){ this.posted.push(m); },close:function(){ this.closed=true; }};
     function posts(t){ var o=[], q; for(q=0;q<ch.posted.length;q++) if(ch.posted[q]&&ch.posted[q].t===t) o.push(ch.posted[q]); return o; }
     function last(t){ var o=posts(t); return o.length?o[o.length-1]:null; }
     var fk=fake(), km;
     try{
       __topClear();
       closeAll();
       netReset();
       say2=function(){};
       for(km in MUS) if(Object.prototype.hasOwnProperty.call(MUS,km)) keepMus[km]=MUS[km];
       keepNet={sndOn:NET.sndOn,sndOther:NET.sndOther,sndG:NET.sndG,sndAc:NET.sndAc};
       lsWas={h:ls(KH),p:ls(KP)};
       try{ localStorage.removeItem(KH); localStorage.removeItem(KP); }catch(_lk0){}
       rng0=RNGS;
       AC=fk; fresh();
       if(G) G.sim=false;   // the real blip returns before making a node in a sim
       musicWanted=function(){ return true; };   // the music scheduler runs whatever the copy is showing

       // ONE: CONTROL, no same machine mode. The world connects straight to the destination, no master gain is made and
       // the row is hidden. The gain nodes bus() makes here (the bus and the room reverb) are the measure the same machine
       // arm below is held to, plus one; the music is left out of the count, since every note makes a gain of its own.
       NET.same=''; renderParty();
       if(shown(g('partysnd'))) bad.push('the SOUND row shows outside a same machine mode');
       var gA0=fk.made.gain, b0=bus(), gains0=fk.made.gain-gA0;
       if(!b0||!REV) bad.push('control: bus() made no bus and reverb on the stand-in context');
       else {
         if(!has(b0.out,fk.destination)) bad.push('control: outside a same machine mode BUS does not connect straight to the destination');
         if(!has(REV.wet.out,fk.destination)) bad.push('control: outside a same machine mode the reverb return does not connect straight to the destination');
         if(NET.sndG) bad.push('control: outside a same machine mode a master gain was made');
       }
       tickMusic();
       if(!MUS.lp||!has(MUS.lp.out,fk.destination)) bad.push('control: outside a same machine mode the music does not connect straight to the destination');
       fk.log.length=0; _realBlip('pick');
       if(!started(fk)) bad.push('control: a blip on the stand-in context started no voice, so nothing below can be measured');
       if(fk.susp) bad.push('control: the context was suspended '+fk.susp+' times outside a same machine mode');

       // TWO: THE HOST at the pick, its title nodes already on the destination. The default is on: the master gain is made
       // at 1, the three nodes move behind it (BUS still feeding the room reverb), and the other window is told.
       NET.same='host'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; ch.posted=[];
       var i1=netSndInit();
       if(i1!==true||NET.sndOn!==true) bad.push('the host does not default to SOUND ON (init '+i1+', on '+NET.sndOn+')');
       var gH=NET.sndG;
       if(!gH) bad.push('the host made no master gain at the pick');
       else {
         if(gH.gain.value!==1) bad.push('the host master gain is '+gH.gain.value+' at the pick, not 1');
         if(!has(gH.out,fk.destination)) bad.push('the master gain does not connect to the destination');
         if(!has(BUS.out,gH)||has(BUS.out,fk.destination)) bad.push('at the pick BUS did not move behind the master gain (to the gain '+has(BUS.out,gH)+', still to the destination '+has(BUS.out,fk.destination)+')');
         if(!has(REV.wet.out,gH)||has(REV.wet.out,fk.destination)) bad.push('at the pick the reverb return did not move behind the master gain');
         if(!has(MUS.lp.out,gH)||has(MUS.lp.out,fk.destination)) bad.push('at the pick the music did not move behind the master gain');
         if(!has(BUS.out,REV.send)) bad.push('moving BUS behind the master gain cut its feed to the room reverb');
         if(netSndRoute()!==0) bad.push('a second routing at the pick moved nodes again');
       }
       var w1=last('snd');
       if(!w1||w1.pair!==PAIR||w1.on!==1) bad.push('the host did not tell the player 2 window its sound is on ('+js(w1)+')');
       var v1=netSndView();
       if(!v1||v1.on!==true||v1.gain!==1||!v1.routed) bad.push('the test handle does not read the host as on with the gain at 1 ('+js(v1)+')');
       renderParty();
       if(!shown(g('partysnd'))) bad.push('the SOUND row is not shown in a same machine mode');
       if(txt(g('partysndbtn')).indexOf('SOUND ON')<0) bad.push('the host row does not read SOUND ON: '+txt(g('partysndbtn')));
       if(txt(g('partysndnote')).toLowerCase().indexOf('not said')<0) bad.push('the note does not say the other window has not said yet: '+txt(g('partysndnote')));
       // The other window word updates the note; another pair is ignored.
       if(netSameOnMsg({t:'snd',pair:PAIR,on:0})!=='snd'||NET.sndOther!==0) bad.push('the player 2 word was not read (other '+NET.sndOther+')');
       renderParty();
       if(txt(g('partysndnote')).toLowerCase().indexOf('sound off')<0) bad.push('the note does not say the other window has its sound off: '+txt(g('partysndnote')));
       netSameOnMsg({t:'snd',pair:PAIR,on:1}); renderParty();
       if(txt(g('partysndnote')).toLowerCase().indexOf('sound on')<0) bad.push('the note does not say the other window has its sound on: '+txt(g('partysndnote')));
       if(netSameOnMsg({t:'snd',pair:'zqxotherpair',on:0})!=='ignored'||NET.sndOther!==1) bad.push('a sound word from another pair code was taken (other '+NET.sndOther+')');
       // A press flips it at once, keeps it, tells the other window; the schedules keep running behind the gain.
       ch.posted=[]; fk.susp=0;
       var t1=netSndToggle(); renderParty();
       if(t1!==false||NET.sndOn!==false) bad.push('one press on the SOUND row did not switch the host off (on '+NET.sndOn+')');
       if(gH&&gH.gain.value!==0) bad.push('switched off, the master gain is '+gH.gain.value+', not 0');
       if(txt(g('partysndbtn')).indexOf('SOUND OFF')<0) bad.push('the row does not read SOUND OFF after one press: '+txt(g('partysndbtn')));
       if(ls(KH)!=='0') bad.push('the host switch is not kept under '+KH+' (it holds '+ls(KH)+')');
       var w2=last('snd');
       if(!w2||w2.pair!==PAIR||w2.on!==0) bad.push('the press was not told to the other window ('+js(w2)+')');
       fk.log.length=0;
       _realBlip('pick'); var sb1=started(fk);
       fk.log.length=0; MUS.next=0; tickMusic(); var sm1=started(fk);
       if(!sb1) bad.push('switched off, a blip started no voice: the sound was stopped instead of muted');
       if(!sm1) bad.push('switched off, the music scheduled no note: the scheduler was stopped instead of muted');
       if(fk.susp) bad.push('switched off, the context was suspended '+fk.susp+' times: the clock would stop and the music come back out of step');
       if(gH&&(!has(BUS.out,gH)||!MUS.lp||!has(MUS.lp.out,gH))) bad.push('switched off, the world no longer runs through the master gain');
       var v2=netSndView();
       if(!v2||v2.on!==false||v2.gain!==0) bad.push('the test handle does not read the host as off with the gain at 0 ('+js(v2)+')');
       var t2=netSndToggle();
       if(t2!==true||NET.sndOn!==true||(gH&&gH.gain.value!==1)||ls(KH)!=='1') bad.push('a second press did not switch the host back on at once (on '+NET.sndOn+', gain '+(gH?gH.gain.value:'none')+', kept '+ls(KH)+')');
       // A ready from player 2 is answered with the switch.
       ch.posted=[];
       spy();
       var rd1=netSameOnMsg({t:'ready',pair:PAIR});
       unspy();
       var w3=last('snd');
       if(!w3||w3.on!==1) bad.push('a ready from player 2 was not answered with the sound switch ('+rd1+', '+js(ch.posted)+')');
       // END THE PARTY puts the gain back to 1 and forgets the other window word.
       netSndSet(false);
       if(gH&&gH.gain.value!==0) bad.push('control: the host switched off before ending the party is not at 0');
       netReset();
       if(NET.same||(gH&&gH.gain.value!==1)||NET.sndOther!==-1) bad.push('ending the party did not put the master gain back to 1 (same '+NET.same+', gain '+(gH?gH.gain.value:'none')+', other '+NET.sndOther+')');

       // THREE: PLAYER 2, a fresh window with no node yet. The default is off; the first sound made builds the master gain at
       // 0 with every node behind it; a blip and the music still start their voices; a press switches it on at once.
       fresh();
       NET.same='p2'; NET.pair=PAIR; NET.mode='coop'; NET.bc=ch; ch.posted=[];
       var gB0=fk.made.gain; fk.susp=0;   // the master gain is made at the boot when a context is there, or at the first sound when not
       var i2=netSndInit();
       if(i2!==false||NET.sndOn!==false) bad.push('the player 2 window does not default to SOUND OFF (init '+i2+', on '+NET.sndOn+')');
       var w4=last('snd');
       if(!w4||w4.pair!==PAIR||w4.on!==0) bad.push('player 2 did not tell the host its sound is off ('+js(w4)+')');
       bus();
       var madeB=fk.made.gain-gB0;
       fk.log.length=0; MUS.next=0; tickMusic(); var sm2=started(fk);
       fk.log.length=0; _realBlip('pick'); var sb2=started(fk);
       var gP=NET.sndG;
       if(!gP) bad.push('player 2 made no master gain when its first sound was made');
       else {
         if(gP.gain.value!==0) bad.push('the player 2 master gain is '+gP.gain.value+', not 0');
         if(!has(gP.out,fk.destination)) bad.push('the player 2 master gain does not connect to the destination');
         if(!has(BUS.out,gP)||has(BUS.out,fk.destination)) bad.push('player 2 BUS does not run through the master gain');
         if(!has(REV.wet.out,gP)||has(REV.wet.out,fk.destination)) bad.push('the player 2 reverb return does not run through the master gain');
         if(!MUS.lp||!has(MUS.lp.out,gP)||has(MUS.lp.out,fk.destination)) bad.push('the player 2 music does not run through the master gain');
         if(madeB!==gains0+1) bad.push('bus() in a same machine mode made '+madeB+' gain nodes where the plain bus() made '+gains0+': not one master gain and nothing else');
       }
       if(!sb2) bad.push('player 2 switched off started no voice for a blip: the sound was stopped instead of muted');
       if(!sm2) bad.push('player 2 switched off scheduled no note of the music: the scheduler was stopped instead of muted');
       if(fk.susp) bad.push('player 2 switched off suspended the context '+fk.susp+' times');
       renderParty();
       if(txt(g('partysndbtn')).indexOf('SOUND OFF')<0) bad.push('the player 2 row does not read SOUND OFF: '+txt(g('partysndbtn')));
       var s3=netSndSet(true);
       if(s3!==true||(gP&&gP.gain.value!==1)||ls(KP)!=='1'||!last('snd')||last('snd').on!==1) bad.push('player 2 switched on is not at 1 at once, kept under '+KP+' and told (gain '+(gP?gP.gain.value:'none')+', kept '+ls(KP)+')');
       netSndSet(false);
       if(gP&&gP.gain.value!==0) bad.push('player 2 switched off again is not at 0');

       // FOUR: THE REAL PICK AND THE REAL BOOT (the window, the code maker and the channel stood in) read the kept switch,
       // apply it and tell the other window; ready stays the last word of the boot.
       NET.bc=null; NET.same=''; NET.pair=''; NET.mode='';
       netReset();
       spy();
       try{ localStorage.setItem(KH,'0'); localStorage.setItem(KP,'1'); }catch(_lk){}
       var k1=netSamePick('coop',function(){});
       if(k1!=='opened'||NET.same!=='host'||!NET.bc||chans.length!==1) bad.push('the stand-in same machine pick did not open ('+k1+', same '+NET.same+', channels '+chans.length+')');
       else {
         if(NET.sndOn!==false) bad.push('the host switch kept from last time (off) was not read at the pick (on '+NET.sndOn+')');
         if(!NET.sndG||NET.sndG.gain.value!==0) bad.push('the host that kept off is not muted at the pick (gain '+(NET.sndG?NET.sndG.gain.value:'none')+')');
         var p1=lastOf(chans[0].posted,'snd');
         if(!p1||p1.on!==0||p1.pair!==NET.pair) bad.push('the host switch was not told to the player 2 window at the pick ('+js(p1)+')');
       }
       netReset();
       if(NET.same||NET.bc||(NET.sndG&&NET.sndG.gain.value!==1)) bad.push('ending the party after the real pick did not let go of the channel and put the gain back (same '+NET.same+', gain '+(NET.sndG?NET.sndG.gain.value:'none')+')');
       chans=[];
       var b2=netSameBootP2(PAIR,'coop');
       if(b2!=='ready'||chans.length!==1) bad.push('the stand-in player 2 boot did not get ready ('+b2+', channels '+chans.length+')');
       else {
         if(NET.sndOn!==true) bad.push('the player 2 switch kept from last time (on) was not read at boot (on '+NET.sndOn+')');
         var p3=lastOf(chans[0].posted,'snd'), rd=chans[0].posted.length?chans[0].posted[chans[0].posted.length-1]:null;
         if(!p3||p3.on!==1||p3.pair!==PAIR) bad.push('the player 2 switch was not told to the host at boot ('+js(p3)+')');
         if(!rd||rd.t!=='ready') bad.push('ready is not the last word of the player 2 boot ('+js(rd)+')');
       }
       NET.bc=null; NET.same=''; NET.pair=''; NET.mode='';   // a player 2 boot keeps its channel across netReset; the stand-in is let go by hand
       netReset();
       unspy();

       // FIVE: CONTROL after the modes. With NET.same unset a new bus goes straight to the destination again, nothing was
       // suspended by this code, and the seeded stream never moved.
       fresh();
       bus();
       if(!BUS||!has(BUS.out,fk.destination)||NET.sndG) bad.push('control: after the party a new bus does not go straight to the destination');
       if(fk.susp) bad.push('control: the context was suspended '+fk.susp+' times by this code');
       if(RNGS!==rng0) bad.push('the seeded stream moved from '+rng0+' to '+RNGS+' through the sound switch');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; }catch(_n){}
       try{ netReset(); }catch(_nr){}
       try{ unspy(); }catch(_us){}
       try{ NET.pick=''; NET.p2url=''; }catch(_np){}
       try{ netModeMsg(''); }catch(_mm){}
       try{ if(keepNet){ NET.sndOn=keepNet.sndOn; NET.sndOther=keepNet.sndOther; NET.sndG=keepNet.sndG; NET.sndAc=keepNet.sndAc; } }catch(_kn){}
       try{ AC=keepAC; BUS=keepBUS; REV=keepREV; PAN_OK=keepPAN; }catch(_ka){}
       try{ for(var km2 in MUS) if(Object.prototype.hasOwnProperty.call(MUS,km2)&&!Object.prototype.hasOwnProperty.call(keepMus,km2)) delete MUS[km2]; for(km2 in keepMus) MUS[km2]=keepMus[km2]; }catch(_km){}
       try{ musicWanted=oMW; }catch(_mw){}
       try{ if(G&&keepSim!==null) G.sim=keepSim; }catch(_gs){}
       try{ if(lsWas){ if(lsWas.h===null) localStorage.removeItem(KH); else localStorage.setItem(KH,lsWas.h); if(lsWas.p===null) localStorage.removeItem(KP); else localStorage.setItem(KP,lsWas.p); } }catch(_l){}
       try{ renderParty(); }catch(_rp){}
       try{ closeAll(); }catch(_ca){}
       try{ say2=_s2; }catch(_s2e){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
