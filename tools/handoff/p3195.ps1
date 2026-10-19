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

# PAD CAREER NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padFocusables(root){
'@ @'
// v28.xx (cw-cx-padname), J4: the career name uses the arcade initials letter picker controls.
// His 10-18 order: the name entered on the title goes into the new save.
var PADNAME=null;
function padLetterMove(n,op,A){
  var c;
  if(op==='up'||op==='down'){ c=A.indexOf(n.l[n.pos]); if(c<0)c=0; n.l[n.pos]=A.charAt((c+(op==='up'?1:A.length-1))%A.length); }
  else if(op==='next') n.pos++;
  else if(op==='back'){ if(n.pos>0)n.pos--; }
  else if(op.length===1&&A.indexOf(op)>=0){ n.l[n.pos]=op; n.pos++; }
  else return false;
  return true;
}
function padLetterInput(nw,ax,n,key){
  var op='',i,b,ay=(ax&&+ax[1])||0;
  for(i=0;i<nw.length&&!op;i++){ b=nw[i]; op=b===12?'up':b===13?'down':(b===15||b===0)?'next':(b===14||b===1)?'back':b===9?'done':''; }
  if(!op){ if(Math.abs(ay)<0.3)n[key]=0; else if(!n[key]&&Math.abs(ay)>0.6){ n[key]=1; op=ay<0?'up':'down'; } }
  return op;
}
function padNameClose(keep){
  var n=PADNAME;
  if(!n)return;
  PADNAME=null;
  if(keep){ n.input.value=n.l.join('').trim()||'pillager'; n.input.dispatchEvent(new Event('input',{bubbles:true})); }
  n.card.remove(); padSetFocus(n.input);
}
function padNameDraw(){
  var n=PADNAME,row,i,s;
  if(!n)return;
  row=n.card.querySelector('.pnl'); row.textContent='';
  for(i=0;i<n.l.length;i++){ s=document.createElement('span'); s.textContent=n.l[i]===' '?'\u00a0':n.l[i]; if(i===n.pos)s.className='cur'; row.appendChild(s); }
  n.card.querySelector('.pnhint').textContent=iniHint().toLowerCase();
}
function padNameOp(op){
  var n=PADNAME;
  if(!n||!op)return;
  if(op==='done'){ padNameClose(true); return; }
  if(op==='back'&&n.pos===0){ padNameClose(false); return; }
  if(!padLetterMove(n,op,'abcdefghijklmnopqrstuvwxyz 0123456789-'))return;
  try{ sndUi(op==='next'?'ok':op==='back'?'back':'move'); }catch(_s){}
  if(n.pos>=n.l.length){ padNameClose(true); return; }
  padNameDraw();
}
function padNameStart(input){
  if(PADNAME||!input||input.id!=='pnamein')return false;
  var st,card,v=String(input.value||'pillager').toLowerCase().slice(0,16),l=(v+'                ').slice(0,16).split('');
  if(!document.getElementById('padnamecss')){
    st=document.createElement('style'); st.id='padnamecss';
    st.textContent='#padnamecard{position:absolute;inset:0;z-index:100;display:grid;place-items:center;background:var(--scrim);color:var(--tx-1)}'+
      '#padnamecard .pnbox{box-sizing:border-box;width:min(680px,92%);padding:24px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad)}'+
      '#padnamecard header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}#padnamecard h2{margin:0;font:700 var(--fs-title)/1.2 var(--f-cond)}'+
      '#padnamecard .pnclose{width:48px;height:48px;padding:0;background:transparent;color:var(--tx-2);border:1px solid var(--ui-line-hi);font:600 var(--fs-title)/1 var(--f-cond)}'+
      '#padnamecard .pnl{display:grid;grid-template-columns:repeat(16,minmax(0,1fr));gap:4px;font:600 var(--fs-title)/1.5 var(--f-cond);text-align:center}'+
      '#padnamecard .pnl span{min-width:0;border-bottom:2px solid var(--ui-line-hi)}#padnamecard .pnl .cur{color:var(--acc);border-color:var(--acc);background:var(--ui-raised)}'+
      '#padnamecard .pnhint{margin-top:24px;color:var(--tx-2);font:600 var(--fs-label)/1.5 var(--f-cond)}'+
      '#padnamecard footer{display:flex;justify-content:flex-end;margin-top:24px}#padnamecard .pndone{min-height:48px;padding:8px 32px;background:var(--acc);color:var(--acc-ink);border:0;border-radius:var(--rad);font:600 var(--fs-body)/1 var(--f-cond)}';
    document.head.appendChild(st);
  }
  card=document.createElement('div'); card.id='padnamecard'; card.setAttribute('role','dialog'); card.setAttribute('aria-modal','true'); card.setAttribute('aria-labelledby','padnametitle');
  card.innerHTML='<section class="pnbox"><header><h2 id="padnametitle">pillager name</h2><button class="pnclose" aria-label="cancel">\u00d7</button></header><div class="pnl"></div><div class="pnhint"></div><footer><button class="pndone">done</button></footer></section>';
  PADNAME={input:input,l:l,pos:0,ay:1,card:card};
  card.querySelector('.pnclose').onclick=function(){padNameClose(false);}; card.querySelector('.pndone').onclick=function(){padNameClose(true);};
  document.getElementById('root').appendChild(card); input.blur(); padNameDraw(); return true;
}
function padNamePoll(pressed){
  var n=PADNAME,nw=[],i;
  if(!n)return false;
  if(!document.getElementById('title').classList.contains('on')){padNameClose(false);return false;}
  for(i=0;i<17;i++){ if(pressed(i)&&!PAD.prev[i])nw.push(i); PAD.prev[i]=pressed(i); }
  padNameOp(padLetterInput(nw,PAD.ax,n,'ay')); return true;
}
// v28.xx (cw-cx-padname): a keyboard can finish or cancel a picker opened with a pad, without starting the title underneath.
window.addEventListener('keydown',function(e){
  if(!PADNAME||e.ctrlKey||e.altKey||e.metaKey||/^F\d+$/.test(e.code||''))return;
  e.preventDefault(); e.stopImmediatePropagation();
  if(e.repeat)return;
  if(e.key==='Escape'){padNameClose(false);return;}
  var op={ArrowUp:'up',ArrowDown:'down',ArrowLeft:'back',Backspace:'back',ArrowRight:'next',Tab:'next',Enter:'done'}[e.key];
  if(!op&&e.key&&e.key.length===1)op=e.key.toLowerCase();
  padNameOp(op);
},true);
function careerNewReload(){ location.reload(); }
function padFocusables(root){
'@

SubRx @'
    var el=q[i],cs=getComputedStyle(el);
'@ @'
    var el=q[i],cs=getComputedStyle(el);
    // v28.xx (cw-cx-padname), J4: only the career name has a pad text route. Delete and reset words remain keyboard only.
    if(el.tagName==='TEXTAREA'||el.isContentEditable||(el.tagName==='INPUT'&&el.id!=='pnamein'&&!/^(button|submit|reset|checkbox|radio|range)$/.test(el.type)))continue;
'@

SubRx @'
function padMenu(pressed){
'@ @'
function padMenu(pressed){
  if(padNamePoll(pressed)) return true; // v28.xx (cw-cx-padname): spend every picker press before title navigation.
'@

SubRx @'
  if(tap(0)&&PAD.focus){ PAD.aSpent=1; if(md.id==='outcome'&&haulRevealSkip()){} else if(md.id==='outcome'&&PAD.focus.id==='oc_btn'&&ocLbNext()){} else if(!stashPadAct(PAD.focus)) PAD.focus.click(); }   // v26.xx (career7): A on the card skips the haul reveal first
'@ @'
  if(tap(0)&&PAD.focus){ PAD.aSpent=1; if(md.id==='outcome'&&haulRevealSkip()){} else if(md.id==='outcome'&&PAD.focus.id==='oc_btn'&&ocLbNext()){} else if(PAD.focus.id==='pnamein') padNameStart(PAD.focus); else if(!stashPadAct(PAD.focus)) PAD.focus.click(); }   // v26.xx (career7): A on the card skips the haul reveal first
'@

SubRx @'
  if(op==='up'||op==='down'){ c=A.indexOf(n.l[n.pos]); if(c<0) c=0; n.l[n.pos]=A.charAt((c+(op==='up'?1:25))%26); }
  else if(op==='next') n.pos++;
  else if(op==='back'){ if(n.pos>0) n.pos--; }
  else if(op.length===1&&A.indexOf(op.toUpperCase())>=0){ n.l[n.pos]=op.toUpperCase(); n.pos++; }
  else return n.l.join('');
'@ @'
  if(!padLetterMove(n,op.length===1?op.toUpperCase():op,A)) return n.l.join(''); // v28.xx (cw-cx-padname): shared initials letter stepping.
'@

SubRx @'
  var op='', i, b, ay=(ax&&+ax[1])||0;
  nw=nw||[];
  for(i=0;i<nw.length&&!op;i++){ b=nw[i]; op=(b===12)?'up':(b===13)?'down':(b===15||b===0)?'next':(b===14||b===1)?'back':(b===9)?'done':''; }
  if(!op){
    if(Math.abs(ay)<0.3) ARCADE.iniAy=0;
    else if(!ARCADE.iniAy&&Math.abs(ay)>0.6){ ARCADE.iniAy=1; op=(ay<0)?'up':'down'; }
  }
  if(op){ if(ARCADE.ini.mirror)
'@ @'
  var op=padLetterInput(nw||[],ax,ARCADE,'iniAy'); // v28.xx (cw-cx-padname): shared initials pad controls.
  if(op){ if(ARCADE.ini.mirror)
'@

SubRx @'
    if(ng) ng.onclick=function(){
      for(var sn=1;sn<=8;sn++){
        var key=String(sn);
        if(!slotInfo(key)&&key!==SLOT&&!slotBlocked(key)){
          fsMark();   // v11.02, his note 8
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window
          if(!netSaveLocked()) newNameKeep(pin&&pin.value,key,pin&&pin.__typed);   // v30.xx (cw-newsavename): the typed name goes with the new save
          location.reload(); return;
'@ @'
    if(ng) ng.onclick=function(){
      for(var sn=1;sn<=8;sn++){
        var key=String(sn);
        if(!slotInfo(key)&&key!==SLOT&&!slotBlocked(key)){
          fsMark();   // v11.02, his note 8
          try{ if(!netSaveLocked()) localStorage.setItem(slotPtrKey(),key); }catch(e){}   // v15.74: a ?netslot copy never moves the save pointer; v15.76: nor the player 2 window
          if(!netSaveLocked()) newNameKeep(pin&&pin.value,key,pin&&pin.__typed);   // v30.xx (cw-newsavename): the typed name goes with the new save
          careerNewReload(); return;
'@

SubRx @'
      <div class="brand">PILLAGERS <span id="verlabel"></span></div>
'@ @'
      <!-- v28.xx (cw-cx-padname), J4: the stash identifies the save by the name entered on the title. --><div class="brand"><span id="stashname">pillager</span> <span id="verlabel"></span></div>
'@

SubRx @'
function renderHub(){
'@ @'
function renderHub(){
  var _pn=document.getElementById('stashname'); if(_pn)_pn.textContent=String(P.pname||'pillager').toLowerCase(); // v28.xx (cw-cx-padname): save ownership in the stash.
'@

SubRx @'
var VER='31.94';
'@ @'
var VER='31.95';
'@

$pat = "(?m)^  now:'v31\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.95: Name a career save with the pad: up or down for a letter, A next, B back, Menu done. The stash shows the saved name. Check 31.95 fails on v31.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
