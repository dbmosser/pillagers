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

# The operator menu is a Panel P card with sentence case and 56px buttons (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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
  d=document.createElement('div'); d.textContent='DEMO  \u00b7  TONIGHT: '+n+' RUN'+(n===1?'':'S')+' ON THE BOARD'+(arcadePartyCode()?'  \u00b7  SEED '+arcadePartyCode():''); d.style.cssText='font:var(--t-label);letter-spacing:.1em;color:var(--tx-2);margin:4px 0 16px';
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
    if(!ARCOP.arm){ ARCOP.arm=1; ARCOP.note='CLEARS TONIGHT\u2019S BEST  \u00b7  NEW SEED  \u00b7  BEST EVER STAYS'; arcadeOpDraw(); return true; }
    ARCOP.arm=0;
    ARCOP.note=arcadeNewParty()?'NEW PARTY  \u00b7  BOARD CLEARED  \u00b7  SEED '+arcadePartyCode():'COULD NOT CLEAR THE BOARD';
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

'@ @'
// v28.xx (cw-party-op): the critic scored the operator menu 2 of 5 (look book: "modal ~418x282px, 11px subtitle and hint, all caps, different panel style than
// the scoreboard, Back is a list button"). Now Panel P: 640px, 32px padding, the 3px accent tab, title 32px, subtitle 16px, three 56px buttons 16px apart,
// Exit demo set apart 32px as the danger one, 82% scrim, sentence case, no footer hint (a note shows only after New party).
function arcadeOpRows(){ return [{id:'party',label:(ARCOP&&ARCOP.arm)?'Confirm new party':'New party'},{id:'exit',label:'Exit demo'},{id:'back',label:'Back'}]; }
function arcadeOpOpen(){
  if(ARCOP) return true;
  if(!ARCADE.on||!document.body) return false;
  var el=document.createElement('div'); el.id='arcop';
  el.style.cssText='position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);z-index:20000;width:640px;box-sizing:border-box;padding:var(--sp-4);'+
    'background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);box-shadow:0 24px 64px rgba(0,0,0,.6);color:var(--tx-1);font:600 var(--fs-body)/1.3 var(--f-cond);letter-spacing:var(--track);cursor:default';
  try{ el.style.zoom=menuScale(); }catch(_mz){}
  el.addEventListener('contextmenu',function(_ev){ _ev.preventDefault(); return false; });
  var bd=document.createElement('div'); bd.style.cssText='position:fixed;left:0;top:0;right:0;bottom:0;z-index:19999;background:var(--ui-scrim)';   // the attract is hidden behind the card
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
  d=document.createElement('div'); d.style.cssText='position:absolute;left:var(--sp-4);top:-1px;width:var(--sp-5);height:3px;background:var(--acc)';
  el.appendChild(d);
  d=document.createElement('div'); d.className='arcoptitle'; d.textContent='Operator'; d.style.cssText='font:700 var(--fs-title)/1.1 var(--f-cond);letter-spacing:var(--track);color:var(--tx-1)';
  el.appendChild(d);
  d=document.createElement('div'); d.className='arcopsub'; d.textContent='Tonight: '+n+' run'+(n===1?'':'s')+(arcadePartyCode()?'  \u00b7  Seed '+arcadePartyCode():''); d.style.cssText='font:600 var(--fs-label)/1.3 var(--f-cond);letter-spacing:var(--track);color:var(--tx-2);margin:var(--sp-1) 0 var(--sp-2)';
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
  if(ARCOP.note){
    d=document.createElement('div'); d.className='arcopnote'; d.textContent=ARCOP.note;
    d.style.cssText='font:600 var(--fs-label)/1.3 var(--f-cond);letter-spacing:var(--track);margin-top:var(--sp-3);color:'+(ARCOP.arm?'var(--danger)':'var(--ok)');
    el.appendChild(d);
  }
  arcadeOpStyle();
}
function arcadeOpStyle(){
  if(!ARCOP) return;
  var bs=ARCOP.el.querySelectorAll('button[data-op]'), i, on, red, ex, bg, fg, bc;
  for(i=0;i<bs.length;i++){
    on=(i===ARCOP.ix); ex=(bs[i].getAttribute('data-op')==='exit'); red=((i===0&&ARCOP.arm)||ex);
    bg=on?(red?'var(--danger-bg)':'var(--acc)'):'var(--ui-raised)';
    fg=on?(red?'var(--danger)':'var(--acc-ink)'):(red?'var(--danger)':'var(--tx-1)');
    bc=red?'var(--danger)':(on?'var(--acc)':'var(--ui-line-hi)');
    bs[i].style.cssText='display:block;box-sizing:border-box;width:100%;height:var(--btn-h);margin:'+(ex?'var(--sp-4)':'var(--sp-2)')+' 0 0;padding:0 var(--sp-3);text-align:left;cursor:pointer;border-radius:var(--rad);'+
      'font:700 var(--fs-body)/1 var(--f-cond);letter-spacing:var(--track);box-shadow:none;outline:none;'+
      'background:'+bg+';color:'+fg+';border:'+(on?'2px':'1px')+' solid '+bc;
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
    if(!ARCOP.arm){ ARCOP.arm=1; ARCOP.note='Clears tonight\u2019s best  \u00b7  New seed'; arcadeOpDraw(); return true; }
    ARCOP.arm=0;
    ARCOP.note=arcadeNewParty()?'Board cleared  \u00b7  Seed '+arcadePartyCode():'Could not clear the board';
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
'@

SubRx @'
var VER='29.43';
'@ @'
var VER='29.44';
'@

$pat = "(?m)^  now:'v29\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.44: The operator menu is a bigger, cleaner card with an accent tab. Check 29.44 fails on v29.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
