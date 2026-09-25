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

# IN A SAME MACHINE MODE, WORLD SOUND COMES FROM ONE WINDOW ONLY. Multiplayer, phase 1, build 5 (tools/multiplayer/plan.md
# section E with the corrections in critique.md), his order of 2026-09-25: two players on the SAME PC in two game windows on
# two screens. Both windows played the Undercroft ambience, the music, the footsteps and the blips through the same speakers
# a few milliseconds apart, so everything was heard twice. Now one master gain sits between everything the game plays and
# the speakers in a same machine mode, and a SOUND row in the PARTY window switches it for each window.
# 1. VER 15.77 to 15.78.
# 2. The three nodes that reach the destination (BUS, the reverb wet return, the music lowpass) connect to netSndOut(a):
#    the master gain in a same machine mode, a.destination otherwise, so outside the modes no node is added.
# 3. NET gains sndOn, sndOther, sndG, sndAc; netSameStop puts the gain back to 1 and forgets the other window word.
# 4. The switch is read and told at the host pick and the player 2 boot, and told again when player 2 says ready.
# 5. netSameOnMsg reads the sound word, snd.
# 6. The sound section: netSndOut, netSndRoute, netSndApply, netSndLoad, netSndSet, netSndToggle, netSndInit, netSndRelease,
#    the labels and netSndView.
# 7. The PARTY window: the SOUND row, drawn by renderParty and wired in the window IIFE; the player 2 title line.
# 8. The test handle: snd() and sndSet(on), for tools/nettest.html.
# Solo play and the invite code party are untouched: netSndOut returns the destination unless NET.same is set.

SubRx @'
var VER='15.77';
'@ @'
var VER='15.78';
'@

SubRx @'
    BUS.connect(a.destination);
'@ @'
    BUS.connect(netSndOut(a));   // v15.78: through the master gain in a same machine mode (the net section); the destination otherwise
'@

SubRx @'
  wet.connect(a.destination);
'@ @'
  wet.connect(netSndOut(a));   // v15.78: as BUS: the master gain in a same machine mode, the destination otherwise
'@

SubRx @'
    MUS.g.connect(MUS.lp); MUS.lp.connect(a.destination);
'@ @'
    MUS.g.connect(MUS.lp); MUS.lp.connect(netSndOut(a));   // v15.78: as BUS: the master gain in a same machine mode, the destination otherwise
'@

SubRx @'
  padIx:-1,padOther:-1,padFwd:null,padSent:0,padGot:0};   // v15.77: this window's controller pick, the other window's, and the state it handed over
'@ @'
  padIx:-1,padOther:-1,padFwd:null,padSent:0,padGot:0,   // v15.77: this window's controller pick, the other window's, and the state it handed over
  sndOn:true,sndOther:-1,sndG:null,sndAc:null};   // v15.78: this window's sound switch, the other window's word (-1 not said), and the master gain
'@

SubRx @'
  NET.padFwd=null; NET.padOther=-1;   // v15.77: the handed-over state and the other window's pick go with the channel; this window's own pick stays
'@ @'
  NET.padFwd=null; NET.padOther=-1;   // v15.77: the handed-over state and the other window's pick go with the channel; this window's own pick stays
  netSndRelease();   // v15.78: the master gain goes back to 1 and the other window's word is forgotten; this window's own switch stays
'@

SubRx @'
  netPadInit();   // v15.77: this window's controller pick, kept from last time, and told to the player 2 window
'@ @'
  netPadInit();   // v15.77: this window's controller pick, kept from last time, and told to the player 2 window
  netSndInit();   // v15.78: this window's sound switch, kept from last time (the host defaults to on), applied and told to the player 2 window
'@

SubRx @'
  netPadInit();   // v15.77: the player 2 controller pick, kept from last time, told to the player 1 window; ready stays the last word of the boot
'@ @'
  netPadInit();   // v15.77: the player 2 controller pick, kept from last time, told to the player 1 window; ready stays the last word of the boot
  netSndInit();   // v15.78: the player 2 sound switch, kept from last time (player 2 defaults to off), told to the player 1 window before ready
'@

SubRx @'
  if(m.t==='padpick'){ NET.padOther=netPadIxOk(m.ix); return 'padpick'; }
'@ @'
  if(m.t==='padpick'){ NET.padOther=netPadIxOk(m.ix); return 'padpick'; }
  if(m.t==='snd'){ NET.sndOther=(m.on===1||m.on===true)?1:0; netRefresh(); return 'snd'; }   // v15.78: the other window says whether its sound is on
'@

SubRx @'
      netPadPost();   // v15.77: a player 2 window that just booted, or reloaded, is told this window's controller pick
'@ @'
      netPadPost();   // v15.77: a player 2 window that just booted, or reloaded, is told this window's controller pick
      netSndPost();   // v15.78: and whether this window's sound is on
'@

SubRx @'
  if(pl){ pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. Your controller works here whether this window is in front or not. MODE: '+netModeName(NET.mode)+'.'; pl.style.display=''; }   // v15.77: the controller sentence
'@ @'
  if(pl){ pl.textContent='PLAYER 2. This window links up with the player 1 window on its own. Drag it to your second screen. Your controller works here whether this window is in front or not. World sound plays from the player 1 window; the SOUND row in the PARTY window switches it. MODE: '+netModeName(NET.mode)+'.'; pl.style.display=''; }   // v15.77: the controller sentence; v15.78: the sound sentence
'@

SubRx @'
// THE PARTY WINDOW.
'@ @'
// v15.78, HIS ORDER OF 2026-09-25: MULTIPLAYER, BUILD 5 OF PHASE 1. IN A SAME MACHINE MODE, WORLD SOUND COMES FROM ONE WINDOW ONLY.
//   THE PROBLEM. Two windows of the game on one PC both play the Undercroft ambience, the music, the footsteps and the blips
//   through the same speakers, a few milliseconds apart, so everything is heard twice with a smear on it.
//   THE MUTE. One master gain, NET.sndG, between everything the game plays and the speakers. The three nodes that reach the
//   destination (BUS, which carries every sound in the world and feeds the room reverb; the reverb's wet return; the music's
//   lowpass) connect to netSndOut(a) instead: that gain in a same machine mode, made on first use, and a.destination
//   otherwise, so outside the modes the chain is what it was, with no node added. A window switched off sets the gain to 0
//   and nothing else: every oscillator, buffer and schedule keeps running behind it and the context clock keeps counting, so
//   switching back on is instant and in step with the other window. Never AC.suspend: a suspended context stops its clock,
//   and the music would come back mid-bar and out of step. The host plays frames on the title before the pick, so its three
//   nodes may already sit on the destination; netSndRoute moves them behind the gain once, at the pick. The player 2 window
//   sets its mode at boot, before any node exists. The menu blips go through it too: a menu click plays the same pick voice
//   a pickup does, through BUS, so there is no clean way to leave the blips audible in a window switched off; it is silent.
//   THE SWITCH. THIS WINDOW: SOUND ON or SOUND OFF, a row in the PARTY window shown in a same machine mode only. The host
//   defaults to on and the player 2 window to off; the choice is kept under salvagerun:samesound:host or :p2 for next time
//   and told to the other window ({t:'snd'}) at the pick, at the player 2 boot, again on ready and on every change, so each
//   window can say what the other does. END THE PARTY puts the gain back to 1 and forgets the other window's word; the node
//   stays, at 1, which changes nothing.
// SOLO PLAY AND THE INVITE CODE PARTY ARE UNTOUCHED: netSndOut returns a.destination while NET.same is unset, nothing new is
// read, and nothing here draws from the seeded stream (rr, rnd, ri, pick, rollTable) or reads G.
function netSndKey(side){ return 'salvagerun:samesound:'+((side==='p2')?'p2':'host'); }
function netSndDefault(side){ return side!=='p2'; }
// The node the world connects to: the master gain in a same machine mode, made once per context; else the destination.
function netSndOut(a){
  if(!a) return null;
  if(!NET.same) return a.destination;
  if(!NET.sndG||NET.sndAc!==a){
    try{ NET.sndG=a.createGain(); NET.sndG.gain.value=NET.sndOn?1:0; NET.sndG.connect(a.destination); NET.sndAc=a; }
    catch(e){ NET.sndG=null; NET.sndAc=null; return a.destination; }
  }
  return NET.sndG;
}
function netSndApply(){ if(NET.sndG){ try{ NET.sndG.gain.value=NET.sndOn?1:0; }catch(e){} } return NET.sndOn; }
// The nodes that reach the destination move behind the master gain, once each. Returns how many moved.
function netSndRoute(){
  var a=(AC&&AC.destination)?AC:null, g, list, i, n, moved=0;
  if(!a||!NET.same) return 0;
  g=netSndOut(a);
  if(!g||g===a.destination) return 0;
  list=[BUS||null,(REV&&REV.wet)||null,(MUS&&MUS.lp)||null];
  for(i=0;i<list.length;i++){
    n=list[i]; if(!n||n===g||n.__sndOut===g) continue;
    try{ n.disconnect(a.destination); }catch(e){}
    try{ n.connect(g); n.__sndOut=g; moved++; }catch(e2){}
  }
  return moved;
}
// THE SWITCH: kept for next time under this side's key, applied at once, and told to the other window.
function netSndLoad(){
  var v=null;
  try{ v=localStorage.getItem(netSndKey(NET.same)); }catch(e){ v=null; }
  NET.sndOn=(v==='1')?true:((v==='0')?false:netSndDefault(NET.same));
  return NET.sndOn;
}
function netSndPost(){ return netSamePost({t:'snd',pair:NET.pair,on:NET.sndOn?1:0}); }
function netSndSet(on){
  NET.sndOn=!!on;
  try{ localStorage.setItem(netSndKey(NET.same),NET.sndOn?'1':'0'); }catch(e){}
  netSndApply();
  netSndPost();
  netRefresh();
  return NET.sndOn;
}
function netSndToggle(){ return netSndSet(!NET.sndOn); }
function netSndInit(){ netSndLoad(); NET.sndOther=-1; netSndRoute(); netSndApply(); netSndPost(); return NET.sndOn; }
function netSndRelease(){ NET.sndOther=-1; if(NET.sndG){ try{ NET.sndG.gain.value=1; }catch(e){} } return true; }
function netSndLabel(on){ return on?'SOUND ON':'SOUND OFF'; }
function netSndOtherLabel(){ return (NET.sndOther===1)?'sound on':((NET.sndOther===0)?'sound off':'not said yet'); }
// What a test page reads: the switch, the other window's word, and the master gain as the game holds it.
function netSndView(){
  var v=null;
  try{ v=localStorage.getItem(netSndKey(NET.same)); }catch(e){ v=null; }
  return {on:NET.sndOn,other:NET.sndOther,gain:(NET.sndG&&NET.sndG.gain)?NET.sndG.gain.value:null,routed:!!NET.sndG,ctx:!!AC,state:(AC&&AC.state)||'',kept:v};
}
// THE PARTY WINDOW.
'@

SubRx @'
    <span id="partypadnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
'@ @'
    <span id="partypadnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
  <!-- v15.78: in a same machine mode world sound comes from one window only; this row switches this window. No word here
       that controller B looks for (leave, close, back, done, return). -->
  <div class="msub" id="partysnd" style="display:none">
    <button id="partysndbtn" style="padding:6px 16px">THIS WINDOW: SOUND ON</button>
    <span id="partysndnote" style="margin-left:10px;color:var(--ash)"></span>
  </div>
'@

SubRx @'
  if(pr){ pr.style.display=NET.same?'':'none'; if(NET.same){ if(pb) pb.textContent='THIS WINDOW: '+netPadLabel(NET.padIx,NET.same); if(pn) pn.textContent='Press to change. The other window is on '+netPadLabel(NET.padOther,(NET.same==='host')?'p2':'host').toLowerCase()+'. Each window keeps its own controller, in front or not.'; } }
'@ @'
  if(pr){ pr.style.display=NET.same?'':'none'; if(NET.same){ if(pb) pb.textContent='THIS WINDOW: '+netPadLabel(NET.padIx,NET.same); if(pn) pn.textContent='Press to change. The other window is on '+netPadLabel(NET.padOther,(NET.same==='host')?'p2':'host').toLowerCase()+'. Each window keeps its own controller, in front or not.'; } }
  // v15.78: whether this window plays the world sound, in a same machine mode; what the other window said beside it.
  var sr=g('partysnd'), sb2=g('partysndbtn'), sn=g('partysndnote');
  if(sr){ sr.style.display=NET.same?'':'none'; if(NET.same){ if(sb2) sb2.textContent='THIS WINDOW: '+netSndLabel(NET.sndOn); if(sn) sn.textContent='Press to change. The other window: '+netSndOtherLabel()+'. Two windows on one PC play the same world sound twice, so one of them is switched off. A window switched off keeps every sound running and comes straight back when switched on.'; } }
'@

SubRx @'
  if(g('partypadbtn')) g('partypadbtn').onclick=function(){ netPadCycle(); };   // v15.77: the CONTROLLER row
'@ @'
  if(g('partypadbtn')) g('partypadbtn').onclick=function(){ netPadCycle(); };   // v15.77: the CONTROLLER row
  if(g('partysndbtn')) g('partysndbtn').onclick=function(){ netSndToggle(); };   // v15.78: the SOUND row
'@

SubRx @'
      padSet:function(ix){ return netPadSet(ix); }};
'@ @'
      padSet:function(ix){ return netPadSet(ix); },
      // v15.78: whether this window plays the world sound, what the other window said, and the master gain as the game holds it.
      snd:function(){ return netSndView(); },
      sndSet:function(on){ return netSndSet(!!on); }};
'@

$pat = "(?m)^  now:'v15\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.78: IN A SAME MACHINE MODE, WORLD SOUND COMES FROM ONE WINDOW ONLY. Multiplayer build 5. Two windows of the game on one PC both played the Undercroft ambience, the music, the footsteps and the blips through the same speakers a few milliseconds apart, so everything was heard twice. Now one master gain sits between everything the game plays and the speakers in a same machine mode, and a SOUND row in the PARTY window switches it for each window: the player 1 window defaults to SOUND ON and the player 2 window to SOUND OFF, the choice is kept for next time, and each window is told what the other does. A window switched off keeps every sound and schedule running behind the gain, so switching it on is instant and in step; the audio context is never suspended for it. The menu blips go through the same gain, so a window switched off is silent. Solo play and the invite code party are untouched: no node is added outside the same machine modes, nothing new is read, and the seed 4242 fingerprint has no way to move. Check 15.78 fails on v15.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
