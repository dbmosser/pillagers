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

if ($s.Contains("  {v:'27.46',what:")) { throw "check 27.46 is in the fixture already" }

SubRx @'
  {v:'27.45',what:
'@ @'
  {v:'27.46',what:'sh2, his order (the stronghold is a mess, you cannot stick a circle in the middle of existing buildings): a stronghold is a REAL building: the compound is the building, its doorway is a shutter wall that blocks bodies and sight until breached, every other doorway is barricaded, the shell cannot be broken, no circle is drawn, the label says HOLD TO BREACH at the gate only, the breach takes the shutter out, and player 2 builds the same walls from the host word',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof flowTick!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p=null, SS=null, s=null, m=null, b=null, i, j, k, w, n, gp, gw=null, nb=0, nWall=0, D, rs=say, own=false, lines=[], cap=[], txts=[], proto, oArc, oFt, big=0, row, PS={sites:null}, HS=null, NK={}, h={seat:0,state:'in'}, oSF=netSendFast, oS=netSend, staged=false, st, sx, sy;
     function shWalls(){ var q, o=[]; for(q=0;q<m.walls.length;q++) if(m.walls[q].sh!==undefined) o.push(m.walls[q]); return o; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof shLayout!=='function'||typeof shWallDraw!=='function'||typeof shNetTake!=='function') return 'ONE: strongholds are not buildings in this build (no shWallDraw)';
       p=g.player; keys={}; m=g.map; say=function(q,kd,o){ lines.push(String(q)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=4; flowTick(0.1); SS=g.flow.sh;
       if(!SS||!SS.sites||!SS.sites.length) return 'ONE: the raid planned no stronghold';
       // ONE: it is a real building: the compound is the building, the gate is its own doorway, on ground that is open and reachable, at the old distances
       for(i=0;i<SS.sites.length;i++){
         s=SS.sites[i]; b=m.buildings[s.bi];
         if(s.kind!=='b'||!b) { bad.push('ONE: stronghold '+i+' is not a building (kind '+s.kind+')'); continue; }
         if(Math.abs(s.x-b.x)>0.5||Math.abs(s.y-b.y)>0.5||Math.abs(s.w-b.w)>0.5||Math.abs(s.h-b.h)>0.5) bad.push('ONE: stronghold '+i+' is not the building it stands on');
         if(s.r!==undefined||s.ga!==undefined) bad.push('ONE: stronghold '+i+' still has a circle (r or ga)');
         D=shDoorsOf(m,b); n=0; for(j=0;j<D.length;j++) if(Math.abs(D[j].x-s.gx)<1&&Math.abs(D[j].y-s.gy)<1&&Math.abs(D[j].w-s.gw)<1) n++;
         if(n!==1) bad.push('ONE: the gate of stronghold '+i+' is not one of the building own doorways ('+n+' of '+D.length+')');
         if(Math.hypot(s.x+s.w/2-p.x,s.y+s.h/2-p.y)<649) bad.push('ONE: stronghold '+i+' is only '+Math.round(Math.hypot(s.x+s.w/2-p.x,s.y+s.h/2-p.y))+' from the drop');
         for(j=0;j<g.zones.length;j++) if(Math.hypot(s.x+s.w/2-g.zones[j].x,s.y+s.h/2-g.zones[j].y)<499) bad.push('ONE: stronghold '+i+' is within 500 of ring '+j);
         if(s.def.length<4) bad.push('ONE: stronghold '+i+' has a garrison of '+s.def.length);
         for(j=0;j<s.def.length;j++) if(!(s.def[j].x>b.x&&s.def[j].x<b.x+b.w&&s.def[j].y>b.y&&s.def[j].y<b.y+b.h)||g.ents.indexOf(s.def[j])<0) { bad.push('ONE: a defender of stronghold '+i+' is outside the building or not in the world'); break; }
         if(!s.cache||s.cache.loot.length<4||g.containers.indexOf(s.cache)<0||!(s.cache.x>b.x&&s.cache.x<b.x+b.w&&s.cache.y>b.y&&s.cache.y<b.y+b.h)) bad.push('ONE: stronghold '+i+' has no cache of four inside the building');
         else { n=0; for(j=0;j<s.cache.loot.length;j++) if((_RRANK[dispR(s.cache.loot[j])]||0)>=3) n++; if(n<s.cache.loot.length) bad.push('ONE: only '+n+' of '+s.cache.loot.length+' cache items are purple or better'); }
       }
       s=SS.sites[0]; b=m.buildings[s.bi]; if(!b) return 'ONE: no building under the first stronghold';
       // TWO: the walls: a shutter in the gate, a barricade in every other outer doorway, the shell unbreakable, all real walls (collision and sight)
       D=shDoorsOf(m,b); gp=shGatePt(s);
       for(j=0;j<m.walls.length;j++){ w=m.walls[j]; if(w.sgate&&w.sh===s.i) gw=w; }
       if(!gw) bad.push('TWO: no shutter wall in the gate');
       else {
         if(spotFree(m,gp.x,gp.y,2)) bad.push('TWO: the gate is open ground (collision does not stop a body there)');
         if(losClear(gp.x-s.nx*40,gp.y-s.ny*40,gp.x+s.nx*40,gp.y+s.ny*40,m.segs)) bad.push('TWO: a line through the shutter is clear (it does not block sight)');
         if(!gw.noDes) bad.push('TWO: the shutter can be broken');
       }
       for(j=0;j<D.length;j++){ if(Math.abs(D[j].x-s.gx)<1&&Math.abs(D[j].y-s.gy)<1) continue; nb++; if(spotFree(m,D[j].x+D[j].w/2,D[j].y+D[j].h/2,2)) bad.push('TWO: another doorway of the building is open ground'); }
       if(shWalls().length!==1+nb) bad.push('TWO: the stronghold added '+shWalls().length+' walls, not a shutter and '+nb+' barricades');
       n=0; k=0;
       for(j=0;j<m.walls.length;j++){ w=m.walls[j]; if(w.sh!==undefined||w.ib!==undefined||w.tree||w.furn||w.wreck||w.ruin||w.door||w.lockWall||w.ledge) continue;
         if(w.x>=b.x-1&&w.y>=b.y-1&&w.x+w.w<=b.x+b.w+1&&w.y+w.h<=b.y+b.h+1&&(w.x<b.x+18||w.y<b.y+18||w.x+w.w>b.x+b.w-18||w.y+w.h>b.y+b.h-18)){ k++; if(w.noDes) n++; } }
       if(!k||n!==k) bad.push('TWO: '+(k-n)+' of '+k+' shell walls can still be broken');
       // a charge cannot break the shell
       for(j=0;j<m.walls.length;j++){ w=m.walls[j]; if(w.noDes&&w.x>=b.x-1&&w.x+w.w<=b.x+b.w+1&&w.y>=b.y-1&&w.y+w.h<=b.y+b.h+1&&w.sh===undefined){ if(typeof wallHp==='function'&&wallHp(w)!==null) bad.push('TWO: a shell wall has hit points'); break; } }
       // THREE: no circle anywhere: the old fence functions and words are gone, and nothing big is drawn round the compound
       if(typeof shKeep==='function') bad.push('THREE: the circular fence code is still in the game (shKeep)');
       p.x=gp.x+s.nx*120; p.y=gp.y+s.ny*120; p.iv=99; g.ents=g.ents.filter(function(q){ return !q||q.shi===s.i||dist(q,p)>1500; });
       render2D(0); cap.length=0; txts.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; proto.fillText=oFt; }
       for(i=0;i<cap.length;i++) if(cap[i].length>=5&&cap[i][2]>=150*ZOOM()) big++;
       if(big) bad.push('THREE: '+big+' big circles were drawn by the flow ('+cap.length+' arcs)');
       // FOUR: the label at the gate: HOLD TO BREACH, never STAND AT THE GATE
       if(txts.indexOf('HOLD TO'+' BREACH')<0) bad.push('FOUR: the label HOLD TO BREACH is not drawn at the gate (said: '+txts.slice(0,6).join(' / ')+')');
       if(txts.indexOf('STAND AT THE'+' GATE')>=0) bad.push('FOUR: the old label STAND AT THE GATE is still drawn');
       // FIVE: the breach: holding at the gate fills the ring, the shutter comes out, wave two comes from inside
       p.x=gp.x+s.nx*40; p.y=gp.y+s.ny*40; lines.length=0; st=g.ents.length;
       for(i=0;i<8;i++){ g.t+=0.25; flowTick(0.25); }
       if(s.open) bad.push('FIVE: the gate opened after only 2 s');
       if(!(s.prog>0.5&&s.prog<1)) bad.push('FIVE: the breach is at '+s.prog.toFixed(2)+' after 2 s');
       for(i=0;i<8;i++){ g.t+=0.25; flowTick(0.25); }
       if(!s.open) bad.push('FIVE: the gate is shut after 4 s at it');
       if(m.walls.indexOf(gw)>=0||s.gateWall) bad.push('FIVE: the shutter is still a wall after the breach');
       else if(!spotFree(m,gp.x,gp.y,2)) bad.push('FIVE: the gate is not open ground after the breach');
       else if(!losClear(gp.x-s.nx*40,gp.y-s.ny*40,gp.x+s.nx*40,gp.y+s.ny*40,m.segs)) bad.push('FIVE: the way in is not clear for sight after the breach');
       if((s.def2||[]).length<4) bad.push('FIVE: wave two is '+(s.def2||[]).length+' bodies');
       for(i=0;i<(s.def2||[]).length;i++){ w=s.def2[i]; if(!(w.x>b.x&&w.x<b.x+b.w&&w.y>b.y&&w.y<b.y+b.h)) { bad.push('FIVE: a body of wave two is outside the building'); break; } }
       n=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf('GATE '+'BREACHED')>=0) n=1;
       if(!n) bad.push('FIVE: no GATE BREACHED callout');
       if(!(G.shake>0)) bad.push('FIVE: the breach shook nothing');
       // SIX: player 2 builds the same walls from the host word: put the host walls back as a plain map, take the word, count the walls and the gate
       s=SS.sites[0]; HS=SS.sites; row=shNetOut();
       if(!row||!row.length||row[0].length<16) bad.push('SIX: the host word does not carry the compound (rows '+JSON.stringify(row)+')');
       else {
         for(i=0;i<m.walls.length;) if(m.walls[i].sh!==undefined) m.walls.splice(i,1); else i++;
         rebuildGeometry();
         for(k in NET) NK[k]=NET[k]; staged=true;
         NET.on=true; NET.max=4; NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; NET.up=[];
         row[0][13]=0; row[0][14]=0; row[0][15]=0;
         g.flow.sh=PS; shNetTake(row);
         n=shWalls().length;
         if(!(n>=1)||!PS.sites||!PS.sites.length||!PS.sites[0].gateWall) bad.push('SIX: player 2 built '+n+' walls and '+(PS.sites&&PS.sites[0]&&PS.sites[0].gateWall?'a':'no')+' shutter from the word');
         else {
           gp=shGatePt(PS.sites[0]);
           if(spotFree(m,gp.x,gp.y,2)) bad.push('SIX: the gate player 2 built is open ground');
           row[0][13]=1; row[0][14]=1; lines.length=0; shNetTake(row);
           if(PS.sites[0].gateWall||!spotFree(m,gp.x,gp.y,2)) bad.push('SIX: the gate stayed shut for player 2 after the host breached it');
           if(!lines.some(function(q){ return /^GATE BREACHED/.test(q); })) bad.push('SIX: player 2 was not told GATE BREACHED');
         }
         g.flow.sh=SS;
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       try{ if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; } }catch(_n){}
       keys={};
       try{ if(g&&HS) g.flow.sh=SS; }catch(_sh){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
