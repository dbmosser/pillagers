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

# THE PERSISTENT FEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgTick(dt){
'@ @'
// v27.24 (feed1), HIS ORDER (2026-10-14): "the way that different player messages come in at different places is messy, needs to be made
// consistent, maybe we should just have a persistent feed ala WoW?". THE FEED. One persistent message feed at the bottom left, above the
// body corner, like the chat frame of WoW: the last 10 lines, the newest at the bottom, each line full bright for 6 s and then dimmed to
// 35 percent, where it stays until a newer line pushes it out (40 lines are kept for the history). Every line the raid says goes in:
// each said line (say, whatever its kind: an alert is written here as well as shown in the alert lane), a pickup (the item in its
// rarity colour, counted when it is picked again), every kill he could witness (his own, a teammate's, and machines and pillagers
// killing each other), medals and money, power-ups and teammate lines. A line is a small glyph and its kind colour (loot rarity, red
// danger, teammate blue, gold medal and money, amber objective, teal extraction), in the HUD voice, on the one HUD plate. A line said
// again within a second (a per-frame caller) is the same line kept bright, never counted; one said again within 30 s (a pickup within 6 s)
// is counted (x2) and moves to the bottom. The 10 lines are a reserved zone (FEEDBOX): the controls legend and the status icons are
// laid out above it. The old places (the message rows, the pickup stack, the kill feed, the loot labels) still show in this build; the
// next builds move them out. A window has its own feed, and a teammate's lines reach it through the same say(). Cosmetic only: no
// seeded draw, nothing under G.sim, no game state; the feed clock (G.fd.t) runs on msgTick, so it stands still under the solo pause.
var FEED={show:10,keep:40,hold:6,dim:0.35,fade:1,again:1,merge:30,enter:0.14};
var FEEDBOX={on:0,x:0,y:0,w:0,h:0,rows:[]};
var FEEDGL={loot:'backpack',kill:'skull',team:'party',danger:'warning',medal:'xp',money:'credits',obj:'contract',ext:'extraction',power:'xp',info:'info',dim:''};
var FEEDMEDALS=/^(DOUBLE KILL|TRIPLE KILL|MULTI KILL|MULTI-KILL|RAMPAGE|UNSTOPPABLE|NEW HIGH SCORE)/;
function feedS(){ if(!G.fd) G.fd={t:0,seq:0,lines:[]}; return G.fd; }
function feedCol(fk){
  return fk==='danger'?HUDC.danger:fk==='kill'?HUDC.danger:fk==='team'?HUDC.ally:(fk==='medal'||fk==='money')?UIC.r_gold:fk==='obj'?HUDC.warn:fk==='ext'?HUDC.extract:fk==='dim'?HUDC.dim:HUDC.text;
}
function feedItemCol(item,c){
  var it, rk;
  if(c&&HUDC[c]) return HUDC[c];
  it=item&&ITEMS[item]; rk=it?(dispR(item)||it.r):'';
  return (rk&&RCOL[rk])||HUDC.text;
}
function feedPwrOf(s){ var i; for(i=0;typeof PWR_KINDS!=='undefined'&&i<PWR_KINDS.length;i++) if(PWR_KINDS[i].n===s) return PWR_KINDS[i]; return null; }
function feedAlpha(ln){ var age=(G.fd?G.fd.t:0)-ln.at; return (age<=FEED.hold)?1:Math.max(FEED.dim,1-(1-FEED.dim)*(age-FEED.hold)/FEED.fade); }
// segs: a string or [{t,c}]; fk the kind; o {key, tag, n, count, col, gl}. Returns the line.
function feedAdd(segs,fk,o){
  var F, now, key, txt, i, ln, n;
  if(!G||G.sim||!G.player) return null;
  F=feedS(); now=F.t; key=(o&&o.key)||''; n=(o&&o.n>0)?Math.round(o.n):1;
  if(typeof segs==='string') segs=[{t:segs,c:null}];
  txt=''; for(i=0;i<segs.length;i++) txt+=segs[i].t;
  for(i=F.lines.length-1;i>=Math.max(0,F.lines.length-6);i--){
    ln=F.lines[i];
    if(!((key&&ln.key===key)||(!key&&!ln.key&&ln.txt===txt))) continue;
    if(!(o&&o.count)&&now-ln.last<FEED.again){ ln.last=now; ln.at=now; return ln; }
    if(now-ln.at<((o&&o.count)?FEED.hold:FEED.merge)){
      ln.n+=n; ln.at=now; ln.last=now; ln.segs=segs; ln.txt=txt; ln.mf='';
      if(i<F.lines.length-1){ F.lines.splice(i,1); F.lines.push(ln); }
      return ln;
    }
    break;
  }
  ln={id:(F.seq=(F.seq|0)+1),fk:fk||'info',segs:segs,txt:txt,key:key,n:n,tag:(o&&o.tag)?String(o.tag):'',money:'',col:(o&&o.col)||feedCol(fk),
      gl:(o&&o.gl!==undefined)?o.gl:FEEDGL[fk||'info'],at:now,last:now,born:now,mf:''};
  F.lines.push(ln);
  while(F.lines.length>FEED.keep) F.lines.shift();
  return ln;
}
function feedKindOf(s,k,o){
  if(o&&o.fk) return o.fk;
  if(k==='crit'||k==='warn') return 'danger';
  if(k==='ext') return feedPwrOf(s)?'power':(FEEDMEDALS.test(s)?'medal':'ext');
  if(k==='obj') return (/^GOAL DONE/).test(s)?'medal':'obj';
  if(k==='ally') return 'team';
  if(k==='chat'||k==='sys') return 'dim';
  return 'info';
}
// every say(): the line goes into the feed whatever lane it also takes. A line the old pipeline says a second time (the waiting
// queue coming out, an alert that waited too long going to the rows) is not written again (o.fd, G.msgDrain).
function feedSay(m,k,o){
  var s, sub, fk, col, D, item, tag, key, segs, cnt=false, gl;
  if(!G||G.sim||!G.player||G.msgDrain||(o&&o.fd)) return null;
  s=String(m); if(!s) return null;
  sub=(o&&o.sub)?String(o.sub):''; item=(o&&o.item)||'';
  if(k==='pick'){
    tag=(o&&o.sub)?String(o.sub):((o&&o.tag)?String(o.tag).toUpperCase():'');
    if(o&&o.c==='danger'){ fk='danger'; col=HUDC.danger; key=(o.key?('k:'+o.key):''); }
    else if(item&&ITEMS[item]){ fk='loot'; col=feedItemCol(item,o&&o.c); cnt=true; key='p:'+item+'|'+tag; }
    else if((/^[+\-]\$/).test(s)){ fk='money'; col=(o&&o.c&&HUDC[o.c]&&o.c!=='gain')?HUDC[o.c]:UIC.r_gold; key='m:'+s+'|'+tag; }
    else { fk='info'; col=feedItemCol('',o&&o.c); key=(o&&o.key)?('k:'+o.key):''; }
    return feedAdd([{t:s,c:col}],fk,{key:key,tag:tag,n:(o&&o.n>0)?o.n:1,count:cnt,col:col});
  }
  fk=feedKindOf(s,k,o); col=feedCol(fk); gl=undefined;
  if(fk==='power'){ D=feedPwrOf(s); if(D) col=D.hex; }
  segs=[{t:s,c:(fk==='info'||fk==='dim')?feedCol(fk):col}];
  if(sub) segs.push({t:'  \u00b7  '+sub,c:HUDC.dim});
  return feedAdd(segs,fk,{key:(o&&o.key)?('k:'+o.key):'',col:col});
}
// a world label (rising text): loot names are the pickup lines, hit feedback stays on its target, a kill has its own line and
// a medal carries its own figure; everything else (a revive, a notoriety rise, a seal broken) is a line here too.
function feedLabel(t,c,ik){
  var s=String(t);
  if(!G||G.sim||!G.player||ik||!s) return null;
  if((/^(WEAK SPOT|ACTIVE RELOAD|PICKED UP|CLOSE CALL)$/).test(s)||(/ (DESTROYED|ELIMINATED)$/).test(s)||feedPwrOf(s)) return null;
  if((/^\s\+\$/).test(s)) return null;
  if((/^\+\$[\d,]+$/).test(s)) return feedMoney(s);
  return feedAdd([{t:s,c:c||HUDC.text}],'info',{col:c||null,gl:'info'});
}
// the figure of a kill rides on his own kill line when that line is under a second old; otherwise it is a line of its own
function feedMoney(s){
  var F=feedS(), Ln=F.lines[F.lines.length-1];
  if(Ln&&Ln.fk==='kill'&&Ln.mine&&!Ln.money&&F.t-Ln.last<0.8){ Ln.money=s; Ln.mf=''; return Ln; }
  return feedAdd([{t:s,c:UIC.r_gold}],'money',{key:'m:'+s});
}
function feedMedal(txt,pts){
  return feedAdd([{t:String(txt),c:UIC.r_gold},{t:'  +'+arcadeCr(pts),c:UIC.r_gold}],'medal',{});
}
function feedSame(a,b){
  a=String(a).toUpperCase().replace(/^ELITE /,''); b=String(b).toUpperCase().replace(/^ELITE /,'');
  return a===b||a.indexOf(b)===0||b.indexOf(a)===0;
}
// by: who did it ('' when nobody known), mine: it was this player, mate: a teammate; vn the victim, verb after it when unattributed
function feedKillLine(by,mine,mate,vn,vcol,verb){
  var F, now, i, Ln, segs, acc;
  if(!G||G.sim||!G.player) return null;
  F=feedS(); now=F.t;
  segs=by?[{t:by,c:mine?HUDC.text:HUDC.ally},{t:'  >  ',c:HUDC.dim},{t:vn,c:vcol}]:[{t:vn,c:vcol},{t:verb||' DESTROYED',c:HUDC.dim}];
  acc=mine?UIC.acc:(mate?HUDC.ally:HUDC.danger);
  for(i=F.lines.length-1;i>=Math.max(0,F.lines.length-6);i--){
    Ln=F.lines[i];
    if(!(Ln.fk==='kill'&&now-Ln.last<1.5&&feedSame(Ln.vn,vn))) continue;
    if(by&&!Ln.by){ Ln.segs=segs; Ln.txt=by+'  >  '+vn; Ln.by=by; Ln.mine=mine; Ln.col=acc; Ln.vn=vn; Ln.mf=''; Ln.last=now; return Ln; }
    if(!by&&Ln.by) return Ln;
    if((by||'')===(Ln.by||'')){ Ln.n++; Ln.at=now; Ln.last=now; Ln.mf=''; return Ln; }
    break;
  }
  Ln=feedAdd(segs,'kill',{key:'kill:'+(F.seq+1),col:acc});
  if(Ln){ Ln.vn=vn; Ln.by=by; Ln.mine=!!mine; }
  return Ln;
}
function feedKillEnt(e){
  var p=G&&G.player, mine, seat, by, vn;
  if(!G||G.sim||!p||!e) return null;
  mine=!!e.byPlayer&&!p.specOut; seat=(e.bySeat|0);
  if(!mine&&seat<=0&&!canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) return null;
  vn=String(e.name||kindWord(e.kind));
  by=mine?'YOU':(seat>0?String(netSeatName(seat)||('PLAYER '+(seat+1))).toUpperCase():'');
  return feedKillLine(by,mine,seat>0,vn,(e.kind==='raider')?HUDC.danger:HUDC.warn,killWord(e));
}
function feedTag(item,tag){
  var F=G&&G.fd, i, Ln;
  if(!F) return;
  for(i=F.lines.length-1;i>=0;i--){ Ln=F.lines[i]; if(Ln.fk==='loot'&&Ln.key.indexOf('p:'+item+'|')===0){ Ln.tag=String(tag||''); Ln.mf=''; return; } }
}
function feedTick(dt){ if(G&&G.fd) G.fd.t+=dt; }
function feedRect(){
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), rh=Math.round(fp*1.5), gap=Math.max(2,Math.round(LH(2)*rs)), B=HUDBOX.body, h=FEED.show*rh+(FEED.show-1)*gap, bot;
  bot=((B&&B.h>0&&B.y>H*0.5)?B.y:Math.round(H-LH(142)*rs*1.4))-Math.round(LH(8)*rs);
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.min(Math.round(LH(460)*rs),Math.round(W*0.3)),h:h,rh:rh,gap:gap,fp:fp};
}
function feedGlyph(name,x,cy,s,col){
  var Pt=name?uiIconPath(name):null;
  if(!Pt) return;
  ctx.save();
  try{ ctx.translate(x,cy-s/2); ctx.scale(s/24,s/24); ctx.strokeStyle=col; ctx.lineWidth=2.4; ctx.lineCap='round'; ctx.lineJoin='round'; ctx.stroke(Pt); } finally { ctx.restore(); }
}
// the words of a line, measured once per font: [{t,c,w}] and the total width
function feedParts(ln,fL,maxW){
  var P, w=0, i, sg, t, c0, tw;
  if(ln.mf===fL&&ln.pr&&ln.pw===maxW) return ln.pr;
  ctx.font=fL; P=[];
  for(i=0;i<ln.segs.length;i++){ sg=ln.segs[i]; P.push({t:sg.t,c:sg.c||ln.col}); }
  if(ln.n>1) P.push({t:'  x'+ln.n,c:HUDC.text});
  if(ln.money) P.push({t:'  '+ln.money,c:UIC.r_gold});
  if(ln.tag) P.push({t:'  \u00b7  '+ln.tag,c:HUDC.dim});
  for(i=0;i<P.length;i++){ P[i].w=ctx.measureText(P[i].t).width; w+=P[i].w; }
  if(w>maxW&&P.length){   // too long for the zone: the first piece gives way, with a mark at its end
    t=P[0].t; tw=w-P[0].w;
    while(t.length>3&&tw+ctx.measureText(t+'...').width>maxW) t=t.slice(0,-1);
    P[0].t=t+'...'; P[0].w=ctx.measureText(P[0].t).width; w=tw+P[0].w;
  }
  ln.pr=P; ln.pr.w=w; ln.mf=fL; ln.pw=maxW;
  return P;
}
function feedDraw(){
  var F=G&&G.fd, R, rs, fL, pad, gs, oa, y, yt, x, w, i, n, ln, al, e, pr, j, tx, yb, tw0;
  FEEDBOX.on=0; FEEDBOX.rows=[];
  if(!G||G.sim||!G.player||G.over) return 0;
  R=feedRect(); FEEDBOX.x=R.x; FEEDBOX.y=R.y; FEEDBOX.w=R.w; FEEDBOX.h=R.h; FEEDBOX.on=1;   // the zone is kept whether or not a line is up
  if(!F||!F.lines.length) return 0;
  rs=Math.max(1,hudRes()); fL=hudFS(TYPE.label); pad=Math.round(LH(7)*rs); gs=Math.round(R.fp*0.95); oa=ctx.globalAlpha;
  ctx.save();
  try{
    ctx.font=fL; ctx.textBaseline='alphabetic'; ctx.textAlign='left';
    y=R.y+R.h;
    for(i=F.lines.length-1,n=0;i>=0&&n<FEED.show;i--,n++){
      ln=F.lines[i]; al=feedAlpha(ln); e=Math.min(1,(F.t-ln.born)/FEED.enter);
      pr=feedParts(ln,fL,R.w-pad*3-gs-Math.round(pad*0.7));
      w=Math.min(R.w,pad+Math.round(pad*0.5)+(ln.gl?gs+Math.round(pad*0.7):0)+pr.w+pad);
      x=R.x+Math.round((e-1)*LH(18)*rs); yt=y-R.rh;
      ctx.globalAlpha=oa*al*e;
      hudPlate(x,yt,w,R.rh,ln.col,HUDC.plate);
      tx=x+pad+Math.round(pad*0.5);
      if(ln.gl){ feedGlyph(ln.gl,tx,yt+R.rh/2,gs,ln.col); tx+=gs+Math.round(pad*0.7); }
      yb=yt+Math.round(R.rh/2+R.fp*0.34);
      ctx.font=fL;
      for(j=0;j<pr.length;j++){ ctx.fillStyle=pr[j].c; ctx.fillText(pr[j].t,tx,yb); tx+=pr[j].w; }
      FEEDBOX.rows.push({id:ln.id,t:ln.txt,fk:ln.fk,a:al,x:x,y:yt,w:w,h:R.rh});
      y-=R.rh+R.gap;
    }
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return n;
}
function msgTick(dt){
'@

SubRx @'
  pickTick(dt);   // v22.50 (R16): the pickup stack
'@ @'
  pickTick(dt);   // v22.50 (R16): the pickup stack
  feedTick(dt);   // v27.24 (feed1): the feed clock
'@

SubRx @'
    if(k==='log') return;
    if(k==='pick'){ pickSay(m,o); return; }
'@ @'
    if(k==='log') return;
    try{ feedSay(m,k,o); }catch(_fsy){}   // v27.24 (feed1): every line said is in the feed, whatever lane it also takes
    if(k==='pick'){ pickSay(m,o); return; }
'@

SubRx @'
function alertToFeed(e){ var o=e.o||{}; say(e.m,'obj',(o.sub||o.key)?{sub:o.sub||'',key:o.key||''}:null); }
'@ @'
function alertToFeed(e){ var o=e.o||{}; say(e.m,'obj',(o.sub||o.key)?{sub:o.sub||'',key:o.key||'',fd:1}:{fd:1}); }   // v27.24 (feed1): fd, it was written into the feed when it was said
'@

SubRx @'
function pickTag(item,tag){
  var q=G&&G.pick, i;
'@ @'
function pickTag(item,tag){
  try{ feedTag(item,tag); }catch(_ftg){}   // v27.24 (feed1): and on the feed line
  var q=G&&G.pick, i;
'@

SubRx @'
function label(x,y,txt,col,delay,big,ik){
  if(G.sim) return;
'@ @'
function label(x,y,txt,col,delay,big,ik){
  if(G.sim) return;
  try{ feedLabel(txt,col,ik); }catch(_flb){}   // v27.24 (feed1): a label that is a message is a line in the feed too
'@

SubRx @'
      if(e.byPlayer&&!(G.player&&G.player.specOut)){
        T.kills[e.kind]++; contractKill(e.kind);
'@ @'
      try{ feedKillEnt(e); }catch(_fke){}   // v27.24 (feed1): the kill in the feed, his, a teammate's or nobody's
      if(e.byPlayer&&!(G.player&&G.player.specOut)){
        T.kills[e.kind]++; contractKill(e.kind);
'@

SubRx @'
  try{ deathAnimAdd(e); }catch(_dz){}   // v17.47: his pick 29, the death animation in a linked window
'@ @'
  try{ deathAnimAdd(e); }catch(_dz){}   // v17.47: his pick 29, the death animation in a linked window
  try{ feedKillEnt(e); }catch(_fkm){}   // v27.24 (feed1): the kill in this window feed (the host word that names who did it joins this line)
'@

SubRx @'
function netFeedPush(s,who){
  var nm=
'@ @'
function netFeedPush(s,who){
  try{ if(NET.role==='join'){ var _fm=(s===NET.seat); feedKillLine(_fm?'YOU':String(netSeatName(s)||'PILLAGER').toUpperCase(),_fm,!_fm,String(who),HUDC.warn,''); } }catch(_fkp){}   // v27.24 (feed1): the host window writes its own kill line when the body falls
  var nm=
'@

SubRx @'
  S.pops.push({txt:txt,pts:pts,t:+G.t||0});
'@ @'
  try{ feedMedal(txt,pts); }catch(_fmd){}   // v27.24 (feed1): the medal and its figure in the feed
  S.pops.push({txt:txt,pts:pts,t:+G.t||0});
'@

SubRx @'
    ctx.restore();                              // v10.43: end of the message scale
  }
  };
'@ @'
    ctx.restore();                              // v10.43: end of the message scale
  }
  try{ feedDraw(); }catch(_fdw){}   // v27.24 (feed1): the feed, bottom left (over the map too)
  };
'@

SubRx @'
    var _legTarget=(HUDBOX.body?HUDBOX.body.y:H)-LH(8);
'@ @'
    var _legTarget=(HUDBOX.body?HUDBOX.body.y:H)-LH(8);
    if(FEEDBOX.on&&FEEDBOX.y-LH(8)<_legTarget) _legTarget=FEEDBOX.y-LH(8);   // v27.24 (feed1): the controls list stands above the feed
'@

SubRx @'
  var _bx=[HUDBOX.raiders,HUDBOX.legend,HUDBOX.body].filter
'@ @'
  var _bx=[HUDBOX.raiders,HUDBOX.legend,HUDBOX.body,FEEDBOX.on?FEEDBOX:null].filter
'@

SubRx @'
var VER='27.23';
'@ @'
var VER='27.24';
'@

$pat = "(?m)^  now:'v27\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.24: There is now one persistent feed at the bottom left that takes every raid line, newest at the bottom. Check 27.24 fails on v27.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
