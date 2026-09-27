import os, gen
from gen import patch, fixture
patch(1637, [
("""function askKit(){""",
"""function askKit(then,mate){   // v16.37: then, what an answer leads to; mate, a teammate asked for the party (no sector page to put back)
  then=then||function(){ netKitGate(ascendNow); };"""),
("""  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); ascendNow(); };   // v12.16: MY LOADOUT gets his packing back too""",
"""  ASKYES=function(){ if(P.freeKit) freeKitRestore(); P.freeKit=0; saveProfile(); then(); };   // v12.16: MY LOADOUT gets his packing back too"""),
("""    try{ renderStage(); }catch(_e){}
    ascendNow();""",
"""    try{ renderStage(); }catch(_e){}
    then();"""),
("""  ASKBACK='sectormodal';""",
"""  ASKBACK=mate?null:'sectormodal';"""),
("""  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host""",
"""  if(m.t==='contact') return netContactTake(peer,m);   // v16.36: an enemy went for this seat first, from the host
  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit"""),
("""function netKillTake(peer,m){""",
"""// v16.37, HIS NOTE: the player who is not starting the raid gets the freebie kit or main kit choice, just like always. THE HOST,
// answering MY LOADOUT or FREEBIE KIT with the party linked, asks each teammate the same question and ascends once every one has
// answered, or after NET_KIT_WAIT seconds with the kit each had chosen before. A TEAMMATE sees the same card on its own save;
// its answer sets its own kit and tells the host. A teammate already up top or on the title answers at once.
var NET_KIT_WAIT=15;
function netKitGate(f){
  var i, q, n=0;
  if(typeof NET!=='object'||!NET||!NET.on||NET.role!=='host') return f();
  if(NET.kitWait){ clearTimeout(NET.kitWait.tm); NET.kitWait=null; }
  for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q.state==='in'&&netSend(q,{t:'kitask'})) n++; }
  if(!n) return f();
  NET.kitWait={f:f,need:n,got:0,tm:setTimeout(netKitGo,NET_KIT_WAIT*1000)};
  NET.status='Waiting for your party to choose a kit.'; netRefresh();
  return 'wait';
}
function netKitGo(){
  var w=NET.kitWait;
  if(!w) return false;
  NET.kitWait=null; clearTimeout(w.tm); NET.status=''; netRefresh();
  w.f();
  return true;
}
function netKitTake(peer,m){
  if(!peer||peer.state!=='in') return 'ignored';
  if(m.t==='kitask'){
    if(NET.role!=='join') return 'ignored';
    if(netUpBusy()){ netSend(peer,{t:'kitok'}); return 'kit:busy'; }
    askKit(function(){ netSend(peer,{t:'kitok'}); },true);
    return 'kit:ask';
  }
  if(NET.role!=='host'||!NET.kitWait) return 'ignored';
  NET.kitWait.got++;
  if(NET.kitWait.got>=NET.kitWait.need) netKitGo();
  return 'kit:ok';
}
function netKillTake(peer,m){"""),
], "EVERY PLAYER CHOOSES A KIT. His note: the player who is not starting the raid should get the freebie kit or main kit choice just like always. The host answering MY LOADOUT or FREEBIE KIT now asks each teammate the same question on its own window and save, and the party ascends once every teammate has answered (or after 15 seconds with the kit each had before). Check 16.37 fails on v16.36",
"# EVERY PLAYER CHOOSES A KIT (his note: player 2 gets freebie kit or main kit, just like always).\n")
fixture(1637, r"""  {v:'16.37',what:'every player chooses a kit: the host waits for each teammate, a teammate is shown MY LOADOUT and FREEBIE KIT, and its answer tells the host',
   run:function(){
     if(typeof netKitGate!=='function'||typeof netKitTake!=='function'||typeof askKit!=='function') return 'this build never asks a teammate for a kit';
     var keep={on:NET.on,role:NET.role,peers:NET.peers,status:NET.status}, oSend=netSend, oRef=netRefresh, sent=[], went=0, r, bad=[], mod=document.getElementById('askmodal');
     try{
       netSend=function(q,m){ sent.push(m.t); return true; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.peers=[{state:'in',seat:1}];
       r=netKitGate(function(){ went++; });
       if(r!=='wait'||went) bad.push('the host went up without waiting for its teammate ('+r+', '+went+')');
       if(sent.indexOf('kitask')<0) bad.push('the host did not ask its teammate');
       netKitTake({state:'in'},{t:'kitok'});
       if(went!==1) bad.push('the teammate answer did not send the party up');
       NET.role='join'; sent=[];
       r=netKitTake({state:'in'},{t:'kitask'});
       if(r==='kit:ask'){
         if(!mod||!mod.classList.contains('on')) bad.push('the teammate was not shown the kit card');
         var y=document.getElementById('askyes'), a=document.getElementById('askalt');
         if(!y||y.textContent!=='MY LOADOUT'||!a||a.textContent!=='FREEBIE KIT'||a.style.display==='none') bad.push('the teammate card does not offer MY LOADOUT and FREEBIE KIT');
         if(ASKBACK) bad.push('the teammate card puts back a sector page it never showed');
         if(typeof ASKYES==='function') ASKYES();
         if(sent.indexOf('kitok')<0) bad.push('the teammate answer did not tell the host');
       } else if(r!=='kit:busy') bad.push('a teammate asked for its kit answered '+r);
     } finally {
       netSend=oSend; netRefresh=oRef; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.status=keep.status; NET.kitWait=null;
       if(mod) mod.classList.remove('on'); ASKYES=null; ASKALT=null; ASKBACK=null;
     }
     return bad.length?bad.join('; '):null; }},
""")
