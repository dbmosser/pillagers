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

if ($s.Contains("  {v:'26.95',what:")) { throw "check 26.95 is in the fixture already" }

SubRx @'
  {v:'26.94',what:
'@ @'
  {v:'26.95',what:'party4, his yes to the team combo (49): a kill inside 2 s and 52 m of the partner kill pays 40 times the chain once, a kill is in one pair only, a late or far kill pays nothing, the other window hears every kill, the 1 player demo is untouched, and a cyan ring drains at the cursor',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oFk=null, oSolo, oPost, sent=[], r, i, arcs=[], txts=[], proto, oArc, oFt, hit, q, n;
     function kill(dx){ var b={x:p.x+dx,y:p.y,blow:'g',blowT:g.t}; ARCADE.streak=null; if(g.sty) g.sty.kt.length=0; return arcadeKill('crawler',0,false,b.x,b.y,b); }
     function mate(dx,lk,tn){ return arcadeOnMsg({t:'arckill',pair:NET.pair,x:p.x+dx,y:p.y,lk:lk||0,tn:tn||0}); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof teamKill!=='function'||typeof arcadeTeamTake!=='function'||typeof teamDraw!=='function') return 'there is no team combo in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0;
       if(typeof flowKill==='function'){ oFk=flowKill; flowKill=function(){}; }
       oSolo=ARCADE.solo; ARCADE.solo=0; ARCADE.team=null; ARCADE.mk=null;
       oPost=netSamePost; netSamePost=function(m){ sent.push(m); return true; };
       // ONE: the partner kill is heard; a kill of ours inside the window and the distance pairs with it and pays 40
       r=mate(100); if(r!=='arckill') bad.push('ONE: the partner kill word answered "'+r+'"');
       ARCADE.mine=0; kill(60);
       if(ARCADE.mine!==50+TEAM.pts) bad.push('ONE: a kill paired with the partner kill paid '+ARCADE.mine+', not '+(50+TEAM.pts));
       if(!(ARCADE.team&&ARCADE.team.n===1)) bad.push('ONE: the first pair made a chain of '+(ARCADE.team&&ARCADE.team.n));
       // TWO: the partner kill is used up
       ARCADE.mine=0; kill(60);
       if(ARCADE.mine!==50) bad.push('TWO: a second kill of ours paired with a partner kill already paired ('+ARCADE.mine+')');
       // THREE: another pair inside two seconds makes the chain two
       mate(100); ARCADE.mine=0; kill(60);
       if(ARCADE.mine!==50+2*TEAM.pts) bad.push('THREE: the second pair paid '+ARCADE.mine+', not '+(50+2*TEAM.pts));
       if(!(ARCADE.team&&ARCADE.team.n===2)) bad.push('THREE: the chain is '+(ARCADE.team&&ARCADE.team.n)+', not 2');
       // FOUR: too far, and too late
       ARCADE.team=null; mate(900); ARCADE.mine=0; kill(0);
       if(ARCADE.mine!==50) bad.push('FOUR: a kill 90 m from the partner kill paid '+ARCADE.mine);
       ARCADE.mk={x:p.x+50,y:p.y,at:Date.now()-2500,used:0}; ARCADE.mine=0; kill(60);
       if(ARCADE.mine!==50) bad.push('FOUR: a kill 2.5 s after the partner kill paid '+ARCADE.mine);
       // FIVE: the other window hears every kill, and whether it paired
       sent.length=0; ARCADE.team=null; mate(100); kill(60); kill(60);
       q=sent.filter(function(m){ return m&&m.t==='arckill'; });
       if(q.length!==2) bad.push('FIVE: '+q.length+' kill words were sent for two kills');
       else if(!(q[0].lk===1&&q[0].tn===1&&q[1].lk===0)) bad.push('FIVE: the kill words said '+JSON.stringify(q.map(function(m){ return [m.lk,m.tn]; })));
       // SIX: a partner word that paired is kept as used, and its chain is taken
       arcadeOnMsg({t:'arckill',pair:NET.pair,x:p.x+100,y:p.y,lk:1,tn:3});
       if(!(ARCADE.team&&ARCADE.team.n===3)) bad.push('SIX: the chain from the partner window was not taken');
       ARCADE.mine=0; kill(60); if(ARCADE.mine!==50) bad.push('SIX: a kill paired with a partner kill that was itself the second of a pair ('+ARCADE.mine+')');
       // SEVEN: the 1 player demo
       ARCADE.solo=1; ARCADE.team=null; sent.length=0;
       r=mate(100); if(r!=='ignored') bad.push('SEVEN: the 1 player demo took a partner kill word ('+r+')');
       ARCADE.mine=0; kill(60);
       if(ARCADE.mine!==50) bad.push('SEVEN: the 1 player demo paid a team combo ('+ARCADE.mine+')');
       if(sent.some(function(m){ return m&&m.t==='arckill'; })) bad.push('SEVEN: the 1 player demo sent a kill word');
       ARCADE.solo=0;
       // EIGHT: the ring drains at the cursor, and is gone with no chain
       ARCADE.team={n:2,at:Date.now()-1000};
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ teamDraw(ctx,p,640,360); } finally { proto.arc=oArc; proto.fillText=oFt; }
       hit=0; for(i=0;i<arcs.length;i++) if(Math.abs(arcs[i][0]-640)<0.5&&Math.abs(arcs[i][1]-360)<0.5&&arcs[i][2]>=27*Math.max(1,hudRes())*xhSize()) hit++;
       if(hit<2) bad.push('EIGHT: the team ring was not drawn at the cursor, outside the combo ring ('+arcs.length+' arcs)');
       else { n=arcs[arcs.length-1]; if(Math.abs((n[4]-n[3])/6.2832-0.5)>0.08) bad.push('EIGHT: the ring half spent shows '+((n[4]-n[3])/6.2832).toFixed(2)); }
       if(txts.join('|').indexOf('TEAM'+' x2')<0) bad.push('EIGHT: the ring does not say TEAM x2');
       arcs.length=0; ARCADE.team=null;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ teamDraw(ctx,p,640,360); } finally { proto.arc=oArc; }
       if(arcs.length) bad.push('EIGHT: a team ring was drawn with no chain');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(oPost) netSamePost=oPost; }catch(_np){}
       try{ if(oFk) flowKill=oFk; }catch(_fk){}
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.solo=oSolo; ARCADE.team=null; ARCADE.mk=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(g) g.pwr=null; if(g) g.sty=null; }catch(_gp){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
