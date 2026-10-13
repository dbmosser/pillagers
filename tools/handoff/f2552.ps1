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

if ($s.Contains("  {v:'25.52',what:")) { throw "check 25.52 is in the fixture already" }

SubRx @'
  {v:'25.51',what:
'@ @'
  {v:'25.52',what:'his order 2026-10-12 (good reload noises): every gun class reloads in recorded steps on its own reload clock (a clip the frame R is pressed, one between 60 and 90 percent, one on the frame the rounds go in only when the gun was empty), a shotgun pushes one shell per shell taken, a faster reload plays the same steps sooner, a reload cut by a swap plays nothing more, and nothing plays under G.sim',
   run:function(){
     if(typeof SFXBANK!=='object'||!SFXBANK||typeof foley!=='function'||typeof SFXB!=='object'||typeof sfxbWav!=='function') return 'SKIP: no foley bank here (v25.20)';
     if(typeof OfflineAudioContext!=='function') return 'SKIP: no OfflineAudioContext in this browser';
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof sndBus!=='function'||typeof tickReload!=='function'||typeof updatePlayer!=='function'||typeof swapGuns!=='function') return 'SKIP: this fixture cannot run a raid';
     var CL=['pistol','smg','rifle','dmr','lmg','shotgun','sniper','magnum','lance'], RACK={pistol:1,smg:1,rifle:1,dmr:1,lmg:1,shotgun:1}, i;
     for(i=0;i<CL.length;i++) if(!WEAPONS[CL[i]]||!(WEAPONS[CL[i]].mag>0)||!(WEAPONS[CL[i]].reload>0)) return 'SKIP: no '+CL[i]+' with a magazine here';
     var bad=[], OFF=new OfflineAudioContext(1,22050,22050);
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
       createConvolver:function(){ var o=N('conv'); o.buffer=null; return o; },
       createBuffer:function(ch,l,sr){ return OFF.createBuffer(ch,l,sr); },
       decodeAudioData:function(){ return Promise.reject(new Error('not here')); }};
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=(typeof AMB!=='undefined')?AMB:null, kSim=null, kFX=FXS;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined, kOn=hasNet?NET.on:undefined;
     var kB={buf:SFXB.buf,ac:SFXB.ac,nb:SFXB.nb,n:SFXB.n,at:SFXB.at,last:SFXB.last}, on=false, g=null, p=null, keep=null, kEnts=null, kKeys=keys, kMd=mouse.down, R={}, TT={}, c, f, q, n, e;
     function cl(id,sc){ var o={}, k; for(k in WEAPONS[id]) o[k]=WEAPONS[id][k]; o.jam=0; if(sc) o.reload=Math.round(o.reload*sc); return o; }
     function role(s){ for(var k in SFXB.buf) if(SFXB.buf[k]===s.buffer) return k; return ''; }
     function grab(m0,fm,fr,out){ MADE.slice(m0).forEach(function(x){ var r; if(x.kind!=='src'||!x.started) return; r=role(x); if(r) out.push({r:r,fm:fm,f:fr,ms:fm+Math.max(0,(x.started[0]||5)-5)*1000}); }); }
     // one staged reload of a fresh copy of gun ID holding AMMO rounds: R pressed for one frame, then 50 ms frames past its end.
     // o.fast scales the reload time; o.cut swaps guns at that fraction of the reload.
     function run(id,ammo,o){
       var w=cl(id,o&&o.fast), ev=[], ms=0, m0, tot, a0, done=-1, cutAt=-1, j;
       o=o||{};
       keys={}; mouse.down=false; g.ents=[]; p.iv=99; p.downed=false; p.dying=false; p.roll=0; p.cooking=false; p.trigYield=false; p.fired=false; p.jam=0; p.reloading=0;
       g.paused=false; g.bagOpen=false; g.mapOpen=false;
       p.wep=w; p.ammo=ammo; p.reserve=w.mag*3; p.sec=cl('pistol'); p.secAmmo=p.sec.mag; p.secIssued=true; p.swapped=false;
       SFXB.at={};
       m0=MADE.length; keys['KeyR']=true; updatePlayer(0.016); keys={};
       tot=p.reloading;
       if(!(tot>0)) return {err:'R on the '+id+' with '+ammo+' of '+w.mag+' rounds started no reload'};
       grab(m0,0,0,ev);
       for(j=0;j<600;j++){
         if(o.cut!==undefined&&cutAt<0&&p.reloading>0&&1-p.reloading/tot>=o.cut){ if(!swapGuns()) return {err:'the gun swap was refused'}; cutAt=ms; }
         a0=p.ammo; m0=MADE.length; updatePlayer(0.05); ms+=50;
         if(done<0&&p.ammo>a0) done=ms;
         grab(m0,ms,1-Math.max(0,p.reloading)/tot,ev);
         if((done>=0&&ms>=done+200)||(cutAt>=0&&ms>=cutAt+tot+200)) break;
       }
       return {id:id,tot:tot,ev:ev,done:done,cut:cutAt,take:Math.min(w.mag-ammo,w.mag*3)};
     }
     function at(r,lo,hi){ return r.ev.filter(function(x){ return x.fm>=lo&&x.fm<=hi; }); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim';
       p=g.player; kSim=g.sim; kEnts=g.ents;
       keep={wep:p.wep,sec:p.sec,ammo:p.ammo,secAmmo:p.secAmmo,secIssued:p.secIssued,reserve:p.reserve,reloading:p.reloading,swapped:p.swapped,iv:p.iv,fired:p.fired,jam:p.jam,x:p.x,y:p.y};
       AC=FK; BUS=null; REV=null; if(typeof AMB!=='undefined') AMB=null; if(typeof SND!=='undefined') SND=null; G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; NET.on=false; } on=true;
       SFXB.ac=null; SFXB.at={};
       // ONE: every class, empty and with rounds left
       for(i=0;i<CL.length;i++){
         c=CL[i];
         R[c]=run(c,0); if(R[c].err) return 'SKIP: staging: '+R[c].err;
         n=WEAPONS[c].mag; TT[c]=run(c,Math.max(1,n-3)); if(TT[c].err) return 'SKIP: staging: '+TT[c].err;
         [R[c],TT[c]].forEach(function(r,k){
           var nm=(k?'a reload with rounds left':'an empty reload')+' of the '+WEAPONS[c].name, mid, end;
           if(r.done<0){ bad.push(nm+' never put the rounds in'); return; }
           if(!r.ev.length){ bad.push(nm+' plays no recorded sound'); return; }
           if(!at(r,0,0).length) bad.push(nm+' plays nothing the frame R is pressed');
           mid=r.ev.filter(function(x){ return x.f>=0.6&&x.f<=0.9; });
           if(c!=='shotgun'&&!mid.length) bad.push(nm+' seats nothing between 60 and 90 percent of its '+r.tot+' ms ('+r.ev.map(function(x){ return x.r+'@'+Math.round(100*x.f); }).join(' ')+')');
           end=at(r,r.done,r.done);
           if(!k&&!end.length) bad.push(nm+' plays nothing on the frame the rounds go in');
           if(k&&RACK[c]&&end.length) bad.push(nm+' still racks on the frame the rounds go in ('+end.map(function(x){ return x.r; }).join(',')+'), a round was chambered');
           if(r.ev.some(function(x){ return x.fm>r.done; })) bad.push(nm+' plays after the rounds are in');
         });
       }
       // TWO: a shotgun pushes one shell per shell it takes, spread over the reload
       [R.shotgun,TT.shotgun].forEach(function(r,k){
         var sh=r.ev.filter(function(x){ return x.r==='shellIn'; }), want=Math.min(WEAPONS.shotgun.mag-(k?Math.max(1,WEAPONS.shotgun.mag-3):0),WEAPONS.shotgun.mag*3);
         if(sh.length!==want) bad.push((k?'a shotgun with rounds left':'an empty shotgun')+' pushes '+sh.length+' shells for the '+want+' it takes');
         else if(sh.length>1&&!(sh[0].f<0.3&&sh[sh.length-1].f>0.6)) bad.push('the shotgun shells are not spread over the reload ('+sh.map(function(x){ return Math.round(100*x.f); }).join(',')+' percent)');
       });
       // THREE: a faster reload plays the same steps sooner
       f=run('rifle',0,{fast:0.5}); if(f.err) return 'SKIP: staging: '+f.err;
       q=R.rifle.ev.filter(function(x){ return x.f>=0.6&&x.f<=0.9; })[0];
       e=f.ev.filter(function(x){ return x.f>=0.6&&x.f<=0.9; })[0];
       if(!q||!e) bad.push('the half-time rifle reload has no magazine in between 60 and 90 percent');
       else if(!(e.ms<q.ms*0.65)) bad.push('the half-time rifle reload seats its magazine at '+e.ms+' ms, the full one at '+q.ms+' ms');
       if(f.done<0||!at(f,f.done,f.done).length||!(f.done<=f.tot+60)) bad.push('the half-time rifle reload does not rack on the frame its rounds go in ('+f.done+' of '+f.tot+' ms)');
       // FOUR: cut short by a swap at 30 percent, nothing more plays
       e=run('rifle',0,{cut:0.3}); if(e.err) return 'SKIP: staging: '+e.err;
       if(e.cut<0) return bad.length?bad.join('; ')+' (then SKIP: the swap did not happen)':'SKIP: staging: the swap did not happen';
       {
         if(!e.ev.some(function(x){ return x.fm<=e.cut; })) bad.push('the rifle reload made no sound before the swap');
         q=e.ev.filter(function(x){ return x.fm>e.cut; });
         if(q.length) bad.push('a rifle reload cut by a swap at '+e.cut+' ms still plays '+q.map(function(x){ return x.r+'@'+x.fm; }).join(' '));
       }
       // FIVE: never under G.sim
       G.sim=true; p.wep=cl('rifle'); p.ammo=0; p.reserve=75; p.reloading=2000; n=MADE.length;
       if(typeof reloadFoley==='function') reloadFoley(p);
       for(i=0;i<50&&p.reloading>0;i++) tickReload(0.05);
       G.sim=false;
       if(MADE.slice(n).some(function(x){ return x.kind==='src'&&role(x); })) bad.push('a reload under G.sim plays a recorded sound');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof rlfxStop==='function') rlfxStop(); }catch(_r){}
       try{ if(on){ AC=kAC; BUS=kBUS; REV=kREV; if(typeof AMB!=='undefined') AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; NET.on=kOn; } } }catch(_f){}
       try{ SFXB.buf=kB.buf; SFXB.ac=kB.ac; SFXB.nb=kB.nb; SFXB.n=kB.n; SFXB.at=kB.at; SFXB.last=kB.last; FXS=kFX; }catch(_k){}
       try{ if(p&&keep){ for(var kk in keep) p[kk]=keep[kk]; } if(g&&kEnts) g.ents=kEnts; }catch(_p){}
       keys=kKeys; mouse.down=kMd; for(var kq in keys) keys[kq]=false;
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
