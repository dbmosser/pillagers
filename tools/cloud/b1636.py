import os, gen
from gen import patch, fixture
patch(1636, [
("""      if(e.state!=='chase'&&T.firstContact===null) T.firstContact=G.t;""",
"""      // v16.36, HIS PRINCIPLE (player 2 equals player 1): first contact is stamped for the player this body went for. A body that
      // went for one of the party tells that seat; before this the host stamped it for itself and player 2 always read none.
      if(e.state!=='chase'){ if(p&&p.net) netContactSend(p.seat); else if(T.firstContact===null) T.firstContact=G.t; }"""),
("""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host""",
"""  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host"""),
("""function netKillTake(peer,m){""",
"""// v16.36: THE HOST tells a seat, once a raid, that an enemy first went for it; THE SEAT stamps its own first contact.
function netContactSend(s){
  var q;
  if(!NET.on||NET.role!=='host'||typeof s!=='number') return false;
  if(!G.netContact) G.netContact={};
  if(G.netContact[s]) return false;
  q=netPeerOfSeat(s); if(!q) return false;
  G.netContact[s]=1;
  return netSend(q,{t:'contact',seat:s});
}
function netContactTake(peer,m){
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof G==='undefined'||!G||G.sim||!G.tel) return 'down';
  if(typeof m.seat==='number'&&m.seat!==NET.seat) return 'ignored';
  if(G.tel.firstContact===null) G.tel.firstContact=G.t;
  return 'contact';
}
function netKillTake(peer,m){"""),
], "PLAYER 2 FIRST CONTACT. His run reports showed player 2 at firstContact none in every co-op raid: first contact was stamped where the host AI picks its target, which never runs on player 2, and it stamped the host even when the enemy went for player 2. The host now tells the seat an enemy went for, once a raid, and that seat stamps its own. The live two window test now also has player 2 shoot a host body for real: hits, damage and the kill credit all reach player 2. Check 16.36 fails on v16.35",
"# PLAYER 2 FIRST CONTACT (his principle: player 2 equals player 1; his run reports showed none).\n")
fixture(1636, r"""  {v:'16.36',what:'player 2 first contact: the host tells the seat an enemy went for, and that seat stamps its own first contact',
   run:function(){
     if(typeof netContactTake!=='function'||typeof netContactSend!=='function') return 'this build never tells a seat its first contact';
     var keepG=G, keepR=NET.role, keepS=NET.seat, r1, r2, fc1, fc2;
     try{
       G={t:42,sim:false,tel:{firstContact:null}}; NET.role='join'; NET.seat=1;
       r1=netContactTake({state:'in'},{t:'contact',seat:1}); fc1=G.tel.firstContact;
       G.t=50; r2=netContactTake({state:'in'},{t:'contact',seat:1}); fc2=G.tel.firstContact;
     } finally { G=keepG; NET.role=keepR; NET.seat=keepS; }
     if(r1!=='contact'||fc1!==42) return 'the seat did not stamp its first contact ('+r1+', '+fc1+')';
     if(fc2!==42) return 'a second word moved the first contact to '+fc2;
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("if(p&&p.net) netContactSend(p.seat); else if(T.firstContact===null) T.firstContact=G.t;")<0) return 'the host still stamps its own first contact when an enemy goes for a teammate';
     return null; }},
""")
