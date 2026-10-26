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

# GUN CARD AND KEYS CHIP TIDY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ var _gz=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _wpR=W-8/_gz, _wtx=ctx.measureText(_cornName).width;
       // v24.xx (noequipline): no OTHER GUN line to measure; the card fits the gun name.
       var _wpx=Math.min(W-252,W-16-_wtx-LH(14)), _wpw=_wpR-_wpx, _hcL=(G.hotCells&&G.hotCells.length)?G.hotCells[G.hotCells.length-1]:null;
       var _gdx=(typeof _boG==='object'&&_boG)?(_boG.dx||0):0, _lim=_hcL?(W+((_hcL.x+_hcL.w+LH(8))-_gdx-W)/_gz):-1e9;   // the belt edge, brought into this corner's scaled space
       if(_hcL&&_wpx<_lim){ _wpx=_lim; _wpw=_wpR-_wpx; }   // v18.39: never over the belt (it covered key 9)
       /* v28.xx (cw-hudstar): the demo hides the item line and the backpack hint (Q56), so the card is 72 high and not 100 with an empty strip; it keeps the tab, it is the star */
       if(_wpw>LH(60)){ var _gtop=trDemo()?LH(62):LH(66), _gh=trDemo()?LH(58):LH(76); /* v28.xx (cw-cardhint), the critic (2026-10-19): the career card is 76 high, the backpack hint left the top (order: name, ammo, one quiet row) so the card has no dead strip over the name */   /* v28.xx (cw-panelflat), the critic (2026-10-19): the demo card had dead space over the name; it is 58 high, the top moves down 14 */ hudPanel(_wpx,by-_gtop,_wpw,_gh,0.88); } ctx.textAlign='right'; }catch(_wp){}
  ctx.fillText(_cornName,W-16,by-LH(46));   // v28.xx (cw-hudammo): the name rides higher (was 34) so the big ammo figure has the room
  ctx.font=FS(TYPE.title);
  if(!_heldGun){
    var _cn=(_HH.count===null||_HH.count===undefined)?null:_HH.count;
    ctx.fillStyle=(_cn===0)?'#ff5a4a':'#cdd6dd';
    ctx.fillText(_HH.kind==='empty'?'EMPTY':(_cn===null?'HELD':(_cn+' held')),W-16,by-LH(14));
  }
  else if(p.wep.mag===0){ ctx.fillStyle='#8a96a1'; ctx.fillText('MELEE',W-16,by-LH(14)); }
  else if(p.jam>0){ ctx.fillStyle='#ff5a4a'; ctx.fillText('JAMMED',W-16,by-LH(14)); }
  else if(p.reloading>0){ ctx.fillStyle='#ffc04a'; ctx.fillText('RELOADING',W-16,by-LH(14)); }
  else {
    ammoDraw(p,W-16,by-LH(14));   // v28.xx (cw-hudammo), his Q57: the rounds are the hero number
  }
'@ @'
  // v28.xx (cw-hudcorner), HIS NOTE (2026-10-25): "in raid, right hand lower corner menu and minizmized controls f1 key are awkward take a look". THE GUN CARD HUGS WHAT IT SHOWS.
  // It was at least 246 wide whatever it held, so behind a short gun name and 12 / 24 its left half was empty and the backpack row hung
  // at the bottom across the gap. It is as wide as its widest row now plus one padding _gP on all four sides: the right edge stays 8 px in
  // from the screen edge, the top is the top of the name less _gP, the bottom the bottom of the last row plus _gP, the rows keep their
  // baselines and the belt clamp stands. The box the mouse moves it by starts where the card starts. The short lime bar on its top edge
  // was the panel accent (cw-hudstar), not a meter, so it is gone.
  // IT NEVER CHANGES SIZE WHILE HE PLAYS. Each row is measured as the widest it can read with the same thing in hand, so a shot, a reload,
  // aiming in or out, a reserve or a count that loses a figure, or loot going in the backpack never moves an edge: the gun name with its
  // aim word on ([ADS] or the scope, as _cornName adds it), the rounds as a full magazine over a reserve of at least three figures and
  // never narrower than RELOADING or JAMMED, a held count of at least two figures, and the backpack row as at least two item figures and
  // five money figures. Every figure is measured as the widest digit of its face, as the digits of this face are not one width (a 1 is
  // 15 wide, a 4 is 26 at the ammo size). The card changes only on a swap, or when a count passes those figures.
  var _gX=W-16, _gP=LH(10), _gCW=0;
  try{ var _gz=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _wpR=W-8/_gz, _gFN=ctx.font, _gnW=ctx.measureText(_cornName).width, _gR2=0, _gFt=FS(TYPE.title), _gFm=FS(TYPE.num), _gFf=hudFineFS(), _gFoot=!trDemo(), _gcv=0, _gcq, _gFW=0, _gDs=0, _gA=0, _gT2, _gHint, _gCnt, _gCt, _gTop, _gBot, _gB, _gO, _gNm, _gWdC={};
       function _gMs(f,s){ ctx.font=f; return ctx.measureText(String(s)); }
       function _gDn(f,s){ var m=_gMs(f,s); return (m&&m.actualBoundingBoxDescent>0)?m.actualBoundingBoxDescent:0; }
       function _gWd(f,s){ var q, w, b=-1, d=_gWdC[f]; if(d===undefined){ d='0'; for(q=0;q<10;q++){ w=_gMs(f,String(q)).width; if(w>b){ b=w; d=String(q); } } _gWdC[f]=d; } return String(s).replace(/[0-9]/g,d); }   // every figure as the widest digit of face f
       if(_heldGun&&p.wep){ _gNm=p.wep.name; _gO=+p.wep.optic||0; _gnW=Math.max(_gnW,ctx.measureText(_gNm).width,ctx.measureText(_gNm+'  [ADS]').width,(_gO>1)?ctx.measureText(_gNm+'  '+(+_gO.toFixed(2))+'x SCOPE').width:0); }   // the name with its aim word on
       _gP=LH(8); _gX=_wpR-_gP;
       if(!_heldGun){ var _gcn=(_HH.count===null||_HH.count===undefined)?null:_HH.count; _gT2=_HH.kind==='empty'?'EMPTY':(_gcn===null?'HELD':(_gcn+' held')); _gR2=Math.max(_gMs(_gFt,_gT2).width,(_HH.kind==='empty'||_gcn===null)?0:_gMs(_gFt,_gWd(_gFt,Math.max(10,_gcn|0))+' held').width); _gDs=_gDn(_gFt,_gT2); }
       else if(p.wep.mag===0){ _gT2='MELEE'; _gR2=_gMs(_gFt,_gT2).width; _gDs=_gDn(_gFt,_gT2); }
       else {   // the rounds as ammoDraw draws them: a full magazine over a reserve of at least three figures, never narrower than RELOADING or JAMMED
         var _gMg=_gWd(_gFm,Math.max(p.wep.mag|0,p.ammo|0)), _gRs=' / '+_gWd(_gFt,Math.max(100,rsvShow(p)|0));
         _gR2=Math.max(_gMs(_gFt,_gRs).width+4+_gMs(_gFm,_gMg).width,_gMs(_gFt,' / '+rsvShow(p)).width+4+_gMs(_gFm,String(p.ammo)).width,_gMs(_gFt,'RELOADING').width,_gMs(_gFt,'JAMMED').width);
         _gDs=Math.max(_gDn(_gFt,_gRs),_gDn(_gFm,_gMg));
       }
       if(_gFoot){
         for(_gcq=0;_gcq<G.bag.length;_gcq++) _gcv+=ival(G.bag[_gcq]);
         _gCnt=G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_gcv.toLocaleString();
         _gCt=_gWd(_gFf,Math.max(10,G.bag.length))+' ITEMS  $'+_gWd(_gFf,Math.max(10000,_gcv).toLocaleString());   // at least two item figures and five money figures
         _gHint=padOn()?padB(pbn(8)+'  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK');
         _gFW=_gMs(_gFf,_gHint).width+LH(16)+Math.max(_gMs(_gFf,_gCnt).width,_gMs(_gFf,_gCt).width); _gDs=Math.max(_gDn(_gFf,_gHint),_gDn(_gFf,_gCt));
       }
       _gCW=Math.max(_gnW,_gR2,_gFW);
       var _wpx=_wpR-_gP*2-_gCW, _wpw, _hcL=(G.hotCells&&G.hotCells.length)?G.hotCells[G.hotCells.length-1]:null;
       var _gdx=(typeof _boG==='object'&&_boG)?(_boG.dx||0):0, _lim=_hcL?(W+((_hcL.x+_hcL.w+LH(8))-_gdx-W)/_gz):-1e9;   // the belt edge, brought into this corner's scaled space
       if(_hcL&&_wpx<_lim) _wpx=_lim;   // v18.39: never over the belt (it covered key 9)
       _wpw=_wpR-_wpx;
       ctx.font=_gFN; _gA=(TXMW?TXMW.call(ctx,'Hl'):ctx.measureText('Hl')).actualBoundingBoxAscent||0;   // one name height for every gun, so a swap never moves the top
       _gTop=by-LH(46)-_gA-_gP; _gBot=(_gFoot?by:by-LH(14))+_gDs+_gP;
       if(_wpw>LH(40)) hudPanel(_wpx,_gTop,_wpw,_gBot-_gTop,0.88,1);   // plain: no tab
       if(HUDBOX.gear){ _gB=hudZoomRect('gear',W,H,{x:_wpx,y:by-LH(80),w:(W-6)-_wpx,h:LH(80)+30}); HUDBOX.gear.x=_gB.x+_gdx; HUDBOX.gear.w=_gB.w; }
  }catch(_wp){}
  ctx.textAlign='right'; ctx.font=_heldGun?FS(TYPE.label):FS(TYPE.head); ctx.fillStyle=_heldGun?UIC.tx_2:(_HH.c||'#cdd6dd');
  ctx.fillText(_cornName,_gX,by-LH(46));   // v28.xx (cw-hudammo): the name rides higher (was 34) so the big ammo figure has the room
  ctx.font=FS(TYPE.title);
  if(!_heldGun){
    var _cn=(_HH.count===null||_HH.count===undefined)?null:_HH.count;
    ctx.fillStyle=(_cn===0)?'#ff5a4a':'#cdd6dd';
    ctx.fillText(_HH.kind==='empty'?'EMPTY':(_cn===null?'HELD':(_cn+' held')),_gX,by-LH(14));
  }
  else if(p.wep.mag===0){ ctx.fillStyle='#8a96a1'; ctx.fillText('MELEE',_gX,by-LH(14)); }
  else if(p.jam>0){ ctx.fillStyle='#ff5a4a'; ctx.fillText('JAMMED',_gX,by-LH(14)); }
  else if(p.reloading>0){ ctx.fillStyle='#ffc04a'; ctx.fillText('RELOADING',_gX,by-LH(14)); }
  else {
    ammoDraw(p,_gX,by-LH(14));   // v28.xx (cw-hudammo), his Q57: the rounds are the hero number
  }
'@

SubRx @'
  if(!trDemo()) ctx.fillText(G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_cv.toLocaleString(),W-16,by);
'@ @'
  if(!trDemo()) ctx.fillText(G.bag.length+' ITEM'+(G.bag.length===1?'':'S')+'  $'+_cv.toLocaleString(),_gX,by);   /* v28.xx (cw-hudcorner): on the right padding of the card */
'@

SubRx @'
?_wpx+LH(10):W-LH(130),by); ctx.textAlign='right';
'@ @'
?_wpx+_gP:W-LH(130),by); ctx.textAlign='right'; /* v28.xx (cw-hudcorner): on the left padding of the card */
'@

SubRx @'
      ctx.fillStyle='rgba(17,19,21,.72)'; ctx.fillRect(Math.round(W/2-_bcW/2-_bcF*0.6),Math.round(hy-LH(6)-_bcF*0.95),Math.round(_bcW+_bcF*1.2),Math.round(_bcF*1.25));
'@ @'
      BELTCAP={x:Math.round(W/2-_bcW/2-_bcF*0.6),y:Math.round(hy-LH(6)-_bcF*0.95),w:Math.round(_bcW+_bcF*1.2),h:Math.round(_bcF*1.25)};   // v28.xx (cw-hudcorner): the caption strip as drawn, screen pixels, so the keys chip on its row and the list over it keep off it
      ctx.fillStyle='rgba(17,19,21,.72)'; ctx.fillRect(BELTCAP.x,BELTCAP.y,BELTCAP.w,BELTCAP.h);
'@

SubRx @'
function drawLegend(fz){   // v20.74 (H40): fz is the zoom the full list is drawn at, so it can stop above the belt as seen on the screen
'@ @'
// v28.xx (cw-hudcorner), HIS NOTE (2026-10-25): "in raid, right hand lower corner menu and minizmized controls f1 key are awkward take a look".
// THE FOLDED KEYS CHIP DOCKS ON THE BELT. His rs-1 (2026-10-24) put the keys mid bottom left, folded, on F1, and the chip floated on the
// map in a different spot in each mode (right of the feed in a career raid, half way up the left edge in the demo). It stands at the
// left end of the tactical belt now, on the row of the belt caption: the same strip, height, face and grey key cap as the fire use
// caption, a clear gap left of key 1, under the feed and the medal spot and right of the vitals, in every raid mode and either window,
// grown with the screen as the belt is. F1 opens the compact list upward from the same spot. legChipSpot is that spot in screen pixels
// (without his drag), or null off the belt (the Undercroft, or before the belt has drawn), where the old places stand.
// NEVER OVER THE VITALS. On a short screen with the bigger party type (the demo at 1280x720, 1366x768 or 1600x900) that spot is beside the armour
// and stamina bars, so there the chip stands at the same x just above the vitals instead (VITBOX, the bars and the posture tag as
// drawn), and the list grows up from it there. The test is the screen and the type size alone, never armour or posture, so it never moves in play.
var BELTCAP=null, VITBOX=null, _legRawB=null;   // _legRawB: the compact list bottom last frame before its zoom (see the anchor in drawHUD)
function legChipSpot(){
  var c=(G&&G.hotCells&&G.hotCells.length&&state!=='hub'&&!G.hubFloor)?G.hotCells[0]:null, rs=Math.max(1,hudRes()), f, px, t, tw, w, h, x, y, b, v=VITBOX, cl, kt, kw, m, a, ov=0;
  if(!c||!(c.w>0)) return null;
  f=beltCapFS(c.w); px=msgPx(f); t=legendKeys('F1')+'  controls';
  ctx.save();
  try{
    ctx.font=f; tw=ctx.measureText(t).width;
    kt=(typeof TX==='function')?TX(legendKeys('F1')):legendKeys('F1'); kw=hudRawW(kt); m=ctx.measureText(t); a=(m&&m.actualBoundingBoxAscent>0)?m.actualBoundingBoxAscent:px*0.72;
    ov=Math.max(0,Math.round((Math.max((a+LH(7))*0.9,kw-LH(2))-kw)/2));   // a short key (f1) gets a cap wider than its letters, as hudKey draws it; the strip keeps the caption margin outside the cap
  } finally { ctx.restore(); }
  w=Math.round(tw+px*1.2)+ov; h=Math.round(px*1.25);
  x=Math.max(4,Math.round(c.x-LH(4)-LH(8)*rs-w));   // the belt plate starts LH(4) left of key 1, and a clear gap of LH(8) (grown with the screen) stays before it
  b=c.y-LH(6); y=Math.round(b-px*0.95); cl=LH(2)*rs;
  if(v&&v.w>0&&x<v.x+v.w+cl&&x+w>v.x-cl&&y+h>v.y-cl&&y<v.y+v.h){ y=Math.round(v.top-LH(6)*rs-h); b=y+px*0.95; }   // beside the bars: lifted just over the vitals, same x
  return {x:x,y:y,w:w,h:h,f:f,px:px,t:t,ov:ov,base:b,belt:c.y-LH(4)};
}
function legChipDraw(s){
  var T, kT, m, a, kw, x0;
  ctx.save();
  try{
    ctx.fillStyle='rgba(17,19,21,.72)'; ctx.fillRect(s.x,s.y,s.w,s.h);   // the belt caption strip
    ctx.font=s.f; ctx.textAlign='left'; ctx.fillStyle='#b4bfca';
    x0=s.x+Math.round(s.px*0.6)+(s.ov||0);
    T=(typeof TX==='function')?TX(s.t):s.t; kT=(typeof TX==='function')?TX(legendKeys('F1')):legendKeys('F1');
    m=ctx.measureText(T); a=(m&&m.actualBoundingBoxAscent>0)?m.actualBoundingBoxAscent:s.px*0.72;
    if(typeof hudKey==='function'&&kT&&String(T).indexOf(kT)===0){   // the key is a grey cap, as fire is on the caption; the line is still drawn whole through the TX door
      kw=hudRawW(kT);
      ctx.save(); ctx.beginPath(); ctx.rect(x0-s.px,s.base-a-s.px,hudRawW(T)+s.px*2,a+s.px*2); ctx.rect(x0,s.base-a-s.px,kw,a+s.px*2); ctx.clip('evenodd');
      try{ ctx.fillText(s.t,x0,s.base); } finally { ctx.restore(); }
      hudKey(kT,x0,s.base,a,kw,{fill:'#3b434b',ink:UIC.tx_1});
    } else ctx.fillText(s.t,x0,s.base);
  } finally { ctx.restore(); }
}
// v28.xx (cw-hudcorner), the second review: THE OPENED LIST NEVER COVERS THE USE BAR, THE TIMER CHIPS OR THE VITALS, AND IT ENDS BEFORE
// 47 PERCENT OF THE WIDTH WHERE THE FEED LEAVES THE ROOM. useBandBox is the plate of the first bar drawUseBar draws (the bandage, medkit and plate wind ups), worked
// out as drawUseBar works it out whether or not a bar shows, so the list stands clear of it before he puts a bandage on and does not
// jump when he does. It moves only when the band moves (the ship called, or standing in an extraction ring), and the list with it.
// The third review: a heal and a plate can wind up at once (v11.82), and then drawUseBar stacks the plate bar one step higher, so while
// both run the box reaches up over that second plate too and the list steps up with it, clear of both bars, and back down after.
// legDock is the whole docked place of the compact list: its left edge on the chip (right of the feed and the medal spot), its zoom
// (the v27.26 cap, never under 0.9), moved left only as far as it must to end before 47 percent of the width when a short screen
// leaves no room (the old place, over the vitals; its rows are 16 px whatever the zoom, so where the feed is in the way, the demo at
// 1280x720, it stands right against the feed and still short of the middle), and its bottom: the chip row, never down over the belt plate, the belt caption,
// the use bar, the power up timer chips or the vitals. The checks that need the docked bottom ask legDock, so it is worked out once.
function useBandBox(){
  var c=(G&&G.hotCells&&G.hotCells.length)?G.hotCells[0]:null, p=G&&G.player, hr, uz, w, h, cap, y, ux, t2;
  if(!c||!p) return null;
  hr=hudRes(); uz=Math.max(1,hr||1); ux=Math.round(LH(10)*uz);
  cap=Math.round(Math.max(LH(11),parseFloat(((/([\d.]+)px/).exec(beltCapFS(c.w))||[0,11])[1])||11));
  w=Math.round(Math.min(LH(300)*hr,W*0.34)); h=Math.max(6,Math.round(LH(9)*hr));
  y=Math.round(c.y-LH(6)-cap-LH(12)-h);
  try{ if((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r)) y=Math.min(y,Math.round(c.y-(LH(48)+LH(34)+LH(34))*uz-h)); }catch(_ex){}
  y-=(Math.round(LH(28)*uz)-Math.round(LH(20)*uz))-(LH(28)-LH(20));
  t2=(p.prep&&p.prepA)?h+Math.round(LH(34)*uz):0;   // v28.xx (cw-hudcorner), the third review: a heal and a plate at once, drawUseBar stacks the plate bar one step up (y-=h+_ug), so the box reaches up over that plate too and the list stands clear of both
  return {x:Math.round(W/2-w/2)-ux,y:y-t2-Math.round(LH(20)*uz),w:w+ux*2,h:h+Math.round(LH(28)*uz)+t2};
}
function legDock(s){
  var rs=Math.max(1,hudRes()), u=hudUserZ('legend'), x, z=LEGZ0, w, b, q, k, A, on=0, v=VITBOX, fr, mr;
  if(!s) return null;
  fr=(FEEDBOX.on&&FEEDBOX.w>0)?FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*rs):0; mr=(MEDALBOX.on&&MEDALBOX.w>0)?MEDALBOX.x+MEDALBOX.w+Math.round(LH(10)*rs):0;
  x=Math.max(s.x,fr,mr);
  if(LEGMW>0) z=Math.max(0.9,Math.min(LEGZ0,((W*0.47-x)/LEGMW)/(rs*u)));
  w=LEGMW*z*rs*u;
  if(LEGMW>0&&x+w>W*0.47) x=Math.max(fr,mr,Math.round(LH(6)*rs),Math.floor(W*0.47-w));   // a short screen: back left toward the old place, so it ends before 47 percent (or as far left as the feed and the medal spot let it: its rows stay 16 px)
  b=Math.min(s.y+s.h,Math.round(s.belt-LH(6)*rs));
  if(BELTCAP&&x<BELTCAP.x+BELTCAP.w&&x+w>BELTCAP.x) b=Math.min(b,Math.round(BELTCAP.y-LH(6)*rs));
  q=useBandBox(); if(q&&x<q.x+q.w&&x+w>q.x-LH(6)*rs) b=Math.min(b,Math.round(q.y-LH(6)*rs));
  A=(G&&G.pwr&&G.pwr.act)?G.pwr.act:null; if(A) for(k in A) if(Object.prototype.hasOwnProperty.call(A,k)&&A[k]>0) on=1;
  q=EDGEBOX.chips; if(on&&q&&q.w>0&&x<q.x+q.w&&x+w>q.x) b=Math.min(b,Math.round(q.y-LH(6)*rs));   // the power up timer chips (only while one runs, so a row left from another raid never counts)
  if(v&&v.w>0&&x<v.x+v.w+LH(2)*rs) b=Math.min(b,Math.round(v.top-LH(6)*rs));   // over the vitals columns: on top of them
  return {x:x,z:z,w:w,b:b};
}
function drawLegend(fz){   // v20.74 (H40): fz is the zoom the full list is drawn at, so it can stop above the belt as seen on the screen
'@

SubRx @'
    LEGHINT=null;
    if(G.career&&!G.arcade&&FEEDBOX.on&&HUDBOX.body){ _hx=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*Math.max(1,hudRes())); _hy=HUDBOX.body.y-LH(8)-LH(8); }   // v27.26 (feedleg): the hint stands over the feed, not on its last line
    // v19.93, from the code review of 2026-10-08: no pad button sends H, so on a controller this hint (and H  hide below) named a key
    // the pad player cannot press, as H  full list did before v19.68. On a pad they are left out.
    if(!padOn()&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) {   // v25.xx (keyswap): F1; v30.xx (cw-partyhud2): not while the arcade controls card is up (it showed through the card)
      // v34.xx (cw-ctrlchip), the critic (job 121) on screen 79: 'the f1 controls chip uses a different chip style from the standing tag'. It is the same chip now: the same HUD panel (88 percent, 1px line, 4px radius), the same label face and the same quiet grey text as the posture tag, standing on the same spot as before (bottom just over the vitals).
      var _f1t=legendKeys('F1')+'  controls'; ctx.font=FS(TYPE.label);
      var _cp=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,16])[1])||16, _ch=Math.round(_cp*1.45), _cw=Math.round(ctx.measureText(_f1t).width+_cp*0.9), _ct=Math.round(_hy+LH(8))-_ch;
      hudPanel(_hx,_ct,_cw,_ch,0.88,1); ctx.fillStyle='#a5b1bc'; ctx.fillText(_f1t,_hx+Math.round(_cp*0.45),_ct+Math.round(_ch*0.72)); LEGHINT={x:_hx,y:_ct,w:_cw,h:_ch};
    }
'@ @'
    LEGHINT=null;
    var _lcs=legChipSpot();   // v28.xx (cw-hudcorner): docked on the belt caption row, left of key 1, in every raid mode (the career spot in the cw-careerlegend line above and the line under it are now only the off belt fallback)
    if(!_lcs&&G.career&&!G.arcade&&FEEDBOX.on&&HUDBOX.body){ _hx=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*Math.max(1,hudRes())); _hy=HUDBOX.body.y-LH(8)-LH(8); }   // v27.26 (feedleg): the hint stands over the feed, not on its last line
    // v19.93, from the code review of 2026-10-08: no pad button sends H, so on a controller this hint (and H  hide below) named a key
    // the pad player cannot press, as H  full list did before v19.68. On a pad they are left out.
    if(!padOn()&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) {   // v25.xx (keyswap): F1; v30.xx (cw-partyhud2): not while the arcade controls card is up (it showed through the card)
      if(_lcs){ legChipDraw(_lcs); LEGHINT={x:_lcs.x,y:_lcs.y,w:_lcs.w,h:_lcs.h}; }   // v28.xx (cw-hudcorner): the belt caption chip
      else {   // v28.xx (cw-hudcorner): off the belt (the Undercroft, or before the belt has drawn), the old chip below
      // v34.xx (cw-ctrlchip), the critic (job 121) on screen 79: 'the f1 controls chip uses a different chip style from the standing tag'. It is the same chip now: the same HUD panel (88 percent, 1px line, 4px radius), the same label face and the same quiet grey text as the posture tag, standing on the same spot as before (bottom just over the vitals).
      var _f1t=legendKeys('F1')+'  controls'; ctx.font=FS(TYPE.label);
      var _cp=parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,16])[1])||16, _ch=Math.round(_cp*1.45), _cw=Math.round(ctx.measureText(_f1t).width+_cp*0.9), _ct=Math.round(_hy+LH(8))-_ch;
      hudPanel(_hx,_ct,_cw,_ch,0.88,1); ctx.fillStyle='#a5b1bc'; ctx.fillText(_f1t,_hx+Math.round(_cp*0.45),_ct+Math.round(_ch*0.72)); LEGHINT={x:_hx,y:_ct,w:_cw,h:_ch};
      }
    }
'@

SubRx @'
    if(FEEDBOX.on&&G.legendOn===1){
      var _lgX=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*_lgR), _lgZ=LEGZ0;
      if(LEGMW>0) _lgZ=Math.max(0.9,Math.min(LEGZ0,((W*0.47-_lgX)/LEGMW)/(_lgR*_lgU)));
      HUDZ.legend=_lgZ; _legFX=Math.round(_lgX-6*_lgZ*_lgR*_lgU);
    } else HUDZ.legend=LEGZ0;
'@ @'
    // v28.xx (cw-hudcorner), his note (2026-10-25) and his rs-1: F1 opens the compact list upward from the folded chip on the belt row. legDock is its place: the left edge on the chip (right of the feed and the medal spot), the bottom on the chip row and never down over the belt, the caption, the use bar, the timer chips or the vitals, and on a short screen moved back left so it ends before 47 percent of the width.
    var _lcs=(G.legendOn===1)?legChipSpot():null, _lgD=_lcs?legDock(_lcs):null;
    if((FEEDBOX.on||_lgD)&&G.legendOn===1){
      var _lgX=FEEDBOX.x+FEEDBOX.w+Math.round(LH(10)*_lgR), _lgZ=LEGZ0;
      if(LEGMW>0) _lgZ=Math.max(0.9,Math.min(LEGZ0,((W*0.47-_lgX)/LEGMW)/(_lgR*_lgU)));
      if(_lgD){ _lgX=_lgD.x; _lgZ=_lgD.z; _legTarget=_lgD.b; }
      HUDZ.legend=_lgZ; _legFX=Math.round(_lgX-6*_lgZ*_lgR*_lgU);
    } else HUDZ.legend=LEGZ0;
'@

SubRx @'
  var HBW=300,HBH=26;   /* v28.xx (cw-barnarrow), the critic (2026-10-19): at 360 the stamina word past the bar ran into belt slot 1; all three vitals bars are 300 wide, the word ends clear of the belt */
'@ @'
  var HBW=300,HBH=26;   /* v28.xx (cw-barnarrow), the critic (2026-10-19): at 360 the stamina word past the bar ran into belt slot 1; all three vitals bars are 300 wide, the word ends clear of the belt */
  VITBOX=(function(){ var R=hudZoomRect('body',0,H,{x:16,y:by-50,w:HBW,h:50+HBH}), T=hudZoomRect('body',0,H,{x:16,y:by-50-LH(5)-LH(18),w:HBW,h:1}); R.x+=_boB.dx; R.y+=_boB.dy; R.top=T.y+_boB.dy; return R; })();   /* v28.xx (cw-hudcorner): the three bars as drawn (armour always counted) and top, the top of the posture tag over the armour bar, with his drag, so the keys chip keeps off the vitals */
'@

SubRx @'
    var _legUB=(typeof _legAnchorY==='number'&&_legAnchorY>0)?_legAnchorY:_legTarget;
'@ @'
    var _legUB=(typeof _legAnchorY==='number'&&_legAnchorY>0)?_legAnchorY:_legTarget;
    if(G.legendOn===1&&typeof _legAnchorY==='number'&&_legAnchorY>0&&typeof _legRawB==='number') _legUB=_legTarget+(_legRawB-_legTarget)*(HUDZ.legend||1)*hudRes()*hudUserZ('legend');   /* v28.xx (cw-hudcorner), the third review: THE LIST LANDS ON A NEW TARGET IN ONE FRAME. _legAnchorY is where its bottom fell for LAST frame's target, and the zoom is about the target, so when the target moved (the ship called, a step into a ring, a plate going on over a bandage, a power up timer) the first frame landed off by the move times the zoom less one: at 4K (zoom 3) the list flashed twice the move the wrong way for one frame, 297 px down over the belt when the ship was called. Its bottom before the zoom (_legRawB) is the same from frame to frame, so this frame's landing is worked out for this frame's target and zoom. */
'@

SubRx @'
      _legAnchorY=_lz.y+_lz.h;
'@ @'
      _legAnchorY=_lz.y+_lz.h;
      _legRawB=(G.legendOn===1)?HUDBOX.legend.y+HUDBOX.legend.h:null;   // v28.xx (cw-hudcorner): the compact list bottom before its zoom, for the next frame (the folded line and the full list draw without the shift)
'@

SubRx @'
var VER='34.88';
'@ @'
var VER='34.89';
'@

$pat = "(?m)^  now:'v34\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.89: The gun card in the lower right is snug around the gun name, the rounds and the backpack row, with no lime stub, and it holds still while you shoot, reload and aim. The f1 controls chip sits just left of belt key 1, on the same row as the fire use caption, and F1 opens the list above it, clear of the bandage and plate bars, the power up timers and the health bars (on a small screen the chip stands just above the health bars and the list opens above them, left of the middle). Watch for: whether the card reads well at a glance in a fight, whether the chip is easy to find when you want F1, and whether the opened list still reads as coming from the chip. It waits above where the bandage bar shows, so it stands about 75 px above the chip at 1080p and 140 px at 4K (95 and 180 in the demo), one bar higher while a bandage and a plate go on at once, and much higher while the ship is called (about 210 px at 1080p and 440 px at 4K, where its top stands above the height of your pillager, off to the left). It steps up and back down at those moments. Check 34.89 fails on v34.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
