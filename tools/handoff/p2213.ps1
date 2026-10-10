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

# THE ALERT LANE, FIRST FOR THE CRIER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sayWhenFree(m,kind,o){
'@ @'
// v22.13, the raid text rewrite (R08): THE ALERT LANE. HIS ORDER (2026-10-09): the raid text reads like Call of Duty, Fortnite or
// ARC Raiders, and in those a threat is a callout of its own, held still on a plate of its own, never one more row in a list of
// remarks. Until now a Crier marking you was a plain message row that the next remark could push down, and the MARKED row under
// the compass flashed its own sentence between 60 and 100 percent ten times a second for as long as the mark ran. Now a line of
// kind crit, warn or ext takes ONE alert slot (G.alert, read by __hudSaid('alert')) at the top of the message band: a measured
// plate (the danger plate for crit and warn), an accent bar and a small glyph in the kind colour (a warning triangle for a threat,
// a ring for extraction; o.icon may ask for a clock or two heads for the party), the headline in TYPE.head and its detail (o.sub)
// in TYPE.label under it. It fades in over 0.12 s, holds a steady alpha, and fades out over its last 0.4 s; it lasts its kind
// life (3.5 s, a crit 4.5 s, or o.life), or while its condition (o.hold: 'marked', 'nuking' or a function) still holds, up to 8 s.
// A line with the same text or key (o.key) refreshes the alert in place. A crit replaces the alert at once; a line of equal or
// higher rank replaces it once it has shown 0.6 s; anything else waits in a 3 line alert queue for up to 1.5 s and then goes to
// the feed as an objective row, so it is never lost. An alert a crit took before it had shown 0.6 s goes back to that queue. The
// feed rows (G.msg and G.feed) carry everything else and now start under the alert while one shows. Cosmetic only: nothing here
// runs while G.sim is set, draws a random number or changes game state.
var ALERTK={crit:1,warn:1,ext:1};
function msgAlertK(k){ return ALERTK.hasOwnProperty(k); }
function alertUp(){ var a=G&&G.alert; return (a&&a.T>0&&a.m)?a:null; }
function alertHeld(a){
  if(!a||!a.hold) return false;
  try{
    if(typeof a.hold==='function') return !!a.hold();
    if(a.hold==='marked') return G.marked>0;
    if(a.hold==='nuking') return !!G.nuking;
  }catch(_h){}
  return false;
}
function alertShow(m,k,o,now){
  var a=alertUp();
  if(a&&a.m!==m&&now-a.at<0.6) alertEnq(a.m,a.k,{sub:a.sub,key:a.key,hold:a.hold,icon:a.icon,c:a.c},a.at);   // a crit took it before it was read: it waits, from when it first showed
  G.alert={m:m,k:k,sub:(o&&o.sub)||'',key:(o&&o.key)||'',hold:(o&&o.hold)||null,icon:(o&&o.icon)||'',c:(o&&o.c)||'',
           T:(o&&o.life>0)?o.life:MSGK[k].life,at:now};
}
function alertToFeed(e){ var o=e.o||{}; say(e.m,'obj',(o.sub||o.key)?{sub:o.sub||'',key:o.key||''}:null); }
function alertQDrop(m,key){ var q=G.alertQ, i; if(!q) return; for(i=q.length-1;i>=0;i--) if(q[i].m===m||(key&&q[i].key===key)) q.splice(i,1); }
function alertEnq(m,k,o,now){
  var q=(G.alertQ=G.alertQ||[]), key=(o&&o.key)||'', i, lo, lr;
  for(i=0;i<q.length;i++) if(q[i].m===m||(key&&q[i].key===key)){ q[i].m=m; q[i].k=k; q[i].o=o||null; q[i].key=key; return; }
  q.push({m:m,k:k,o:o||null,key:key,t:now});
  while(q.length>3){ lo=0; lr=1e9; for(i=0;i<q.length;i++) if(MSGK[q[i].k].r<lr){ lr=MSGK[q[i].k].r; lo=i; } alertToFeed(q.splice(lo,1)[0]); }
}
function alertSay(m,k,o){
  var now=G.t||0, a=alertUp(), key=(o&&o.key)||'';
  if(a&&(a.m===m||(key&&a.key===key))){   // the same line, or the same key: refreshed in place, with no new fade and no new start
    a.m=m; a.k=k; a.sub=(o&&o.sub)||''; a.c=(o&&o.c)||''; if(o&&o.hold) a.hold=o.hold; if(o&&o.icon) a.icon=o.icon;
    a.T=Math.max(a.T,(o&&o.life>0)?o.life:MSGK[k].life); alertQDrop(m,key); return;
  }
  if(!a||k==='crit'||(MSGK[k].r>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6)){ alertQDrop(m,key); alertShow(m,k,o,now); return; }
  alertEnq(m,k,o,now);
}
function alertTick(dt){
  if(!G||G.sim) return;
  var a=G.alert, now=G.t||0, q=G.alertQ, i, b, br, e;
  if(a&&a.T>0){ a.T-=dt; if(a.T<0.4&&alertHeld(a)&&now-a.at<8) a.T=0.4; }
  if(!q||!q.length) return;
  for(i=q.length-1;i>=0;i--) if(now-q[i].t>1.5) alertToFeed(q.splice(i,1)[0]);   // waited 1.5 s: into the feed, never lost
  if(!q.length) return;
  a=alertUp(); b=0; br=-1e9;
  for(i=0;i<q.length;i++) if(MSGK[q[i].k].r>br){ br=MSGK[q[i].k].r; b=i; }
  if(!a||(br>=MSGK[msgKind(a.k)].r&&now-a.at>=0.6)){ e=q.splice(b,1)[0]; alertShow(e.m,e.k,e.o,now); }
}
function msgPx(f){ var m=(/([\d.]+)px/).exec(f); return m?parseFloat(m[1]):LH(12); }
function alertLayout(){   // with the message scale not yet applied: the alert plate, its lines and their baselines, or null
  var a=alertUp(), hf, lf, hp, lp, gs, mw, hl, sl=[], w=0, i, y, bl=[];
  if(!a) return null;
  hf=FS(TYPE.head); lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
  mw=Math.max(LH(80),msgMaxW()-gs-LH(29));
  ctx.save();
  try{
    ctx.font=hf; hl=msgWrap(String(a.m),mw); for(i=0;i<hl.length;i++) w=Math.max(w,ctx.measureText(hl[i]).width);
    if(a.sub){ ctx.font=lf; sl=msgWrap(String(a.sub),mw); for(i=0;i<sl.length;i++) w=Math.max(w,ctx.measureText(sl[i]).width); }
  } finally { ctx.restore(); }
  y=LH(5)+Math.round(hp*0.82);
  for(i=0;i<hl.length;i++){ bl.push(y); if(i<hl.length-1) y+=Math.round(hp*1.2); }
  for(i=0;i<sl.length;i++){ y+=Math.round(lp*(i?1.2:1.35)); bl.push(y); }
  return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.ceil(LH(12)+gs+LH(7)+w+LH(10)),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(5)};
}
function alertGlyph(kd,x,cy,s,col){
  var r=s/2, cx=x+r, lw=Math.max(1.5,s*0.13);
  ctx.save();
  try{
    ctx.fillStyle=col; ctx.strokeStyle=col; ctx.lineWidth=lw; ctx.lineJoin='round'; ctx.lineCap='round';
    ctx.beginPath();
    if(kd==='ring'){ ctx.arc(cx,cy,r-lw/2,0,6.2832); ctx.stroke(); ctx.beginPath(); ctx.arc(cx,cy,r*0.36,0,6.2832); ctx.fill(); }
    else if(kd==='clock'){ ctx.arc(cx,cy,r-lw/2,0,6.2832); ctx.stroke(); ctx.beginPath(); ctx.moveTo(cx,cy-r*0.55); ctx.lineTo(cx,cy); ctx.lineTo(cx+r*0.42,cy); ctx.stroke(); }
    else if(kd==='party'){
      ctx.arc(cx-r*0.42,cy-r*0.3,r*0.27,0,6.2832); ctx.fill();
      ctx.beginPath(); ctx.arc(cx+r*0.42,cy-r*0.3,r*0.27,0,6.2832); ctx.fill();
      ctx.beginPath(); ctx.arc(cx-r*0.42,cy+r*0.62,r*0.46,Math.PI,0); ctx.fill();
      ctx.beginPath(); ctx.arc(cx+r*0.42,cy+r*0.62,r*0.46,Math.PI,0); ctx.fill();
    } else {
      ctx.moveTo(cx,cy-r); ctx.lineTo(cx+r,cy+r*0.82); ctx.lineTo(cx-r,cy+r*0.82); ctx.closePath(); ctx.fill();
      ctx.fillStyle=HUDC.ink; ctx.fillRect(cx-lw/2,cy-r*0.38,lw,r*0.7); ctx.fillRect(cx-lw/2,cy+r*0.44,lw,lw);
    }
  } finally { ctx.restore(); }
}
function alertDraw(L){   // inside the message scale, at the top of the band
  var a=L.a, now=G.t||0, al=Math.max(0,Math.min(1,(now-a.at)/0.12,a.T/0.4)), col=HUDC[a.c]||HUDC[MSGK[msgKind(a.k)].c]||HUDC.text,
      x0=Math.round(W/2-L.w/2), y0=LH(96), gx=x0+LH(12), tx, i, oa=ctx.globalAlpha, oal=ctx.textAlign;
  if(!(al>0)) return;
  ctx.globalAlpha=oa*al;
  hudPlate(x0,y0,L.w,L.h,col,(a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate);
  alertGlyph(a.icon||(a.k==='ext'?'ring':'threat'),gx,y0+L.bl[0]-Math.round(L.hp*0.36),L.gs,col);
  tx=gx+L.gs+LH(7);
  ctx.textAlign='left';
  ctx.font=L.hf; ctx.fillStyle=col;
  for(i=0;i<L.hl.length;i++) hudText(L.hl[i],tx,y0+L.bl[i],2);
  if(L.sl.length){ ctx.font=L.lf; ctx.fillStyle=HUDC.text; for(i=0;i<L.sl.length;i++) hudText(L.sl[i],tx,y0+L.bl[L.hl.length+i],2); }
  ctx.globalAlpha=oa; ctx.textAlign=oal;
}
function sayWhenFree(m,kind,o){
'@

SubRx @'
    if(k==='log') return;
'@ @'
    if(k==='log') return;
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
'@

SubRx @'
function msgLayout(){
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), rows=feedRows(), ex=0, i, n, mw, la, ll;
  if(G) G.feed=rows;
'@ @'
function msgLayout(){
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), rows=feedRows(), ex=0, i, n, mw, la, ll, al=null;
  if(G) G.feed=rows;
  // v22.13 (R08): the alert plate is laid out first, at the top of the band; the feed rows start under it (HUDFEEDT, before the
  // message scale) and HUDALERTB is its bottom on screen. With no alert both are where the feed always was.
  HUDFEEDT=LH(96); HUDALERTB=0; ALERTL=null;
  try{ al=alertLayout(); }catch(_al){ al=null; }
  if(al){ ALERTL=al; HUDALERTB=Math.round((LH(96)+al.h)*z); HUDFEEDT=LH(96)+al.h+LH(4); }
'@

SubRx @'
  HUDMSGB=Math.round((LH(96)+LH(17)+ex)*z);
'@ @'
  HUDMSGB=Math.round((HUDFEEDT+LH(17)+ex)*z);   // v22.13 (R08): under the feed, which starts under an alert
'@

SubRx @'
var HUDBOSSB=0, HUDGIFTB=0, HUDMSGB=0;
'@ @'
var HUDBOSSB=0, HUDGIFTB=0, HUDMSGB=0, HUDALERTB=0, HUDFEEDT=0, ALERTL=null;   // v22.13 (R08): the alert plate bottom, the feed top (unscaled) and the alert layout
'@

SubRx @'
  var _frows=feedRows();   // v21.86 (R04): the rows msgLayout laid out
  if(_frows.length){
    // v10.43, his answers 25 and 30: the message line scales with the monitor
    // like every panel, anchored at the top centre. It was 19px at 4K.
    ctx.save(); hudZoomIn('msg',W/2,0);
    ctx.font=FS(TYPE.label);
'@ @'
  var _frows=feedRows(), _alL=ALERTL;   // v21.86 (R04): the rows msgLayout laid out; v22.13 (R08): and the alert over them
  if(_frows.length||_alL){
    // v10.43, his answers 25 and 30: the message line scales with the monitor
    // like every panel, anchored at the top centre. It was 19px at 4K.
    ctx.save(); hudZoomIn('msg',W/2,0);
    if(_alL&&G){ try{ alertDraw(_alL); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
    ctx.font=FS(TYPE.label);
'@

SubRx @'
    var _mh=msgRowH(), _mla=msgLineA(), _mmx=msgMaxW(), _mty=LH(96);
'@ @'
    var _mh=msgRowH(), _mla=msgLineA(), _mmx=msgMaxW(), _mty=HUDFEEDT||LH(96);   // v22.13 (R08): under the alert while one shows
'@

SubRx @'
  if(G.marked>0){
    ctx.font=_fMk;
    ctx.fillStyle='rgba(255,60,40,'+(.6+.4*Math.sin(G.t*10))+')';
    ctx.fillText('MARKED - THEY KNOW WHERE YOU ARE',W/2,_yMk);
  }
'@ @'
  // v22.13, the raid text rewrite (R08): the MARKED row that flashed here is retired. It repeated the Crier line in a second
  // sentence and flickered between 60 and 100 percent ten times a second; the Crier line is now an alert that holds steady
  // while the mark runs (G.marked), and G.marked still draws the red edge of the screen.
'@

SubRx @'
      if(G.feed&&G.feed[1]&&G.feed[1].T>0) G.feed[1].T-=dt;   // v21.86 (R04): the second message row runs out on the same clock
'@ @'
      if(G.feed&&G.feed[1]&&G.feed[1].T>0) G.feed[1].T-=dt;   // v21.86 (R04): the second message row runs out on the same clock
      alertTick(dt);   // v22.13 (R08): the alert lane and its queue run on the same clock
'@

SubRx @'
if(!e.markSeat) say('A CRIER IS REVEALING YOUR LOCATION');
'@ @'
if(!e.markSeat) say('A CRIER IS REVEALING YOUR LOCATION','warn',{key:'crier'});
'@

SubRx @'
say(sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION');
'@ @'
say(sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION','warn',{key:'crier',hold:'marked'});   // v22.13 (R08): an alert held while the mark runs
'@

SubRx @'
if(mine) say('A CRIER IS REVEALING YOUR LOCATION');
'@ @'
if(mine) say('A CRIER IS REVEALING YOUR LOCATION','warn',{key:'crier'});
'@

SubRx @'
if(!G.sim) say(m.sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION');
'@ @'
if(!G.sim) say(m.sees?'CRIER REVEALED YOUR LOCATION':'CRIER REVEALED YOUR LAST LOCATION','warn',{key:'crier',hold:'marked'});
'@

SubRx @'
var VER='22.12';
'@ @'
var VER='22.13';
'@

$pat = "(?m)^  now:'v22\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.13: Danger, critical and extraction lines take their own steady alert slot at the top of the screen, starting with his Crier lines. Check 22.13 fails on v22.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
