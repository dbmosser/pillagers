$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# TRADING BETWEEN PLAYERS IN A RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netAidPass(s,by,key){
'@ @'
// v17.44, HIS PICK 4 (2026-09-30): TRADING IN A RAID, without seeing the other backpack. With the backpack open, T (or Y on a
// pad) offers the selected item to the nearest teammate up top within 220; he reads NAME offers you ITEM and takes it with T
// or Y within GIFT_T seconds. The item leaves the giver only when the taker says yes (op yes), and then lands with the taker
// through the loot path (room, or at his feet), so nothing is lost or copied on the way. A loaner Bandage stays a loaner and
// an armoury gun leaves the giver's spliced list, as a drop taken by a teammate does (v17.06, v17.07). The host passes words
// between teammates.
var GIFT_T=12;
function netGiftSeat(){
  var i, g, best=-1, bd=220, d, p=G&&G.player;
  if(!p||!NET.up) return -1;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(!g||g.seat===NET.seat||!netUpShown(g)||g.dn) continue; d=Math.hypot(g.x-p.x,g.y-p.y); if(d<bd){ bd=d; best=g.seat; } }
  return best;
}
function netGiftSend(to,m){
  var i, q;
  m.t='gift'; m.to=to; m.from=NET.seat;
  if(NET.role==='host'){ for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===to) return netSend(NET.peers[i],m); return false; }
  q=netPeerOfSeat(0); return q?netSend(q,m):false;
}
function netGiftKey(){
  var s, st, S, k, it, nm, gi;
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||G.player.downed) return false;
  if(G.bagOpen){
    S=bagStacks(); st=S[clamp(G.bagSel|0,0,Math.max(0,S.length-1))];
    if(!st||!st.idxs||!st.idxs.length) return false;
    k=G.bag[st.idxs[st.idxs.length-1]]; it=ITEMS[k]; if(!it) return false;
    s=netGiftSeat();
    if(s<0){ say('Nobody close enough to give it to.'); return true; }
    nm=netSeatName(s)||'your teammate';
    G.giftOut={id:String(Date.now()%1e9)+'-'+Math.floor(Math.random()*1e4),k:k,to:s,t:G.t};
    netGiftSend(s,{op:'offer',id:G.giftOut.id,k:k});
    say('Offered '+it.name+' to '+nm+'.'); return true;
  }
  gi=G.giftIn;
  if(gi&&!gi.yes&&G.t-gi.t<=GIFT_T){ gi.yes=1; netGiftSend(gi.from,{op:'yes',id:gi.id}); say('Taking it.'); return true; }
  return false;
}
function netGiftTake(peer,m){
  var fr, it, nm, i, ix, go, gi, out, key, gk, j, where;
  if(!peer||peer.state!=='in'||!m||typeof m.op!=='string') return 'bad';
  fr=(NET.role==='host')?peer.seat:((typeof m.from==='number'&&m.from===(m.from|0))?m.from:0);
  if(NET.role==='host'&&typeof m.to==='number'&&m.to!==NET.seat){
    out={t:'gift',op:m.op,id:m.id,k:m.k,ib:m.ib,to:m.to,from:fr};
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===m.to) return netSend(NET.peers[i],out)?'passed':'lost';
    return 'nobody';
  }
  if(typeof m.to==='number'&&m.to!==NET.seat) return 'ignored';
  if(typeof G==='undefined'||!G||G.over||!G.player) return 'no raid';
  nm=netSeatName(fr)||'Your teammate'; key=netClean(m.k,32); it=ITEMS[key];
  if(m.op==='offer'){
    if(!it) return 'bad';
    G.giftIn={id:String(m.id).slice(0,40),k:key,from:fr,t:G.t};
    say(nm+' offers you '+it.name+'. Press T or Y to take it.'); return 'offer';
  }
  if(m.op==='yes'){
    go=G.giftOut;
    if(!go||go.id!==m.id||go.to!==fr||G.t-go.t>GIFT_T+5){ netGiftSend(fr,{op:'no',id:m.id}); return 'stale'; }
    ix=G.bag.lastIndexOf(go.k); G.giftOut=null;
    if(ix<0){ netGiftSend(fr,{op:'no',id:m.id}); return 'gone'; }
    G.bag.splice(ix,1);
    var ib=0;
    if(go.k==='bandage'&&(G.issuedBandages||0)>0){ G.issuedBandages--; if(G.bandSeen!==undefined) G.bandSeen--; ib=1; }
    if(/^gun_/.test(go.k)&&ITEMS[go.k]&&ITEMS[go.k].gk){ gk=ITEMS[go.k].gk; j=(G.spliced||[]).indexOf(gk); if(j>=0) G.spliced.splice(j,1); if(P.raidSpliced){ j=P.raidSpliced.indexOf(gk); if(j>=0) P.raidSpliced.splice(j,1); } try{ saveProfile(); }catch(_sp){} }
    netGiftSend(fr,{op:'give',id:m.id,k:go.k,ib:ib});
    say('Gave '+(ITEMS[go.k]?ITEMS[go.k].name:go.k)+' to '+nm+'.'); return 'gave';
  }
  if(m.op==='give'){
    gi=G.giftIn; if(!it||!gi||gi.id!==m.id) return 'stale';
    G.giftIn=null;
    where=openContainer({x:G.player.x,y:G.player.y,issuedB:m.ib?1:0},[key]);
    say('Took '+it.name+' from '+nm+'.'); if(where) sayWhenFree(where);
    return 'took';
  }
  if(m.op==='no'){ if(G.giftIn&&G.giftIn.id===m.id) G.giftIn=null; say(nm+' could not hand it over.'); return 'no'; }
  return 'bad';
}function netAidPass(s,by,key){
'@

SubRx @'
  if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netAidHold==='function') netAidHold();   // v16.84, his ask: T patches up a teammate in reach with your Bandage or Medkit, the pad Y; T was bound to nothing in a raid (H cycles the legend, X is the ring search)
'@ @'
  if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netGiftKey==='function'&&netGiftKey()){}   // v17.44: his pick 4, T offers the selected backpack item or takes an offer
  else if(code==='KeyT'&&G&&!G.over&&!G.paused&&!repeat&&NET.on&&typeof netAidHold==='function') netAidHold();   // v16.84, his ask: T patches up a teammate in reach with your Bandage or Medkit, the pad Y; T was bound to nothing in a raid (H cycles the legend, X is the ring search)
'@

SubRx @'
      var _yD=pressed(3)&&!bagNav;
'@ @'
      if(pressed(3)&&bagNav&&!PAD.prev[3]&&NET.on){ try{ netGiftKey(); }catch(_gk){} }   // v17.44: his pick 4, Y in the backpack offers the selected item
      var _yD=pressed(3)&&!bagNav;
'@

SubRx @'
      if(_yD&&!PAD.prev[3]){ var _yA=false; try{ _yA=!!(NET.on&&!G.over&&typeof netAidHold==='function'&&netAidHold(!!G.nearContainer)); }catch(_ye){} PAD.yAid=_yA; }
'@ @'
      if(_yD&&!PAD.prev[3]){ var _yA=false; if(G&&G.giftIn&&!G.bagOpen&&!G.giftIn.yes&&G.t-G.giftIn.t<=GIFT_T){ try{ _yA=!!netGiftKey(); }catch(_gy){} } else try{ _yA=!!(NET.on&&!G.over&&typeof netAidHold==='function'&&netAidHold(!!G.nearContainer)); }catch(_ye){} PAD.yAid=_yA; }
'@

SubRx @'
  if(m.t==='sc') return netScoreTake(peer,m);   // v17.39: a teammate score for the end card
'@ @'
  if(m.t==='sc') return netScoreTake(peer,m);   // v17.39: a teammate score for the end card
  if(m.t==='gift') return netGiftTake(peer,m);   // v17.44: his pick 4, an offer, a yes, a hand-over or a no
'@

SubRx @'
var VER='17.43';
'@ @'
var VER='17.44';
'@

$pat = "(?m)^  now:'v17\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.44: TRADING BETWEEN PLAYERS IN A RAID, his pick from the feature list. With the backpack open, T or Y offers the selected item to the nearest teammate, who takes it with T or Y within 12 seconds; it leaves the giver only when taken, lands with the taker (or at his feet), and nobody sees the other backpack. Check 17.44 fails on v17.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
