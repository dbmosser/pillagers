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

# NEW KEYS: E SEARCH, X EXTRACT, Q CROWBAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(code==='KeyG'||code==='Space'||code==='KeyQ'||code==='KeyC') return;
'@ @'
if(code==='KeyG'||code==='Space'||code==='KeyQ'||code==='KeyC'||code==='KeyH'||code==='KeyF'||code==='KeyU') return;   // v25.xx (keyswap): and the new throw, heal, melee, next gun and switch keys do nothing behind the stall
'@

SubRx @'
['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyV','KeyC','KeyX','Backspace','ControlLeft','ShiftLeft'].indexOf(code)>=0
'@ @'
['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyV','KeyC','KeyX','KeyU','F1','Backspace','ControlLeft','ShiftLeft'].indexOf(code)>=0
'@

SubRx @'
if(code==='KeyH'&&G&&!repeat) G.legendOn=(G.legendOn+1)%3;
'@ @'
if(code==='F1'&&G&&!repeat) G.legendOn=(G.legendOn+1)%3;   // v25.xx (keyswap): F1 cycles the controls list (it was H)
  if(code==='KeyH'&&G&&!G.over&&!G.paused&&!repeat) quickHeal();   // v25.xx (keyswap): H is the quick heal, no backpack needed
'@

SubRx @'
if(code==='KeyF'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();
'@ @'
if(code==='KeyF'&&G&&!G.over&&!G.paused&&!repeat) nextGun();   // v25.xx (keyswap): F brings up the next gun
  if(code==='KeyQ'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();   // v25.xx (keyswap): Q swings the crowbar (it was F)
'@

SubRx @'
if(code==='KeyQ'&&G&&!G.over&&!repeat) cycleThrow();
'@ @'
if(code==='KeyU'&&G&&!G.over&&!repeat) cycleThrow();   // v25.xx (keyswap): switch throwable moved from Q (now the crowbar) to U
'@

SubRx @'
if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat&&!(G.arcade&&typeof arcadeQuickHeal==='function'&&arcadeQuickHeal())) useHot();
'@ @'
if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat) doThrow();
'@

SubRx @'
if(e.code==='KeyH'&&!e.repeat&&HB&&!_hubBusy){ HB.legend=!HB.legend; e.preventDefault(); return; }
'@ @'
if(e.code==='F1'&&!e.repeat&&HB&&!_hubBusy){ HB.legend=!HB.legend; e.preventDefault(); return; }   // v25.xx (keyswap): F1, H is the quick heal up top
'@

SubRx @'
_lg.push('H','close this');
'@ @'
_lg.push('F1','close this');
'@

SubRx @'
if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad))){
'@ @'
if(near&&((keys['KeyE']&&!(keys['PadX']&&onPad))||keys['PadSearch'])){   // v25.xx (keyswap): E searches in a ring too; the pad X in a ring still calls instead (PadX), and its Y search is PadSearch
'@

SubRx @'
tryExtractTick(dt,!!keys['KeyE']&&(!near||onPad));
'@ @'
tryExtractTick(dt,xCallKey()&&(!near||onPad));   // v25.xx (keyswap): X calls and takes the extraction
'@

SubRx @'
tryExtractTick(dt,!!keys['KeyE']);
'@ @'
tryExtractTick(dt,xCallKey());   // v25.xx (keyswap): and downed too, on X
'@

SubRx @'
padHold('KeyE',_xDown&&PAD.xMode==='KeyE'&&!_xSearch);
'@ @'
padHold('KeyE',_xDown&&PAD.xMode==='KeyE'&&!_xSearch);
      padHold('PadX',_xDown&&PAD.xMode==='KeyE'&&!_xSearch);   // v25.xx (keyswap): the pad X hold also stands for the keyboard X, the extraction call
'@

SubRx @'
padHold('KeyX',(_yD&&!PAD.yAid)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch));
'@ @'
padHold('PadSearch',(_yD&&!PAD.yAid)||(_xDown&&PAD.xMode==='KeyE'&&_xSearch));   // v25.xx (keyswap): the pad ring search (was keyboard X, which is the extraction now)
'@

SubRx @'
KeyP:'MENU',KeyX:'Y',
'@ @'
KeyP:'MENU',KeyX:'X',
'@

SubRx @'
var _skey='['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH ',
'@ @'
var _skey='['+((G.nearPad&&padOn())?padB('Y'):keyLabel('KeyE','E'))+'] SEARCH ',
'@

SubRx @'
Hold '+keyLabel('KeyE','E')+' to try again.
'@ @'
Hold '+keyLabel('KeyX','X')+' to try again.
'@

SubRx @'
_xk='['+keyLabel('KeyE','E')+']';
'@ @'
_xk='['+keyLabel('KeyX','X')+']';
'@

SubRx @'
sub:'Hold ['+keyLabel('KeyE','E')+'] to extract.'
'@ @'
sub:'Hold ['+keyLabel('KeyX','X')+'] to extract.'
'@

SubRx @'
'Hold ['+keyLabel('KeyE','E')+'] to call again'
'@ @'
'Hold ['+keyLabel('KeyX','X')+'] to call again'
'@

SubRx @'
'['+keyLabel('KeyE','E')+'] EXTRACT  
'@ @'
'['+keyLabel('KeyX','X')+'] EXTRACT  
'@

SubRx @'
'['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION'
'@ @'
'['+keyLabel('KeyX','X')+'] CALL FOR EXTRACTION'
'@

SubRx @'
hudText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION'
'@ @'
hudText('HOLD ['+keyLabel('KeyX','X')+'] TO CALL FOR EXTRACTION'
'@

SubRx @'
ctx.fillText('HOLD ['+keyLabel('KeyE','E')+'] TO CALL FOR EXTRACTION'
'@ @'
ctx.fillText('HOLD ['+keyLabel('KeyX','X')+'] TO CALL FOR EXTRACTION'
'@

SubRx @'
msg:'HOLD ['+keyLabel('KeyE','E')+'] TO EXTRACT'
'@ @'
msg:'HOLD ['+keyLabel('KeyX','X')+'] TO EXTRACT'
'@

SubRx @'
_msg='HOLD ['+keyLabel('KeyE','E')+'] TO EXTRACT';
'@ @'
_msg='HOLD ['+keyLabel('KeyX','X')+'] TO EXTRACT';
'@

SubRx @'
var _K='['+keyLabel('KeyE','E')+']';
'@ @'
var _K='['+keyLabel('KeyX','X')+']';   // v25.xx (keyswap): the extraction hint names X
'@

SubRx @'
G.punchT=0.22;                      // the thrust the fists attack draws
'@ @'
G.punchT=0.22;                      // the thrust the fists attack draws
  G.barT=0.22; meleeFoley('swing');   // v25.xx (keyswap): and Q swings a crowbar through that same 0.22 s: drawn in the hand, with a whoosh
'@

SubRx @'
if(G.punchT>0) G.punchT-=dt;
'@ @'
if(G.punchT>0) G.punchT-=dt;
  if(G.barT>0) G.barT-=dt;   // v25.xx (keyswap): the crowbar swing
'@

SubRx @'
if(!G.sim){ spark(_me.x,_me.y,'#cdd6dd',10,200); sfx('clank',_me.x,_me.y); }
'@ @'
if(!G.sim){ spark(_me.x,_me.y,'#cdd6dd',10,200); sfx('clank',_me.x,_me.y); if(G.barT>0) meleeFoley('hit',_me.x,_me.y); }   // v25.xx (keyswap): a crowbar blow thuds
'@

SubRx @'
if(!G.sim&&!_swHit&&fromPlayer) blip('foot');
'@ @'
if(!G.sim&&!_swHit&&fromPlayer&&!(G.barT>0)) blip('foot');   // v25.xx (keyswap): a crowbar miss is its whoosh, not a footfall
'@

SubRx @'
wc.fillStyle=_HANDC; wc.fillRect(2+ext,-1.6,10,3.2);
'@ @'
if(typeof G!=='undefined'&&G&&G.barT>0){
      // v25.xx (keyswap): THE CROWBAR. Q swings a short crowbar through the arc the blow hits in (0.95 rad either side of the aim): an
      // inked steel bar with a hooked claw end and a red grip, the hand on the grip, and a pale trail behind the tip. Cosmetic only.
      var _cbP=1-Math.max(0,Math.min(1,G.barT/0.22)), _cbT=-0.95+1.9*_cbP;
      wc.fillStyle=_HANDC; wc.fillRect(2+ext,-1.6,5,3.2);
      wc.strokeStyle='rgba(205,214,221,.38)'; wc.lineWidth=1.6; wc.beginPath(); wc.arc(6+ext,0,17,-0.95,_cbT); wc.stroke();
      wc.save(); wc.translate(6+ext,0); wc.rotate(_cbT);
      wc.fillStyle=INK; wc.fillRect(-2.2,-2.1,20.6,4.2); wc.fillRect(14.8,-4.2,3.6,3.2);
      wc.fillStyle='#8d99a6'; wc.fillRect(-1.4,-1.3,18.2,2.6); wc.fillRect(15.4,-3.6,2.2,2.4);
      wc.fillStyle='#c9d3dc'; wc.fillRect(-1.4,-1.3,18.2,0.8);
      wc.fillStyle='#a8372a'; wc.fillRect(-1.4,-1.3,6.4,2.6);
      wc.fillStyle=_HANDC; wc.fillRect(0.4,-1.9,3.6,3.8);
      wc.restore();
    } else { wc.fillStyle=_HANDC; wc.fillRect(2+ext,-1.6,10,3.2); }
'@

SubRx @'
wc.beginPath(); wc.arc(13+ext,0,2.8,0,6.2832); wc.fill();
'@ @'
if(!(typeof G!=='undefined'&&G&&G.barT>0)){ wc.beginPath(); wc.arc(13+ext,0,2.8,0,6.2832); wc.fill(); }
'@

SubRx @'
function meleeStrike(){
'@ @'
// v25.xx (keyswap), HIS ORDERS 2026-10-13: "E - search (always); X - start extraction countdown / extract; G - quick grenade (or other
// throwable); H - quick heal", then "Q - melee (change it so you melee attack with a crowbar); F - next gun". E searches boxes, bodies and
// caches in a ring too and never calls an extraction; X calls it and takes it (xCallKey); G throws the selected throwable at once (doThrow);
// H uses the best heal you carry through the same picker and wind-up as the belt (quickHeal: a Bandage stops at 85, a Medkit reaches
// 100); Q swings a crowbar (the blow, reach and cooldown of the bare hands strike, now drawn and sounded as a crowbar); F brings up the next
// gun on keys 1 to 4, skipping an empty key and wrapping round (nextGun, the swap path the number keys use). F1 shows the controls list,
// and U switches throwable. The pad layout is his of 2026-09-27 and is unchanged: the pad X still holds E, now with PadX beside it to stand
// for the keyboard X, and its Y ring search is PadSearch.
function xCallKey(){ return !!(keys['KeyX']||(keys['PadX']&&keys['KeyE'])); }
function quickHeal(){
  var p=G&&G.player;
  if(!G||G.sim||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.specOut) return false;
  try{ useMedical(); }catch(_qh){}
  return true;
}
function nextGun(){
  var p=G&&G.player, sl, cur, n=GUNKEYS, k, i;
  if(!G||G.over||G.paused||G.trade||!p||p.downed||p.dying||p.roll>0) return false;
  sl=hotbarSlots(); cur=heldGunCell(sl); if(cur<0) cur=clamp(G.hot||0,0,n-1);
  for(k=1;k<=n;k++){
    i=(cur+k)%n;
    if(!sl[i]||sl[i].kind!=='gun'||sl[i].vacant||sl[i].inHand) continue;
    if(G.hot===i) G.hot=cur;   // setHot ignores the key the highlight is already on
    setHot(i);
    return true;
  }
  return false;
}
// the crowbar sounds, from the v25.20 foley bank: a metal whoosh as it swings, a thud and a rattle where it lands
function meleeFoley(kind,x,y){
  if((G&&G.sim)||typeof foley!=='function') return false;
  if(kind==='swing'){ foley('strapRip',null,null,{rate:2.2,g:0.9,dur:0.2}); foley('boltLatch',null,null,{rate:2.4,g:0.4,at:0.05,dur:0.09,gap:0}); return true; }
  if(kind==='hit'){ foley('plateClack',x,y,{rate:0.75,g:1.2}); foley('lmgClack',x,y,{rate:0.9,g:0.6,at:0.03,gap:0}); return true; }
  return false;
}
function meleeStrike(){
'@

SubRx @'
ctx.fillText('H  controls',14,_hy);
'@ @'
ctx.fillText(legendKeys('F1')+'  controls',14,_hy);   // v25.xx (keyswap): F1
'@

SubRx @'
ctx.fillText('H  full list',mx,my+LH(7)+MROW*_mr+LH(3));
'@ @'
ctx.fillText(legendKeys('F1')+'  full list',mx,my+LH(7)+MROW*_mr+LH(3));
'@

SubRx @'
ctx.fillText('H  hide',x,top+boxH-LH(2));
'@ @'
ctx.fillText(legendKeys('F1')+'  hide',x,top+boxH-LH(2));
'@

SubRx @'
['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['F','melee strike, whatever you are holding']]],
'@ @'
['FIGHT',[['MOUSE','aim'],['LMB','fire'],['RMB','aim down sights'],['R','reload'],['Q','melee, swing the crowbar'],['F','next gun']]],
'@

SubRx @'
['GEAR',[['1-9','select tactical belt slot'],['FIRE','use selected slot'],['B / I','backpack'],['ENTER','equip gun from backpack'],['BKSP','reset cursor']]],
'@ @'
['GEAR',[['1-9','select tactical belt slot'],['FIRE','use selected slot'],['G','quick throw'],['U','switch throwable'],['H','quick heal'],['B / I','backpack'],['ENTER','equip gun from backpack'],['BKSP','reset cursor']]],
'@

SubRx @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],
'@ @'
['WORLD',[['E','search, use, open'],['X','call for extraction, then board'],['M','map'],['F1','cycle this list'],
'@

SubRx @'
  ['F','melee'],
'@ @'
  ['Q','melee'],['F','next gun'],['G','throw'],['H','heal'],
'@

SubRx @'
['E','search'],['M','map']
'@ @'
['E','search'],['X','extract'],['M','map']
'@

SubRx @'
'E':['KeyE'],'M':['KeyM'],'Z':['KeyZ'],'N':['KeyN']}
'@ @'
'E':['KeyE'],'M':['KeyM'],'Z':['KeyZ'],'N':['KeyN'],'Q':['KeyQ'],'G':['KeyG'],'H':['KeyH'],'X':['KeyX'],'U':['KeyU'],'F1':['F1']}
'@

SubRx @'
s('KeyE')+' interact &nbsp; '
'@ @'
s('KeyE')+' search / use &nbsp; '+s('KeyX')+' extraction &nbsp; '
'@

SubRx @'
s('KeyF')+' melee strike &nbsp; '
'@ @'
s('KeyQ')+' melee &nbsp; '+s('KeyF')+' next gun &nbsp; '+s('KeyG')+' quick throw &nbsp; '+s('KeyH')+' quick heal &nbsp; '
'@

SubRx @'
s('KeyH')+' controls &nbsp; '
'@ @'
s('F1')+' controls &nbsp; '
'@

SubRx @'
['KeyE','interact, search, call for extraction']
'@ @'
['KeyE','search and use']
'@

SubRx @'
['KeyF','melee strike'],
'@ @'
['KeyQ','melee (crowbar)'],['KeyF','next gun'],
'@

SubRx @'
['KeyX','search what you stand on']
'@ @'
['KeyX','call for extraction, then board']
'@

SubRx @'
['KeyM','map'],['KeyH','controls'],
'@ @'
['KeyM','map'],['F1','controls list'],['KeyH','quick heal'],
'@

SubRx @'
['KeyG','use the selected belt item'],['KeyQ','switch throwable']
'@ @'
['KeyG','quick throw'],['KeyU','switch throwable']
'@

SubRx @'
['HEAL',kn('KeyG'),padB('D-DOWN')]
'@ @'
['HEAL',kn('KeyH'),padB('D-DOWN')]
'@

SubRx @'
['EXTRACT','HOLD '+kn('KeyE')+' IN A TEAL RING'
'@ @'
['EXTRACT','HOLD '+kn('KeyX')+' IN A TEAL RING'
'@

SubRx @'
var VER='25.66';
'@ @'
var VER='25.67';
'@

$pat = "(?m)^  now:'v25\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.67: E searches, X calls and boards the extraction, G throws, H heals, Q swings a crowbar, F brings up the next gun, F1 shows the controls. Check 25.67 fails on v25.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
