import os, gen
from gen import patch, fixture
patch(1640, [
('''  <div class="manifest" id="oc_manifest"></div>''',
'''  <div class="manifest" id="oc_manifest"></div>
  <div class="manifest" id="oc_party" style="display:none;margin-top:12px"></div>'''),
("""  document.getElementById('outcome').classList.add('on');""",
"""  if(NET.on&&!G.sim){ try{ netSumSend(how,(how==='extract')?haul:0); }catch(_ns){} }   // v16.40: the party summary
  document.getElementById('outcome').classList.add('on');"""),
("""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp;""",
"""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp; NET.sum={};"""),
("""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp;""",
"""  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp; NET.sum={};"""),
("""  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit""",
"""  if(m.t==='kitask'||m.t==='kitok') return netKitTake(peer,m);   // v16.37: every player chooses a kit
  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary"""),
("""var NET_KIT_WAIT=15;""",
"""var NET_KIT_WAIT=15;
// v16.40, HIS PICK (co-op list item 6): AN END OF RAID PARTY SUMMARY. Each window, as its raid ends, tells the party how it ended,
// its kills and what it brought out (nothing on a death or an abandon, which come back empty). The run card lists every player:
// EXTRACTED, KILLED, ABANDONED or STILL UP TOP, with kills and haul, and fills in as the others finish.
function netSumTake(peer,m){
  var s, e, i;
  if(!peer||peer.state!=='in') return 'ignored';
  if(NET.role==='host') s=peer.seat;
  else if(NET.role==='join'){ s=(m.s===undefined)?0:m.s; if(typeof s!=='number'||s!==(s|0)) return 'bad'; }
  else return 'off';
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  e={how:netClean(m.how,12),k:Math.max(0,m.k|0),v:Math.max(0,Math.round(+m.v||0))};
  if(!NET.sum) NET.sum={};
  NET.sum[s]=e;
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'sum',s:s,how:e.how,k:e.k,v:e.v});
  netSumDraw();
  return 'sum';
}
function netSumSend(how,v){
  var k=0, q, K=(G&&G.tel&&G.tel.kills)||null, e;
  if(!NET.on) return false;
  if(K) for(q in K) if(Object.prototype.hasOwnProperty.call(K,q)) k+=(K[q]|0);
  e={how:netClean(how,12),k:k,v:Math.max(0,Math.round(v||0))};
  if(!NET.sum) NET.sum={};
  NET.sum[NET.seat]=e;
  netBroadcast({t:'sum',how:e.how,k:e.k,v:e.v});
  netSumDraw();
  return true;
}
function netSumDraw(){
  var el=document.getElementById('oc_party'), r=NET.roster||[], h='', i, e, st, c;
  if(!el) return false;
  if(!NET.on||r.length<2||!NET.sum){ el.style.display='none'; el.innerHTML=''; return false; }
  h='<div style="font-size:10.5px;color:var(--ash);letter-spacing:.2em;margin-bottom:4px">YOUR PARTY</div>';
  for(i=0;i<r.length;i++){
    e=NET.sum[r[i].seat];
    if(!e){ st='STILL UP TOP'; c='var(--amber)'; }
    else if(e.how==='extract'){ st='EXTRACTED'; c='var(--bone)'; }
    else if(e.how==='dead'){ st='KILLED'; c='var(--rust)'; }
    else { st='ABANDONED'; c='var(--ash)'; }
    h+='<div style="display:flex;gap:14px;justify-content:center;font-size:13px">'+
       '<span style="width:150px;text-align:right">'+escHtml(r[i].seat===NET.seat?'YOU':r[i].name)+'</span>'+
       '<span style="width:110px;color:'+c+'">'+st+'</span>'+
       '<span style="width:80px">'+(e?(e.k+(e.k===1?' kill':' kills')):'')+'</span>'+
       '<span style="width:90px;text-align:right">'+(e?(e.v.toLocaleString()+'c'):'')+'</span></div>';
  }
  el.innerHTML=h; el.style.display='';
  return true;
}"""),
], "END OF RAID PARTY SUMMARY. His pick from the co-op list (item 6). Each window, as its raid ends, tells the party how it ended, its kills and what it brought out (nothing on a death or an abandon). The run card lists every player as EXTRACTED, KILLED, ABANDONED or STILL UP TOP with kills and haul, and fills in as the others finish. Check 16.40 fails on v16.39",
"# END OF RAID PARTY SUMMARY (his pick, co-op list item 6).\n")
fixture(1640, r"""  {v:'16.40',what:'end of raid party summary: each result reaches the party, and the run card lists every player with how it ended, kills and haul',
   run:function(){
     if(typeof netSumTake!=='function'||typeof netSumDraw!=='function'||!document.getElementById('oc_party')) return 'this build has no party summary';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,roster:NET.roster,sum:NET.sum,peers:NET.peers}, el=document.getElementById('oc_party'), bad=[], t, r;
     try{
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[]; NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'}]; NET.sum={};
       NET.sum[1]={how:'dead',k:0,v:0};
       r=netSumTake({state:'in'},{t:'sum',how:'extract',k:3,v:1240});
       t=String(el.textContent);
       if(r!=='sum') bad.push('the host result was not taken ('+r+')');
       if(t.indexOf('YOUR PARTY')<0||t.indexOf('KITE')<0||t.indexOf('EXTRACTED')<0||t.indexOf('3 kills')<0||t.indexOf('1,240c')<0) bad.push('the card does not show the host out with 3 kills and 1,240c: '+t);
       if(t.indexOf('YOU')<0||t.indexOf('KILLED')<0) bad.push('the card does not show this player killed: '+t);
       NET.sum={}; netSumDraw(); t=String(el.textContent);
       if(t.indexOf('STILL UP TOP')<0) bad.push('a player with no result is not shown still up top: '+t);
       NET.on=false; netSumDraw();
       if(el.style.display!=='none') bad.push('the summary shows outside a party');
     } finally { NET.on=keep.on; NET.role=keep.role; NET.seat=keep.seat; NET.roster=keep.roster; NET.sum=keep.sum; NET.peers=keep.peers; el.style.display='none'; el.innerHTML=''; }
     return bad.length?bad.join('; '):null; }},
""")
