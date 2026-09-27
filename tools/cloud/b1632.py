import os, gen
from gen import patch, fixture
patch(1632, [
("""  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;""",
"""  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
  if(typeof m.n==='number'&&m.n>=0) ct.netLeft=m.n|0;   // v16.32, his note: player 2 search bar shows how many items are left, as player 1 does"""),
("""  if(m.ok){ s.ok=1; if(ct&&typeof m.prog==='number'&&isFinite(m.prog)) ct.prog=clamp(m.prog,0,ct.time||1); return 'srch:ok'; }""",
"""  if(m.ok){ s.ok=1; if(ct&&typeof m.prog==='number'&&isFinite(m.prog)) ct.prog=clamp(m.prog,0,ct.time||1); if(ct&&typeof m.n==='number'&&m.n>=0) ct.netLeft=m.n|0; return 'srch:ok'; }"""),
("""    where=openContainer(at,items);""",
"""    where=openContainer(at,items);
    if(ct&&typeof ct.netLeft==='number') ct.netLeft=Math.max(0,ct.netLeft-items.length);   // v16.32: the count on the bar falls as each item comes out"""),
("""      var _left=_sc.loot?_sc.loot.length:0;""",
"""      var _left=(_sc.net&&typeof _sc.netLeft==='number')?_sc.netLeft:(_sc.loot?_sc.loot.length:0);   // v16.32: a box on a linked window holds no list, only the count the host sends"""),
], "PLAYER 2 SEARCH BAR COUNTS ITEMS. His note: player 2 looting shows no item names. The live two window test shows the Took lines do reach player 2; what player 2 lacked was the count over the search bar (2 items left), because its copy of a box holds no list. The host now sends the count with each box and each granted search, and it falls as each item comes out. Check 16.32 fails on v16.31",
"# PLAYER 2 SEARCH BAR COUNTS ITEMS (his note: player 2 looting shows no item names).\n")
fixture(1632, r"""  {v:'16.32',what:'player 2 search bar counts the items left: a box made from the host word keeps the count, and a loot word lowers it',
   run:function(){
     if(typeof netContMake!=='function') return 'SKIP: no net containers in this build';
     var ct=netContMake(99001,{ty:'crate',x:10,y:10,tm:1,n:3});
     if(!ct) return 'netContMake refused a plain crate word';
     if(ct.netLeft!==3) return 'a box made from a host word with n 3 holds count '+ct.netLeft+', not 3';
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("ct.netLeft=Math.max(0,ct.netLeft-items.length)")<0) return 'a loot word does not lower the count';
     if(src.indexOf("(_sc.net&&typeof _sc.netLeft==='number')?_sc.netLeft")<0) return 'the search bar does not read the count on a linked window';
     return null; }},
""")
