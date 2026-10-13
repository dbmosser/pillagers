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

if ($s.Contains("  {v:'25.39',what:")) { throw "check 25.39 is in the fixture already" }

SubRx @'
  {v:'25.38',what:
'@ @'
  {v:'25.39',what:'his order (sounds for armour): a round on the plates rings them with a plate knock, the round that takes the last of the armour plays one heavy clack and a shatter, a bare hit plays neither, nothing under G.sim',
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
       if(typeof damagePlayer!=='function') return 'SKIP: no damagePlayer here';
       blip=function(t,d,pn,m){ PICKS.push(String(t)+(m?':'+m:'')); };
       function hit(arm,amt){ p.iv=0; p.hp=100; p.downed=false; p.armor=arm; PICKS=[]; FK.currentTime+=1; var m=MADE.length; damagePlayer(amt,'test','Test'); return heard(m); }
       // a round on the plates rings them
       L=hit(40,10);
       if(!(p.armor<40)) return 'SKIP: the plates took nothing here (no rig soak)';
       if(!has(PICKS,'hit:armor')) bad.push('a round on the plates does not ring them (blips '+(PICKS.join(',')||'none')+')');
       if(!has(L,'plateClack')) bad.push('a round on the plates plays no plate clack ('+(L.join(',')||'nothing')+')');
       if(has(PICKS,'hit:glass')) bad.push('a round that leaves armour plays the plate breaking');
       // the round that takes the last of it breaks the plate: a heavy clack and a shatter, once
       L=hit(2,30);
       if(p.armor>0) bad.push('the armour did not run out');
       if(!has(PICKS,'hit:glass')) bad.push('the plate breaking plays no shatter (blips '+(PICKS.join(',')||'none')+')');
       if(cnt(L,'plateClack')!==1) bad.push('the plate breaking plays '+cnt(L,'plateClack')+' plate clacks, wanted 1 ('+(L.join(',')||'nothing')+')');
       // no armour: a plain hit
       L=hit(0,5);
       if(has(PICKS,'hit:armor')||has(PICKS,'hit:glass')||L.length) bad.push('a hit with no armour still plays the plates ('+PICKS.join(',')+' '+L.join(',')+')');
       if(!has(PICKS,'hit')) bad.push('a hit with no armour lost its own hit sound');
       // never under G.sim
       G.sim=true; L=hit(40,10); G.sim=false;
       if(L.length||has(PICKS,'hit:armor')) bad.push('a plate hit under G.sim played '+L.join(',')+' '+PICKS.join(','));
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
  {v:'25.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
