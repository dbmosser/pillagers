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

if ($s.Contains("  {v:'27.82',what:")) { throw "check 27.82 is in the fixture already" }

SubRx @'
  {v:'27.81',what:
'@ @'
  {v:'27.82',what:'his order (add the sounds): the five raid events have sounds: each plays its own sting with its callout, a piece of debris roars as it falls and lands with its own blast (not the plain boom), the convoy, the coolant burst and the Overseer rampage play at the event start, the bounty paid has its own sting, and the stronghold gate breach and the explosive barrels (a chain blast sounds different) have blasts of their own',
   run:function(){
     if(!window.__endRaid||typeof arcadeDeploy!=='function'||typeof evLaunch!=='function'||typeof EVENTS!=='object'||typeof ARCADE!=='object'||typeof flowTick!=='function') return 'SKIP: no arcade raid events here';
     if(typeof SPK_EVWARN!=='object') return 'the sound pack is not in this build (no SPK_EVWARN)';
     var bad=[], g=null, p, rs=say, rb=blip, rx=sfx, own=false, heard=[], pk={}, ids=['debris','convoy','bounty','cool','rampage'], i, id, ev, E, pt, n, b, e1, e2, nb=-1, b1, b2, b3;
     function nm(kind){ return heard.filter(function(h){ return h[0]===kind; }).map(function(h){ return h[1]; }); }
     function stub(i2){ pk[i2]=EVENTS[i2].pick; EVENTS[i2].pick=function(q){ q.x=p.x+600; q.y=p.y; return true; }; }
     function unstub(i2){ if(pk[i2]) EVENTS[i2].pick=pk[i2]; }
     function launch(i2){ var q=null; stub(i2); try{ q=evLaunch(i2); } finally { unstub(i2); } return q; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; blip=function(t){ heard.push(['b',String(t)]); }; sfx=function(t,x,y,w){ heard.push(['s',String(t),x,y,w]); }; own=true;
       ARCADE.holdT=0; g.t=5; flowTick(0.1); E=g.flow&&g.flow.ev; if(!E||!E.plan) return 'SKIP: no event state';
       E.plan.length=0;
       // ONE: each event is announced with its own sting, once
       for(i=0;i<ids.length;i++){
         id=ids[i]; E.live.length=0; heard.length=0; ev=launch(id);
         if(!ev){ bad.push('ONE: evLaunch('+id+') made no event'); continue; }
         n=nm('b');
         if(n.length!==1||n[0]!==SPK_EVWARN[id]) bad.push('ONE: the '+id+' announcement played '+(n.join(',')||'nothing')+', not '+SPK_EVWARN[id]);
       }
       if(SPK_EVWARN.debris===SPK_EVWARN.convoy) bad.push('ONE: two events share a sting');
       // TWO: a piece of debris roars 2.2 s before it lands, once, and lands with its own blast and not the plain boom
       E.live.length=0; ev=launch('debris');
       if(!ev) bad.push('TWO: no debris event to stage');
       else {
         pt={x:p.x+400,y:p.y,at:5,done:0,i:0}; ev.d.pts=[pt]; ev.ph='live';
         heard.length=0; ev.lt=1; EVENTS.debris.tick(ev,0.1);
         if(nm('s').length) bad.push('TWO: a piece still 4 s out already made a sound ('+nm('s').join(',')+')');
         ev.lt=3; EVENTS.debris.tick(ev,0.1); EVENTS.debris.tick(ev,0.1);
         b=heard.filter(function(h){ return h[0]==='s'&&h[1]==='debrisFall'; });
         if(b.length!==1) bad.push('TWO: the falling roar played '+b.length+' times, not once');
         else if(b[0][2]!==pt.x||b[0][3]!==pt.y) bad.push('TWO: the falling roar was not placed under the piece');
         heard.length=0; ev.lt=5.1; EVENTS.debris.tick(ev,0.1);
         b=nm('s');
         if(b.indexOf('debrisLand')<0) bad.push('TWO: the landing made no debrisLand ('+b.join(',')+')');
         if(b.indexOf('boom')>=0) bad.push('TWO: the landing still plays the plain boom');
       }
       // THREE: the convoy, the coolant burst and the rampage play at their start
       E.live.length=0; ev=launch('convoy');
       if(!ev) bad.push('THREE: no convoy to stage'); else { heard.length=0; EVENTS.convoy.start(ev); b=heard.filter(function(h){ return h[0]==='s'&&h[1]==='convoyRoll'; }); if(b.length!==1||b[0][2]!==ev.x||b[0][3]!==ev.y) bad.push('THREE: the convoy start played '+nm('s').join(',')+' not one convoyRoll at its ring'); }
       E.live.length=0; ev=launch('cool');
       if(!ev) bad.push('THREE: no coolant event to stage'); else { heard.length=0; EVENTS.cool.start(ev); b=heard.filter(function(h){ return h[0]==='s'&&h[1]==='coolantBurst'; }); if(b.length!==1||b[0][2]!==ev.x||b[0][3]!==ev.y) bad.push('THREE: the coolant burst played '+nm('s').join(',')+' not one coolantBurst at its ring'); }
       E.live.length=0; ev=launch('rampage');
       if(!ev) bad.push('THREE: no rampage to stage');
       else {
         ev.d.b={hp:500,x:p.x+700,y:p.y+40,lairX:p.x+700,lairY:p.y+40,spd:40};
         heard.length=0; EVENTS.rampage.start(ev); b=heard.filter(function(h){ return h[0]==='s'&&h[1]==='rampageRoar'; });
         if(b.length!==1||b[0][2]!==ev.d.b.x||b[0][3]!==ev.d.b.y) bad.push('THREE: the rampage start played '+nm('s').join(',')+' not one rampageRoar where the Overseer stands');
       }
       // FOUR: the bounty paid plays its sting for a kill of the party, and nothing for a death nobody caused
       e1={d:{e:{hp:0,byPlayer:true,bySeat:0,finished:0}}}; heard.length=0; EVENTS.bounty.tick(e1,0.1);
       if(nm('b').indexOf('bountyPaid')<0) bad.push('FOUR: the bounty paid made no sting ('+nm('b').join(',')+')');
       e2={d:{e:{hp:0,byPlayer:false,bySeat:0,finished:0}}}; heard.length=0; EVENTS.bounty.tick(e2,0.1);
       if(nm('b').indexOf('bountyPaid')>=0) bad.push('FOUR: a death nobody caused paid a bounty sting');
       // FIVE: the linked window plays the same sting from the host word
       if(String(evNetTake).indexOf('SPK_EV'+'WARN')<0) bad.push('FIVE: the linked window plays no event sting (evNetTake)');
       // SIX: the stronghold gate blown in plays its own blast, not the plain boom
       heard.length=0; shBreachFx({gx:p.x+600,gy:p.y,gw:20,gh:20});
       b=heard.filter(function(h){ return h[0]==='s'; });
       if(b.length!==1||b[0][1]!=='gateBreach') bad.push('SIX: the gate breach played '+(b.map(function(h){ return h[1]; }).join(',')||'nothing')+', not one gateBreach');
       else if(Math.abs(b[0][2]-(p.x+610))>0.01||Math.abs(b[0][3]-(p.y+10))>0.01) bad.push('SIX: the gate breach was not placed at the gate');
       // SEVEN: a barrel blast, a barrel it lights (a chain blast), and a barrel lit by a round (a plain blast again)
       if(!g.brl) g.brl=[];
       nb=g.brl.length;
       b1={id:9001,x:p.x+700,y:p.y,hp:1,fuse:-1,by:-1,gone:0}; b2={id:9002,x:p.x+740,y:p.y,hp:1,fuse:-1,by:-1,gone:0}; b3={id:9003,x:p.x+1700,y:p.y,hp:1,fuse:-1,by:-1,gone:0};
       g.brl.push(b1,b2,b3);
       heard.length=0; brlBlast(b1);
       b=heard.filter(function(h){ return h[0]==='s'; }).map(function(h){ return h[1]; });
       if(b.join(',')!=='barrelBlast') bad.push('SEVEN: a barrel blast played '+(b.join(',')||'nothing')+', not one barrelBlast');
       if(!(b2.fuse>=0&&b2.chain===1)) bad.push('SEVEN: the barrel the blast lit is not marked as a chain ('+b2.fuse+', '+b2.chain+')');
       if(b3.chain||b3.fuse>=0) bad.push('SEVEN: a barrel 1,000 away was lit by the blast');
       heard.length=0; brlBlast(b2);
       b=heard.filter(function(h){ return h[0]==='s'; }).map(function(h){ return h[1]; });
       if(b.join(',')!=='barrelChain') bad.push('SEVEN: a chain blast played '+(b.join(',')||'nothing')+', not one barrelChain');
       brlLight(b3,-1,0.06); heard.length=0; brlBlast(b3);
       b=heard.filter(function(h){ return h[0]==='s'; }).map(function(h){ return h[1]; });
       if(b.join(',')!=='barrelBlast') bad.push('SEVEN: a barrel lit by a round played '+(b.join(',')||'nothing')+', not one barrelBlast');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own){ say=rs; blip=rb; sfx=rx; }
       try{ if(g&&g.brl&&nb>=0) g.brl.length=nb; }catch(_nb){}
       keys={};
       try{ for(i=0;i<ids.length;i++) unstub(ids[i]); }catch(_u){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
