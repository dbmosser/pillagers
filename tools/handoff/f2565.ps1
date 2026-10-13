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

if ($s.Contains("  {v:'25.65',what:")) { throw "check 25.65 is in the fixture already" }

SubRx @'
  {v:'25.64',what:
'@ @'
  {v:'25.65',what:'his orders (siren too often, damage must not throw it, crawler alarm quieter): the lock-on siren starts only for a machine that sees him now, inside 500, after 0.6 s, not again for 5 s; a chase without sight or damage alone is silent; a crawler lock-on is half a sentry one and the crawler shout alarm is half level',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tickMachSiren!=='function'||typeof MSIREN!=='object'||typeof mkSentry!=='function'||typeof mkCrawler!=='function'||typeof _realBlip!=='function') return 'SKIP: this fixture cannot stage the siren';
     var bad=[], MADE=[], faked=false, g=null, p=null, E0=null, kT=0, kSim=null, kHp=0, kIv=0, kPause=false, kMS={}, kSay=say, S, C, i, k, st, lvS, lvC, got, src;
     function P(v){ var q={value:v}; q.setValueAtTime=function(x){ q.value=x; return q; }; q.setTargetAtTime=function(x){ q.value=x; return q; }; q.linearRampToValueAtTime=function(x){ q.last=x; return q; }; q.exponentialRampToValueAtTime=function(x){ q.last=x; return q; }; q.cancelScheduledValues=function(){ return q; }; q.cancelAndHoldAtTime=function(){ return q; }; return q; }
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
     var hasNet=(typeof NET==='object'&&!!NET), kAC=AC, kBUS=BUS, kREV=REV, kSND=(typeof SND!=='undefined')?SND:null, kAMB=(typeof AMB!=='undefined')?AMB:null, kDuck=(typeof SND_DUCK!=='undefined')?SND_DUCK:null;
     var ownST=hasNet&&Object.prototype.hasOwnProperty.call(NET,'specTick'), kST=hasNet?NET.specTick:undefined, kSame=hasNet?NET.same:undefined;
     function fakeOn(){ faked=true; AC=FK; BUS=null; REV=null; if(typeof AMB!=='undefined') AMB=null; if(typeof SND!=='undefined') SND=null; if(kDuck) SND_DUCK={}; if(G) G.sim=false; if(hasNet){ NET.specTick=0; NET.same=''; } }
     function fakeOff(){ if(!faked) return; faked=false; AC=kAC; BUS=kBUS; REV=kREV; if(typeof AMB!=='undefined') AMB=kAMB; if(typeof SND!=='undefined') SND=kSND; if(kDuck) SND_DUCK=kDuck; if(G&&kSim!==null) G.sim=kSim; if(hasNet){ if(ownST) NET.specTick=kST; else delete NET.specTick; NET.same=kSame; } }
     // sec seconds in 0.05 steps; seeing stamps the sight flag the AI would; returns how many times the siren started in it
     function run(sec,seeing){ var j, s=0, was=MSIREN.on, n=Math.round(sec/0.05); for(j=0;j<n;j++){ g.t+=0.05; if(seeing) for(k=0;k<g.ents.length;k++) g.ents[k].sirenSeeT=g.t; tickMachSiren(0.05); if(MSIREN.on&&!was) s++; was=MSIREN.on; } return s; }
     function mk(f,dx){ var e=f(p.x+dx,p.y); e.state='chase'; e.alert=2.4; e.hp=Math.max(e.hp,10); delete e.sirenSeeT; return e; }
     function glance(sec){ return sec; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents) return 'SKIP: no live raid';
       kT=g.t; kHp=p.hp; kIv=p.iv; kPause=!!g.paused; E0=g.ents; kSim=g.sim; for(k in MSIREN) kMS[k]=MSIREN[k];
       g.paused=false; p.iv=99; fakeOn(); say=function(){}; MSIREN.v=null; MSIREN.on=0; MSIREN.n=0; MSIREN.lvl=0;
       // A. chasing the last place it knew, never seeing him: silent
       S=mk(mkSentry,300); g.ents=[S];
       st=run(3,false); if(st||MSIREN.on) bad.push('a sentry chasing him without seeing him started the siren');
       // B. sees him: not before 0.6 s, then once
       st=run(0.5,true); if(st||MSIREN.on) bad.push('the siren started before the machine held the lock for 0.6 s');
       st+=run(1.5,true); if(st!==1||!MSIREN.on) bad.push('a machine that sees him for two seconds started the siren '+st+' times (on '+MSIREN.on+'), not once');
       // C. it stops; sight again soon is inside the 5 s cooldown; after the cooldown it starts again
       st=run(1,false); if(MSIREN.on) bad.push('the siren plays on after the machine stopped seeing him');
       st=run(2,true); if(st) bad.push('the siren started again within 5 s of stopping');
       run(1,false); st=run(6,false); st=run(1.5,true); if(st!==1) bad.push('the siren did not start again once the 5 s cooldown had passed ('+st+')');
       run(1,false);
       // D. range: 600 away is out, 480 is in
       S=mk(mkSentry,600); g.ents=[S]; st=run(2,true); if(st||MSIREN.on) bad.push('a machine 600 away that sees him started the siren (range is 500)');
       S=mk(mkSentry,480); g.ents=[S]; st=run(2,true); if(st!==1) bad.push('a machine 480 away that sees him did not start the siren once ('+st+')');
       run(1,false);
       // E. taking damage alone: a machine chasing the noise, none seeing him, a hit lands: silent
       S=mk(mkSentry,300); g.ents=[S]; run(1,false);
       try{ p.iv=0; damagePlayer(4,'stray','Stray round',p.x+60,p.y); }catch(_dm){}
       p.iv=99; st=run(3,false); if(st||MSIREN.on) bad.push('taking damage with no machine seeing him started the siren');
       // F. a crawler-only lock-on is half a sentry-only one
       run(1,false); S=mk(mkSentry,300); g.ents=[S]; run(1.5,true); lvS=MSIREN.lvl; run(1,false);
       C=mk(mkCrawler,300); g.ents=[C]; run(1.5,true); lvC=MSIREN.lvl; run(1,false);
       if(!(lvS>0)||!(lvC>0)) bad.push('a lock-on level was silent (sentry '+lvS+', crawler '+lvC+')');
       else if(Math.abs(lvC/lvS-0.5)>0.02) bad.push('a crawler-only lock-on is '+(lvC/lvS).toFixed(2)+' of a sentry-only one, not half');
       // G. the crawler shout alarm is half level at the source, the others are not
       i=MADE.length; _realBlip('alarm',undefined,undefined,'crawler'); got=MADE.slice(i).filter(function(x){ return x.kind==='osc'&&x.type==='sawtooth'&&x.outs.length&&x.outs[0].gain; })[0];
       lvC=got?got.outs[0].gain.value:null;
       i=MADE.length; _realBlip('alarm'); got=MADE.slice(i).filter(function(x){ return x.kind==='osc'&&x.type==='sawtooth'&&x.outs.length&&x.outs[0].gain; })[0];
       lvS=got?got.outs[0].gain.value:null;
       if(lvC===null||lvS===null) bad.push('the alarm built no voice'); else if(Math.abs(lvC*2-lvS)>0.0002||Math.abs(lvS-0.06)>0.0002) bad.push('the alarm levels are '+lvC+' (crawler) and '+lvS+' (other), not .03 and .06');
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('');
       if(src.indexOf("sfx('al"+"arm',e.x,e.y,(e.kind==='craw"+"ler')?'crawler':undefined)")<0) bad.push('the crawler shout does not ask for the half level alarm');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=kSay; }catch(_s){}
       try{ for(k in kMS) MSIREN[k]=kMS[k]; }catch(_m){}
       fakeOff();
       try{ var g2=__state(); if(g2){ if(E0) g2.ents=E0; g2.t=kT; g2.paused=kPause; if(g2.player){ g2.player.hp=kHp; g2.player.iv=kIv; } if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
