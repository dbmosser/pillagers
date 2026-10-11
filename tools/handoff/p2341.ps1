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

# ARCADE: PARTY SCOREBOARD AND INITIALS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _arn=false, _ar0=pressed(0)&&!PAD.prev[0];
      for(_ati=0;_ati<bt.length;_ati++) if(pressed(_ati)&&!PAD.prev[_ati]) _arn=true;
      for(_ati=0;_ati<bt.length;_ati++) PAD.prev[_ati]=pressed(_ati);
      padRelease();
      try{ arcadePadAtt(_arn,_ar0); }catch(_apa){}
'@ @'
      var _arn=false, _ar0=pressed(0)&&!PAD.prev[0], _arw=[];
      for(_ati=0;_ati<bt.length;_ati++) if(pressed(_ati)&&!PAD.prev[_ati]){ _arn=true; _arw.push(_ati); }
      for(_ati=0;_ati<bt.length;_ati++) PAD.prev[_ati]=pressed(_ati);
      padRelease();
      try{ if(!arcadePadIni(_arw,ax)) arcadePadAtt(_arn,_ar0); }catch(_apa){}   // v23.41 (arcade18): the initials card takes the pad first
'@

SubRx @'
  ARCADE.over=null; try{ arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card goes
'@ @'
  try{ arcadeIniEnd(); }catch(_ie){}   // v23.41 (arcade18): initials still up keep what is there
  ARCADE.over=null; try{ arcadeOverSync(); }catch(_ov){}   // v23.39 (arcade16): the RUN OVER card goes
'@

SubRx @'
  arcadeScSend('x',ARCADE_XBONUS+pot);   // v23.29 (arcade8): the teammate sees PLAYER 1 EXTRACTED
'@ @'
  arcadeScSend('x',ARCADE_XBONUS+pot);   // v23.29 (arcade8): the teammate sees PLAYER 1 EXTRACTED
  try{ arcadeBoardPut(); }catch(_bp){}   // v23.41 (arcade18): the board row is written at every extraction
'@

SubRx @'
  if(m.ev==='x'&&(m.n|0)>0&&G&&G.arcade&&!G.over){ try{ say((ARCADE.role==='p2'?'PLAYER 1':'PLAYER 2')+' EXTRACTED +'
'@ @'
  if(m.ev==='x'&&ARCADE.role==='host'){ try{ arcadeBoardPut(); }catch(_bx){} }   // v23.41 (arcade18): a player 2 extraction checkpoints the board row
  if(m.ev==='x'&&(m.n|0)>0&&G&&G.arcade&&!G.over){ try{ say((ARCADE.role==='p2'?'PLAYER 1':'PLAYER 2')+' EXTRACTED +'
'@

SubRx @'
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
'@ @'
    if(m.t==='arcinis') return arcadeIniMirror(m);   // v23.41 (arcade18): the host initials card, shown here too
    if(m.t==='archi'){   // v23.41 (arcade18): the host saw the team pass tonights best
      if(!ARCADE.on) return 'ignored';
      if(ARCADE.hiRun===String(m.run||'')&&ARCADE.hiSaid) return 'ignored';
      ARCADE.hiRun=String(m.run||'').slice(0,40); ARCADE.hiSaid=1;
      if(G&&G.arcade&&!G.over) arcadeHiSay(+m.s||arcadeTeam());
      return 'archi';
    }
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
'@

SubRx @'
    if(m.t==='arcact'){ ARCADE.mateAt=Date.now(); return 'arcact'; }   // v23.39 (arcade16): player 2 is playing
'@ @'
    if(m.t==='arcini'){ if(!ARCADE.ini||ARCADE.ini.mirror) return 'ignored'; arcadeIniOp(String(m.op||'').slice(0,4)); return 'arcini'; }   // v23.41 (arcade18): the player 2 pad on the initials card
    if(m.t==='arcact'){ ARCADE.mateAt=Date.now(); return 'arcact'; }   // v23.39 (arcade16): player 2 is playing
'@

SubRx @'
  try{ arcadeIdleTick(Date.now()); }catch(_ai){}   // v23.39 (arcade16): idle return and the run end
'@ @'
  try{ arcadeIdleTick(Date.now()); }catch(_ai){}   // v23.39 (arcade16): idle return and the run end
  try{ arcadeIniTick(Date.now()); }catch(_it){}   // v23.41 (arcade18): 20 s untouched keeps what is there
  try{ arcadeHiTick(); }catch(_ht){}   // v23.41 (arcade18): NEW HIGH SCORE, once per run
'@

SubRx @'
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
'@ @'
  if(ARCADE.role==='host'&&arcadeIniLive()) return arcadeIniKey(e);   // v23.41 (arcade18): the initials card takes the keys, and a click drops nobody in
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
'@

SubRx @'
  if(host) netSamePost({t:'arcend',pair:NET.pair});
  arcadeRaidStop('end');
  ARCADE.wantIn=0; ARCADE.idleSaid=0;
  try{ arcadeAttShow(); }catch(_as){}
  return true;
}
'@ @'
  var _bw=false; try{ _bw=arcadeBoardPut(); }catch(_bp){}   // v23.41 (arcade18): the final board row
  if(host) netSamePost({t:'arcend',pair:NET.pair});
  arcadeRaidStop('end');
  ARCADE.wantIn=0; ARCADE.idleSaid=0;
  try{ if(_bw&&ARCADE.run&&arcadeBoardQual(ARCADE.run.id)) arcadeIniStart(ARCADE.run.id); }catch(_is){}   // v23.41 (arcade18): a top 10 run asks for initials
  try{ arcadeAttShow(); }catch(_as){}
  return true;
}
'@

SubRx @'
function arcadeOverSync(){
  var o=ARCADE.over, on=!!(ARCADE.on&&o&&Date.now()-(+o.at||0)<ARCADE_IDLE.overMs&&!(G&&G.arcade&&!arcadeBenched())), c, i, ln, el;
  if(!on&&!document.querySelector('#attract .arcover')) return false;
  c=arcadeOverEl();
  if(on&&c.getAttribute('data-at')!==String(o.at)){
    c.textContent=''; c.setAttribute('data-at',String(o.at));
    ln=[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]];
    for(i=0;i<ln.length;i++){ if(!ln[i][1]) continue; el=document.createElement('div'); el.className=ln[i][0]; el.textContent=ln[i][1]; c.appendChild(el); }
  }
  c.style.display=on?'block':'none';
  return on;
}
'@ @'
function arcadeOverSync(){
  var o=ARCADE.over, oc=!!(o&&Date.now()-(+o.at||0)<ARCADE_IDLE.overMs), ini=arcadeIniLive()?ARCADE.ini:null,
      on=!!(ARCADE.on&&(oc||ini)&&!(G&&G.arcade&&!arcadeBenched())), c, i, ln, el, sig;   // v23.41 (arcade18): the initials card keeps it up
  if(!on&&!document.querySelector('#attract .arcover')) return false;
  c=arcadeOverEl();
  sig=(oc?String(o.at):'-')+'|'+(ini?(ini.l.join('')+ini.pos):'');
  if(on&&c.getAttribute('data-at')!==sig){
    c.textContent=''; c.setAttribute('data-at',sig);
    ln=oc?[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]]:[];
    for(i=0;i<ln.length;i++){ if(!ln[i][1]) continue; el=document.createElement('div'); el.className=ln[i][0]; el.textContent=ln[i][1]; c.appendChild(el); }
    if(ini) arcadeIniDraw(c,ini);
  }
  c.style.display=on?'block':'none';
  return on;
}
'@

SubRx @'
  var d=ATT.el, i, e, cl=['arcpage','arcboo','arcstrip','arcover'], v;
  ARCADE.att=null;
'@ @'
  var d=ATT.el, i, e, cl=['arcpage','arcboo','arcstrip','arcover'], v;
  ARCADE.att=null;
  try{ arcadeIniEnd(); }catch(_ie){}   // v23.41 (arcade18): initials still up keep what is there
'@

SubRx @'
// The containers as this window holds them, for the test page handle.
'@ @'
// v23.41, HIS ORDER (2026-10-11), build 18 of 20 (arcade18): THE PARTY SCOREBOARD, INITIALS AND NEW HIGH SCORE. The party night needs a
// board to beat. The board has its own key (ARCADE_BOARD_KEY, never his save): {v:1, rows:[{run,i,s,x,k,t}]}, one row per run, at most
// 100 kept (the 50 best and the 50 newest). Only the run authority writes it (the host, or player 2 after a host takeover): the run
// row is written at every extraction (his and player 2) and finalised at the run end, so a crash or a reload keeps the score.
// TONIGHTS BEST on the attract is the top 10 of the last 12 hours and BEST EVER the overall best. A run that makes tonights top 10
// with no initials yet gets the 3 letter initials card on the RUN OVER card, on both windows: the pad (up and down change the letter,
// right or A next, left or B back, MENU done; player 2 sends its pad as arcini and the host sends the card as arcinis) or the
// keyboard (letters, Backspace, Enter). 20 s with no input keeps what is there, or ??? if it was never touched. While the card is up
// the loop pages wait and a click or key drops nobody in. NEW HIGH SCORE is said once per run on both windows (archi) when the team
// passes tonights best. Every line is behind ARCADE.on or G.arcade, so a normal raid writes and draws nothing new.
var ARCADE_BOARD_KEY='pillagers:arcade:board';
var ARCADE_BOARD={keep:100,night:12*3600000,top:10,iniMs:20000,mirMs:25000};
var ARCADE_INI_AB='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
function arcadeBoardLoad(){
  var o=null, r, out=[], i, x;
  try{ o=JSON.parse(localStorage.getItem(ARCADE_BOARD_KEY)||'null'); }catch(_bl){ o=null; }
  r=(o&&Array.isArray(o.rows))?o.rows:[];
  for(i=0;i<r.length;i++){
    x=r[i]; if(!x||typeof x.run!=='string'||!x.run) continue;
    out.push({run:x.run.slice(0,40),i:(typeof x.i==='string')?x.i.slice(0,3).toUpperCase():'',s:Math.max(0,Math.round(+x.s||0)),x:Math.max(0,x.x|0),k:Math.max(0,x.k|0),t:+x.t||0});
  }
  return out;
}
// one row per run: the best score, and the initials from any of its rows
function arcadeBoardDedupe(r){
  var m={}, out=[], i, x, o;
  for(i=0;i<r.length;i++){
    x=r[i]; o=Object.prototype.hasOwnProperty.call(m,x.run)?m[x.run]:null;
    if(!o){ o=m[x.run]={run:x.run,i:x.i||'',s:x.s,x:x.x,k:x.k,t:x.t}; out.push(o); continue; }
    if(!o.i&&x.i) o.i=x.i;
    if(x.s>o.s||(x.s===o.s&&x.t>o.t)){ o.s=x.s; o.x=x.x; o.k=x.k; o.t=x.t; }
  }
  return out;
}
function arcadeBoardSave(rows){
  var r=arcadeBoardDedupe(rows), h=Math.floor(ARCADE_BOARD.keep/2), all, out=[], seen={}, i, x;
  all=r.slice().sort(function(p,q){ return q.s-p.s; }).slice(0,h).concat(r.slice().sort(function(p,q){ return q.t-p.t; }).slice(0,h));
  for(i=0;i<all.length;i++){ x=all[i]; if(seen[x.run]) continue; seen[x.run]=1; out.push(x); }
  try{ localStorage.setItem(ARCADE_BOARD_KEY,JSON.stringify({v:1,rows:out})); return true; }catch(_bs){ return false; }
}
// tonights best: the last 12 hours, one row per run, best first, the top 10
function arcadeBoardTonight(now){
  now=+now||Date.now();
  var r=arcadeBoardDedupe(arcadeBoardLoad()), out=[], i;
  for(i=0;i<r.length;i++) if(r[i].t>=now-ARCADE_BOARD.night&&r[i].t<=now+60000) out.push(r[i]);
  out.sort(function(p,q){ return (q.s-p.s)||(p.t-q.t); });
  return out.slice(0,ARCADE_BOARD.top);
}
function arcadeBoardBest(){ var r=arcadeBoardLoad(), b=0, i; for(i=0;i<r.length;i++) if(r[i].s>b) b=r[i].s; return b; }
function arcadeBoardAuth(){ return !!(ARCADE.on&&(ARCADE.role==='host'||(G&&G.netWasJoin))); }
// the run row, written in place under the run id. Returns whether it was written.
function arcadeBoardPut(){
  if(!arcadeBoardAuth()||!ARCADE.run||!ARCADE.run.id) return false;
  var id=ARCADE.run.id, s=arcadeTeam(), r, i, ini='';
  if(!(s>0)) return false;
  r=arcadeBoardLoad();
  for(i=r.length-1;i>=0;i--) if(r[i].run===id){ if(!ini&&r[i].i) ini=r[i].i; if(r[i].s>s) s=r[i].s; r.splice(i,1); }
  r.push({run:id,i:ini,s:s,x:Math.max(0,(ARCADE.ext|0)+(ARCADE.mateX|0)),k:Math.max(0,(ARCADE.kills|0)+(ARCADE.mateK|0)),t:Date.now()});
  return arcadeBoardSave(r);
}
// the run is in tonights top 10 and has no initials yet
function arcadeBoardQual(id){
  var r=arcadeBoardTonight(), i;
  for(i=0;i<r.length;i++) if(r[i].run===id) return !r[i].i;
  return false;
}
function arcadeBoardIni(id,ini){
  var r=arcadeBoardLoad(), i, n=0;
  for(i=0;i<r.length;i++) if(r[i].run===id){ r[i].i=ini; n++; }
  return n?arcadeBoardSave(r):false;
}
// The initials card. ARCADE.ini={run,l,pos,at,touched,mirror}: mirror is player 2 showing the host card.
function arcadeIniLive(){ return !!(ARCADE.on&&ARCADE.ini); }
function arcadeIniStart(run){
  run=(typeof run==='string'&&run)?run:((ARCADE.run&&ARCADE.run.id)||'');
  if(!ARCADE.on||!run) return false;
  ARCADE.ini={run:run,l:['A','A','A'],pos:0,at:Date.now(),touched:0,mirror:0};
  ARCADE.iniAy=1;   // a stick already held does not move the first letter
  arcadeIniPost();
  try{ if(ARCADE.att) ARCADE.att.ph=''; arcadeOverSync(); }catch(_io){}
  return true;
}
function arcadeIniPost(){
  var n=ARCADE.ini;
  if(!n||n.mirror||ARCADE.role!=='host') return false;
  return netSamePost({t:'arcinis',pair:NET.pair,run:n.run,l:n.l.join(''),pos:n.pos,on:1});
}
// One op on the card: up, down, next, back, done, or a letter. Returns the letters (the initials once it is done).
function arcadeIniOp(op){
  var n=ARCADE.ini, A=ARCADE_INI_AB, c;
  if(!n||n.mirror) return '';
  op=String(op||'');
  if(op==='done') return arcadeIniEnd();
  if(op==='up'||op==='down'){ c=A.indexOf(n.l[n.pos]); if(c<0) c=0; n.l[n.pos]=A.charAt((c+(op==='up'?1:25))%26); }
  else if(op==='next') n.pos++;
  else if(op==='back'){ if(n.pos>0) n.pos--; }
  else if(op.length===1&&A.indexOf(op.toUpperCase())>=0){ n.l[n.pos]=op.toUpperCase(); n.pos++; }
  else return n.l.join('');
  n.touched=1; n.at=Date.now();
  if(n.pos>2) return arcadeIniEnd();
  arcadeIniPost();
  try{ arcadeOverSync(); }catch(_io){}
  return n.l.join('');
}
// The card closes: the owner writes the initials (??? when never touched); a mirror just goes.
function arcadeIniEnd(){
  var n=ARCADE.ini, s='';
  if(!n) return '';
  ARCADE.ini=null;
  if(!n.mirror){
    s=n.touched?n.l.join(''):'???';
    try{ arcadeBoardIni(n.run,s); }catch(_bi){}
    if(ARCADE.role==='host') netSamePost({t:'arcinis',pair:NET.pair,run:n.run,on:0});
  }
  try{ if(ARCADE.att) ARCADE.att.ph=''; arcadeOverSync(); }catch(_io){}
  return s;
}
function arcadeIniTick(now){
  var n=ARCADE.ini;
  if(!n) return '';
  now=+now||Date.now();
  if(now-(+n.at||0)<(n.mirror?ARCADE_BOARD.mirMs:ARCADE_BOARD.iniMs)) return '';
  if(n.mirror){ ARCADE.ini=null; try{ if(ARCADE.att) ARCADE.att.ph=''; arcadeOverSync(); }catch(_io){} return 'gone'; }
  return arcadeIniEnd();
}
// player 2: the host card, as arcinis tells it
function arcadeIniMirror(m){
  if(!ARCADE.on) return 'ignored';
  if(!m.on){
    if(ARCADE.ini&&ARCADE.ini.mirror){ ARCADE.ini=null; try{ if(ARCADE.att) ARCADE.att.ph=''; arcadeOverSync(); }catch(_io){} }
    return 'arcinis';
  }
  var l=(String(m.l||'')+'AAA').slice(0,3).toUpperCase().split(''), i;
  for(i=0;i<3;i++) if(ARCADE_INI_AB.indexOf(l[i])<0) l[i]='A';
  ARCADE.ini={run:String(m.run||'').slice(0,40),l:l,pos:clamp(m.pos|0,0,2),at:Date.now(),touched:1,mirror:1};
  ARCADE.iniAy=1;
  try{ arcadeOverSync(); }catch(_io2){}
  return 'arcinis';
}
// The host keyboard on the card: letters, Backspace, Enter (and the arrows). Every press and click is taken.
function arcadeIniKey(e){
  var ty=String(e.type||''), cd=String(e.code||''), ky=String(e.key||''), op='';
  if(ty==='wheel') return false;
  if(ty==='keydown'&&(/^F([1-9]|1[0-2])$/.test(cd)||e.ctrlKey||e.altKey||e.metaKey||cd==='Escape')) return false;
  try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
  if(ty!=='keydown'||e.repeat) return true;
  if(/^[a-zA-Z]$/.test(ky)) op=ky.toUpperCase();
  else if(/^Key[A-Z]$/.test(cd)) op=cd.charAt(3);
  else if(cd==='Backspace'||cd==='ArrowLeft') op='back';
  else if(cd==='ArrowRight'||cd==='Space'||cd==='Tab') op='next';
  else if(cd==='ArrowUp') op='up';
  else if(cd==='ArrowDown') op='down';
  else if(cd==='Enter'||cd==='NumpadEnter') op='done';
  if(op) arcadeIniOp(op);
  return true;
}
// The pad on the card: nw is the buttons newly pressed this poll, ax the axes. Player 2 sends its op to the host.
function arcadePadIni(nw,ax){
  if(!arcadeIniLive()) return false;
  var op='', i, b, ay=(ax&&+ax[1])||0;
  nw=nw||[];
  for(i=0;i<nw.length&&!op;i++){ b=nw[i]; op=(b===12)?'up':(b===13)?'down':(b===15||b===0)?'next':(b===14||b===1)?'back':(b===9)?'done':''; }
  if(!op){
    if(Math.abs(ay)<0.3) ARCADE.iniAy=0;
    else if(!ARCADE.iniAy&&Math.abs(ay)>0.6){ ARCADE.iniAy=1; op=(ay<0)?'up':'down'; }
  }
  if(op){ if(ARCADE.ini.mirror) netSamePost({t:'arcini',pair:NET.pair,op:op}); else arcadeIniOp(op); }
  return true;
}
function arcadeIniDraw(c,n){
  var el, sp, i, st;
  if(!document.getElementById('arcinicss')){
    st=document.createElement('style'); st.id='arcinicss';
    st.textContent='#attract .arcover .aoi{color:#7fe3d4;margin-top:.55em}#attract .arcover .aol{font-size:2.6em;letter-spacing:.4em;margin:.05em 0 .05em .4em}'+
      '#attract .arcover .aol span{display:inline-block;min-width:1em;border-bottom:.08em solid rgba(242,230,200,.35)}#attract .arcover .aol span.cur{color:#ffc04a;border-bottom-color:#ffc04a}'+
      '#attract .arcover .aoq{font-size:.6em;opacity:.8}';
    document.head.appendChild(st);
  }
  el=document.createElement('div'); el.className='aoi'; el.textContent='TOP 10 TONIGHT \u00b7 ENTER INITIALS'; c.appendChild(el);
  el=document.createElement('div'); el.className='aol';
  for(i=0;i<3;i++){ sp=document.createElement('span'); sp.textContent=n.l[i]||'A'; if(i===n.pos) sp.className='cur'; el.appendChild(sp); }
  c.appendChild(el);
  el=document.createElement('div'); el.className='aoq'; el.textContent=padB('TYPE OR \u25b2\u25bc  \u00b7  A NEXT  \u00b7  B BACK  \u00b7  ENTER / MENU DONE'); c.appendChild(el);
}
// NEW HIGH SCORE: the run authority, every half second in an arcade raid. The bar is tonights best of the other runs, read once per run.
function arcadeHiTick(){
  if(!arcadeBoardAuth()||!G||!G.arcade||G.over||G.sim||!ARCADE.run||!ARCADE.run.id) return false;
  var id=ARCADE.run.id, r, i, b=0, t=arcadeTeam();
  if(ARCADE.hiRun!==id){
    ARCADE.hiRun=id; ARCADE.hiSaid=0; r=arcadeBoardTonight();
    for(i=0;i<r.length;i++) if(r[i].run!==id&&r[i].s>b) b=r[i].s;
    ARCADE.hiBar=b;
  }
  if(ARCADE.hiSaid||!(ARCADE.hiBar>0)||!(t>ARCADE.hiBar)) return false;
  ARCADE.hiSaid=1;
  arcadeHiSay(t);
  netSamePost({t:'archi',pair:NET.pair,run:id,s:t});
  return true;
}
function arcadeHiSay(t){ try{ say('NEW HIGH SCORE','ext',{sub:'TEAM SCORE '+arcadeN(t)}); }catch(_hs){} }
// The containers as this window holds them, for the test page handle.
'@

SubRx @'
var VER='23.40';
'@ @'
var VER='23.41';
'@

$pat = "(?m)^  now:'v23\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.41: In the arcade a top 10 run now enters 3 initials for TONIGHTS BEST, and passing the best of the night calls NEW HIGH SCORE. Check 23.41 fails on v23.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
