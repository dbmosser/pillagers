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

# EACH WINDOW ON ONE PC GETS A CONTROLLER OF ITS OWN. Multiplayer, phase 1, build 4 (tools/multiplayer/plan.md section E with
# the corrections in critique.md), his order of 2026-09-25: two players on the SAME PC in two game windows on two screens,
# player 2 on a controller. A browser hands the keyboard, the mouse and (in Chrome) the controllers to the window in front
# only, so the second window had no controller while the first was in front. Now the window in front reads every connected
# pad each frame and hands the other window the state of its pad over the channel between windows (v15.76); the window not
# in front plays that state in place of its own read.
# 1. VER 15.76 to 15.77.
# 2. pollPad: in a same machine mode the pad comes from netPadTick; otherwise the first connected pad, as ever.
# 3. NET gains padIx, padOther, padFwd, padSent, padGot; netSameStop lets go of the handed state and the other pick.
# 4. The pick is read and told at the host pick and the player 2 boot, and told again when player 2 says ready.
# 5. netSameOnMsg reads the two controller words, pad and padpick.
# 6. The controller section: netPadFor, netPadWant, netPadSend, netPadRecv, netPadTick, the pick and the row label.
# 7. The PARTY window: the CONTROLLER row, drawn by renderParty and wired in the window IIFE; the player 2 title line.
# 8. The test handle: pad() and padSet(ix), for tools/nettest.html.
# Solo play and the invite code party are untouched: pollPad asks nothing new unless NET.same is set.

SubRx @'
var VER='15.76';
'@ @'
var VER='15.77';
'@

SubRx @'
  var gps=navigator.getGamepads(),gp=null;
  for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
'@ @'
  var gps=navigator.getGamepads(),gp=null;
  // v15.77, HIS ORDER OF 2026-09-25 (multiplayer, build 4): EACH WINDOW ON ONE PC PLAYS A CONTROLLER OF ITS OWN. In a same
  // machine mode the pad this window plays comes from netPadTick (the net section): in front, its own pick out of every
  // connected pad, while it hands the other window the state of that window's pad; not in front, the state the window in
  // front handed over. Outside those modes the first connected pad, as ever, and nothing below this line is asked.
  if(typeof NET!=='undefined'&&NET&&NET.same) gp=netPadTick(gps);
  else for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
'@

SubRx @'
  mode:'',pick:'',same:'',pair:'',bc:null,p2win:null,p2url:'',sameBusy:false,start:null};   // v15.76: the mode, and the two windows on one PC
'@ @'
  mode:'',pick:'',same:'',pair:'',bc:null,p2win:null,p2url:'',sameBusy:false,start:null,   // v15.76: the mode, and the two windows on one PC
  padIx:-1,padOther:-1,padFwd:null,padSent:0,padGot:0};   // v15.77: this window's controller pick, the other window's, and the state it handed over
'@

SubRx @'
  NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.p2win=null; NET.sameBusy=false;
'@ @'
  NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; NET.p2win=null; NET.sameBusy=false;
  NET.padFwd=null; NET.padOther=-1;   // v15.77: the handed-over state and the other window's pick go with the channel; this window's own pick stays
'@

SubRx @'
  netSameChan();
  netSameHostLink();
'@ @'
  netSameChan();
  netPadInit();   // v15.77: this window's controller pick, kept from last time, and told to the player 2 window
  netSameHostLink();
'@

SubRx @'
  netSamePost({t:'ready',pair:NET.pair});
  return 'ready';
'@ @'
  netPadInit();   // v15.77: the player 2 controller pick, kept from last time, told to the player 1 window; ready stays the last word of the boot
  netSamePost({t:'ready',pair:NET.pair});
  return 'ready';
'@

SubRx @'
  if(!NET.same||!NET.pair||m.pair!==NET.pair) return 'ignored';
  if(NET.same==='host'){
'@ @'
  if(!NET.same||!NET.pair||m.pair!==NET.pair) return 'ignored';
  // v15.77: the two controller words, read on either side: a pad state handed over by the window in front, and a pick.
  if(m.t==='pad') return netPadRecv(m);
  if(m.t==='padpick'){ NET.padOther=netPadIxOk(m.ix); return 'padpick'; }
  if(NET.same==='host'){
'@

SubRx @'
    if(m.t==='ready'){
'@ @'
    if(m.t==='ready'){
      netPadPost();   // v15.77: a player 2 window that just booted, or reloaded, is told this window's controller pick
'@

SubRx @'
  if(pl){ pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. MODE: '+netModeName(NET.mode)+'.'; pl.style.display=''; }
'@ @'
  if(pl){ pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. Your controller works here whether this window is in front or not. MODE: '+netModeName(NET.mode)+'.'; pl.style.display=''; }   // v15.77: the controller sentence
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.77, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 4 OF PHASE 1. EACH WINDOW ON ONE PC GETS A CONTROLLER OF ITS OWN.
//   THE PROBLEM. A browser hands the keyboard, the mouse and (in Chrome) the controllers to the window in front only: in a
//   window that is not in front navigator.getGamepads returns nothing, or a state that never moves. Player 1 plays the window
//   in front on the keyboard and mouse, or on a pad; player 2 sits at the second window with a controller, and that window
//   is not in front. So the window in front reads every connected pad each frame and hands the other window the state of
//   that window's pad over the channel the two windows already share (netSamePost, a word {t:'pad'}), about sixty times a
//   second while that pad is plugged in. The window not in front plays the handed-over state in place of its own read; in
//   front, it plays its own pad. The channel between windows carries it and not the data channel of the link: the channel is
//   open from the pick and from the player 2 boot (so the pad works on the player 2 title, before the two are linked), it
//   survives END THE PARTY on the player 2 side, and on one PC it is a message between two windows of one browser, well
//   under a millisecond, where the data channel goes out through the network stack and back.
//   WHOSE PAD IS WHOSE. Each window has a pick (NET.padIx; -1 is none picked; the CONTROLLER row in the PARTY window changes
//   it, and it is kept under salvagerun:samepad:host or :p2 for next time). The host plays the keyboard and mouse unless it
//   picked a pad. Player 2 plays the pad it picked, or, with none picked, the first connected pad the host has not taken. A
//   pick both windows made goes to the host. Each window tells the other its pick ({t:'padpick'}), and every handed-over
//   state names the pad it came from and the sender's own pick, so a state from the other window's own pad, or from a pad
//   this window did not pick, is never played: player 1's pad never moves player 2 and player 2's never moves player 1. A
//   handed-over state older than NET_PAD_STALE is dropped, so an unplugged pad, or a window that stopped handing over, lets go.
// SOLO PLAY AND THE INVITE CODE PARTY ARE UNTOUCHED. pollPad asks netPadTick only while NET.same is set (a same machine mode);
// otherwise it reads the first connected pad as it always did, asks nothing about focus and hands nothing over. Nothing here
// draws from the seeded stream (rr, rnd, ri, pick, rollTable) or reads G.
var NET_PAD_STALE=0.25, NET_PAD_MAX=4;
function netPadNow(){ return ((typeof performance!=='undefined'&&performance&&performance.now)?performance.now():Date.now())/1000; }
function netPadFocused(){ try{ return (typeof document!=='undefined'&&document&&typeof document.hasFocus==='function')?!!document.hasFocus():true; }catch(e){ return true; } }
function netPadIxOk(v){ return (typeof v==='number'&&v===(v|0)&&v>=0&&v<NET_PAD_MAX)?v:-1; }
function netPadKey(side){ return 'salvagerun:samepad:'+((side==='p2')?'p2':'host'); }
// The pad index a side plays on, from its own pick, the other side's pick and the pads connected: -1 for none. The host
// plays only a pad it picked; player 2 plays its pick unless the host picked the same, else the first free pad.
function netPadFor(side,pick,taken,gps){
  var i, n=(gps&&gps.length)||0;
  pick=netPadIxOk(pick); taken=netPadIxOk(taken);
  if(side!=='p2') return (pick>=0&&pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
  if(pick>=0&&pick!==taken) return (pick<n&&gps[pick]&&gps[pick].connected)?pick:-1;
  for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
  return -1;
}
// The pad this window will take from the window in front: its pick; for player 2 with no pick (or a pick the host holds)
// any pad but the sender's own (-2); for the host with no pick, none (-1).
function netPadWant(){
  if(NET.same==='host') return netPadIxOk(NET.padIx);
  if(NET.same==='p2') return (netPadIxOk(NET.padIx)>=0&&NET.padIx!==NET.padOther)?NET.padIx:-2;
  return -1;
}
// THE PICK: kept for next time under this side's key, and told to the other window.
function netPadLoad(){
  var v=null;
  try{ v=localStorage.getItem(netPadKey(NET.same)); }catch(e){ v=null; }
  NET.padIx=(v===null||v===undefined||v==='')?-1:netPadIxOk(parseInt(v,10));
  return NET.padIx;
}
function netPadPost(){ return netSamePost({t:'padpick',pair:NET.pair,ix:NET.padIx}); }
function netPadSet(ix){
  NET.padIx=netPadIxOk(ix);
  try{ if(NET.padIx>=0) localStorage.setItem(netPadKey(NET.same),String(NET.padIx)); else localStorage.removeItem(netPadKey(NET.same)); }catch(e){}
  netPadPost();
  netRefresh();
  return NET.padIx;
}
function netPadInit(){ netPadLoad(); NET.padOther=-1; NET.padFwd=null; netPadPost(); return NET.padIx; }
// The CONTROLLER row: none, then controller 1 to 4, then none again.
function netPadCycle(){ return netPadSet((NET.padIx>=NET_PAD_MAX-1)?-1:(NET.padIx+1)); }
function netPadLabel(ix,side){
  ix=netPadIxOk(ix);
  if(ix>=0) return 'CONTROLLER '+(ix+1);
  return (side==='p2')?'THE FIRST FREE CONTROLLER':'NO CONTROLLER, KEYBOARD AND MOUSE';
}
// One pad's state, handed to the other window: which pad, this window's own pick, the buttons (down, and how far) and the
// sticks. Returns whether it went out.
function netPadSend(g,ix){
  var p=[], v=[], a=[], i, b, bt=(g&&g.buttons)||[], ax=(g&&g.axes)||[];
  for(i=0;i<bt.length&&i<32;i++){ b=bt[i]; p.push((b&&(b.pressed||b.value>0.5))?1:0); v.push(b?(Math.round(((b.value!==undefined)?+b.value:(b.pressed?1:0))*100)/100):0); }
  for(i=0;i<ax.length&&i<8;i++) a.push(Math.round((+ax[i]||0)*1000)/1000);
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,p:p,v:v,a:a})) return false;
  NET.padSent++;
  return true;
}
// A state handed over by the window in front. Kept only if it is the pad this window plays on, and never the sender's own.
// Returns what it did, so a check can read the answer.
function netPadRecv(m){
  var ix=netPadIxOk(m.ix), own=netPadIxOk(m.own), want, i, n, v, bts=[], a=[];
  if(typeof m.own==='number') NET.padOther=own;
  want=netPadWant();
  if(ix<0){ NET.padFwd=null; return 'padnone'; }
  if(want===-1) return 'padnone';
  if(ix===own) return 'padown';
  if(want>=0&&ix!==want) return 'padnot';
  if(!m.p||!m.v||!m.a||typeof m.p.length!=='number'||m.p.length!==m.v.length||m.p.length>32||m.a.length>8) return 'bad';
  n=m.p.length;
  for(i=0;i<n;i++){ v=+m.v[i]; v=isFinite(v)?clamp(v,0,1):0; bts.push({pressed:!!m.p[i],value:v,touched:!!m.p[i]}); }
  for(i=0;i<m.a.length;i++){ v=+m.a[i]; a.push(isFinite(v)?clamp(v,-1,1):0); }
  NET.padFwd={ix:ix,at:netPadNow(),gp:{connected:true,index:ix,id:'controller handed over by the other window',mapping:'standard',timestamp:0,axes:a,buttons:bts}};
  NET.padGot++;
  return 'pad';
}
// Called by pollPad with what navigator.getGamepads gave, in a same machine mode only. In front: hands the other window its
// pad and returns this window's own, or null. Not in front: returns the state handed over while it is fresh, else null.
function netPadTick(gps){
  var focused=netPadFocused(), mine, other, fwd=NET.padFwd;
  gps=gps||[];
  if(focused){
    NET.padFwd=null;
    other=netPadFor((NET.same==='host')?'p2':'host',NET.padOther,NET.padIx,gps);
    if(other>=0) netPadSend(gps[other],other);
    mine=netPadFor(NET.same,NET.padIx,NET.padOther,gps);
    return (mine>=0)?gps[mine]:null;
  }
  if(fwd&&fwd.gp&&(netPadNow()-fwd.at)<=NET_PAD_STALE) return fwd.gp;
  return null;
}
// THE PARTY WINDOW.
'@

SubRx @'
  <div class="msub" id="partymode" style="display:none;color:var(--bone);letter-spacing:.14em"></div>
'@ @'
  <div class="msub" id="partymode" style="display:none;color:var(--bone);letter-spacing:.14em"></div>
  <!-- v15.77: in a same machine mode each window plays a controller of its own; this row picks it. No word here that
       controller B looks for (leave, close, back, done, return). -->
  <div class="msub" id="partypad" style="display:none">
    <button id="partypadbtn" style="padding:6px 16px">THIS WINDOW: NO CONTROLLER, KEYBOARD AND MOUSE</button>
    <span id="partypadnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
'@

SubRx @'
  var mo=g('partymode'); if(mo){ mo.textContent=NET.mode?('MODE: '+netModeName(NET.mode)):''; mo.style.display=NET.mode?'':'none'; }   // v15.76: the mode picked on the title
'@ @'
  var mo=g('partymode'); if(mo){ mo.textContent=NET.mode?('MODE: '+netModeName(NET.mode)):''; mo.style.display=NET.mode?'':'none'; }   // v15.76: the mode picked on the title
  // v15.77: the controller this window plays on, in a same machine mode; the other window's pick beside it.
  var pr=g('partypad'), pb=g('partypadbtn'), pn=g('partypadnote');
  if(pr){ pr.style.display=NET.same?'':'none'; if(NET.same){ if(pb) pb.textContent='THIS WINDOW: '+netPadLabel(NET.padIx,NET.same); if(pn) pn.textContent='Press to change. The other window is on '+netPadLabel(NET.padOther,(NET.same==='host')?'p2':'host').toLowerCase()+'. Each window keeps its own controller, in front or not.'; } }
'@

SubRx @'
  g('closeparty').onclick=function(){ blurIn(); g('partymodal').classList.remove('on'); };
'@ @'
  g('closeparty').onclick=function(){ blurIn(); g('partymodal').classList.remove('on'); };
  if(g('partypadbtn')) g('partypadbtn').onclick=function(){ netPadCycle(); };   // v15.77: the CONTROLLER row
'@

SubRx @'
      pick:function(mode){ return netSamePick(mode,function(){}); }};
'@ @'
      pick:function(mode){ return netSamePick(mode,function(){}); },
      // v15.77: the controller this window plays on, the state the other window handed over, and the buttons the reader holds down.
      pad:function(){ var d=[], i; for(i=0;i<((PAD&&PAD.prev)||[]).length;i++) if(PAD.prev[i]) d.push(i); return {on:!!(PAD&&PAD.on),ix:NET.padIx,other:NET.padOther,fwd:NET.padFwd?{ix:NET.padFwd.ix,age:Math.round((netPadNow()-NET.padFwd.at)*1000)}:null,down:d,sent:NET.padSent,got:NET.padGot,front:netPadFocused()}; },
      padSet:function(ix){ return netPadSet(ix); }};
'@

$pat = "(?m)^  now:'v15\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.77: EACH WINDOW ON ONE PC GETS A CONTROLLER OF ITS OWN. Multiplayer build 4. A browser hands the keyboard, the mouse and the controllers to the window in front only, so player 2 at the second window had no controller while player 1 played the first. Now the window in front reads every connected controller each frame and hands the other window the state of the controller that window plays, over the channel the two windows already share, about sixty times a second; the window not in front plays that state, and in front it plays its own. The host plays the keyboard and mouse unless it picks a controller; player 2 plays the controller it picks, or the first one the host has not taken. A CONTROLLER row in the PARTY window picks it for each window and the pick is kept for next time. Neither window ever plays the other one. Solo play and the invite code party are untouched: nothing is handed over, nothing new is read, and the seed 4242 fingerprint has no way to move. Check 15.77 fails on v15.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
