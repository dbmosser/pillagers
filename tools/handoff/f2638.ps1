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

if ($s.Contains("  {v:'26.38',what:")) { throw "check 26.38 is in the fixture already" }

SubRx @'
  {v:'26.37',what:
'@ @'
  {v:'26.38',what:'settings1, his order 2026-10-14: Settings reads in sections (THE RAID, AUDIO, CONTROLS, CONTROLLER, DISPLAY, SAVES AND TOOLS) under a jump bar, each row in its own section, and AUDIO carries UI VOLUME, FOOTSTEPS VOLUME and MONO AUDIO: they default to today (full, full, off), step and save, and change what is played (the HUD bus level, the level of a step, a one channel output with no pan)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof sndBus!=='function'||typeof earsOf!=='function'||typeof volApply!=='function'||typeof sndUi!=='function'||typeof _realBlip!=='function') return 'SKIP: no Settings or sound here';
     if(typeof setSecsHtml!=='function'||typeof SETSEC==='undefined') return 'Settings has no sections: one flat list';
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
     function reach(n,t){ var q=[n],seen=[],i=0,x,j; while(i<q.length&&i<6000){ x=q[i++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(j=0;j<(x.outs||[]).length;j++) q.push(x.outs[j]); } return false; }
     function peak(nodes){ var m=0, n; nodes.forEach(function(x){ if(x.kind==='gain'&&x.gain){ n=Math.max(+x.gain.value||0,+x.gain.last||0); if(n>m) m=n; } }); return m; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), host=document.getElementById('setlist'), was=md&&md.classList.contains('on'), mh, ov,
         kGO=P.gameOpts, kTU=P.tuned, kMono=CFG.mono, kVU=CFG.volUi, kVF=CFG.volFoot, i, j, k, q, el, hd, rows, row, seen, m0, made, d0, d1, ub, osc, pans, at, bar, off, chip;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(g) g.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(g&&kSim!==null) g.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; kSim=g.sim; g.ents.length=0;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the sections, in order, each row under its own head
       md.classList.add('on'); renderSettings();
       hd=[].map.call(document.querySelectorAll('#setlist .row[style*="opacity:.7"] b'),function(b){ return b.textContent; });
       at=-1;
       ['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','SAVES AND TOOLS'].forEach(function(w){ var x=hd.indexOf(w); if(x<0) bad.push('ONE: Settings has no '+w+' section'); else { if(x<=at) bad.push('ONE: '+w+' is out of order ('+hd.join(' > ')+')'); at=x; } });
       q={go_raiders:'THE RAID',go_volMaster:'AUDIO',go_volMusic:'AUDIO',go_volFx:'AUDIO',go_volUi:'AUDIO',go_volFoot:'AUDIO',go_mono:'AUDIO',set_music:'AUDIO',set_keys:'CONTROLS',go_rumble:'CONTROLLER',go_gfxLight:'DISPLAY',go_minimap:'DISPLAY',go_fxInt:'DISPLAY',set_text:'DISPLAY',set_layout:'DISPLAY',set_auto:'SAVES AND TOOLS'};
       for(k in q){ if(!document.getElementById(k)){ bad.push('ONE: Settings draws no '+k); continue; } if(secOf(k)!==q[k]) bad.push('ONE: '+k+' sits under '+secOf(k)+', not '+q[k]); }
       // TWO: the jump bar scrolls to a section
       chip=null; el=host.querySelectorAll('.setjump button');
       if(el.length<5) bad.push('TWO: the jump bar has '+el.length+' chips');
       for(i=0;i<el.length;i++){ if(!document.getElementById('setsec_'+el[i].getAttribute('data-sec').replace(/ /g,'_'))) bad.push('TWO: the chip '+el[i].textContent+' has no section'); if(el[i].getAttribute('data-sec')==='AUDIO') chip=el[i]; }
       mh=host.style.maxHeight; ov=host.style.overflowY; host.style.maxHeight='300px'; host.style.overflowY='auto'; host.scrollTop=0;
       if(chip&&host.getClientRects().length&&host.scrollHeight>host.clientHeight+500){
         chip.click(); bar=host.querySelector('.setjump'); off=document.getElementById('setsec_AUDIO').getBoundingClientRect().top-host.getBoundingClientRect().top-bar.getBoundingClientRect().height;
         if(Math.abs(off)>6) bad.push('TWO: the AUDIO chip left the section '+Math.round(off)+'px from the top of the list');
       }
       // THREE: the rows default to today, step, and save
       rows=__opts.rows()||[];
       [['volUi',1,[1,0,0.25]],['volFoot',1,[1,0,0.25]],['mono',0,[0,1,0]]].forEach(function(w){
         var kk=w[0], rr=rowOf(kk), sn, jj;
         if(!rr){ bad.push('THREE: Settings has no '+kk+' row'); return; }
         if(CFG[kk]!==w[1]) bad.push('THREE: a fresh profile has '+kk+' '+CFG[kk]+', not '+w[1]);
         if(gameOptLive(kk)!==rr.def) bad.push('THREE: the '+kk+' row reads CUSTOM on a fresh profile');
         if(rr.label!==String(rr.label).toUpperCase()) bad.push('THREE: the '+kk+' label is not caps');
         sn=[CFG[kk]]; for(jj=1;jj<w[2].length;jj++){ __opts.cycle(kk); sn.push(CFG[kk]); }
         if(sn.join(',')!==w[2].join(',')) bad.push('THREE: clicking '+kk+' steps it '+sn.join(' > ')+', not '+w[2].join(' > '));
         if(typeof P.gameOpts[kk]!=='number') bad.push('THREE: the '+kk+' pick was not saved in the profile');
       });
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // FOUR: the sounds, through a stand-in audio context
       fakeOn();
       CFG.volUi=0.5; ub=sndBus('ui');
       if(!ub||!ub.gain) bad.push('FOUR: no HUD bus');
       else {
         if(Math.abs(ub.gain.value-0.5)>1e-6) bad.push('FOUR: the HUD bus was born at '+ub.gain.value+', not the UI VOLUME 0.5');
         CFG.volUi=0.25; volApply(); if(Math.abs(ub.gain.value-0.25)>1e-6) bad.push('FOUR: UI VOLUME 25% left the HUD bus at '+ub.gain.value);
         CFG.volUi=1; volApply(); if(Math.abs(ub.gain.value-1)>1e-6) bad.push('FOUR: UI VOLUME full left the HUD bus at '+ub.gain.value);
         m0=MADE.length; SND_UI_AT=-1; sndUi('ok'); made=MADE.slice(m0); osc=made.filter(function(x){ return x.kind==='osc'; });
         if(!osc.length||!reach(osc[0],ub)) bad.push('FOUR: a menu click does not play on the HUD bus');
       }
       CFG.volFoot=1; sndBus('foley');
       ['foot','step','stepHeavy'].forEach(function(kd){ m0=MADE.length; _realBlip(kd,100,0,'stone','walk'); if(MADE.length===m0) bad.push('FOUR: control: a '+kd+' made no sound at full FOOTSTEPS VOLUME'); });
       m0=MADE.length; _realBlip('foot',100,0,'stone','walk'); d1=peak(MADE.slice(m0));
       CFG.volFoot=0.5; m0=MADE.length; _realBlip('foot',100,0,'stone','walk'); d0=peak(MADE.slice(m0));
       if(d1>0&&!(d0>d1*0.35&&d0<d1*0.65)) bad.push('FOUR: FOOTSTEPS VOLUME 50% played a step at '+(d0/d1).toFixed(2)+' of full, not half');
       CFG.volFoot=0;
       ['foot','step','stepHeavy'].forEach(function(kd){ m0=MADE.length; _realBlip(kd,100,0,'stone','walk'); if(MADE.length>m0) bad.push('FOUR: FOOTSTEPS VOLUME off still played a '+kd); });
       m0=MADE.length; _realBlip('clank',100,0); if(MADE.length===m0) bad.push('FOUR: FOOTSTEPS VOLUME off silenced a clank as well');
       CFG.volFoot=1;
       // FIVE: mono
       CFG.mono=0; if(!(earsOf(p.x+400,p.y).pan>0.5)) bad.push('FIVE: control: a sound 400 to the right does not pan right');
       m0=MADE.length; _realBlip('hit',100,0.9); pans=MADE.slice(m0).filter(function(x){ return x.kind==='pan'; });
       if(!pans.length||!(pans[0].pan.value>0.5)) bad.push('FIVE: control: a panned hit made no right pan');
       volApply(); if(FK.destination.channelCount!==2) bad.push('FIVE: stereo output is '+FK.destination.channelCount+' channels');
       CFG.mono=1;
       if(earsOf(p.x+400,p.y).pan!==0||earsOf(p.x-400,p.y).pan!==0) bad.push('FIVE: MONO AUDIO still pans a world sound');
       m0=MADE.length; _realBlip('hit',100,0.9); pans=MADE.slice(m0).filter(function(x){ return x.kind==='pan'; });
       if(pans.some(function(x){ return x.pan.value!==0; })) bad.push('FIVE: MONO AUDIO still pans a placed sound ('+pans[0].pan.value+')');
       volApply(); if(FK.destination.channelCount!==1) bad.push('FIVE: MONO AUDIO leaves the output at '+FK.destination.channelCount+' channels');
       if(hasNet){ NET.same='host'; volApply(); if(FK.destination.channelCount!==2) bad.push('FIVE: MONO AUDIO folded the split speakers of a same machine pair'); NET.same=''; }
       CFG.mono=0; volApply(); if(FK.destination.channelCount!==2) bad.push('FIVE: MONO AUDIO off did not give the two channels back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fakeOff(); }catch(_f){}
       try{ CFG.mono=kMono; CFG.volUi=kVU; CFG.volFoot=kVF; }catch(_c){}
       try{ host.style.maxHeight=mh||''; host.style.overflowY=ov||''; }catch(_h){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
