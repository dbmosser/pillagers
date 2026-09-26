$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")   # every anchor sits among LF lines; this script may be saved with CRLF
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# LOOT PER PLAYER, AND THE HOST LEAVING ENDS THE RUN FOR EVERYONE. Multiplayer, phase 3, build 1 (tools/multiplayer/plan.md
# phase 3 with the corrections in critique.md), his order of 2026-09-25 and his rulings: the host dropping mid raid COUNTS AS
# ABANDON for everyone; coming back empty on death or abandon stays per player; numbers frozen; no team damage.
# 1. VER 15.90 to 15.91.
# 2. Every container is numbered at the build (netContInit, from netUpAnnounce on the host and netUpStart on a linked window);
#    the host owns container state.
# 3. On a linked window a held E on a numbered box goes through netSrchHold: a reliable {t:'srch',op:'start'} to the host,
#    the bar drawn here once granted, nothing granted from this window own list. On the host a box one of the party holds is
#    refused to the host player (netSrchShared).
# 4. The host (netSrchTake) grants a request if nobody else holds the box (one searcher per box), refuses it as held, open or
#    far; every frame (netSrchTick) it runs each held search on the searcher slow factor with the staged pulls the play path
#    makes and sends each item to that seat as {t:'loot',cid,items}, the rest with done:1 when the bar fills; the box is then
#    open for everyone ({t:'cont',cid,st:'open',by}). Ten times a second (netContTick) it tells the party about a box that
#    arrived ({t:'cont',st:'new'}), opened or shut (a restock). A window that comes up late is told the whole state.
# 5. On a linked window a loot word puts the items in its own backpack through openContainer(ct,keys), the same grant the
#    staged pull makes (netLootTake); a cont word marks the box held, free, open or shut, or makes one the host made
#    (netContWord), so a local E search never starts on a box that is open or held.
# 6. The host leaving: an out word from seat 0, a bye from the host or a lost host link ends a linked window up top on that
#    seed as ABANDON through its own endRaid, with the host left line on the run card (netHostGone).
# 7. netOnMsg routes srch, loot and cont; NET gains contMap, contN, contN0, srch, holds and srchOwn; netReset and netUpEnd
#    clear them; the test handle gains cont() and stand().
# Solo play is untouched: every new line is behind NET.on, and nothing here draws from the seeded stream (rr, rnd, ri, pick,
# rollTable). The hot ground bonus a host open rolls is not rolled for a search one of the party makes (a seeded draw the net
# code must not make); that is written down in d1591.txt.

SubRx @'
var VER='15.90';
'@ @'
var VER='15.91';
'@

SubRx @'
      if(G.searching!==near){
        G.searching=near;
'@ @'
      if(NET.on&&netSrchShared(near)) netSrchHold(near,dt); else {   // v15.91: on a linked window a shared box is searched through the host, and on the host a box one of the party holds is refused; the block below is the solo path, untouched
      if(G.searching!==near){
        G.searching=near;
'@

SubRx @'
    }
  } else {
    // Cancelled: the container keeps its progress, you just stop working it.
'@ @'
      }   // v15.91: the end of the solo path
    }
  } else {
    // Cancelled: the container keeps its progress, you just stop working it.
'@

SubRx @'
    s.textContent=(isFinite(T.closestExtract)&&T.closestExtract<1e8)
      ?('CLOSEST YOU CAME TO EXTRACTION: '+metres(T.closestExtract)+'M')
      :'RUN TERMINATED';
'@ @'
    s.textContent=G.netLeft?G.netLeft   // v15.91: the host left, so this run ended for the whole party, his ruling
      :((isFinite(T.closestExtract)&&T.closestExtract<1e8)
      ?('CLOSEST YOU CAME TO EXTRACTION: '+metres(T.closestExtract)+'M')
      :'RUN TERMINATED');
'@

SubRx @'
  entMap:{},entGone:{},entN:0,entRot:0,entLast:-1};   // v15.80: every body by number, the bodies lately gone, the snapshot count, where a snapshot too big to send whole picks up, and the last snapshot a linked window applied
'@ @'
  entMap:{},entGone:{},entN:0,entRot:0,entLast:-1,   // v15.80: every body by number, the bodies lately gone, the snapshot count, where a snapshot too big to send whole picks up, and the last snapshot a linked window applied
  contMap:{},contN:0,contN0:0,srch:null,holds:{},srchOwn:-1};   // v15.91: every container by number, how many are numbered and how many the build made, the search this linked window asked for, the searches the host runs by seat, and the host own search as last told
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='srch') return (NET.role==='host')?netSrchTake(peer,m):netSrchAnswer(peer,m);   // v15.91: a search request from one of the party, or the host answer to one
  if(m.t==='loot') return netLootTake(peer,m);   // v15.91: loot from the host list, into this window own backpack
  if(m.t==='cont') return netContWord(peer,m);   // v15.91: a container arrived, is held, is free, opened or shut, from the host
'@

SubRx @'
    if(!NET.err) NET.err=(was==='in')?'The link to the host was lost.':'Could not link up with the host. One of your routers may be blocking a direct link; ask for a new invite code, or try from another network.';
'@ @'
    if(!NET.err) NET.err=(was==='in')?'The link to the host was lost.':'Could not link up with the host. One of your routers may be blocking a direct link; ask for a new invite code, or try from another network.';
    if(was==='in') netHostGone('lost');   // v15.91: a raid up top on the party seed ends as abandon, his ruling; the section resets right after
'@

SubRx @'
      NET.status=peer.name+' left your party.';
'@ @'
      netSrchEndSeat(peer.seat);   // v15.91: a box he was searching is free again
      NET.status=peer.name+' left your party.';
'@

SubRx @'
    if(m.t==='bye'){ NET.err='The host ended the party.'; netReset(true); return 'bye'; }
'@ @'
    if(m.t==='bye'){ NET.err='The host ended the party.'; netHostGone('bye'); netReset(true); return 'bye'; }   // v15.91: the host is gone, so a raid up top on its seed ends as abandon
'@

SubRx @'
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: and no body is numbered
'@ @'
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: and no body is numbered
  NET.contMap={}; NET.contN=0; NET.contN0=0; NET.srch=null; NET.holds={}; NET.srchOwn=-1;   // v15.91: and no container is numbered or held
'@

SubRx @'
  netEntsInit(g);   // v15.80: every body numbered in list order, the numbers a linked window gives the same bodies
'@ @'
  netEntsInit(g);   // v15.80: every body numbered in list order, the numbers a linked window gives the same bodies
  netContInit(g);   // v15.91: every container numbered in list order, the numbers a linked window gives the same containers
'@

SubRx @'
  netEntsInit(G);   // v15.80: the same numbers the host gave the same bodies (the populations match by the fingerprint)
'@ @'
  netEntsInit(G);   // v15.80: the same numbers the host gave the same bodies (the populations match by the fingerprint)
  netContInit(G);   // v15.91: the same numbers the host gave the same containers; the host list is the truth from here on
'@

SubRx @'
  else if(NET.role==='join'){ if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad'; s=m.s; }
'@ @'
  else if(NET.role==='join'){ if(m.s===undefined) s=0; else if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad'; else s=m.s; }   // v15.91: the host own word (netUpEnd) names no seat: it is seat 0. Refused as bad before, so the host leaving never reached a linked window
'@

SubRx @'
  if(st!=='in') NET.up[s]=null;
'@ @'
  if(st!=='in') NET.up[s]=null;
  if(NET.role==='join'&&st==='out'&&s===0) netHostGone('out');   // v15.91: the host raid ended, so this one ends as abandon for the whole party, his ruling
'@

SubRx @'
    out={t:'up',s:s,st:st}; if(m.why!==undefined) out.why=netClean(m.why,24); if(m.how!==undefined) out.how=netClean(m.how,12);
'@ @'
    out={t:'up',s:s,st:st}; if(m.why!==undefined) out.why=netClean(m.why,24); if(m.how!==undefined) out.how=netClean(m.how,12);
    if(st==='in') netContHello(peer); else if(st==='out') netSrchEndSeat(s);   // v15.91: a window that came up is told which boxes are open and held; one whose raid ended lets go of the box it was searching
'@

SubRx @'
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: the bodies of this raid are let go
'@ @'
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: the bodies of this raid are let go
  NET.contMap={}; NET.contN=0; NET.contN0=0; NET.srch=null; NET.holds={}; NET.srchOwn=-1;   // v15.91: and the containers
'@

SubRx @'
  if(G.over||!p||!netInCount()) return 0;
'@ @'
  if(G.over||!p||!netInCount()) return 0;
  if(NET.role==='host') netSrchTick(dt); else if(NET.role==='join') netSrchSync();   // v15.91: the host runs every search one of the party holds; a linked window tells the host when its own hold ended
'@

SubRx @'
  if(NET.role==='host') netEntsTick();   // v15.80: on the same clock, where every body stands, and every body that arrived or left since the last tick
'@ @'
  if(NET.role==='host') netEntsTick();   // v15.80: on the same clock, where every body stands, and every body that arrived or left since the last tick
  if(NET.role==='host') netContTick();   // v15.91: on the same clock, every container that arrived, opened or shut since the last tick
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.91, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 1 OF PHASE 3. LOOT PER PLAYER, AND THE HOST LEAVING ENDS THE RUN FOR
// EVERYONE. Until now each window in a shared raid searched its own copy of every box, so two players could empty one box
// twice and a box searched on one window stayed shut on the other. Now the host owns container state.
//   NUMBERS. Every container gets a number (cid) at the build, in list order, on the host and on each linked window alike
//   (netContInit; the lists match by the fingerprint). A box the host makes later (a pillager body, a wreck, the seal payout,
//   a pile the host dropped) is numbered on the next tick and told to the party with what the drawing needs
//   ({t:'cont',st:'new'}: kind, place, tag, cache, strongbox, camp, time, district, dropped, open, how many items). A box a
//   linked window makes on its own (its own dropped pile) has no number and is searched as before, on that window alone.
//   A SEARCH FROM ONE OF THE PARTY. On a linked window a held E on a numbered box (netSrchHold) sends the host a reliable
//   {t:'srch',op:'start',cid,slow} once and draws the bar from where the host has it once granted; nothing is granted from
//   this window own list, ever. The host (netSrchTake) grants it if nobody else holds the box, and refuses it as held, open,
//   far or none; ONE SEARCHER PER BOX, so two players never double the search speed (numbers frozen). Every frame the host
//   (netSrchTick) runs each held search on the searcher slow factor with the staged pulls the play path makes, worst first,
//   and sends each item to that seat as it comes out ({t:'loot',cid,items}), the rest with done:1 when the bar fills; the box
//   is then open on the host and told open to everyone ({t:'cont',cid,st:'open',by}), with the litter any open leaves. The
//   host own tally, contract progress and hot ground bonus are not touched by a search one of the party makes, and the
//   host own hold on a box one of the party holds is refused with a line. A hold let go (walked off, E released, the
//   backpack full, the raid over) is told to the host on the next frame (netSrchSync, {t:'srch',op:'stop'}) and the box keeps
//   its progress for whoever comes back. A box the host player is searching is told held to the party, and freed after.
//   THE STATE FOR EVERYONE. Ten times a second on the netUpTick clock (netContTick) the host tells the party about a box that
//   arrived, opened (the host own open, a pillager emptying it) or shut again (the restock). A window that comes up late is
//   told every box that arrived since the build and which are open and held ({t:'cont',st:'all'}). On a linked window
//   (netContWord) a held box refuses its E with a line naming who holds it, an open box leaves its reach as any open box
//   does, a shut box comes back, and the KEY mark follows the host list on the host map (a key pulled by one of the party
//   leaves the host list, so the mark goes with it, the v15.55 test).
//   THE LOOT. On a linked window a loot word (netLootTake) goes into its own backpack through openContainer(ct,keys), the
//   same grant the staged pull makes (its own belt, its own gun slots, its own Took line and loot voice); the done word
//   counts the box on its own run and its own contracts, as its own open would.
//   THE HOST LEAVING, HIS RULING. When the host raid ends for any reason (extract, death, abandon) every link is told
//   {t:'up',st:'out'} with no seat named (netUpEnd), which a linked window files under seat 0; a linked window up top on that seed takes that word, a bye from the
//   host or a lost host link through netHostGone: its raid ends as ABANDON through its own endRaid, so it comes back empty
//   on its own save as any abandon does, with the host left line on its run card. A linked window own extraction, death or
//   abandon stays its own and ends nobody else.
// SOLO PLAY IS UNTOUCHED. The one line in the play path tests NET.on first; every call in here is behind NET.on; nothing
// here draws from the seeded stream (rr, rnd, ri, pick, rollTable). The hot ground bonus a host open rolls at open time is
// not rolled for a search one of the party makes, since that is a seeded draw the net code must not make; written down.
var NET_SRCH_REACH=200;
function netContPeer(){ return netEntsPeer(); }
function netContHost(){ return netEntsHost(); }
function netContOf(cid){ return (NET.contMap&&cid>=0&&NET.contMap[cid])||null; }
// Every container numbered at the build, in list order. Returns how many.
function netContInit(g){
  var i, ct;
  NET.contMap={}; NET.contN=0; NET.contN0=0; NET.srch=null; NET.holds={}; NET.srchOwn=-1;
  if(!g||!g.containers) return 0;
  for(i=0;i<g.containers.length;i++){ ct=g.containers[i]; ct.cid=i; ct.netBy=-1; ct.netOpen=ct.opened?1:0; NET.contMap[i]=ct; }
  NET.contN=g.containers.length; NET.contN0=NET.contN;
  return NET.contN;
}
// Whether this box is searched through the host: on a linked window up top on the party seed, any numbered box; on the host,
// a box one of the party holds (refused to the host player).
function netSrchShared(ct){
  if(!NET.on||!ct||typeof ct.cid!=='number') return false;
  if(NET.role==='join') return netContPeer();
  if(NET.role==='host') return netContHost()&&ct.netBy>0;
  return false;
}
// A LINKED WINDOW, in place of the solo search block while E is held on a box: one request to the host, the bar from where
// the host has it once granted, nothing granted here. On the host: the box one of the party holds is refused with a line.
function netSrchHold(near,dt){
  var s, cid=near.cid, q, nm;
  if(NET.role==='host'||(near.netBy>0&&near.netBy!==NET.seat)){
    if(G.searching===near){ G.searching=null; G.searchT=0; }
    if(near.netSaidT===undefined||G.t-near.netSaidT>2.5){ near.netSaidT=G.t; nm=netSeatName(near.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.'); }
    return 'held';
  }
  if(G.searching!==near&&near.netAskT!==undefined&&G.t-near.netAskT<1) return 'wait';   // a request the host turned down is not made again every frame
  s=NET.srch;
  if(G.searching!==near||!s||s.cid!==cid){
    if(s&&s.cid!==cid) netSrchStop();
    G.searching=near; near.netAskT=G.t;
    NET.srch={cid:cid,ok:0};
    q=netPeerOfSeat(0);
    if(q) netSend(q,{t:'srch',op:'start',cid:cid,slow:+(+buzzSlow()).toFixed(3)});
    if(!G.sim&&(near.prog||0)>0) say('Search resumed, '+Math.round(100*near.prog/(near.time||1))+'% done.');
    s=NET.srch;
  }
  if(s.ok) near.prog=Math.min(near.time||1,(near.prog||0)+dt/buzzSlow());
  G.searchT=near.prog||0;
  if(!G.sim) G.handsT=0.25;
  return s.ok?'hold':'asked';
}
function netSrchStop(){
  var s=NET.srch, q;
  if(!s) return false;
  NET.srch=null;
  q=netPeerOfSeat(0);
  if(q) netSend(q,{t:'srch',op:'stop',cid:s.cid});
  return true;
}
// A LINKED WINDOW, every frame: a hold that ended by any road (E let go, walked off, the backpack full, the raid over) is told
// to the host, so the box is free for the others and keeps its progress.
function netSrchSync(){
  var s=NET.srch, ct;
  if(!s) return false;
  ct=netContOf(s.cid);
  if(typeof G==='undefined'||!G||G.over||!G.searching||G.searching!==ct) return netSrchStop();
  return false;
}
// A LINKED WINDOW: the host answer to its request.
function netSrchAnswer(peer,m){
  var s=NET.srch, ct, why, nm;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netContPeer()) return 'down';
  if(!s||s.cid!==(m.cid|0)) return 'stale';
  ct=netContOf(s.cid);
  if(m.ok){ s.ok=1; if(ct&&typeof m.prog==='number'&&isFinite(m.prog)) ct.prog=clamp(m.prog,0,ct.time||1); return 'srch:ok'; }
  NET.srch=null;
  if(ct&&G.searching===ct){ G.searching=null; G.searchT=0; }
  why=netClean(m.why,12);
  if(ct&&why==='held'){ ct.netBy=(typeof m.by==='number')?(m.by|0):-1; ct.netSaidT=G.t; nm=netSeatName(ct.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.'); }
  else if(ct&&why==='open'){ ct.opened=true; ct.loot=[]; ct.prog=0; }
  return 'srch:'+(why||'no');
}
// THE HOST: a search request from one of the party, start or stop. One searcher per box.
function netSrchTake(peer,m){
  var s, cid, ct, r, g, slow;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!netContHost()) return 'down';
  s=peer.seat; cid=m.cid|0; ct=netContOf(cid);
  if(!NET.holds) NET.holds={};
  if(m.op==='stop'){ r=NET.holds[s]; if(r&&r.cid===cid) netSrchEnd(s); return 'srch:stop'; }
  if(m.op!=='start') return 'bad';
  if(!ct){ netSend(peer,{t:'srch',cid:cid,ok:0,why:'none'}); return 'srch:none'; }
  if(ct.opened){ netSend(peer,{t:'srch',cid:cid,ok:0,why:'open'}); return 'srch:open'; }
  if(typeof ct.netBy==='number'&&ct.netBy>=0&&ct.netBy!==s){ netSend(peer,{t:'srch',cid:cid,ok:0,why:'held',by:ct.netBy}); return 'srch:held'; }
  g=NET.up[s];
  if(g&&netUpShown(g)&&dist({x:g.tx,y:g.ty},ct)>NET_SRCH_REACH){ netSend(peer,{t:'srch',cid:cid,ok:0,why:'far'}); return 'srch:far'; }
  slow=+m.slow; if(!isFinite(slow)||slow<1) slow=1; if(slow>2) slow=2;
  if(NET.holds[s]&&NET.holds[s].cid!==cid) netSrchEnd(s);   // one search per seat
  NET.holds[s]={cid:cid,slow:slow}; ct.netBy=s;
  netSend(peer,{t:'srch',cid:cid,ok:1,prog:+(+(ct.prog||0)).toFixed(3),n:(ct.loot?ct.loot.length:0)});
  netBroadcast({t:'cont',cid:cid,st:'held',by:s});
  return 'srch:ok';
}
function netSrchEnd(s){
  var r=NET.holds?NET.holds[s]:null, ct;
  if(!r) return false;
  delete NET.holds[s];
  ct=netContOf(r.cid);
  if(ct&&ct.netBy===s){ ct.netBy=-1; netBroadcast({t:'cont',cid:r.cid,st:'free',by:s}); }
  return true;
}
function netSrchEndSeat(s){ return (NET.role==='host')?netSrchEnd(s):false; }
// THE HOST, every frame: its own search is told held and freed for everyone, and each search one of the party holds runs
// here on his slow factor, with the staged pulls the play path makes, each item sent to his window as it comes out.
function netSrchTick(dt){
  var s, r, ct, q, tot, due, k, items, cid, n=0;
  if(!netContHost()) return 0;
  if(!isFinite(dt)||dt<0) dt=0;
  cid=(G.searching&&typeof G.searching.cid==='number')?G.searching.cid:-1;
  if(cid!==NET.srchOwn){
    if(NET.srchOwn>=0){ ct=netContOf(NET.srchOwn); if(ct&&ct.netBy===0){ ct.netBy=-1; netBroadcast({t:'cont',cid:NET.srchOwn,st:'free',by:0}); } }
    if(cid>=0){ ct=netContOf(cid); if(ct){ if(ct.netBy>0){ G.searching=null; G.searchT=0; cid=-1; } else { ct.netBy=0; netBroadcast({t:'cont',cid:cid,st:'held',by:0}); } } }
    NET.srchOwn=cid;
  }
  if(!NET.holds) return 0;
  for(s in NET.holds){
    if(!Object.prototype.hasOwnProperty.call(NET.holds,s)) continue;
    r=NET.holds[s]; ct=netContOf(r.cid); q=netPeerOfSeat(+s);
    if(!ct||!q||ct.opened||ct.netBy!==(+s)){ netSrchEnd(+s); continue; }
    ct.prog=(ct.prog||0)+dt/r.slow;
    items=[];
    tot=(ct.loot?ct.loot.length:0)+(ct.pulled||0);
    if(tot>0&&ct.loot.length>0){
      due=Math.floor(ct.prog/(ct.time||1)*tot)-(ct.pulled||0);
      while(due>0&&ct.loot.length>0){ k=ct.loot.shift(); ct.pulled=(ct.pulled||0)+1; items.push(k); due--; }
      ct.best=bestRarity(ct.loot);
    }
    ct.noiseAcc=(ct.noiseAcc||0)+dt;
    if(ct.noiseAcc>0.5){ ct.noiseAcc=0; ping(ct.x,ct.y,ct.strong?560:180,false,false,'player','move'); if(ct.strong&&!G.sim) sfx('alarm',ct.x,ct.y); }
    if(ct.prog>=(ct.time||1)){
      items=items.concat(ct.loot); ct.pulled=(ct.pulled||0)+ct.loot.length; ct.loot=[]; ct.best='common';
      netContOpenHost(ct,+s);
      netSend(q,{t:'loot',cid:r.cid,items:items,done:1});
      delete NET.holds[s];
    } else if(items.length) netSend(q,{t:'loot',cid:r.cid,items:items});
    n++;
  }
  return n;
}
// A box one of the party emptied: open on the host, told to everyone, litter on the ground as any open leaves. The host own
// tally, contracts and hot ground bonus are not touched.
function netContOpenHost(ct,by){
  ct.opened=true; ct.prog=0; ct.netBy=-1; ct.netOpen=1; ct.netOpenBy=by;
  netContLitter(ct);
  netBroadcast({t:'cont',cid:ct.cid,st:'open',by:by});
}
function netContLitter(ct){
  var lj, _ja;
  if(G.sim||!G.decals) return;
  for(lj=0;lj<fxi(2,3);lj++){
    _ja=fxn(.25,.4);
    G.decals.push({x:ct.x+fxn(-16,16),y:ct.y+fxn(6,18),c:fxpick(['#8d9199','#6a5a3c','#4a5a6a']),s:fxn(2.2,3.6),a:_ja,a0:_ja,rot:fxn(0,3),junk:1,t:0,life:45});
  }
  if(G.decals.length>420) G.decals.splice(0,G.decals.length-420);
}
// THE HOST: a box that arrived since the last tick is numbered and told to the party.
function netContNumber(){
  var ct, n=0;
  if(!NET.contMap) NET.contMap={};
  while(NET.contN<G.containers.length){
    ct=G.containers[NET.contN]; ct.cid=NET.contN; if(typeof ct.netBy!=='number') ct.netBy=-1; ct.netOpen=ct.opened?1:0;
    NET.contMap[NET.contN]=ct; NET.contN++;
    netBroadcast(netContNewWord(ct)); n++;
  }
  return n;
}
function netContNewWord(ct){
  return {t:'cont',st:'new',cid:ct.cid,x:Math.round(ct.x),y:Math.round(ct.y),ty:netClean(ct.type,12),tag:netClean(ct.tag,24),ca:ct.cache?1:0,sg:ct.strong?1:0,cp:ct.camp?1:0,
          tm:+(+(ct.time||1)).toFixed(2),d:(typeof ct.d==='number')?ct.d:-1,dr:ct.dropped?1:0,op:ct.opened?1:0,n:ct.loot?ct.loot.length:0};
}
// THE HOST, about ten times a second: every box that arrived, opened or shut since the last tick. Returns how many words.
function netContTick(){
  var i, ct, op, n=0;
  if(!netContHost()) return 0;
  n+=netContNumber();
  for(i=0;i<G.containers.length;i++){
    ct=G.containers[i]; op=ct.opened?1:0;
    if((ct.netOpen|0)!==op){
      ct.netOpen=op;
      netBroadcast({t:'cont',cid:ct.cid,st:op?'open':'shut',by:(op&&typeof ct.netOpenBy==='number')?ct.netOpenBy:0});
      if(!op) ct.netOpenBy=undefined;
      n++;
    }
  }
  return n;
}
// THE HOST: a window that came up is told every box that arrived since the build, and which are open and which are held.
function netContHello(peer){
  var i, ct, open=[], held=[];
  if(!netContHost()||!peer||peer.state!=='in') return false;
  netContNumber();
  for(i=NET.contN0;i<NET.contN;i++){ ct=NET.contMap[i]; if(ct) netSend(peer,netContNewWord(ct)); }
  for(i=0;i<NET.contN;i++){ ct=NET.contMap[i]; if(!ct) continue; if(ct.opened) open.push(i); if(typeof ct.netBy==='number'&&ct.netBy>=0) held.push([i,ct.netBy]); }
  netSend(peer,{t:'cont',st:'all',open:open,held:held});
  return true;
}
// A LINKED WINDOW: loot from the host list, into this window own backpack through the same grant the staged pull makes; the
// done word closes the box and counts it on this run, as this window own open would.
function netLootTake(peer,m){
  var i, ct, at, items=[], k, where, lv, T;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netContPeer()||!G.player) return 'down';
  ct=netContOf(m.cid|0);
  if(m.items&&typeof m.items.length==='number') for(i=0;i<m.items.length&&i<40;i++){ k=netClean(m.items[i],32); if(k&&Object.prototype.hasOwnProperty.call(ITEMS,k)&&ITEMS[k]) items.push(k); }
  if(!items.length&&!m.done) return 'bad';
  at=ct||{x:G.player.x,y:G.player.y};
  if(items.length){
    where=openContainer(at,items);
    if(!G.sim){
      say('Took '+items.map(function(q){ return ITEMS[q].name; }).join(', ')+'.');
      if(where) sayWhenFree(where);
      lv=lootVoice(items); if(lv!=='pick') blip(lv);
    }
  }
  if(m.done){
    T=G.tel;
    if(ct&&!ct.netCounted){
      ct.netCounted=1;
      if(T){ T.containers++; if(T.firstLoot===null) T.firstLoot=G.t; if(ct.cache) T.cachesOpened=(T.cachesOpened||0)+1; if(ct.strong) T.strongbox=(T.strongbox||0)+1; }
      try{ contractOpen(ct); }catch(_co){}
    }
    if(ct) netContOpen(ct,NET.seat);
    if(NET.srch&&NET.srch.cid===(m.cid|0)) NET.srch=null;
    if(ct&&G.searching===ct){ G.searching=null; G.searchT=0; }
    if(!G.sim&&!items.length) blip('pick');
  }
  return items.length?'loot':'loot:done';
}
// A LINKED WINDOW: a box arrived, is held, is free, opened or shut, from the host; or the whole state for a window that came up.
function netContWord(peer,m){
  var st, cid, by, ct, i, q;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netContPeer()) return 'down';
  st=netClean(m.st,8); cid=m.cid|0; by=(typeof m.by==='number')?(m.by|0):-1;
  if(!NET.contMap) NET.contMap={};
  if(st==='new'){
    if(NET.contMap[cid]) return 'cont:known';
    ct=netContMake(cid,m); if(!ct) return 'bad';
    G.containers.push(ct); NET.contMap[cid]=ct; if(cid>=NET.contN) NET.contN=cid+1;
    return 'cont:new';
  }
  if(st==='all'){
    if(m.open&&typeof m.open.length==='number') for(i=0;i<m.open.length;i++){ ct=netContOf(m.open[i]|0); if(ct&&!ct.opened) netContOpen(ct,-1); }
    if(m.held&&typeof m.held.length==='number') for(i=0;i<m.held.length;i++){ q=m.held[i]; if(q&&typeof q.length==='number'){ ct=netContOf(q[0]|0); if(ct) ct.netBy=q[1]|0; } }
    return 'cont:all';
  }
  ct=netContOf(cid); if(!ct) return 'cont:unknown';
  if(st==='held'){ ct.netBy=by; if(by!==NET.seat&&G.searching===ct){ G.searching=null; G.searchT=0; netSrchStop(); } return 'cont:held'; }
  if(st==='free'){ if(by<0||ct.netBy===by) ct.netBy=-1; return 'cont:free'; }
  if(st==='open'){ netContOpen(ct,by); return 'cont:open'; }
  if(st==='shut'){
    ct.opened=false; ct.openedAt=null; ct.prog=0; ct.pulled=0; ct.loot=[]; ct.best='common'; ct.netBy=-1; ct.netCounted=0; ct.netLit=0;
    if(!G.sim&&G.player&&dist(ct,G.player)<700) say('Something restocked nearby.');
    return 'cont:shut';
  }
  return 'bad';
}
function netContOpen(ct,by){
  ct.opened=true; ct.loot=[]; ct.prog=0; ct.netBy=-1;
  if(!ct.netLit){ ct.netLit=1; netContLitter(ct); }
  if(NET.srch&&NET.srch.cid===ct.cid) NET.srch=null;
  if(G.searching===ct){ G.searching=null; G.searchT=0; }
}
// A box the host made, with what the drawing and the reach need; its loot is the host list, never rolled here.
function netContMake(cid,m){
  var ty=netClean(m.ty,12), x=+m.x, y=+m.y, tm=+m.tm, ct;
  if(!(/^[a-z]+$/).test(ty)||!isFinite(x)||!isFinite(y)) return null;
  ct={cid:cid,net:1,x:clamp(x,-9000,NET_UP_MAX),y:clamp(y,-9000,NET_UP_MAX),r:15,type:ty,d:(typeof m.d==='number'&&m.d>=0)?(m.d|0):-1,loot:[],opened:!!m.op,
      time:(isFinite(tm)&&tm>0)?clamp(tm,0.2,20):1,best:'common',rot:0,pulled:0,prog:0,netBy:-1};
  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
  if(typeof m.tag==='string'&&m.tag) ct.tag=netClean(m.tag,24);
  return ct;
}
// THE HOST LEFT, on a linked window up top on the party seed: its raid ends as ABANDON through its own endRaid, his ruling of
// 2026-09-25 (the host dropping mid raid counts as abandon for everyone; coming back empty stays per player). A window whose
// own raid is over already, or that is not up top on that seed, is left alone.
function netHostGone(why){
  if(typeof G==='undefined'||!G||G.sim||G.over) return false;
  if(!netContPeer()) return false;
  G.netLeft=(why==='out')?'YOUR HOST LEFT THE SURFACE. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.'
                         :'THE LINK TO YOUR HOST WAS LOST. THE RUN ENDS AS ABANDONED FOR THE WHOLE PARTY.';
  NET.status=(why==='out')?'Your host left the surface. The run counts as abandoned for the whole party.'
                          :'The link to your host was lost. The run counts as abandoned for the whole party.';
  try{ endRaid('abandon'); }catch(_eg){}
  return true;
}
// The containers as this window holds them, for the test page handle.
function netContView(){
  var out=[], i, ct, n=0, op=0, held=[], s, up=!!(typeof G!=='undefined'&&G);
  if(up&&G.containers) for(i=0;i<G.containers.length;i++){
    ct=G.containers[i];
    if(typeof ct.cid==='number') n++; if(ct.opened) op++;
    if(typeof ct.netBy==='number'&&ct.netBy>=0) held.push([ct.cid,ct.netBy]);
    out.push({cid:(typeof ct.cid==='number')?ct.cid:-1,x:ct.x,y:ct.y,ty:ct.type,op:ct.opened?1:0,by:(typeof ct.netBy==='number')?ct.netBy:-1,prog:+(+(ct.prog||0)).toFixed(2),tm:+(ct.time||1),n:ct.loot?ct.loot.length:0});
  }
  s=NET.srch?{cid:NET.srch.cid,ok:NET.srch.ok}:null;
  return {peer:netContPeer(),host:netContHost(),n:out.length,numbered:n,opened:op,held:held,srch:s,own:NET.srchOwn,holds:NET.holds?JSON.parse(JSON.stringify(NET.holds)):null,
          bag:(up&&G.bag)?G.bag.slice():[],left:(up&&G.netLeft)||'',list:out};
}
// THE PARTY WINDOW.
'@

SubRx @'
      ents:function(){ return netEntsView(); }};
'@ @'
      ents:function(){ return netEntsView(); },
      // v15.91: the containers as this window holds them (numbered, open, held, the search it asked for, its own backpack), and a
      // test only stand, so the live test can put this player beside a box before it holds E for real.
      cont:function(){ return netContView(); },
      stand:function(x,y){ if(typeof G==='undefined'||!G||!G.player) return false; G.player.x=+x; G.player.y=+y; return true; }};
'@

SubRx @'
function startRaid(){
  G=buildRaid(false);
'@ @'
function startRaid(){
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
  G=buildRaid(false);
'@

SubRx @'
function ascendNow(){
  commitKit();
'@ @'
function ascendNow(){
  if(netGuestHeld()) return false;   // v15.91: before the kit is committed or a window shut, so a guest held at the lift loses nothing
  commitKit();
'@

SubRx @'
           KeyR:['quick ascent',function(){ liftResetDay(); commitKit(); ac(); startRaid(); }],   // v12.61: day by default here too, which is his answer 24
'@ @'
           KeyR:['quick ascent',function(){ if(netGuestHeld()) return; liftResetDay(); commitKit(); ac(); startRaid(); }],   // v12.61: day by default here too, which is his answer 24; v15.91: a party guest is held
'@

SubRx @'
function netUpBusy(){
'@ @'
// v15.91, HIS PLAYTEST: THE TWO OF THEM WENT UP INTO DIFFERENT RAIDS. A linked window could take the lift on its own: ascendNow,
// the quick ascent and startRaid had no party test, so a guest who walked to the lift beside the host built its own raid on its
// own seed, and the host word that came after found it up top already (netUpBusy) and was turned away. Two players, two
// surfaces, and neither could see the other. In a party the host takes everyone up: a guest linked to a host is held at the
// lift with a line that says so, before its kit is committed or a window shut, and goes up when the host word comes
// (netUpStart sets NET.upHold, which this lets through). A guest whose link is gone is not in a party and ascends alone as ever.
function netGuestHeld(){
  if(typeof NET!=='object'||!NET||!NET.on||NET.role!=='join'||NET.upHold||!netInCount()) return false;
  netSay('Your host takes the party up. Stay here and you go up together.');
  return true;
}
function netUpBusy(){
'@

$pat = "(?m)^  now:'v15\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.91: LOOT PER PLAYER, AND THE HOST LEAVING ENDS THE RUN FOR EVERYONE. Multiplayer phase 3 build 1. Every container is numbered at the build on every window alike and the host owns container state. On a linked window a held E on a box is a request to the host, which grants it if nobody else is searching that box (one searcher per box, so two players never double the search speed), runs the search timer itself with the staged pulls the play path makes and sends each item to the searcher window as it comes out, where it goes into that window own backpack through the same grant; the host marks the box open and tells everyone, so both windows draw it searched and neither searches it again; a box the host opened before a window came up is told open to it, a restocked box is told shut, a box the host made mid raid is told new, and the KEY mark follows the host list. The host raid ending for any reason, a bye from the host or a lost host link ends every linked window up top on that seed as ABANDON through its own endRaid, with the host left line on the run card, his ruling; a linked window own extraction, death or abandon stays its own. And from his playtest: a guest linked to a host is held at the lift (Your host takes the party up), so the two of them can no longer go up into different raids. Solo play untouched: every call is behind NET.on and nothing here draws from the seeded stream. Check 15.91 fails on v15.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
