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

# REBIND KEYS: SETTINGS, CHANGE KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
CapsLock:'CAPS'};
'@ @'
CapsLock:'CAPS',Mouse3:'MOUSE 4',Mouse4:'MOUSE 5'};
'@

SubRx @'
var KEYS={inv:null,waiting:null,built:0,inited:0};
'@ @'
var KEYS={inv:null,waiting:null,built:0,inited:0,note:null};
// v25.xx (keyremap), HIS ORDER 2026-10-13 ("add something in settings where the player can remap keys"): the version of the map (a map made
// before the key swap named jobs that have moved, so a profile older than this starts on the defaults, once, at load), and the keys no action
// may take: ESC, TAB and P (the pause and back-out keys), BACKSPACE (the cursor rescue), the key left of 1 (Superhot), F9 (the recorder) and
// F11 (fullscreen). 1 to 9 stay the tactical belt.
var KEYS_V=2, KEYS_FIXED={Escape:1,Tab:1,KeyP:1,Backspace:1,Backquote:1,F9:1,F11:1};
'@

SubRx @'
['KeyN','ping'],['KeyP','pause'],
'@ @'
['KeyN','ping'],
'@

SubRx @'
if(typeof logical!=='string'||typeof physical!=='string'||!physical||physical==='Escape'||physical==='Tab'||physical==='Backspace'||physical==='Backquote'||/^Digit[1-9]$/.test(physical)) return false;   // v18.54: and never BACKSPACE (the cursor) or the key left of 1 (Superhot), which keep their own jobs
'@ @'
if(typeof logical!=='string'||typeof physical!=='string'||!physical) return false;
  if(KEYS_FIXED[physical]||/^Digit[1-9]$/.test(physical)){ KEYS.note={t:'clash',s:keyName(physical)+' KEEPS ITS OWN JOB. ESC, TAB, P, BACKSPACE, F9, F11, THE KEY LEFT OF 1 AND 1-9 CANNOT BE REBOUND.'}; return false; }   // v25.xx (keyremap): the pause key and its kin are reserved
'@

SubRx @'
m[logical]=physical; if(other) m[other]=old;
'@ @'
m[logical]=physical; if(other) m[other]=old; P.keymapV=KEYS_V;
  KEYS.note=other?{t:'clash',s:'CLASH: '+keysActName(other)+' WAS ON '+keyName(physical)+'. SWAPPED: '+keysActName(logical)+' IS ON '+keyName(physical)+', '+keysActName(other)+' IS ON '+keyName(old)+'.'}:{t:'set',s:keysActName(logical)+' IS ON '+keyName(physical)+'.'};   // v25.xx (keyremap): the clash is shown
'@

SubRx @'
function keysReset(){ if(P) P.keymap={}; KEYS.inv=null; keysInv();
'@ @'
function keysReset(){ if(P){ P.keymap={}; P.keymapV=KEYS_V; } KEYS.note={t:'set',s:'ALL KEYS ARE BACK ON THEIR DEFAULTS.'}; KEYS.inv=null; keysInv();
'@

SubRx @'
if(d&&typeof d.credits==='number'){ P=d;
'@ @'
if(d&&typeof d.credits==='number'){ P=d; if(P.keymapV!==2){ P.keymap={}; P.keymapV=2; } try{ if(typeof KEYS==='object'&&KEYS) KEYS.inv=null; }catch(_kv){}   // v25.xx (keyremap): the key translation is rebuilt from the loaded map, and a map from before the swap is dropped once
'@

SubRx @'
notoriety:0,runs:0,autoloot:1,keymap:{},crashes:[]};
'@ @'
notoriety:0,runs:0,autoloot:1,keymap:{},keymapV:2,crashes:[]};
'@

SubRx @'
function keysLegendHtml(){
'@ @'
// v25.xx (keyremap): THE KEYS WINDOW FINISHED. Every action has its key and a REBIND control; clicking either says PRESS A KEY and the next
// press binds (ESC cancels; a reserved key says so and keeps waiting). A key another action holds is a clash: the two swap and the note says
// who moved where. The two side mouse buttons bind too (Mouse3 and Mouse4): a bound button is dispatched as the keyboard event of that code,
// so every reader of keys, in the raid, the Undercroft and the menus, sees it as the key it stands for, and an unbound button keeps the
// browser back and forward. The pad is never touched.
var KEYS_SECT=[['MOVE',['KeyW','KeyA','KeyS','KeyD','Space','ShiftLeft','ControlLeft','KeyC']],['FIGHT',['KeyR','KeyQ','KeyF','KeyG','KeyU','KeyH']],
  ['WORLD',['KeyE','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyO']],['PARTY',['KeyT','KeyZ','KeyN','KeyV']]];
function keysActName(code){ var i; for(i=0;i<KEYS_ACTS.length;i++) if(KEYS_ACTS[i][0]===code) return String(KEYS_ACTS[i][1]).toUpperCase(); return String(code).toUpperCase(); }
function keysRow1(a){
  var k=a[0], w=(KEYS.waiting===k), ch=(keysOf(k)!==k);
  return '<div class="row"><div style="flex:1"><b>'+a[1]+'</b></div><button class="keybtn'+(w?' wait':'')+'" data-k="'+k+'" style="padding:6px 12px;min-width:110px'+((ch&&!w)?';color:var(--amber)':'')+'">'+(w?'PRESS A KEY':keyName(keysOf(k)))+
    '</button><button class="rebind" data-k="'+k+'">'+(w?'CANCEL':'REBIND')+'</button></div>';
}
function keysListBody(){
  var h='', done={}, s, i, j, left=[];
  for(s=0;s<KEYS_SECT.length;s++){
    h+='<div class="keysec">'+KEYS_SECT[s][0]+'</div>';
    for(j=0;j<KEYS_SECT[s][1].length;j++) for(i=0;i<KEYS_ACTS.length;i++) if(KEYS_ACTS[i][0]===KEYS_SECT[s][1][j]){ h+=keysRow1(KEYS_ACTS[i]); done[KEYS_ACTS[i][0]]=1; }
  }
  for(i=0;i<KEYS_ACTS.length;i++) if(!done[KEYS_ACTS[i][0]]) left.push(KEYS_ACTS[i]);
  if(left.length){ h+='<div class="keysec">OTHER</div>'; for(i=0;i<left.length;i++) h+=keysRow1(left[i]); }
  return h;
}
function keysNoteShow(){
  var el=document.getElementById('keysnote'), s, c='';
  if(!el) return false;
  if(KEYS.waiting){ s='PRESS A KEY FOR '+keysActName(KEYS.waiting)+'. ESC CANCELS.'; c='wait'; }
  else if(KEYS.note){ s=KEYS.note.s; c=KEYS.note.t; }
  else s='CLICK REBIND, THEN PRESS THE KEY YOU WANT. A KEY IN USE SWAPS WITH THE ACTION ON IT.';
  el.className=c; el.textContent=s;
  return true;
}
function keysMouse(e,down){
  var pc='Mouse'+e.button, inv;
  if(!(e.button>=3&&e.button<=4)) return false;
  inv=KEYS.inv||keysInv();
  if(down&&KEYS.waiting){ var m=document.getElementById('keysmodal'); if(m&&m.classList.contains('on')){ e.preventDefault(); e.stopPropagation(); keysBind(KEYS.waiting,pc); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_rs){} return true; } }
  if(!inv[pc]) return false;
  e.preventDefault();
  try{ window.dispatchEvent(new KeyboardEvent(down?'keydown':'keyup',{code:pc,key:pc,bubbles:true,cancelable:true})); }catch(_km){}
  return true;
}
try{ window.addEventListener('mousedown',function(e){ keysMouse(e,true); },true); window.addEventListener('mouseup',function(e){ keysMouse(e,false); },true); }catch(_kmw){}
function keysLegendHtml(){
'@

SubRx @'
for(i=0;i<KEYS_ACTS.length;i++){ a=KEYS_ACTS[i]; h+='<div class="row"><div style="flex:1"><b>'+a[1]+'</b></div><button class="keybtn" data-k="'+a[0]+'" style="padding:6px 12px;min-width:110px'+(keysOf(a[0])!==a[0]?';color:var(--amber)':'')+'">'+(KEYS.waiting===a[0]?'PRESS A KEY':keyName(keysOf(a[0])))+'</button></div>'; }
'@ @'
h=keysListBody();   // v25.xx (keyremap): in sections, a REBIND control on every action
'@

SubRx @'
list.innerHTML=keysListHtml();
'@ @'
list.innerHTML=keysListHtml(); keysNoteShow();
'@

SubRx @'
bs=list.querySelectorAll('.keybtn');
'@ @'
bs=list.querySelectorAll('.keybtn, .rebind');
'@

SubRx @'
KEYS.waiting=b.getAttribute('data-k'); keysRender(); }; })(bs[i]);
'@ @'
var _kk=b.getAttribute('data-k'); KEYS.waiting=(KEYS.waiting===_kk)?null:_kk; KEYS.note=null; keysRender(); }; })(bs[i]);
'@

SubRx @'
Click an action, then press the key you want on it. Two actions never share a key: they swap. ESC cancels a press. 1 to 9 stay the tactical belt and TAB stays TAB.</div>
'@ @'
Rebind any action to a keyboard key or a side mouse button. The controller layout never changes.</div><div id="keysnote"></div>
'@

SubRx @'
KEYS.waiting=null; keysRender(); openModal('keysmodal');
'@ @'
KEYS.waiting=null; KEYS.note=null; keysRender(); openModal('keysmodal');
'@

SubRx @'
if(KEYS.waiting){ if(ev.code!=='Escape') keysBind(KEYS.waiting,ev.code); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r3){} }
'@ @'
if(KEYS.waiting){ if(ev.code!=='Escape'){ if(!keysBind(KEYS.waiting,ev.code)){ keysRender(); return; } } KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r3){} }   // v25.xx (keyremap): a reserved key says so and the press keeps waiting
'@

SubRx @'
Change which key does what. Two actions never share a key: they swap.
'@ @'
Rebind any action to the key you want. Two actions never share a key: they swap.
'@

SubRx @'
return (s==='WASD')?o.join(''):o.join(' / ');
'@ @'
return (s==='WASD')?o.join(''):o.join(s==='B or I'?' or ':' / ');
'@

SubRx @'
'U':['KeyU'],'F1':['F1']}
'@ @'
'U':['KeyU'],'F1':['F1'],'O':['KeyO'],'ENTER':['Enter'],'B or I':['KeyB','KeyI']}
'@

SubRx @'
ctx.fillText(padB(k[0]),x+LH(6),cy);
'@ @'
ctx.fillText(padB((PAD&&PAD.on)?k[0]:legendKeys(k[0])),x+LH(6),cy);   // v25.xx (keyremap): the full list names the keys as set
'@

SubRx @'
LH(6)+ctx.measureText(padB(_lgk[0])).width
'@ @'
LH(6)+ctx.measureText(padB((PAD&&PAD.on)?_lgk[0]:legendKeys(_lgk[0]))).width
'@

SubRx @'
_lg.push('F1','close this');
'@ @'
_lg.push('F1','close this');   if(!padOn()) for(var _li=0;_li<_lg.length;_li+=2) _lg[_li]=legendKeys(_lg[_li]);   // v25.xx (keyremap): and the Undercroft list names the keys as set
'@

SubRx @'
#root #keyslist .keybtn:hover:not(:disabled){ border-color:var(--acc); background:var(--ui-hover); }
'@ @'
#root #keyslist .keybtn:hover:not(:disabled){ border-color:var(--acc); background:var(--ui-hover); }
  /* v25.xx (keyremap): the REBIND control, the section heads and the note under the title. Graphite, the amber accent, condensed caps, and a
     square frame with one cut corner, as every window. A press waiting turns its keycap solid amber; a clash note has the danger red rail. */
  #root #keyslist .rebind{ min-width:104px; min-height:40px; margin-left:10px; border:1px solid var(--ui-line-hi); background:rgba(0,0,0,.35); color:var(--tx-2);
    font-family:var(--f-cond); font-weight:700; font-size:14px; letter-spacing:.16em; clip-path:polygon(9px 0,100% 0,100% 100%,0 100%,0 9px); }
  #root #keyslist .rebind:hover:not(:disabled){ color:var(--acc); border-color:var(--acc); background:var(--ui-hover); }
  #root #keyslist .keybtn.wait{ color:var(--acc-ink) !important; background:var(--acc) !important; border-color:var(--acc) !important; }
  #root #keyslist .keysec{ margin-top:14px; padding:10px 16px 6px; border-top:1px solid var(--ui-line); font-family:var(--f-cond); font-weight:700; font-size:15px; letter-spacing:.2em; color:var(--acc); }
  #root #keyslist .keysec:first-child{ margin-top:0; border-top:0; }
  #root #keysnote{ max-width:1100px; margin:8px 0 12px; padding:9px 16px; border-left:3px solid var(--ui-line-hi); background:rgba(0,0,0,.28); color:var(--tx-2); min-height:24px;
    font-family:var(--f-cond); font-weight:600; font-size:16px; letter-spacing:.08em; clip-path:polygon(10px 0,100% 0,100% 100%,0 100%,0 10px); }
  #root #keysnote.wait, #root #keysnote.set{ border-left-color:var(--acc); background:var(--acc-dim); color:var(--tx-1); }
  #root #keysnote.clash{ border-left-color:var(--danger); background:rgba(224,92,92,.12); color:var(--tx-1); }
'@

SubRx @'
var VER='25.70';
'@ @'
var VER='25.71';
'@

$pat = "(?m)^  now:'v25\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.71: Settings, CHANGE KEYS now has a REBIND control on every action, shows a clash and swaps, keeps ESC and P, and takes the side mouse buttons. Check 25.71 fails on v25.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
