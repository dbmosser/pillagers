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

if ($s.Contains("  {v:'24.94',what:")) { throw "check 24.94 is in the fixture already" }

SubRx @'
  {v:'24.93',what:
'@ @'
  {v:'24.94',what:'his order 2026-10-12, distinct noises: an enemy round that passes close by you without hitting whizzes past once, on the side it passed (a band of noise falling from 3.5 kHz with a small snap, on the HUD bus); a round that hits you, one far off, your own round and any round under G.sim do not, and the whizz itself never plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateBullets!=='function'||!window.__audio||!__audio.blipRaw) return 'SKIP: this fixture cannot run a raid';
     function P(v){ var q={value:v,h:[]}; q.setValueAtTime=function(x){ q.value=x; q.h.push(x); return q; }; q.setTargetAtTime=function(x){ q.value=x; q.h.push(x); return q; }; q.linearRampToValueAtTime=function(x){ q.value=x; q.h.push(x); return q; }; q.exponentialRampToValueAtTime=function(x){ q.value=x; q.h.push(x); return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(k,ps){ var o={kind:k,outs:[],on:0}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(){ o.on++; }; o.stop=function(){}; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
       createGain:function(){ return N('gain',['gain']); },
       createBiquadFilter:function(){ var o=N('filter',['frequency','Q','gain','detune']); o.type='lowpass'; return o; },
       createStereoPanner:function(){ return N('pan',['pan']); },
       createDynamicsCompressor:function(){ return N('comp',['threshold','knee','ratio','attack','release']); },
       createOscillator:function(){ var o=N('osc',['frequency','detune']); o.type='sine'; return o; },
       createDelay:function(){ return N('delay',['delayTime']); },
       createConvolver:function(){ var o=N('conv'); o.buffer=null; return o; },
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet) NET.specTick=0; }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; } }
     var bad=[], g=null, p=null, heard=[], kB=blip, ownB=false, kIv=null, kBul=null, e=null, faked=false, made, k, kAt=null;
     function rd(dx,dy,vx,vy,mine){ return {x:p.x+dx,y:p.y+dy,vx:vx,vy:vy,dmg:1,life:1,player:!!mine,owner:mine?p:e,tint:'#ffffff'}; }
     function fly(b,n){ G.bullets.length=0; G.bullets.push(b); for(var q=0;q<n&&G.bullets.length;q++) updateBullets(1/60); G.bullets.length=0; }
     function wz(){ return heard.filter(function(h){ return h[0]==='whizz'; }); }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=G.sim; kIv=p.iv; kBul=G.bullets.slice(); p.iv=99;
       e=G.ents.filter(function(q){ return q&&q.kind!=='raider'&&!q.merc&&q.hp>0; })[0]||null;
       if(!e) return 'SKIP: no machine to fire the round';
       blip=function(t){ heard.push([String(t),arguments[2]]); }; ownB=true;
       fly(rd(25,-80,0,1180,false),20);
       made=wz();
       if(made.length!==1) bad.push('a machine round passing 25 to your right whizzed '+made.length+' times, not once');
       else if(!(made[0][1]>0.2)) bad.push('a round passing on your right whizzed '+(made[0][1]<0?'on the left':'in the centre')+' ('+made[0][1]+')');
       heard.length=0; fly(rd(-25,-80,0,1180,false),20); made=wz();
       if(made.length!==1) bad.push('a machine round passing 25 to your left whizzed '+made.length+' times, not once');
       else if(!(made[0][1]<-0.2)) bad.push('a round passing on your left whizzed '+(made[0][1]>0?'on the right':'in the centre')+' ('+made[0][1]+')');
       heard.length=0; fly(rd(0,-80,0,1180,false),20);
       if(wz().length) bad.push('a round that hit you also whizzed');
       heard.length=0; fly(rd(200,-80,0,1180,false),20);
       if(wz().length) bad.push('a round passing 200 away whizzed');
       heard.length=0; fly(rd(25,-80,0,1180,true),20);
       if(wz().length) bad.push('your own round whizzed past you');
       heard.length=0; G.sim=true; try{ fly(rd(25,-80,0,1180,false),20); }finally{ G.sim=kSim; }
       if(wz().length) bad.push('a near miss whizzed under G.sim');
       blip=kB; ownB=false;
       if(typeof SNDA!=='object'||!SNDA) bad.push('no new noise kit (SNDA)');
       else {
         kAt=SNDA.at.whizz; delete SNDA.at.whizz;
         fakeOn(); faked=true; sndBus('ui');
         k=MADE.length; __audio.blipRaw('whizz',undefined,0.6); made=MADE.slice(k);
         if(!made.some(function(n){ return n.kind==='src'&&n.on>0; })) bad.push('the whizz starts no noise');
         if(!made.some(function(n){ return n.kind==='filter'&&n.type==='bandpass'&&n.frequency.h[0]>=3000&&Math.min.apply(null,n.frequency.h)<=1500; })) bad.push('the whizz is not a band sweeping down from 3.5 kHz');
         if(!made.some(function(n){ return n.kind==='osc'&&n.on>0&&n.frequency.h[0]>=3500; })) bad.push('the whizz has no snap');
         if(!made.some(function(n){ return n.kind==='pan'&&n.pan.value>0.3; })) bad.push('the whizz is not panned to its side');
         if(made.length>12) bad.push('the whizz builds '+made.length+' nodes');
         k=MADE.length; __audio.blipRaw('whizz',undefined,0.6);
         if(MADE.slice(k).some(function(n){ return (n.kind==='src'||n.kind==='osc')&&n.on>0; })) bad.push('two whizzes in the same instant both played (no rate limit)');
         FK.currentTime=1.5; G.sim=true; k=MADE.length; __audio.blipRaw('whizz',undefined,0.6); G.sim=false;
         if(MADE.slice(k).some(function(n){ return (n.kind==='src'||n.kind==='osc')&&n.on>0; })) bad.push('the whizz played under G.sim');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownB) blip=kB;
       if(faked){ try{ fakeOff(); }catch(_f){} }
       try{ if(typeof SNDA==='object'&&SNDA){ if(kAt===null||kAt===undefined) delete SNDA.at.whizz; else SNDA.at.whizz=kAt; } }catch(_k){}
       try{ if(G&&kSim!==null) G.sim=kSim; if(kBul){ G.bullets.length=0; kBul.forEach(function(q){ G.bullets.push(q); }); } }catch(_b){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
