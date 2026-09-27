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

# HIS CONTROLLER LAYOUT, BOTH PLAYERS (his order 2026-09-27, during his co-op session).

SubRx @'
var PADTAP={
  1:'Space',      // B      dodge roll
  // Y is reload now and lives in PADHOLD; swapping guns is what the bumpers are for.
  // 4 and 5, the bumpers, are handled as belt selection in pollPad rather than as key
  // taps, because there is no key that means "previous slot".
  8:'KeyI',       // View   backpack. v13.44: TAB pauses and backs out now, so View taps I
  9:'KeyP',       // Menu   pause
  // v7.87: 12 (dpad up) removed - it fought the v6.41 map toggle on the same
  // press and ate bag browsing. Merc orders stay on the keyboard, on O since v13.45.
  14:'KeyZ',      // Dpad left   drop selected
  15:'KeyG',      // Dpad right  use the selected belt slot (was autoloot, v6.79)
'@ @'
var PADTAP={
  // v16.72, HIS ORDER 2026-09-27, THE SAME FOR BOTH PLAYERS: A rolls; B crouches (a toggle, and rolling or sprinting stands
  // you up, as on the keyboard); RT fires or uses what is selected, as a mouse click does (read as a trigger in pollPad);
  // LT is focus aim, the right mouse button; D-LEFT and D-RIGHT set the aim distance (was LT and RT); RS click is the second
  // search inside an extraction circle, keyboard X. D-LEFT no longer drops and D-RIGHT no longer uses: RT uses.
  0:'Space',      // A      dodge roll
  1:'ControlLeft',// B      crouch, one change per press
  // Y is reload now and lives in PADHOLD; swapping guns is what the bumpers are for.
  // 4 and 5, the bumpers, are handled as belt selection in pollPad rather than as key
  // taps, because there is no key that means "previous slot".
  8:'KeyI',       // View   backpack. v13.44: TAB pauses and backs out now, so View taps I
  9:'KeyP'        // Menu   pause
  // v7.87: 12 (dpad up) removed - it fought the v6.41 map toggle on the same
  // press and ate bag browsing. Merc orders stay on the keyboard, on O since v13.45.
'@

SubRx @'
  11:'ControlLeft'// RS click    crouch, one change per click
};
'@ @'
};
'@

SubRx @'
var PADLABEL={KeyE:'X',KeyR:'Y',KeyF:'D-DOWN',KeyT:'RB',KeyG:'D-RIGHT',KeyQ:'LB',
              Space:'B',Tab:'BACK',KeyP:'MENU',KeyZ:'D-LEFT',
              ShiftLeft:'LS',ControlLeft:'RS',KeyM:'D-UP',KeyI:'VIEW'};
'@ @'
var PADLABEL={KeyE:'X',KeyR:'X',KeyF:'D-DOWN',KeyT:'RB',KeyG:'RT',KeyQ:'LB',
              Space:'A',Tab:'BACK',KeyP:'MENU',KeyX:'Y',
              ShiftLeft:'LS',ControlLeft:'B',KeyM:'D-UP',KeyI:'VIEW'};
'@

SubRx @'
  var _out=trig(7), _in=trig(6);
'@ @'
  var _out=(pressed(15)&&!G.bagOpen)?1:0, _in=(pressed(14)&&!G.bagOpen)?1:0;   // v16.72, his order: aim distance is on D-LEFT and D-RIGHT
'@

SubRx @'
  var rtOn=!PAD.aSpent&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&pressed(0);
'@ @'
  var rtOn=!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&trig(7)>0.35;   // v16.72, his order: RT fires or uses the selected item, as a mouse click does
'@

SubRx @'
  if(PAD.adsT>0){ G.player.ads=true; PAD.adsing=1; }
'@ @'
  if(pressed(11)&&!PAD.prev[11]&&!G.over&&!G.paused) PAD.adsTog=!PAD.adsTog;   // v16.72, his order: RS click toggles focus aim
  if(G.over) PAD.adsTog=false;
  if(PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused)){ G.player.ads=true; PAD.adsing=1; }   // v16.72, his order: LT held or RS toggled is focus aim
'@

SubRx @'
    if(hn===2){ padHold(_xSearch?'KeyE':'KeyX',false); padHold(_xSearch?'KeyX':'KeyE',_xDown); continue; }
'@ @'
    // v16.72, his order: X loots (E) when there is something in reach to search, pick up, open or call extraction from, and
    // reloads (R) otherwise; the choice is made on the press and kept for the hold, so a search that ends never turns into a
    // reload. Y holds keyboard X, the second search inside an extraction circle (bodies at the ring).
    if(hn===2){
      if(_xDown&&!PAD.xWas){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||_xm)?'KeyE':'KeyR'; }
      PAD.xWas=_xDown;
      padHold('KeyR',_xDown&&PAD.xMode==='KeyR');
      padHold('KeyE',_xDown&&PAD.xMode==='KeyE'&&!_xSearch);   // in a ring with a box at his feet X still searches first (v13.48), below
      continue;
    }
    if(hn===3){ padHold('KeyX',(pressed(3)&&!bagNav)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch)); continue; }
'@

SubRx @'
    if(now&&!PAD.prev[n]&&n===1&&!G.over&&(G.mapOpen||G.bagOpen||G.emoteBar)&&backOut()){ keys['Space']=false; }
    else if(now&&!PAD.prev[n]){ raidKey(PADTAP[n],false,null); keys[PADTAP[n]]=false; }
'@ @'
    if(now&&!PAD.prev[n]&&n===1&&!G.over&&(G.mapOpen||G.bagOpen||G.emoteBar)&&backOut()){ keys['ControlLeft']=false; }
    else if(now&&!PAD.prev[n]&&n===0&&(PAD.aSpent||G.bagOpen||G.mapOpen)){}   // v16.72: A rolls, but not under the open backpack or map, nor the A that pressed a menu button
    else if(now&&!PAD.prev[n]){ raidKey(PADTAP[n],false,null); keys[PADTAP[n]]=false; }
'@

SubRx @'
  padHold('Space',pressed(1)&&!G.over&&!!(G.player&&G.player.downed));
'@ @'
  padHold('Space',pressed(0)&&!G.over&&!!(G.player&&G.player.downed));   // v16.72: the roll is on A now, so the surrender hold is too
'@

SubRx @'
  ['MOVE',[['L STICK','move, analog'],['LS CLICK','sprint'],['RS CLICK','crouch'],['B','dodge roll']]],
  ['FIGHT',[['R STICK','aim'],['A','fire'],['LT / RT','reach, analog'],['Y','reload']]],
  ['GEAR',[['LB/RB','change tactical belt slot'],['D-RIGHT','use selected'],['D-LEFT','drop selected'],['D-DOWN','revive when down'],['VIEW','backpack']]],
  ['WORLD',[['X','search / call for extraction'],['DPAD UP','ping (twice: danger); hold: map'],['MENU','pause']]]
'@ @'
  ['MOVE',[['L STICK','move, analog'],['LS CLICK','sprint'],['B','crouch'],['A','dodge roll']]],
  ['FIGHT',[['R STICK','aim'],['RT','fire / use selected'],['LT / RS CLICK','focus aim, hold / toggle'],['D-LEFT/RIGHT','aim distance'],['X','reload']]],
  ['GEAR',[['LB/RB tap','change tactical belt slot'],['LB/RB hold','zoom out / in'],['D-DOWN','revive when down'],['VIEW','backpack']]],
  ['WORLD',[['X','search / open / call for extraction'],['Y','search in a ring'],['DPAD UP','ping (twice: danger); hold: map'],['MENU','pause']]]
'@

SubRx @'
  var _lbN=pressed(4), _rbN=pressed(5);
  if(G&&!G.over&&!G.paused){
    var _slN=hotbarSlots().length;
    if(_slN>0){
      if(_lbN&&!PAD.prev[4]) setHot((hotSel()-1+_slN)%_slN);
      if(_rbN&&!PAD.prev[5]) setHot((hotSel()+1)%_slN);
    }
  }
'@ @'
  // v16.72, his order: HOLD RB ZOOMS IN, HOLD LB ZOOMS OUT. A tap (let go inside 0.25 s) still walks the tactical belt, so
  // the belt keeps a home on the pad; a hold past 0.25 s zooms for as long as it is held, the way the wheel does, and never
  // changes the slot.
  var _lbN=pressed(4), _rbN=pressed(5), _bnow=netPadNow(), _bdt=Math.min(0.05,Math.max(0,_bnow-(PAD.bT||_bnow)));
  PAD.bT=_bnow;
  if(G&&!G.over&&!G.paused){
    var _slN=hotbarSlots().length;
    if(_lbN&&!PAD.prev[4]){ PAD.lbAt=_bnow; PAD.lbHeld=0; }
    if(_rbN&&!PAD.prev[5]){ PAD.rbAt=_bnow; PAD.rbHeld=0; }
    if(_lbN&&PAD.lbAt!=null&&_bnow-PAD.lbAt>=0.25){ PAD.lbHeld=1; if(typeof setZoom==='function') setZoom(zoomTarget()/Math.exp(1.1*_bdt)); }
    if(_rbN&&PAD.rbAt!=null&&_bnow-PAD.rbAt>=0.25){ PAD.rbHeld=1; if(typeof setZoom==='function') setZoom(zoomTarget()*Math.exp(1.1*_bdt)); }
    if(_slN>0){
      if(!_lbN&&PAD.prev[4]&&!PAD.lbHeld) setHot((hotSel()-1+_slN)%_slN);
      if(!_rbN&&PAD.prev[5]&&!PAD.rbHeld) setHot((hotSel()+1)%_slN);
    }
  }
  if(!_lbN) PAD.lbAt=null;
  if(!_rbN) PAD.rbAt=null;
'@

SubRx @'
var VER='16.71';
'@ @'
var VER='16.72';
'@

$pat = "(?m)^  now:'v16\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.72: HIS CONTROLLER LAYOUT, FOR BOTH PLAYERS. His order during his co-op session: A rolls, B crouches (a toggle; rolling or sprinting stands you up), RT fires or uses the selected item as a mouse click does, LT held or RS click toggled is focus aim, D-LEFT and D-RIGHT set the aim distance, X loots when there is something to loot and reloads otherwise, Y searches inside an extraction circle, a bumper tap walks the tactical belt and a bumper held zooms (LB out, RB in), and holding A while down gives up. The button names in prompts and the controller legend say the same. Check 16.72 fails on v16.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
