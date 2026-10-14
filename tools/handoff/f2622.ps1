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

if ($s.Contains("  {v:'26.22',what:")) { throw "check 26.22 is in the fixture already" }

SubRx @'
  {v:'26.21',what:
'@ @'
  {v:'26.22',what:'his order (success music and failure music): the EXTRACTED card starts one short rising piece and the KILLED IN ACTION card one short falling piece, each once on the music bus at the Music volume, an abandon starts none, nothing plays while a raid is live and a raid going up cuts one still ringing, the title waits until it has rung out, Music OFF or a Music volume of 0 keeps them silent, and the DEMO RUN OVER card and the player 2 window play their own',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof __topClear!=='function'||typeof tickMusic!=='function'||typeof musicWanted!=='function') return 'SKIP: this fixture cannot run a raid';
     if(typeof outMusic!=='function'||typeof outSpec!=='function'||typeof OUTM!=='object'||!OUTM) return 'the end of a raid plays no music (no outMusic)';
     function AP(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(k,ps){ var o={kind:k,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(t){ o.st=t; }; o.stop=function(t){ o.sp=t; }; (ps||[]).forEach(function(n){ o[n]=AP(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createConvolver:function(){ var o=N('conv'); o.buffer=null; o.normalize=true; return o; },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     function reach(n,t){ var q=[n],seen=[],i=0,x,j; while(i<q.length&&i<6000){ x=q[i++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(j=0;j<(x.outs||[]).length;j++) q.push(x.outs[j]); } return false; }
     var bad=[], g=null, hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null),
         kAnn={busy:ANNC.busy,n:ANNC.n,last:ANNC.last}, kO={}, kVm=CFG.volMusic, kVM=CFG.volMaster, ownPM=!!(P&&Object.prototype.hasOwnProperty.call(P,'music')), kPM=P?P.music:undefined,
         ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined, nsv=null, pr0=pendingRun,
         ti=document.getElementById('title'), ti0=!!(ti&&ti.classList.contains('on')), rsp=null, ownSp=false, nb0=null, ownNb=false, BK='', bk=null, ownBk=false, src0=null, tried0=null, ownAtt=false,
         k, gA=0, gB=0, r, n0, m0, held;
     for(k in OUTM) if(Object.prototype.hasOwnProperty.call(OUTM,k)) kO[k]=OUTM[k];
     function fkOn(keepNet){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; if(!keepNet) NET.same=''; } FK.currentTime+=40; OUTM.end=0; }
     function fkOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     function under(fn,keepNet){
       var o={m0:MADE.length,n0:OUTM.n,bus:null};
       fkOn(keepNet);
       try{ fn(o); o.bus=BUS; } finally{ fkOff(); }
       o.nodes=MADE.slice(o.m0); o.n=OUTM.n-o.n0; o.last=OUTM.last;
       return o;
     }
     function raid(){ __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player||g.over) return false; g.ents.length=0; g.player.iv=99; return true; }
     function phase(how,prep,pm){
       var o;
       if(P) P.music=pm||'hub';
       o=under(function(q){ if(prep) prep(); __endRaid(how); if(how==='extract'||how==='dead'){ q.again=outMusic(how==='extract'?'win':'kia'); q.nAfter=OUTM.n; } },false);
       try{ o.card=document.getElementById('oc_title').textContent; }catch(_c){}
       return o;
     }
     function judge(label,o,kind){
       var sp, mine, nnz;
       if(!kind){ if(o.n!==0) bad.push(label+' started '+o.n+' pieces of music, not none'); return; }
       if(o.n!==1||o.last!==kind){ bad.push(label+' started '+o.n+' pieces, the last '+(o.last||'none')+', not one '+kind); return; }
       if(o.again!==undefined&&(o.again!==false||o.nAfter!==o.n0+1)) bad.push(label+' played a second piece over the first');
       sp=outSpec(kind); mine=o.nodes.filter(function(x){ return (x.kind==='osc'||x.kind==='src')&&OUTM.g&&reach(x,OUTM.g); });
       nnz=sp.notes.filter(function(q){ return q[4]==='noise'; }).length;
       if(mine.length!==sp.notes.length||mine.filter(function(x){ return x.kind==='src'; }).length!==nnz) bad.push(label+' built '+mine.length+' voices for '+sp.notes.length+' notes');
       if(!mine.every(function(x){ return reach(x,FK.destination); })) bad.push(label+' does not reach the output through the music path');
       if(o.bus&&mine.some(function(x){ return reach(x,o.bus); })) bad.push(label+' rides the sound bus, not the music bus');
       if(!mine.every(function(x){ return typeof x.st==='number'&&typeof x.sp==='number'&&x.sp>x.st&&x.sp-x.st<=sp.len+0.3; })) bad.push(label+' has a voice that never stops');
       if(!OUTM.g||!(OUTM.g.gain.value>0)||Math.abs(OUTM.g.gain.value-OUTM.base*outLevel())>1e-9) bad.push(label+' is not at the Music volume ('+(OUTM.g?OUTM.g.gain.value:'no gain')+' for '+(OUTM.base*outLevel())+')');
     }
     try{
       // 1. the two pieces, as written
       ['win','kia'].forEach(function(kd){
         var sp=outSpec(kd), i, ok=true, hi=0, lo=0, sum, cur, q, big;
         if(!sp||!(sp.len>=4&&sp.len<=6)){ bad.push('the '+kd+' piece is not 4 to 6 seconds long'); return; }
         if(!sp.fig||sp.fig.length<4) ok=false;
         for(i=1;sp.fig&&i<sp.fig.length;i++) if(kd==='win'?!(sp.fig[i]>sp.fig[i-1]):!(sp.fig[i]<sp.fig[i-1])) ok=false;
         if(!ok) bad.push('the '+kd+' piece does not '+(kd==='win'?'climb':'fall')+' ('+(sp.fig||[]).map(Math.round).join(' ')+' Hz)');
         sum=0;
         for(i=0;i<sp.notes.length;i++){
           if(sp.notes[i][0]+sp.notes[i][3]>sp.len+0.01) bad.push('a note of the '+kd+' piece runs past its end');
           cur=0; for(q=0;q<sp.notes.length;q++) if(sp.notes[q][0]<=sp.notes[i][0]+1e-9&&sp.notes[q][0]+sp.notes[q][3]>sp.notes[i][0]) cur+=sp.notes[q][5];
           sum=Math.max(sum,cur);
         }
         if(sum>2.6) bad.push('the '+kd+' piece sums to '+sum.toFixed(2)+' at once, too loud');
         if(kd==='win'){
           big=sp.notes.filter(function(x){ return x[0]===sp.chordAt&&x[4]!=='noise'&&x[1]>=140; }).length;
           if(big<6) bad.push('the last chord of the success piece has only '+big+' voices');
           sp.notes.forEach(function(x){ if(x[4]==='noise') return; if(x[0]>=sp.chordAt-0.001) hi=Math.max(hi,x[1]); else lo=Math.max(lo,x[1]); });
           if(!(hi>lo)) bad.push('the success piece does not end higher than it began ('+Math.round(lo)+' to '+Math.round(hi)+' Hz)');
         } else {
           if(!sp.notes.some(function(x){ return x[0]===0&&x[4]==='sine'&&x[1]>x[2]; })) bad.push('the failure piece has no falling hit at the start');
           if(!sp.notes.some(function(x){ return x[0]===0&&x[3]>=4.5&&x[1]<=80; })) bad.push('the failure piece has no low drone that lasts');
         }
       });
       // 2. nothing plays while a raid is live
       if(!raid()) return 'SKIP: no live raid';
       CFG.volMusic=0.6; CFG.volMaster=1;
       m0=MADE.length; n0=OUTM.n;
       under(function(){ tickMusic(); tickMusic(); if(musicWanted()) bad.push('a live raid asks for music'); },false);
       if(OUTM.n!==n0||MADE.slice(m0).some(function(x){ return x.kind==='osc'||x.kind==='src'; })) bad.push('a live raid built music voices');
       // 3. EXTRACTED, KILLED IN ACTION, ABANDONED
       r=phase('extract'); judge('EXTRACTED',r,'win'); gA=OUTM.g?OUTM.g.gain.value:0;
       if(!raid()) return bad.length?bad.join('; '):'SKIP: no second raid';
       CFG.volMusic=0.3; CFG.volMaster=1;
       r=phase('dead'); judge('KILLED IN ACTION',r,'kia'); gB=OUTM.g?OUTM.g.gain.value:0;
       if(!(gA>0)||Math.abs(gB/gA-0.5)>0.01) bad.push('the piece does not follow the Music volume (60% gave '+gA+', 30% gave '+gB+')');
       if(!raid()) return bad.length?bad.join('; '):'SKIP: no third raid';
       CFG.volMusic=0.6; CFG.volMaster=1;
       r=phase('abandon',function(){ if(g&&g.tel) g.tel.shots=3; }); judge('an abandon',r,'');
       if(r.card!=='ABANDONED') bad.push('the abandon did not reach its card ('+r.card+')');
       // 4. silence: the Music volume at 0, the Music row at OFF
       if(!raid()) return bad.length?bad.join('; '):'SKIP: no fourth raid';
       CFG.volMusic=0; CFG.volMaster=1;
       r=phase('extract'); judge('EXTRACTED at a Music volume of 0',r,'');
       if(!raid()) return bad.length?bad.join('; '):'SKIP: no fifth raid';
       CFG.volMusic=0.6; CFG.volMaster=1;
       r=phase('dead',null,'off'); judge('KILLED IN ACTION with the Music row at OFF',r,'');
       // 5. a raid going up cuts a piece still ringing, and the title waits for one that rings out
       if(raid()){
         CFG.volMusic=0.6; CFG.volMaster=1; if(P) P.music='hub';
         under(function(){
           if(!outMusic('win')) bad.push('the success piece did not start for the cut test');
           else { tickMusic(); if(OUTM.end!==0||!OUTM.g||OUTM.g.gain.value!==0) bad.push('a live raid did not cut the piece still ringing ('+OUTM.end+', gain '+(OUTM.g?OUTM.g.gain.value:'none')+')'); }
         },false);
         held=G; G=null; pendingRun=null;
         try{
           if(ti) under(function(){
             ti.classList.add('on');
             if(!outMusic('kia')) bad.push('the failure piece did not start for the title test');
             else {
               if(musicWanted()) bad.push('the title music starts while the piece still rings');
               FK.currentTime=OUTM.end+0.5;
               if(!musicWanted()) bad.push('the title music does not come back after the piece');
             }
           },false);
         } finally{ G=held; if(ti){ if(ti0) ti.classList.add('on'); else ti.classList.remove('on'); } }
       }
       // 6. the DEMO RUN OVER card, and player 2
       if(typeof arcadeDeploy==='function'&&typeof arcadeRunEnd==='function'&&typeof arcadeOnMsg==='function'&&typeof ARCADE==='object'&&ARCADE&&typeof attStop==='function'&&typeof arcadeLeave==='function'&&typeof ARCADE_BOARD_KEY==='string'&&hasNet&&!NET.on&&typeof netSamePost==='function'&&typeof ATT==='object'&&ATT){
         rsp=netSamePost; netSamePost=function(){ return true; }; ownSp=true;
         BK=ARCADE_BOARD_KEY; bk=localStorage.getItem(BK); ownBk=true; src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
         [['extract','win'],['dead','kia'],['idle','']].forEach(function(w){
           var up=false, o;
           try{ __topClear(); __runPrep(); if(!ARCADE.on) up=!!(arcadeDeploy({mapIx:0,seed:4242})&&__state()&&__state().arcade&&ARCADE.role==='host'); }catch(_ad){ up=false; }
           if(!up) return;
           try{ attStop(); }catch(_as){}
           CFG.volMusic=0.6; CFG.volMaster=1; ARCADE.ownAt=Date.now(); if(P) P.music='hub';
           o=under(function(){ arcadeRunEnd(w[0]); },false);
           judge('the DEMO RUN OVER card ('+w[0]+')',o,w[1]);
           try{ ARCADE.over=null; ARCADE.ini=null; }catch(_ao){}
         });
         try{ ARCADE.over=null; ARCADE.ini=null; if(ARCADE.on) arcadeLeave(); }catch(_al){}
         nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
         nb0=netBroadcast; netBroadcast=function(){}; ownNb=true;
         function stage2(){
           var gg;
           NET.on=false; NET.role=''; NET.same='p2';
           if(!arcadeDeploy({role:'p2',mapIx:0,seed:4242})||!__state()||!__state().arcade) return null;
           try{ attStop(); }catch(_a2){}
           gg=__state(); ARCADE.role='p2'; ARCADE.endRun=''; ARCADE.p2StopAt=0; ARCADE.holdT=0; ARCADE.ownAt=Date.now();
           NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=gg.seed>>>0; NET.up=[]; NET.peers=[]; NET.upOut={}; NET.pair='tp';
           CFG.volMusic=0.6; CFG.volMaster=1; if(P) P.music='hub';
           return gg;
         }
         function msg(id,extra){ var m={t:'arcend',pair:'tp',run:id}, q; for(q in extra) m[q]=extra[q]; return under(function(){ arcadeOnMsg(m); },true); }
         try{
           __topClear(); __runPrep();
           if(!ARCADE.on&&stage2()){
             judge('player 2 when the host run ends on an extraction',msg('zom1',{x2:1}),'win');
             if(stage2()) judge('player 2 when the host run ends on a death',msg('zom2',{ko:1}),'kia');
             if(stage2()) judge('player 2 when the host run is ended with END RUN',msg('zom3',{}),'');
             if(stage2()){
               arcadeEndTake();
               judge('player 2 when the out word came before the run end',msg('zom4',{x2:1}),'win');
               ARCADE.p2StopAt=0;
               judge('player 2 on its attract, out of the run',msg('zom5',{x2:1}),'');
             }
           }
         } finally{
           NET.on=false; NET.role='';
           try{ ARCADE.over=null; ARCADE.ini=null; ARCADE.endSend=null; ARCADE.endRun=''; if(ARCADE.on) arcadeLeave(); }catch(_a3){}
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ fkOff(); }catch(_f){}
       try{ if(ownSp) netSamePost=rsp; }catch(_a1){}
       try{ if(ownNb) netBroadcast=nb0; }catch(_a2){}
       try{ NET.on=false; NET.role=''; }catch(_a4){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_a5){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a6){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_a7){}
       try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.over=null; ARCADE.ini=null; ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.mine=0; ARCADE.mate=0; ARCADE.holdT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.late=0; if(ARCADE.on) arcadeLeave(); } }catch(_a3){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       try{ ANNC.busy=kAnn.busy; ANNC.n=kAnn.n; ANNC.last=kAnn.last; }catch(_b){}
       try{ for(k in OUTM) if(!(k in kO)) delete OUTM[k]; for(k in kO) OUTM[k]=kO[k]; }catch(_c2){}
       try{ CFG.volMusic=kVm; CFG.volMaster=kVM; }catch(_d){}
       try{ if(P){ if(ownPM) P.music=kPM; else delete P.music; } }catch(_e2){}
       try{ pendingRun=pr0; }catch(_pr){}
       try{ if(ti){ if(ti0) ti.classList.add('on'); else ti.classList.remove('on'); } }catch(_t){}
       __topClear(); try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
