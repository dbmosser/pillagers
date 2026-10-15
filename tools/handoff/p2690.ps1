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

# THE OPERATOR MENU: NEW PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(e.repeat) return true;
  try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_tp){}
  arcadeLeave();
  return true;
}
'@ @'
  if(e.repeat) return true;
  if(!ARCOP&&!(G&&G.arcade&&!G.over)&&!arcadeIniLive()&&arcadeOpOpen()) return true;   // v26.xx (party5): on the attract it opens the OPERATOR menu
  try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_tp){}
  arcadeOpClose();
  arcadeLeave();
  return true;
}
// v26.xx (party5), HIS ANSWER 22 (2026-10-12): "a", a NEW PARTY reset in the operator menu. THE OPERATOR MENU. On the attract the
// operator chord (Ctrl+Shift+F10) now opens a small OPERATOR card instead of leaving at once. NEW PARTY starts tonights board again
// (the 1 and 2 player lists both; BEST EVER stays), and asks once more first: the first press arms it, the second clears. EXIT DEMO
// leaves the arcade as the chord did, and the chord again with the card up also leaves, so two presses still get the operator out.
// BACK or ESC closes the card. Up and down (or W and S) move, ENTER or SPACE picks, a click picks a row. While the card is up no
// key, click or pad press drops anybody in. In an arcade raid the chord still leaves at once. The party start is its own key
// (ARCADE_PARTY_KEY, never his save); tonights board counts only runs after it.
var ARCADE_PARTY_KEY='pillagers:arcade:party';
var ARCOP=null;   // {el, ix, arm, note}
function arcadePartyAt(){ var t=0; try{ t=+localStorage.getItem(ARCADE_PARTY_KEY)||0; }catch(_pa){ t=0; } return t; }
function arcadeNewParty(){
  try{ localStorage.setItem(ARCADE_PARTY_KEY,String(Date.now())); }catch(_np){ return false; }
  try{ if(ARCADE.att) ARCADE.att.ph=''; }catch(_ap){}   // the board page draws again
  return true;
}
function arcadeOpRows(){ return [{id:'party',label:(ARCOP&&ARCOP.arm)?'CONFIRM NEW PARTY':'NEW PARTY'},{id:'exit',label:'EXIT DEMO'},{id:'back',label:'BACK'}]; }
function arcadeOpOpen(){
  if(ARCOP) return true;
  if(!ARCADE.on||!document.body) return false;
  var el=document.createElement('div'); el.id='arcop';
  el.style.cssText='position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);z-index:20000;width:420px;box-sizing:border-box;padding:22px 24px 20px;'+
    'background:var(--ui-bg);border:1px solid var(--ui-line);box-shadow:0 24px 64px rgba(0,0,0,.6);color:var(--tx-1);font:var(--t-body);cursor:default;'+
    'clip-path:polygon(12px 0,100% 0,100% 100%,0 100%,0 12px)';
  try{ el.style.zoom=menuScale(); }catch(_mz){}
  el.addEventListener('contextmenu',function(_ev){ _ev.preventDefault(); return false; });
  var bd=document.createElement('div'); bd.style.cssText='position:fixed;left:0;top:0;right:0;bottom:0;z-index:19999;background:rgba(0,0,0,.66)';   // the attract dims behind the card
  document.body.appendChild(bd); document.body.appendChild(el);
  ARCOP={el:el,bd:bd,ix:0,arm:0,note:''};
  arcadeOpDraw();
  return true;
}
function arcadeOpClose(){ if(!ARCOP) return false; try{ if(ARCOP.el&&ARCOP.el.parentNode) ARCOP.el.parentNode.removeChild(ARCOP.el); if(ARCOP.bd&&ARCOP.bd.parentNode) ARCOP.bd.parentNode.removeChild(ARCOP.bd); }catch(_rc){} ARCOP=null; return true; }
function arcadeOpDraw(){
  if(!ARCOP) return;
  var el=ARCOP.el, rows=arcadeOpRows(), n=0, i, d;
  try{ n=arcadeBoardTonight(Date.now(),1).length+arcadeBoardTonight(Date.now(),2).length; }catch(_bt){ n=0; }
  el.innerHTML='';
  d=document.createElement('div'); d.style.cssText='width:48px;height:2px;background:var(--acc);margin:-22px 0 18px';
  el.appendChild(d);
  d=document.createElement('div'); d.textContent='OPERATOR'; d.style.cssText='font:var(--t-h2);letter-spacing:.08em;color:var(--tx-1)';
  el.appendChild(d);
  d=document.createElement('div'); d.textContent='DEMO  \u00b7  TONIGHT: '+n+' RUN'+(n===1?'':'S')+' ON THE BOARD'; d.style.cssText='font:var(--t-label);letter-spacing:.1em;color:var(--tx-2);margin:4px 0 16px';
  el.appendChild(d);
  for(i=0;i<rows.length;i++){
    (function(ix,r){
      var b=document.createElement('button');
      b.setAttribute('data-op',r.id); b.textContent=r.label;
      b.onmouseenter=function(){ if(!ARCOP||ARCOP.ix===ix) return; ARCOP.ix=ix; if(ARCOP.arm&&ix!==0){ ARCOP.arm=0; ARCOP.note=''; arcadeOpDraw(); return; } arcadeOpStyle(); };
      b.onclick=function(ev){ try{ ev.stopPropagation(); }catch(_s){} arcadeOpPick(ix); };
      el.appendChild(b);
    })(i,rows[i]);
  }
  d=document.createElement('div'); d.className='arcopnote'; d.textContent=ARCOP.note||'\u2191\u2193 SELECT  \u00b7  ENTER CONFIRM  \u00b7  ESC BACK';
  d.style.cssText='font:var(--t-label);letter-spacing:.1em;margin-top:16px;color:'+(ARCOP.note?(ARCOP.arm?'var(--danger)':'var(--ok)'):'var(--tx-3)');
  el.appendChild(d);
  arcadeOpStyle();
}
function arcadeOpStyle(){
  if(!ARCOP) return;
  var bs=ARCOP.el.querySelectorAll('button[data-op]'), i, on, red;
  for(i=0;i<bs.length;i++){
    on=(i===ARCOP.ix); red=(i===0&&ARCOP.arm);
    bs[i].style.cssText='display:block;width:100%;height:44px;margin:8px 0 0;padding:0 16px;text-align:left;cursor:pointer;border-radius:2px;'+
      'font:var(--t-button);letter-spacing:.08em;box-shadow:none;outline:none;'+
      'background:'+(on?(red?'rgba(229,72,47,.16)':'var(--acc-dim)'):'var(--ui-raised)')+';'+
      'color:'+(red?'var(--danger)':'var(--tx-1)')+';'+
      'border:1px solid '+(red?'var(--danger)':(on?'var(--acc)':'var(--ui-line)'))+';'+
      'border-left:'+(on?('4px solid '+(red?'var(--danger)':'var(--acc)')):'1px solid var(--ui-line)');
  }
}
function arcadeOpMove(d){
  if(!ARCOP) return;
  var n=arcadeOpRows().length;
  ARCOP.ix=(ARCOP.ix+d+n)%n;
  if(ARCOP.arm){ ARCOP.arm=0; ARCOP.note=''; arcadeOpDraw(); return; }
  arcadeOpStyle();
}
function arcadeOpPick(ix){
  if(!ARCOP) return false;
  var r=arcadeOpRows()[ix]; if(!r) return false;
  ARCOP.ix=ix;
  if(r.id==='party'){
    if(!ARCOP.arm){ ARCOP.arm=1; ARCOP.note='CLEARS TONIGHT\u2019S BEST  \u00b7  BEST EVER STAYS'; arcadeOpDraw(); return true; }
    ARCOP.arm=0;
    ARCOP.note=arcadeNewParty()?'NEW PARTY  \u00b7  BOARD CLEARED':'COULD NOT CLEAR THE BOARD';
    try{ sfx('pick'); }catch(_sp){}
    arcadeOpDraw(); return true;
  }
  if(r.id==='exit'){
    arcadeOpClose();
    try{ if(typeof pauseOpen!=='undefined'&&pauseOpen) togglePauseBox(false); }catch(_tp2){}
    arcadeLeave(); return true;
  }
  arcadeOpClose(); return true;
}
// A key, click or touch while the operator menu is up. A click inside the card goes on to its row.
function arcadeOpKey(e){
  var ty=String(e.type||''), cd=String(e.code||'');
  if(ty==='mousedown'||ty==='touchstart'){
    if(ARCOP&&ARCOP.el&&e.target&&ARCOP.el.contains(e.target)) return false;
    try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
    return true;
  }
  if(ty!=='keydown') return false;
  if(/^F([1-9]|1[0-2])$/.test(cd)) return false;
  try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x2){}
  if(e.repeat) return true;
  if(cd==='Escape'||cd==='Backspace') arcadeOpClose();
  else if(cd==='ArrowUp'||cd==='KeyW') arcadeOpMove(-1);
  else if(cd==='ArrowDown'||cd==='KeyS') arcadeOpMove(1);
  else if(cd==='Enter'||cd==='NumpadEnter'||cd==='Space') arcadeOpPick(ARCOP?ARCOP.ix:0);
  return true;
}
'@

SubRx @'
  if(arcadeOpChord(e)) return true;   // v23.44 (arcade21): Ctrl+Shift+F10, the only way out
'@ @'
  if(arcadeOpChord(e)) return true;   // v23.44 (arcade21): Ctrl+Shift+F10, the only way out
  if(ARCOP) return arcadeOpKey(e);   // v26.xx (party5): the operator menu takes the keys and clicks
'@

SubRx @'
function arcadePadAtt(anyNew,aNew){
  if(!ARCADE.on) return false;
'@ @'
function arcadePadAtt(anyNew,aNew){
  if(!ARCADE.on) return false;
  if(ARCOP) return true;   // v26.xx (party5): no drop-in while the operator menu is up
'@

SubRx @'
function arcadeLeave(){
  if(!ARCADE.on) return false;
'@ @'
function arcadeLeave(){
  try{ arcadeOpClose(); }catch(_oc){}   // v26.xx (party5)
  if(!ARCADE.on) return false;
'@

SubRx @'
  for(i=0;i<r.length;i++) if(arcadeBoardIn(r[i],md)&&r[i].t>=now-ARCADE_BOARD.night&&r[i].t<=now+60000) out.push(r[i]);
'@ @'
  var since=Math.max(now-ARCADE_BOARD.night,(typeof arcadePartyAt==='function')?arcadePartyAt():0);   // v26.xx (party5): or since NEW PARTY
  for(i=0;i<r.length;i++) if(arcadeBoardIn(r[i],md)&&r[i].t>=since&&r[i].t<=now+60000) out.push(r[i]);
'@

SubRx @'
var VER='26.89';
'@ @'
var VER='26.90';
'@

$pat = "(?m)^  now:'v26\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.90: On the DEMO attract, Ctrl+Shift+F10 opens the OPERATOR menu: NEW PARTY clears tonights board, EXIT DEMO leaves. Check 26.90 fails on v26.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
