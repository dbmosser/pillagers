import os, gen
from gen import patch, fixture
patch(1644, [
("""function damagePlayer(amt,src,srcName,sx,sy){""",
"""function damagePlayer(amt,src,srcName,sx,sy){
  if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&isFinite(amt)) amt*=netKidMul();   // v16.44, his order: kid mode, player 2 takes less"""),
("""  host.innerHTML=_go+""",
"""  host.innerHTML=_go+kidRowHtml()+"""),
("""  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };""",
"""  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };
  (function(){ var _kb=document.getElementById('set_kid'); if(_kb) _kb.onclick=function(){ kidCycle(); renderSettings(); }; })();   // v16.44"""),
("""  m.bd=netBoardRows();   // v16.34: the board, for the party""",
"""  m.bd=netBoardRows();   // v16.34: the board, for the party
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live"""),
("""  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board""",
"""  if(m.bd&&typeof m.bd.length==='number') netBoardTake(m.bd);   // v16.34: the host board
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it"""),
("""var NET_FEED_T=6;""",
"""var NET_FEED_T=6;
// v16.44, HIS ORDER: KID MODE. Player 2 (every window that joined a party) takes a fraction of the damage: all of it, 1/2, 1/4,
// 1/5 or 1/10. A row in Settings on either window sets it; the host sends its choice with the world word twice a second, so a
// change on the host lands on player 2 mid raid, and player 2 takes the lower of the two. Player 1 is never touched.
var KID_OPTS=[[1,'OFF'],[0.5,'1/2'],[0.25,'1/4'],[0.2,'1/5'],[0.1,'1/10']];
function kidMulOwn(){ var v=(typeof P!=='undefined'&&P)?+P.kidDmg:1; return (isFinite(v)&&v>=0.1&&v<=1)?v:1; }
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=0.1&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
function kidCycle(){
  var i, v=kidMulOwn(), ix=0;
  for(i=0;i<KID_OPTS.length;i++) if(Math.abs(KID_OPTS[i][0]-v)<1e-6) ix=i;
  P.kidDmg=KID_OPTS[(ix+1)%KID_OPTS.length][0];
  saveProfile();
  return P.kidDmg;
}
function kidRowHtml(){
  var i, v=kidMulOwn(), lbl='OFF';
  for(i=0;i<KID_OPTS.length;i++) if(Math.abs(KID_OPTS[i][0]-v)<1e-6) lbl=KID_OPTS[i][1];
  return '<div class="row"><div style="flex:1"><b>Kid mode</b><div class="hint">Player 2 takes less damage: 1/2, 1/4, 1/5 or 1/10 of every hit. Player 1 is not changed. Either window can set it, and it changes the raid at once.</div></div>'+
    '<button id="set_kid" style="padding:6px 12px;min-width:92px'+(v<1?';color:var(--amber)':'')+'">'+lbl+'</button></div>';
}"""),
], "KID MODE. His order: player 2 incoming damage can be cut to 1/2, 1/4, 1/5 or 1/10 to make the game easier for player 2. A Kid mode row in Settings on either window; the host choice reaches player 2 live with the world word, and player 2 takes the lower of the two. Player 1 is never changed. Check 16.44 fails on v16.43",
"# KID MODE (his order: player 2 takes 1/2, 1/4, 1/5 or 1/10 of the damage).\n")
fixture(1644, r"""  {v:'16.44',what:'kid mode: player 2 takes the chosen fraction of every hit, the lower of its own and the host setting; player 1 is never changed',
   run:function(){
     if(typeof netKidMul!=='function'||typeof kidCycle!=='function'||typeof kidRowHtml!=='function') return 'this build has no kid mode';
     var keep={k:P.kidDmg,h:NET.kidHost}, bad=[], seen=[], i;
     try{
       P.kidDmg=1; NET.kidHost=undefined;
       for(i=0;i<5;i++) seen.push(kidCycle());
       if(seen.join(',')!=='0.5,0.25,0.2,0.1,1') bad.push('the row cycles '+seen.join(','));
       P.kidDmg=0.25; NET.kidHost=0.5; if(netKidMul()!==0.25) bad.push('own 1/4 against host 1/2 gives '+netKidMul());
       P.kidDmg=1; NET.kidHost=0.1; if(netKidMul()!==0.1) bad.push('host 1/10 does not reach player 2 ('+netKidMul()+')');
       if(kidRowHtml().indexOf('Kid mode')<0) bad.push('no Kid mode row');
     } finally { P.kidDmg=keep.k; NET.kidHost=keep.h; }
     var src='';
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&isFinite(amt)) amt*=netKidMul();")<0) bad.push('damage to player 2 is not scaled');
     return bad.length?bad.join('; '):null; }},
""")
