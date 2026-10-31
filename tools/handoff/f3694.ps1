$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'36.94',what:")) { throw "check 36.94 is in the fixture already" }

SubRx @'
  {v:'36.93',what:
'@ @'
  {v:'36.94',what:'ALARMS VOLUME (his 10-25 g-81): a row in AUDIO that scales the alarms, warnings and the raid clock (OFF silences them, guns and steps stay), the clock leaves UI VOLUME; and a light lowmag tick under the shot on the last quarter of a magazine (g-82)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows&&window.__sim&&window.__blipCount)) return 'SKIP: this fixture cannot deploy, step or reach the Settings rows';
     if(typeof sndBus!=='function'||typeof _realBlip!=='function'||typeof alertSting!=='function'||typeof sndMateAlert!=='function'||typeof annCue!=='function'||typeof tickMachSiren!=='function'||typeof mkSentry!=='function') return 'SKIP: no sound or siren here';
     function Pp(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(k,ps){ var o={kind:k,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){}; o.stop=function(){}; (ps||[]).forEach(function(n){ o[n]=Pp(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     function peak(nodes){ var m=0, n; nodes.forEach(function(x){ if(x.kind==='gain'&&x.gain){ n=Math.max(+x.gain.value||0,+x.gain.last||0); if(n>m) m=n; } }); return m; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=null, kSay=say, kMS={}, kDuck=(typeof SND_DUCK!=='undefined')?SND_DUCK:null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     var bad=[], g=null, p=null, rows, rr, sn, jj, k, m0, d0, d1, ty, made, ok, S, kGO=P.gameOpts, kTU=P.tuned, kVU=CFG.volUi, kVA=CFG.volAlarm, kAB=ANNC.busy, kWep, i;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(kDuck) SND_DUCK={}; if(g) g.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(kDuck) SND_DUCK=kDuck; if(g&&kSim!==null) g.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function steps(n){ for(var s=0;s<n;s++) __sim(0.05); }
     function gun(am){ p.wep=Object.assign({},WEAPONS.rifle); p.drawRef=p.wep; p.ammo=am; p.reserve=60; p.reloading=0; p.drawT=0; p.hand=null; p.jam=0; p.fired=false; p.dryTold=0; p.lastShot=-1e9; p.trigYield=0; p.cooking=false; g.hot=0; keys={}; mouse.down=false; }
     function ring(type){ m0=MADE.length; _realBlip(type); return MADE.length-m0; }
     for(k in MSIREN) kMS[k]=MSIREN[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; kSim=g.sim; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the row, in AUDIO, five steps, defaulting to FULL; the clock leaves the UI VOLUME hint
       rows=__opts.rows()||[]; rr=rowOf('volAlarm');
       if(!rr) return 'Settings has no ALARMS VOLUME row (volAlarm)';
       if(rr.sec!=='AUDIO') bad.push('ONE: the row sits under '+rr.sec+', not AUDIO');
       if(!rr.opts||rr.opts.length!==5) bad.push('ONE: the row has '+(rr.opts&&rr.opts.length)+' steps, not 5');
       if(CFG.volAlarm!==1) bad.push('ONE: a fresh profile has volAlarm '+CFG.volAlarm+', not 1');
       if(gameOptLive('volAlarm')!==rr.def) bad.push('ONE: the volAlarm row reads CUSTOM on a fresh profile');
       if(rr.label!==String(rr.label).toUpperCase()) bad.push('ONE: the label is not caps');
       sn=[CFG.volAlarm]; for(jj=1;jj<5;jj++){ __opts.cycle('volAlarm'); sn.push(CFG.volAlarm); }
       if(sn.join(',')!=='1,0,0.25,0.5,0.75') bad.push('ONE: clicking the row steps it '+sn.join(' > '));
       if(typeof P.gameOpts.volAlarm!=='number') bad.push('ONE: the pick was not saved in the profile');
       P.gameOpts={}; P.tuned={}; __opts.apply();
       if(rowOf('volUi')&&/clock/i.test(rowOf('volUi').hint||'')) bad.push('ONE: the UI VOLUME hint still names the clock');
       if(SND_CAT.clockwarn!=='sting'||SND_CAT.clocktick!=='sting') bad.push('ONE: the clock sounds are on the '+SND_CAT.clockwarn+' bus, not sting');
       if(SND_CAT.lowmag!=='gun') bad.push('ONE: lowmag is on the '+SND_CAT.lowmag+' bus, not gun');
       if(typeof SND_ALARM!=='object') return bad.concat(['no SND_ALARM list']).join('; ');
       // TWO: the sounds through a stand-in audio context
       fakeOn(); sndBus('sting'); sndBus('mach'); sndBus('world'); sndBus('gun');
       CFG.volAlarm=1; made=0;
       Object.keys(SND_ALARM).forEach(function(t){ if(ring(t)>0) made++; });
       if(made<4) bad.push('TWO: control: only '+made+' of the alarm sounds make nodes at FULL');
       CFG.volAlarm=1; m0=MADE.length; _realBlip('clockwarn'); d1=peak(MADE.slice(m0));
       CFG.volAlarm=0.5; m0=MADE.length; _realBlip('clockwarn'); d0=peak(MADE.slice(m0));
       if(!(d1>0)||!(d0>d1*0.35&&d0<d1*0.65)) bad.push('TWO: ALARMS VOLUME 50% played the clock warning at '+(d1>0?(d0/d1).toFixed(2):'nothing')+' of full, not half');
       CFG.volAlarm=0;
       Object.keys(SND_ALARM).forEach(function(t){ if(ring(t)>0) bad.push('TWO: ALARMS VOLUME off still played '+t); });
       CFG.volAlarm=0; ANNC.busy=-1;
       if(alertSting('warn')!==false) bad.push('TWO: ALARMS VOLUME off still stung a warn');
       if(alertSting('crit')!==false) bad.push('TWO: ALARMS VOLUME off still stung a crit');
       if(sndMateAlert()!==false) bad.push('TWO: ALARMS VOLUME off still played the teammate down alert');
       if(annCue('TWOMIN')!==false) bad.push('TWO: ALARMS VOLUME off still played the two minute cue');
       if(annCue('ONEMIN')!==false) bad.push('TWO: ALARMS VOLUME off still played the one minute cue');
       if(ANNC.busy>0) bad.push('TWO: ALARMS VOLUME off marked the announcer busy');
       // the controls: other sounds are untouched at 0
       if(ring('clank')===0) bad.push('TWO: control: ALARMS VOLUME off silenced a clank');
       m0=MADE.length; _realBlip('shot'); if(MADE.length===m0) bad.push('TWO: control: ALARMS VOLUME off silenced a shot');
       if(alertSting('ext')!==true) bad.push('TWO: control: ALARMS VOLUME off silenced the extraction sting');
       CFG.volAlarm=1; ANNC.busy=-1;
       if(alertSting('warn')!==true) bad.push('TWO: control: a warn sting made no sound at FULL');
       if(annCue('TWOMIN')!==true) bad.push('TWO: control: the two minute cue made no sound at FULL');
       // the clock follows ALARMS VOLUME, not UI VOLUME
       CFG.volUi=0; CFG.volAlarm=1; if(ring('clockwarn')===0) bad.push('TWO: UI VOLUME off silenced the clock warning');
       CFG.volUi=kVU;
       // THREE: the lock-on siren follows the row
       CFG.volAlarm=1; g.paused=false; say=function(){}; MSIREN.v=null; MSIREN.on=0; MSIREN.n=0; MSIREN.lvl=0;
       S=mkSentry(p.x+300,p.y); S.state='chase'; S.alert=2.4; S.hp=Math.max(S.hp,10); delete S.sirenSeeT; g.ents=[S];
       for(i=0;i<40;i++){ g.t+=0.05; S.sirenSeeT=g.t; tickMachSiren(0.05); }
       if(!MSIREN.on||!(MSIREN.lvl>0)) bad.push('THREE: control: a sentry holding the lock did not start the siren at FULL ('+MSIREN.on+', '+MSIREN.lvl+')');
       CFG.volAlarm=0;
       for(i=0;i<4;i++){ g.t+=0.05; S.sirenSeeT=g.t; tickMachSiren(0.05); }
       if(!MSIREN.on||MSIREN.lvl!==0) bad.push('THREE: ALARMS VOLUME off left the siren level at '+MSIREN.lvl+' (on '+MSIREN.on+')');
       g.ents.length=0; say=kSay; CFG.volAlarm=1;
       fakeOff();
       // FOUR: the low magazine tick (the Auto Rifle holds 25: the last 6)
       ANNC.busy=kAB;
       kWep=p.wep;
       gun(4); mouse.down=true; __blipCount(true); steps(1); mouse.down=false;
       if((__blipCount()['lowmag']||0)!==1) bad.push('FOUR: the Auto Rifle on its last rounds made '+(__blipCount()['lowmag']||0)+' lowmag ticks, not 1 ('+JSON.stringify(__blipCount())+')');
       gun(20); mouse.down=true; __blipCount(true); steps(1); mouse.down=false;
       if((__blipCount()['lowmag']||0)!==0) bad.push('FOUR: a nearly full magazine ticked');
       gun(7); mouse.down=true; __blipCount(true); steps(1); mouse.down=false;
       if((__blipCount()['lowmag']||0)!==1) bad.push('FOUR: 6 rounds left after the shot (the ring red step) did not tick once');
       gun(8); mouse.down=true; __blipCount(true); steps(1); mouse.down=false;
       if((__blipCount()['lowmag']||0)!==0) bad.push('FOUR: 7 rounds left after the shot ticked, the ring is not red yet');
       gun(1); mouse.down=true; __blipCount(true); steps(1); mouse.down=false;
       if((__blipCount()['lowmag']||0)!==0) bad.push('FOUR: the very last round ticked, the empty gun clicks dry instead');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fakeOff(); }catch(_f){}
       try{ say=kSay; CFG.volUi=kVU; CFG.volAlarm=kVA; ANNC.busy=kAB; for(k in kMS) MSIREN[k]=kMS[k]; }catch(_c){}
       try{ mouse.down=false; keys={}; }catch(_m){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'36.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
