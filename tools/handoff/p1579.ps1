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

# THE PARTY ASCENDS TOGETHER INTO ONE SURFACE AND SEES EACH OTHER UP TOP. Multiplayer, phase 2, build 1 (tools/multiplayer/plan.md
# phase 2 with the corrections in critique.md), his order of 2026-09-25. The smallest slice of the shared raid: no shared
# pillagers, machines, loot, bullets or extraction yet; each window still runs its own pillagers and each player still extracts,
# dies or abandons on its own.
# 1. VER 15.78 to 15.79.
# 2. saveProfile writes nothing while a party build has the host world dials in (NET.upHold).
# 3. buildRaid: the loaner draw follows the host word in a party build (NET.upIss); the raid remembers whether it drew (issDraw).
# 4. startRaid: right after the build the host tells the party (netUpAnnounce).
# 5. endRaid: the party is told the raid ended (netUpEnd).
# 6. render2D: the others go into the depth list (netUpDraw), are drawn by the list (netUpDrawOne) and named (netUpTags).
# 7. loop: the raid tick (netUpTick) while a party is on.
# 8. NET gains up, upAcc, upN, upSeed, upFp, upHold, upIss; netReset clears them; netOnMsg hands raid and up words on;
#    netOnState files a word from up top (k r) on NET.up with its seed, crouch, sprint, downed and gun, and relays it as it came.
# 9. The up top section: netUpTerms, netUpCfgDiff, netUpFp, netUpFpSame, netUpFpText, netUpAnnounce, netUpBusy, netUpSnapP,
#    netUpPutP, netUpStart, netUpTake, netUpWhyText, netUpWord, netUpEnd, netUpTick, netUpShown, netUpDraw, netUpDrawOne,
#    netUpTags, netUpView.
# 10. The test handle: up(), for tools/nettest.html.
# Solo play is untouched: every call is behind NET.on and the loaner draw reads NET.upHold, which only a party build sets.

SubRx @'
var VER='15.78';
'@ @'
var VER='15.79';
'@

SubRx @'
function saveProfile(){ P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@ @'
function saveProfile(){ if(typeof NET==='object'&&NET&&NET.upHold) return;   // v15.79: nothing is written while a party build has the host world dials in; the build is saved once they are out
  P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@

SubRx @'
  var wep=WEAPONS[P.equipped],wepIssued=false;
  if(wep&&wearable(P.equipped)) wep=bakeWear(P.equipped);
  if(!wep||wep.id==='fists'||!P.weapons||P.weapons.indexOf(P.equipped)<0){
    wep=WEAPONS[pick(STARTERS)]; wepIssued=true;
  }
'@ @'
  var wep=WEAPONS[P.equipped],wepIssued=false;
  // v15.79: THE ONE SEEDED DRAW IN THE BUILD THAT DEPENDS ON THE PLAYER. In a party build (NET.upHold) the host says whether it
  // drew a loaner (NET.upIss): a window that would draw when the host did not draws its loaner off a saved and restored
  // stream, and one that would not draw when the host did makes the same draw and drops it, so the population lands where
  // the host put it. Outside a party build _upIss is null and this block is what it always was.
  var _upIss=(typeof NET==='object'&&NET&&NET.upHold)?NET.upIss:null;
  if(wep&&wearable(P.equipped)) wep=bakeWear(P.equipped);
  if(!wep||wep.id==='fists'||!P.weapons||P.weapons.indexOf(P.equipped)<0){
    if(_upIss===false){ var _upR=RNGS; wep=WEAPONS[pick(STARTERS)]; RNGS=_upR; }
    else wep=WEAPONS[pick(STARTERS)];
    wepIssued=true;
  } else if(_upIss===true){ pick(STARTERS); }
'@

SubRx @'
    spawnDbg:_spDbg,
'@ @'
    spawnDbg:_spDbg,issDraw:wepIssued,   // v15.79: whether a loaner was drawn from the stream, told to the party so their builds make the same draw
'@

SubRx @'
  G.carriedKit=(G.bag||[]).slice();   // v13.55: WHICH items came up, so an item contract counts only what was found   // v10.27: what the lift carried in, valued as the haul is
'@ @'
  G.carriedKit=(G.bag||[]).slice();   // v13.55: WHICH items came up, so an item contract counts only what was found   // v10.27: what the lift carried in, valued as the haul is
  if(NET.on&&NET.role==='host'&&!G.sim) netUpAnnounce(G);   // v15.79: the party is told to ascend into this world (the net section)
'@

SubRx @'
  G.over=how;
'@ @'
  G.over=how;
  if(NET.on&&!G.sim){ try{ netUpEnd(how); }catch(_ue){} }   // v15.79: the party is told this raid ended, and nobody is drawn up top any more
'@

SubRx @'
  DR.push({k:p.y-drawLift((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y):0),pl:1});
'@ @'
  DR.push({k:p.y-drawLift((G&&G.map&&G.map.liftAt)?G.map.liftAt(p.x,p.y):0),pl:1});
  if(NET.on) netUpDraw(DR);   // v15.79: the others in the party, sorted into the same list at the depth of where they stand
'@

SubRx @'
      drawContS(it.c);
    } else if(it.pl){
'@ @'
      drawContS(it.c);
    } else if(it.up){
      netUpDrawOne(it.up);   // v15.79: one of the party up top, drawn as this body is drawn below
    } else if(it.pl){
'@

SubRx @'
  // nameplates over anything you can currently see
'@ @'
  if(NET.on) netUpTags();   // v15.79: the party names over their heads, beside the pillager nameplates
  // nameplates over anything you can currently see
'@

SubRx @'
  if(state!=='raid'||!G||G.sim) return;
'@ @'
  if(state!=='raid'||!G||G.sim) return;
  if(NET.on) netUpTick(dt);   // v15.79: where the party stands up top, eased in and sent out, whatever the frame does below
'@

SubRx @'
  sndOn:true,sndOther:-1,sndG:null,sndAc:null};   // v15.78: this window's sound switch, the other window's word (-1 not said), and the master gain
'@ @'
  sndOn:true,sndOther:-1,sndG:null,sndAc:null,   // v15.78: this window's sound switch, the other window's word (-1 not said), and the master gain
  up:[],upAcc:0,upN:0,upSeed:0,upFp:null,upHold:false,upIss:null};   // v15.79: who stands where up top by seat, the send clock, this raid seed and fingerprint, the party build guard and the loaner word
'@

SubRx @'
  if(m.t==='st') return netOnState(peer,m);
'@ @'
  if(m.t==='st') return netOnState(peer,m);
  if(m.t==='raid') return netUpTake(peer,m);   // v15.79: the host ascended; a linked window in the Undercroft builds the same raid
  if(m.t==='up') return netUpWord(peer,m);   // v15.79: a window went up, could not, or its raid ended
'@

SubRx @'
  NET.floor=[]; NET.hubAcc=0; NET.hubN=0; NET.lkSent='';   // v15.75: nobody is left standing on the floor
'@ @'
  NET.floor=[]; NET.hubAcc=0; NET.hubN=0; NET.lkSent='';   // v15.75: nobody is left standing on the floor
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
'@

SubRx @'
  var s, x, y, f, g, lk, out, i;
'@ @'
  var s, x, y, f, g, lk, out, i, up, L;
'@

SubRx @'
  x=clamp(m.x,0,HUBW); y=clamp(m.y,0,HUBH);
'@ @'
  up=(m.k==='r'); x=clamp(m.x,0,up?NET_UP_MAX:HUBW); y=clamp(m.y,0,up?NET_UP_MAX:HUBH);   // v15.79: k r is a word from up top, where the surface is far bigger than the floor
'@

SubRx @'
  g=NET.floor[s]||null;
'@ @'
  L=up?NET.up:NET.floor; g=L[s]||null;   // v15.79: up top and the floor are two lists; a word from up top never moves a man on the floor
'@

SubRx @'
  if(!g){ g={seat:s,x:x,y:y,f:f,tx:x,ty:y,tf:f,mv:0,roll:0,bob:0,age:0,n:0,lk:null}; NET.floor[s]=g; }
'@ @'
  if(!g){ g={seat:s,x:x,y:y,f:f,tx:x,ty:y,tf:f,mv:0,roll:0,bob:0,age:0,n:0,lk:null,cr:0,sp:0,dn:0,w:'',sd:0,wep:null}; L[s]=g; }   // v15.79: filed on the list the word names
'@

SubRx @'
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++;
'@ @'
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++;
  if(up){ g.cr=m.c?1:0; g.sp=m.sp?1:0; g.dn=m.dn?1:0; g.w=netClean(m.w,24); g.sd=(+m.sd)>>>0; }   // v15.79: crouched, sprinting, downed, the gun in hand and the seed of the raid he is in
'@

SubRx @'
    out={t:'st',s:s,x:+x.toFixed(1),y:+y.toFixed(1),f:+f.toFixed(2),m:g.mv,r:+g.roll.toFixed(2)};
'@ @'
    out={t:'st',s:s,x:+x.toFixed(1),y:+y.toFixed(1),f:+f.toFixed(2),m:g.mv,r:+g.roll.toFixed(2)};
    if(up){ out.k='r'; out.sd=g.sd; out.c=g.cr; out.sp=g.sp; out.dn=g.dn; out.w=g.w; }   // v15.79: passed on as it came
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.79, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 1 OF PHASE 2. THE PARTY ASCENDS TOGETHER INTO ONE SURFACE AND SEES EACH
// OTHER UP TOP. The smallest slice of the shared raid (tools/multiplayer/plan.md, phase 2, with the corrections in critique.md):
// no shared pillagers, machines, loot, bullets or extraction yet. Each window still runs its own pillagers and machines (host
// snapshots replace them in the next slices), and each player still extracts, dies or abandons on its own, coming back empty
// on its own save as today. The host dropping mid-raid does not end the others in this slice.
//   ASCEND TOGETHER. When the host ascends (the sector page, the loadout question, ascendNow, startRaid) its raid is built as
//   always, and right after the build the party is told {t:'raid'} on the reliable channel (netUpAnnounce): the seed, the
//   sector (mapIx), the hour (cond, DAY or NIGHT), the weather the host got (wx), whether the host drew a loaner gun from the
//   seeded stream (iss), the terms, the hire (merc), every Settings dial and console override that differs from its default
//   (cfg) and a fingerprint of what was built (fp). Each linked window in the Undercroft (netUpTake, netUpStart) builds the
//   same raid from those values through the real commitKit and startRaid, on its OWN save and kit: the host world fields
//   (mapIx, cond, terms, merc, the weather pick, the dials on top of the defaults) go in for the length of the build and its
//   own come back after; saveProfile writes nothing while they are in (NET.upHold) and the build is saved once they are out,
//   so the host dials never reach this save; the intel core is not spent. The sector and the hour stay, since the fog saves
//   under the sector he is on. The loaner draw is the one seeded draw in the build that depends on the player, so the host
//   says whether it drew (buildRaid reads NET.upIss under NET.upHold): a window that would draw when the host did not draws
//   its loaner off a saved and restored stream, one that would not draw when the host did makes the same draw and drops it,
//   and the population lands where the host put it. The built world is fingerprinted (netUpFp: the counts, the weather, an
//   FNV hash over every wall, body and container by place and kind) and held against the host fingerprint. A mismatch never
//   plays a different surface: the raid is torn down before a frame, the save is put back from a snapshot taken before the
//   kit was committed, the PARTY window says so and the host is told. A window that is not in the Undercroft (up top
//   already, on the title, still on the run card) is told it was left behind, and the host is told why.
//   SEE EACH OTHER. Up top every player sends where it stands ten times a second on the fast channel (netUpTick), the v15.75
//   word with k:'r', the seed, crouched, sprinting, downed and the gun in hand; the host relays as it does on the floor, and
//   netOnState files a word from up top on NET.up, never on the floor list. Each window eases the others as the floor does,
//   sorts them into the raid depth list with the deck lift (netUpDraw) and draws each with drawOp exactly as its own body is
//   drawn up top, in his fit and racks with his gun (netUpDrawOne), named over his head beside the pillager nameplates
//   (netUpTags). Nobody up top is a target for anything yet and nobody collides. A window whose raid ends says {t:'up',
//   st:'out'} (netUpEnd, from endRaid) and is hidden at once; a bye or a lost link takes his seat out as before; a word from
//   another seed is filed and not drawn.
// SOLO PLAY IS UNTOUCHED. Every call in here is behind NET.on; the loaner draw in buildRaid reads NET.upHold, which only a party
// build sets; nothing here draws from the seeded stream (rr, rnd, ri, pick, rollTable): the fingerprint is an FNV hash.
var NET_UP_MAX=20000;
function netUpTerms(list){ var out=[], i, v; if(!list||typeof list.length!=='number') return out; for(i=0;i<list.length&&out.length<12;i++){ v=netClean(list[i],24); if(v) out.push(v); } return out; }
// Every Settings dial and console override that differs from its default: what another window needs to build this world.
function netUpCfgDiff(){ var out={}, k; for(k in DEF) if(Object.prototype.hasOwnProperty.call(DEF,k)&&CFG[k]!==DEF[k]) out[k]=CFG[k]; return out; }
// The fingerprint of a built world: the counts, the weather, and an FNV hash over every wall, body and container by place.
function netUpFp(g){
  var h=0x811c9dc5, i, w, e, c;
  function mix(v){ var s=String(v)+'|', q; for(q=0;q<s.length;q++){ h=(h^s.charCodeAt(q))>>>0; h=Math.imul(h,0x01000193)>>>0; } }
  if(!g||!g.map||!g.map.walls||!g.ents||!g.containers) return null;
  for(i=0;i<g.map.walls.length;i++){ w=g.map.walls[i]; mix(Math.round(w.x)); mix(Math.round(w.y)); mix(Math.round(w.w)); mix(Math.round(w.h)); }
  for(i=0;i<g.ents.length;i++){ e=g.ents[i]; mix(e.kind); mix(Math.round(e.x)); mix(Math.round(e.y)); }
  for(i=0;i<g.containers.length;i++){ c=g.containers[i]; mix(Math.round(c.x)); mix(Math.round(c.y)); }
  return {e:g.ents.length,c:g.containers.length,w:g.map.walls.length,h:('0000000'+h.toString(16)).slice(-8),wx:(g.wx&&g.wx.id)||''};
}
function netUpFpSame(a,b){ return !!a&&!!b&&a.e===b.e&&a.c===b.c&&a.w===b.w&&a.h===b.h&&a.wx===b.wx; }
function netUpFpText(f){ return f?(f.e+' bodies, '+f.c+' containers, '+f.w+' walls, '+f.h+(f.wx?(', '+f.wx):'')):'nothing'; }
// THE HOST, right after its raid is built: the party is told what to build. Returns the word, or null outside a party.
function netUpAnnounce(g){
  var m;
  if(!NET.on||NET.role!=='host'||!g||g.sim) return null;
  m={t:'raid',seed:g.seed>>>0,mapIx:clamp((P&&P.mapIx)|0,0,FIXED_MAPS.length-1),cond:(P&&P.cond==='night')?'night':'day',wx:(g.wx&&g.wx.id)||'',
     iss:g.issDraw?1:0,terms:netUpTerms(termsOn()),merc:(P&&typeof P.merc==='string')?P.merc:'',cfg:netUpCfgDiff(),fp:netUpFp(g)};
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=m.seed; NET.upFp=m.fp;
  netBroadcast(m);
  return m;
}
// Why this window cannot go up right now, or nothing when it can: on the Undercroft floor, past the title, no raid in hand.
function netUpBusy(){
  var t=document.getElementById('title');
  if(typeof G!=='undefined'&&G) return G.over?'still on the run card':'up top already';
  if(typeof state!=='undefined'&&state==='raid') return 'up top already';
  if(t&&t.classList.contains('on')) return 'on the title';
  return '';
}
function netUpSnapP(){ try{ return JSON.stringify(P); }catch(e){ return null; } }
// The save put back as it was, in place: P is the one object every closure holds.
function netUpPutP(js){
  var o=null, k;
  try{ o=JSON.parse(js); }catch(e){ o=null; }
  if(!o||typeof o!=='object') return false;
  for(k in P) if(Object.prototype.hasOwnProperty.call(P,k)&&!Object.prototype.hasOwnProperty.call(o,k)) delete P[k];
  for(k in o) if(Object.prototype.hasOwnProperty.call(o,k)) P[k]=o[k];
  return true;
}
// A LINKED WINDOW IN THE UNDERCROFT: the same raid from the host word, on its own save and kit. Returns what happened.
function netUpStart(m){
  var keepCfg={}, keep, k, snap, fp, threw=null, hostFp=(m.fp&&typeof m.fp==='object')?m.fp:null, seed=(+m.seed)>>>0;
  snap=netUpSnapP();
  try{ commitKit(); }catch(e0){}   // its own packed kit, as MY LOADOUT commits it, saved under its own dials
  for(k in CFG) if(Object.prototype.hasOwnProperty.call(CFG,k)) keepCfg[k]=CFG[k];
  keep={terms:P.terms,merc:P.merc,intel:P.intel,wxPick:P.wxPick};
  NET.upHold=true; NET.upIss=(m.iss===1)?true:((m.iss===0)?false:null);
  try{
    for(k in DEF) if(Object.prototype.hasOwnProperty.call(DEF,k)) CFG[k]=DEF[k];
    if(m.cfg&&typeof m.cfg==='object') for(k in m.cfg) if(Object.prototype.hasOwnProperty.call(DEF,k)&&(typeof m.cfg[k]==='number'||typeof m.cfg[k]==='string'||typeof m.cfg[k]==='boolean')) CFG[k]=m.cfg[k];
    P.mapIx=clamp((m.mapIx|0),0,FIXED_MAPS.length-1); P.cond=(m.cond==='night')?'night':'day';
    P.terms=netUpTerms(m.terms); P.merc=netClean(m.merc,24)||null; P.intel=0; P.wxPick=netClean(m.wx,16)||'any';
    pendSeed=seed;
    startRaid();
  }catch(e){ threw=netErrText(e); }
  finally{
    NET.upHold=false; NET.upIss=null; pendSeed=null;
    for(k in keepCfg) if(Object.prototype.hasOwnProperty.call(keepCfg,k)) CFG[k]=keepCfg[k];
    P.terms=keep.terms; P.merc=keep.merc; P.intel=keep.intel; P.wxPick=keep.wxPick;
  }
  fp=(!threw&&G&&!G.sim&&G.seed===seed)?netUpFp(G):null;
  if(threw||!fp||!netUpFpSame(fp,hostFp)){
    // Never a different surface: torn down before a frame, the save put back as it was before the kit was committed.
    G=null; keys={};
    try{ showScreen('hub'); }catch(e2){}
    if(snap) netUpPutP(snap);
    try{ saveProfile(); }catch(e3){}
    NET.err=threw?('This window could not build the surface your party went up to ('+threw+'), so it stays in the Undercroft.')
                 :('This window could not build the same surface as your host (the host built '+netUpFpText(hostFp)+'; this window built '+netUpFpText(fp)+'). Both copies need the same build and the same Settings dials. This window stays in the Undercroft.');
    netSay('Your party went up without you: this window could not build the same surface. Open the PARTY window at the lift.');
    netBroadcast({t:'up',st:'no',why:'surface'});
    netRefresh();
    return 'mismatch';
  }
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=seed; NET.upFp=fp;
  try{ saveProfile(); }catch(e4){}   // the kit that went up, the sector and the hour, under its own dials
  NET.status='Your party ascended together.'; NET.err='';
  netBroadcast({t:'up',st:'in'});
  return 'up';
}
// The host word, on a linked window: taken when this window is in the Undercroft, else told and ignored.
function netUpTake(peer,m){
  var why;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof m.seed!=='number'||!isFinite(m.seed)) return 'bad';
  why=netUpBusy();
  if(why){ NET.err='Your party went up without you: this window was '+why+'.'; netBroadcast({t:'up',st:'no',why:why}); netRefresh(); return 'busy'; }
  return netUpStart(m);
}
function netUpWhyText(w){
  w=netClean(w,24);
  if(w==='surface') return 'it could not build the same surface';
  if(w==='up top already') return 'it was up top already';
  if(w==='on the title') return 'it was on the title';
  if(w==='still on the run card') return 'it was still on the run card';
  return 'it could not go up';
}
// A window went up (in), could not (no) or its raid ended (out): from a friend, on the host, filed under the seat of his link
// and passed on to the others; or passed on by the host, on a friend, under the seat it names.
function netUpWord(peer,m){
  var s, st, out, i, nm;
  if(!peer||peer.state!=='in') return 'ignored';
  st=(m.st==='in'||m.st==='out'||m.st==='no')?m.st:'';
  if(!st) return 'bad';
  if(NET.role==='host') s=peer.seat;
  else if(NET.role==='join'){ if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad'; s=m.s; }
  else return 'off';
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  if(st!=='in') NET.up[s]=null;
  nm=netSeatName(s)||'PILLAGER';
  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); }
  if(NET.role==='host'){
    out={t:'up',s:s,st:st}; if(m.why!==undefined) out.why=netClean(m.why,24); if(m.how!==undefined) out.how=netClean(m.how,12);
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],out);
  }
  return 'up:'+st;
}
// This raid ended, however it ended: the party is told, and nobody is drawn up top any more.
function netUpEnd(how){
  if(!NET.on) return false;
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
  return true;
}
// Called from loop while a party is on and a raid is in hand, every frame. Eases the others toward where they last said
// they stood, takes anyone who left the roster off, and about ten times a second sends where this player stands.
function netUpTick(dt){
  if(!NET.on||typeof G==='undefined'||!G||G.sim) return 0;
  if(!isFinite(dt)||dt<0) dt=0;
  var k=1-Math.exp(-NET_HUB_EASE*dt), i, g, dx, dy, da, sp, p, msg, lk, ls, sent=0;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!g) continue;
    if(g.seat===NET.seat||netSeatName(g.seat)===null){ NET.up[i]=null; continue; }
    g.age+=dt;
    dx=(g.tx-g.x)*k; dy=(g.ty-g.y)*k;
    g.x+=dx; g.y+=dy;
    da=g.tf-g.f;
    if(da>Math.PI) da-=6.2832; else if(da<-Math.PI) da+=6.2832;
    g.f+=da*k; g.f=g.f-6.2832*Math.floor(g.f/6.2832);
    sp=(dt>0)?Math.sqrt(dx*dx+dy*dy)/dt:0;
    g.bob+=dt*(g.mv?((sp>200)?15:9):1.2);
    if(g.roll>0) g.roll=Math.max(0,g.roll-dt);
  }
  p=G.player;
  if(G.over||!p||!netInCount()) return 0;
  NET.upAcc+=dt;
  if(NET.upAcc<NET_HUB_STEP) return 0;
  NET.upAcc=Math.min(NET.upAcc-NET_HUB_STEP,NET_HUB_STEP);
  msg={t:'st',k:'r',sd:NET.upSeed>>>0,x:+(+p.x||0).toFixed(1),y:+(+p.y||0).toFixed(1),f:+(+p.face||0).toFixed(2),m:p.moving?1:0,r:(p.roll>0)?+(+p.roll).toFixed(2):0,
       c:(G.pCrouch||crouchHeld())?1:0,sp:G.sprinting?1:0,dn:p.downed?1:0,w:(p.wep&&p.wep.id)?String(p.wep.id):''};
  if(NET.role==='host') msg.s=NET.seat;   // a friend names no seat: the host files him under the seat of his link
  lk=netLook(); ls=JSON.stringify(lk);
  if(ls!==NET.lkSent||NET.upN%10===0){ msg.lk=lk; NET.lkSent=ls; }
  NET.upN++;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&netSendFast(NET.peers[i],msg)) sent++;
  return sent;
}
function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }
// Called from render2D while a party is on: each of the others goes into the raid depth list with the deck lift, and the
// list draws him with netUpDrawOne. Returns how many went in.
function netUpDraw(DR){
  var i, g, n=0;
  if(!NET.on||!DR||typeof G==='undefined'||!G) return 0;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(netUpShown(g)){ DR.push({k:g.y-drawLift((G.map&&G.map.liftAt)?G.map.liftAt(g.x,g.y):0),up:g}); n++; } }
  return n;
}
// One of the party up top: drawOp as this window draws its own body up top, in his fit and racks with his gun, crouched,
// rolling, sprinting or down as he said, lifted by the deck he stands on. Wrapped, because a fault in one body must never
// cost the frame.
function netUpDrawOne(g){
  var lk, fit, lift=0, mode, wp=null;
  try{
    lk=g.lk||{}; fit=FITCOL[lk.fit]||FITCOL.slate;
    if(g.w&&Object.prototype.hasOwnProperty.call(WEAPONS,g.w)&&WEAPONS[g.w]&&WEAPONS[g.w].id) wp=WEAPONS[g.w];
    g.wep=wp;   // read by drawOp off own, as the gun in hand; the hair lag lives on the entry too, as it does on any body
    lift=drawLift((G&&G.map&&G.map.liftAt)?G.map.liftAt(g.x,g.y):0);
    if(lift>0){ wc.save(); wc.translate(0,-lift); }
    mode=g.dn?'down':((g.roll>0)?'roll':(g.cr?'crouch':(wp?'':'none')));
    drawOp(g.x,g.y,g.f,(g.roll>0)?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,mode,0,
      {hero:0,own:g,moving:!!g.mv,sprint:!!g.sp,ads:false,hurt:0,rl:0,bulk:0,
       skin:lk.skin,hair:lk.hair,hat:lk.hat,cut:lk.cut,beard:lk.beard,eyes:lk.eyes,faceMark:lk.face,boots:lk.boots,
       gloves:lk.gloves,pack:lk.pack,patch:lk.patch,tattoo:lk.tattoo,outfit:lk.outfit});
  }catch(e){}
  if(lift>0){ try{ wc.restore(); }catch(e2){} }
}
// Their names over their heads, drawn in the world beside the pillager nameplates.
function netUpTags(){
  var i, g, nm, tw, n=0;
  if(!NET.on||typeof G==='undefined'||!G) return 0;
  try{
    wc.font=FS(TYPE.micro);
    for(i=0;i<NET.up.length;i++){
      g=NET.up[i]; if(!netUpShown(g)) continue;
      nm=netSeatName(g.seat)||'PILLAGER';
      tw=wc.measureText(nm).width;
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x-tw/2,g.y-52);
      n++;
    }
  }catch(e){}
  return n;
}
// Where the others stand up top, and this raid, for the test page handle.
function netUpView(){
  var out=[], i, g, up=!!(typeof G!=='undefined'&&G&&!G.sim&&typeof state!=='undefined'&&state==='raid');
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(g) out.push({seat:g.seat,name:netSeatName(g.seat),x:g.x,y:g.y,tx:g.tx,ty:g.ty,n:g.n,sd:g.sd,shown:netUpShown(g)}); }
  return {on:up,over:!!(typeof G!=='undefined'&&G&&G.over),seed:NET.upSeed,fp:NET.upFp,me:(up&&G.player)?{x:G.player.x,y:G.player.y,face:G.player.face||0,seat:NET.seat}:null,list:out};
}
// THE PARTY WINDOW.
'@

SubRx @'
      sndSet:function(on){ return netSndSet(!!on); }};
'@ @'
      sndSet:function(on){ return netSndSet(!!on); },
      // v15.79: whether this window is up top, the seed and fingerprint of its raid, where it stands, and where it draws the others.
      up:function(){ return netUpView(); }};
'@

$pat = "(?m)^  now:'v15\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.79: THE PARTY ASCENDS TOGETHER INTO ONE SURFACE AND SEES EACH OTHER UP TOP. Multiplayer phase 2 build 1, the smallest slice of the shared raid. When the host ascends, the party is told the seed, the sector, the hour, the weather, the loaner draw, the terms, the hire and the dials, and every linked window in the Undercroft builds the same raid through the real startRaid on its own save and kit: the host world fields go in for the build and come out after, nothing is saved while they are in, and the built world is fingerprinted against the host before a frame is drawn; a mismatch stays in the Undercroft with the kit put back. Up top each player sends where it stands ten times a second, the host relays, and each window draws the others with its own body drawing at their depth with a name over their head; a raid that ends hides its player at once. No shared pillagers, loot, bullets or extraction yet; each window still runs its own pillagers and extracts, dies or abandons on its own. Solo play untouched: every call is behind NET.on and the seed 4242 fingerprint has no way to move. Check 15.79 fails on v15.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
