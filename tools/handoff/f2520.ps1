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

if ($s.Contains("  {v:'25.20',what:")) { throw "check 25.20 is in the fixture already" }

SubRx @'
  {v:'25.19',what:
'@ @'
  {v:'25.20',what:'his orders (good reload noises, sounds for bandaging and armour): the foley bank decodes every clip, and foley() plays one on its bus, centred for you and panned for a thing off to the side, never under G.sim',
   run:function(){
     if(typeof SFXBANK!=='object'||!SFXBANK||typeof foley!=='function'||typeof sfxbDecode!=='function'||typeof sfxbWav!=='function') return 'no foley bank (SFXBANK, foley): reloads, bandages and plates have no recorded sounds';
     if(typeof OfflineAudioContext!=='function') return 'SKIP: no OfflineAudioContext in this browser';
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function') return 'SKIP: this fixture cannot run a raid';
     var bad=[], OFF=new OfflineAudioContext(1,22050,22050), keys0=Object.keys(SFXBANK), tot=0, i, k, b, c, pk, j;
     ['magOut','magIn','slideRack','rifleMagOut','rifleCharge','shellIn','pump','boltLatch','lmgClack','bandageTear','bandageWrap','medkitZip','medkitSnap','injector','plateClack','strapRip'].forEach(function(r){ if(!SFXBANK[r]) bad.push('the bank has no '+r+' clip'); });
     for(i=0;i<keys0.length;i++){
       k=keys0[i]; tot+=String(SFXBANK[k].w||'').length;
       b=null; try{ b=sfxbWav(OFF,SFXBANK[k].w); }catch(x0){ b=null; }
       if(!b||!(b.duration>0.03)){ bad.push('the '+k+' clip does not decode to a sound longer than 0.03 s ('+(b?b.duration:'null')+')'); continue; }
       c=b.getChannelData(0); pk=0; for(j=0;j<c.length;j++){ if(c[j]>pk) pk=c[j]; else if(-c[j]>pk) pk=-c[j]; }
       if(!(pk>0.3&&pk<=1.0001)) bad.push('the '+k+' clip decodes to the wrong level (peak '+pk.toFixed(3)+')');
       if(!(SFXBANK[k].g>0&&SFXBANK[k].g<=1)) bad.push('the '+k+' clip has no sane level');
       if(['gun','foley','mach','imp','ui','world'].indexOf(SFXBANK[k].c)<0) bad.push('the '+k+' clip names no mix bus');
     }
     if(tot>450*1024) bad.push('the bank is '+tot+' bytes of base64, over the 450 KB budget');
     if(bad.length) return bad.join('; ');
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(kd,ps){ var o={kind:kd,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){ o.started=[].slice.call(arguments); }; o.stop=function(){}; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:5,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(ch,l,sr){ return OFF.createBuffer(ch,l,sr); },
       decodeAudioData:function(){ return Promise.reject(new Error('not here')); }};
     function reach(n,t){ var q=[n],seen=[],ii=0,x,jj; while(ii<q.length&&ii<6000){ x=q[ii++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(jj=0;jj<(x.outs||[]).length;jj++) q.push(x.outs[jj]); } return false; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=(typeof AMB!=='undefined')?AMB:null, kSim=null, kFX=FXS;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined, kOn=hasNet?NET.on:undefined;
     var kB={buf:SFXB.buf,ac:SFXB.ac,nb:SFXB.nb,n:SFXB.n,at:SFXB.at,last:SFXB.last}, on=false, g=null, p, m0, made, s1, s2, s3, src, pans, gn, want, E, Pl, kx, ky;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=g.sim;
       AC=FK; BUS=null; REV=null; if(typeof AMB!=='undefined') AMB=null; if(typeof SND!=='undefined') SND=null; G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; NET.on=false; } on=true;
       SFXB.ac=null; SFXB.at={};
       // yours: centred, on the gun bus, the whole clip
       m0=MADE.length; s1=foley('magOut'); made=MADE.slice(m0);
       if(SFXB.nb!==keys0.length) bad.push('the first foley decoded '+SFXB.nb+' of '+keys0.length+' clips at once');
       src=made.filter(function(x){ return x.kind==='src'; })[0];
       if(!s1||!src||s1!==src) bad.push('foley(magOut) played no buffer');
       else{
         if(!(src.buffer&&src.buffer.duration>0.03)) bad.push('your magazine out plays an empty buffer');
         if(!reach(src,sndBus(SFXBANK.magOut.c))) bad.push('your magazine out is not on the '+SFXBANK.magOut.c+' bus');
         if(made.some(function(x){ return x.kind==='pan'&&reach(src,x)&&Math.abs(x.pan.value)>0.001; })) bad.push('your own sound is panned in your own ears');
         if(!(src.started&&Math.abs(src.started[0]-5)<0.001)) bad.push('your magazine out does not start now ('+(src.started||[]).join(',')+')');
         if(!(Math.abs(src.playbackRate.value-1)<=0.0401)) bad.push('the pitch spread is more than 4 percent ('+src.playbackRate.value+')');
       }
       // a thing 400 to your left: panned left by earsOf and the v23.73 width, quieter, on its own bus
       kx=p.x-400; ky=p.y;
       m0=MADE.length; s2=foley('bandageTear',kx,ky); made=MADE.slice(m0);
       src=made.filter(function(x){ return x.kind==='src'; })[0];
       if(!s2||!src) bad.push('foley(bandageTear) 400 away played nothing');
       else{
         E=earsOf(kx,ky); Pl=sndPlace(kx,ky); want=clamp(E.pan*(Pl.panK||1),-1,1);
         pans=made.filter(function(x){ return x.kind==='pan'&&reach(src,x); });
         if(!pans.length) bad.push('a sound 400 to your left is not panned');
         else if(!(Math.abs(pans[0].pan.value-want)<0.001&&pans[0].pan.value<-0.5)) bad.push('a sound 400 to your left is panned '+pans[0].pan.value+', wanted '+want);
         if(!reach(src,sndBus(SFXBANK.bandageTear.c))) bad.push('the far bandage is not on the '+SFXBANK.bandageTear.c+' bus');
         gn=made.filter(function(x){ return x.kind==='gain'&&x.outs.length&&reach(src,x); })[0];
         if(!gn||!(Math.abs(gn.gain.value-SFXBANK.bandageTear.g*(1-400/900))<0.0005)) bad.push('the far bandage is not faded by distance ('+(gn?gn.gain.value:'no gain')+')');
         if(Pl.lp>0&&!made.some(function(x){ return x.kind==='filter'&&reach(src,x)&&x.frequency.value===Pl.lp; })) bad.push('a sound behind a wall is not muffled');
       }
       // a trim window and out of earshot
       SFXB.at={}; m0=MADE.length; s3=foley('medkitZip',undefined,undefined,{off:0.1,dur:0.2}); made=MADE.slice(m0);
       if(!s3||!s3.started||Math.abs(s3.started[1]-0.1)>0.001||Math.abs(s3.started[2]-0.2)>0.001) bad.push('a trim window is not played as asked ('+(s3&&s3.started||[]).join(',')+')');
       if(foley('bandageTear',p.x+4000,p.y)) bad.push('a sound 4000 away still plays');
       if(foley('noSuchClip')) bad.push('an unknown clip played');
       // never under G.sim
       SFXB.at={}; G.sim=true; m0=MADE.length; s1=foley('magOut'); G.sim=false;
       if(s1||MADE.length!==m0) bad.push('foley played under G.sim');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(on){ AC=kAC; BUS=kBUS; REV=kREV; if(typeof AMB!=='undefined') AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; NET.on=kOn; } } }catch(_f){}
       try{ SFXB.buf=kB.buf; SFXB.ac=kB.ac; SFXB.nb=kB.nb; SFXB.n=kB.n; SFXB.at=kB.at; SFXB.last=kB.last; FXS=kFX; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
