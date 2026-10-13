$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# HOLD ALT FOR THE RAID STATUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['KeyV','emotes'],['KeyO','order your hire']];
'@ @'
['KeyV','emotes'],['KeyO','order your hire'],['AltLeft','raid status (hold)']];
'@

SubRx @'
['WORLD',['KeyE','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyO']],
'@ @'
['WORLD',['KeyE','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyO','AltLeft']],
'@

SubRx @'
' ping &nbsp; '+s('F1')+' controls &nbsp; '
'@ @'
' ping &nbsp; '+s('AltLeft')+' raid status (hold) &nbsp; '+s('F1')+' controls &nbsp; '
'@

SubRx @'
function raidKey(code,repeat,ev){
'@ @'
function raidKey(code,repeat,ev){
  if(ev&&(code==='AltLeft'||keys['AltLeft'])) ev.preventDefault();   // v25.xx (altstatus): Alt is the browser menu key; while it is the status key its press, and every key pressed with it, stay in the game
'@

SubRx @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false;
'@ @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false; if(keyRemap(e.code)==='AltLeft'&&state==='raid') e.preventDefault(); /* v25.xx (altstatus): and its release, or the browser takes the menu focus */
'@

SubRx @'
NET.upOut[s]=(st==='in')?0:(NET.upSeed>>>0);
'@ @'
NET.upOut[s]=(st==='in')?0:(NET.upSeed>>>0); if(!NET.upHow) NET.upHow={}; NET.upHow[s]=(st==='in')?'':String(m.how||'').slice(0,12);   // v25.xx (altstatus): how his run ended, for the raid status
'@

SubRx @'
// Wide enough for the value column, and names TRUNCATED to a measured budget
'@ @'
RSTAT.rows=rows.slice(); RSTAT.live=live; RSTAT.out=out; RSTAT.dead=dead;   // v25.xx (altstatus): the board as ranked, for the raid status
  // Wide enough for the value column, and names TRUNCATED to a measured budget
'@

SubRx @'
if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@ @'
if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
  RSTAT.on=0; if(keys['AltLeft']&&!G.mapOpen&&!G.bagOpen&&!G.trade){ try{ raidStatusDraw(); }catch(_rsd){} } RSTAT.rows=null;   // v25.xx (altstatus): hold ALT, the raid status over everything else
'@

SubRx @'
function drawCrierMarkers(){
'@ @'
// v25.xx (altstatus), HIS ORDER 2026-10-13 ("hold alt for that raid status, not tab"): THE RAID STATUS, WHILE ALT IS HELD. One graphite plate
// (hudPanel: the cut corner and the amber tick), HUD face, upper centre, in two columns: the CURRENT PILLAGERS board as it is ranked (the
// first eight, YOU first; a living pillager reads OUT HERE whatever he is doing, as the board has said since v8.08, and only EXTRACTED and DEAD
// are outcomes), and a stack of tiles: the score (CAREER SCORE, or the DEMO SCORE with the team split; the haul in a plain raid) with your
// credits, the raid clock (red in the last minute), the extraction (the state of the ring called, and the nearest open one), and each
// teammate (health and armour, DOWN with the count, EXTRACTED, DEAD or gone). The arcade shows no pillagers board, so this shows none either.
// Nothing is drawn while the map, the backpack or a stall is up. RSTAT.lines keeps what was written, for the check.
var RSTAT={on:0,rows:null,live:0,out:0,dead:0,lines:[]};
function rsText(s,x,y,col,font,al){
  ctx.font=font; ctx.fillStyle=col; ctx.textAlign=al||'left';
  RSTAT.lines.push(String(s));
  hudText(s,x,y);
}
function raidStatusDraw(){
  if(!G||!G.player||!ctx) return false;
  var k=Math.max(1,(typeof hudRes==='function')?hudRes():1), U=function(n){ return LH(n)*k; };
  var p=G.player, arc=!!G.arcade, car=!!G.career, rows=RSTAT.rows, hasR=!!(rows&&rows.length&&!arc), T=[], i, z, d, bd=1e9, nz=null, tz=0, t, hv=0, R, g, nm, how, w, col, stt, val, bud, yy, more, ss;
  var fM=hudFS(TYPE.micro), fH=hudFS(TYPE.head), fT=hudFS(TYPE.title);
  RSTAT.lines=[];
  // the score
  if(arc&&typeof ARCADE==='object'&&ARCADE){
    var so=!!ARCADE.solo, mi=Math.max(0,ARCADE.mine|0), ma=so?0:Math.max(0,ARCADE.mate|0);
    T.push({l:so?'DEMO SCORE':'DEMO TEAM SCORE',v:arcadeCr(mi+ma),c:'#e8eef2',s:so?'':('YOU '+arcadeCr(mi)+'   '+(ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(ma)),big:1,rail:'#f5b73b'});
  } else if(car){
    T.push({l:'CAREER SCORE',v:arcadeCr((G.cs&&G.cs.s)|0),c:'#e8eef2',s:'CREDITS '+arcadeCr(P.credits|0),big:1,rail:'#f5b73b'});
  } else {
    for(i=0;i<G.bag.length;i++) hv+=ival(G.bag[i]);
    T.push({l:'CARRIED',v:'$'+hv.toLocaleString(),c:'#e8eef2',s:'CREDITS '+arcadeCr(P.credits|0),big:1,rail:'#f5b73b'});
  }
  // the clock
  if(raidClockOn()){ t=Math.ceil(Math.max(0,+G.timeLeft||0)); T.push({l:'RAID CLOCK',v:fmtClock(t),c:(t<=CLOCK_RED)?'#ff5a4a':'#e8eef2',s:'ELAPSED '+fmtClock(elapsed()),big:1,rail:(t<=CLOCK_RED)?'#e5482f':'#4a5257'}); }
  else T.push({l:'RAID TIME',v:fmtClock(elapsed()),c:'#e8eef2',s:'NO CLOCK',big:1,rail:'#4a5257'});
  // the extraction
  z=G.active;
  for(i=0;i<G.zones.length;i++){ if(G.zones[i].open===false) continue; tz++; d=dist(p,G.zones[i]); if(d<bd){ bd=d; nz=G.zones[i]; } }
  T.push({l:'EXTRACTION',v:z?zoneBadge(z):(tz?'NONE CALLED':'ALL CLOSED'),c:z?HUDC.extract:(tz?'#cdd6dd':HUDC.danger),s:nz?('NEAREST '+extLetter(nz)+'  '+metres(bd)+'M '+compass8(nz.x-p.x,nz.y-p.y)):'',rail:z?HUDC.extract:'#4a5257'});
  // the teammates
  if(typeof NET==='object'&&NET&&NET.on&&NET.roster){
    for(i=0;i<NET.roster.length;i++){
      R=NET.roster[i]; if(!R||R.seat===NET.seat) continue;
      g=(NET.up&&NET.up[R.seat])?NET.up[R.seat]:null;
      nm=String(R.name||'TEAMMATE').toUpperCase(); if(nm.length>14) nm=nm.slice(0,13)+'\u2026';
      if(g&&netUpShown(g)){
        if(g.dn) T.push({l:'TEAMMATE  '+nm,v:'DOWN'+(g.dt>0?'  '+Math.ceil(g.dt)+'S':''),c:HUDC.danger,s:'',rail:HUDC.danger});
        else T.push({l:'TEAMMATE  '+nm,v:'HEALTH '+Math.round(g.hp)+' / '+Math.round(g.mh),c:HUDC.ally,s:(g.ar>0?'ARMOUR '+Math.round(g.ar):''),rail:HUDC.ally});
      } else if(NET.upOut&&NET.upOut[R.seat]){
        how=(NET.upHow&&NET.upHow[R.seat])||'';
        T.push({l:'TEAMMATE  '+nm,v:how==='extract'?'EXTRACTED':(how==='dead'?'DEAD':'LEFT THE RAID'),c:how==='extract'?'#7fc4a0':'#6b7783',s:'',rail:how==='extract'?'#7fc4a0':'#4a5257'});
      }
    }
  }
  // the plate
  var pad=U(14), colW=U(236), tileW=U(250), gap=U(16), headH=U(34), rowH=U(17), nR=hasR?Math.min(rows.length,8):0;
  more=hasR?(rows.length-nR):0;
  var extra=(hasR&&(more>0||RSTAT.out+RSTAT.dead>0))?1:0, boardH=hasR?(U(24)+nR*rowH+extra*rowH):0, tilesH=-U(6);
  for(i=0;i<T.length;i++) tilesH+=(T[i].big?U(56):U(46))+U(6);
  var PW=Math.min(pad*2+tileW+(hasR?colW+gap:0),W-U(16)), PH=headH+Math.max(boardH,tilesH)+pad, x0=Math.round((W-PW)/2), y0=Math.round(Math.max(U(8),H*0.07)), bx=x0+pad, by=y0+headH;
  ctx.save(); ctx.textBaseline='alphabetic';
  hudPanel(x0,y0,PW,PH,0.93);
  rsText('RAID STATUS',bx,y0+U(23),'#f5b73b',fH);
  rsText((arc?'DEMO   ':(car?'CAREER   ':''))+'HOLD '+keyName(keysOf('AltLeft')),x0+PW-pad,y0+U(22),'#8a96a1',fM,'right');
  ctx.fillStyle='rgba(74,82,87,.9)'; ctx.fillRect(bx,y0+headH-U(4),PW-pad*2,Math.max(1,Math.round(k)));
  // the board
  if(hasR){
    rsText('CURRENT PILLAGERS  '+RSTAT.live,bx,by+U(14),'#ffc04a',fM);
    yy=by+U(14)+U(18);
    for(i=0;i<nR;i++){
      w=rows[i];
      col=(w.st==='EXTRACTED')?'#7fc4a0':((w.st==='DEAD')?'#6b7783':(w.me?'#ffc04a':(w.el?'#d08ce8':(w.gh?'#7cc4ff':'#cdd6dd'))));
      stt=w.me?String(w.st):((w.st==='EXTRACTED')?'EXTRACTED':((w.st==='DEAD')?'DEAD':'OUT HERE'));
      val=(w.val>0)?('$'+w.val.toLocaleString()):'-';
      ctx.font=fM; bud=colW-U(76)-ctx.measureText(val).width-U(14);
      nm=String(w.name);
      if(ctx.measureText(nm).width>bud){ while(nm.length>2&&ctx.measureText(nm+'\u2026').width>bud) nm=nm.slice(0,-1); nm+='\u2026'; }
      rsText(nm,bx,yy,col,fM);
      rsText(val,bx+colW-U(76),yy,col,fM,'right');
      rsText(stt,bx+colW,yy,col,fM,'right');
      yy+=rowH;
    }
    if(extra){
      ss=[]; if(more>0) ss.push('+'+more+' MORE'); if(RSTAT.out+RSTAT.dead>0) ss.push(RSTAT.out+' OUT / '+RSTAT.dead+' DEAD');
      rsText(ss.join('   '),bx,yy,'#8a96a1',fM);
    }
  }
  // the tiles
  var tx=hasR?(bx+colW+gap):bx, ty=by, th, fv;
  for(i=0;i<T.length;i++){
    th=T[i].big?U(56):U(46);
    ctx.fillStyle='rgba(0,0,0,.30)'; ctx.fillRect(tx,ty,tileW,th);
    ctx.fillStyle=T[i].rail||'#4a5257'; ctx.fillRect(tx,ty,Math.max(2,U(3)),th);
    rsText(T[i].l,tx+U(11),ty+U(14),'#8a96a1',fM);
    if(T[i].s) rsText(T[i].s,tx+tileW-U(8),ty+U(14),'#aaa498',fM,'right');
    fv=T[i].big?fT:fH; ctx.font=fv; if(ctx.measureText(T[i].v).width>tileW-U(22)) fv=fM;
    rsText(T[i].v,tx+U(11),ty+th-U(10),T[i].c,fv);
    ty+=th+U(6);
  }
  ctx.restore();
  RSTAT.on=1;
  return true;
}
function drawCrierMarkers(){
'@

SubRx @'
var VER='25.78';
'@ @'
var VER='25.79';
'@

$pat = "(?m)^  now:'v25\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.79: Hold Alt to see the raid status: the pillagers board, your score and credits, the raid clock, the extraction and your teammate. Check 25.79 fails on v25.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
