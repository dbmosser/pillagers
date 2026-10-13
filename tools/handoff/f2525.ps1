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

if ($s.Contains("  {v:'25.25',what:")) { throw "check 25.25 is in the fixture already" }

SubRx @'
  {v:'25.24',what:
'@ @'
  {v:'25.25',what:'his order (sounds for the use items): the pin clicks on a cook and a quick throw (no old clank), the throw whooshes, a frag lands with a knock, a smoke hisses, a tripwire latches and beeps twice only as it arms, nothing under G.sim',
   run:function(){
     if(typeof SFXBANK!=='object'||!SFXBANK||typeof foley!=='function'||typeof SFXB!=='object') return 'SKIP: no foley bank on this build';
     if(typeof OfflineAudioContext!=='function') return 'SKIP: no OfflineAudioContext in this browser';
     if(!window.__deploy||!window.__endRaid||typeof sndBus!=='function') return 'SKIP: this fixture cannot run a raid';
     var bad=[], OFF=new OfflineAudioContext(1,22050,22050), MADE=[], PICKS=[];
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
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
     // the bank clips started since m0 (a BufferSource that was started on a bank buffer), by role
     function heard(m0){ return MADE.slice(m0).filter(function(x){ return x.kind==='src'&&x.started&&x.buffer; }).map(function(x){ for(var k in SFXB.buf) if(SFXB.buf[k]===x.buffer) return k; return '?'; }); }
     function has(L,r){ return L.indexOf(r)>=0; }
     function cnt(L,r){ return L.filter(function(x){ return x===r; }).length; }
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=(typeof AMB!=='undefined')?AMB:null, kSim=null, kFX=FXS, kBlip=blip;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined, kOn=hasNet?NET.on:undefined;
     var kB={buf:SFXB.buf,ac:SFXB.ac,nb:SFXB.nb,n:SFXB.n,at:SFXB.at,last:SFXB.last}, on=false, g=null, p=null, kBag=null, kHp=0, kArm=0, m0, L;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=g.sim; kBag=G.bag.slice(); kHp=p.hp; kArm=p.armor;
       AC=FK; BUS=null; REV=null; if(typeof AMB!=='undefined') AMB=null; if(typeof SND!=='undefined') SND=null; G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; NET.on=false; } on=true;
       SFXB.ac=null; SFXB.at={};
       blip=function(t){ PICKS.push(t); };
       if(typeof startCook!=='function'||typeof activateThrow!=='function'||typeof tickTrips!=='function'||typeof THROWKEYS==='undefined') return 'SKIP: no throws here';
       var kPouch=JSON.parse(JSON.stringify(G.pouch||{})), kTsel=G.tsel, kTrips=(G.trips||[]).slice(), kSm=(G.smokes||[]).length, kFr=(G.frags||[]).length, kTh=(G.throws||[]).length;
       try{
         function nx(){ FK.currentTime+=1; PICKS=[]; return MADE.length; }
         p.cooking=0; p.roll=0; p.downed=false; G.pouch.frag=3; G.tsel=THROWKEYS.indexOf('frag');
         // the cook: the pin comes out, not the old clank
         m0=nx(); if(!startCook()) return 'SKIP: the cook would not start here';
         L=heard(m0);
         if(!has(L,'pinClick')) bad.push('pulling the pin plays no pin click ('+(L.join(',')||'nothing')+')');
         if(has(PICKS,'clank')) bad.push('pulling the pin still plays the old clank');
         // the release: an arm whoosh
         m0=nx(); releaseCook(); L=heard(m0);
         if(!has(L,'bandageWrap')) bad.push('the throw plays no whoosh ('+(L.join(',')||'nothing')+')');
         // a quick throw pulls the pin too
         m0=nx(); doThrow(); L=heard(m0);
         if(!has(L,'pinClick')||!has(L,'bandageWrap')) bad.push('a quick throw plays no pin and whoosh ('+(L.join(',')||'nothing')+')');
         // the frag lands with a knock, the smoke hisses where it lands
         m0=nx(); activateThrow({kind:'frag',tx:p.x+100,ty:p.y,sx:p.x,sy:p.y,cook:0}); L=heard(m0);
         if(!has(L,'lmgClack')) bad.push('a frag lands with no knock ('+(L.join(',')||'nothing')+')');
         if(G.frags) G.frags.length=Math.min(G.frags.length,kFr);
         m0=nx(); activateThrow({kind:'smoke',tx:p.x+100,ty:p.y,sx:p.x,sy:p.y,cook:0}); L=heard(m0);
         if(!has(L,'injector')) bad.push('a smoke deploys with no hiss ('+(L.join(',')||'nothing')+')');
         // the tripwire: a latch as it strings, two beeps as it arms (not before)
         m0=nx(); activateThrow({kind:'trip',tx:p.x+90,ty:p.y,sx:p.x,sy:p.y,cook:0}); L=heard(m0);
         if(!has(L,'boltLatch')) bad.push('a tripwire strings with no latch ('+(L.join(',')||'nothing')+')');
         m0=nx(); tickTrips(0.3); L=heard(m0);
         if(has(L,'keyBeep')) bad.push('the tripwire beeps before it is armed');
         m0=nx(); tickTrips(0.4); L=heard(m0);
         if(cnt(L,'keyBeep')!==2) bad.push('the tripwire arms with '+cnt(L,'keyBeep')+' beeps, wanted 2 ('+(L.join(',')||'nothing')+')');
         m0=nx(); tickTrips(0.5); L=heard(m0);
         if(L.length) bad.push('an armed tripwire keeps playing '+L.join(','));
         // never under G.sim
         G.pouch.frag=3; m0=nx(); G.sim=true; if(startCook()) releaseCook(); L=heard(m0); G.sim=false;
         if(L.length) bad.push('a throw under G.sim played '+L.join(','));
       } finally {
         p.cooking=0; G.pouch=kPouch; G.tsel=kTsel; G.trips=kTrips; if(G.smokes) G.smokes.length=Math.min(G.smokes.length,kSm); if(G.frags) G.frags.length=Math.min(G.frags.length,kFr); if(G.throws) G.throws.length=Math.min(G.throws.length,kTh);
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ blip=kBlip; }catch(_b){}
       try{ if(on){ AC=kAC; BUS=kBUS; REV=kREV; if(typeof AMB!=='undefined') AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; NET.on=kOn; } } }catch(_f){}
       try{ SFXB.buf=kB.buf; SFXB.ac=kB.ac; SFXB.nb=kB.nb; SFXB.n=kB.n; SFXB.at=kB.at; SFXB.last=kB.last; FXS=kFX; }catch(_k){}
       try{ if(p){ p.prep=null; p.prepA=null; p.healQ=0; if(kBag) G.bag=kBag; p.hp=kHp; p.armor=kArm; p.downed=false; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
