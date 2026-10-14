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

# CHANGE PAD BUTTONS: CONTROLLER REBINDING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ShiftLeft:'LS',ControlLeft:'B',KeyM:'D-UP',KeyI:'VIEW'};
'@ @'
ShiftLeft:'LS',ControlLeft:'B',KeyM:'D-UP',KeyI:'VIEW'};
// v26.xx (padbind), HIS ORDER 2026-10-14 ("CONTROLLER REBINDING is NEW"): PADLABEL is the table the raid prompts read, and it follows the pad bindings now (padLabelsApply rewrites it);
// PADLABEL_DEF is the standard layout, kept as it was for the Undercroft and the menus, which do not move.
var PADLABEL_DEF={}; (function(){ for(var k in PADLABEL) PADLABEL_DEF[k]=PADLABEL[k]; })();
'@

SubRx @'
if(PADLABEL[code]) return padB(PADLABEL[code]);
'@ @'
if(PADLABEL[code]) return padB((state==='hub'&&PADLABEL_DEF[code])?PADLABEL_DEF[code]:PADLABEL[code]);   // v26.xx (padbind): the raid names the buttons as bound, the Undercroft the standard ones
'@

SubRx @'
  PAD.ax=ax;
'@ @'
  PAD.ax=ax;
  // v26.xx (padbind): CHANGE PAD BUTTONS is waiting for a button: the next press is the new button for that action, and nothing else acts on it.
  if(PADB.waiting!==null&&padWaitTick(bt)){ for(var _wi=0;_wi<bt.length;_wi++) PAD.prev[_wi]=pressed(_wi); padRelease(); return; }
'@

SubRx @'
  if(state!=='raid'||!G){ padRelease(); return; }
'@ @'
  if(state!=='raid'||!G){ padRelease(); return; }
  bt=padLogical(bt);   // v26.xx (padbind): from here the raid reads the buttons as CHANGE PAD BUTTONS has them (action n is on the button it is bound to); the menus, the title and the Undercroft above read the pad as it is
'@

SubRx @'
  list.innerHTML=keysListHtml(); keysNoteShow();
'@ @'
  list.innerHTML=(KEYS.pad?padListBody():keysListHtml()); keysNoteShow();   // v26.xx (padbind): the same window lists the pad buttons in pad mode
'@

SubRx @'
KEYS.waiting=(KEYS.waiting===_kk)?null:_kk; KEYS.note=null; keysRender(); }; })(bs[i]);
'@ @'
if(KEYS.pad){ padRebindClick(_kk); return; } KEYS.waiting=(KEYS.waiting===_kk)?null:_kk; KEYS.note=null; keysRender(); }; })(bs[i]);
'@

SubRx @'
  if(KEYS.waiting){ s='PRESS A KEY FOR '+keysActName(KEYS.waiting)+'. ESC CANCELS.'; c='wait'; }
'@ @'
  if(KEYS.pad){ padNoteShow(el); return true; }   // v26.xx (padbind)
  if(KEYS.waiting){ s='PRESS A KEY FOR '+keysActName(KEYS.waiting)+'. ESC CANCELS.'; c='wait'; }
'@

SubRx @'
function keysOpen(){
'@ @'
function keysOpen(pad){
'@

SubRx @'
  KEYS.waiting=null; KEYS.note=null; keysRender(); openModal('keysmodal');
'@ @'
  KEYS.pad=!!pad; PADB.waiting=null; PADB.armed=0; PADB.note=null;   // v26.xx (padbind): keysOpen(true) is CHANGE PAD BUTTONS
  try{ var _kh=m.querySelector('h3'), _ks=m.querySelector('.msub'); if(_kh) _kh.textContent=pad?'Pad buttons':'Keys'; if(_ks) _ks.textContent=pad?'Put any action on the pad button you want. The sticks and the menus keep their standard buttons.':'Rebind any action to a keyboard key or a mouse button (middle or side). The controller has its own window: CHANGE PAD BUTTONS.'; }catch(_kt){}
  KEYS.waiting=null; KEYS.note=null; keysRender(); openModal('keysmodal');
'@

SubRx @'
document.getElementById('keysreset').onclick=function(){ keysReset(); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r){} };
'@ @'
document.getElementById('keysreset').onclick=function(){ if(KEYS.pad){ padReset(); PADB.waiting=null; keysRender(); try{ renderSettings(); }catch(_r0){} return; } keysReset(); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r){} };
'@

SubRx @'
  if(KEYS.waiting){ if(ev.code!=='Escape'){ if(!keysBind(KEYS.waiting,ev.code)){ keysRender(); return; } }
'@ @'
  if(KEYS.pad){ if(ev.code==='Escape'){ if(PADB.waiting!==null){ PADB.waiting=null; keysRender(); } else m.classList.remove('on'); } return; }   // v26.xx (padbind): in pad mode only ESC means anything on the keyboard
  if(KEYS.waiting){ if(ev.code!=='Escape'){ if(!keysBind(KEYS.waiting,ev.code)){ keysRender(); return; } }
'@

SubRx @'
function keysListHtml(){
'@ @'
// v26.xx (padbind), HIS ORDER 2026-10-14 ("A CHANGE PAD BUTTONS screen like CHANGE KEYS: each pad action shows its button; REBIND reads PRESS A BUTTON; a clash swaps the two; RESET TO
// DEFAULTS restores his 2026-09-27 pad layout"): CONTROLLER REBINDING. An action is named by the button it has on his layout (0 A, 1 B, 2 X, 3 Y, 4 LB, 5 RB, 6 LT, 7 RT, 8 VIEW, 9 MENU, 10 LS click,
// 11 RS click, 12 D-UP, 13 D-DOWN, 14 D-LEFT, 15 D-RIGHT) and P.padmap holds the button an action is on when that is not its own (action to button, like the key map). The sixteen are always a
// permutation: binding an action onto a button another action holds swaps the two. In a raid pollPad reads the buttons through padLogical (action n is read from the button it is bound to), so
// every raid branch, the tap, the hold, the triggers, the bumpers and the stall, is untouched; the title, the menus, the attract and the Undercroft read the pad as it is. Every raid prompt
// goes through PADLABEL (padLabelsApply rewrites it, and the two legends), keyLabel and pbn, so the names follow the binding. The sticks stay where they are.
var PAD_BTN=['A','B','X','Y','LB','RB','LT','RT','VIEW','MENU','LS','RS','D-UP','D-DOWN','D-LEFT','D-RIGHT'];
var PAD_ACTS=[[10,'sprint','MOVE'],[0,'dodge roll','MOVE'],[1,'crouch','MOVE'],
  [7,'fire, use what is selected','FIGHT'],[6,'focus aim (hold)','FIGHT'],[11,'focus aim (toggle)','FIGHT'],[14,'aim distance shorter','FIGHT'],[15,'aim distance longer','FIGHT'],
  [2,'use, search, reload, call for extraction','FIGHT'],[3,'search in a ring, help a teammate','FIGHT'],
  [4,'previous gun (hold: zoom out)','GEAR'],[5,'next gun (hold: zoom in)','GEAR'],[13,'item wheel (hold)','GEAR'],[8,'backpack','GEAR'],
  [12,'ping (hold: the map)','WORLD'],[9,'pause','WORLD']];
var PADLOGIC={KeyE:2,KeyR:2,KeyF:13,KeyT:5,KeyG:7,KeyQ:13,Space:0,KeyP:9,KeyX:2,ShiftLeft:10,ControlLeft:1,KeyM:12,KeyI:8};
var PADB={waiting:null,armed:0,t0:0,note:null,sig:''};
function padMapArr(){
  var m=(typeof P!=='undefined'&&P&&P.padmap&&typeof P.padmap==='object')?P.padmap:null, o=[], used={}, i, v;
  for(i=0;i<16;i++){ v=m?m[i]:undefined; v=(typeof v==='number'&&v>=0&&v<16&&v===Math.floor(v))?v:i; o.push(v); }
  for(i=0;i<16;i++){ if(used[o[i]]) return [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]; used[o[i]]=1; }
  return o;
}
function padLogical(bt){
  var m=padMapArr(), i, o, same=true;
  for(i=0;i<16;i++) if(m[i]!==i){ same=false; break; }
  if(same) return bt;
  o=[].slice.call(bt);
  for(i=0;i<16&&i<o.length;i++) if(bt[m[i]]) o[i]=bt[m[i]];
  return o;
}
function pbn(i){ return PAD_BTN[padMapArr()[i]]||String(i); }
function pln(i){ var b=padMapArr()[i]; return (b===10)?'LS CLICK':((b===11)?'RS CLICK':((b===12)?'DPAD UP':PAD_BTN[b])); }
function padActName(i){ var k; for(k=0;k<PAD_ACTS.length;k++) if(PAD_ACTS[k][0]===i) return String(PAD_ACTS[k][1]).toUpperCase(); return String(i); }
function padLegendBuild(){
  var n=pln, dl=n(14), dr=n(15);
  return [
    ['MOVE',[['L STICK','move, analog'],[n(10),'sprint'],[n(1),'crouch'],[n(0),'dodge roll']]],
    ['FIGHT',[['R STICK','aim'],[n(7),'fire / use selected'],[n(6)+' / '+n(11),'focus aim, hold / toggle'],[(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-LEFT/RIGHT':(dl+' / '+dr),'aim distance'],[n(2),'reload']]],
    ['GEAR',[[n(4)+'/'+n(5)+' tap','change tactical belt slot'],[n(4)+'/'+n(5)+' hold','zoom out / in'],[n(13),'item wheel (hold), revive when down'],[n(8),'backpack']]],
    ['WORLD',[[n(2),'search / open / call for extraction'],[n(3),'search in a ring'],[n(12),'ping (twice: danger); hold: map'],[n(9),'pause']]],
    ['TEAM',[[n(3),'backpack open: drop an item for a teammate'],[n(12),'ping, twice for danger']]]
  ];
}
function padMiniBuild(){
  var b=pbn, dl=b(14), dr=b(15);
  return [['L STICK','move'],[b(10),'sprint'],[b(1),'crouch'],[b(0),'roll'],[b(7),'fire / use'],[b(6)+' / '+b(11),'focus aim'],[b(2),'reload'],
    [(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-L / D-R':(dl+' / '+dr),'aim distance'],[b(4)+' / '+b(5),'tactical belt'],[b(8),'backpack'],[b(12),'ping, hold: map'],[b(9),'pause']];
}
function padLabelsApply(){
  var sig=padMapArr().join(','), m, k;
  if(PADB.sig===sig) return false;
  PADB.sig=sig; m=padMapArr();
  for(k in PADLOGIC) PADLABEL[k]=PAD_BTN[m[PADLOGIC[k]]];
  LEGEND_PAD=padLegendBuild(); LEGEND_MINI_PAD=padMiniBuild();
  try{ keysLegendApply(); }catch(_pl){}
  return true;
}
function padBind(action,button){
  var m=padMapArr(), old, other=-1, i;
  if(typeof action!=='number'||typeof button!=='number'||!(action>=0&&action<16)||!(button>=0&&button<16)) return false;
  old=m[action];
  if(old===button){ PADB.note={t:'set',s:padActName(action)+' IS ON '+padB(PAD_BTN[button])+'.'}; return true; }
  for(i=0;i<16;i++) if(i!==action&&m[i]===button){ other=i; break; }
  m[action]=button; if(other>=0) m[other]=old;
  P.padmap={}; for(i=0;i<16;i++) if(m[i]!==i) P.padmap[i]=m[i];
  P.padmapV=1;
  PADB.note=(other>=0)?{t:'clash',s:'CLASH: '+padActName(other)+' WAS ON '+padB(PAD_BTN[button])+'. SWAPPED: '+padActName(action)+' IS ON '+padB(PAD_BTN[button])+', '+padActName(other)+' IS ON '+padB(PAD_BTN[old])+'.'}:{t:'set',s:padActName(action)+' IS ON '+padB(PAD_BTN[button])+'.'};
  try{ saveProfile(); }catch(_ps){}
  padLabelsApply();
  return true;
}
function padReset(){ if(P){ P.padmap={}; P.padmapV=1; } PADB.note={t:'set',s:'ALL BUTTONS ARE BACK ON THEIR DEFAULTS.'}; try{ saveProfile(); }catch(_pr){} padLabelsApply(); return true; }
function padNoteShow(el){
  var s, c='';
  if(PADB.waiting!==null){ s='PRESS A BUTTON FOR '+padActName(PADB.waiting)+'. ESC OR TEN SECONDS CANCELS.'; c='wait'; }
  else if(PADB.note){ s=PADB.note.s; c=PADB.note.t; }
  else s='CLICK REBIND, THEN PRESS THE BUTTON YOU WANT. A BUTTON IN USE SWAPS WITH THE ACTION ON IT. THE UNDERCROFT AND THE MENUS KEEP THE STANDARD BUTTONS.';
  el.className=c; el.textContent=s;
}
function padRow1(a){
  var i=a[0], w=(PADB.waiting===i), ch=(padMapArr()[i]!==i);
  return '<div class="row"><div style="flex:1"><b>'+a[1]+'</b></div><button class="keybtn'+(w?' wait':'')+'" data-k="'+i+'" style="padding:6px 12px;min-width:110px'+((ch&&!w)?';color:var(--amber)':'')+'">'+(w?'PRESS A BUTTON':padB(pbn(i)))+
    '</button><button class="rebind" data-k="'+i+'">'+(w?'CANCEL':'REBIND')+'</button></div>';
}
function padListBody(){
  var h='', secs=['MOVE','FIGHT','GEAR','WORLD'], s, i, lk=[['MOVE','L STICK'],['AIM','R STICK'],['MENUS: SELECT','A'],['MENUS: BACK','B']];
  for(s=0;s<secs.length;s++){ h+='<div class="keysec">'+secs[s]+'</div>'; for(i=0;i<PAD_ACTS.length;i++) if(PAD_ACTS[i][2]===secs[s]) h+=padRow1(PAD_ACTS[i]); }
  h+='<div class="keysec">LOCKED: THESE KEEP THEIR JOBS</div>';
  for(i=0;i<lk.length;i++) h+='<div class="row"><div style="flex:1"><b>'+lk[i][0]+'</b></div><span class="keyfixed">'+padB(lk[i][1])+'</span></div>';
  return h;
}
function padRebindClick(k){
  k=+k; PADB.waiting=(PADB.waiting===k)?null:k; PADB.armed=0; PADB.note=null;
  PADB.t0=(typeof performance!=='undefined')?performance.now():Date.now();
  keysRender();
}
function padWaiting(){
  var m;
  if(PADB.waiting===null) return false;
  m=document.getElementById('keysmodal');
  if(!m||!m.classList.contains('on')||!KEYS.pad){ PADB.waiting=null; return false; }
  return true;
}
function padWaitTick(bt){
  var down=[], i, b, now=(typeof performance!=='undefined')?performance.now():Date.now();
  if(!padWaiting()) return false;
  if(now-PADB.t0>10000){ PADB.waiting=null; PADB.note={t:'clash',s:'NO BUTTON WAS PRESSED. NOTHING CHANGED.'}; try{ keysRender(); }catch(_w0){} return true; }
  for(i=0;i<16&&i<bt.length;i++){ b=bt[i]; if(b&&(b.pressed||b.value>0.5)) down.push(i); }
  if(!PADB.armed){ if(!down.length) PADB.armed=1; return true; }   // a button still held from the click that started this has to be let go first
  if(!down.length) return true;
  padBind(PADB.waiting,down[0]);
  PADB.waiting=null; PADB.armed=0;
  try{ keysRender(); renderSettings(); }catch(_w1){}
  return true;
}
function padRowHtml(){
  var n=0, m=padMapArr(), i;
  for(i=0;i<16;i++) if(m[i]!==i) n++;
  return '<div class="row"><div style="flex:1"><b>Pad buttons</b><div class="hint">Put any action on the pad button you want. Two actions never share a button: they swap. The Undercroft and the menus keep the standard buttons.</div></div>'+
    '<button id="set_pad" style="padding:6px 12px;min-width:92px'+(n?';color:var(--amber)':'')+'">'+(n?'CHANGED':'CHANGE PAD BUTTONS')+'</button></div>';
}
function keysListHtml(){
'@

SubRx @'
n=SETSEC[i]; b=(S[n]||'')+((X&&X[n])||'');
'@ @'
n=SETSEC[i]; b=((X&&X[n])||'')+(S[n]||'');   // v26.xx (padbind): the rows that are not GAMEOPTS (CHANGE KEYS, CHANGE PAD BUTTONS) lead their section
'@

SubRx @'
host.innerHTML=setSecsHtml(_SEC,{CONTROLS:keysRowHtml()})+kidHeadHtml()
'@ @'
host.innerHTML=setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml()})+kidHeadHtml()
'@

SubRx @'
(function(){ var _kk=document.getElementById('set_keys'); if(_kk) _kk.onclick=function(){ keysOpen(); }; })();
'@ @'
(function(){ var _kk=document.getElementById('set_keys'); if(_kk) _kk.onclick=function(){ keysOpen(); }; })();
  (function(){ var _kp=document.getElementById('set_pad'); if(_kp) _kp.onclick=function(){ keysOpen(true); }; })();   // v26.xx (padbind): CHANGE PAD BUTTONS
'@

SubRx @'
try{ cbApply(); }catch(_cb){}   // v26.xx (settings8): COLOUR-BLIND MODE, applied at once
'@ @'
try{ cbApply(); }catch(_cb){}   // v26.xx (settings8): COLOUR-BLIND MODE, applied at once
  try{ padLabelsApply(); }catch(_pl){}   // v26.xx (padbind): the pad prompts follow the pad bindings, whenever they change (a profile load, the DEMO sandbox, a rebind)
'@

SubRx @'
if(padOn()) return padB('[LB] [RB] GUN');
'@ @'
if(padOn()) return padB('['+pbn(4)+'] ['+pbn(5)+'] GUN');
'@

SubRx @'
padB('[VIEW] BACKPACK  \u00b7  [Y] DROP')
'@ @'
padB('['+pbn(8)+'] BACKPACK  \u00b7  ['+pbn(3)+'] DROP')
'@

SubRx @'
vb=padOn()?'RT':'LMB';
'@ @'
vb=padOn()?pbn(7):'LMB';
'@

SubRx @'
hk=padOn()?'D-DOWN':String(keyLabel('KeyQ','Q'));
'@ @'
hk=padOn()?pbn(13):String(keyLabel('KeyQ','Q'));
'@

SubRx @'
['FIRE','LEFT CLICK',padB('RT')],['ROLL',kn('Space'),padB('A')],
'@ @'
['FIRE','LEFT CLICK',padB(pbn(7))],['ROLL',kn('Space'),padB(pbn(0))],
'@

SubRx @'
['RELOAD',kn('KeyR'),padB('X')],['SWITCH GUN','1-9',padB('LB')+' / '+padB('RB')],['ITEMS','HOLD '+kn('KeyQ'),'HOLD '+padB('D-DOWN')],
'@ @'
['RELOAD',kn('KeyR'),padB(pbn(2))],['SWITCH GUN','1-9',padB(pbn(4))+' / '+padB(pbn(5))],['ITEMS','HOLD '+kn('KeyQ'),'HOLD '+padB(pbn(13))],
'@

SubRx @'
['EXTRACT','HOLD '+kn('KeyX')+' IN A TEAL RING','HOLD '+padB('X')+' IN A TEAL RING'],['LOOT','HOLD '+kn('KeyE'),'HOLD '+padB('X')]];
'@ @'
['EXTRACT','HOLD '+kn('KeyX')+' IN A TEAL RING','HOLD '+padB(pbn(2))+' IN A TEAL RING'],['LOOT','HOLD '+kn('KeyE'),'HOLD '+padB(pbn(2))]];
'@

SubRx @'
(padOn()?(((G.pedSel||0)===0)?padB('[A]'):'   '):'[1]')
'@ @'
(padOn()?(((G.pedSel||0)===0)?padB('['+pbn(0)+']'):'   '):'[1]')
'@

SubRx @'
(padOn()?(((G.pedSel||0)===i+1)?padB('[A]')+'  ':'     '):('['+(i+2)+']  '))
'@ @'
(padOn()?(((G.pedSel||0)===i+1)?padB('['+pbn(0)+']')+'  ':'     '):('['+(i+2)+']  '))
'@

SubRx @'
var VER='26.52';
'@ @'
var VER='26.53';
'@

$pat = "(?m)^  now:'v26\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.53: Controller has change pad buttons: rebind any pad action. Check 26.53 fails on v26.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
