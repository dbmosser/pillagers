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

# REMAPPABLE KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function togglePauseBox(on){
'@ @'
// v17.75, AAA CHECK (2026-10-02): REMAPPABLE KEYS. Every AAA game lets you change its keys; this one could not. The map lives on
// the profile (P.keymap: the key an action is on, when it is not the default) and is applied where keys enter the game: the
// window keydown and keyup handlers translate the key pressed into the key the game reads, so every reader of keys[] and every
// raidKey branch is unchanged. Two actions never share a key: binding one onto another's key swaps them. The CONTROLS window
// (Settings, CHANGE KEYS) lists the actions; the pause box legend is rebuilt from the map. Prompts in the raid still name
// the defaults in this build.
var KEYS_ACTS=[['KeyW','move up'],['KeyA','move left'],['KeyS','move down'],['KeyD','move right'],['Space','dodge roll'],['ShiftLeft','sprint (hold)'],
  ['ControlLeft','crouch (hold)'],['KeyC','crouch toggle'],['KeyE','interact, search, call for extraction'],['KeyR','reload'],['KeyF','melee strike'],
  ['KeyX','search what you stand on'],['KeyB','backpack'],['KeyI','backpack'],['Enter','equip from the backpack'],['KeyM','map'],['KeyH','controls'],
  ['KeyT','offer an item to a teammate'],['KeyN','ping'],['KeyP','pause']];
var KEYS={inv:null,waiting:null,built:0,inited:0};
function keysMap(){ return (typeof P!=='undefined'&&P&&P.keymap&&typeof P.keymap==='object')?P.keymap:{}; }
function keysInv(){ var m=keysMap(), k, inv={}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&typeof m[k]==='string'&&m[k]!==k) inv[m[k]]=k; KEYS.inv=inv; return inv; }
function keyRemap(code){ var inv=KEYS.inv||keysInv(); if(!KEYS.inited){ KEYS.inited=1; try{ keysLegendApply(); }catch(_kl){} } return (typeof code==='string'&&inv[code])?inv[code]:code; }
function keyRemapEvent(e){
  var c=keyRemap(e.code);
  if(c===e.code) return e;
  return {code:c,key:e.key,repeat:e.repeat,shiftKey:e.shiftKey,ctrlKey:e.ctrlKey,altKey:e.altKey,metaKey:e.metaKey,target:e.target,defaultPrevented:e.defaultPrevented,
          preventDefault:function(){ e.preventDefault(); this.defaultPrevented=true; },stopPropagation:function(){ e.stopPropagation(); }};
}
function keyName(code){
  var T={Space:'SPACE',ShiftLeft:'SHIFT',ShiftRight:'R SHIFT',ControlLeft:'CTRL',ControlRight:'R CTRL',AltLeft:'ALT',AltRight:'R ALT',Enter:'ENTER',Tab:'TAB',Escape:'ESC',Backspace:'BACKSPACE',
    ArrowUp:'UP',ArrowDown:'DOWN',ArrowLeft:'LEFT',ArrowRight:'RIGHT',Semicolon:';',Quote:"'",Comma:',',Period:'.',Slash:'/',Backslash:'\\',BracketLeft:'[',BracketRight:']',Minus:'-',Equal:'=',Backquote:'`',CapsLock:'CAPS'};
  if(T[code]) return T[code];
  if(/^Key[A-Z]$/.test(code)) return code.slice(3);
  if(/^Digit[0-9]$/.test(code)) return code.slice(5);
  if(/^Numpad/.test(code)) return 'NUM '+code.slice(6);
  if(/^F[0-9]+$/.test(code)) return code;
  return String(code||'').toUpperCase();
}
function keysOf(logical){ var m=keysMap(); return (typeof m[logical]==='string')?m[logical]:logical; }
function keysBind(logical,physical){
  var m=keysMap(), k, other=null, old=keysOf(logical), i;
  if(typeof logical!=='string'||typeof physical!=='string'||!physical||physical==='Escape'||physical==='Tab'||/^Digit[1-9]$/.test(physical)) return false;
  if(!P.keymap||typeof P.keymap!=='object') P.keymap={}; m=P.keymap;
  for(i=0;i<KEYS_ACTS.length;i++){ k=KEYS_ACTS[i][0]; if(k!==logical&&keysOf(k)===physical){ other=k; break; } }
  if(!other&&physical!==logical){ for(i=0;i<KEYS_ACTS.length;i++){ k=KEYS_ACTS[i][0]; if(k===physical&&k!==logical&&keysOf(k)===k){ other=k; break; } } }
  m[logical]=physical; if(other) m[other]=old;
  for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)&&m[k]===k) delete m[k];
  KEYS.inv=null; keysInv(); try{ saveProfile(); }catch(_ks){} try{ keysLegendApply(); }catch(_kl2){}
  return true;
}
function keysReset(){ if(P) P.keymap={}; KEYS.inv=null; keysInv(); try{ saveProfile(); }catch(_kr){} try{ keysLegendApply(); }catch(_kl3){} return true; }
function keysLegendHtml(){
  var n=keyName, s=function(c){ return '<b style="color:var(--bone)">'+n(keysOf(c))+'</b>'; };
  return 'MOUSE aim &nbsp; LMB fire &nbsp; RMB aim down sights &nbsp; '+s('KeyW')+s('KeyA')+s('KeyS')+s('KeyD')+' move &nbsp; '+s('Space')+' dodge roll &nbsp; '+s('ShiftLeft')+' hold to sprint &nbsp; '+
    s('ControlLeft')+' / '+s('KeyC')+' crouch &nbsp; '+s('KeyE')+' interact &nbsp; '+s('KeyR')+' reload &nbsp; '+s('KeyF')+' melee strike &nbsp; 1-9 tactical belt &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+
    s('Enter')+' equip from backpack &nbsp; '+s('KeyM')+' map &nbsp; '+s('KeyH')+' controls &nbsp; TAB back out &nbsp; '+s('KeyP')+' / TAB pause';
}
function keysLegendApply(){ var el=document.getElementById('pausekeys'); if(!el) return false; el.innerHTML=keysLegendHtml(); return true; }
function keysRowHtml(){
  var n=0, m=keysMap(), k; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)) n++;
  return '<div class="row"><div style="flex:1"><b>Keys</b><div class="hint">Change which key does what. Two actions never share a key: they swap.</div></div>'+
    '<button id="set_keys" style="padding:6px 12px;min-width:92px'+(n?';color:var(--amber)':'')+'">'+(n?'CHANGED':'CHANGE KEYS')+'</button></div>';
}
function keysListHtml(){
  var i, a, h='';
  for(i=0;i<KEYS_ACTS.length;i++){ a=KEYS_ACTS[i]; h+='<div class="row"><div style="flex:1"><b>'+a[1]+'</b></div><button class="keybtn" data-k="'+a[0]+'" style="padding:6px 12px;min-width:110px'+(keysOf(a[0])!==a[0]?';color:var(--amber)':'')+'">'+(KEYS.waiting===a[0]?'PRESS A KEY':keyName(keysOf(a[0])))+'</button></div>'; }
  return h;
}
function keysRender(){
  var list=document.getElementById('keyslist'), bs, i;
  if(!list) return false;
  list.innerHTML=keysListHtml();
  bs=list.querySelectorAll('.keybtn');
  for(i=0;i<bs.length;i++) bs[i].onclick=(function(b){ return function(){ KEYS.waiting=b.getAttribute('data-k'); keysRender(); }; })(bs[i]);
  return true;
}
function keysOpen(){
  var m=document.getElementById('keysmodal');
  if(!m){
    m=document.createElement('div'); m.className='modal'; m.id='keysmodal';
    m.innerHTML='<h3>Keys</h3><div class="msub">Click an action, then press the key you want on it. Two actions never share a key: they swap. ESC cancels a press. 1 to 9 stay the tactical belt and TAB stays TAB.</div>'+
      '<div id="keyslist"></div><div class="pbox" style="display:flex;gap:8px;margin-top:14px"><button id="keysreset" style="padding:8px 22px">RESET TO DEFAULTS</button><button id="closekeys" style="padding:8px 22px;margin-left:auto">CLOSE</button></div>';
    document.body.appendChild(m);
    document.getElementById('keysreset').onclick=function(){ keysReset(); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r){} };
    document.getElementById('closekeys').onclick=function(){ KEYS.waiting=null; m.classList.remove('on'); try{ renderSettings(); }catch(_r2){} };
  }
  KEYS.waiting=null; keysRender(); openModal('keysmodal');
  return true;
}
try{ window.addEventListener('keydown',function(ev){
  var m=document.getElementById('keysmodal');
  if(!m||!m.classList.contains('on')) return;
  ev.preventDefault(); ev.stopPropagation();
  if(KEYS.waiting){ if(ev.code!=='Escape') keysBind(KEYS.waiting,ev.code); KEYS.waiting=null; keysRender(); try{ renderSettings(); }catch(_r3){} }
  else if(ev.code==='Escape'){ m.classList.remove('on'); }
},true); }catch(_kw){}
function togglePauseBox(on){
'@

SubRx @'
window.addEventListener('keydown',function(e){
  var tn=(e.target&&e.target.tagName)||'';
  if(tn==='TEXTAREA'||tn==='INPUT') return;
'@ @'
window.addEventListener('keydown',function(e){
  var tn=(e.target&&e.target.tagName)||'';
  if(tn==='TEXTAREA'||tn==='INPUT') return;
  e=keyRemapEvent(e);   // v17.75: the key pressed becomes the key the game reads
'@

SubRx @'
window.addEventListener('keyup',function(e){ keys[e.code]=false; if((e.code==='ControlLeft'||e.code==='ControlRight')&&G) G.ctrlUndo=null; });
'@ @'
window.addEventListener('keyup',function(e){ keys[keyRemap(e.code)]=false; if((e.code==='ControlLeft'||e.code==='ControlRight')&&G) G.ctrlUndo=null; });
'@

SubRx @'
  host.innerHTML=_go+kidHeadHtml()+kidRowHtml()+afRowHtml()+kbRowHtml()+   // v17.71: the kid menu
'@ @'
  host.innerHTML=_go+keysRowHtml()+kidHeadHtml()+kidRowHtml()+afRowHtml()+kbRowHtml()+   // v17.71: the kid menu
'@

SubRx @'
  (function(){ var _kb2=document.getElementById('set_kb'); if(_kb2) _kb2.onclick=function(){ kbCycle(); renderSettings(); }; })();   // v17.71: player 2 comes back after death
'@ @'
  (function(){ var _kb2=document.getElementById('set_kb'); if(_kb2) _kb2.onclick=function(){ kbCycle(); renderSettings(); }; })();   // v17.71: player 2 comes back after death
  (function(){ var _kk=document.getElementById('set_keys'); if(_kk) _kk.onclick=function(){ keysOpen(); }; })();   // v17.75: remappable keys
'@

SubRx @'
var VER='17.74';
'@ @'
var VER='17.75';
'@

$pat = "(?m)^  now:'v17\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.75: Settings has CHANGE KEYS: click an action, press the key you want on it. Two actions never share a key, they swap. Check 17.75 fails on v17.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
