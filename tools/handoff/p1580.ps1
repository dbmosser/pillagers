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

# ONE SET OF ENEMIES, RUN BY THE HOST, SEEN AND FELT BY EVERYONE. Multiplayer, phase 2, build 2 (tools/multiplayer/plan.md
# phase 2 with the corrections in critique.md), his order of 2026-09-25. Until now each window in a shared raid ran its own
# pillagers and machines, so two players saw two different worlds. Now the host runs them and the linked windows watch.
# 1. VER 15.79 to 15.80.
# 2. Every body is numbered at the build (netEntsInit, from netUpAnnounce on the host and netUpStart on a linked window).
# 3. The host, ten times a second (netEntsTick, off the netUpTick clock): a snapshot of every body near any player on the fast
#    channel ({t:'en'}), a reliable word for a body that arrived or left ({t:'ent'}), the kill to the seat that made it ({t:'kill'}).
# 4. A linked window up top: its own updateEnts runs nothing (netEntsEase slides the bodies instead), snapshots and words fill
#    G.ents (netEntsApply, netEntWord), a hit word goes through its own damagePlayer (netHitTake), its rounds, fists and charges
#    on a body send the host a shot request (netShotSend) and change nothing themselves.
# 5. The host: every body picks the NEAREST player (netTargetFor: the host player or one of the party up top) in updateEnts,
#    navSeek, feudEngage and the wave spawn; a blow on one of the party is a reliable hit word (netHitPlayer, netBulletPeer,
#    netAreaHitPeers for a raider charge, a Howler shell and a bolt), never a change to his health here; a shot request lowers
#    the body (netShotTake) and marks the seat for the kill. No team damage: player rounds, fists and charges test G.ents only.
# 6. netOnMsg routes en, ent, hit, shot and kill; NET gains entMap, entN, entRot and entLast; netReset and netUpEnd clear them;
#    the test handle gains ents().
# Solo play is untouched: every new line is behind NET.on or a p.net read that is undefined on the player, and nothing here
# draws from the seeded stream (rr, rnd, ri, pick, rollTable).

SubRx @'
var VER='15.79';
'@ @'
var VER='15.80';
'@

SubRx @'
  if(CFG.lodR>0&&G.player&&!e.merc&&dist(e,G.player)>CFG.lodR){
'@ @'
  if(CFG.lodR>0&&G.player&&!e.merc&&(NET.on?netNearDist(e):dist(e,G.player))>CFG.lodR){   // v15.80: out of earshot of EVERY player, the party up top included
'@

SubRx @'
  if(CFG.engageNear!==0&&dist(e,p)>=CFG.engageNear) return false;
'@ @'
  if(CFG.engageNear!==0&&(NET.on?netNearDist(e):dist(e,p))>=CFG.engageNear) return false;   // v15.80: near any player, the party up top included
'@

SubRx @'
    damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
'@ @'
    damagePlayer(SH.dmg*(1-dp/R)+6,'howler','HOWLER',SH.tx,SH.ty);
  if(NET.on) netAreaHitPeers(SH.tx,SH.ty,R,function(dq){ return SH.dmg*(1-dq/R)+6; },'howler','HOWLER',{roof:_onRoof?_roof:null});   // v15.80: and the party up top, by the same rules, each through his own window
'@

SubRx @'
    damagePlayer(80*(1-dp/R)+18,_fSrc,_fName,f.x,f.y);   // v11.77: was 60 and 12; 98 at the centre, so a full man just lives
'@ @'
    damagePlayer(80*(1-dp/R)+18,_fSrc,_fName,f.x,f.y);   // v11.77: was 60 and 12; 98 at the centre, so a full man just lives
  if(!_fMine&&NET.on) netAreaHitPeers(f.x,f.y,R,function(dq){ return 80*(1-dq/R)+18; },_fSrc,_fName,{down:true});   // v15.80: a pillager charge reaches the party up top by the same rules; your own charge never touches them (no team damage)
'@

SubRx @'
      e.hp-=115*(1-Math.max(0,de-e.r)/R)+25; e.hitT=.2;   // v11.77: was 85 and 15
'@ @'
      var _fdm=115*(1-Math.max(0,de-e.r)/R)+25;   // v11.77: was 85 and 15
      if(_fMine&&NET.on&&netEntsPeer()) netShotSend(e,_fdm,Math.atan2(e.y-f.y,e.x-f.x),null); else e.hp-=_fdm;   // v15.80: on a linked window the host runs this body, so the blow is a request to the host
      e.hitT=.2;
'@

SubRx @'
      if(e.hp<=0) e.byPlayer=!!_fMine;
'@ @'
      if(e.hp<=0){ e.byPlayer=!!_fMine; e.bySeat=0; }   // v15.80: a charge on the host is never one of the party, so the seat mark comes off with the kill
'@

SubRx @'
    ping(S.x,S.y,900,false,false,'env','fire');
'@ @'
    ping(S.x,S.y,900,false,false,'env','fire');
    if(NET.on) netAreaHitPeers(S.x,S.y,STRIKE_R,function(){ return STRIKE_DMG; },'lightning','the storm',{noRoof:true});   // v15.80: the bolt reaches the party up top by the same roof and wall rules; the draws below are untouched
'@

SubRx @'
      if(dist(E,S)<STRIKE_R&&!roofAt(E.x,E.y)&&losClear(S.x,S.y,E.x,E.y,G.map.segs)){ E.hp-=STRIKE_DMG; E.hitT=.16; if(E.hp<=0) E.byPlayer=false; }   // v14.31: the same roof and wall
'@ @'
      if(dist(E,S)<STRIKE_R&&!roofAt(E.x,E.y)&&losClear(S.x,S.y,E.x,E.y,G.map.segs)){ E.hp-=STRIKE_DMG; E.hitT=.16; if(E.hp<=0){ E.byPlayer=false; E.bySeat=0; } }   // v14.31: the same roof and wall. v15.80: and no seat is credited
'@

SubRx @'
        _me.hp-=_mdm; _me.hitT=.16; _me.pHitT=.3;   // v11.37: your strike provokes
'@ @'
        if(NET.on&&netEntsPeer()) netShotSend(_me,_mdm,base,null); else _me.hp-=_mdm;   // v15.80: on a linked window the host runs this body, so the blow is a request to the host
        _me.hitT=.16; _me.pHitT=.3;   // v11.37: your strike provokes
'@

SubRx @'
  if(CFG.raiderWaves===0||!G||G.over||!G.roster) return;
'@ @'
  if(CFG.raiderWaves===0||!G||G.over||!G.roster) return;
  if(NET.on&&netEntsPeer()) return;   // v15.80: a linked window up top spawns nobody; the host does, and the arrival comes as a word
'@

SubRx @'
    var _c=freeSpot(G.map,30), _cd=dist(_c,G.player);
'@ @'
    var _c=freeSpot(G.map,30), _cd=NET.on?netNearDist(_c):dist(_c,G.player);   // v15.80: far from EVERY player, the party up top included; the 24 draws are unchanged
'@

SubRx @'
function updateEnts(dt){
'@ @'
function updateEnts(dt){
  if(NET.on&&netEntsPeer()){ netEntsEase(dt); return; }   // v15.80: a linked window up top runs no pillager or machine of its own: the host does, and this slides each body to where the host put it
'@

SubRx @'
    var e=G.ents[i];
    e.moving=false;
    if(e.hitT>0) e.hitT-=dt;
'@ @'
    var e=G.ents[i];
    if(NET.on) p=netTargetFor(e);   // v15.80: this body picks the NEAREST player, the host player or one of the party up top; with the party off it is the host player as always
    e.moving=false;
    if(e.hitT>0) e.hitT-=dt;
'@

SubRx @'
        if(CFG.listenLive!==0&&!p.downed&&p.moving&&!G.pCrouch){
'@ @'
        if(CFG.listenLive!==0&&!p.downed&&p.moving&&!(p.net?p.cr:G.pCrouch)){   // v15.80: the crouch of whichever player it hunts
'@

SubRx @'
            damagePlayer(e.dmg,'listener',e.name,e.x,e.y); e.cd=0.85;
'@ @'
            netHitPlayer(p,e.dmg,'listener',e.name,e.x,e.y); e.cd=0.85;   // v15.80: the host player through damagePlayer as always; one of the party through a hit word to his window
'@

SubRx @'
              damagePlayer(e.dmg,'listener',e.name,e.x,e.y);
'@ @'
              netHitPlayer(p,e.dmg,'listener',e.name,e.x,e.y);   // v15.80: the host player through damagePlayer as always; one of the party through a hit word to his window
'@

SubRx @'
    var pcon=(G.pConceal===undefined)?1:G.pConceal;
'@ @'
    var pcon=p.net?1:((G.pConceal===undefined)?1:G.pConceal);   // v15.80: one of the party up top has no bush cover here (his window knows it, this one does not)
'@

SubRx @'
    if(sees&&G.pCrouch&&!WDC&&CHID>0&&!onYou&&dist(e,p)>CHID&&(!G.sim||HARDC)) sees=false;
'@ @'
    if(sees&&(p.net?p.cr:G.pCrouch)&&!WDC&&CHID>0&&!onYou&&dist(e,p)>CHID&&(!G.sim||HARDC)) sees=false;   // v15.80: the crouch of whichever player it looks at
'@

SubRx @'
        else if(e.cd<=0&&!p.downed){ damagePlayer(e.dmg*(e.elite?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),'crawler',e.name,e.x,e.y); e.cd=.7; }
'@ @'
        else if(e.cd<=0&&!p.downed){ netHitPlayer(p,e.dmg*(e.elite?(CFG.eliteDmg===undefined?1.6:CFG.eliteDmg):1),'crawler',e.name,e.x,e.y); e.cd=.7; }   // v15.80: the host player through damagePlayer as always; one of the party through a hit word to his window
'@

SubRx @'
            var _rmv=(p.moving?(G.sprinting?0.030:0.018):0);
'@ @'
            var _rmv=(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0);   // v15.80: the sprint of whichever player he aims at
'@

SubRx @'
          var _rgj=Math.max(18,_rgd*_rgk*(0.062+(p.moving?(G.sprinting?0.030:0.018):0)));
'@ @'
          var _rgj=Math.max(18,_rgd*_rgk*(0.062+(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0)));   // v15.80: the sprint of whichever player he aims at
'@

SubRx @'
              en.hp-=edmg; en.hitT=.16;
'@ @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK); else en.hp-=edmg;   // v15.80: on a linked window the host runs this body, so the round is a request to the host with the damage worked out here
              en.hitT=.16;
'@

SubRx @'
          if(!_mOwn&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
'@ @'
          if(!_mOwn&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }
          if(!hit&&!_mOwn&&NET.on&&netBulletPeer(b)){ spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }   // v15.80: an enemy round on one of the party up top is a hit word to his window; a player round never comes down this branch
'@

SubRx @'
              if(en3.hp<=0) en3.byPlayer=false;
'@ @'
              if(en3.hp<=0){ en3.byPlayer=false; en3.bySeat=0; }   // v15.80: an enemy round on the host credits no seat either
'@

SubRx @'
  up:[],upAcc:0,upN:0,upSeed:0,upFp:null,upHold:false,upIss:null};   // v15.79: who stands where up top by seat, the send clock, this raid seed and fingerprint, the party build guard and the loaner word
'@ @'
  up:[],upAcc:0,upN:0,upSeed:0,upFp:null,upHold:false,upIss:null,   // v15.79: who stands where up top by seat, the send clock, this raid seed and fingerprint, the party build guard and the loaner word
  entMap:{},entGone:{},entN:0,entRot:0,entLast:-1};   // v15.80: every body by number, the bodies lately gone, the snapshot count, where a snapshot too big to send whole picks up, and the last snapshot a linked window applied
'@

SubRx @'
  if(m.t==='up') return netUpWord(peer,m);   // v15.79: a window went up, could not, or its raid ended
'@ @'
  if(m.t==='up') return netUpWord(peer,m);   // v15.79: a window went up, could not, or its raid ended
  if(m.t==='en') return netEntsApply(peer,m);   // v15.80: where every body stands, from the host
  if(m.t==='ent') return netEntWord(peer,m);   // v15.80: a body arrived or left, from the host
  if(m.t==='hit') return netHitTake(peer,m);   // v15.80: a blow on this player, from the host, taken through its own damagePlayer
  if(m.t==='shot') return netShotTake(peer,m);   // v15.80: a round, blade or charge from one of the party on a body the host runs
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: and no body is numbered
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp;
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp;
  netEntsInit(g);   // v15.80: every body numbered in list order, the numbers a linked window gives the same bodies
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp;
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp;
  netEntsInit(G);   // v15.80: the same numbers the host gave the same bodies (the populations match by the fingerprint)
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;   // v15.80: the bodies of this raid are let go
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
'@

SubRx @'
  NET.upN++;
'@ @'
  NET.upN++;
  if(NET.role==='host') netEntsTick();   // v15.80: on the same clock, where every body stands, and every body that arrived or left since the last tick
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.80, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 2 OF PHASE 2. ONE SET OF ENEMIES, RUN BY THE HOST, SEEN AND FELT BY
// EVERYONE. Until now each window in a shared raid ran its own pillagers and machines, so two players up top on one seed saw
// two different worlds. Now the host runs them all and the linked windows watch.
//   NUMBERS. Every body gets a number (nid) at the build, in list order, on the host and on each linked window alike: the
//   populations match by the fingerprint, so one number names one body everywhere (netEntsInit). A body that arrives later on
//   the host (a wave, a reinforcement, a siege arrival) is numbered on the next tick and told to the party with what the
//   drawing needs ({t:'ent',op:'new'}: kind, name, coat, crew, identity, gun, rig, health, elite, hostile).
//   THE HOST, ten times a second on the netUpTick clock (netEntsTick): a snapshot on the fast channel of every body within
//   NET_ENT_RANGE of any player, the host player or one of the party up top, as {t:'en',sd,n,e:[[nid,kind,x,y,face,state,
//   health in twentieths,flags],...]} (whole units, two decimals of facing, at most NET_ENT_MAX rows, the rest on the next
//   tick); a body that left the list since the last tick is told to the party at once on the reliable channel
//   ({t:'ent',op:'gone',how:'dead'|'out'}), and a body one of the party killed is credited to that seat ({t:'kill'}).
//   THE NEAREST PLAYER. In updateEnts every body picks its target afresh each frame (netTargetFor): the host player or one of
//   the party up top on this seed, a standing man before a downed one, the nearest of those; a hired man keeps the host. The
//   same reach test feeds navSeek (out of earshot of every player), feudEngage and the wave spawn (far from every player).
//   Where a body reads the crouch, the sprint or the cover of its target, one of the party gives what his window last sent
//   (crouched, sprinting; no bush cover, since only his window knows it).
//   A BLOW ON ONE OF THE PARTY (netHitPlayer, netBulletPeer, netAreaHitPeers): the host never touches his health. His
//   window is told {t:'hit',seat,dmg,kind,name,x,y} on the reliable channel and takes it through its own damagePlayer, so
//   armour, the downed rules and death stay his own. Crawler and Listener blows, enemy rounds, a pillager charge, a Howler
//   shell and a bolt all come here. NO TEAM DAMAGE: player rounds, fists and charges test G.ents only, as they always did,
//   and one of the party is never in G.ents; the host charge and the host rounds never reach the peers branch.
//   A LINKED WINDOW UP TOP (netEntsPeer): its own updateEnts runs nothing; netEntsEase slides each body toward where the
//   host last put it (1 - e^(-12 dt), shortest arc, the walk cycle while the host says it moves, the hit, muzzle, roll,
//   windup and vent timers running down) and takes off any body the host has said nothing about for NET_ENT_STALE seconds,
//   and any body this window made on its own. netEntsApply files each snapshot row on the body by number (a body it has
//   never seen is made with what the drawing needs and filled by the word about it); a gone word takes the body off with
//   the same spark, puff and label the host frame shows; a kill word counts the kill, the contract and the grudge on this
//   window as its own kill would. Its rounds, fists and charges on a body send the host {t:'shot',id,dmg,x,y,a,wk} with the
//   damage worked out here (weak point, shield, armour and the back shot) and change nothing on the body themselves; the
//   host applies it if the body is alive (netShotTake), marks the seat for the kill by the v15.45 rule, turns the man
//   hostile and onto the shooter as a host round would, and rolls him out of the line as v3.94 does. Loot, searching,
//   revives, extraction, the clock, the weather and the bullets themselves stay each window own in this slice.
// SOLO PLAY IS UNTOUCHED. Every call in here is behind NET.on; the target and crouch reads in updateEnts test p.net, which is
// undefined on the player; nothing here draws from the seeded stream (rr, rnd, ri, pick, rollTable): the crier alarm a shot
// request starts winds 3.5 seconds flat where a host round draws it.
var NET_ENT_RANGE=1600, NET_ENT_MAX=200, NET_ENT_STALE=3;
var NET_ENT_KINDS=['sentry','crawler','raider','snitch','listener','bulwark','howler','warden','choir','peddler','stray'];
var NET_ENT_STATES=['patrol','chase','alarm','investigate','loot','extract','hunt','dormant','down','possum'];
var NET_ENT_R={sentry:22,crawler:15,raider:11,snitch:11,listener:14,bulwark:24,howler:20,warden:30,choir:26,peddler:12,stray:11};
// Whether this window watches a raid the host runs (a linked window up top on the host seed), or runs one for the party.
function netEntsPeer(){ return !!(NET.on&&NET.role==='join'&&typeof G!=='undefined'&&G&&!G.sim&&!G.over&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }
function netEntsHost(){ return !!(NET.on&&NET.role==='host'&&typeof G!=='undefined'&&G&&!G.sim&&!G.over&&NET.upSeed&&(G.seed>>>0)===(NET.upSeed>>>0)); }
// Every body numbered at the build, in list order. Returns how many.
function netEntsInit(g){
  var i;
  NET.entMap={}; NET.entGone={}; NET.entN=0; NET.entRot=0; NET.entLast=-1;
  if(!g||!g.ents) return 0;
  g.nidN=1;
  for(i=0;i<g.ents.length;i++){ g.ents[i].nid=g.nidN++; g.ents[i].nIn=1; NET.entMap[g.ents[i].nid]=g.ents[i]; }
  return g.ents.length;
}
// One of the party as a body the AI can read: where his window last said he stood, facing, downed, moving, crouched, sprinting.
function netUpBody(g){
  var b=g.body;
  if(!b){ b={net:1,seat:g.seat,x:0,y:0,r:11,face:0,downed:false,moving:false,cr:0,sp:0,hp:100,maxhp:100,iv:0,roll:0,ads:false,wep:null,pendKiller:null,rig:'none'}; g.body=b; }
  b.seat=g.seat; b.x=g.tx; b.y=g.ty; b.face=g.tf; b.downed=!!g.dn; b.moving=!!g.mv; b.cr=g.cr?1:0; b.sp=g.sp?1:0;
  return b;
}
// The player this body goes for: the host player, or one of the party up top on this seed; a standing man before a downed
// one, the nearest of those. A hired man keeps the host. With nobody up top it is the host player, as it always was.
function netTargetFor(e){
  var best=G.player, bd, i, g, b, d, up;
  if(!NET.on||!best||!e||e.merc||!NET.upSeed) return best;
  bd=dist(e,best); up=!best.downed;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    b=netUpBody(g); d=dist(e,b);
    if((!b.downed&&!up)||(((!b.downed)===up)&&d<bd)){ best=b; bd=d; up=!b.downed; }
  }
  return best;
}
// How far a point is from the nearest player, the party up top included.
function netNearDist(pt){
  var d=G.player?dist(pt,G.player):1e9, i, g, q;
  if(!NET.on||!NET.upSeed) return d;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!netUpShown(g)) continue; q=dist(pt,netUpBody(g)); if(q<d) d=q; }
  return d;
}
function netPeerOfSeat(s){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return NET.peers[i]; return null; }
function netPlayersList(){ var out=[], i, g; if(G&&G.player) out.push(G.player); for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(netUpShown(g)) out.push(netUpBody(g)); } return out; }
// A blow on a player. The host player takes it through damagePlayer as always. One of the party is told on the reliable
// channel and takes it through his own damagePlayer, on his own window: his armour, his downed rules, his death.
function netHitPlayer(p,amt,src,srcName,sx,sy){
  var q, m;
  if(!p||!p.net){ damagePlayer(amt,src,srcName,sx,sy); return 'own'; }
  if(!NET.on||NET.role!=='host') return 'off';
  q=netPeerOfSeat(p.seat);
  if(!q) return 'noseat';
  m={t:'hit',seat:p.seat,dmg:+(+amt).toFixed(2),kind:netClean(src,16),name:netClean(srcName,24)};
  if(typeof sx==='number'&&isFinite(sx)){ m.x=+sx.toFixed(1); m.y=+(+sy).toFixed(1); }
  netSend(q,m);
  return 'sent';
}
// A blast or a bolt: each of the party inside the radius with a clear line takes it, by the rules the host player takes it
// (opt.roof: spared under that roof; opt.noRoof: spared under any roof; opt.down: a downed man takes it too).
function netAreaHitPeers(x,y,R,dmgFn,src,name,opt){
  var i, g, b, d, n=0;
  opt=opt||{};
  if(!NET.on||NET.role!=='host'||!NET.upSeed) return 0;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    b=netUpBody(g);
    if(b.downed&&!opt.down) continue;
    d=dist(b,{x:x,y:y}); if(d>=R) continue;
    if(opt.roof&&underSameRoof(opt.roof,b.x,b.y)) continue;
    if(opt.noRoof&&roofAt(b.x,b.y)) continue;
    if(!losClear(x,y,b.x,b.y,G.map.segs)) continue;
    if(netHitPlayer(b,dmgFn(d),src,name,x,y)==='sent') n++;
  }
  return n;
}
// An enemy round against the party up top: the first one it touches takes it. A player round never comes here.
function netBulletPeer(b){
  var i, g, bd;
  if(!NET.on||NET.role!=='host'||!NET.upSeed||!b||b.player) return false;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)) continue;
    bd=netUpBody(g);
    if(dist(b,bd)<bd.r+3){ netHitPlayer(bd,b.dmg,(b.owner&&b.owner.kind)||'other',(b.owner&&b.owner.name)||'',b.x-b.vx*0.05,b.y-b.vy*0.05); return true; }
  }
  return false;
}
// THE SNAPSHOT ROW. The flags are what the drawing, the nameplates and the pillager board read.
function netEntFlags(e){
  var f=0;
  if(e.downed) f|=1; if(e.finished) f|=2; if(e.alert>0) f|=4; if(e.moving) f|=8; if(e.hostile) f|=16; if(e.friendlyPC) f|=32;
  if(e.hitT>0) f|=64; if(e.muzzle>0) f|=128; if(e.seenYou) f|=256; if(e.windup!==undefined&&e.windup!==null) f|=512; if(e.overheat>0) f|=1024;
  if(e.kind==='raider'&&raiderCrouched(e)) f|=2048; if(e.roll>0) f|=4096; if(e.steady) f|=8192; if(e.reviving) f|=16384; if(e.shotT>0) f|=32768;
  if(e.lootT>0) f|=65536; if((e.healQ||0)>0) f|=131072; if(e.sprintPool>0) f|=262144; if(e.helped) f|=524288; if(e.grudge) f|=1048576;
  if(e.parley>0) f|=2097152; if(e.blind>0) f|=4194304;
  return f;
}
function netEntRow(e){
  var k=NET_ENT_KINDS.indexOf(e.kind), s=NET_ENT_STATES.indexOf(e.state), mh=e.maxhp||1;
  return [e.nid,(k<0)?0:k,Math.round(e.x),Math.round(e.y),+(+e.face||0).toFixed(2),(s<0)?0:s,Math.ceil(clamp(e.hp/mh,0,1)*20),netEntFlags(e)];
}
// A body that arrived after the build: what a linked window needs to draw and name it.
function netEntNewWord(e){
  var m={t:'ent',op:'new',id:e.nid,k:e.kind,x:Math.round(e.x),y:Math.round(e.y),n:netClean(e.name,24),r:e.r,mh:e.maxhp,hp:Math.ceil(clamp(e.hp/(e.maxhp||1),0,1)*20),el:e.elite?1:0,ho:e.hostile?1:0};
  if(e.kind==='raider'){ m.c=netClean(e.coat,12); m.cr=e.crew|0; m.idn=netClean(e.ident,24); m.w=(e.wep&&e.wep.id)?String(e.wep.id):''; m.rg=netClean(e.rig,8); m.mc=e.merc?1:0; }
  return m;
}
// A body left the list: dead or out. A dead body one of the party killed is his kill, told to his seat.
function netEntGone(e){
  var how=(e.hp<=0||e.finished)?'dead':'out', q;
  netBroadcast({t:'ent',op:'gone',id:e.nid,how:how,n:NET.entN});   // n: the snapshot that follows; an older one naming this body is a late packet
  if(how==='dead'&&e.bySeat>0&&!e.byPlayer){ q=netPeerOfSeat(e.bySeat); if(q) netSend(q,{t:'kill',seat:e.bySeat,id:e.nid,k:e.kind,el:e.elite?1:0}); }
  return how;
}
function netEntNear(e,ps){ var i; for(i=0;i<ps.length;i++) if(dist(e,ps[i])<NET_ENT_RANGE) return true; return false; }
// THE HOST, about ten times a second. Numbers and announces any body that arrived since the last tick, tells the party about
// any body that left (with the kill to the seat that made it), and sends where every body within reach of any player stands
// on the fast channel. Returns the snapshot, or null when this window runs no raid for a party.
function netEntsTick(){
  var i, e, seen={}, id, rows=[], cand=[], ps, m, sent=0, n, st;
  if(!netEntsHost()) return null;
  if(!NET.entMap||!G.nidN) netEntsInit(G);
  ps=netPlayersList();
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e.nid){ e.nid=G.nidN++; NET.entMap[e.nid]=e; netBroadcast(netEntNewWord(e)); }
    seen[e.nid]=1;
    if(netEntNear(e,ps)) cand.push(e);
  }
  for(id in NET.entMap) if(Object.prototype.hasOwnProperty.call(NET.entMap,id)&&!seen[id]){ netEntGone(NET.entMap[id]); delete NET.entMap[id]; }
  n=cand.length;
  if(n<=NET_ENT_MAX){ for(i=0;i<n;i++) rows.push(netEntRow(cand[i])); }
  else { st=NET.entRot%n; for(i=0;i<NET_ENT_MAX;i++) rows.push(netEntRow(cand[(st+i)%n])); NET.entRot=(st+NET_ENT_MAX)%n; }
  m={t:'en',sd:NET.upSeed>>>0,n:NET.entN++,e:rows};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&netSendFast(NET.peers[i],m)) sent++;
  return m;
}
// A LINKED WINDOW: a body it has never seen, with what the drawing needs until the word about it arrives.
function netEntMake(id,kind,x,y){
  var e={nid:id,net:1,kind:kind,x:x,y:y,r:NET_ENT_R[kind]||12,hp:100,maxhp:100,name:'',face:0,state:'patrol',tx:x,ty:y,cd:0,alert:0,spd:0,dmg:0,rng:100,cone:.8,
    hitT:0,pHitT:0,muzzle:0,legs:0,step:0,moving:false,downed:0,finished:0,elite:0,hostile:true,coat:'#5a5248',bag:[],skips:[],goal:null,bulk:0,rig:'none',armor:0,
    seenYou:false,windup:null,overheat:0,roll:0,rollCd:0,ntx:x,nty:y,ntf:0,nAge:0,nT:0,nIn:0};
  if(kind==='raider'){ e.wep=WEAPONS.pistol; e.crew=0; }
  return e;
}
function netEntFill(e,m){
  var lk, A;
  if(typeof m.n==='string') e.name=netClean(m.n,24);
  if(typeof m.r==='number'&&m.r>0&&m.r<80) e.r=m.r;
  if(typeof m.mh==='number'&&m.mh>0){ e.maxhp=m.mh; if(typeof m.hp==='number') e.hp=Math.round(clamp(m.hp,0,20)/20*e.maxhp); }
  e.elite=m.el?1:0; e.hostile=!!m.ho;
  if(e.kind==='raider'){
    if(typeof m.c==='string'&&(/^#[0-9a-fA-F]{3,8}$/).test(m.c)) e.coat=m.c;
    if(typeof m.cr==='number') e.crew=m.cr|0;
    if(typeof m.w==='string'&&Object.prototype.hasOwnProperty.call(WEAPONS,m.w)&&WEAPONS[m.w]&&WEAPONS[m.w].id) e.wep=WEAPONS[m.w];
    if(typeof m.rg==='string'){ A=armorById(m.rg); if(A&&A.id===m.rg){ e.rig=m.rg; e.bulk=A.bulk||0; } }
    e.merc=m.mc?1:0;
    if(typeof m.idn==='string'&&m.idn){
      e.ident=netClean(m.idn,24);
      try{ lk=raiderLook(e.ident,m.x,m.y); if(lk){ e.hair=lk.hair; e.cut=lk.cut; e.hat=lk.hat; e.skin=lk.skin; e.beard=lk.beard; e.eyes=lk.eyes; e.faceMark=lk.face; e.boots=lk.boots; e.gloves=lk.gloves; e.pack=lk.pack; e.patch=lk.patch; e.tattoo=lk.tattoo; } }catch(_lk){}
    }
  }
}
// The flags off a snapshot row, onto the body: what the drawing, the nameplates and the board read.
function netEntFlagsApply(e,f){
  e.downed=(f&1)?1:0; e.finished=(f&2)?1:0; e.alert=(f&4)?1:0; e.moving=!!(f&8); e.hostile=!!(f&16); e.friendlyPC=(f&32)?1:0;
  if((f&64)&&!(e.hitT>0)) e.hitT=.16;
  if((f&128)&&!(e.muzzle>0)) e.muzzle=.06;
  e.seenYou=!!(f&256);
  if(f&512){ if(e.windup===undefined||e.windup===null) e.windup=(e.kind==='warden')?0.7:0.4; } else e.windup=null;
  e.overheat=(f&1024)?Math.max(e.overheat||0,0.3):0;
  if(f&2048){ e.goal=e; if(e.state!=='loot') e.state='loot'; } else if(e.goal===e) e.goal=null;
  if((f&4096)&&!(e.roll>0)) e.roll=0.38;
  e.steady=!!(f&8192); e.reviving=(f&16384)?e:null; e.shotT=(f&32768)?0.35:0; e.lootT=(f&65536)?1:0; e.healQ=(f&131072)?1:0;
  e.sprintPool=(f&262144)?6:0; e.helped=(f&524288)?1:0; e.grudge=!!(f&1048576); e.parley=(f&2097152)?1:0; e.blind=(f&4194304)?1:0;
}
// A snapshot from the host, on a linked window up top on that seed: each row onto its body by number, a body never seen made
// on the spot. An older snapshot than the last applied is dropped (the fast channel is unordered). Returns what it did.
function netEntsApply(peer,m){
  var i, r, id, e, k, kind, st, fl, hb, x, y, f, n=0;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()) return 'down';
  if(typeof m.sd!=='number'||(m.sd>>>0)!==(NET.upSeed>>>0)) return 'seed';
  if(!m.e||typeof m.e.length!=='number'||m.e.length>NET_ENT_MAX) return 'bad';
  if(typeof m.n==='number'){ if(m.n<=NET.entLast&&NET.entLast-m.n<1000) return 'old'; NET.entLast=m.n; }
  if(!NET.entMap) NET.entMap={};
  for(i=0;i<m.e.length;i++){
    r=m.e[i]; if(!r||typeof r.length!=='number'||r.length<8) continue;
    id=r[0]|0; k=r[1]|0; x=+r[2]; y=+r[3]; f=+r[4]; st=r[5]|0; hb=r[6]|0; fl=r[7]|0;
    if(id<=0||!isFinite(x)||!isFinite(y)) continue;
    kind=NET_ENT_KINDS[k]; if(!kind) continue;
    if(NET.entGone&&NET.entGone[id]!==undefined&&typeof m.n==='number'&&m.n<NET.entGone[id]) continue;   // a packet from before the word that took this body off (the fast channel is unordered)
    x=clamp(x,-9000,NET_UP_MAX); y=clamp(y,-9000,NET_UP_MAX); f=isFinite(f)?f:0;
    e=NET.entMap[id];
    if(!e){ e=netEntMake(id,kind,x,y); NET.entMap[id]=e; }
    if(!e.nIn){ e.nIn=1; G.ents.push(e); }
    if(!e.nT||e.nAge>=NET_ENT_STALE||Math.sqrt((x-e.x)*(x-e.x)+(y-e.y)*(y-e.y))>NET_HUB_SNAP){ e.x=x; e.y=y; e.face=f; }
    e.nT=1; e.ntx=x; e.nty=y; e.ntf=f; e.nAge=0;
    e.state=NET_ENT_STATES[st]||'patrol';
    e.hp=Math.round(clamp(hb,0,20)/20*(e.maxhp||1));
    netEntFlagsApply(e,fl);
    n++;
  }
  return 'ents';
}
// A body arrived (new) or left (gone), from the host, on a linked window up top on that seed.
function netEntWord(peer,m){
  var e, id, i, ix, k;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()) return 'down';
  id=m.id|0; if(id<=0) return 'bad';
  if(!NET.entMap) NET.entMap={};
  if(m.op==='new'){
    k=(typeof m.k==='string'&&NET_ENT_KINDS.indexOf(m.k)>=0)?m.k:'';
    if(!k||typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
    e=NET.entMap[id];
    if(!e){ e=netEntMake(id,k,clamp(m.x,-9000,NET_UP_MAX),clamp(m.y,-9000,NET_UP_MAX)); NET.entMap[id]=e; }
    netEntFill(e,m);
    if(!e.nIn){ e.nIn=1; G.ents.push(e); }
    e.nAge=0;
    return 'ent:new';
  }
  if(m.op==='gone'){
    e=NET.entMap[id]; if(!e) return 'ent:unknown';
    delete NET.entMap[id];
    if(!NET.entGone||Object.keys(NET.entGone).length>400) NET.entGone={};
    NET.entGone[id]=(typeof m.n==='number')?m.n:(NET.entLast+1);
    ix=G.ents.indexOf(e);
    if(ix>=0){ G.ents.splice(ix,1); e.nIn=0; }
    if(m.how==='dead') netEntDeathFx(e);
    else if(G.roster){ for(i=0;i<G.roster.length;i++) if(G.roster[i].ref===e){ G.roster[i].out=true; G.roster[i].outAt=elapsed(); break; } }
    return 'ent:gone';
  }
  return 'bad';
}
// The end of a body this window watched: the spark, the puff and the label the host frame shows, and nothing else (what it
// drops is the host world, a later slice). Nothing here draws from the seeded stream.
function netEntDeathFx(e){
  try{
    var p=G.player;
    if(p&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)) label(e.x,e.y-16,(e.name||String(e.kind).toUpperCase())+(e.kind==='raider'?' ELIMINATED':' DOWN'),e.kind==='raider'?'#ff5a4a':'#ffc04a',0,true);
    spark(e.x,e.y,e.kind==='raider'?'#c8452f':'#ffc04a',22,300);
    if(G.puffs) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
  }catch(_fx){}
}
// A LINKED WINDOW, every frame in place of its own updateEnts: each body slides toward where the host last put it, turns on
// the shortest arc, walks its cycle while the host says it moves, runs its timers down, and goes when the host has said
// nothing about it for NET_ENT_STALE seconds. A body this window made on its own (nothing the host numbered) goes too.
function netEntsEase(dt){
  var i, e, k, dx, dy, da, tr, n=0;
  if(!isFinite(dt)||dt<0) dt=0;
  k=1-Math.exp(-NET_HUB_EASE*dt);
  for(i=G.ents.length-1;i>=0;i--){
    e=G.ents[i];
    if(!e.nid){ G.ents.splice(i,1); continue; }
    e.nAge=(e.nAge||0)+dt;
    if(e.nAge>=NET_ENT_STALE){ e.nIn=0; G.ents.splice(i,1); continue; }
    if(e.nT){
      dx=(e.ntx-e.x)*k; dy=(e.nty-e.y)*k; e.x+=dx; e.y+=dy;
      da=e.ntf-e.face; if(da>Math.PI) da-=6.2832; else if(da<-Math.PI) da+=6.2832; e.face+=da*k;
      tr=Math.sqrt(dx*dx+dy*dy); if(e.moving) e.step=(e.step||0)+tr*.05;
    }
    if(e.kind==='crawler') e.legs=(e.legs||0)+dt*14; else if(e.kind==='listener') e.legs=(e.legs||0)+dt*10;
    if(e.hitT>0) e.hitT-=dt; if(e.pHitT>0) e.pHitT-=dt; if(e.muzzle>0) e.muzzle-=dt;
    if(e.roll>0) e.roll=Math.max(0,e.roll-dt);
    if(e.windup!==undefined&&e.windup!==null){ e.windup-=dt; if(e.windup<=0) e.windup=null; }
    if(e.overheat>0) e.overheat-=dt; if(e.shotT>0) e.shotT-=dt;
    n++;
  }
  return n;
}
// A blow on this player, from the host: through its own damagePlayer, so armour, the downed rules and death are its own.
function netHitTake(peer,m){
  var d;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()||!G.player) return 'down';
  if(typeof m.seat==='number'&&m.seat!==NET.seat) return 'ignored';
  d=+m.dmg; if(!isFinite(d)||d<=0||d>500) return 'bad';
  damagePlayer(d,netClean(m.kind,16)||'other',netClean(m.name,24)||'',(typeof m.x==='number'&&isFinite(m.x))?m.x:undefined,(typeof m.y==='number'&&isFinite(m.y))?m.y:undefined);
  return 'hit';
}
// A LINKED WINDOW: its round, blade or charge landed on a body the host runs. The damage worked out here goes to the host,
// with where this player stands, the bearing of the blow and the weak point it found; the body itself is not touched here.
function netShotSend(e,dmg,ang,wk){
  var q, m;
  if(!e||!e.nid||!NET.on||NET.role!=='join'||!netEntsPeer()) return false;
  q=netPeerOfSeat(0); if(!q) return false;
  m={t:'shot',id:e.nid,dmg:+(+dmg).toFixed(2),x:+(+G.player.x).toFixed(1),y:+(+G.player.y).toFixed(1)};
  if(typeof ang==='number'&&isFinite(ang)) m.a=+ang.toFixed(3);
  if(wk&&wk.name) m.wk=netClean(wk.name,16);
  return netSend(q,m);
}
// THE HOST: a shot request from one of the party. Applied if the body is alive; the seat is marked for the kill by the rule
// the host rounds keep (v15.45: a killing or downing blow marks, a blow a standing man survives clears); the man turns
// hostile and onto the shooter as a host round turns him, and rolls out of the line as v3.94 rolls him. Never a seeded draw.
function netShotTake(peer,m){
  var e, d, L, i, s, sx, sy, px, py;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!netEntsHost()) return 'down';
  e=(NET.entMap&&NET.entMap[m.id|0])||null;
  if(!e||G.ents.indexOf(e)<0) return 'gone';
  if(e.hp<=0&&!e.downed) return 'dead';
  if(e.merc&&!e.downed) return 'merc';
  d=+m.dmg; if(!isFinite(d)||d<=0||d>400) return 'bad';
  s=peer.seat;
  sx=(typeof m.x==='number'&&isFinite(m.x))?m.x:e.x; sy=(typeof m.y==='number'&&isFinite(m.y))?m.y:e.y;
  if(typeof m.wk==='string'&&m.wk){ L=weakOf(e); if(L) for(i=0;i<L.length;i++) if(L[i].name===m.wk){ applyWeak(e,L[i]); break; } }
  e.hp-=d; e.hitT=.16; e.pHitT=.3;
  if(CFG.raiderRoll!==0&&e.kind==='raider'&&!e.downed&&!e.finished&&!e.roll&&!(e.rollCd>0)&&e.hp>0&&typeof m.a==='number'&&isFinite(m.a)&&
     dist(e,{x:sx,y:sy})<(CFG.raiderRollEar===undefined?900:CFG.raiderRollEar)){
    px=-Math.sin(m.a); py=Math.cos(m.a);
    if((px*Math.cos(e.face)+py*Math.sin(e.face))<0){ px=-px; py=-py; }
    e.rollDir={x:px,y:py}; e.roll=0.38;
    if(!G.sim) sfx('step',e.x,e.y);
  }
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
  if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC) e.hostile=true;
  if(e.kind==='raider'&&e.state==='extract'){ e.alert=2.6; }
  else if(e.kind!=='snitch'){ e.alert=2.6; e.state='chase'; e.tx=sx; e.ty=sy; }
  else if(e.state!=='alarm'){ e.state='alarm'; e.lost=0; e.wind=3.5; e.markX=sx; e.markY=sy; }
  if(!G.sim){ spark(e.x,e.y,e.kind==='raider'?'#ff5a4a':'#ffc25c',9,220); sfx('hit',e.x,e.y); }
  return 'shot';
}
// A kill credited to this seat, from the host: the count, the contract and the grudge, as this window own kill would be.
function netKillTake(peer,m){
  var e, k, T, rr2;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof G==='undefined'||!G||G.sim||!G.tel) return 'down';
  if(typeof m.seat==='number'&&m.seat!==NET.seat) return 'ignored';
  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||null;
  if(!k) return 'bad';
  if(T.kills&&T.kills[k]!==undefined) T.kills[k]++;
  try{ contractKill(k); }catch(_ck){}
  if(m.el||(e&&e.elite)) T.eliteKills=(T.eliteKills||0)+1;
  if(k==='raider'&&e&&e.ident){
    rr2=idRec(e.ident); rr2.kills++; rr2.standing=Math.min(rr2.standing-2,-1); rr2.met++;
    saveProfile();
    sayWhenFree((e.name||'He')+' will remember that.');
  }
  return 'kill';
}
// The bodies as this window holds them, for the test page handle.
function netEntsView(){
  var out=[], i, e, n=0;
  if(typeof G!=='undefined'&&G&&G.ents) for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e.nid) n++; out.push({id:e.nid||0,k:e.kind,x:e.x,y:e.y,st:e.state,hp:e.hp,name:e.name||''}); }
  return {peer:netEntsPeer(),host:netEntsHost(),n:out.length,numbered:n,sent:NET.entN,last:NET.entLast,list:out};
}
// THE PARTY WINDOW.
'@

SubRx @'
      up:function(){ return netUpView(); }};
'@ @'
      up:function(){ return netUpView(); },
      // v15.80: the bodies as this window holds them: whether it runs them for the party or watches the host run them, and each by number.
      ents:function(){ return netEntsView(); }};
'@

$pat = "(?m)^  now:'v15\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.80: ONE SET OF ENEMIES, RUN BY THE HOST, SEEN AND FELT BY EVERYONE. Multiplayer phase 2 build 2. Up top the host runs every pillager and machine and the linked windows watch: every body is numbered at the build, in list order, on every window alike; ten times a second the host sends where every body near any player stands on the fast channel, and tells the party at once on the reliable channel about a body that arrived or left; a linked window runs no pillager or machine of its own and slides each body to where the host put it, made and named on first sight if it arrived later. Every body picks the nearest player, the host player or one of the party up top, a standing man before a downed one; a blow on one of the party is a hit word to his window, taken through his own damagePlayer, so the host never touches his health; no team damage anywhere. A round, blade or charge from one of the party on a body is a request the host applies, with the kill credited to that seat as a word back. Loot, searching, revives, extraction, the clock and the weather stay with each window in this slice. Solo play untouched: every call is behind NET.on and the seed 4242 fingerprint has no way to move. Check 15.80 fails on v15.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
