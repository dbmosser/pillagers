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

if ($s.Contains("  {v:'25.19',what:")) { throw "check 25.19 is in the fixture already" }

SubRx @'
  {v:'25.18',what:
'@ @'
  {v:'25.19',what:'his order 2026-10-12, no player speech: a reload, a dry gun, a frag, a tripwire, going down, a heal and the score loss ask for no spoken bark and the page carries no player speech clip (the announcer clips stay); a revive charges up and lands with a click, the extraction pull starts with a rising beacon and the score loss is a falling buzz with a thud, each on the sting bus under a gunshot, and none plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof blipMine!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture cannot run a raid';
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
       createBufferSource:function(){ var o=N('src',['playbackRate','detune']); o.buffer=null; o.loop=false; return o; },
       createWaveShaper:function(){ var o=N('shaper'); o.curve=null; return o; },
       createBuffer:function(c,l,sr){ return {length:l,numberOfChannels:c,sampleRate:sr,getChannelData:function(){ return new Float32Array(l); }}; },
       decodeAudioData:function(){ return Promise.resolve({}); }};
     function reach(n,t){ var q=[n],seen=[],i=0,x,j; while(i<q.length&&i<6000){ x=q[i++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(j=0;j<(x.outs||[]).length;j++) q.push(x.outs[j]); } return false; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null);
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     var PL=['RELOADING','NOAMMO','FRAGOUT','TRIPWIRE','DOWN','HEALING','REVIVING','EXTRACTING','SCORELOST'];
     var bad=[], g=null, p=null, kV=(typeof voxBark==='function')?voxBark:null, own=false, asked=[], faked=false, st, k, made, fr=[], r, loud=0, kRev=null;
     var FN={blipMine:blipMine, throwFrom:(typeof throwFrom==='function')?throwFrom:null, tripArm:(typeof tripArm==='function')?tripArm:null, damagePlayer:(typeof damagePlayer==='function')?damagePlayer:null, useMedical:(typeof useMedical==='function')?useMedical:null, arcadeDied:(typeof arcadeDied==='function')?arcadeDied:null};
     var RC=(typeof sndRevCharge==='function')?sndRevCharge:null, RL=(typeof sndRevLand==='function')?sndRevLand:null, EX=(typeof sndExtracting==='function')?sndExtracting:null, SL=(typeof sndScoreLost==='function')?sndScoreLost:null;
     function fresh(){ var m=MADE.slice(k); m.forEach(function(n){ if(n.kind==='gain'&&n.on===0){ var v=Math.max(n.gain.value,Math.max.apply(null,n.gain.h.concat([0]))); if(v>loud&&reach(n,st)) loud=v; } }); return m; }
     function rises(n){ var h=n.frequency.h; return h.length>1&&h[h.length-1]>h[0]*1.4; }
     try{
       if(typeof VOX_BARKS==='object'&&VOX_BARKS) PL.forEach(function(q){ if(VOX_BARKS[q]) bad.push('the page still carries the '+q+' speech clip'); });
       if(typeof voxCall!=='function'||typeof VOX_ANN!=='object'||!VOX_ANN||!VOX_ANN.DOUBLEKILL||!VOX_ANN.EXTRACTED) bad.push('the announcer clips are gone');
       Object.keys(FN).forEach(function(q){ if(FN[q]&&String(FN[q]).indexOf('vox'+'Bark(')>=0) bad.push(q+' still asks for a spoken bark'); });
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player;
       if(kV){ voxBark=function(q){ asked.push(q); return true; }; own=true; }
       kSim=(G?G.sim:null); fakeOn(); faked=true;
       st=sndBus('sting');
       blipMine('reload'); blipMine('dry');
       if(asked.length) bad.push('a reload or a dry gun asks for a spoken bark ('+asked.join(',')+')');
       if(!RC||!RL||!EX||!SL) bad.push('no revive, extraction or score lost noise (sndRevCharge, sndRevLand, sndExtracting, sndScoreLost)');
       else {
         kRev=SND_NV.step; SND_NV.step=-1;
         [0.05,0.3,0.6,0.95].forEach(function(x){ k=MADE.length; RC(x); var o=fresh().filter(function(n){ return n.kind==='osc'&&n.on>0&&reach(n,st); })[0]; fr.push(o?o.frequency.h[0]:0); });
         if(!(fr[0]>0&&fr[0]<fr[1]&&fr[1]<fr[2]&&fr[2]<fr[3])) bad.push('the revive charge does not rise step by step ('+fr.map(Math.round).join(',')+')');
         p.downed=true; p.hp=0; p.revived=false;
         k=MADE.length; selfRevive(); made=fresh();
         if(!made.some(function(n){ return n.kind==='src'&&n.on>0&&reach(n,st); })) bad.push('a self-revive lands with no click');
         if(!made.some(function(n){ return n.kind==='osc'&&n.on>0&&rises(n)&&reach(n,st); })) bad.push('a self-revive lands with no rise');
         k=MADE.length; EX(); made=fresh();
         if(made.filter(function(n){ return n.kind==='osc'&&n.on>0&&rises(n)&&reach(n,st); }).length<2) bad.push('the extraction pull has no rising beacon');
         k=MADE.length; SL(); made=fresh();
         if(!made.some(function(n){ return n.kind==='osc'&&n.on>0&&n.type==='sawtooth'&&n.frequency.h[0]>=300&&Math.min.apply(null,n.frequency.h)<=120&&reach(n,st); })) bad.push('the score loss has no falling buzz');
         if(!made.some(function(n){ return n.kind==='osc'&&n.on>0&&Math.min.apply(null,n.frequency.h)<=50&&reach(n,st); })) bad.push('the score loss has no thud');
         if(!(loud>0)||loud>0.15) bad.push('the new noises are not under a gunshot (peak gain '+loud+')');
         if(String(netRevHold).indexOf('sndRevCh'+'arge(')<0) bad.push('holding E over a downed teammate does not charge');
         if(String(netRevApply).indexOf('sndRevL'+'and(')<0||String(selfRevive).indexOf('sndRevL'+'and(')<0) bad.push('a revive that lands does not click');
         if(typeof tryExtractTick==='function'&&String(tryExtractTick).indexOf('sndExtr'+'acting(')<0) bad.push('the extraction pull does not play its beacon');
         if(FN.arcadeDied&&String(FN.arcadeDied).indexOf('sndScore'+'Lost(')<0) bad.push('losing the score does not play its noise');
         G.sim=true; k=MADE.length; r=[RC(0.5),RL(),EX(),SL()]; G.sim=false;
         if(r.some(function(x){ return !!x; })||MADE.length>k) bad.push('a noise played under G.sim');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&kV) voxBark=kV;
       try{ if(kRev!==null) SND_NV.step=kRev; }catch(_r){}
       if(faked){ try{ fakeOff(); }catch(_f){} }
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.downed=false; g2.player.hp=100; g2.player.iv=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
