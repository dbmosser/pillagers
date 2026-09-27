import os, gen
from gen import patch, fixture
KL = "  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); }"
patch(1642, [
(KL, KL + """
  if(how==='dead'&&(e.byPlayer||e.bySeat>0)) netFeedKill(e.byPlayer?0:e.bySeat,e);   // v16.42: the kill feed"""),
("""  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary""",
"""  if(m.t==='sum') return netSumTake(peer,m);   // v16.40: a teammate's raid result, for the party summary
  if(m.t==='kf') return netFeedTake(peer,m);   // v16.42: a line for the kill feed, from the host"""),
("""function netAllPaused(){""",
"""// v16.42, THE CO-OP LIST (item 4): A KILL FEED. THE HOST, when a player kills a body: NAME killed WHAT, shown on the host and sent
// to the party. Each window keeps the last four lines for six seconds, drawn at the right edge. Drawing and words only.
var NET_FEED_T=6;
function netFeedKill(s,e){
  var who=(e.kind==='raider'&&e.name)?netClean(e.name,24):String(e.kind||'').toUpperCase();
  if(e.elite) who='ELITE '+who;
  netBroadcast({t:'kf',s:s,w:who});
  netFeedPush(s,who);
  return who;
}
function netFeedTake(peer,m){
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  netFeedPush(m.s,netClean(m.w,32));
  return 'kf';
}
function netFeedPush(s,who){
  var nm=(s===NET.seat)?'YOU':(netSeatName(s)||'PILLAGER');
  if(!NET.feed) NET.feed=[];
  NET.feed.push({txt:nm+' killed '+who,me:(s===NET.seat),at:Date.now()});
  if(NET.feed.length>4) NET.feed.shift();
  return NET.feed.length;
}
function netFeedDraw(){
  var i, f, now=Date.now(), y=Math.round(H*0.40), x=W-LH(16), n=0, a, tw;
  if(!NET.feed||!NET.feed.length) return 0;
  ctx.font=FS(TYPE.label); ctx.textAlign='right';
  for(i=NET.feed.length-1;i>=0;i--){
    f=NET.feed[i]; a=(now-f.at)/1000;
    if(a>NET_FEED_T){ NET.feed.splice(i,1); continue; }
    ctx.globalAlpha=clamp((NET_FEED_T-a)/1.2,0,1);
    tw=ctx.measureText(f.txt).width;
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-tw-LH(6),y-LH(13),tw+LH(12),LH(18));
    ctx.fillStyle=f.me?'#ffc04a':'#bfe0ff'; ctx.fillText(f.txt,x,y);
    y+=LH(22); n++;
  }
  ctx.globalAlpha=1; ctx.textAlign='left';
  return n;
}
function netAllPaused(){"""),
("""  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own""",
"""  try{ if(NET.on) netTeamHud(by); }catch(_nth){}   // v16.26: your teammates, their health and armour, above your own
  try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed"""),
], "KILL FEED. Co-op list item 4. When a player kills a body the host shows NAME killed WHAT (a pillager by name, a machine by kind, ELITE marked) and sends it to the party; each window shows the last four for six seconds at the right edge, its own kills in amber as YOU. Check 16.42 fails on v16.41",
"# KILL FEED (co-op list item 4).\n")
fixture(1642, r"""  {v:'16.42',what:'kill feed: a party kill becomes a NAME killed WHAT line on every window, its own as YOU',
   run:function(){
     if(typeof netFeedPush!=='function'||typeof netFeedTake!=='function'||typeof netFeedKill!=='function') return 'this build has no kill feed';
     var keep={role:NET.role,seat:NET.seat,roster:NET.roster,feed:NET.feed}, oB=netBroadcast, sent=[], bad=[], r;
     try{
       netBroadcast=function(m){ sent.push(m); return 1; };
       NET.roster=[{seat:0,name:'KITE'},{seat:1,name:'MOSS'}]; NET.feed=[];
       NET.role='host'; NET.seat=0;
       netFeedKill(1,{kind:'crawler',elite:1});
       if(!sent.length||sent[0].t!=='kf'||sent[0].s!==1||sent[0].w!=='ELITE CRAWLER') bad.push('the host sent '+JSON.stringify(sent[0]));
       if(!NET.feed.length||NET.feed[0].txt!=='MOSS killed ELITE CRAWLER') bad.push('the host feed reads '+JSON.stringify(NET.feed[0]));
       NET.role='join'; NET.seat=1; NET.feed=[];
       r=netFeedTake({state:'in'},{t:'kf',s:1,w:'RatioedInChat'});
       if(r!=='kf'||!NET.feed.length||NET.feed[0].txt!=='YOU killed RatioedInChat'||!NET.feed[0].me) bad.push('the teammate feed reads '+JSON.stringify(NET.feed[0])+' ('+r+')');
       for(var i=0;i<6;i++) netFeedPush(0,'SENTRY');
       if(NET.feed.length!==4) bad.push('the feed keeps '+NET.feed.length+' lines, not four');
     } finally { netBroadcast=oB; NET.role=keep.role; NET.seat=keep.seat; NET.roster=keep.roster; NET.feed=keep.feed; }
     return bad.length?bad.join('; '):null; }},
""")
