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

if ($s.Contains("  {v:'26.84',what:")) { throw "check 26.84 is in the fixture already" }

SubRx @'
  {v:'26.83',what:
'@ @'
  {v:'26.84',what:'party1, his yes to style scoring (37): a combo ring drains at the cursor while a chain is live; a long shot, a melee kill, a grenade double, a burst of three and thirty untouched seconds each pay a bonus and a medal plate; a plain kill pays only the kill',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oFk=null, hp0, mine0, proto, oArc, oFt, arcs=[], txts=[], i, q, S, ex, ang, ok, ox, oy, src, d, x0, y0, z, xs;
     function reset(){ ARCADE.streak=null; ARCADE.mine=0; S=g.sty; if(S){ S.kt.length=0; S.gT=-9; S.gN=0; } }
     function kill(blow,dx,age){ var b={x:p.x+dx,y:p.y,blow:blow,blowT:g.t-(age||0)}; return arcadeKill('crawler',0,false,b.x,b.y,b); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof styleKill!=='function'||typeof styleTick!=='function'||typeof styleDraw!=='function') return 'there is no style scoring in this build';
       p=g.player; keys={}; say=function(){}; own=true; hp0=p.hp; ARCADE.holdT=0;
       if(typeof flowKill==='function'){ oFk=flowKill; flowKill=function(){}; }
       // ONE: a plain kill at close range pays the kill and nothing else
       reset(); kill('g',100); if(ARCADE.mine!==50) bad.push('ONE: a close round kill paid '+ARCADE.mine+', not 50');
       // TWO: a long shot, a swing, a stale swing
       reset(); kill('g',600); if(ARCADE.mine!==50+STY.long) bad.push('TWO: a kill 60 m away paid '+ARCADE.mine+', not '+(50+STY.long));
       reset(); kill('m',60); if(ARCADE.mine!==50+STY.melee) bad.push('TWO: a melee kill paid '+ARCADE.mine+', not '+(50+STY.melee));
       reset(); kill('m',60,5); if(ARCADE.mine!==50) bad.push('TWO: a swing from 5 s ago still counted as a melee kill ('+ARCADE.mine+')');
       reset(); kill('m',600); if(ARCADE.mine!==50+STY.melee) bad.push('TWO: a melee kill far off paid '+ARCADE.mine+' (a swing is not a long shot)');
       // THREE: two kills in one blast, and three in a burst
       reset(); kill('x',200); kill('x',210);
       if(ARCADE.mine!==50+100+STY.gren) bad.push('THREE: two kills in one blast paid '+ARCADE.mine+', not '+(150+STY.gren));
       reset(); kill('g',100); kill('g',110); kill('g',120);
       if(ARCADE.mine!==50*(arcadeStreakX(1)+arcadeStreakX(2)+arcadeStreakX(3))+STY.multi) bad.push('THREE: three kills in a burst paid '+ARCADE.mine);
       // FOUR: thirty untouched seconds
       g.sty=null; styleTick(p,0.016); S=g.sty;
       S.calmAt=g.t+1; S.calmK=2; g.t+=1.5; ARCADE.mine=0; styleTick(p,0.016);
       if(ARCADE.mine!==STY.calm) bad.push('FOUR: the calm bonus paid '+ARCADE.mine+', not '+STY.calm);
       styleTick(p,0.016); if(ARCADE.mine!==STY.calm) bad.push('FOUR: the calm bonus paid twice in a row');
       p.hp-=10; styleTick(p,0.016);
       if(!(S.calmAt>g.t+STY.calmT-0.5)) bad.push('FOUR: a hit did not start the thirty seconds again');
       S.calmK=1; ARCADE.mine=0; g.t+=STY.calmT-0.2; styleTick(p,0.016);
       if(ARCADE.mine!==0) bad.push('FOUR: the calm bonus paid 0.2 s early');
       g.t+=0.4; styleTick(p,0.016);
       if(ARCADE.mine!==STY.calm) bad.push('FOUR: the calm bonus did not pay again after another quiet thirty seconds ('+ARCADE.mine+')');
       S.calmK=0; S.calmAt=g.t+1; g.t+=1.5; ARCADE.mine=0; styleTick(p,0.016);
       if(ARCADE.mine!==0) bad.push('FOUR: thirty quiet seconds with no kill paid a calm bonus');
       // FIVE: the ring and a medal plate at the cursor
       reset(); g.sty.pops.length=0; g.sty.pops.push({txt:'LONG'+' SHOT',pts:STY.long,t:g.t});
       ARCADE.streak={n:3,t:g.t-2};
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ styleDraw(ctx,p,640,360); } finally { proto.arc=oArc; proto.fillText=oFt; }
       z=Math.max(1,hudRes()); xs=xhSize(); ok=0;
       for(i=0;i<arcs.length;i++) if(Math.abs(arcs[i][0]-640)<0.5&&Math.abs(arcs[i][1]-360)<0.5&&arcs[i][2]>=19*z*xs) ok++;
       if(ok<2) bad.push('FIVE: the combo ring was not drawn at the cursor, outside the magazine ring ('+arcs.length+' arcs)');
       else { q=arcs[arcs.length-1]; if(Math.abs((q[4]-q[3])/6.2832-0.5)>0.06) bad.push('FIVE: the ring a chain half spent shows '+((q[4]-q[3])/6.2832).toFixed(2)+' of its sweep, not a half'); }
       if(txts.join('|').indexOf('LONG'+' SHOT')<0) bad.push('FIVE: the medal plate did not draw its name');
       if(txts.join('|').indexOf('x3')<0) bad.push('FIVE: the ring does not show its multiplier');
       arcs.length=0; txts.length=0; ARCADE.streak=null; g.sty.pops.length=0;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ styleDraw(ctx,p,640,360); } finally { proto.arc=oArc; }
       if(arcs.length) bad.push('FIVE: a ring was drawn with no chain and no medal ('+arcs.length+' arcs)');
       reset(); g.sty.pops.push({txt:'MULTI-KILL',pts:1,t:g.t}); g.t+=5; styleTick(p,0.016);
       if(g.sty.pops.length) bad.push('FIVE: a spent medal plate was kept');
       // SIX: the last blow is marked where it lands (the swing, the blast and the round)
       src=[].slice.call(document.scripts).map(function(s){ return s.textContent; }).join('\n');
       if(src.indexOf('_me.blo'+"w='m'")<0) bad.push('SIX: a swing does not mark its body');
       if(src.indexOf('e.blo'+"w='x'")<0) bad.push('SIX: a blast does not mark its body');
       if(src.indexOf('en.blo'+"w='g'")<0) bad.push('SIX: a round does not mark its body');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(oFk) flowKill=oFk; }catch(_fk){}
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={};
       try{ if(p&&hp0!==undefined) p.hp=hp0; }catch(_hp){}
       try{ if(g) g.sty=null; }catch(_gs){}
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
