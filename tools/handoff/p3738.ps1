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

# SEASON ZERO M2: RETIRE A PILLAGER, RENAME AT THE MAINFRAME, THE ACCOUNT NAME IN MENUS AND THE LOBBY, THE LINEAGE IN THE RESTORE CODE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
mig0p:1,lifeEarn:0,mig1x:1,mkt:{s:{}},
'@ @'
mig0p:1,lifeEarn:0,mig1x:1,mig2n:1,mkt:{s:{}},
'@

SubRx @'
          try{ seasonZeroMig(P); }catch(_szm){}
'@ @'
          try{ acctNameMig(P); }catch(_anm){}   // v37.xx (cw-m2retire): the name typed since m0 is the account name (once, P.mig2n)
          try{ seasonZeroMig(P); }catch(_szm){}
'@

SubRx @'
// The one short floor line after a death, at the next arrival there. Never in the demo.
'@ @'
// v37.xx (cw-m2retire), HIS RULINGS OF 11-01, plan m2: "A living pillager can retire into the hall. Its worn gear goes to the stash and it pays a bonus by level: $250 a level, so $5,000 at level 20. Then
// three heirs line up as on a death." Answer 6: rename "any time but this should happen at the mainframe right?" Answer 7: account and pillager names are separate; the account name shows in menus and the
// two-player lobby; over the head it is the pillager's. P.pname stays the old field and always holds the account name (the demo renames its own copy to PLAYER 1 or 2).
// A pillager with no raids cannot retire: birth for free, retire, birth again would print $250 a press and climb the ranks.
function acctNameMig(p){ if(!p||typeof p!=='object'||p.mig2n===1) return; if(typeof p.pname==='string'&&p.pname) p.acctName=p.pname; p.mig2n=1; }
// THE ONE WRITER of a typed account name. A save that has not played yet: its first pillager takes the name too.
function acctNameSet(v){
  var q;
  v=String(v||'').trim().slice(0,16)||'PILLAGER';
  P.pname=v; P.acctName=v; q=acctEnsure(P);
  if(q&&(q.gen|0)===1&&!(q.raids|0)&&!(P.runs|0)&&!P.hall.length){ q.name=v; q.num=1; }
  return v;
}
// Only on the floor of his own career: never in a raid, the demo or the player 2 window (which keeps today's rules until m3f).
function pilHome(){ if(!P||state!=='hub') return false; if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return false; if(typeof NETP2!=='undefined'&&NETP2) return false; return true; }
function pilHeadName(){
  var q;
  if(!P) return '';
  if((typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||(typeof NETP2!=='undefined'&&NETP2)) return String(P.pname||'');
  q=acctEnsure(P);
  return q?pilName(q):'';
}
// The rules of the birth card's name box. The numeral counts the lineage.
function pilRename(p,name){
  var q, v=String(name||'').toLowerCase().trim().slice(0,16);
  if(!v||!pilHome()) return null;
  q=acctEnsure(p); if(!q) return null;
  if(v!==String(q.name).toLowerCase()){ q.num=pilNum(p,v); q.name=v; try{ saveProfile(); }catch(_prs){} }
  return q;
}
function retirePay(q){ return 250*Math.max(1,(q&&q.lvl)|0); }
function pilRetire(){
  var q, pay, worn, i, r;
  if(!pilHome()) return null;
  q=pilNow(); if(!q||(q.raids|0)<1) return null;
  pay=retirePay(q); wornClean(P); worn=JSON.parse(JSON.stringify(P.worn));
  for(i=0;i<WORN_SLOTS.length;i++) wornOff(P,WORN_SLOTS[i]);
  P.credits=(+P.credits||0)+pay; lifeEarnAdd(pay);
  r=pilEnd(P,{how:'retire',pay:pay,worn:worn,look:pilLookNow()});
  pilHeirs(P);
  BIRTH=null;
  try{ saveProfile(); }catch(_prt){}
  document.getElementById('opmodal').classList.remove('on');
  try{ sndUi('ok'); }catch(_pro){}
  hubToast(pilName(r)+' retired  +$'+pay.toLocaleString(),6);
  birthOpen();
  return r;
}
// Keys and the pad press a button with no hold, so they get the confirm card instead of retiring on one press.
function pilRetireAsk(){
  var q=pilNow(), y=document.getElementById('askyes'), a=document.getElementById('askalt'), n=document.getElementById('askno');
  if(!q||!pilHome()) return;
  document.getElementById('askq').textContent='retire '+pilName(q)+'?';
  document.getElementById('asksub').textContent='+$'+retirePay(q).toLocaleString();
  ASKYES=function(){ pilRetire(); }; ASKALT=null;
  kitExtraHide();
  if(y) y.textContent='retire'; if(a) a.style.display='none'; if(n) n.textContent='not yet';
  ASKBACK='opmodal';
  openModal('askmodal');
}
// THE ROW ON THE HALL TAB: the living pillager's name box and the retire hold.
function hallMeDraw(){
  var m=document.getElementById('hallme'), n=document.getElementById('hallname'), b=document.getElementById('hallretire'), q;
  if(!m||!n||!b) return;
  q=pilHome()?pilNow():null;
  m.style.display=q?'':'none';
  if(!q) return;
  if(document.activeElement!==n) n.value=String(q.name).toLowerCase();
  b.disabled=(q.raids|0)<1;
  b.textContent=b.disabled?'retire after one raid':('retire '+pilName(q)+'  +$'+retirePay(q).toLocaleString());
  b.onmousedown=function(e){ if(e&&e.button!==undefined&&e.button!==0) return; craftHoldStart(b,pilRetire); };
  b.onmouseleave=function(){ craftHoldCancel(); };
  b.onclick=function(e){ if(e&&e.detail){ try{ say2('Hold for one second to confirm.'); }catch(_prc){} return; } pilRetireAsk(); };
  n.oninput=function(){
    var v=String(n.value||'').toLowerCase().slice(0,16);
    if(n.value!==v) n.value=v;
    if(v.trim()&&pilRename(P,v)) renderHall();
  };
  n.onblur=function(){ var w=pilNow(); if(w) n.value=String(w.name).toLowerCase(); };
  n.onkeydown=function(e){ if(e.code==='Escape') return; e.stopPropagation(); if(e.code==='Enter'||e.code==='NumpadEnter'){ e.preventDefault(); n.blur(); } };
}
// The one short floor line after a death, at the next arrival there. Never in the demo.
'@

SubRx @'
  var rb=document.getElementById('hallrecs'), lb=document.getElementById('halllist'), L, i, r, h, b, s, any;
'@ @'
  hallMeDraw();   // v37.xx (cw-m2retire)
  var rb=document.getElementById('hallrecs'), lb=document.getElementById('halllist'), L, i, r, h, b, s, any;
'@

SubRx @'
    #opane_hall .hallgrid > :nth-child(2){ margin-right:16px; }   /* v37.xx (cw-m2hallb), critic: gen sat 16px from how it ended, 32 now */
'@ @'
    #opane_hall .hallgrid > :nth-child(2){ margin-right:16px; }   /* v37.xx (cw-m2hallb), critic: gen sat 16px from how it ended, 32 now */
    #opane_hall #hallme{ display:grid; grid-template-columns:auto minmax(0,1fr) auto; gap:16px; align-items:center; margin:0 0 16px; }   /* v37.xx (cw-m2retire) */
    #opane_hall #hallme .hk{ white-space:nowrap; }
    #root #opane_hall #hallname{ box-sizing:border-box; width:100%; height:56px; padding:0 16px; background:var(--ui-panel); border:1px solid var(--ui-line-hi); border-radius:var(--rad); color:var(--tx-1); font:700 28px/1 var(--f-cond); text-transform:none; }
    #root #opane_hall #hallretire{ min-height:56px; padding:0 24px; font:700 24px/1 var(--f-cond); white-space:pre; text-transform:none; }
'@

SubRx @'
    <div id="hallrecs"></div>
'@ @'
    <div id="hallme" style="display:none"><span class="hk">rename</span><input id="hallname" maxlength="16" autocomplete="off" spellcheck="false" aria-label="name"><button id="hallretire"></button></div>
    <div id="hallrecs"></div>
'@

SubRx @'
  if(PADNAME||!input||(input.id!=='pnamein'&&input.id!=='birthname'))return false;
'@ @'
  if(PADNAME||!input||(input.id!=='pnamein'&&input.id!=='birthname'&&input.id!=='hallname'))return false;
'@

SubRx @'
(el.tagName==='INPUT'&&el.id!=='pnamein'&&el.id!=='birthname'&&!/^(button
'@ @'
(el.tagName==='INPUT'&&el.id!=='pnamein'&&el.id!=='birthname'&&el.id!=='hallname'&&!/^(button
'@

SubRx @'
  if(!document.getElementById('title').classList.contains('on')&&!birthOn()){padNameClose(false);return false;}
'@ @'
  if(!document.getElementById('title').classList.contains('on')&&!birthOn()&&!(n.input.id==='hallname'&&document.getElementById('opmodal').classList.contains('on'))){padNameClose(false);return false;}
'@

SubRx @'
PAD.focus.id==='pnamein'||PAD.focus.id==='birthname') padNameStart(PAD.focus);
'@ @'
PAD.focus.id==='pnamein'||PAD.focus.id==='birthname'||PAD.focus.id==='hallname') padNameStart(PAD.focus);
'@

SubRx @'
if(_pn)_pn.textContent=String(P.pname||'pillager').toLowerCase();
'@ @'
if(_pn)_pn.textContent=String(P.acctName||P.pname||'pillager').toLowerCase();
'@

SubRx @'
        ? ((P.pname||'PILLAGER')+'  \u00b7  '+P.runs+' raid'+
'@ @'
        ? ((P.acctName||P.pname||'PILLAGER')+'  \u00b7  '+P.runs+' raid'+
'@

SubRx @'
        return {name:(d.pname||'PILLAGER'),runs:d.runs||0,credits:d.credits||0,xp:d.xp||0};
'@ @'
        return {name:((d.mig2n===1&&d.acctName)||d.pname||'PILLAGER'),runs:d.runs||0,credits:d.credits||0,xp:d.xp||0};   // v37.xx (cw-m2retire): the account name
'@

SubRx @'
      P.pname=v||'PILLAGER'; saveProfile(); renderSlots();
'@ @'
      acctNameSet(v); saveProfile(); renderSlots();   // v37.xx (cw-m2retire)
'@

SubRx @'
if(_nv&&_nv!==P.pname&&_nv!==titleNameShown(P.pname)){ P.pname=_nv; saveProfile(); }
'@ @'
if(_nv&&_nv!==P.pname&&_nv!==titleNameShown(P.pname)){ acctNameSet(_nv); saveProfile(); }
'@

SubRx @'
  P.pname=o.n.trim().slice(0,16);
'@ @'
  acctNameSet(o.n);   // v37.xx (cw-m2retire)
'@

SubRx @'
function netMe(){ NET.name=netClean(P&&P.pname,16)||'PILLAGER';
'@ @'
function netMe(){ NET.name=netClean(P&&(P.acctName||P.pname),16)||'PILLAGER';
'@

SubRx @'
  sb.pname=(ARCADE.role==='p2')?'PLAYER 2':'PLAYER 1';
'@ @'
  sb.pname=(ARCADE.role==='p2')?'PLAYER 2':'PLAYER 1'; sb.acctName=sb.pname;   // v37.xx (cw-m2retire)
'@

SubRx @'
function netSeatName(s){
'@ @'
function netPnPut(msg,n){ var nm=netClean(pilHeadName(),24); if(nm&&(nm!==NET.pnSent||n%10===0)){ msg.pn=nm; NET.pnSent=nm; } }   // v37.xx (cw-m2retire)
function netSeatName(s){
'@

SubRx @'
?('Player '+(s+1)):r[i].name;
'@ @'
?('Player '+(s+1)):((NET.pn&&NET.pn[s])||r[i].name);   // v37.xx (cw-m2retire): the name his word carries (his pillager), else the roster's; the lobby reads the roster itself
'@

SubRx @'
  up=(m.k==='r'); x=clamp(m.x,0,up?NET_UP_MAX:HUBW); y=clamp(m.y,0,up?NET_UP_MAX:HUBH);
'@ @'
  if(typeof m.pn==='string'&&netClean(m.pn,24)){ if(!NET.pn) NET.pn={}; NET.pn[s]=netClean(m.pn,24); }   // v37.xx (cw-m2retire); a word without it (an older window) leaves the roster's name
  up=(m.k==='r'); x=clamp(m.x,0,up?NET_UP_MAX:HUBW); y=clamp(m.y,0,up?NET_UP_MAX:HUBH);
'@

SubRx @'
    if(lk) out.lk=lk;
'@ @'
    if(lk) out.lk=lk;
    if(typeof m.pn==='string'&&NET.pn&&NET.pn[s]) out.pn=NET.pn[s];   // v37.xx (cw-m2retire): passed on as it came
'@

SubRx @'
  if(ls!==NET.lkSent||NET.hubN%10===0){ msg.lk=lk; NET.lkSent=ls; }
'@ @'
  if(ls!==NET.lkSent||NET.hubN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  netPnPut(msg,NET.hubN);   // v37.xx (cw-m2retire)
'@

SubRx @'
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
'@ @'
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  netPnPut(msg,NET.upN);   // v37.xx (cw-m2retire)
'@

SubRx @'
  NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[];
'@ @'
  NET.pn={}; NET.pnSent=''; NET.pend=null; NET.on=false; NET.role=null; NET.seat=-1; NET.roster=[];   // v37.xx (cw-m2retire): pn
'@

SubRx @'
      netSrchEndSeat(peer.seat);   // v15.91: a box he was searching is free again
'@ @'
      if(NET.pn) delete NET.pn[peer.seat];   // v37.xx (cw-m2retire)
      netSrchEndSeat(peer.seat);   // v15.91: a box he was searching is free again
'@

SubRx @'
r:(p.rollT>0)?+(+p.rollT).toFixed(2):0,nm:netClean(P&&P.pname,16)};
'@ @'
r:(p.rollT>0)?+(+p.rollT).toFixed(2):0,nm:netClean(pilHeadName(),24)};   // v37.xx (cw-m2retire): over the head in the other window
'@

SubRx @'
  var nm=netClean(g&&g.nm,16);
'@ @'
  var nm=netClean(g&&g.nm,24);
'@

SubRx @'
g.n++; g.nm=netClean(m.nm,16);
'@ @'
g.n++; g.nm=netClean(m.nm,24);
'@

SubRx @'
escHtml(r[i].seat===NET.seat?'YOU':r[i].name)
'@ @'
escHtml(r[i].seat===NET.seat?'YOU':(netSeatName(r[i].seat)||r[i].name))
'@

SubRx @'
  <h1 id="oc_title">EXTRACTED</h1>
'@ @'
  <div id="oc_pil" style="display:none;font:600 20px/1.2 var(--f-cond);color:var(--tx-2);margin-bottom:8px"></div>   <!-- v37.xx (cw-m2retire): whose raid this was -->
  <h1 id="oc_title">EXTRACTED</h1>
'@

SubRx @'
  var t=document.getElementById('oc_title'),s=document.getElementById('oc_sub');
'@ @'
  try{ (function(){ var _e=document.getElementById('oc_pil'), _h=P&&P.hall, _q=(G.sim||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||(typeof NETP2!=='undefined'&&NETP2))?null:((P&&P.pil)||(_h&&_h[_h.length-1])); if(_e){ _e.textContent=_q?pilName(_q):''; _e.style.display=_q?'':'none'; } })(); }catch(_ocp){}   // v37.xx (cw-m2retire): the pillager that went up, on the card whether it lived or not
  var t=document.getElementById('oc_title'),s=document.getElementById('oc_sub');
'@

SubRx @'
  var o={v:1,n:P.pname||'PILLAGER',c:P.credits||0,x:P.xp||0,l:P.xpLevel||1,
'@ @'
  var o={v:1,n:P.acctName||P.pname||'PILLAGER',c:P.credits||0,x:P.xp||0,l:P.xpLevel||1,   // v37.xx (cw-m2retire): n, the account name
'@

SubRx @'
  for(var wk in (P.wear||{})) if(P.wear[wk]) o.g.wr[wk]=P.wear[wk]|0;
'@ @'
  for(var wk in (P.wear||{})) if(P.wear[wk]) o.g.wr[wk]=P.wear[wk]|0;
  // v37.xx (cw-m2retire): THE LINEAGE TRAVELS WITH THE CODE: the living pillager, the hall, the generation and any heirs waiting.
  acctEnsure(P); o.pl={p:P.pil||null,h:P.hall,g:P.pilGen|0}; if(P.heirs) o.pl.e=P.heirs;
'@

SubRx @'
  P.pname=String(o.n||'PILLAGER').slice(0,16);
'@ @'
  P.pname=String(o.n||'PILLAGER').slice(0,16); P.acctName=P.pname; P.mig2n=1;   // v37.xx (cw-m2retire)
'@

SubRx @'
  P.mig1r=0; try{ rankMig(P); }catch(_rkr){}
'@ @'
  // v37.xx (cw-m2retire): A RESTORE NEVER WEARS ANOTHER ACCOUNT'S LINEAGE. The code's pillager, hall, generation and heirs come through. An older code has none, so acctEnsure makes generation one and it
  // keeps the character's record, as seasonZeroMig does. A death note or a paid kit waiting belonged to the save being replaced.
  (function(){
    var L=(o.pl&&typeof o.pl==='object'&&!Array.isArray(o.pl))?o.pl:null, q;
    P.hall=(L&&Array.isArray(L.h))?L.h.filter(function(r){ return !!r&&typeof r==='object'; }):[];
    P.pil=(L&&L.p&&typeof L.p==='object'&&!Array.isArray(L.p))?L.p:null;
    P.pilGen=(L&&typeof L.g==='number'&&isFinite(L.g))?Math.max(0,L.g|0):0;
    delete P.heirs; if(L&&Array.isArray(L.e)) P.heirs=L.e;
    delete P.pilNote; delete P.birthKit; delete P.birthLook; BIRTH=null;
    q=acctEnsure(P);
    if(!L&&q){ q.raids=Math.max(0,o.r|0); q.ext=Math.max(0,o.e|0); q.best=Math.max(0,+o.b||0); q.kills=Math.max(0,((o.an&&o.an.r)|0)+((o.an&&o.an.m)|0)); q.born=0; }
  })();
  P.mig1r=0; try{ rankMig(P); }catch(_rkr){}
'@

SubRx @'
var VER='37.37';
'@ @'
var VER='37.38';
'@

$pat = "(?m)^  now:'v37\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.38: the hall tab has a rename box and a retire row: hold to retire pays 250 a level into lifetime earnings, moves worn gear to the stash, puts the pillager in the hall and opens the birth card (keys and pad get a confirm card, one raid needed first); the title name is the account name in menus, save slots and the lobby; the partner sees the pillager name with numeral over the head; the run card names the pillager; restore codes carry the lineage and old codes still restore Check 37.38 fails on v37.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
