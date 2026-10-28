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

# CLOCK OVER SCORE, ARROW TO THE NEAREST EXIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0};
'@ @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0};
var CLOCKBOX={g:null,x:0,y:0,w:0,h:0}, GUNCARD={g:null,x:0,y:0,w:0,h:0}, HUDTOPB=0, ALERTY=0;   // v35.xx (cw-clockcard): the clock card over the score card as last drawn; GUNCARD the gun card panel as drawn (screen px); HUDTOPB the bottom of the top centre stack (clock, score, extract pill, arrow) in screen px; ALERTY the top of the alert band, unscaled

'@

SubRx @'
return wlHit(EDGEBOX.trcol,X,Y,X1,Y1)||wlHit(HUDBOX.cond,X,Y,X1,Y1)||(s.g===G&&wlHit(s,X,Y,X1,Y1));
'@ @'
return wlHit(EDGEBOX.trcol,X,Y,X1,Y1)||wlHit(HUDBOX.cond,X,Y,X1,Y1)||(s.g===G&&wlHit(s,X,Y,X1,Y1))||(CLOCKBOX.g===G&&wlHit(CLOCKBOX,X,Y,X1,Y1))||wlHit(EDGEBOX.notes,X,Y,X1,Y1);   // v35.xx (cw-clockcard): and the clock card and the notes row
'@

SubRx @'
function arcadeScoreHud(y,z){
  // v28.xx (cw-cx-hudtvread): readable score labels and a real top inset in both windows. Score, streak and final-minute clock rules stay the same.
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade,solo=cr||!!ARCADE.solo,cx=Math.round(W/2),mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)),mate=cr?0:Math.max(0,ARCADE.mate|0),nm=arcadeCr(mine+mate),
      fb=FSz(TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
      clock=raidClockOn(),ct=Math.ceil(Math.max(0,+G.timeLeft||0)),fin=ct<=CLOCK_RED,fc=FSz(fin?TYPE.title:TYPE.head,z),ch=parseFloat((/([\d.]+)px/.exec(fc)||[0,20])[1]),
      top=Math.round(16*z),pad=Math.round(12*z),labelY=top+pad+lh,scoreY=labelY+Math.round(8*z)+h,clockY=scoreY+Math.round(8*z)+ch,
      sx=arcadeStreakLive(),w,gx,pw,bot,side=0,sw=0,apo=false;
  ctx.save();ctx.textAlign='center';
  ctx.font=fb;w=ctx.measureText(nm).width;
  if(!solo){ctx.font=fs;side=Math.max(ctx.measureText('YOU '+arcadeCr(mine)).width,ctx.measureText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate)).width)+Math.round(24*z);}
  if(sx>1){ctx.font=fb;sw=ctx.measureText('x'+sx).width+Math.round(10*z);}
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
  ctx.font=fs; pw=Math.max(pw,Math.ceil(dmulTagW(ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z)+pad));   // v35.xx (cw-dmulshow): room for the multiplier tag
  bot=Math.ceil((clock?clockY+ch*.25:scoreY+h*.25)+pad);
  hudPlate(cx-pw,top,pw*2,bot-top,null,HUDC.plate);
  SCOREBOX.g=G;SCOREBOX.x=cx-pw;SCOREBOX.y=top;SCOREBOX.w=pw*2;SCOREBOX.h=bot-top;
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
  dmulTag(cx,labelY,ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z);   // v35.xx (cw-dmulshow): the settings multiplier beside the label
  ctx.font=fb;ctx.fillStyle=UIC.tx_1;hudText(nm,cx,scoreY);
  if(clock){apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();}
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
  if(sx>1){ctx.font=fb;ctx.textAlign='right';ctx.fillStyle='#ffc04a';hudText('x'+sx,Math.round(cx-w/2-10*z),scoreY);}
  ctx.restore();return bot;
}
'@ @'
function arcadeScoreHud(y,z){
  // v28.xx (cw-cx-hudtvread): readable score labels and a real top inset in both windows. Score, streak and final-minute clock rules stay the same.
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "score and clock should be separate windows.  Clock should be bigger than score and should be above score." The raid clock
  // has its own card on top, in the big number size (39 px at 1080p, over the score's 26), the same size all raid (red with its pop in the final minute, so the
  // score card under it never jumps). The score card under it keeps its label, its figure, the YOU and partner column and the streak. SCOREBOX stays the score card.
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade,solo=cr||!!ARCADE.solo,cx=Math.round(W/2),mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)),mate=cr?0:Math.max(0,ARCADE.mate|0),nm=arcadeCr(mine+mate),
      fb=FSz(TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
      clock=raidClockOn(),ct=Math.ceil(Math.max(0,+G.timeLeft||0)),fin=ct<=CLOCK_RED,fc=FSz(TYPE.huge,z),ch=parseFloat((/([\d.]+)px/.exec(fc)||[0,30])[1]),
      top=Math.round(16*z),pad=Math.round(12*z),cpad=Math.round(10*z),cw=0,cBot=0,clockY=0,labelY,scoreY,
      sx=arcadeStreakLive(),w,gx,pw,bot,side=0,sw=0,apo=false;
  ctx.save();ctx.textAlign='center';
  CLOCKBOX.g=null;
  if(clock){
    ctx.font=fc;cw=Math.ceil(Math.max(70*z,ctx.measureText('10:00').width/2+cpad*1.6));
    clockY=top+cpad+Math.round(ch*0.92);cBot=Math.ceil(clockY+ch*0.22+cpad);
    hudPlate(cx-cw,top,cw*2,cBot-top,null,HUDC.plate);
    CLOCKBOX.g=G;CLOCKBOX.x=cx-cw;CLOCKBOX.y=top;CLOCKBOX.w=cw*2;CLOCKBOX.h=cBot-top;
    apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();
    top=cBot+Math.round(6*z);
  }
  labelY=top+pad+lh;scoreY=labelY+Math.round(8*z)+h;
  ctx.font=fb;w=ctx.measureText(nm).width;
  if(!solo){ctx.font=fs;side=Math.max(ctx.measureText('YOU '+arcadeCr(mine)).width,ctx.measureText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate)).width)+Math.round(24*z);}
  if(sx>1){ctx.font=fb;sw=ctx.measureText('x'+sx).width+Math.round(10*z);}
  pw=Math.ceil(Math.max(100*z,w/2+pad+Math.max(side,sw)));
  ctx.font=fs; pw=Math.max(pw,Math.ceil(dmulTagW(ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z)+pad));   // v35.xx (cw-dmulshow): room for the multiplier tag
  bot=Math.ceil(scoreY+h*.25+pad);
  hudPlate(cx-pw,top,pw*2,bot-top,null,HUDC.plate);
  SCOREBOX.g=G;SCOREBOX.x=cx-pw;SCOREBOX.y=top;SCOREBOX.w=pw*2;SCOREBOX.h=bot-top;
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
  dmulTag(cx,labelY,ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z);   // v35.xx (cw-dmulshow): the settings multiplier beside the label
  ctx.font=fb;ctx.fillStyle=UIC.tx_1;hudText(nm,cx,scoreY);
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
  if(sx>1){ctx.font=fb;ctx.textAlign='right';ctx.fillStyle='#ffc04a';hudText('x'+sx,Math.round(cx-w/2-10*z),scoreY);}
  ctx.restore();return bot;
}
'@

SubRx @'
try{ if(SCOREBOX&&SCOREBOX.g===G&&SCOREBOX.w>0) wxIconDraw(Math.round(SCOREBOX.x+SCOREBOX.w+LH(16)*_tz),Math.round(SCOREBOX.y+Math.min(SCOREBOX.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}
'@ @'
try{ var _wxB=(CLOCKBOX.g===G&&CLOCKBOX.w>0)?CLOCKBOX:SCOREBOX; if(_wxB&&_wxB.g===G&&_wxB.w>0) wxIconDraw(Math.round(_wxB.x+_wxB.w+LH(16)*_tz),Math.round(_wxB.y+Math.min(_wxB.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}   /* v35.xx (cw-clockcard): beside the clock card */
'@

SubRx @'
  if(G.beaconT!==null&&G.beaconT!==undefined&&G.active){
_tgt=G.active; _lbl='EXTRACTION';
  } else if(G.waypoint){
'@ @'
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "extraction arrow should always point to the closest extraction point". A live beacon no longer holds the arrow:
  // the beacon mirror makes ANY live ring G.active (a pillager's call or a teammate's across the map), so it pointed far away. It is the nearest open
  // ring now, called or not (the pill still names that ring's state); a waypoint he set himself still wins.
  if(G.waypoint){
'@

SubRx @'
  if(_tgt){
    var za=Math.atan2(_tgt.y-p.y,_tgt.x-p.x),zd=Math.round(dist(p,_tgt));
'@ @'
  HUDTOPB=(G.arcade||G.career)?Math.max((SCOREBOX.g===G)?SCOREBOX.y+SCOREBOX.h:0,Math.round(_yCmp+_hCmp*0.3)):0;   // v35.xx (cw-clockcard): the alert band starts under the top centre stack
  if(_tgt){
    var za=Math.atan2(_tgt.y-p.y,_tgt.x-p.x),zd=Math.round(dist(p,_tgt));
'@

SubRx @'
    if(G.arcade){ ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.lineJoin='round'; ctx.stroke(); }
    ctx.restore();

'@ @'
    if(G.arcade){ ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.lineJoin='round'; ctx.stroke(); }
    ctx.restore();
    if(G.arcade||G.career) HUDTOPB=Math.max(HUDTOPB,Math.round(_yArw+(G.arcade?8*_tz:0)+8*_az));   // v35.xx (cw-clockcard)

'@

SubRx @'
  HUDFEEDT=LH(96); HUDALERTB=0; ALERTL=null;
  try{ al=alertLayout(); }catch(_al){ al=null; }
  if(al){ ALERTL=al; HUDALERTB=Math.round((LH(96)+al.h)*z); HUDFEEDT=LH(96)+al.h+LH(4); }
  else if(locUp()) HUDFEEDT=LH(96)+locH()+LH(4);
'@ @'
  ALERTY=LH(96); if(G&&(G.arcade||G.career)&&!G.over&&HUDTOPB>0) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(6));   // v35.xx (cw-clockcard): under the clock card, the score card, the extract pill and its arrow (the stack grew by the clock card)
  HUDFEEDT=ALERTY; HUDALERTB=0; ALERTL=null;
  try{ al=alertLayout(); }catch(_al){ al=null; }
  if(al){ ALERTL=al; HUDALERTB=Math.round((ALERTY+al.h)*z); HUDFEEDT=ALERTY+al.h+LH(4); }
  else if(locUp()) HUDFEEDT=ALERTY+locH()+LH(4);
'@

SubRx @'
x0=Math.round(W/2-L.w/2), y0=LH(96), gx=x0+LH(12)
'@ @'
x0=Math.round(W/2-L.w/2), y0=ALERTY||LH(96), gx=x0+LH(12)
'@

SubRx @'
hudText(l.m,W/2,LH(96)+LH(5)+Math.round(hp*0.82),2);
'@ @'
hudText(l.m,W/2,(ALERTY||LH(96))+LH(5)+Math.round(hp*0.82),2);   // v35.xx (cw-clockcard)
'@

SubRx @'
y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);
'@ @'
y=Math.round(((ALERTY||LH(96))+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);
'@

SubRx @'
var EXTNEAR=60;
'@ @'
var EXTNEAR=60;
// v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "extracts starting and extracts in progress should only be shown at the bottom of the screen if player is within 250m of the extract".
// The band above the belt (EXTRACT A INBOUND 20s, EXTRACT IN PROGRESS! A 30S LEFT, its arrow and metres, the hostiles row) showed for any live ring on the map.
// It shows within 250 m of that ring's centre now (the metres it prints); the things that make room for it (the use bar, the controls dock, the ammo card's step down) read the same test.
var EXTSHOW=250;
function extBandOn(p){ return !!(G&&p&&G.active&&G.beaconT!==null&&G.beaconT!==undefined&&!G.over&&dist(p,G.active)<=EXTSHOW*U_PER_M); }
'@

SubRx @'
  if(G.beaconT!==null&&!G.over){
    var inRing=dist(p,G.active)<G.active.r;
'@ @'
  if(extBandOn(p)){   // v35.xx (cw-clockcard): within 250 m
    var inRing=dist(p,G.active)<G.active.r;
'@

SubRx @'
try{ if((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(by-(LH(48)+LH(34)+LH(34))*Math.max(1,hudRes())-h));
'@ @'
try{ if(extBandOn(p)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(by-(LH(48)+LH(34)+LH(34))*Math.max(1,hudRes())-h));   /* v35.xx (cw-clockcard) */
'@

SubRx @'
try{ if((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(c.y-(LH(48)+LH(34)+LH(34))*uz-h)); }catch(_ex){}
'@ @'
try{ if(extBandOn(p)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(c.y-(LH(48)+LH(34)+LH(34))*uz-h)); }catch(_ex){}   // v35.xx (cw-clockcard)
'@

SubRx @'
  if(typeof G.beaconT==='number'&&G.beaconT>0) ctx.globalAlpha=0.7;
'@ @'
  if(typeof G.beaconT==='number'&&G.beaconT>0&&extBandOn(p)) ctx.globalAlpha=0.7;   // v35.xx (cw-clockcard): only while the band shows
'@

SubRx @'
if(!G.sim&&chatNear(z.x,z.y)) say('PILLAGER BOT CALLED EXTRACTION'
'@ @'
if(!G.sim&&chatNear(z.x,z.y)&&G.player&&dist(G.player,z)<=EXTSHOW*U_PER_M) say('PILLAGER BOT CALLED EXTRACTION'
'@

SubRx @'
function feedMedal(txt,pts){
'@ @'
// v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "score should only be shown here, e.g. it should NOT pop on the screen (like looting does) every time sp is earned", and on the
// kill lines ("you > crawler m-10 +50 sp"): "these look good, sp can stay". A kill's figure goes straight onto his own kill line; no float rises over the body and
// no line of its own is made when there is no kill line to ride on.
function feedKillSp(s){
  if(!G||G.sim||!G.player) return null;
  var F=feedS(), Ln=F.lines[F.lines.length-1];
  if(Ln&&Ln.fk==='kill'&&Ln.mine&&!Ln.money&&F.t-Ln.last<0.8){ Ln.money=s; Ln.mf=''; return Ln; }
  return null;
}
function feedMedal(txt,pts){
'@

SubRx @'
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n)+(hot?' hot':''),'#ffc04a',0,true); }catch(_alb){} }
  c=arcadeStreakCall(s.n);
'@ @'
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only
  c=arcadeStreakCall(s.n);
'@

SubRx @'
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n)+(hot?' hot':''),'#ffc04a',0,true); }catch(_alb){} }   // v23.56 (arcade31): +$50
'@ @'
  try{ feedKillSp('+'+arcadeCr(n)+(hot?' hot':'')); }catch(_alb){}   // v35.xx (cw-clockcard): on the kill line only (v23.56, arcade31, was a float over the body)
'@

SubRx @'
  try{ label(x,y,txt+' +'+arcadeCr(n),'#ffc04a',0,true); }catch(_l){}
  return n;
'@ @'
  return n;   // v35.xx (cw-clockcard): no figure floats (a medal shows its emblem and name, FINISHER and CLOSE CALL their word)
'@

SubRx @'
  if(!scoreBonus(FIN_PTS,e.x,e.y-30,'FINISHER')){ try{ label(e.x,e.y-30,'FINISHER','#ffc04a',0,true); }catch(_l){} }
'@ @'
  scoreBonus(FIN_PTS,e.x,e.y-30,'FINISHER'); try{ label(e.x,e.y-30,'FINISHER','#ffc04a',0,true); }catch(_l){}   // v35.xx (cw-clockcard): the word, never the figure
'@

SubRx @'
  sc=scoreBonus(CC_PTS,p.x,p.y-32,'CLOSE CALL');
  if(!sc){ try{ label(p.x,p.y-32,'CLOSE CALL','#ffc04a',0,true); }catch(_l){} }
'@ @'
  sc=scoreBonus(CC_PTS,p.x,p.y-32,'CLOSE CALL');
  try{ label(p.x,p.y-32,'CLOSE CALL','#ffc04a',0,true); }catch(_l){}   // v35.xx (cw-clockcard): the word, never the figure
'@

SubRx @'
  say(head,'ext',{sub:sub+'  +'+arcadeCr(n)});
  try{ if(p) label(p.x,p.y-44,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_cl){}
'@ @'
  say(head,'ext',{sub:sub});   // v35.xx (cw-clockcard): no +sp on the line and no float; the score card counts it
'@

SubRx @'
    try{ label(R.doorX,R.doorY-30,'+'+arcadeCr(ARCADE_VAULT_PAY),'#ffc04a',0,true); }catch(_cl){}

'@ @'

'@

SubRx @'
  try{ label(R.doorX,R.doorY-30,'+'+arcadeCr(ARCADE_VAULT_PAY),'#ffc04a',0,true); }catch(_vl){}

'@ @'

'@

SubRx @'
nm=String(pp.txt); fg='+'+arcadeCr(pp.pts);
'@ @'
nm=String(pp.txt); fg='';   /* v35.xx (cw-clockcard): the medal's name, no figure */
'@

SubRx @'
say('BOUNTY ON THE MAP','warn',{sub:'HE HUNTS YOU  $'+BOUNTY.pay});
'@ @'
say('BOUNTY ON THE MAP','warn',{sub:'HE HUNTS YOU'});   /* v35.xx (cw-clockcard): no figure (it was score shown as $) */
'@

SubRx @'
+'  $'+BOUNTY.pay});

'@ @'
});   // v35.xx (cw-clockcard)

'@

SubRx @'
hudText('BOUNTY  $'+BOUNTY.pay,s.x,s.y+ev.r*q+U(16));
'@ @'
hudText('BOUNTY',s.x,s.y+ev.r*q+U(16));   // v35.xx (cw-clockcard)
'@

SubRx @'
         for(_gcq=0;_gcq<G.bag.length;_gcq++) _gcv+=ival(G.bag[_gcq]);
         _gCnt=G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_gcv.toLocaleString();
         _gCt=_gWd(_gFf,Math.max(10,G.bag.length))+' ITEMS  $'+_gWd(_gFf,Math.max(10000,_gcv).toLocaleString());   // at least two item figures and five money figures

'@ @'
         // v35.xx (cw-clockcard): the item count and its value are gone from the card, the backpack key is the row

'@

SubRx @'
         _gFW=_gMs(_gFf,_gHint).width+LH(16)+Math.max(_gMs(_gFf,_gCnt).width,_gMs(_gFf,_gCt).width); _gDs=Math.max(_gDn(_gFf,_gHint),_gDn(_gFf,_gCt));
'@ @'
         _gFW=_gMs(_gFf,_gHint).width; _gDs=_gDn(_gFf,_gHint);
'@

SubRx @'
  var _cv=0; for(var _cq9=0;_cq9<G.bag.length;_cq9++) _cv+=ival(G.bag[_cq9]);
  if(!trDemo()) ctx.fillText(G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_cv.toLocaleString(),_gX,by);
'@ @'
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28), on the gun card: "item number is useless; remove it.  also remove the stash value as that is already shown in another window (current pillager bots)". The N ITEMS $N line is gone.
'@

SubRx @'
_gR2=Math.max(_gMs(_gFt,_gRs).width+4+_gMs(_gFm,_gMg).width,_gMs(_gFt,' / '+rsvShow(p)).width+4+_gMs(_gFm,String(p.ammo)).width,_gMs(_gFt,'RELOADING').width,_gMs(_gFt,'JAMMED').width);
'@ @'
_gR2=Math.max(_gMs(_gFt,_gRs).width+4+_gMs(_gFm,_gMg).width,_gMs(_gFt,' / '+rsvShow(p)).width+4+_gMs(_gFm,String(p.ammo)).width,_gMs(_gFt,'RELOADING').width,_gMs(_gFt,'JAMMED').width,_gMs(_gFt,_gRs).width+4+_gMs(_gFm,'0').width+LH(10)+Math.max(LH(24),_gMs(FS(TYPE.head),ammoCapKey()).width+LH(14)));   // v35.xx (cw-clockcard): room for the reload key left of an empty 0, now the count row is gone
'@

SubRx @'
    if(_rcn) _rtl.push('contracts '+_rcd+'/'+_rcn);

'@ @'
    // v35.xx (cw-clockcard), HIS NOTE (2026-10-28): "not sure what is meant by 'contracts 6/8' -- seems pretty useless if you aren't going to show the contracts". The count is gone (most of it was contracts done and waiting at the Mainframe); the contract rows the panel lists stay.

'@

SubRx @'
  g.yE=Math.ceil((g.y0+(n?g.rh+g.gp:0))*g.z);
'@ @'
  g.yE=Math.ceil(g.y0*g.z);   // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "this menu should spawn in upper right hand corner": nothing sits over the run info panel (the notes row is under it now, trColDraw)
'@

SubRx @'
  var g=TRG, y=g.y0, by=y+8+LH(8)+(i>>1)*g.ls,
'@ @'
  var g=TRG, y=(g.yN>0)?g.yN:g.y0, by=y+8+LH(8)+(i>>1)*g.ls,
'@

SubRx @'
  if(nn) trRow(i++,'notes logged',TRV.ns);
  ctx.textAlign='left';
'@ @'
  var _cb=HUDBOX.cond; EDGEBOX.notes=null;
  TRG.yN=(_cb&&_cb.h>0)?Math.ceil((_cb.y+_cb.h)/g.z)+g.gp:0;   // v35.xx (cw-clockcard): the notes row under the run info panel, one gap
  if(nn){ trRow(i++,'notes logged',TRV.ns); EDGEBOX.notes={x:W-(W-g.x)*g.z,y:(TRG.yN||g.y0)*g.z,w:g.bw*g.z,h:g.rh*g.z}; }
  ctx.textAlign='left';
'@

SubRx @'
  if(!(g.n>0)) return 0;
  if(nn&&TRV.nn!==nn)
'@ @'
  if(!(g.n>0)){ EDGEBOX.notes=null; return 0; }   // v35.xx (cw-clockcard): no rows, no notes box (an old raid's box must not hold the corner)
  if(nn&&TRV.nn!==nn)
'@

SubRx @'
  if(!g.n&&!b){ EDGEBOX.trcol=null; return; }
  if(!E) E=EDGEBOX.trcol={x:0,y:0,w:0,h:0};
  y1=b?(b.y+b.h):(g.yE-Math.round(g.gp*g.z));
'@ @'
  if(!b){ EDGEBOX.trcol=null; return; }   // v35.xx (cw-clockcard): the column over the run info panel is the minimap alone
  if(!E) E=EDGEBOX.trcol={x:0,y:0,w:0,h:0};
  y1=b.y+b.h;
'@

SubRx @'
function mmOffMove(){
'@ @'
// v35.xx (cw-clockcard): once per save, the run info panel goes back to its corner (an old drag had moved it); drags made after this stay
function condTopMove(){
  if(!P||P.condTop1===1) return false;
  if(P.hud&&P.hud.cond){ delete P.hud.cond.dx; delete P.hud.cond.dy; }
  P.condTop1=1;
  return true;
}
function mmOffMove(){
'@

SubRx @'
  try{ mmOffMove(); }catch(_mo){} try{ pixOffMove(); }catch(_po){}
'@ @'
  try{ mmOffMove(); }catch(_mo){} try{ pixOffMove(); }catch(_po){} try{ condTopMove(); }catch(_ct){}   // v35.xx (cw-clockcard)
'@

SubRx @'
  ctx.fillText('CURRENT PILLAGER BOTS  '+live,PADX,y0-LH(2));
'@ @'
  ctx.fillText('CURRENT PILLAGERS  '+live,PADX,y0-LH(2));   // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "This should say 'current pillagers'  and then 'value at risk'"
  if(!HOr.c){ ctx.save(); ctx.textAlign='right'; ctx.fillStyle=UIC.tx_2; ctx.fillText('VALUE AT RISK',PADX-8+LW-LH(26),y0-LH(2)); ctx.restore(); }   // the money column's head, left of the chevron
'@

SubRx @'
  if(!L) return {x:Math.round(W-bw-16*z),y:Math.round(H*0.6)};
  for(i=0;i<hc.length;i++) top=Math.min(top,hc[i].y);
  x=Math.round(L.x+L.w-bw);
  y=Math.round(top-g8-bh);
'@ @'
  var GB=(GUNCARD.g===G&&GUNCARD.w>0&&GUNCARD.h>0&&!G.bagOpen)?GUNCARD:null;
  if(GB){ x=Math.round(GB.x+GB.w-bw); y=Math.round(GB.y-g8-bh); }   // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "air strike needs to move ABOVE this weapon panel, and be further over on the right hand side"
  else {
  if(!L) return {x:Math.round(W-bw-16*z),y:Math.round(H*0.6)};
  for(i=0;i<hc.length;i++) top=Math.min(top,hc[i].y);
  x=Math.round(L.x+L.w-bw);
  y=Math.round(top-g8-bh);
  }
'@

SubRx @'
  E=[HUDBOX.gear,handPlateBox(),
'@ @'
  E=[GB?null:HUDBOX.gear,handPlateBox(),
'@

SubRx @'
       if(_wpw>LH(40)) hudPanel(_wpx,_gTop,_wpw,_gBot-_gTop,0.88,1);   // plain: no tab
'@ @'
       if(_wpw>LH(40)) hudPanel(_wpx,_gTop,_wpw,_gBot-_gTop,0.88,1);   // plain: no tab
       try{ var _gC=hudZoomRect('gear',W,H,{x:_wpx,y:_gTop,w:_wpw,h:_gBot-_gTop}); GUNCARD.g=G; GUNCARD.x=_gC.x+_gdx; GUNCARD.y=_gC.y+((typeof _boG==='object'&&_boG)?(_boG.dy||0):0); GUNCARD.w=_gC.w; GUNCARD.h=_gC.h; }catch(_gcx){}   // v35.xx (cw-clockcard): the card as drawn, for the air strike plate on top of it
'@

SubRx @'
    var _dy=H/2-34;                                  // unchanged at 1920x1080

'@ @'
    var _dy=H/2-34;                                  // unchanged at 1920x1080
    // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "when player is downed, the downed card blocks the view of the centered player -- needs to move up". The card lifts until
    // its bottom edge is DOWNGAP over the screen centre (the player), never higher than the top centre stack.
    try{ var _dpR=downPlateRect(W/2,_dy,_hH,_hD,!!p.revived,CFG.giveUp!==0,!!(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)),downedVerb(),p.dbOn===1), _dLift=Math.max(0,Math.round(_dpR.y+_dpR.h-(H/2-DOWNGAP))), _dCap=Math.floor(_dpR.y-H/2-((HUDTOPB||0)+LH(8)-H/2)/_dwz); _dLift=Math.max(0,Math.min(_dLift,_dCap)); if(_dLift>0) ctx.translate(0,-_dLift); DOWNLIFT=_dLift; }catch(_dlf){}

'@

SubRx @'
var HUDBOSSB=0, HUDGIFTB=0,
'@ @'
var DOWNGAP=64, DOWNLIFT=0;   // v35.xx (cw-clockcard): the downed card's bottom stands 64 (1080p units) over the player; the lift last applied
var HUDBOSSB=0, HUDGIFTB=0,
'@

SubRx @'
var VER='35.79';
'@ @'
var VER='35.80';
'@

$pat = "(?m)^  now:'v35\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.80: clock card over the score card; arrow to the nearest exit; no sp pop-ups; far exits stay quiet; tidier gun card, goals panel and board; air strike over the gun card; downed card above you Check 35.80 fails on v35.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
