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

if ($s.Contains("  {v:'25.07',what:")) { throw "check 25.07 is in the fixture already" }

SubRx @'
  {v:'25.06',what:
'@ @'
  {v:'25.07',what:'his order 2026-10-12, the downed noise: going down asks for no spoken DOWN bark and plays the downed noise (a thump on the sting bus, a ring, and a lowpass dip on the world mix that opens again), a teammate going down is heard panned where he fell with no ring, and nothing plays under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof damagePlayer!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture cannot run a raid';
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
     var bad=[], g=null, p=null, kV=(typeof voxBark==='function')?voxBark:null, own=false, asked=[], faked=false, made, m0, st, thump, ring, dips, pn, r, src0, fn;
     function isThump(x){ return x.kind==='osc'&&x.on>0&&x.frequency.h.some(function(v){ return v<=40; }); }
     function isRing(x){ return x.kind==='osc'&&x.on>0&&x.frequency.value>=1000; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player;
       if(kV){ voxBark=function(k){ asked.push(k); return true; }; own=true; }
       kSim=(G?G.sim:null); fakeOn(); faked=true;
       st=sndBus('sting');
       p.iv=0; p.hp=5; p.armor=0; p.downed=false;
       m0=MADE.length;
       damagePlayer(400,'test','TEST');
       made=MADE.slice(m0);
       if(!p.downed) return 'SKIP: staging: the hit did not put him down';
       if(asked.indexOf('DOWN')>=0) bad.push('going down still asks for the spoken DOWN bark');
       thump=made.filter(function(x){ return isThump(x)&&reach(x,st); });
       ring=made.filter(function(x){ return isRing(x)&&reach(x,st); });
       if(!thump.length) bad.push('going down plays no low thump on the sting bus');
       if(!ring.length) bad.push('going down plays no ring');
       dips=MADE.filter(function(x){ return x.kind==='filter'&&x.type==='lowpass'&&x.frequency.h.some(function(v){ return v<=500; })&&SND&&reach(SND.world,x)&&reach(x,BUS); });
       if(!dips.length) bad.push('going down does not dip the world mix through a lowpass');
       else {
         if(!(dips[0].frequency.value>=10000)) bad.push('the world dip does not open again ('+dips[0].frequency.value+')');
         if(thump.some(function(x){ return reach(x,dips[0]); })) bad.push('the downed noise is muffled by its own dip');
       }
       fn=(typeof sndDowned==='function')?sndDowned:null;
       if(!fn) bad.push('no downed noise to play for a teammate');
       else {
         m0=MADE.length; r=fn(0,p.x+300,p.y); made=MADE.slice(m0);
         pn=made.filter(function(x){ return x.kind==='pan'&&x.pan.value>0.2&&reach(x,st); })[0];
         if(!r||!pn) bad.push('a teammate going down 300 to the right is not heard panned right');
         else if(!made.some(function(x){ return isThump(x)&&reach(x,pn); })) bad.push('a teammate going down plays no thump');
         if(made.some(isRing)) bad.push('a teammate going down plays the ring meant for your own fall');
         G.sim=true; m0=MADE.length; r=fn(1); G.sim=false;
         if(r||MADE.length>m0) bad.push('the downed noise played under G.sim');
         src0=(typeof netOnState==='function')?String(netOnState):'';
         if(src0.indexOf('sndDow'+'ned(0,x,y)')<0) bad.push('the TEAMMATE DOWN word does not play the downed noise where he fell');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&kV) voxBark=kV;
       if(faked){ try{ fakeOff(); }catch(_f){} }
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.downed=false; g2.player.hp=100; g2.player.iv=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
