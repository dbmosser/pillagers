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

# PLAYER 1 AND PLAYER 2 SEE EACH OTHER IN THE UNDERCROFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.on) netHubTick(dt);

'@ @'
  if(NET.on) netHubTick(dt);
  try{ netMateTick(dt); }catch(_mt){}   // v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "players 1 and 2 should be able to see each other in the undercroft". The other window of the pair, over the pair channel.

'@

SubRx @'
  if(NET.on) netDrawPeers(DR);

'@ @'
  if(NET.on) netDrawPeers(DR);
  try{ netMatePeer(DR); }catch(_mp){}   // v30.xx (cw-p1p2): and the other window of the pair, when no linked party already draws him

'@

SubRx @'
  if(NET.on) netDrawTags(S,ox,oy);
'@ @'
  try{ netMateTag(S,ox,oy); }catch(_mg){}   // v30.xx (cw-p1p2): the name of the other window, over the darkness like the party names
  if(NET.on) netDrawTags(S,ox,oy);
'@

SubRx @'
  if(m.t.indexOf('arc')===0) return arcadeOnMsg(m);
'@ @'
  if(m.t==='hubmate'||m.t==='hubgone') return netMateIn(m);   // v30.xx (cw-p1p2): where the other window stands on the floor, or that he left it
  if(m.t.indexOf('arc')===0) return arcadeOnMsg(m);
'@

SubRx @'
  if(state!=='raid'||!G||G.sim) return;

'@ @'
  if(NETMATE.on){ try{ netMateLeave(); }catch(_ml){} }   // v30.xx (cw-p1p2): this window is no longer on the floor, so the other window loses the body he was drawing
  if(state!=='raid'||!G||G.sim) return;

'@

SubRx @'
// Where the others stand on this floor, for the test page handle.

'@ @'
// v30.xx (cw-p1p2), HIS ORDER (2026-10-18, from his first look at the two-window game): "players 1 and 2 should be able to see each other in
// the undercroft". The floor already drew the other player (netHubTick, netDrawPeer), but only over the WebRTC link, which comes up some seconds
// after the pick. The pair channel (the BroadcastChannel the two windows already talk on, netSamePost and netSameOnMsg, with the pair code on every
// word) is up at once, so the same body now also rides on it: each window posts hubmate a few times a second while it stands on the floor (where it
// stands, which way it faces, walking or rolling, its name, and its look every fifth word so a window that joins late is dressed within a second),
// hubgone once when it leaves the floor (a raid, or the title), and the other window draws the body with the same operator drawing the party uses,
// with its name over its head. A body not heard from for NET_MATE_STALE seconds goes by itself. When a linked party already shows him the pair body
// is not drawn a second time. Solo play posts nothing and draws nothing: NET.same is empty. No seeded stream is touched.
var NET_MATE_STEP=0.12, NET_MATE_STALE=2.5;
var NETMATE={g:null,pair:'',acc:0,on:0,n:0,lkSent:''};
function netMateLive(){
  var g=NETMATE.g;
  return !!g&&g.n>0&&g.age<NET_MATE_STALE&&!!NET.same&&!!NET.pair&&NETMATE.pair===NET.pair;
}
// A linked party draws him from the floor list; then the pair body would stand on him a second time.
function netMateShadowed(){
  var i;
  if(!NET.on) return false;
  for(i=0;i<NET.floor.length;i++) if(netShown(NET.floor[i])) return true;
  return false;
}
// His own name when he has one, else which player he is: the host window is player 1, the other is player 2.
function netMateName(g){
  var nm=netClean(g&&g.nm,16);
  if(!nm||/^pillager$/i.test(nm)) nm='Player '+(((g&&g.seat)|0)+1);
  return nm;
}
// A word from the other window. Returns what it did, so a check can read the answer.
function netMateIn(m){
  var g, x, y, f, lk;
  if(!NET.same||!NET.pair||!m||m.pair!==NET.pair) return 'ignored';
  if(m.t==='hubgone'){ NETMATE.g=null; return 'hubgone'; }
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  x=clamp(m.x,0,HUBW); y=clamp(m.y,0,HUBH);
  f=(typeof m.f==='number'&&isFinite(m.f)&&m.f>-100&&m.f<100)?m.f:0;
  f=f-6.2832*Math.floor(f/6.2832);
  lk=(m.lk!==undefined)?netLookClean(m.lk):null;
  g=NETMATE.g;
  if(!g||NETMATE.pair!==NET.pair){ g={seat:(NET.same==='host')?1:0,x:x,y:y,f:f,tx:x,ty:y,tf:f,mv:0,roll:0,bob:0,age:0,n:0,lk:null,nm:''}; NETMATE.g=g; NETMATE.pair=NET.pair; }
  else if(g.age>=NET_MATE_STALE||Math.sqrt((x-g.x)*(x-g.x)+(y-g.y)*(y-g.y))>NET_HUB_SNAP){ g.x=x; g.y=y; g.f=f; }
  g.tx=x; g.ty=y; g.tf=f; g.mv=m.m?1:0; g.roll=clamp(+m.r||0,0,0.38); g.age=0; g.n++; g.nm=netClean(m.nm,16);
  if(lk) g.lk=lk;
  return 'hubmate';
}
// This window is off the floor: say so once.
function netMateLeave(){
  if(NETMATE.on){ NETMATE.on=0; NETMATE.acc=0; if(NET.same&&NET.pair) netSamePost({t:'hubgone',pair:NET.pair}); }
  return 0;
}
// Every floor frame while the pair is on: eases the other body toward where he last said he stood, drops him when he is not heard from, and
// a few times a second posts where this player stands. Returns 1 when a word went out.
function netMateTick(dt){
  var g=NETMATE.g, k, dx, dy, da, sp, p, msg, lk, ls;
  if(!isFinite(dt)||dt<0) dt=0;
  if(g&&(!NET.same||!NET.pair||NETMATE.pair!==NET.pair||g.age>=NET_MATE_STALE)){ NETMATE.g=null; g=null; }
  if(g){
    g.age+=dt; k=1-Math.exp(-NET_HUB_EASE*dt);
    dx=(g.tx-g.x)*k; dy=(g.ty-g.y)*k;
    g.x+=dx; g.y+=dy;
    da=g.tf-g.f;
    if(da>Math.PI) da-=6.2832; else if(da<-Math.PI) da+=6.2832;
    g.f+=da*k; g.f=g.f-6.2832*Math.floor(g.f/6.2832);
    sp=(dt>0)?Math.sqrt(dx*dx+dy*dy)/dt:0;
    g.bob+=dt*(g.mv?((sp>200)?15:9):1.2);
    if(g.roll>0) g.roll=Math.max(0,g.roll-dt);
  }
  p=(typeof HB!=='undefined'&&HB)?HB.player:null;
  if(!NET.same||!NET.pair||!p||titleOn()){ if(NET.same&&NET.pair) netMateLeave(); else NETMATE.on=0; return 0; }
  NETMATE.acc+=dt;
  if(NETMATE.on&&NETMATE.acc<NET_MATE_STEP) return 0;
  NETMATE.acc=NETMATE.on?Math.min(NETMATE.acc-NET_MATE_STEP,NET_MATE_STEP):0;
  msg={t:'hubmate',pair:NET.pair,x:+(+p.x||0).toFixed(1),y:+(+p.y||0).toFixed(1),f:+(+p.face||0).toFixed(2),m:p.moving?1:0,r:(p.rollT>0)?+(+p.rollT).toFixed(2):0,nm:netClean(P&&P.pname,16)};
  lk=netLook(); ls=JSON.stringify(lk);
  if(!NETMATE.on||ls!==NETMATE.lkSent||NETMATE.n%5===0){ msg.lk=lk; NETMATE.lkSent=ls; }   // the first word after arriving on the floor always carries it: the other window drew nobody before
  NETMATE.n++; NETMATE.on=1;
  return netSamePost(msg)?1:0;
}
// The other window body goes into the y-sorted floor list; the list draws him with netDrawPeer.
function netMatePeer(DR){
  if(!DR||!netMateLive()||netMateShadowed()) return 0;
  DR.push({k:NETMATE.g.y,np:NETMATE.g});
  return 1;
}
// His name over his head: the same plate the party names use.
function netMateTag(S,ox,oy){
  var g=NETMATE.g, nm, tw;
  if(!netMateLive()||netMateShadowed()) return 0;
  nm=netMateName(g);
  wc.save();
  try{
    wc.scale(S,S); wc.translate(-ox,-oy);
    wc.textAlign='center'; wc.font=FS(TYPE.micro);
    tw=wc.measureText(nm).width;
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
    wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52);
  }catch(e){}
  wc.textAlign='left';
  wc.restore();
  return 1;
}
// Where the others stand on this floor, for the test page handle.

'@

SubRx @'
var VER='30.83';
'@ @'
var VER='30.84';
'@

$pat = "(?m)^  now:'v30\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.84: The other player now appears in the Undercroft as soon as both windows are on the floor, walking and standing where they are, with a name over the head, and disappears when that window leaves the floor. Check 30.84 fails on v30.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
