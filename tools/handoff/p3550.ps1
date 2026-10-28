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

# EXTRACTION ON THE PILL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function zoneBadge(z){
'@ @'
// v35.xx (cw-extpill), HIS ASK (2026-10-27 ~21:40): "Everything about this game needs to be AAA and right now all the messaging on the hud is a clusterfuck", built
// to the research of that night (reports/Player alerts and HUD messaging.md, Top centre and Centre, job 6). EXTRACTION LIVES ON THE PILL UNDER THE CLOCK. The pill
// names the exit the compass points at: teal while it is open (as before), amber once it is inside its two minute warning ("closing"), with its countdown in the
// last minute ("0:42"), red if it has shut, and it pulses once (a 0.6 s swell and ring) each time that state changes. AN EXIT JUST OFF THE SCREEN IS AN EDGE ARROW:
// its letter and distance ("c 152m") on a plate with an arrow pointing at it, pinned to an oval inside the screen edges and slid along it until it is clear of every
// corner panel, the feed, the gun card and the pickup stack's column (empty or not); a closed exit gets no arrow. It replaces the "extraction c available" line
// under the pill. THE SKY IS A SMALL ICON BESIDE THE CLOCK from the ascend: the weather when it is not clear (cloud, rain, fog, storm, blackout), else the time of
// day (sun, low sun, moon); it pulses once when the sky turns. Cosmetic only: nothing here draws a random number or changes game state.
var EXTPS={st:'',col:'',tail:''}, EXTPILL={st:'',col:'',txt:''}, EXTARROW={on:0,x:0,y:0,w:0,h:0,t:''}, WXICON={id:'',x:0,y:0};
function extPillState(z,lbl){
  var o=EXTPS, l;
  o.st='open'; o.col=''; o.tail='';
  if(!z||lbl==='WAYPOINT'){ o.st='way'; return o; }
  if(z.open===false){ o.st='closed'; o.col=HUDC.danger; o.tail=' \u00b7 closed'; return o; }
  if(z.beaconT!==null&&z.beaconT!==undefined){ o.st='called'; return o; }
  if(z.closeAt!==undefined&&G&&G.timeLeft<=z.closeAt+120){ l=Math.max(0,Math.ceil(G.timeLeft-z.closeAt)); o.st='closing'; o.col=HUDC.warn; o.tail=(l<=60)?(' \u00b7 '+fmtClock(l)):' \u00b7 closing'; }
  return o;
}
function extPillPulse(s){
  var now=statusNow(), k;
  if(G.xpSt===undefined){ G.xpSt=s.st; G.xpAt=-1e9; } else if(G.xpSt!==s.st){ G.xpSt=s.st; G.xpAt=now; }
  k=(now-G.xpAt)/0.6;
  return (k>=0&&k<1)?Math.max(k,0.001):0;
}
function extEdgeArrow(E){
  var hr=Math.max(1,hudRes()), p=G.player, ps, ox=W/2, oy=H/2, a0, lab, f=hudFS(TYPE.head), tw, bw, bh, k, s, a=0, cx=0, cy=0, ok=false, mx, rx, ry, i, B, L=[], col='#4de3d0', ar, ux, uy, tx, ty;
  EXTARROW.on=0;
  if(!E||!E.za||!E.z||!G) return false;
  ps=p?w2s(p.x,0,p.y):null; if(ps){ ox=ps.x; oy=ps.y; }
  a0=Math.atan2(E.sy-oy,E.sx-ox);
  lab=extLetter(E.z).toLowerCase()+' '+metres(E.d)+'m';
  mx=LH(6)*hr; ar=LH(8)*hr;
  ctx.save();
  try{
    ctx.font=f; tw=ctx.measureText(TX(lab)).width; bw=Math.round(tw+LH(16)*hr); bh=Math.round(msgPx(f)*1.5);
    // what it keeps off: every HUD panel and edge stack as last drawn, the gun card corner, the teammate rows, the feed, the pickup stack's column even while it is
    // empty, and the clock with the pill
    for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    for(k in EDGEBOX){ B=EDGEBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
    if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&NETTEAMBOX.n&&NETTEAMBOX.w>0) L.push(NETTEAMBOX);
    if(G.cornerBox) L.push(G.cornerBox);
    if(typeof FEEDBOX==='object'&&FEEDBOX&&FEEDBOX.on&&FEEDBOX.w>0) L.push(FEEDBOX);
    L.push({x:W-LH(250)*hr,y:Math.round(H*0.5),w:LH(250)*hr,h:H});
    L.push({x:W/2-LH(170)*hr,y:0,w:LH(340)*hr,h:LH(130)*hr});
    var hit=function(x0,y0){ var j, b; for(j=0;j<L.length;j++){ b=L[j]; if(x0+bw/2+ar*2+mx>b.x&&x0-bw/2-ar*2-mx<b.x+b.w&&y0+bh/2+ar+mx>b.y&&y0-bh/2-ar-mx<b.y+b.h) return true; } return false; };
    rx=W/2-bw/2-ar*2-LH(16)*hr; ry=H/2-bh/2-ar-LH(16)*hr;
    for(s=1;s>=0.55&&!ok;s-=0.15) for(i=0;i<29&&!ok;i++){ a=a0+((i&1)?1:-1)*Math.ceil(i/2)*0.06; cx=W/2+Math.cos(a)*rx*s; cy=H/2+Math.sin(a)*ry*s; if(!hit(cx,cy)) ok=true; }
    if(!ok){ cx=W/2+Math.cos(a0)*rx*0.55; cy=H/2+Math.sin(a0)*ry*0.55; }
    cx=Math.round(cx); cy=Math.round(cy);
    hudPlate(Math.round(cx-bw/2),Math.round(cy-bh/2),bw,bh,null,HUDC.plate);
    ctx.textAlign='center'; ctx.fillStyle=col;
    hudText(lab,cx,Math.round(cy+msgPx(f)*0.36));
    // the arrow just outside the plate on the side of the exit, pointing at it
    ux=cx+Math.cos(a0)*(bw/2+ar*1.2); uy=cy+Math.sin(a0)*(bh/2+ar*0.9);
    tx=ux+Math.cos(a0)*ar; ty=uy+Math.sin(a0)*ar;
    ctx.beginPath(); ctx.moveTo(tx,ty);
    ctx.lineTo(ux+Math.cos(a0+2.3)*ar*0.9,uy+Math.sin(a0+2.3)*ar*0.9);
    ctx.lineTo(ux+Math.cos(a0-2.3)*ar*0.9,uy+Math.sin(a0-2.3)*ar*0.9);
    ctx.closePath(); ctx.fillStyle=col; ctx.fill(); ctx.lineWidth=Math.max(1.5,1.5*hr); ctx.strokeStyle=HUDC.ink; ctx.lineJoin='round'; ctx.stroke();
    EXTARROW.on=1; EXTARROW.x=cx-bw/2; EXTARROW.y=cy-bh/2; EXTARROW.w=bw; EXTARROW.h=bh; EXTARROW.t=lab;
  } finally { ctx.restore(); }
  return true;
}
function wxIconId(){
  var w=wx(), t=tod();
  if(w&&w.id&&w.id!=='clear'&&w.id!=='turning') return w.id;
  if(typeof P!=='undefined'&&P&&P.cond==='night') return 'night';
  return (t&&(t.id==='dawn'||t.id==='golden'||t.id==='dusk'))?'low':'sun';
}
function wxCloud(x,y,s,col){
  ctx.fillStyle=col; ctx.beginPath(); ctx.arc(x-s*0.42,y+s*0.12,s*0.34,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.arc(x,y-s*0.12,s*0.44,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.arc(x+s*0.44,y+s*0.14,s*0.32,0,6.2832); ctx.fill();
  ctx.fillRect(x-s*0.42,y+s*0.1,s*0.86,s*0.36);
}
function wxSun(x,y,s,col){
  var i, a;
  ctx.fillStyle=col; ctx.strokeStyle=col; ctx.beginPath(); ctx.arc(x,y,s*0.42,0,6.2832); ctx.fill();
  ctx.lineWidth=Math.max(1,s*0.14); ctx.beginPath();
  for(i=0;i<8;i++){ a=i*0.7854; ctx.moveTo(x+Math.cos(a)*s*0.62,y+Math.sin(a)*s*0.62); ctx.lineTo(x+Math.cos(a)*s*0.9,y+Math.sin(a)*s*0.9); }
  ctx.stroke();
}
function wxIconDraw(cx,cy,r){
  var id=wxIconId(), u=r*0.66, now=statusNow(), k, sc, i;
  if(!G) return '';
  if(G.wxIc!==id){ if(G.wxIc!==undefined) G.wxIcAt=now; G.wxIc=id; }
  k=(now-(G.wxIcAt===undefined?-1e9:G.wxIcAt))/0.6; sc=(k>=0&&k<1)?1+0.2*Math.sin(Math.PI*k):1;
  WXICON.id=id; WXICON.x=cx; WXICON.y=cy;
  ctx.save();
  try{
    ctx.translate(cx,cy); ctx.scale(sc,sc);
    ctx.beginPath(); ctx.arc(0,0,r,0,6.2832); ctx.fillStyle='rgba(8,12,18,.78)'; ctx.fill();
    ctx.lineWidth=Math.max(1,r*0.08); ctx.strokeStyle='rgba(127,146,216,.45)'; ctx.stroke();
    ctx.lineCap='round'; ctx.lineJoin='round';
    if(id==='sun') wxSun(0,0,u,'#ffd25a');
    else if(id==='low'){
      ctx.fillStyle='#ff9d5a'; ctx.strokeStyle='#ff9d5a'; ctx.beginPath(); ctx.arc(0,u*0.3,u*0.5,Math.PI,6.2832); ctx.closePath(); ctx.fill();
      ctx.lineWidth=Math.max(1,u*0.14); ctx.beginPath(); ctx.moveTo(-u*0.95,u*0.42); ctx.lineTo(u*0.95,u*0.42);
      ctx.moveTo(0,-u*0.42); ctx.lineTo(0,-u*0.72); ctx.moveTo(-u*0.56,-u*0.1); ctx.lineTo(-u*0.78,-u*0.3); ctx.moveTo(u*0.56,-u*0.1); ctx.lineTo(u*0.78,-u*0.3); ctx.stroke();
    } else if(id==='night'){
      ctx.fillStyle='#cdd6dd'; ctx.beginPath(); ctx.arc(0,0,u*0.66,0,6.2832); ctx.fill();
      ctx.fillStyle='rgb(8,12,18)'; ctx.beginPath(); ctx.arc(u*0.32,-u*0.22,u*0.56,0,6.2832); ctx.fill();
    } else if(id==='partly'){ wxSun(-u*0.32,-u*0.3,u*0.66,'#ffd25a'); wxCloud(u*0.12,u*0.16,u*0.78,'#cdd6dd'); }
    else if(id==='rain'){
      wxCloud(0,-u*0.28,u*0.8,'#a5b1bc'); ctx.strokeStyle='#6fb6d8'; ctx.lineWidth=Math.max(1,u*0.14); ctx.beginPath();
      for(i=-1;i<=1;i++){ ctx.moveTo(i*u*0.4,u*0.36); ctx.lineTo(i*u*0.4-u*0.14,u*0.78); }
      ctx.stroke();
    } else if(id==='fog'){
      ctx.strokeStyle='#a5b1bc'; ctx.lineWidth=Math.max(1,u*0.18); ctx.beginPath();
      ctx.moveTo(-u*0.8,-u*0.42); ctx.lineTo(u*0.5,-u*0.42); ctx.moveTo(-u*0.5,0); ctx.lineTo(u*0.8,0); ctx.moveTo(-u*0.8,u*0.42); ctx.lineTo(u*0.6,u*0.42); ctx.stroke();
    } else if(id==='storm'){
      wxCloud(0,-u*0.3,u*0.8,'#7d8894');
      ctx.fillStyle='#ffd25a'; ctx.beginPath(); ctx.moveTo(u*0.1,u*0.02); ctx.lineTo(-u*0.26,u*0.5); ctx.lineTo(-u*0.02,u*0.5); ctx.lineTo(-u*0.16,u*0.92); ctx.lineTo(u*0.3,u*0.36); ctx.lineTo(u*0.06,u*0.36); ctx.closePath(); ctx.fill();
    } else {
      ctx.strokeStyle='#8a96a1'; ctx.lineWidth=Math.max(1,u*0.14); ctx.beginPath(); ctx.arc(0,-u*0.14,u*0.48,0,6.2832); ctx.stroke();
      ctx.beginPath(); ctx.moveTo(-u*0.2,u*0.5); ctx.lineTo(u*0.2,u*0.5); ctx.moveTo(-u*0.72,u*0.62); ctx.lineTo(u*0.72,-u*0.86); ctx.stroke();
    }
  } finally { ctx.restore(); }
  return id;
}
function zoneBadge(z){
'@

SubRx @'
    var _epw=Math.round(ctx.measureText(TX(_lbl+' '+metres(zd)+'m')).width+LH(20)), _eph=Math.round(_hCmp*1.5);
'@ @'
    var _xps=extPillState(_lbl==='WAYPOINT'?null:_tgt,_lbl), _xpt=_lbl+' '+metres(zd)+'m'+_xps.tail; if(_xps.col) _col=_xps.col;   // v35.xx (cw-extpill): the exit's state on the pill
    var _epw=Math.round(ctx.measureText(TX(_xpt)).width+LH(20)), _eph=Math.round(_hCmp*1.5), _xpk=extPillPulse(_xps), _xpx=Math.round(W/2-_epw/2), _xpy=Math.round(_yCmp-_hCmp*1.05);
    ctx.save();
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(W/2,_xpy+_eph/2); ctx.scale(_xsc,_xsc); ctx.translate(-W/2,-(_xpy+_eph/2)); }
'@

SubRx @'
    hudPlate(Math.round(W/2-_epw/2),Math.round(_yCmp-_hCmp*1.05),_epw,_eph,null,HUDC.plate);
'@ @'
    hudPlate(_xpx,_xpy,_epw,_eph,null,HUDC.plate);
    if(_xpk>0||_xps.st==='closing'||_xps.st==='closed'){ ctx.save(); ctx.globalAlpha=(_xpk>0)?(1-_xpk*0.7):0.8; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.strokeStyle=_col; ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(_xpx+0.5,_xpy+0.5,_epw-1,_eph-1,Math.min(_eph/2,LH(4))); else ctx.rect(_xpx,_xpy,_epw,_eph); ctx.stroke(); ctx.restore(); }   // v35.xx (cw-extpill): the state's edge, and the ring of the one pulse
'@

SubRx @'
    hudText(_lbl+' '+metres(zd)+'m',W/2,_yCmp);
'@ @'
    hudText(_xpt,W/2,_yCmp);
    ctx.restore(); EXTPILL.st=_xps.st; EXTPILL.col=_col; EXTPILL.txt=_xpt;   // v35.xx (cw-extpill)
'@

SubRx @'
_zEdge={lab:zlab,za:za,d:_zed};
'@ @'
_zEdge={lab:zlab,za:za,d:_zed,z:zz2,sx:zs.x,sy:zs.y};
'@

SubRx @'
  if(_zEdge&&typeof _yMk==='number'&&typeof _yArw==='number'){
    ctx.font=_fCmp; ctx.textAlign='center';
    var _zeb=_yArw+(G.arcade?Math.round(8*_tz):0)+5*_tz*(G.arcade?ARCADE_ARW:1), _zey=Math.max(_yMk,Math.round(_zeb+LH(3)*_tz+_hCmp*1.05)), _zew=Math.round(ctx.measureText(_zEdge.lab).width+LH(20)), _zeh=Math.round(_hCmp*1.5), _zet=Math.round(_zey-_hCmp*1.05);
    var _zea=Math.round((LH(96)-LH(10))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'));
    if(!((ALERTL||locUp())&&_zet+_zeh>_zea)){
      hudPlate(Math.round(W/2-_zew/2),_zet,_zew,_zeh,null,HUDC.plate);
      ctx.fillStyle=_zEdge.za?'#4de3d0':'rgba(168,180,193,.95)';
      hudText(_zEdge.lab,W/2,_zey);
    }
  }

'@ @'
  EXTARROW.on=0; if(_zEdge&&_zEdge.za){ try{ extEdgeArrow(_zEdge); }catch(_xea){} }   // v35.xx (cw-extpill): an open exit just off the screen is an edge arrow with its letter and distance

'@

SubRx @'
hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); }
'@ @'
hudText(mm+':'+(ss<10?'0':'')+ss,W/2,_yClk); if(_cpo) ctx.restore(); try{ ctx.font=_fClk; wxIconDraw(Math.round(W/2+ctx.measureText(mm+':'+(ss<10?'0':'')+ss).width/2+LH(18)*_tz),Math.round(_yClk-_hClk*0.36),Math.round(LH(10)*_tz)); }catch(_wxi){} }   /* v35.xx (cw-extpill): the sky beside the clock */
'@

SubRx @'
var _arcB=arcadeScoreHud(_yClk,_tz)||0;
'@ @'
var _arcB=arcadeScoreHud(_yClk,_tz)||0; try{ if(SCOREBOX&&SCOREBOX.g===G&&SCOREBOX.w>0) wxIconDraw(Math.round(SCOREBOX.x+SCOREBOX.w+LH(16)*_tz),Math.round(SCOREBOX.y+Math.min(SCOREBOX.h/2,LH(28)*_tz)),Math.round(LH(10)*_tz)); }catch(_wxa){}   /* v35.xx (cw-extpill): the sky beside the score block */
'@

SubRx @'
var VER='35.49';
'@ @'
var VER='35.50';
'@

$pat = "(?m)^  now:'v35\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.50: the extract pill turns amber and counts down when your exit is closing; an exit off screen is an edge arrow with its letter and distance; the sky is an icon by the clock Check 35.50 fails on v35.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
