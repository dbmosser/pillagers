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

if ($s.Contains("  {v:'26.91',what:")) { throw "check 26.91 is in the fixture already" }

SubRx @'
  {v:'26.90',what:
'@ @'
  {v:'26.91',what:'flow11, his yes to strongholds: the raid plans one or two fenced compounds on its seed, advertised on the maps, with a garrison, a gate that is breached by standing at it for 3 s (which opens it for good and sends wave two), a purple-or-better cache, a fence nobody crosses except through the open gate, and a chip when both waves are dead',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], SS, s, i, j, k, e, d, a, M, mk, cap=[], proto, oArc, sc, hit, t1, t2, m0, n, saw, ok, ang, gp, x0, y0, def2, tmp, needB='GATE '+'BREACHED', needC='STRONGHOLD '+'CLEARED', tagC='STRONGHOLD '+'CACHE', el;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof shLayout!=='function'||typeof flowTick!=='function') return 'there are no strongholds in this build';
       p=g.player; keys={};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); SS=g.flow.sh;
       if(!SS||!SS.sites||!SS.sites.length) return 'ONE: the raid planned '+(SS&&SS.sites?SS.sites.length:'no')+' strongholds';
       if(SS.sites.length>2) bad.push('ONE: '+SS.sites.length+' strongholds');
       s=SS.sites[0];
       for(i=0;i<SS.sites.length;i++){
         s=SS.sites[i];
         if(Math.hypot(s.x-p.x,s.y-p.y)<649) bad.push('ONE: stronghold '+i+' is '+Math.round(Math.hypot(s.x-p.x,s.y-p.y))+' from the drop');
         for(j=0;j<g.zones.length;j++) if(Math.hypot(s.x-g.zones[j].x,s.y-g.zones[j].y)<499) bad.push('ONE: stronghold '+i+' is within 500 of ring '+j);
         if(!isFinite(s.ga)) bad.push('ONE: stronghold '+i+' has no gate');
         if(s.def.length<4) bad.push('ONE: stronghold '+i+' has a garrison of '+s.def.length);
         for(j=0;j<s.def.length;j++){ e=s.def[j]; if(Math.hypot(e.x-s.x,e.y-s.y)>s.r||g.ents.indexOf(e)<0) bad.push('ONE: a defender is outside or not in the world'); }
         if(!s.cache||s.cache.loot.length<4||g.containers.indexOf(s.cache)<0) bad.push('ONE: stronghold '+i+' has no cache of four');
         else { n=0; for(j=0;j<s.cache.loot.length;j++) if((_RRANK[dispR(s.cache.loot[j])]||0)>=3) n++; if(n<s.cache.loot.length) bad.push('ONE: only '+n+' of '+s.cache.loot.length+' cache items are purple or better'); }
       }
       s=SS.sites[0];
       // TWO: the same seed lays out the same strongholds
       t1=shLayout(); t2=shLayout();
       if(JSON.stringify(t1)!==JSON.stringify(t2)||JSON.stringify(t1)!==JSON.stringify(SS.sites.map(function(q){ return {i:q.i,x:q.x,y:q.y,r:q.r,ga:q.ga,gw:q.gw,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null}; }))) bad.push('TWO: the same seed laid out different strongholds');
       // THREE: advertised on the maps
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='sh'&&M[i].pin) mk++;
       if(mk!==SS.sites.length) bad.push('THREE: '+mk+' of '+SS.sites.length+' strongholds are marks on the maps');
       // FOUR: the fence: on open ground away from the gate a player who crossed in is put back out, and a machine who crossed out is put back in
       ok=0;
       for(j=0;j<48&&!ok;j++){
         ang=j*0.1309; x0=Math.cos(ang); y0=Math.sin(ang);
         if(Math.abs(angDiff(ang,s.ga))<s.gw+0.3) continue;
         if(spotFree(g.map,s.x+x0*(s.r-30),s.y+y0*(s.r-30),12)&&spotFree(g.map,s.x+x0*(s.r+40),s.y+y0*(s.r+40),12)&&spotFree(g.map,s.x+x0*(s.r-21),s.y+y0*(s.r-21),10)&&spotFree(g.map,s.x+x0*(s.r+17),s.y+y0*(s.r+17),8)) ok=1;
       }
       if(!ok) return 'SKIP: staging: no open ground across the fence';
       p.shS=[0,0,0]; p.shS[s.i]=2; p.x=s.x+x0*(s.r-30); p.y=s.y+y0*(s.r-30);
       flowTick(0.1);
       d=Math.hypot(p.x-s.x,p.y-s.y);
       if(d<s.r+(p.r||11)) bad.push('FOUR: the player who crossed in stands '+Math.round(d)+' from the middle of a fence of '+s.r);
       e=mkCrawler(s.x+x0*(s.r+40),s.y+y0*(s.r+40)); e.shS=[0,0,0]; e.shS[s.i]=1; g.ents.push(e);
       flowTick(0.1);
       d=Math.hypot(e.x-s.x,e.y-s.y);
       if(d>s.r-(e.r||12)+0.5) bad.push('FOUR: a machine that crossed out stands '+Math.round(d)+' from the middle');
       // and the closed gate is a fence too
       gp=shGatePt(s); p.shS[s.i]=2; p.x=s.x+Math.cos(s.ga)*(s.r-30); p.y=s.y+Math.sin(s.ga)*(s.r-30);
       flowTick(0.1);
       if(Math.hypot(p.x-s.x,p.y-s.y)<s.r) bad.push('FOUR: the player walked through the closed gate');
       // FIVE: the breach: 3 s at the gate opens it, wave two comes, the cache is marked
       p.x=gp.x+Math.cos(s.ga)*30; p.y=gp.y+Math.sin(s.ga)*30; p.shS[s.i]=2; lines.length=0;
       for(i=0;i<8;i++) flowTick(0.25);
       if(s.open) bad.push('FIVE: the gate opened after only 2 s');
       if(!(s.prog>0.5&&s.prog<1)) bad.push('FIVE: the breach is at '+s.prog.toFixed(2)+' after 2 s');
       for(i=0;i<8;i++) flowTick(0.25);
       if(!s.open) bad.push('FIVE: the gate is shut after 4 s at it');
       def2=s.def2||[];
       if(def2.length<4) bad.push('FIVE: wave two is '+def2.length+' bodies');
       for(i=0;i<def2.length;i++) if(g.ents.indexOf(def2[i])<0) bad.push('FIVE: a body of wave two is not in the world');
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needB)>=0) saw=1;
       if(!saw) bad.push('FIVE: no GATE BREACHED callout');
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='loot'&&Math.abs(M[i].x-s.cache.x)<1&&String(M[i].txt)===tagC) mk++;
       if(!mk) bad.push('FIVE: the cache is not a mark once the gate is open');
       // SIX: through the open gate nobody is held
       p.x=s.x+Math.cos(s.ga)*(s.r-30); p.y=s.y+Math.sin(s.ga)*(s.r-30); tmp=p.x;
       flowTick(0.1);
       if(Math.abs(p.x-tmp)>0.01) bad.push('SIX: the player was held in the open gate');
       // SEVEN: the fence and the gate are drawn
       render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       sc=w2s(s.x,0,s.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-sc.x)<2&&Math.abs(cap[i][1]-sc.y)<2&&Math.abs(cap[i][2]-s.r*ZOOM())<1.5) hit++;
       if(hit<2) bad.push('SEVEN: the fence was drawn '+hit+' times ('+cap.length+' arcs)');
       // EIGHT: the Director never lands a pack in a stronghold
       if(arcadeWaveOk([],{x:s.x+900,y:s.y},s.x,s.y,0,5000)) bad.push('EIGHT: a pack may land in a stronghold');
       // NINE: clear both waves and the chip is paid, once
       m0=ARCADE.mine|0; lines.length=0;
       for(i=0;i<SS.sites.length;i++){ for(j=0;j<SS.sites[i].def.length;j++) SS.sites[i].def[j].hp=0; for(j=0;j<SS.sites[i].def2.length;j++) SS.sites[i].def2[j].hp=0; }
       flowTick(0.25);
       if(!s.clear||(ARCADE.mine|0)<m0+SH.chip) bad.push('NINE: the stronghold is '+(s.clear?'cleared':'not cleared')+' and the score moved '+((ARCADE.mine|0)-m0));
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needC)>=0) saw=1;
       if(!saw) bad.push('NINE: no STRONGHOLD CLEARED callout');
       m0=ARCADE.mine|0; flowTick(0.25); flowTick(0.25);
       if((ARCADE.mine|0)!==m0) bad.push('NINE: the chip was paid again');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
