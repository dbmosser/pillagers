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

# the top strip: clock, score, extract, alerts and down all across the top edge (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0}, CLKCARD={g:null,k:'',x:0,y:0,w:0,h:0,ay:0};
'@ @'
var SCOREBOX={g:null,x:0,y:0,w:0,h:0}, RAIL={g:null,h:0,b:0,m:0,in:0,scR:0,clL:0,clR:0,skR:0,exL:0};
'@

SubRx @'
var DOWNGAP=64, DOWNLIFT=0, DOWNTOP=0;   // v36.77 (cw-dangerdown): DOWNTOP is the top of the downed card on the screen, in px, as last drawn   // v35.xx (cw-clockcard): the downed card's bottom stands 64 (1080p units) over the player; the lift last applied

'@ @'

'@

SubRx @'
var ALERTDROP=1.5, ALERTAGAIN=10, ALERTYF=0.27, ALERTIN=0.2,
'@ @'
var ALERTDROP=1.5, ALERTAGAIN=10, ALERTIN=0.2,
'@

SubRx @'
function alertSlotY(hh){   // the top of the danger plate, before the message scale
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), y=Math.max(ALERTY||LH(96),Math.round(H*ALERTYF/z)), p=G&&G.player;
  // v36.77 (cw-dangerdown): while you are down the downed card stands at the same height (it was lifted off the player, v35.xx cw-clockcard), so the danger plate stands on top of it
  if(p&&p.downed&&!G.over&&DOWNTOP>0) y=Math.max(ALERTY||LH(96),Math.min(y,Math.floor(DOWNTOP/z-hh-LH(8))));
  return y;
}

'@ @'

'@

SubRx @'
var ARCADE_ARW=2;   // the arcade compass arrow, times its normal size
'@ @'
var ARCADE_ARW=1.6;   // the arcade compass arrow, times its normal size (v37.xx cw-topstrip: the 1080p rail is 52 px tall)
'@

SubRx @'
function wlUnder(x,y,w,h){
  var z=WTX.z, X=(x-WTX.ox)*z, Y=(y-WTX.oy)*z, X1=X+w*z, Y1=Y+h*z, s=SCOREBOX;
  // v28.xx (cw-cx-rushlayout): keep world nameplates out of the rush banner, as they already clear the score and clock.
  if(ALERTL&&G&&G.alert===ALERTL.a&&ALERTL.a.key==='finalrush'){
    var az=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), aw=ALERTL.w*az, ay=ALERTY*az;
    if(X1>W/2-aw/2-8&&X<W/2+aw/2+8&&Y1>ay-8&&Y<ay+ALERTL.h*az+8) return true;
  }
  return wlHit(EDGEBOX.trcol,X,Y,X1,Y1)||wlHit(HUDBOX.cond,X,Y,X1,Y1)||(s.g===G&&wlHit(s,X,Y,X1,Y1))||(CLOCKBOX.g===G&&wlHit(CLOCKBOX,X,Y,X1,Y1))||wlHit(EDGEBOX.notes,X,Y,X1,Y1);
'@ @'
function wlUnder(x,y,w,h){
  var z=WTX.z, X=(x-WTX.ox)*z, Y=(y-WTX.oy)*z, X1=X+w*z, Y1=Y+h*z;
  // v37.xx (cw-topstrip): the rail runs the whole top edge, so a world label under it is under it wherever it stands; the score, clock and rush tests are this one test now.
  if(RAIL.g===G&&Y<RAIL.b&&Y1>0) return true;
  return wlHit(EDGEBOX.trcol,X,Y,X1,Y1)||wlHit(HUDBOX.cond,X,Y,X1,Y1)||wlHit(EDGEBOX.notes,X,Y,X1,Y1);
'@

SubRx @'
  g.z=(HUDZ.cond||1)*hudRes()*hudUserZ('cond');

'@ @'
  g.z=(HUDZ.cond||1)*hudRes()*hudUserZ('cond');
  g.y0=railOn()?Math.ceil((railH()+8)/g.z):16;   // v37.xx (cw-topstrip): the corner column starts under the rail

'@

SubRx @'
tp=Math.round(r.top+14*z)+'px'
'@ @'
tp=Math.round(r.top+(railOn()?Math.max(14*z,railH()*(r.height/(H||r.height||1))+6*z):14*z))+'px'
'@

SubRx @'
function alertLayout(){   // with the message scale not yet applied: the alert plate, its lines and their baselines, or null
  var a=alertUp(), hf, lf, hp, lp, gs, mw, hl, sl=[], w=0, i, y, bl=[];
  if(!a) return null;
  // v27.50 (alert3), HIS ANSWER (2026-10-14), "just polish UI up as you see fit consistent with AAA practices", and the HUD spec (section 6): the
  // headline of an alert is the L size (the 32 px step), the detail under it stays the S size. It was the M size, the size of a prompt; a callout
  // that has to be read in a firefight is the biggest line the HUD has bar the score and DOWN.
  hf=FS(TYPE.title); if(msgPx(hf)<ALERTPX) hf=hf.replace(/[\d.]+px/,ALERTPX+'px');   // v35.xx (cw-hudsize): the danger headline is 30 px at 1080p (was 26), still under the message scale
  lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
  mw=Math.max(LH(80),msgMaxW()-gs-LH(29));
  ctx.save();
  try{
    ctx.font=hf; hl=msgWrap(String(a.m),mw); for(i=0;i<hl.length;i++) w=Math.max(w,ctx.measureText(hl[i]).width);
    if(a.sub){ ctx.font=lf; sl=msgWrap(String(a.sub),mw); for(i=0;i<sl.length;i++) w=Math.max(w,ctx.measureText(sl[i]).width); }
  } finally { ctx.restore(); }
  y=LH(5)+Math.round(hp*0.82);
  for(i=0;i<hl.length;i++){ bl.push(y); if(i<hl.length-1) y+=Math.round(hp*1.2); }
  for(i=0;i<sl.length;i++){ y+=Math.round(lp*(i?1.2:1.35)); bl.push(y); }
  // v28.xx (cw-cx-rushlayout): the rush uses a 416px minimum panel and a 16px inset at the normal text scale.
  if(a.key==='finalrush'){
    for(i=0;i<bl.length;i++) bl[i]+=LH(7);
    return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,slot:0,y:ALERTY||LH(96),w:Math.max(LH(320),Math.ceil(LH(12)+gs+LH(7)+w+LH(12))),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(24)};
  }
  return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,slot:1,y:alertSlotY(y+Math.round((sl.length?lp:hp)*0.3)+LH(5)),w:Math.ceil(LH(12)+gs+LH(7)+w+LH(10)),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(5)};
}
'@ @'
function alertLayout(){   // v37.xx (cw-topstrip): the alert as one line, its fonts, its words and their widths. alertDraw places it on the rail, which is drawn after this runs.
  var a=alertUp(), hf, lf, m, s, hw, sw=0;
  if(!a) return null;
  hf=railF(TYPE.title,1.15); lf=railF(TYPE.head,1.28); m=String(a.m); s=a.sub?String(a.sub):'';   // 30 and 25 px at 1080p and 100 percent text: v35.53 (cw-hudsize) keeps the danger headline about 30 px, the detail is his approved picture
  ctx.save();
  try{ ctx.font=hf; hw=ctx.measureText(TX(m)).width; if(s){ ctx.font=lf; sw=ctx.measureText(TX(s)).width; } } finally { ctx.restore(); }
  return {a:a,m:m,s:s,hf:hf,lf:lf,hp:msgPx(hf),gs:Math.round(msgPx(hf)*0.9),hw:hw,sw:sw};
}
'@

SubRx @'
function alertDraw(L){   // inside the message scale, at the top of the band
  var a=L.a, now=G.t||0, rm=Math.min(1,(now-a.at)/(L.slot?ALERTIN:0.12)), al=Math.max(0,Math.min(rm,a.T/0.4)), col=a.col||HUDC[a.c]||HUDC[MSGK[msgKind(a.k)].c]||HUDC.text,
      x0=Math.round(W/2-L.w/2), y0=L.y, sc, gx=x0+LH(12), tx, i, oa=ctx.globalAlpha, oal=ctx.textAlign;
  if(!(al>0)) return;
  ctx.globalAlpha=oa*al;
  ctx.save();
  if(L.slot){ sc=0.86+0.14*(1-(1-rm)*(1-rm)); ctx.translate(W/2,y0+L.h/2); ctx.scale(sc,sc); ctx.translate(-W/2,-(y0+L.h/2)); }   // v36.73 (cw-dangerslot): it scales in over 0.2 s
  else ctx.translate(0,Math.round((1-rm)*-LH(10)));   // v27.50 (alert3): it drops in from 10 above over its fade in
  hudPlate(x0,y0,L.w,L.h,col,a.key==='finalrush'?'rgba(17,19,21,.96)':((a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate));   // v28.xx (cw-cx-rushlayout): red marks the rush title, with quiet graphite behind its detail.
  alertGlyph(a.icon||(a.k==='ext'?'ring':'threat'),gx,y0+L.bl[0]-Math.round(L.hp*0.36),L.gs,col);
  tx=gx+L.gs+LH(7);
  ctx.textAlign='left';
  ctx.font=L.hf; ctx.fillStyle=col;
  for(i=0;i<L.hl.length;i++) hudText(L.hl[i],tx,y0+L.bl[i],2);
  if(L.sl.length){ ctx.font=L.lf; ctx.fillStyle=HUDC.text; for(i=0;i<L.sl.length;i++) hudText(L.sl[i],tx,y0+L.bl[L.hl.length+i],2); }
  if(a.T0>0&&!alertHeld(a)){ ctx.fillStyle=col; ctx.globalAlpha=oa*al*0.6; ctx.fillRect(x0+LH(3),y0+L.h-Math.max(2,LH(2)),Math.max(0,(L.w-LH(3))*Math.min(1,a.T/a.T0)),Math.max(2,LH(2))); }   // v27.50 (alert3): its time, a bar along the foot of the plate
  ctx.restore();
  ctx.globalAlpha=oa; ctx.textAlign=oal;
}
'@ @'
function alertDraw(L){   // v37.xx (cw-topstrip): on the rail, right up against the clock. Down, the left of the rail is the down card, so it takes a line of its own under the rail.
  var a=L.a, now=G.t||0, rm=Math.min(1,(now-a.at)/ALERTIN), al=alertA(a), col=a.col||HUDC[a.c]||HUDC[MSGK[msgKind(a.k)].c]||HUDC.text,
      z=railZ(), dn=!!(G.player&&G.player.downed), oa=ctx.globalAlpha, oal=ctx.textAlign, gg=Math.round(10*z), gm=Math.round(14*z), gap=Math.round(20*z),
      hh=dn?Math.round(42*z):RAIL.h, y0=dn?RAIL.b:0, mid=y0+hh/2, avail=dn?W-RAIL.in*2:RAIL.clL-gap-RAIL.scR-gap, sub=!!L.s, tw=L.gs+gg+L.hw+(sub?gm+L.sw:0), k=Math.min(1,avail/tw), ax, x, tx0, bw;
  if(!(al>0)) return;
  if(k<0.72&&sub){ sub=false; tw=L.gs+gg+L.hw; k=Math.min(1,avail/tw); }   // too narrow to read both: the headline alone
  ax=dn?W/2:RAIL.clL-gap; tx0=dn?ax-tw*k/2:ax-tw*k; bw=tw*k;
  ctx.save();
  ctx.globalAlpha=oa*al;
  if(dn){ ctx.fillStyle=HUDC.dangerPlate; ctx.fillRect(Math.round(tx0-gm),y0,Math.round(bw+gm*2),hh); RAIL.b=y0+hh; }
  ctx.translate(ax,mid); var sc=k*(0.86+0.14*(1-(1-rm)*(1-rm))); ctx.scale(sc,sc);   // v36.73 (cw-dangerslot): it scales in over 0.2 s
  x=dn?-tw/2:-tw;
  alertGlyph(a.icon||(a.k==='ext'?'ring':'threat'),x,0,L.gs,col);
  x+=L.gs+gg;
  ctx.textAlign='left';
  ctx.font=L.hf; ctx.fillStyle=col; hudText(L.m,x,Math.round(L.hp*0.35),2);
  if(sub){ x+=L.hw+gm; ctx.font=L.lf; ctx.fillStyle=HUDC.text; hudText(L.s,x,Math.round(L.hp*0.35),2); }
  ctx.restore();
  if(a.T0>0&&!alertHeld(a)){ var bh=Math.max(2,Math.round(3*z)); ctx.fillStyle=col; ctx.globalAlpha=oa*al*0.6; ctx.fillRect(tx0,y0+hh-bh,Math.max(0,bw*Math.min(1,a.T/a.T0)),bh); }   // v27.50 (alert3): its time, a bar along the foot of the line
  ctx.globalAlpha=oa; ctx.textAlign=oal;
}
'@

SubRx @'
function locDraw(l){   // inside the message scale, in the alert slot
  var now=G.t||0, al=Math.max(0,Math.min(1,(now-l.at)/0.2,l.T/0.5)), hf=FS(TYPE.head), hp=msgPx(hf), oa=ctx.globalAlpha;
  if(!(al>0)) return;
  ctx.save();
  try{
    ctx.globalAlpha=oa*al; ctx.font=hf; ctx.textAlign='center'; ctx.textBaseline='alphabetic'; ctx.fillStyle=HUDC.dim;
    if('letterSpacing' in ctx) ctx.letterSpacing=Math.round(hp*0.2)+'px';
    hudText(l.m,W/2,(ALERTY||LH(96))+LH(5)+Math.round(hp*0.82),2);   // v35.xx (cw-clockcard)
  } finally { ctx.restore(); }
}
'@ @'
function locDraw(l){   // v37.xx (cw-topstrip): on the rail, in the alert's room, against the clock
  var now=G.t||0, al=Math.max(0,Math.min(1,(now-l.at)/0.2,l.T/0.5)), hf=railF(TYPE.head,1.1), gap=Math.round(20*railZ()), sl=RAIL.scR+gap, sr=RAIL.clL-gap, oa=ctx.globalAlpha;
  if(!(al>0)||(G.player&&G.player.downed)) return;
  ctx.save();
  try{
    ctx.globalAlpha=oa*al; ctx.textAlign='right'; ctx.textBaseline='alphabetic'; ctx.fillStyle=HUDC.dim;
    if('letterSpacing' in ctx) ctx.letterSpacing=Math.round(msgPx(hf)*0.12)+'px';
    ctx.font=railFit(hf,l.m,sr-sl);
    hudText(l.m,sr,railBase(hf,RAIL.m||0),2);
  } finally { ctx.restore(); }
}
'@

SubRx @'
  ALERTY=LH(96); if(G&&(G.arcade||G.career)&&!G.over&&HUDTOPB>0) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(6));   // v35.xx (cw-clockcard): under the clock card, the score card, the extract pill and its arrow (the stack grew by the clock card)
  if(arcadeRushOn()) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(18));   // v28.xx (cw-cx-rushlayout): 24px clear space above the rush callout.
  HUDFEEDT=ALERTY; HUDALERTB=0; ALERTL=null;
  try{ al=alertLayout(); }catch(_al){ al=null; }
  if(al){ ALERTL=al; HUDALERTB=Math.round((al.y+al.h)*z); HUDFEEDT=al.slot?ALERTY:ALERTY+al.h+LH(4); }   // v36.73 (cw-dangerslot): the danger plate stands at 27 percent, so nothing under the clock stack moves down for it
  else if(locUp()) HUDFEEDT=ALERTY+locH()+LH(4);   // v22.xx (R34): the location tag holds the slot, so the feed starts under it
'@ @'
  ALERTY=(railOn()&&HUDTOPB>0)?Math.ceil(HUDTOPB/z)+LH(6):LH(96);   // v37.xx (cw-topstrip): right under the rail, so everything that hung under the old stack moves up with it
  HUDFEEDT=ALERTY; HUDALERTB=0; ALERTL=null;
  try{ al=alertLayout(); }catch(_al){ al=null; }
  if(al) ALERTL=al;   // the alert and the location tag stand on the rail now, so the rows under the rail never move for them
'@

SubRx @'
  if(arcadeRushOn()) msgLayout();   // v28.xx (cw-cx-rushlayout): the header was just measured; use this frame when drawing the rush, including its first frame.

'@ @'

'@

SubRx @'
    // v10.43, his answers 25 and 30: the message line scales with the monitor
    // like every panel, anchored at the top centre. It was 19px at 4K.
    ctx.save(); hudZoomIn('msg',W/2,0);
    if(_alL&&G){ try{ hudFadeCall('alert',alertDraw,[_alL]); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
    else if(_loc&&G){ try{ hudFadeCall('location',locDraw,[_loc]); }catch(_ld){} }   // v22.xx (R34): the location tag in the free alert slot
'@ @'
    // v37.xx (cw-topstrip): the alert and the location tag stand on the rail, outside the message scale: the rail's height has no room for it to grow.
    if(_alL&&G){ try{ hudFadeCall('alert',alertDraw,[_alL]); }catch(_ad){} }   // v22.13 (R08): the alert lane
    else if(_loc&&G){ try{ hudFadeCall('location',locDraw,[_loc]); }catch(_ld){} }   // v22.xx (R34): the location tag in the free alert slot
    // v10.43, his answers 25 and 30: the message line scales with the monitor
    // like every panel, anchored at the top centre. It was 19px at 4K.
    ctx.save(); hudZoomIn('msg',W/2,0);
'@

SubRx @'
  // timer + compass
  // v9.56, HIS REPORT: "numbers and text at the top are way too tiny and
  // colliding lol". Both, and both from the same place: this block was drawn at
  // the literal baselines 30, 46, 60 and 82. Literals do not grow with the
  // screen, so at 4K it sat in the top 82 pixels at its 1080p size; and 30 to 46
  // is sixteen pixels for a font that renders at twenty four, so the clock's
  // descent has been running into the line beneath it at every size since the
  // text scale went above 1.
  // It stacks from the size of its own type now. _yClk works out to exactly 30 at
  // 1920x1080, which is where the clock has always been.
  var _tz=hudRes(), _rushUI=arcadeRushOn(), _compX=W/2;   // v28.xx (cw-cx-rushlayout): the rush keeps navigation beside the clock, clear of the callout.
  var _fClk=FSz(TYPE.title,_tz), _fCmp=FSz(TYPE.label,_tz), _fMk=FSz(TYPE.head,_tz);
  function _fpx(f){ var m=/([\d.]+)px/.exec(f); return m?+m[1]:12; }
  var _hClk=_fpx(_fClk), _hCmp=_fpx(_fCmp), _hMk=_fpx(_fMk);
  var _yClk=Math.round(6*_tz+_hClk);
  // 0.30 of the line above is its descent, which is the part that was overlapping.
  var _yCmp=Math.round(_yClk+_hClk*0.30+_hCmp);
  var _yArw=Math.round(_yCmp+_hCmp*0.90);
  var _yMk =Math.round(_yArw+_hMk*1.30);
  ctx.font=_fClk; ctx.textAlign='center';
  // v9.35: with the clock off there is nothing to count down to, so the readout
  // counts UP instead. Leaving it frozen at the starting figure would have looked
  // like a broken timer rather than an absent one.
  // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The readout counts up only on a raid built with no
  // clock; a dial moved mid-raid used to flip a running countdown into a count up, and a count up into a negative countdown.
  var _noClk=!raidClockOn();
  // v15.43, hud audit finding: THE RAID CLOCK READS 0:10 WHEN TEN SECONDS IS SAID, AND 0:00 ONLY WHEN IT IS OUT. The countdown
  // rounded its seconds down, and tickClockWarn fires on the frame the clock crosses a mark. So TEN SECONDS was said and the
  // first tick played with 0:09 on screen, THIRTY SECONDS with 0:29 and 1 minute left with 0:59; the last tick played as the
  // figure turned 0:00, and a whole second then passed at 0:00 before the site began to burn. Once it burns the loop runs the
  // clock on below zero, and the floor of a negative figure drew -1:0-1, then -1:0-2 and -1:0-3. Every other countdown rounds
  // up (EXTRACT NOW, INBOUND, the closes in line on the map), so an extraction window clamped to the clock read 3S LEFT beside
  // 0:02. The countdown now rounds up and stops at zero: each figure turns on the same frame as its warning, 0:00 means the
  // clock is out, and red tests the figure shown, so it still starts at 0:44. The count up with the clock off, tickClockWarn
  // and every number are unchanged.
  var _tSrc=_noClk?(G.t||0):Math.ceil(Math.max(0,G.timeLeft));
  // v28.xx (cw-hudinset), the critic (o-120d): 'the timer, sun icon, extract chip and teal arrow are four separate floating pieces with no shared container; the extract timer is the number the player needs under pressure and is light on a busy backdrop'. In a raid with no score card (no career, no arcade) the clock, its sky icon, the extract line and its arrow stand on ONE centred card (_clkCard); the clock text is drawn by _clkJob once the card is down. With a score card (career, arcade) his order keeps the clock and the score as separate windows, so the extract line and its arrow share one card under the score card instead.
  var _clkJob=null, _clkTx='';
  CLKCARD.g=null;
  function _clkCard(hMin,botY){
    var ow=ctx.font, ctw, hw, x0, y0=Math.round(4*_tz), h;
    ctx.font=_fClk; ctw=ctx.measureText(_clkTx).width; ctx.font=ow;
    hw=Math.round(Math.max(hMin,ctw/2+30*_tz)+8*_tz); x0=Math.round(W/2-hw); h=Math.round(botY-y0);
    hudPlate(x0,y0,hw*2,h,null,HUDC.plate);
    CLKCARD.g=G; CLKCARD.k='one'; CLKCARD.x=x0; CLKCARD.y=y0; CLKCARD.w=hw*2; CLKCARD.h=h; CLKCARD.ay=Math.round(botY-5*_tz);
    if(_clkJob){ var jb=_clkJob; _clkJob=null; jb(); }
    ctx.textAlign='center';
  }
  var mm=Math.floor(_tSrc/60),ss=Math.floor(_tSrc%60);
  ctx.fillStyle=(!_noClk&&_tSrc<=CLOCK_RED)?'#ff5a4a':'#cdd6dd';   // v23.xx (his answer 19): red for the final minute
  // v22.xx, the raid text rewrite (R44): BARE HUD TEXT GETS THE OUTLINE. HIS ORDER (2026-10-09): the raid text reads like a shooter HUD,
  // where every word reads on any ground. The clock, the compass, the extraction band lines, the REVIVING word, the Crier countdown
  // and the party ping, Waypoint and arrow labels were filled with no outline and no plate, so over snow, a lit street or a fire they
  // washed out. Each now goes through hudText: a 2 x hudRes ink stroke with round joins, then the same fill. No shadowBlur (frame
  // cost); about twenty strokes a frame at most. The words, colours and places are unchanged.
  if(G.arcade||G.career){ var _arcB=arcadeScoreHud(_yClk,_tz)||0; try{ var _wxB=(CLOCKBOX.g===G&&CLOCKBOX.w>0)?CLOCKBOX:SCOREBOX; if(_wxB&&_wxB.g===G&&_wxB.w>0) wxIconDraw(Math.round(_wxB.x+_wxB.w+LH(16)*_tz),Math.round(_wxB.y+Math.min(_wxB.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}   /* v35.xx (cw-clockcard): beside the clock card */   /* v35.xx (cw-extpill): the sky beside the score block */ if(_arcB>0&&_yCmp<_arcB+Math.round(8*_tz+_hCmp*1.05)){ _yCmp=_arcB+Math.round(8*_tz+_hCmp*1.05); _yArw=Math.round(_yCmp+_hCmp*0.90); _yMk=Math.round(_yArw+_hMk*1.30); } } else {   /* v25.xx (topmid): the compass starts under the score block, not through its clock row */ _clkTx=mm+':'+(ss<10?'0':'')+ss; _clkJob=function(){ var _cpo; ctx.font=_fClk; ctx.textAlign='center'; ctx.fillStyle=(!_noClk&&_tSrc<=CLOCK_RED)?'#ff5a4a':'#cdd6dd'; _cpo=(!_noClk&&_tSrc<=CLOCK_RED&&_tSrc>0)?clockPopIn(W/2,_yClk-_hClk*0.35,G.timeLeft):false; hudText(_clkTx,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(_clkTx).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }; }   /* v35.xx (cw-extpill): the sky beside the clock */   /* v23.xx (his answer 19): it pops on every second of the final minute */   // v23.29 (arcade8): in the arcade, TEAM SCORE in place of the clock // v28.xx (cw-cx-hudtvread): the extraction pill clears the score plate by 8 scaled pixels.
  // HIS NOTE, 2026-08-26: "can you make it point to the NEAREST extraction instead,
  // and make it switch any time the player finds a nearer extraction -- also ...
  // the beacon indicator should change to like 'Marked Waypoint' and point to that
  // instead". It pointed at G.active, which is whichever ring the raid nominated,
  // and it never changed as you moved. On a map with three open extracts that
  // means the arrow can point AWAY from the nearest way out, which is the single
  // worst thing a compass can do.
  // A waypoint outranks the extracts when one is set, because a waypoint is an
  // explicit instruction and the nearest extract is only a default. Once the
  // beacon is actually inbound the compass locks to THAT ring regardless, because
  // at that point there is only one way out that matters and pointing anywhere
  // else would get him killed.
  var _tgt=null,_lbl='',_col='#4de3d0';
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "extraction arrow should always point to the closest extraction point". A live beacon no longer holds the arrow:
  // the beacon mirror makes ANY live ring G.active (a pillager's call or a teammate's across the map), so it pointed far away. It is the nearest open
  // ring now, called or not (the pill still names that ring's state); a waypoint he set himself still wins.
  if(G.waypoint){
    _tgt=G.waypoint; _lbl='mark'; _col=netMarkColour(NET.seat);
  } else {
    var _bd=1e9;
    for(var _zi=0;_zi<G.zones.length;_zi++){
      var _z=G.zones[_zi];
      if(_z.open===false) continue;
      var _dz=dist(p,_z);
      if(_dz<_bd){ _bd=_dz; _tgt=_z; }
    }
    _lbl='EXTRACT';
    if(!_tgt){ _tgt=G.active; _lbl='EXTRACTION'; }
  }
  HUDTOPB=(G.arcade||G.career)?Math.max((SCOREBOX.g===G)?SCOREBOX.y+SCOREBOX.h:0,Math.round(_yCmp+_hCmp*0.3)):0;   // v35.xx (cw-clockcard): the alert band starts under the top centre stack
  if(_rushUI&&SCOREBOX.g===G) HUDTOPB=SCOREBOX.y+SCOREBOX.h;   // v28.xx (cw-cx-rushlayout): the side compass no longer occupies the alert column.
  if(_tgt){
    var za=Math.atan2(_tgt.y-p.y,_tgt.x-p.x),zd=Math.round(dist(p,_tgt));
    ctx.font=_fCmp; ctx.fillStyle=_col;
    // v28.xx (cw-extplate), the critic (2026-10-19): 'extract 148m is bare teal text, no plate'. The distance line sits on the HUD plate like the score block above it.
    var _xps=extPillState(_lbl==='WAYPOINT'?null:_tgt,_lbl), _xpt=_lbl+' '+metres(zd)+'m'+_xps.tail; if(_xps.col) _col=_xps.col;   // v35.xx (cw-extpill): the exit's state on the pill
    var _epw=Math.round(ctx.measureText(TX(_xpt)).width+LH(20)), _eph=Math.round(_hCmp*1.5), _xpk=extPillPulse(_xps), _xpx=Math.round(W/2-_epw/2), _xpy=Math.round(_yCmp-_hCmp*1.05);
    // v28.xx (cw-cx-rushlayout): move the existing extraction chip and arrow together, without duplicating a navigation control.
    if(_rushUI&&CLOCKBOX.g===G){
      _compX=Math.round(CLOCKBOX.x-24*_tz-_epw/2);
      _yCmp=Math.round(CLOCKBOX.y+CLOCKBOX.h/2+_hCmp*0.35);
      _yArw=Math.round(_yCmp+_hCmp*1.2);
      _xpx=Math.round(_compX-_epw/2); _xpy=Math.round(_yCmp-_hCmp*1.05);
    }
    // v28.xx (cw-hudinset): ONE CARD. The arrow stands 4 px lower so it clears the words, and sits inside the card with the extract line. No score card: the clock card is this card (_clkCard). A score card above: the extract card is as wide as the score card and holds the arrow.
    var _oneCard=!!_clkJob, _rowCard=!!(G.arcade||G.career), _az0=_tz*(G.arcade?ARCADE_ARW:1), _cdX=_xpx, _cdY=_xpy, _cdW=_epw, _cdH=_eph, _ayy;
    if(_oneCard||_rowCard) _yArw+=Math.round(4*_tz);
    _ayy=_yArw+(G.arcade?Math.round(8*_tz):0);
    if(_rowCard){
      if(!_rushUI&&SCOREBOX.g===G&&SCOREBOX.w>_cdW){ _cdW=SCOREBOX.w; _cdX=Math.round(_compX-_cdW/2); }
      _cdH=Math.round(_ayy+5*_az0+5*_tz-_cdY);
      CLKCARD.g=G; CLKCARD.k='row'; CLKCARD.x=_cdX; CLKCARD.y=_cdY; CLKCARD.w=_cdW; CLKCARD.h=_cdH; CLKCARD.ay=Math.round(_ayy+5*_az0);
    }
    if(_oneCard){ _clkCard(_epw/2,Math.round(_ayy+5*_az0+5*_tz)); _cdX=CLKCARD.x; _cdY=CLKCARD.y; _cdW=CLKCARD.w; _cdH=CLKCARD.h; ctx.font=_fCmp; ctx.fillStyle=_col; }
    ctx.save();
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(_compX,_cdY+_cdH/2); ctx.scale(_xsc,_xsc); ctx.translate(-_compX,-(_cdY+_cdH/2)); }
    if(!_oneCard) hudPlate(_cdX,_cdY,_cdW,_cdH,null,HUDC.plate);
    if(_xpk>0||_xps.st==='closing'||_xps.st==='closed'){ ctx.save(); ctx.globalAlpha=(_xpk>0)?(1-_xpk*0.7):0.8; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.strokeStyle=_col; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_cdX+0.5,_cdY+0.5,_cdW-1,_cdH-1,Math.min(_cdH/2,LH(4))); else ctx.rect(_cdX,_cdY,_cdW,_cdH); ctx.stroke(); ctx.restore(); }   // v35.xx (cw-extpill): the state's edge, and the ring of the one pulse
    ctx.fillStyle=_col;
    hudText(_xpt,_compX,_yCmp);
    ctx.restore(); EXTPILL.st=_xps.st; EXTPILL.col=_col; EXTPILL.txt=_xpt;   // v35.xx (cw-extpill)
    var _az=_tz*(G.arcade?ARCADE_ARW:1);   // v23.35 (arcade13): in the arcade the arrow is twice the size, set lower so it clears the label
    ctx.save(); ctx.translate(_compX,_yArw+(G.arcade?Math.round(8*_tz):0)); ctx.rotate(za+Math.PI/2);
    ctx.fillStyle=_col;
    // the arrow is geometry, so it scales with the screen like the type does
    ctx.beginPath(); ctx.moveTo(0,-8*_az); ctx.lineTo(-5*_az,5*_az); ctx.lineTo(5*_az,5*_az); ctx.closePath(); ctx.fill();
    if(G.arcade){ ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.lineJoin='round'; ctx.stroke(); }
    ctx.restore();
    if(G.arcade||G.career) HUDTOPB=Math.max(HUDTOPB,Math.round(_yArw+(G.arcade?8*_tz:0)+8*_az));   // v35.xx (cw-clockcard)
  }
  if(_clkJob) _clkCard(0,Math.round(_yClk+_hClk*0.30+6*_tz));   // v28.xx (cw-hudinset): no extraction to point at (all shut): the clock and its sky icon still stand on their card
'@ @'
  // timer + compass
  // v37.xx (cw-topstrip): the rail (his order, above railOn). The plate first, then the score, the clock with the sky, the way out. The sizes are his approved picture at 1080p: a 52 px rail, the clock 44, the score and the way out 32.
  var _tpz=railZ(), _tpH=railH(), _tpM=Math.round(_tpH/2), _tpIn=Math.round(24*_tpz), _fClk=railF(TYPE.num), _fExt=railF(TYPE.title,1.23);
  var _tpDn=!!p.downed, _tpAl=alertUp(), _tpDg=(_tpAl&&!_tpDn&&(alertDanger(_tpAl.k)||_tpAl.key==='finalrush'))?alertA(_tpAl):0;
  RAIL.g=G; RAIL.h=_tpH; RAIL.b=_tpH; RAIL.m=_tpM; RAIL.in=_tpIn; RAIL.scR=_tpIn; RAIL.clL=W/2; RAIL.clR=W/2; RAIL.skR=W/2; RAIL.exL=W-_tpIn;
  HUDTOPB=_tpH; SCOREBOX.g=null; CLOCKBOX.g=null;
  var _tpFd=hudFadeBegin('rail');
  try{
  hudFadeRect(0,0,W,_tpH);
  ctx.fillStyle=_tpDn?'rgba(52,14,12,.95)':HUDC.plate; ctx.fillRect(0,0,W,_tpH);
  if(_tpDg>0){ var _tpLn=Math.max(2,Math.round(3*_tpz)); ctx.save(); ctx.globalAlpha*=_tpDg; ctx.fillStyle='rgba(66,18,15,.94)'; ctx.fillRect(0,0,W,_tpH); ctx.fillStyle=HUDC.danger; ctx.fillRect(0,_tpH-_tpLn,W,_tpLn); ctx.restore(); }
  else if(!_tpDn){ ctx.fillStyle='rgba(255,255,255,.14)'; ctx.fillRect(0,_tpH-1,W,1); }
  if((G.arcade||G.career)&&!_tpDn) arcadeScoreHud(_tpM,_tpz);   // down, the left of the rail is the down card
  // v9.35: with the clock off there is nothing to count down to, so the readout
  // counts UP instead. Leaving it frozen at the starting figure would have looked
  // like a broken timer rather than an absent one.
  // v15.14, dials audit finding 6: A RAID KEEPS THE CLOCK IT STARTED WITH. The readout counts up only on a raid built with no
  // clock; a dial moved mid-raid used to flip a running countdown into a count up, and a count up into a negative countdown.
  var _noClk=!raidClockOn();
  // v15.43, hud audit finding: THE RAID CLOCK READS 0:10 WHEN TEN SECONDS IS SAID, AND 0:00 ONLY WHEN IT IS OUT. The countdown
  // rounded its seconds down, and tickClockWarn fires on the frame the clock crosses a mark. So TEN SECONDS was said and the
  // first tick played with 0:09 on screen, THIRTY SECONDS with 0:29 and 1 minute left with 0:59; the last tick played as the
  // figure turned 0:00, and a whole second then passed at 0:00 before the site began to burn. Once it burns the loop runs the
  // clock on below zero, and the floor of a negative figure drew -1:0-1, then -1:0-2 and -1:0-3. Every other countdown rounds
  // up (EXTRACT NOW, INBOUND, the closes in line on the map), so an extraction window clamped to the clock read 3S LEFT beside
  // 0:02. The countdown now rounds up and stops at zero: each figure turns on the same frame as its warning, 0:00 means the
  // clock is out, and red tests the figure shown, so it still starts at 0:44. The count up with the clock off, tickClockWarn
  // and every number are unchanged.
  var _tSrc=_noClk?(G.t||0):Math.ceil(Math.max(0,G.timeLeft));
  var mm=Math.floor(_tSrc/60),ss=Math.floor(_tSrc%60);
  // v23.xx (his answer 19): red for the final minute, and it pops on every second of it. v22.xx (R44): bare HUD text gets the outline.
  if(!(G.arcade||G.career)||!_noClk){
    var _clkTx=mm+':'+(ss<10?'0':'')+ss, _clkRed=!_noClk&&_tSrc<=CLOCK_RED, _clkHw, _cpo;
    ctx.font=_fClk; ctx.textAlign='center'; _clkHw=Math.ceil(Math.max(ctx.measureText('10:00').width,ctx.measureText(_clkTx).width)/2);
    _cpo=(_clkRed&&_tSrc>0)?clockPopIn(W/2,_tpM,G.timeLeft):false;
    ctx.fillStyle=_clkRed?'#ff5a4a':'#cdd6dd';
    hudText(_clkTx,W/2,railBase(_fClk,_tpM));
    if(_cpo) ctx.restore();
    CLOCKBOX.g=G; CLOCKBOX.x=Math.round(W/2-_clkHw); CLOCKBOX.y=0; CLOCKBOX.w=_clkHw*2; CLOCKBOX.h=_tpH;
    RAIL.clL=CLOCKBOX.x; RAIL.clR=CLOCKBOX.x+CLOCKBOX.w;
  }
  try{ var _wxR=Math.round(LH(13)*_tpz), _wxX=Math.round(RAIL.clR+10*_tpz+_wxR); wxIconDraw(_wxX,_tpM,_wxR); RAIL.skR=_wxX+_wxR; }catch(_wxa){}   // v35.xx (cw-extpill): the sky beside the clock
  // HIS NOTE, 2026-08-26: "can you make it point to the NEAREST extraction instead,
  // and make it switch any time the player finds a nearer extraction -- also ...
  // the beacon indicator should change to like 'Marked Waypoint' and point to that
  // instead". It pointed at G.active, which is whichever ring the raid nominated,
  // and it never changed as you moved. On a map with three open extracts that
  // means the arrow can point AWAY from the nearest way out, which is the single
  // worst thing a compass can do.
  // A waypoint outranks the extracts when one is set, because a waypoint is an
  // explicit instruction and the nearest extract is only a default. Once the
  // beacon is actually inbound the compass locks to THAT ring regardless, because
  // at that point there is only one way out that matters and pointing anywhere
  // else would get him killed.
  var _tgt=null,_lbl='',_col='#4de3d0';
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "extraction arrow should always point to the closest extraction point". A live beacon no longer holds the arrow:
  // the beacon mirror makes ANY live ring G.active (a pillager's call or a teammate's across the map), so it pointed far away. It is the nearest open
  // ring now, called or not (the pill still names that ring's state); a waypoint he set himself still wins.
  if(G.waypoint){
    _tgt=G.waypoint; _lbl='mark'; _col=netMarkColour(NET.seat);
  } else {
    var _bd=1e9;
    for(var _zi=0;_zi<G.zones.length;_zi++){
      var _z=G.zones[_zi];
      if(_z.open===false) continue;
      var _dz=dist(p,_z);
      if(_dz<_bd){ _bd=_dz; _tgt=_z; }
    }
    _lbl='EXTRACT';
    if(!_tgt){ _tgt=G.active; _lbl='EXTRACTION'; }
  }
  if(_tgt){
    var za=Math.atan2(_tgt.y-p.y,_tgt.x-p.x),zd=Math.round(dist(p,_tgt));
    ctx.font=_fExt; ctx.textAlign='right';
    var _xps=extPillState(_lbl==='WAYPOINT'?null:_tgt,_lbl), _xpt=_lbl+' '+metres(zd)+'m'+_xps.tail; if(_xps.col) _col=_xps.col;   // v35.xx (cw-extpill): the exit's state on the pill
    var _az=_tpz*(G.arcade?ARCADE_ARW:1.3), _axw=Math.round(16*_az), _axx=Math.round(W-_tpIn-_axw/2), _xtr=Math.round(_axx-_axw/2-12*_tpz), _xtw=Math.ceil(ctx.measureText(TX(_xpt)).width), _xpk=extPillPulse(_xps), _cdX=Math.round(_xtr-_xtw-10*_tpz), _cdY=Math.round(5*_tpz), _cdW=Math.round(W-_tpIn+8*_tpz-_cdX), _cdH=_tpH-2*_cdY;
    RAIL.exL=_cdX;
    ctx.save();
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk), _xcx=_cdX+_cdW/2; ctx.translate(_xcx,_tpM); ctx.scale(_xsc,_xsc); ctx.translate(-_xcx,-_tpM); }
    if(_xpk>0||_xps.st==='closing'||_xps.st==='closed'){ ctx.save(); ctx.globalAlpha=(_xpk>0)?(1-_xpk*0.7):0.8; ctx.lineWidth=Math.max(1.5,1.5*_tpz); ctx.strokeStyle=_col; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_cdX+0.5,_cdY+0.5,_cdW-1,_cdH-1,Math.min(_cdH/2,LH(4))); else ctx.rect(_cdX,_cdY,_cdW,_cdH); ctx.stroke(); ctx.restore(); }   // v35.xx (cw-extpill): the state's edge, and the ring of the one pulse
    ctx.fillStyle=_col;
    hudText(_xpt,_xtr,railBase(_fExt,_tpM));
    ctx.restore(); EXTPILL.st=_xps.st; EXTPILL.col=_col; EXTPILL.txt=_xpt;   // v35.xx (cw-extpill)
    ctx.save(); ctx.translate(_axx,_tpM); ctx.rotate(za+Math.PI/2);   // v23.35 (arcade13): the arcade arrow is the bigger one
    ctx.fillStyle=_col;
    // the arrow is geometry, so it scales with the screen like the type does
    ctx.beginPath(); ctx.moveTo(0,-8*_az); ctx.lineTo(-5*_az,5*_az); ctx.lineTo(5*_az,5*_az); ctx.closePath(); ctx.fill();
    if(G.arcade){ ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1.5,1.5*_tpz); ctx.lineJoin='round'; ctx.stroke(); }
    ctx.restore();
  }
  ctx.textAlign='center'; ctx.font=railF(TYPE.label);
  } finally { hudFadeEnd(_tpFd,null); }
'@

SubRx @'
    return {msg:null,sub:'Nearest extraction is '+metres(closestRingDist(p))+'m away',col:'#ff5a4a'};
'@ @'
    return null;   // v37.xx (cw-topstrip): the way out and its distance stand on the rail
'@

SubRx @'
  if(p.downed){
    // THE WASH IS DRAWN OUTSIDE THE SCALE, deliberately. It has to cover the
    // whole screen, and a fillRect(0,0,W,H) under a 2x scale about the centre
    // covers a quarter of it.
    ctx.fillStyle='rgba(60,8,5,.30)'; ctx.fillRect(0,0,W,H);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'the heavy red wash tints every HUD colour'): the downed wash is 30 percent, was 45, so the HUD keeps its contrast
    hudFadeCall('downed',function(){
    // v9.08, HIS NOTE: this block is too small. Everything below scales with the
    // SCREEN as well as the text setting, which is the half that was missing:
    // the type roles and LH follow the TEXT SIZE setting only, so at 4K this was
    // drawn at its 1080p pixel size while every other panel had doubled. One
    // transform about the centre rather than arithmetic on nine coordinates, so
    // the bar, the gaps and the type all keep their relationship.
    // hudRes() is exactly 1 at 1920x1080, so 1080p is unchanged by this.
    ctx.save();
    var _dwz=hudRes();
    ctx.translate(W/2,H/2); ctx.scale(_dwz,_dwz); ctx.translate(-W/2,-H/2);
    // v9.61: STACKED FROM THE HEIGHT OF ITS OWN TYPE, not from nine literal
    // offsets. The timer used to sit at H/2-9 with the line under it at H/2+6,
    // and both render at 23, so the timer was inside that line by 8 pixels at
    // 1080p and 17 at 4K. Rows are a full line apart now and cannot touch.
    var _fH=FS(TYPE.huge), _fD=FS(TYPE.head);
    function _dpx(f){ var m=/([\d.]+)px/.exec(f); return m?+m[1]:14; }
    var _hH=_dpx(_fH), _hD=_dpx(_fD);
    ctx.font=_fH; ctx.textAlign='center';
    var _dy=H/2-34;                                  // unchanged at 1920x1080
    // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "when player is downed, the downed card blocks the view of the centered player -- needs to move up". The card lifts until
    // its bottom edge is DOWNGAP over the screen centre (the player), never higher than the top centre stack.
    try{ var _dpR=downPlateRect(W/2,_dy,_hH,_hD,!!p.revived,CFG.giveUp!==0,!!(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)),downedVerb(),p.dbOn===1), _dLift=Math.max(0,Math.round(_dpR.y+_dpR.h-(H/2-DOWNGAP))), _dCap=Math.floor(_dpR.y-H/2-((HUDTOPB||0)+LH(8)-H/2)/_dwz); _dLift=Math.max(0,Math.min(_dLift,_dCap)); if(_dLift>0) ctx.translate(0,-_dLift); DOWNLIFT=_dLift; DOWNTOP=Math.round(H/2+_dwz*((_dpR.y-_dLift)-H/2)); }catch(_dlf){}
    try{ downPlateDraw(downPlateRect(W/2,_dy,_hH,_hD,!!p.revived,CFG.giveUp!==0,!!(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)),downedVerb(),p.dbOn===1)); }catch(_dpl){}   // v28.xx (cw-downplate)
    ctx.font=FS(TYPE.title); ctx.fillStyle=UIC.danger; ctx.fillText('DOWN',W/2,_dy-Math.round((_hH-_dpx(FS(TYPE.title)))*0.5));   // v34.40 (cw-downedcard2), critic on screen 34 (P1 'the small down label is easy to miss'): the danger label is the title size (26), the timer stays the one hero   // v34.39 (cw-downedcard), critic on screen 34: the word down is a danger label at the callout size; the timer below is the one hero
    try{ downBarDraw(W/2,_dy-_hH-4,p); }catch(_dbd){}   // v28.xx (downbar1): the slider bar, above the title, inside the same scale
    // The bar clears DOWN by its descent, and is narrower so the timer beside it
    // has room of its own instead of leaning on the line below.
    var _tmY=_dy+Math.round(_hH*1.05), _barY=_dy+Math.round(_hH*0.42)+Math.round(_hH*1.05);   // v28.xx (cw-downplate2): the timer has its own row under the word down, centred
    bar(W/2-100,_barY,200,10,p.downT/(p.downMax||CFG.downTime),UIC.tx_2);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'three red elements stacked, use one accent per card'): the bleed bar is neutral, the danger red stays on the label and the slider   // v34.39 (cw-downedcard): the guide danger colour
    // cw-downgain, HIS WORDS (2026-10-18): "players clock should include 2 decimals so that it is shown to run down". Left aligned so the digits do not
    // push into the bar as they change, and green while a hit's +0.50s shows.
    ctx.font=FS(TYPE.num); ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':UIC.tx_1; ctx.textAlign='center';   // v34.39 (cw-downedcard): the timer is the hero, the biggest type on the card (44, the HUD hero size), in the text colour   // v28.xx (cw-downplate2): one centred column (critic on screen 34: the timer was pushed to the plate edge)
    ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',W/2,_tmY);
    var _rowY=_barY+10+Math.round(_hD*1.15);
    ctx.font=_fD; ctx.fillStyle='#e8d5d2';
    // v8.87, his wording. The old line opened with what he had just used up.
    // This opens with what he can still do about it.
    if(p.revived) ctx.fillText('Bleeding out. Crawl to an open extraction point.',W/2,_rowY);
    else{   // v34.40 (cw-downedcard2), critic on screen 34 (P1 'make the self-revive prompt the lime action'): the live key is the accent, the rest is the text colour
      // v36.79 (cw-downedpolish), critic on screen 34 (P1 'self-revive is the primary action but has no key chip'): the key stands on the shared keycap (hudKey, the one the prompts and the controls list use), then the words
      var _k1=keyLabel('KeyF','F'), _k2='SELF-REVIVE, one per raid', _ka=Math.round(_hD*0.72), _kgap=LH(8), _kw0=Math.max((_ka+LH(7))*0.9,hudRawW(_k1.toLowerCase())+LH(10))+LH(2), _kx=W/2-(_kw0+_kgap+ctx.measureText(_k2.toLowerCase()).width)/2;
      hudKey(_k1,_kx,_rowY,_ka,0); ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; ctx.fillText(_k2,_kx+_kw0+_kgap,_rowY); ctx.textAlign='center';
    }
    // v21.61, HIS NOTE (2026-10-09): "when downed and holding E to extract, there's no clear progress bar on the downed screen that tells
    // you that you are extracting". The ring prompt and its hold bars are drawn only for a player on his feet, so a downed player
    // holding E in a ring saw nothing move. The downed screen now shows the hold itself, as large as the bleed bar above it.
    if(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)){
      var _xp=(padZ.pullT||0)>0, _xf=_xp?clamp(padZ.pullT/1.4,0,1):clamp(padZ.callT/1.6,0,1), _xc=_xp?'#7fc4a0':'#4de3d0';
      _rowY+=Math.round(_hD*1.35);
      ctx.font=_fD; ctx.fillStyle=_xc;
      ctx.fillText(_xp?'EXTRACTING':'CALLING EXTRACTION',W/2,_rowY);
      bar(W/2-100,_rowY+Math.round(_hD*0.4),200,10,_xf,_xc);
      _rowY+=Math.round(_hD*0.4)+10;
    }
    // v9.71: the surrender, offered only in the state he described. It lights up
    // as he holds it and the bar is the same 200 wide as the bleed bar above, so
    // the two read as the same instrument.
    if(p.revived&&CFG.giveUp!==0){
      var _gp=Math.min(1,(p.giveT||0)/GIVEUP_HOLD());
      _rowY+=Math.round(_hD*1.25);
      // v12.81, 2026-09-07 audit: AND IT SAYS SO WHEN IT WILL NOT TAKE THE KEY.
      // The v9.71 guard refuses the surrender while an extraction is waiting on
      // the point he is lying in, silently: this row printed the prompt anyway,
      // the key did nothing, the bar never appeared and nothing explained it. It
      // reads the same test the key reads now, and says what is true, with the
      // working verb still drawn underneath it in colour.
      ctx.font=_fD; ctx.fillStyle='#9b8f8c';
      if(surrenderBlocked()) ctx.fillText('NO SURRENDER WITH AN EXTRACTION WAITING',W/2,_rowY);
      else{
      ctx.fillStyle=_gp>0?'#ff8a76':'#9b8f8c';
      ctx.fillText('HOLD ['+keyLabel('Space','SPACE')+'] TO SURRENDER',W/2,_rowY);
      }
      if(_gp>0){
        _rowY+=Math.round(_hD*0.50);
        bar(W/2-100,_rowY,200,6,_gp,'#ff5a4a');
        _rowY+=6;
      }
    }
    // The verb, in the same stack and the same coordinate system as everything
    // above it. This used to be a separate block drawn afterwards at an unscaled
    // H/2+64.
    var _dv=downedVerb();
    if(_dv){
      if(_dv.msg){
        _rowY+=Math.round(_hD*1.5);
        ctx.font=_fH; ctx.fillStyle=_dv.col;
        ctx.fillText(_dv.msg,W/2,_rowY);
        _rowY+=Math.round(_hH*0.30);
      }
      if(_dv.sub){
        _rowY+=Math.round(_hD*1.35);
        ctx.font=_fD; ctx.fillStyle='#e8e2d5';
        ctx.fillText(_dv.sub,W/2,_rowY);
      }
    }
    // HIS RUN #44: "couldn't call the beacon when downed in the extraction
    // circle". Driven before touching anything: THE CALL WORKS FROM THE FLOOR
    // and has since v2.30, E passes through and 1.6 held seconds set the
    // beacon. What was missing was any pixel saying so. The downed overlay
    // covered every state except this one: in the ring, no ship called. A man
    // holding a dead-feeling key for a second with no response concludes it
    // does not work, and he is right to.
    // v14.13, HUD audit: the ring he is lying in, uncalled, whatever the global pointer says about another ring.
    var _cr=(typeof standingRing==='function')?standingRing():G.active;
    if(_cr&&_cr.open!==false&&(_cr.beaconT===null||_cr.beaconT===undefined)&&dist(p,_cr)<_cr.r){
      _rowY+=Math.round(_hD*1.35);
      ctx.font=_fD; ctx.fillStyle='#4de3d0';
      ctx.fillText('HOLD ['+keyLabel('KeyX','X')+'] TO CALL FOR EXTRACTION',W/2,_rowY);   // v22.66 (R24): the key in brackets
      if(_cr.callT>0) bar(W/2-70,_rowY+Math.round(_hD*0.45),140,7,clamp(_cr.callT/1.6,0,1),'#4de3d0');
    }
    ctx.textAlign='left';
    ctx.restore();
    });
  }

'@ @'
  if(p.downed){
    // v37.xx (cw-topstrip), his order (above railOn): NO CENTRE CARD. Down, the timer, the words and the slider stand on the rail, and the bleed bar runs along its bottom edge. The wash starts under the rail so the rail's words stay clean.
    HUDTOPB=RAIL.b;
    ctx.fillStyle='rgba(60,8,5,.30)'; ctx.fillRect(0,_tpH,W,H-_tpH);   // v34.40 (cw-downedcard3), critic on screen 34: the downed wash is 30 percent
    hudFadeCall('downed',function(){
    ctx.save();
    var _dxf=railF(TYPE.title,1.23), _dkf=railF(TYPE.title,1.04), _dx=_tpIn, _dgp=Math.round(14*_tpz), _dR=RAIL.clL-Math.round(20*_tpz);
    ctx.textAlign='left';
    ctx.font=_dxf; ctx.fillStyle=UIC.danger; ctx.fillText('DOWN',_dx,railBase(_dxf,_tpM)); _dx+=Math.ceil(ctx.measureText(TX('DOWN')).width)+_dgp;
    // cw-downgain, HIS WORDS (2026-10-18): "players clock should include 2 decimals so that it is shown to run down". A fixed width so nothing beside it moves as the digits change, green while a hit's +0.50s shows.
    ctx.font=_fClk; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':UIC.tx_1;
    ctx.fillText(Math.max(0,p.downT).toFixed(2)+'s',_dx,railBase(_fClk,_tpM)); _dx+=Math.ceil(ctx.measureText('88.88s').width)+Math.round(_dgp*1.5);
    // v8.87, his wording. The old line opened with what he had just used up.
    // This opens with what he can still do about it.
    if(p.revived){
      var _drl='Bleeding out. Crawl to an open extraction point.', _dlf=railFit(_dkf,_drl,_dR-_dx);
      ctx.font=_dlf; ctx.fillStyle='#e8d5d2'; ctx.fillText(_drl,_dx,railBase(_dlf,_tpM));
    } else {   // v36.79 (cw-downedpolish): the key stands on the shared keycap, then the words
      var _k1=keyLabel('KeyF','F'), _k2='SELF-REVIVE, one per raid', _ka, _kw, _kf;
      ctx.font=_dkf; _ka=Math.round(msgPx(_dkf)*0.72); _kw=hudKey(_k1,_dx,railBase(_dkf,_tpM),_ka,0)+LH(2)+Math.round(8*_tpz);
      _kf=railFit(_dkf,_k2,_dR-_dx-_kw); ctx.font=_kf; ctx.fillStyle=UIC.tx_1; ctx.fillText(_k2,_dx+_kw,railBase(_kf,_tpM));
    }
    // v28.xx (downbar1): the slider bar, on the right of the rail, between the sky and the way out
    try{ var _sL=RAIL.skR+Math.round(24*_tpz), _sR=RAIL.exL-Math.round(24*_tpz), _sW=Math.min(400*_tpz,_sR-_sL); ctx.save(); ctx.translate(Math.round((_sL+_sR)/2),_tpM); ctx.scale(_tpz,_tpz); downBarDraw(0,7,p,_sW/_tpz); ctx.restore(); }catch(_dbd){}
    // the bleed bar, the rail's bottom edge, draining to the middle. v34.40 (cw-downedcard3): neutral, the danger red stays on the label and the slider.
    var _dbf=clamp(p.downT/(p.downMax||CFG.downTime),0,1), _dbh=Math.max(3,Math.round(5*_tpz));
    ctx.fillStyle='rgba(0,0,0,.6)'; ctx.fillRect(0,_tpH-_dbh,W,_dbh);
    ctx.fillStyle=UIC.tx_2; ctx.fillRect(Math.round(W/2*(1-_dbf)),_tpH-_dbh,Math.round(W*_dbf),_dbh);
    var _drI=[];
    // v21.61, HIS NOTE (2026-10-09): "when downed and holding E to extract, there's no clear progress bar on the downed screen that tells
    // you that you are extracting". The hold shows here, under the rail.
    if(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)){
      var _xp=(padZ.pullT||0)>0, _xf=_xp?clamp(padZ.pullT/1.4,0,1):clamp(padZ.callT/1.6,0,1), _xc=_xp?'#7fc4a0':'#4de3d0';
      _drI.push({t:_xp?'EXTRACTING':'CALLING EXTRACTION',c:_xc,f:_xf,fc:_xc});
    }
    // v9.71: the surrender, offered only in the state he described.
    // v12.81, 2026-09-07 audit: AND IT SAYS SO WHEN IT WILL NOT TAKE THE KEY. It reads the same test the key reads.
    if(p.revived&&CFG.giveUp!==0){
      var _gp=Math.min(1,(p.giveT||0)/GIVEUP_HOLD());
      if(surrenderBlocked()) _drI.push({t:'NO SURRENDER WITH AN EXTRACTION WAITING',c:'#9b8f8c'});
      else _drI.push({t:'HOLD ['+keyLabel('Space','SPACE')+'] TO SURRENDER',c:_gp>0?'#ff8a76':'#9b8f8c',f:_gp>0?_gp:null,fc:'#ff5a4a'});
    }
    var _dv=downedVerb();
    if(_dv){ if(_dv.msg) _drI.push({t:_dv.msg,c:_dv.col}); if(_dv.sub) _drI.push({t:_dv.sub,c:'#e8e2d5'}); }
    // HIS RUN #44: "couldn't call the beacon when downed in the extraction circle". THE CALL WORKS FROM THE FLOOR and has since v2.30; what was missing was any pixel saying so.
    // v14.13, HUD audit: the ring he is lying in, uncalled, whatever the global pointer says about another ring.
    var _cr=(typeof standingRing==='function')?standingRing():G.active;
    if(_cr&&_cr.open!==false&&(_cr.beaconT===null||_cr.beaconT===undefined)&&dist(p,_cr)<_cr.r) _drI.push({t:'HOLD ['+keyLabel('KeyX','X')+'] TO CALL FOR EXTRACTION',c:'#4de3d0',f:_cr.callT>0?clamp(_cr.callT/1.6,0,1):null,fc:'#4de3d0'});
    // what is left goes on one short line under the rail, hugging its words, so the corner column stays clear
    if(_drI.length){
      var _dlf2=railF(TYPE.head,1.1), _drh=Math.round(34*_tpz), _drg=Math.round(26*_tpz), _drp=Math.round(14*_tpz), _drw=0, _dri, _drk, _drx, _dwt=[];
      ctx.font=_dlf2; for(_dri=0;_dri<_drI.length;_dri++){ _dwt[_dri]=ctx.measureText(TX(_drI[_dri].t)).width; _drw+=_dwt[_dri]; } _drw+=_drg*(_drI.length-1);
      _drk=Math.min(1,(W-_tpIn*2)/(_drw+_drp*2));
      ctx.fillStyle='rgba(52,14,12,.88)'; ctx.fillRect(Math.round(W/2-(_drw/2+_drp)*_drk),RAIL.b,Math.round((_drw+_drp*2)*_drk),_drh);
      ctx.save(); ctx.translate(W/2,RAIL.b+_drh/2); ctx.scale(_drk,_drk); ctx.textAlign='left'; _drx=-_drw/2;
      for(_dri=0;_dri<_drI.length;_dri++){
        ctx.fillStyle=_drI[_dri].c; ctx.fillText(_drI[_dri].t,_drx,Math.round(msgPx(_dlf2)*0.3));
        if(_drI[_dri].f>0) bar(_drx,Math.round(_drh/2-5*_tpz),_dwt[_dri],Math.max(2,Math.round(3*_tpz)),_drI[_dri].f,_drI[_dri].fc);
        _drx+=_dwt[_dri]+_drg;
      }
      ctx.restore();
      RAIL.b+=_drh; HUDTOPB=RAIL.b;
    }
    ctx.textAlign='left';
    ctx.restore();
    });
  }

'@

SubRx @'
// v28.xx (cw-downplate), critic on screen 34 (P0): "put a scrim plate behind the whole block, make the timer the hero". The downed words (down, bar,
// timer, self-revive, surrender, the extraction line) sat straight on the red wash and the busy world. They now sit on one shared panel (uiPanel,
// Panel P), sized from the same row math the block uses, and the timer is the big type of the word down. DP_DRAWS counts the plates for the check.
var DP_DRAWS=0;
function downPlateRect(cx,dy,hH,hD,revived,giveOn,hasPull,dv,barOn){
  var yb=dy-hH-4, top=barOn?(yb-14-3-16):(dy-hH-12), rowY=dy+Math.round(hH*0.42)+Math.round(hH*1.05)+10+Math.round(hD*1.15);
  if(hasPull) rowY+=Math.round(hD*1.35)+Math.round(hD*0.4)+10;
  if(revived&&giveOn) rowY+=Math.round(hD*1.25);
  if(dv){ if(dv.msg) rowY+=Math.round(hD*1.5)+Math.round(hH*0.30); if(dv.sub) rowY+=Math.round(hD*1.35); }
  return {x:Math.round(cx-240),y:top,w:480,h:rowY+16-top};
}
function downPlateDraw(r){ DP_DRAWS++; hudPanel(r.x,r.y,r.w,r.h,0.9,true); ctx.save(); ctx.fillStyle=UIC.danger; ctx.fillRect(r.x+14,r.y,36,3); ctx.restore(); }   // v34.39 (cw-downedcard), critic on screen 34 (P0 'flat box, not the standard panel; wants a 3px danger top tab'): the same panel as every raid panel (hudPanel, plain) plus a 3px danger tab on top

'@ @'

'@

SubRx @'
function downBarDraw(cx,yb,p){
  var BW=240, BH=14, x0, y0, zx, zw, f, inz, lk, st;
'@ @'
function downBarDraw(cx,yb,p,bw){
  var BW=bw||240, BH=14, x0, y0, zx, zw, f, inz, lk, st;
'@

SubRx @'
  if(p.dbGainT>0){   // cw-downgain: the time a hit gave back rises over the bar and fades
    var _gk=p.dbGainT/DB_POP; ctx.font=FS(TYPE.head); ctx.textAlign='center'; ctx.globalAlpha=Math.min(1,_gk*2); ctx.fillStyle='#9fe8b0';
    ctx.fillText('+'+(+p.dbGain||0).toFixed(2)+'s',cx,Math.round(y0-10-(1-_gk)*14)); ctx.globalAlpha=1;
  }
'@ @'
  if(p.dbGainT>0){   // cw-downgain: the time a hit gave back drops out under the rail and fades (v37.xx cw-topstrip: over the bar was off the top of the screen)
    var _gk=p.dbGainT/DB_POP; ctx.font=FS(TYPE.head); ctx.textAlign='center'; ctx.globalAlpha=Math.min(1,_gk*2); ctx.fillStyle='#9fe8b0';
    hudText('+'+(+p.dbGain||0).toFixed(2)+'s',cx,Math.round(y0+BH+40-(1-_gk)*8)); ctx.globalAlpha=1;
  }
'@

SubRx @'
function arcadeScoreHud(y,z){
  // v28.xx (cw-cx-hudtvread): readable score labels and a real top inset in both windows. Score, streak and final-minute clock rules stay the same.
  // v35.xx (cw-clockcard), HIS ORDER (2026-10-28): "score and clock should be separate windows.  Clock should be bigger than score and should be above score." The raid clock
  // has its own card on top, in the big number size (39 px at 1080p, over the score's 26), the same size all raid (red with its pop in the final minute, so the
  // score card under it never jumps). The score card under it keeps its label, its figure, the YOU and partner column and the streak. SCOREBOX stays the score card.
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var rushUI=arcadeRushOn();   // v28.xx (cw-cx-rushlayout): keep the larger clock above a quieter score window throughout the final rush.
  var cr=!G.arcade,solo=cr||!!ARCADE.solo,cx=Math.round(W/2),mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)),mate=cr?0:Math.max(0,ARCADE.mate|0),nm=arcadeCr(mine+mate),
      fb=FSz(rushUI?TYPE.head:TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
      clock=raidClockOn(),ct=Math.ceil(Math.max(0,+G.timeLeft||0)),fin=ct<=CLOCK_RED,fc=FSz(TYPE.huge,z),ch=parseFloat((/([\d.]+)px/.exec(fc)||[0,30])[1]),
      top=Math.round(16*z),pad=Math.round(12*z),cpad=Math.round(10*z),cw=0,cBot=0,clockY=0,labelY,scoreY,
      w,gx,pw,bot,side=0,apo=false;
  ctx.save();ctx.textAlign='center';
  CLOCKBOX.g=null;
  if(clock){
    ctx.font=fc;cw=Math.ceil(Math.max(70*z,ctx.measureText('10:00').width/2+cpad*1.6));
    clockY=top+cpad+Math.round(ch*0.92);cBot=Math.ceil(clockY+ch*0.22+cpad);
    hudFadeCall('clock',function(){
    hudPlate(cx-cw,top,cw*2,cBot-top,null,HUDC.plate);
    CLOCKBOX.g=G;CLOCKBOX.x=cx-cw;CLOCKBOX.y=top;CLOCKBOX.w=cw*2;CLOCKBOX.h=cBot-top;
    apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();
    });
    top=cBot+Math.round((rushUI?16:6)*z);   // v28.xx (cw-cx-rushlayout): a full 16px gap between the separate clock and score windows.
  }
  labelY=top+pad+lh;scoreY=labelY+Math.round(8*z)+h;
  ctx.font=fb;w=ctx.measureText(nm).width;
  if(!solo){ctx.font=fs;side=Math.max(ctx.measureText('YOU '+arcadeCr(mine)).width,ctx.measureText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate)).width)+Math.round(24*z);}
  pw=Math.ceil(Math.max(100*z,w/2+pad+side));
  ctx.font=fs; pw=Math.max(pw,Math.ceil(dmulTagW(ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z)+pad));   // v35.xx (cw-dmulshow): room for the multiplier tag
  bot=Math.ceil(scoreY+Math.max(h*.25,rushUI?lh:0)+pad);   // v28.xx (cw-cx-rushlayout): the partner figure keeps its descent and bottom inset with the quieter score font.
  hudFadeCall('score',function(){
  hudPlate(cx-pw,top,pw*2,bot-top,null,rushUI?'rgba(17,19,21,.96)':HUDC.plate);   // v28.xx (cw-cx-rushlayout): score labels stay legible over a wall or rain.
  SCOREBOX.g=G;SCOREBOX.x=cx-pw;SCOREBOX.y=top;SCOREBOX.w=pw*2;SCOREBOX.h=bot-top;
  ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText(solo?'SCORE':'TEAM SCORE',cx,labelY);
  dmulTag(cx,labelY,ctx.measureText(solo?'SCORE':'TEAM SCORE').width,z);   // v35.xx (cw-dmulshow): the settings multiplier beside the label
  ctx.font=fb;ctx.fillStyle=UIC.tx_1;hudText(nm,cx,scoreY);
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
  });
  ctx.restore();return bot;
}
'@ @'
function arcadeScoreHud(mid,z){
  // v28.xx (cw-cx-hudtvread): readable score labels and a real top inset in both windows. Score, streak and final-minute clock rules stay the same.
  // v37.xx (cw-topstrip), his order (above railOn): the score stands on the rail, at its left end, with the settings multiplier after it. The word score is gone on a solo raid: the sp says it. With two players: the team label, the sum, then both shares on the same line, and the shares step aside while an alert needs the room. SCOREBOX stays its rectangle.
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade,solo=cr||!!ARCADE.solo,mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)),mate=cr?0:Math.max(0,ARCADE.mate|0),nm=arcadeCr(mine+mate),
      fb=railF(TYPE.title,1.23),fm=railF(TYPE.title),fs=railF(TYPE.label,1.4),x=RAIL.in,x0=x,y=railBase(fb,mid),gap=Math.round(14*z),w,mt,lb;
  ctx.save();ctx.textAlign='left';
  if(!solo){ctx.font=fs;ctx.fillStyle=UIC.tx_2;hudText('TEAM SCORE',x,y);x+=Math.ceil(ctx.measureText(TX('TEAM SCORE')).width)+gap;}
  ctx.font=fb;ctx.fillStyle=UIC.tx_1;hudText(nm,x,y);w=Math.ceil(ctx.measureText(TX(nm)).width);x+=w;
  ctx.font=fm;mt=dmulTag(x-w/2,y,w,z);if(mt)x+=Math.round(8*z)+Math.ceil(ctx.measureText(mt).width);   // v35.xx (cw-dmulshow): the settings multiplier
  if(!solo&&!alertUp()){
    ctx.font=fs;ctx.fillStyle=UIC.tx_2;x+=gap*2;
    lb='YOU '+arcadeCr(mine);hudText(lb,x,y);x+=Math.ceil(ctx.measureText(TX(lb)).width)+gap;
    lb=(ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate);hudText(lb,x,y);x+=Math.ceil(ctx.measureText(TX(lb)).width);
  }
  ctx.restore();
  SCOREBOX.g=G;SCOREBOX.x=x0;SCOREBOX.y=0;SCOREBOX.w=x-x0;SCOREBOX.h=RAIL.h;RAIL.scR=x;
  return x;
}
'@

SubRx @'
function drawHUD(){
  hudFadeFrame();
'@ @'
// v37.xx (cw-topstrip), HIS ORDER (2026-11-02): "i don't like how all these different boxes take up so much of the screen, can we redesign this (and redesign player alerts) so that they all hit across the top edge of the screen somehow, leaving more screen space for play", and "they should fill across the entire top of the screen, leaving more room for gameplay". THE TOP STRIP. One rail across the whole top edge: the score at the left, the clock and the sky in the middle, the way out and its arrow at the right. An alert takes the room between the score and the clock and tints the rail. Down takes the left of the rail, the slider the right and the bleed bar its bottom edge. Only down can hang a short line under it, and only when that line has something to say. RAIL is the rail as last drawn, in screen pixels.
function railOn(){ return !!(G&&G.player&&!G.hubFloor&&!G.sim&&state==='raid'); }
function railZ(){ var r=hudRes(); return r*clamp(W/(1180*r),0.7,1); }   // a narrow window shrinks the whole rail, so its ends never reach the clock
function railF(spec,m){ var z=railZ()*(m||1); return FS(String(spec).replace(/([\d.]+)px/,function(_s,n){ return (Math.round(parseFloat(n)*z*100)/100)+'px'; })); }
function railH(){ return Math.round(msgPx(railF(TYPE.num))*1.18); }
function railBase(f,mid){ return Math.round(mid+msgPx(f)*0.35); }   // the baseline that centres this font's figures on the line
function railFit(f,s,w){ var o=ctx.font, tw; ctx.font=f; tw=ctx.measureText(TX(s)).width; ctx.font=o; return (tw>w&&w>0)?f.replace(/[\d.]+px/,(Math.floor(msgPx(f)*w/tw*100)/100)+'px'):f; }
function alertA(a){ return Math.max(0,Math.min(1,(((G&&G.t)||0)-a.at)/ALERTIN,a.T/0.4)); }   // how far in an alert has faded
function drawHUD(){
  hudFadeFrame();
'@

SubRx @'
var VER='37.45';
'@ @'
var VER='37.46';
'@

$pat = "(?m)^  now:'v37\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.46: One slim rail across the whole top edge. Score at the left, clock and sky in the middle, the way out and its arrow at the right. An alert stands on the rail against the clock and tints it red. Down takes the left of the rail with its timer and self-revive, the slider the right, and the bleed bar the bottom edge; no centre card any more, so the pillager stays in view. The corner column starts under the rail. Watch for: alerts with a long detail line on small windows, the go fullscreen button under the rail, and two players, whose shares step aside while an alert shows. Check 37.46 fails on v37.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
