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

if ($s.Contains("  {v:'25.61',what:")) { throw "check 25.61 is in the fixture already" }

SubRx @'
  {v:'25.60',what:
'@ @'
  {v:'25.61',what:'his order 2026-10-12, robot deaths: a staged kill of each machine kind (Sentry, Crawler, Crier, Listener, Pillbox, Warden, the Overseer, Bulwark, Howler) plays one death sound named for that kind, once, where it fell; on the stand-in context each kind builds its own layered graph (three or more voices) on the impact bus, every graph different, the small machines done by 1.25 s and the Overseer the longest, under 2.6 s',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__ents||typeof _realBlip!=='function'||typeof sndBus!=='function') return 'SKIP: this fixture cannot stage a kill or trace a sound';
     var MK={sentry:(typeof mkSentry==='function')?mkSentry:null,crawler:(typeof mkCrawler==='function')?mkCrawler:null,
       snitch:(typeof mkSnitch==='function')?mkSnitch:null,listener:(typeof mkListener==='function')?mkListener:null,
       choir:(typeof mkChoir==='function')?mkChoir:null,warden:(typeof mkWarden==='function')?mkWarden:null,
       bulwark:(typeof mkBulwark==='function')?mkBulwark:null,howler:(typeof mkHowler==='function')?mkHowler:null};
     var KS=['sentry','crawler','snitch','listener','choir','warden','overseer','bulwark','howler'];
     var bad=[], heard=[], kSfx=sfx, kSay=say, g, p, i, j, k, e, mk, got, sig={}, done=[], dsnd={}, lens={}, kSim=null, faked=false;
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.value=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.value=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
     var MADE=[];
     function N(kn,ps){ var o={kind:kn,outs:[]}; o.connect=function(t){ if(t) o.outs.push(t); return t; }; o.disconnect=function(){ o.outs=[]; }; o.start=function(x){ o.at=x; }; o.stop=function(x){ o.end=x; }; (ps||[]).forEach(function(n){ o[n]=P(n==='gain'?1:0); }); MADE.push(o); return o; }
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
     function reach(n,t){ var q=[n],seen=[],z=0,x,y; while(z<q.length&&z<6000){ x=q[z++]; if(x===t) return true; if(!x||seen.indexOf(x)>=0) continue; seen.push(x); for(y=0;y<(x.outs||[]).length;y++) q.push(x.outs[y]); } return false; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=AMB, kDuck=(typeof SND_DUCK!=='undefined')?SND_DUCK:null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ faked=true; AC=FK; BUS=null; REV=null; AMB=null; if(typeof SND!=='undefined') SND=null; if(kDuck) SND_DUCK={}; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ if(!faked) return; faked=false; AC=kAC; BUS=kBUS; REV=kREV; AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(kDuck) SND_DUCK=kDuck; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       sfx=function(t,x,y,w){ heard.push({t:String(t),x:x,y:y,w:String(w===undefined?'':w)}); };
       say=function(){};
       for(i=0;i<KS.length;i++){
         k=KS[i]; mk=MK[k==='overseer'?'warden':k];
         if(!mk){ bad.push('this build has no '+k); continue; }
         e=mk(p.x+150,p.y+30);
         if(k==='overseer'){ e.boss=1; e.name=BOSS_NAME; e.r=44; }
         e.state='patrol'; e.hp=0; e.byPlayer=false;
         g.ents.push(e); heard.length=0; p.iv=5; p.hp=100;
         __ents(0.016); __ents(0.016); __ents(0.016);
         if(g.ents.indexOf(e)>=0){ bad.push('a staged '+k+' at 0 health did not die'); g.ents.splice(g.ents.indexOf(e),1); continue; }
         got=heard.filter(function(h){ return h.x===e.x&&h.y===e.y; });
         if(!got.length){ bad.push('a '+k+' dies in silence'); continue; }
         if(got.length!==1) bad.push('a '+k+' death plays '+got.length+' sounds where it fell, not one');
         sig[k]=got[0].t+'/'+got[0].w; done.push(k);
       }
       for(i=0;i<done.length;i++) for(j=i+1;j<done.length;j++) if(sig[done[i]]===sig[done[j]]) bad.push('a '+done[i]+' and a '+done[j]+' die with the same sound ('+sig[done[i]]+')');
       if(done.length){
         kSim=G.sim; fakeOn();
         var imp=sndBus('imp'), m0, made, src, ln, s, w;
         for(i=0;i<done.length;i++){
           k=done[i]; w=sig[k].split('/'); m0=MADE.length; _realBlip(w[0],100,0,w[1]); made=MADE.slice(m0);
           src=made.filter(function(x){ return (x.kind==='osc'||x.kind==='src')&&reach(x,imp); });
           if(src.length<3){ bad.push('a '+k+' death plays '+src.length+' voices on the impact bus, not a layered sound'); continue; }
           ln=0; for(j=0;j<src.length;j++) ln=Math.max(ln,(isFinite(src[j].end)?src[j].end:(src[j].at||0))-FK.currentTime);
           lens[k]=ln;
           s=made.map(function(x){ return x.kind+(x.type||'')+(x.frequency?Math.round(x.frequency.value):'')+(x.buffer?x.buffer.length:''); }).join(',');
           for(j in dsnd) if(dsnd[j]===s) bad.push('a '+k+' and a '+j+' build the same sound');
           dsnd[k]=s;
           if(k!=='overseer'&&ln>1.25) bad.push('a '+k+' death runs '+ln.toFixed(2)+' s, over 1.25');
         }
         if(lens.overseer!==undefined){
           if(lens.overseer>2.6) bad.push('the Overseer death runs '+lens.overseer.toFixed(2)+' s, over 2.6');
           for(k in lens) if(k!=='overseer'&&lens[k]>=lens.overseer) bad.push('a '+k+' death is as long as the Overseer death');
         }
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ try{ fakeOff(); }catch(_f){} sfx=kSfx; say=kSay; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
