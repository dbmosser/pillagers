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

# F8 is an in game snipping tool: it freezes the game, you drag a box, then copy it or save it (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v11.52, HIS NOTE: credits and XP shown at all times in the upper right, in
'@ @'
// v30.xx (cw-snip), HIS ORDER (2026-10-18): "add one that is an in game snipping tool so it pauses the game and i can snip whatever portion of the page that i like to send it to you", and then "i want
// option to copy to clipboard so i can easily send it wherever I want". F8 (free, and next to F2) is the snip key. It freezes the game through the SAME freeze the Edit the words key built (devFreeze, so one
// freeze, not two), dims the screen a little and turns the cursor into a cross. He drags a box (outline and size in px); on release the box is cut out, the game stays frozen, and a small panel beside the box
// has two buttons: COPY (the picture to the clipboard) and SAVE (the same two files the Feedback window writes, through the collector into exports/). Either, then the other, as often as he likes. ESC, F8 or
// a click anywhere outside the panel ends it; only then does the game carry on, and the click that ended it is eaten so it fires no shot. The picture is the screen at the moment F8 was pressed: the two canvases
// (the same ones the Feedback shot composes) with the page elements (menus, windows, the upper right block, toasts) laid over them. The page elements are drawn from a copy of the page rendered as a picture,
// which takes a moment; copy and save simply wait for it. Only on this machine (DEV_LOCAL). Mouse and keyboard only: the pad is not read while a snip is up, so a pad press cannot reach a menu under it.
var SNIP={on:0,ph:'',dom:1,domBusy:0,domState:'',domP:null,gen:0,base:null,k:1,box:null,d:null,acted:0,eat:0,said:'',png:'',ov:null,bx:null,sz:null,ht:null,pn:null};
function snipSay(t){ SNIP.said=t; try{ hubToast(t); }catch(_h){} }
function snipWhy(e){ var m=''; try{ m=(e&&(e.message||e.name))||String(e||''); }catch(_m){} m=String(m).toLowerCase().replace(/\s+/g,' ').slice(0,60); return m||'unknown'; }
function snipBlob(d){
  var s=atob(String(d).slice(String(d).indexOf(',')+1)), n=s.length, u=new Uint8Array(n), i;
  for(i=0;i<n;i++) u[i]=s.charCodeAt(i);
  return new Blob([u],{type:'image/png'});
}
function snipPt(e){ return {x:Math.max(0,Math.min(window.innerWidth,Math.round(e.clientX||0))),y:Math.max(0,Math.min(window.innerHeight,Math.round(e.clientY||0)))}; }
function snipRect(a,p){ return {x:Math.min(a.x,p.x),y:Math.min(a.y,p.y),w:Math.abs(a.x-p.x),h:Math.abs(a.y-p.y)}; }
// The box cut out of the picture of the whole window, at the HUD canvas ratio (DPRH, the screen own ratio capped at 2): a 240 x 180 box on a 2x screen is a 480 x 360 file.
function snipCut(base,b,k){
  var sx, sy, sw, sh, c, x;
  if(!base||!b||!(b.w>0&&b.h>0)) return '';
  sx=Math.max(0,Math.round(b.x*k)); sy=Math.max(0,Math.round(b.y*k));
  sw=Math.max(1,Math.min(base.width-sx,Math.round(b.w*k))); sh=Math.max(1,Math.min(base.height-sy,Math.round(b.h*k)));
  c=document.createElement('canvas'); c.width=sw; c.height=sh; x=c.getContext('2d');
  try{ x.drawImage(base,sx,sy,sw,sh,0,0,sw,sh); return c.toDataURL('image/png'); }catch(e){ return ''; }
}
// The whole window as the game draws it: the world canvas and the HUD canvas, as fbShot composes them, placed where they sit in the window.
function snipBase(){
  var k=DPRH||1, c=document.createElement('canvas'), x, r;
  c.width=Math.max(1,Math.round(window.innerWidth*k)); c.height=Math.max(1,Math.round(window.innerHeight*k));
  x=c.getContext('2d'); x.fillStyle='#000'; x.fillRect(0,0,c.width,c.height);
  try{ r=cv.getBoundingClientRect(); x.drawImage(cv,Math.round(r.left*k),Math.round(r.top*k),Math.round(r.width*k),Math.round(r.height*k)); }catch(_a){}
  try{ if(hcv&&hcv.width>0&&hcv.height>0){ r=hcv.getBoundingClientRect(); x.drawImage(hcv,Math.round(r.left*k),Math.round(r.top*k),Math.round(r.width*k),Math.round(r.height*k)); } }catch(_b){}
  return c;
}
// The page elements (menus, windows, the upper right block, toasts) are not on either canvas. A copy of the page is made NOW (the screen at the moment of the key), the scripts and the two big canvases left out,
// the small canvases turned into pictures, the scroll offsets and typed text kept, and it is rendered as an SVG picture and laid over the canvases. It takes a moment, so SNIP.domBusy says so; if it fails the
// snip is the canvases alone and the note says "page layer failed". SNIP.dom = 0 turns the layer off (the check does that, since a check cannot wait).
function snipDomStart(base,k,gen){
  var ob=document.body, vw=Math.round(window.innerWidth), vh=Math.round(window.innerHeight), cb, oa, ca, n, i, j, o, c, t, im, a, kid, sl, st, rm, rt, ser, svg, sb, done=0, tm=0;
  cb=ob.cloneNode(true);
  oa=ob.querySelectorAll('*'); ca=cb.querySelectorAll('*'); n=Math.min(oa.length,ca.length);
  for(i=0;i<n;i++){
    o=oa[i]; c=ca[i]; t=o.tagName;
    if(t==='SCRIPT') continue;
    if(t==='CANVAS'){
      if(o.id==='cv'||o.id==='hcv'||!(o.width>0&&o.height>0)){ c.setAttribute('data-snipdrop','1'); continue; }
      try{ im=document.createElement('img'); im.src=o.toDataURL('image/png'); for(j=0;j<c.attributes.length;j++){ a=c.attributes[j]; im.setAttribute(a.name,a.value); } c.parentNode.replaceChild(im,c); }catch(_c){ c.setAttribute('data-snipdrop','1'); }
      continue;
    }
    if(t==='TEXTAREA') c.textContent=o.value;
    else if(t==='INPUT'){ c.setAttribute('value',o.value); if(o.checked) c.setAttribute('checked','checked'); else c.removeAttribute('checked'); }
    sl=o.scrollLeft|0; st=o.scrollTop|0;
    if(sl||st){ for(kid=c.firstElementChild;kid;kid=kid.nextElementSibling) kid.style.transform='translate('+(-sl)+'px,'+(-st)+'px)'; }
  }
  rm=cb.querySelectorAll('script,[data-snipdrop],#snipov,#snipbox,#snipsz,#sniphint,#snippanel');
  for(i=0;i<rm.length;i++) if(rm[i].parentNode) rm[i].parentNode.removeChild(rm[i]);
  cb.style.cssText='margin:0;padding:0;position:relative;overflow:hidden;display:block;width:'+vw+'px;height:'+vh+'px';
  cb.style.setProperty('background','transparent','important');
  rt=cb.querySelector('#root'); if(rt) rt.style.setProperty('background','transparent','important');
  ser=new XMLSerializer().serializeToString(cb).replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g,'');
  svg='<svg xmlns="http://www.w3.org/2000/svg" width="'+vw+'" height="'+vh+'"><foreignObject x="0" y="0" width="'+vw+'" height="'+vh+'">'+ser+'</foreignObject></svg>';
  sb=new Blob([svg],{type:'image/svg+xml;charset=utf-8'});   // read back as a data: address, since a blob: address taints the canvas it is drawn on and a data: one does not
  SNIP.domBusy=1; SNIP.domState='busy';
  SNIP.domP=new Promise(function(res){
    var img=new Image();
    function fin(ok){
      if(done) return; done=1;
      if(tm){ clearTimeout(tm); tm=0; }
      if(SNIP.gen===gen){ SNIP.domBusy=0; SNIP.domState=ok?'on':'failed'; }
      res(!!ok);
    }
    img.onload=function(){
      var ok=0, tc;
      if(done) return;
      try{ tc=document.createElement('canvas'); tc.width=tc.height=1; tc.getContext('2d').drawImage(img,0,0,1,1); tc.toDataURL(); base.getContext('2d').drawImage(img,0,0,base.width,base.height); ok=1; }catch(_t){}
      fin(ok);
    };
    img.onerror=function(){ fin(0); };
    tm=setTimeout(function(){ tm=0; fin(0); },6000);
    try{ var fr=new FileReader(); fr.onload=function(){ try{ img.src=fr.result; }catch(_s){ fin(0); } }; fr.onerror=function(){ fin(0); }; fr.readAsDataURL(sb); }catch(_f){ fin(0); }
  });
}
function snipNote(b){
  var raid=false, mp='', m;
  try{ raid=!!(state==='raid'&&G&&!G.over); }catch(_r){}
  try{ if(raid){ m=FIXED_MAPS[clamp(P.mapIx||0,0,FIXED_MAPS.length-1)]; if(m&&m.name) mp=', map '+String(m.name).toLowerCase(); } }catch(_m){}
  return 'snip, build '+VER+', '+(raid?'in a raid':'screen '+String(state))+mp+', box '+b.x+','+b.y+' '+b.w+'x'+b.h+' px (page), page layer '+(SNIP.domState||'off');
}
function snipUi(){
  var host=document.getElementById('root')||document.body, plate='position:fixed;z-index:9502;background:rgba(11,12,13,.92);border:1px solid var(--ui-line-hi);pointer-events:none;white-space:nowrap;font:700 14px/1.3 var(--f-cond);letter-spacing:.08em;', ov, bx, sz, ht;
  ov=document.createElement('div'); ov.id='snipov';
  ov.style.cssText='position:fixed;left:0;top:0;width:100%;height:100%;z-index:9500;cursor:crosshair;background:rgba(0,0,0,.3);user-select:none;-webkit-user-select:none';
  bx=document.createElement('div'); bx.id='snipbox';
  bx.style.cssText='position:fixed;display:none;box-sizing:border-box;z-index:9501;border:2px solid var(--acc);box-shadow:0 0 0 100vmax rgba(0,0,0,.5);pointer-events:none';
  sz=document.createElement('div'); sz.id='snipsz'; sz.style.cssText=plate+'display:none;padding:2px 8px 1px;color:var(--tx-1);font-size:13px';
  ht=document.createElement('div'); ht.id='sniphint'; ht.style.cssText=plate+'left:8px;top:68px;padding:3px 12px 2px;color:var(--acc)';
  ht.textContent='snip: drag a box. esc cancels.';
  host.appendChild(ov); host.appendChild(bx); host.appendChild(sz); host.appendChild(ht);
  SNIP.ov=ov; SNIP.bx=bx; SNIP.sz=sz; SNIP.ht=ht;
  try{ var tt=document.getElementById('hubtoast'); if(tt) tt.style.zIndex='9600'; }catch(_z){}   // the toast stays above the dim
}
function snipPaint(){
  var b=SNIP.box, bx=SNIP.bx, sz=SNIP.sz, k=SNIP.k, y, x;
  if(!bx||!sz) return;
  if(!b){ bx.style.display='none'; sz.style.display='none'; if(SNIP.ov) SNIP.ov.style.background='rgba(0,0,0,.3)'; return; }
  if(SNIP.ov) SNIP.ov.style.background='transparent';
  bx.style.display='block'; bx.style.left=b.x+'px'; bx.style.top=b.y+'px'; bx.style.width=b.w+'px'; bx.style.height=b.h+'px';
  sz.textContent=b.w+' x '+b.h+' px'+(k!==1?', '+Math.round(b.w*k)+' x '+Math.round(b.h*k)+' image':'');
  sz.style.display='block';
  x=Math.max(4,Math.min(window.innerWidth-160,b.x)); y=b.y-26;
  if(y<4){ y=b.y+4; x=Math.max(4,Math.min(window.innerWidth-160,b.x+4)); }
  sz.style.left=x+'px'; sz.style.top=y+'px';
}
function snipPanel(){
  var host=document.getElementById('root')||document.body, b=SNIP.box, pn=document.createElement('div'), vw=window.innerWidth, vh=window.innerHeight, r, x, y;
  pn.id='snippanel';
  pn.style.cssText='position:fixed;left:0;top:0;z-index:9503;display:flex;gap:8px;padding:8px;background:rgba(11,12,13,.94);border:1px solid var(--ui-line-hi);cursor:default';
  pn.innerHTML='<button type="button" data-snip="copy" style="min-width:104px">copy</button><button type="button" data-snip="save" style="min-width:104px">save</button>';
  host.appendChild(pn);
  r=pn.getBoundingClientRect();
  x=b.x+b.w-r.width; y=b.y+b.h+8;
  if(y+r.height>vh-4) y=b.y-r.height-8;
  if(y<4) y=Math.max(4,b.y+b.h-r.height-8);
  x=Math.max(4,Math.min(vw-r.width-4,x));
  pn.style.left=Math.round(x)+'px'; pn.style.top=Math.round(y)+'px';
  SNIP.pn=pn;
}
function snipStart(){
  var base;
  if(SNIP.on||!DEV_LOCAL) return false;
  try{ base=snipBase(); }catch(_b){ return false; }
  SNIP.gen++; SNIP.base=base; SNIP.k=DPRH||1; SNIP.box=null; SNIP.d=null; SNIP.png=''; SNIP.ph='pick'; SNIP.acted=0; SNIP.eat=0; SNIP.said='';
  SNIP.domBusy=0; SNIP.domP=null; SNIP.domState=SNIP.dom?'':'off';
  if(SNIP.dom){ try{ snipDomStart(base,SNIP.k,SNIP.gen); }catch(_d){ SNIP.domBusy=0; SNIP.domP=null; SNIP.domState='failed'; } }
  snipUi();
  SNIP.on=1;
  try{ syncPause(); }catch(_sp){}   // a raid stands still from this moment, through the one pause (devFreeze)
  return true;
}
function snipEnd(why){
  var acted;
  if(!SNIP.on) return false;
  acted=SNIP.acted;
  SNIP.on=0; SNIP.ph=''; SNIP.d=null; SNIP.base=null; SNIP.box=null;
  [SNIP.ov,SNIP.bx,SNIP.sz,SNIP.ht,SNIP.pn].forEach(function(e){ try{ if(e&&e.parentNode) e.parentNode.removeChild(e); }catch(_e){} });
  SNIP.ov=SNIP.bx=SNIP.sz=SNIP.ht=SNIP.pn=null;
  try{ var tt=document.getElementById('hubtoast'); if(tt) tt.style.zIndex=''; }catch(_z){}
  devLetGo();   // no key and no mouse button stays held, so nothing walks or fires when the game carries on
  try{ syncPause(); }catch(_sp){}
  if(why==='click'){ SNIP.eat=1; setTimeout(function(){ SNIP.eat=0; },900); }   // the rest of the click that ended it (its release and its click) is eaten too
  if(!acted) snipSay('snip cancelled');
  return true;
}
function snipCopy(){
  var base=SNIP.base, box=SNIP.box, k=SNIP.k, wait=(SNIP.domBusy&&SNIP.domP)?SNIP.domP:null, mk, item, pr;
  mk=function(){ var d=snipCut(base,box,k); if(!d) throw new Error('no picture'); SNIP.png=d; return snipBlob(d); };
  if(typeof ClipboardItem==='undefined'||!navigator.clipboard||typeof navigator.clipboard.write!=='function'){ snipSay('copy refused: no clipboard here'); return false; }
  try{
    item=new ClipboardItem({'image/png':wait?wait.then(mk,mk):mk()});   // called inside the click, so the browser sees the button press
    pr=navigator.clipboard.write([item]);
  }catch(e){ snipSay('copy refused: '+snipWhy(e)); return false; }
  if(pr&&pr.then) pr.then(function(){ snipSay('snip copied'); },function(e){ snipSay('copy refused: '+snipWhy(e)); });
  else snipSay('snip copied');
  return true;
}
function snipFall(txt,d,st){ var r=fbFiles(txt,d,st); snipSay(r==='downloaded'?'snip saved to downloads':(r==='embedded'?'snip note copied':'snip not saved')); }
function snipSave(){
  var base=SNIP.base, box=SNIP.box, k=SNIP.k, wait=(SNIP.domBusy&&SNIP.domP)?SNIP.domP:null, go;
  go=function(){
    var d=snipCut(base,box,k), st=fbStamp(), txt, url, pr;
    if(!d){ snipSay('snip not saved: no picture'); return; }
    SNIP.png=d; txt=fbText(snipNote(box));
    url=(typeof LOCAL_DROP==='string'&&LOCAL_DROP&&DROP===LOCAL_DROP)?LOCAL_DROP.replace(/telemetry$/,'feedback'):null;
    pr=url?fbPost(url,txt+'\n----PILLAGERS-PNG----\n'+d):null;   // the Feedback window own route: exports/feedback-STAMP.txt and .png
    if(pr&&pr.then) pr.then(function(r){ if(r&&r.ok) snipSay('snip saved'); else snipFall(txt,d,st); },function(){ snipFall(txt,d,st); });
    else snipFall(txt,d,st);
  };
  if(wait) wait.then(go,go); else go();
  return true;
}
function snipPress(which){
  SNIP.acted=1;
  if(which==='copy') return snipCopy();
  if(which==='save') return snipSave();
  return false;
}
function snipEat(e){ try{ e.stopImmediatePropagation(); }catch(_x){} }
function snipMouse(e){
  var t=e.type, tg=e.target, pn=(tg&&tg.closest)?tg.closest('#snippanel'):null, bt=(tg&&tg.closest)?tg.closest('[data-snip]'):null, p, b;
  if(!SNIP.on){
    if(SNIP.eat&&(t==='mouseup'||t==='click'||t==='auxclick'||t==='dblclick'||t==='pointerup'||t==='contextmenu')){ snipEat(e); if(t==='click') SNIP.eat=0; }
    return;
  }
  snipEat(e);   // the page under the overlay never hears the mouse while a snip is up
  if(pn){ if(t==='click'&&bt) snipPress(bt.getAttribute('data-snip')); return; }
  if(t==='contextmenu'){ try{ e.preventDefault(); }catch(_c){} return; }
  if(t==='mousedown'&&e.button===0){
    if(SNIP.ph==='panel'){ snipEnd('click'); return; }
    SNIP.d=snipPt(e); SNIP.box=null; snipPaint();
    if(SNIP.ht) SNIP.ht.style.display='none';
    return;
  }
  if(t==='mousemove'&&SNIP.d){ SNIP.box=snipRect(SNIP.d,snipPt(e)); snipPaint(); return; }
  if(t==='mouseup'&&e.button===0&&SNIP.d){
    b=snipRect(SNIP.d,snipPt(e)); SNIP.d=null;
    if(b.w>=6&&b.h>=6){ SNIP.box=b; SNIP.ph='panel'; snipPaint(); snipPanel(); }
    else{ SNIP.box=null; snipPaint(); if(SNIP.ht) SNIP.ht.style.display=''; }
  }
}
(function(){
  try{
    ['mousedown','mouseup','mousemove','click','dblclick','auxclick','contextmenu','pointerdown','pointerup','pointermove','wheel'].forEach(function(n){ window.addEventListener(n,snipMouse,true); });
    window.addEventListener('keydown',function(e){
      if(!DEV_LOCAL||!e) return;
      if(e.code==='F8'&&!(e.ctrlKey||e.altKey||e.metaKey||e.shiftKey)){
        try{ if(typeof KEYS==='object'&&KEYS&&KEYS.waiting) return; }catch(_kw){}   // the Keys window is waiting for a key to bind: it says F8 keeps its own job
        try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
        if(e.repeat) return;   // an edge press only
        try{ if(SNIP.on) snipEnd('key'); else snipStart(); }catch(_t){}
        return;
      }
      if(!SNIP.on) return;
      snipEat(e);   // a snip is up: no key reaches the game (ESC included, so it does not open the pause box)
      if(e.code==='Escape'){ try{ e.preventDefault(); }catch(_p){} if(!e.repeat) snipEnd('esc'); }
    },true);
    window.addEventListener('keyup',function(e){ if(SNIP.on) snipEat(e); },true);
  }catch(_e){}
})();
// v11.52, HIS NOTE: credits and XP shown at all times in the upper right, in
'@

SubRx @'
function devFreeze(){ return !!(DEV_LOCAL&&CFG.textEdit===1&&
'@ @'
function devFreeze(){ return !!(DEV_LOCAL&&(CFG.textEdit===1||(typeof SNIP==='object'&&SNIP&&SNIP.on))&&
'@

SubRx @'
if(DEV_LOCAL) KEYS_FIXED.F2=1;   // v30.xx (cw-txkey): F2 turns Edit the words on and off on this machine, so no action can be bound to it
'@ @'
if(DEV_LOCAL) KEYS_FIXED.F2=1;   // v30.xx (cw-txkey): F2 turns Edit the words on and off on this machine, so no action can be bound to it
if(DEV_LOCAL) KEYS_FIXED.F8=1;   // v30.xx (cw-snip): F8 is the snip key on this machine, so no action can be bound to it
'@

SubRx @'
if(DEV_LOCAL) KEYS_LOCKED.push(['EDIT THE WORDS','F2']);   // v30.xx (cw-txkey): the Keys window names it too (this machine only)
'@ @'
if(DEV_LOCAL) KEYS_LOCKED.push(['EDIT THE WORDS','F2']);   // v30.xx (cw-txkey): the Keys window names it too (this machine only)
if(DEV_LOCAL) KEYS_LOCKED.push(['SNIP THE SCREEN','F8']);   // v30.xx (cw-snip): the Keys window names it too (this machine only)
'@

SubRx @'
function pollPad(){
  if(!navigator.getGamepads) return;
'@ @'
function pollPad(){
  if(!navigator.getGamepads) return;
  if(typeof SNIP==='object'&&SNIP&&SNIP.on) return;   // v30.xx (cw-snip): the pad is not read while a snip is up, so a press cannot reach a menu under it
'@

SubRx @'
var VER='31.12';
'@ @'
var VER='31.13';
'@

$pat = "(?m)^  now:'v31\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.13: F8 freezes the game so you can drag a box around any part of the screen. Press copy to put it on your clipboard, or save to write it to the exports folder. ESC or F8 carries on. Check 31.13 fails on v31.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
