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

if ($s.Contains("  {v:'25.08',what:")) { throw "check 25.08 is in the fixture already" }

SubRx @'
  {v:'25.07',what:
'@ @'
  {v:'25.08',what:'his note: the rarer find sounds stop lingering: a green, blue, purple and gold find each play dry (no room reverb, no delay), every source and gain envelope ends inside 0.6 s for green and blue and 0.8 s for purple and gold, purple still climbs above blue, and a new find cuts the one still ringing',
   run:function(){
     if(typeof _realBlip!=='function'||typeof AC==='undefined'||typeof BUS==='undefined'||typeof REV==='undefined'||typeof AMB==='undefined'||typeof lootVoice!=='function'||typeof sndBus!=='function'||typeof ITEMS!=='object') return 'SKIP: this fixture has no real blip or audio holders to stand in for';
     function PR(v){ var q={value:v,ev:[]};
       q.setValueAtTime=function(x,t){ q.value=x; q.ev.push({m:'set',v:x,t:t}); return q; };
       q.setTargetAtTime=function(x,t,c){ q.value=x; q.ev.push({m:'tgt',v:x,t:t,c:c}); return q; };
       q.linearRampToValueAtTime=function(x,t){ q.value=x; q.ev.push({m:'lin',v:x,t:t}); return q; };
       q.exponentialRampToValueAtTime=function(x,t){ q.value=x; q.ev.push({m:'exp',v:x,t:t}); return q; };
       q.cancelScheduledValues=function(t){ q.ev.push({m:'cancel',t:t}); return q; }; q.cancelAndHoldAtTime=function(t){ q.ev.push({m:'cancel',t:t}); return q; }; return q; }
     var MADE=[], FK=null;
     function N(k,ps){ var o={kind:k,outs:[],st:null,sp:null}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(t){ o.st=(t===undefined)?FK.currentTime:t; }; o.stop=function(t){ o.sp=(t===undefined)?FK.currentTime:t; }; (ps||[]).forEach(function(n){ o[n]=PR(n==='gain'?1:0); }); MADE.push(o); return o; }
     FK={currentTime:1,sampleRate:48000,state:'running',resume:function(){},destination:N('dest'),
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
     function isSrc(n){ return n.kind==='osc'||n.kind==='src'; }
     // When the voice is over: the last source stop (a buffer with no stop ends with its buffer), and the last gain move
     // (a glide to a target counts until it is 60 dB down, 6.91 time constants). A source never stopped never ends.
     function endOf(made,t0){ var e=t0, i, j, n, q, k, x;
       for(i=0;i<made.length;i++){ n=made[i];
         if(isSrc(n)){ if(n.st===null) continue; x=(n.sp!==null)?n.sp:((n.kind==='src'&&!n.loop&&n.buffer&&n.buffer.length)?n.st+n.buffer.length/FK.sampleRate:Infinity); if(x>e) e=x; }
         if(n.kind==='gain'&&n.gain&&n.gain.ev){ q=n.gain.ev; for(j=0;j<q.length;j++){ k=q[j]; if(k.m==='cancel') continue; x=k.t+(k.m==='tgt'?6.91*k.c:0); if(x>e) e=x; } }
       }
       return e-t0; }
     function hiNote(made){ var h=0, i, j, q; for(i=0;i<made.length;i++) if(made[i].kind==='osc'){ q=made[i].frequency.ev; for(j=0;j<q.length;j++) if(q[j].m==='set'&&q[j].v>h) h=q[j].v; } return h; }
     function keyOf(f){ for(var k in ITEMS){ var it=ITEMS[k]; if(it&&f(it)) return k; } return null; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kSim=(G?G.sim:null), kCTX=(typeof SND_CTX!=='undefined')?SND_CTX:null;
     var hasFL=(typeof SND_FIND_LAST!=='undefined'), kFL=hasFL?SND_FIND_LAST:null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(typeof SND_CTX!=='undefined') SND_CTX=null; if(hasFL) SND_FIND_LAST=null; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(typeof SND_CTX!=='undefined') SND_CTX=kCTX; if(hasFL) SND_FIND_LAST=kFL; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     var bad=[], T, i, j, m0, made, v, t0, len, hi={}, name={};
     var kG=keyOf(function(it){ return it.use!=='gun'&&it.r==='uncommon'; }), kB=keyOf(function(it){ return it.use!=='gun'&&it.r==='rare'; }),
         kP=keyOf(function(it){ return it.use!=='gun'&&it.r==='elite'; }),
         kO=keyOf(function(it){ return it.use==='gun'&&it.gk&&typeof gunRarity==='function'&&gunRarity(it.gk)==='gold'; });
     if(!kG||!kB||!kP) return 'SKIP: staging: no green, blue or purple item in the table';
     T=[['green',kG,0.6],['blue',kB,0.6],['purple',kP,0.8]]; if(kO) T.push(['gold',kO,0.8]);
     try{
       fakeOn();
       bus(); sndBus('ui'); sndBus('world');
       if(!BUS||!REV||!REV.send) return 'SKIP: no bus or room reverb on the stand-in context';
       for(i=0;i<T.length;i++){
         FK.currentTime+=3; t0=FK.currentTime; v=lootVoice([T[i][1]]); name[T[i][0]]=v;
         m0=MADE.length; _realBlip(v); made=MADE.slice(m0);
         if(!made.some(isSrc)){ bad.push('a '+T[i][0]+' find ('+v+') made no sound'); continue; }
         if(made.some(function(n){ return reach(n,REV.send); })) bad.push('a '+T[i][0]+' find ('+v+') still rings on in the room reverb');
         if(made.some(function(n){ return n.kind==='delay'; })) bad.push('a '+T[i][0]+' find ('+v+') runs through a delay of its own');
         if(!made.filter(isSrc).every(function(n){ return reach(n,FK.destination); })) bad.push('a '+T[i][0]+' find ('+v+') does not reach the speakers');
         len=endOf(made,t0);
         if(!(len<=T[i][2]+1e-6)) bad.push('a '+T[i][0]+' find ('+v+') rings '+(isFinite(len)?len.toFixed(2)+' s':'forever')+', over its '+T[i][2]+' s');
         hi[T[i][0]]=hiNote(made);
       }
       if(!(hi.purple>hi.blue&&hi.blue>0)) bad.push('the purple find no longer climbs above the blue one (top notes '+hi.purple+' and '+hi.blue+')');
       if(name.green===name.blue||name.blue===name.purple||name.green===name.purple) bad.push('two tiers share one voice ('+name.green+', '+name.blue+', '+name.purple+')');
       // Two in a row: the second cuts the first, so they never stack into a smear.
       FK.currentTime+=3; t0=FK.currentTime;
       m0=MADE.length; _realBlip(lootVoice([kP])); made=MADE.slice(m0);
       FK.currentTime=t0+0.1; _realBlip(lootVoice([kB]));
       var cut=made.filter(function(n){ if(n.kind!=='gain'||!n.gain||!n.gain.ev) return false; return n.gain.ev.some(function(k){ return k.t>=t0+0.1-1e-6&&k.t<=t0+0.1+0.02&&((k.m==='tgt'&&k.v<=0.001&&k.c<=0.02)||((k.m==='lin'||k.m==='exp')&&k.v<=0.001)); }); });
       if(!cut.length) bad.push('a purple find 0.1 s before a blue one is not cut when the blue one starts: the two stack');
       else if(!made.filter(isSrc).every(function(n){ return cut.some(function(c){ return reach(n,c); }); })) bad.push('the cut on a new find leaves part of the last one ringing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ fakeOff(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'25.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
