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

if ($s.Contains("  {v:'25.23',what:")) { throw "check 25.23 is in the fixture already" }

SubRx @'
  {v:'25.22',what:
'@ @'
  {v:'25.23',what:'his order (sounds for bandaging): a Bandage tears, wraps through its wind-up and lands with a tape rip; a Medkit snaps, zips, rummages and lands with the injector; no menu chirp; a cleared wind-up plays nothing more; nothing under G.sim',
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
       function tick(sec){ var n=Math.round(sec/0.05), i; for(i=0;i<n;i++){ FK.currentTime+=0.05; tickPrepSlot(p,'prep',0.05); } }
       if(typeof useMedical!=='function'||typeof tickPrepSlot!=='function') return 'SKIP: no heal verb here';
       // a Bandage: the tear as you start, the wrap through the wind-up, a tape pat as it lands, and no menu chirp
       p.prep=null; p.prepA=null; p.healQ=0; p.hp=40; G.bag=['bandage']; PICKS=[];
       m0=MADE.length;
       if(!useMedical()||!p.prep) return 'SKIP: the Bandage would not start here';
       L=heard(m0);
       if(!has(L,'bandageTear')) bad.push('a Bandage starts with no tear ('+(L.join(',')||'nothing')+')');
       m0=MADE.length; tick(1.4); L=heard(m0);
       if(!p.prep) bad.push('the Bandage landed before 1.4 s');
       if(cnt(L,'bandageWrap')<2) bad.push('the Bandage wind-up wraps '+cnt(L,'bandageWrap')+' times, wanted 2 or more ('+(L.join(',')||'nothing')+')');
       m0=MADE.length; tick(0.3); L=heard(m0);
       if(p.prep) bad.push('the Bandage did not land by 1.7 s');
       else if(!L.length) bad.push('the Bandage lands in silence');
       if(has(PICKS,'pick')) bad.push('the Bandage still plays the menu chirp');
       // a Medkit: the case snaps and zips open, a rummage, the injector as it lands
       p.prep=null; p.healQ=0; p.hp=20; G.bag=['medkit']; PICKS=[]; FK.currentTime+=1;
       m0=MADE.length;
       if(!useMedical()||!p.prep) bad.push('the Medkit would not start');
       else{
         L=heard(m0);
         if(!has(L,'medkitSnap')||!has(L,'medkitZip')) bad.push('a Medkit does not open with a snap and a zip ('+(L.join(',')||'nothing')+')');
         m0=MADE.length; tick(0.9); L=heard(m0);
         if(!has(L,'rummage')) bad.push('no rummage in the Medkit wind-up ('+(L.join(',')||'nothing')+')');
         m0=MADE.length; tick(0.7); L=heard(m0);
         if(p.prep) bad.push('the Medkit did not land by 1.6 s');
         else if(!has(L,'injector')) bad.push('the Medkit lands with no injector ('+(L.join(',')||'nothing')+')');
         if(has(PICKS,'pick')) bad.push('the Medkit still plays the menu chirp');
       }
       // cancelled (going down clears the wind-up): nothing more plays
       p.prep=null; p.healQ=0; p.hp=20; G.bag=['bandage']; PICKS=[]; FK.currentTime+=1;
       if(useMedical()&&p.prep){
         tick(0.2); p.prep=null;
         m0=MADE.length; tick(2); L=heard(m0);
         if(L.length) bad.push('a cancelled Bandage still plays '+L.join(','));
       } else bad.push('the second Bandage would not start');
       // never under G.sim
       p.prep=null; p.healQ=0; p.hp=20; G.bag=['bandage']; FK.currentTime+=1; G.sim=true;
       m0=MADE.length; useMedical(); tick(2); L=heard(m0); G.sim=false;
       if(L.length) bad.push('a Bandage under G.sim played '+L.join(','));
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
  {v:'25.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
