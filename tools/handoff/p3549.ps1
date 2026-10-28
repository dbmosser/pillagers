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

# HUD STATES ON THE VITALS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawStatusIcons(){
'@ @'
// v35.xx (cw-hudstates), HIS ASK (2026-10-27 ~21:40): "Everything about this game needs to be AAA and right now all the messaging on the hud is a clusterfuck", built
// to the research of that night (reports/Player alerts and HUD messaging.md, Bottom left and Bottom right). LASTING STATES ARE SMALL ICONS BESIDE THE STANCE CHIP,
// for as long as they are true: revealed (the crier mark runs, G.marked: a red open eye), concealed (concealState: the struck eye in its state colour) and in cover
// (in a bush: a leaf cluster). The hidden pill in the status column at mid left (cw-quiettext) is gone; the column keeps the timed statuses. The first time an icon
// turns on, or after it has been off 3 s, its word shows beside the row for 2.2 s, then the icon stands alone. Drawn inside the vitals zoom, so it grows and moves
// with the vitals; the vitals box already holds it, so no new HUDBOX. HUDSTBOX is the row as last drawn, in screen pixels (the checks read it).
// LOW HEALTH PULSES THE BAR and LOW AMMO PULSES THE COUNT, slowly (1.2 a second, under the 3 a second limit of XAG 118), with no text line; an empty gun with rounds
// to load shows a small key cap for reload on the gun card.
var HUDSTATES=1, HUDST_WORD=2.2, HUDST_AGAIN=3, HUDPULSE_HZ=1.2;
var HUDSTBOX={n:0,x:0,y:0,w:0,h:0,ids:''}, HPPULSE={on:0,a:0};
function hudStateList(){
  var p=G&&G.player, L=[], cs;
  if(!p) return L;
  if(G.marked>0) L.push({id:'reveal',col:'#ff5a4a',w:'revealed'});
  cs=concealState();
  if(cs) L.push({id:'conceal',col:cs.col,w:String(cs.nm).toLowerCase()});
  if(G.pBush) L.push({id:'cover',col:'#7fc4a0',w:'in cover'});
  return L;
}
function hudStateGlyph(id,cx,cy,u,col){
  ctx.fillStyle=col; ctx.strokeStyle=col;
  if(id==='conceal'){ statusGlyph('hide',cx,cy,u,col); return; }
  if(id==='reveal'){
    ctx.beginPath(); ctx.lineWidth=u*0.24; ctx.lineCap='round'; ctx.lineJoin='round';
    ctx.moveTo(cx-u,cy); ctx.quadraticCurveTo(cx,cy-u*1.1,cx+u,cy); ctx.quadraticCurveTo(cx,cy+u*1.1,cx-u,cy); ctx.stroke();
    ctx.beginPath(); ctx.arc(cx,cy,u*0.38,0,6.2832); ctx.fill();
    ctx.lineCap='butt'; ctx.lineJoin='miter';
    return;
  }
  ctx.beginPath(); ctx.arc(cx-u*0.46,cy+u*0.24,u*0.5,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.arc(cx+u*0.46,cy+u*0.24,u*0.5,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.arc(cx,cy-u*0.34,u*0.58,0,6.2832); ctx.fill();
}
function hudStateDraw(p,by){
  var L=hudStateList(), i, e, now=statusNow(), S=(G.hudSt=G.hudSt||{}), k, ps, pw=0, up, x, cy, d, r, u, Tm, ws=[], wt, tw, al, ids=[];
  for(k in S) if(S.hasOwnProperty(k)) S[k].seen=0;
  for(i=0;i<L.length;i++){ e=L[i]; ids.push(e.id); k=S[e.id]; if(!k) k=S[e.id]={at:now,off:-1e9,on:0}; else if(!k.on&&now-k.off>HUDST_AGAIN) k.at=now; k.on=1; k.seen=1; }
  for(k in S) if(S.hasOwnProperty(k)&&S[k].on&&!S[k].seen){ S[k].on=0; S[k].off=now; }
  HUDSTBOX.n=L.length; HUDSTBOX.ids=ids.join(',');
  if(!L.length){ HUDSTBOX.w=0; return 0; }
  ps=p.downed?'DOWN':(G.pCrouch?'CROUCHED':'');
  ctx.save();
  try{
    ctx.font=FS(TYPE.label); ctx.textAlign='left';
    if(ps) pw=ctx.measureText(ps).width+14+LH(6);   // beside the stance chip when it shows, where the chip would be when it does not
    up=(p.armor>0)?(50+LH(5)):(29+LH(5));            // the chip's own lift over the bars (v8.97)
    d=LH(18); r=d/2; u=d*0.27; x=18+pw; cy=by-up-LH(10);
    Tm=ctx.getTransform(); HUDSTBOX.x=Tm.a*x+Tm.e; HUDSTBOX.y=Tm.d*(cy-r)+Tm.f; HUDSTBOX.h=d*Tm.d;
    for(i=0;i<L.length;i++){
      e=L[i];
      ctx.beginPath(); ctx.arc(x+r,cy,r,0,6.2832); ctx.fillStyle='rgba(8,12,18,.9)'; ctx.fill();
      ctx.lineWidth=Math.max(1.2,d*0.07); ctx.strokeStyle=e.col; ctx.stroke();
      hudStateGlyph(e.id,x+r,cy,u,e.col);
      if(now-S[e.id].at<HUDST_WORD) ws.push(e);
      x+=d+LH(4);
    }
    for(i=0;i<ws.length;i++){
      e=ws[i]; wt=now-S[e.id].at; al=clamp((HUDST_WORD-wt)/0.4,0,1)*clamp(wt/0.15,0,1);
      tw=ctx.measureText(e.w).width;
      if(al>0.01){ ctx.globalAlpha=al; hudPanel(x,cy-LH(8),tw+14,LH(16),0.88,1); ctx.fillStyle=e.col; ctx.fillText(e.w,x+7,cy+LH(4)); ctx.globalAlpha=1; }
      x+=tw+14+LH(4);
    }
    HUDSTBOX.w=Tm.a*x+Tm.e-HUDSTBOX.x;
  } finally { ctx.restore(); }
  return L.length;
}
function hpPulseA(hp,mx,t){ if(!(hp>0)||!(mx>0)||hp/mx>=0.25) return 0; return 0.5-0.5*Math.cos(t*6.2832*HUDPULSE_HZ); }
function ammoLow(p){ return !!(p&&p.wep&&p.wep.mag>0&&p.ammo>0&&p.ammo<=Math.ceil((p.wep.mag||0)*0.25)); }
function ammoCapOn(p){ return !!(p&&p.wep&&p.wep.mag>0&&p.ammo===0&&!(p.reloading>0)&&!(p.jam>0)&&rsvShow(p)>0); }
function ammoCapKey(){ var s=padOn()?String(padB(pbn(2))):String(keyLabel('KeyR','R')); return s.replace(/[\[\]]/g,'').toLowerCase(); }
function ammoCapW(){ var o=ctx.font, w; ctx.font=FS(TYPE.head); w=ctx.measureText(ammoCapKey()).width; ctx.font=o; return Math.max(LH(24),w+LH(14))+LH(10); }
function drawStatusIcons(){
'@

SubRx @'
      if(cs){ E.on=true; E.col=cs.col; E.bad=cs.bad;
'@ @'
      if(cs&&!HUDSTATES){ E.on=true; E.col=cs.col; E.bad=cs.bad;   /* v35.xx (cw-hudstates): an icon beside the stance chip now (hudStateDraw) */
'@

SubRx @'
  // The number that was just taken off, fading.
'@ @'
  try{ hudStateDraw(p,by); }catch(_hsd){}   // v35.xx (cw-hudstates): revealed, concealed, in cover, beside the stance chip
  // The number that was just taken off, fading.
'@

SubRx @'
  bar(16,by,HBW,HBH,p.hp/p.maxhp,p.hp>50?'#5fae6f':(p.hp>25?'#d0a13c':'#c8452f'));
'@ @'
  bar(16,by,HBW,HBH,p.hp/p.maxhp,p.hp>50?'#5fae6f':(p.hp>25?'#d0a13c':'#c8452f'));
  // v35.xx (cw-hudstates): under a quarter health the whole bar pulses red, 1.2 a second, brightest on the health that is left; no text line
  HPPULSE.on=0; HPPULSE.a=hpPulseA(p.hp,p.maxhp,statusNow());
  if(p.hp>0&&p.hp/p.maxhp<0.25){
    HPPULSE.on=1;
    ctx.save(); ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(16,by,HBW,HBH,6); else ctx.rect(16,by,HBW,HBH); ctx.clip();
    ctx.fillStyle='rgba(200,40,30,'+(0.10+0.30*HPPULSE.a).toFixed(3)+')'; ctx.fillRect(16,by,HBW,HBH);
    ctx.fillStyle='rgba(255,170,150,'+(0.45*HPPULSE.a).toFixed(3)+')'; ctx.fillRect(16,by,HBW*clamp(p.hp/p.maxhp,0,1),HBH);
    ctx.restore();
  }
'@

SubRx @'
function ammoDraw(p,x,y){
'@ @'
function ammoDraw(p,x,y,lx){
'@

SubRx @'
  if(p.ammo===0) c=UIC.danger; else if(p.ammo<=Math.ceil((p.wep.mag||0)*0.25)) c=UIC.warn;
'@ @'
  var lo=ammoLow(p), fw, kc, kw, kh, kx, ky;   // v35.xx (cw-hudstates): low ammo pulses red (it was a steady amber); empty is steady red and shows the reload key cap
  if(p.ammo===0||lo) c=UIC.danger;
'@

SubRx @'
  ctx.font=FS(TYPE.num); ctx.fillStyle=c; ctx.fillText(String(p.ammo),x-w-4,y);
'@ @'
  ctx.font=FS(TYPE.num); ctx.fillStyle=c;
  var oa=ctx.globalAlpha; if(lo) ctx.globalAlpha=oa*(0.5+0.5*(0.5+0.5*Math.cos(statusNow()*6.2832*HUDPULSE_HZ)));
  ctx.fillText(String(p.ammo),x-w-4,y); ctx.globalAlpha=oa;
  if(ammoCapOn(p)){
    fw=ctx.measureText(String(p.ammo)).width; kc=ammoCapKey(); ctx.font=FS(TYPE.head); kw=Math.max(LH(24),ctx.measureText(kc).width+LH(14)); kh=LH(24);
    kx=x-w-4-fw-LH(10)-kw; ky=Math.round(y-LH(18)-kh/2);
    if(typeof lx==='number'&&kx<lx) kx=x-w-4-kw;   // no room left of the 0 on a narrow card (the demo): the cap stands over the 0
    ctx.font=FS(TYPE.head);
    ctx.save();
    ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(kx,ky,kw,kh,LH(4)); else ctx.rect(kx,ky,kw,kh);
    ctx.fillStyle='rgba(8,12,18,.92)'; ctx.fill(); ctx.lineWidth=1.5; ctx.strokeStyle=UIC.tx_1; ctx.stroke();
    ctx.fillStyle=UIC.tx_1; ctx.textAlign='center'; ctx.fillText(kc,kx+kw/2,ky+kh/2+LH(6));
    ctx.restore();
  }
'@

SubRx @'
    ammoDraw(p,_gX,by-LH(14));
'@ @'
    ammoDraw(p,_gX,by-LH(14),(typeof _wpx==='number'&&_wpx===_wpx)?_wpx+_gP:null);   // v35.xx (cw-hudstates): with the card's left inner edge, for the reload key cap
'@

SubRx @'
var VER='35.48';
'@ @'
var VER='35.49';
'@

$pat = "(?m)^  now:'v35\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.49: revealed, hidden and in cover are small icons by your stance; low health pulses the bar; low ammo pulses the count; an empty gun shows the reload key Check 35.49 fails on v35.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
