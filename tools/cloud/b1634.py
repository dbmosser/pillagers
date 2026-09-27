import os, gen
from gen import patch, fixture
WD = "  m={t:'wd',sd:G.seed>>>0,tl:netNum(G.timeLeft),wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:netNum(G.wxT)||0,ai:(G.zones||[]).indexOf(G.active),z:z,s:s};"
patch(1634, [
("""function netWorldSend(){""",
"""// v16.34, HIS NOTE: player 2 CURRENT PILLAGERS board was broken. It listed the pillagers of its own seed, whose bodies it never
// runs (the host bodies replace them), so every row read DEAD and dropped off. THE HOST: its board rows, sent with the world word.
function netBoardRows(){
  var R=G.roster||[], out=[], i, r, e, inE, v, b;
  for(i=0;i<R.length&&out.length<40;i++){
    r=R[i]; e=r.ref;
    if(r.merc||(e&&e.merc)) continue;
    inE=!!(e&&G.ents.indexOf(e)>=0);
    if(inE){ v=0; for(b=0;b<(e.bag||[]).length;b++) v+=ival(e.bag[b]); r.val=v; }
    out.push([netClean(r.name,24),Math.round(r.val||0),r.out?'EXTRACTED':(inE?raiderStatus(e):'DEAD'),r.crew|0,r.out?1:0,(e&&e.rival)?1:0,(e&&e.elite)?1:0,(e&&e.ghost)?1:0]);
  }
  return out;
}
// A LINKED WINDOW: the host board, with the time each name went out or down kept here so the board ages them off as it does.
function netBoardTake(bd){
  var i, a, nm, st, o, row, old={}, rows=[];
  for(i=0;i<(G.netBoard||[]).length;i++) old[G.netBoard[i].name]=G.netBoard[i];
  for(i=0;i<bd.length&&i<40;i++){
    a=bd[i]; if(!a||typeof a.length!=='number'||a.length<5) continue;
    nm=(a[5]?'\\u2605 ':'')+netClean(a[0],24); if(!nm) continue;
    st=netClean(a[2],24)||'GONE'; o=old[nm];
    row={name:nm,val:Math.max(0,+a[1]||0),st:st,crew:a[3]|0,out:!!a[4],el:!!a[6],gh:!!a[7]};
    if(row.out) row.outAt=(o&&o.outAt!==undefined)?o.outAt:elapsed();
    if(st==='DEAD') row.deadAt=(o&&o.deadAt!==undefined)?o.deadAt:elapsed();
    rows.push(row);
  }
  G.netBoard=rows;
  return rows.length;
}
function netWorldSend(){"""),
(WD, WD + "\n  m.bd=netBoardRows();   // v16.34: the board, for the party"),
("""  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;""",
"""  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board"""),
("""  var R=G.roster;""",
"""  var R=G.roster, _nb=(NET.on&&netEntsPeer()&&G.netBoard)?G.netBoard:null;   // v16.34: a linked window draws the host board
  if(_nb) R=[];"""),
("""  if(!R||!R.length) return;""",
"""  if(!_nb&&(!R||!R.length)) return;"""),
("""  var _eNow=elapsed(),_stay=[],_gone=[],_LEAVE=10;""",
"""  if(_nb) for(i=0;i<_nb.length;i++){ if(_nb[i].out) out++; else if(_nb[i].st==='DEAD') dead++; else live++; rows.push(_nb[i]); }
  var _eNow=elapsed(),_stay=[],_gone=[],_LEAVE=10;"""),
], "PLAYER 2 CURRENT PILLAGERS BOARD. His note: player 2 board was broken. It listed the pillagers of its own seed, whose bodies the host bodies replace, so every row read DEAD and then dropped off. The host now sends its board (names, values, status, extracted) with the twice a second world word and player 2 draws that. Check 16.34 fails on v16.33",
"# PLAYER 2 CURRENT PILLAGERS BOARD (his note: player 2 board was broken).\n")
fixture(1634, r"""  {v:'16.34',what:'player 2 CURRENT PILLAGERS board: the host sends its rows with the world word and a linked window keeps them, with names, values and who is out',
   run:function(){
     if(typeof netBoardTake!=='function'||typeof netBoardRows!=='function') return 'this build has no shared board';
     var keep=G, rows, n;
     try{
       G={t:5,timeLeft:100,raidLen:540,roster:[],ents:[]};
       n=netBoardTake([['Kite',420,'LOOTING',1,0,0,0,0],['Van',90,'EXTRACTED',0,1,1,0,0],['Moss',0,'DEAD',2,0,0,1,0]]);
       rows=G.netBoard;
     } finally { G=keep; }
     if(n!==3||!rows||rows.length!==3) return 'three host rows became '+n;
     if(rows[0].name!=='Kite'||rows[0].val!==420||rows[0].st!=='LOOTING') return 'the first row reads '+JSON.stringify(rows[0]);
     if(!rows[1].out||rows[1].outAt===undefined||rows[1].name.indexOf('Van')<0) return 'the extracted row lost its stamp or name: '+JSON.stringify(rows[1]);
     if(rows[2].deadAt===undefined||!rows[2].el) return 'the dead row lost its stamp or elite mark: '+JSON.stringify(rows[2]);
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf('m.bd=netBoardRows();')<0) return 'the host does not send its board with the world word';
     if(src.indexOf('if(_nb) R=[];')<0) return 'the board does not draw the host rows on a linked window';
     return null; }},
""")
