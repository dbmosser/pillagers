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

# WHOLE RUN RECORDINGS AND EVERY CAPTURE WHEN IDLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ATTRACT_IDLE=30, ATT={last:Date.now(),on:false,el:null,src:null,tried:false,url:null,mx:-1,my:-1};
function attTitleUp(){ var t=document.getElementById('title'); return !!(t&&t.classList.contains('on')); }
function attPoke(){ ATT.last=Date.now(); if(ATT.on) attStop(); }
function attDb(cb){
  try{ var r=indexedDB.open('pillagers-attract',1);
       r.onupgradeneeded=function(){ try{ r.result.createObjectStore('clips'); }catch(_u){} };
       r.onsuccess=function(){ cb(r.result); }; r.onerror=function(){ cb(null); }; }
  catch(e){ cb(null); }
}
function attClipGet(cb){ attDb(function(db){ if(!db) return cb(null); try{ var q=db.transaction('clips','readonly').objectStore('clips').get('main'); q.onsuccess=function(){ cb(q.result||null); }; q.onerror=function(){ cb(null); }; }catch(e){ cb(null); } }); }
function attClipPut(blob,cb){ attDb(function(db){ if(!db) return cb&&cb(false); try{ var tx=db.transaction('clips','readwrite'); tx.objectStore('clips').put(blob,'main'); tx.oncomplete=function(){ ATT.src=null; ATT.tried=false; cb&&cb(true); }; tx.onerror=function(){ cb&&cb(false); }; }catch(e){ cb&&cb(false); } }); }

'@ @'
// v28.xx (cw-cx-wholerun), HIS ORDER (2026-10-30): "capture the entire run" and "play through all the captures".
var ATTRACT_IDLE=30, ATT={last:Date.now(),on:false,el:null,src:null,tried:false,url:null,mx:-1,my:-1,list:[],ix:-1,ready:false,loading:false,pending:false,playing:false,gen:0,timer:0,keyTime:0,padHeld:false};
function attTitleUp(){ var t=document.getElementById('title'); return !!(t&&t.classList.contains('on')); }
function attPoke(){ ATT.last=Date.now(); if(ATT.on||ATT.pending||ATT.loading) attStop(); }
function attDb(cb){
  try{ var r=indexedDB.open('pillagers-attract',1);
       r.onupgradeneeded=function(){ try{ r.result.createObjectStore('clips'); }catch(_u){} };
       r.onsuccess=function(){ cb(r.result); }; r.onerror=function(){ cb(null); }; }
  catch(e){ cb(null); }
}
// v28.xx (cw-cx-wholerun): legacy main is kept and sorts last; new captures never overwrite one another.
function attClipList(cb){
  var done=false, db0=null, tm=setTimeout(function(){ finish([]); },4500);
  function finish(rows){ if(done) return; done=true; clearTimeout(tm); try{ if(db0) db0.close(); }catch(_c){} rows.sort(function(a,b){ return b.time-a.time; }); cb(rows); }
  attDb(function(db){
    if(done){ try{ if(db) db.close(); }catch(_c){} return; } db0=db;
    if(!db) return finish([]);
    try{ var rows=[], tx=db.transaction('clips','readonly'), q=tx.objectStore('clips').openCursor();
      q.onsuccess=function(){ var c=q.result; if(!c) return finish(rows); if(c.value&&c.value.size>0) rows.push({key:String(c.key),blob:c.value,time:c.key==='main'?0:(+String(c.key).slice(5)||0)}); c.continue(); };
      q.onerror=function(){ finish([]); }; tx.onabort=function(){ finish([]); };
    }catch(e){ finish([]); }
  });
}
function attClipGet(cb){ attClipList(function(rows){ cb(rows.length?rows[0].blob:null); }); }
function attClipPut(blob,cb){
  attDb(function(db){
    if(!db) return cb&&cb(false);
    var done=false;
    function finish(ok){ if(done) return; done=true; try{ db.close(); }catch(_c){} if(ok){ ATT.tried=false; ATT.ready=false; ATT.exhausted=false; } if(cb) cb(ok); }
    try{ var tx=db.transaction('clips','readwrite'), tries=0;
      function add(){
        ATT.keyTime=Math.max(Date.now(),ATT.keyTime+1); var q=tx.objectStore('clips').add(blob,'clip-'+ATT.keyTime);
        q.onerror=function(e){ if(q.error&&q.error.name==='ConstraintError'&&++tries<20){ e.preventDefault(); e.stopPropagation(); add(); } };
      }
      add(); tx.oncomplete=function(){ finish(true); }; tx.onabort=function(){ finish(false); };
    }
    catch(e){ finish(false); }
  });
}
// v28.xx (cw-cx-wholerun): a missing manifest is normal. HEAD avoids reading large copies already kept in this browser.
function attFetch(src,method){
  return new Promise(function(resolve){
    var done=false, ac=typeof AbortController==='function'?new AbortController():null;
    var tm=setTimeout(function(){ if(ac) ac.abort(); finish(null); },4500);
    function finish(r){ if(done) return; done=true; clearTimeout(tm); resolve(r); }
    try{ fetch(src,{method:method||'GET',signal:ac?ac.signal:undefined}).then(function(r){ finish(r.ok?r:null); },function(){ finish(null); }); }catch(e){ finish(null); }
  });
}
function attDiskList(cb){
  attFetch('attract/list.json').then(function(r){ return r?r.json():[]; }).then(function(names){
    if(!Array.isArray(names)) return [];
    var seen={};
    return Promise.all(names.filter(function(n){ if(typeof n!=='string'||!n||/[\\/]/.test(n)||n==='.'||n==='..'||seen[n]) return false; seen[n]=true; return true; }).map(function(n){
      var src='attract/'+encodeURIComponent(n);
      return attFetch(src,'HEAD').then(function(r){ var size=r?+r.headers.get('content-length'):0; if(size>0) return {src:src,size:size};
        return attFetch(src).then(function(full){ return full?full.blob():null; }).then(function(b){ return b&&b.size?{src:src,size:b.size}:null; });
      }).catch(function(){ return null; });
    }));
  }).then(function(rows){ cb((rows||[]).filter(function(r){ return !!r; })); },function(){ cb([]); });
}
function attMakeList(rows,files){
  (ATT.list||[]).forEach(function(c){ if(c.owned) try{ URL.revokeObjectURL(c.src); }catch(_r){} });
  var list=[], sizes={};
  rows.forEach(function(r){ try{ list.push({src:URL.createObjectURL(r.blob),owned:true,key:r.key}); sizes[r.blob.size]=true; }catch(_u){} });
  files.forEach(function(f){ if(!sizes[f.size]) list.push({src:f.src}); });
  // v28.xx (cw-cx-wholerun): the original beside-the-game clips remain fallbacks when no capture can play.
  list.push({src:'attract.mp4',fallback:true},{src:'attract.webm',fallback:true});
  ATT.list=list; ATT.ix=-1; ATT.ready=true; ATT.exhausted=false;
}
function attBlocked(){
  if(typeof FSG==='object'&&FSG&&FSG.open) return true;
  var a=document.activeElement;
  return !!(a&&(/^(INPUT|TEXTAREA|SELECT)$/.test(a.tagName)||a.isContentEditable));
}
function attAllowed(){
  if(attBlocked()||state==='raid') return false;
  return attTitleUp()||state==='hub';
}
// v28.xx (cw-cx-wholerun): only the pad assigned to this window wakes its clip; spend the whole held gesture.
function attPad(gp){
  var bt=gp.buttons||[], ax=gp.axes||[], active=bt.some(function(b){ return b&&(b.pressed||b.value>0.3); })||ax.some(function(a){ return Math.abs(a)>0.3; });
  if(!active){ ATT.padHeld=false; return false; }
  var wake=ATT.playing||ATT.pending||ATT.loading||(ATT.on&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on));
  if(wake){ attPoke(); ATT.padHeld=true; } else ATT.last=Date.now();
  if(!ATT.padHeld) return false;
  PAD.prev=bt.map(function(b){ return !!(b&&(b.pressed||b.value>0.3)); });
  PAD.mSpent=PAD.prev.map(function(b){ return b?1:0; });
  return true;
}

'@

SubRx @'
// ATTRACT MODE. On the title, after ATTRACT_IDLE seconds with no key, mouse or controller input, a gameplay clip plays over the
// whole screen, muted and looping, under PRESS ANY KEY. Any input stops it (that press does nothing else) and the idle clock
// starts again. The clip is the one recorded in the game (F9 in a raid, kept in this browser), or else attract.mp4 or
// attract.webm beside the game file (a clip recorded any other way, and the one an itch build ships). With neither, nothing shows.

'@ @'
// v28.xx (cw-cx-wholerun): after 30 idle seconds, the title and hub play every kept capture, newest first.
// The arcade keeps its page sequence. Disk captures come from attract/list.json; attract.mp4 and attract.webm remain fallbacks.
// Wake input is consumed. Failed footage is skipped and the overlay waits for decoded video.

'@

SubRx @'
// F9 starts recording what the game draws (the world and the HUD, composed at up to 1920 wide, 30 frames a second) and F9 again
// stops it; it stops by itself after REC.max seconds. The clip is kept in this browser as the attract clip the title plays when
// nobody is playing, and a copy goes to the downloads as pillagers-attract.webm (rename it attract.webm beside the game file to
// ship it). The red REC mark is a page element, not part of the drawing, so it is never in the clip. Menus drawn as page
// elements are not in the clip either, which suits a gameplay reel.

'@ @'
// v28.xx (cw-cx-wholerun), HIS ORDER (2026-10-30): F9 records the whole run, with a 30 minute safety stop.
// F9 again or any run end saves a separate browser clip and a dated download. World and HUD are recorded; page menus are not.
// The lower case elapsed mark lives on the page, outside the recording.

'@

SubRx @'
  d.innerHTML='<video muted loop playsinline></video><div class="attname">PILLAGERS</div><div class="attpress">PRESS ANY KEY</div>';
'@ @'
  d.innerHTML='<video muted playsinline></video><div class="attname">pillagers</div><div class="attpress">press any key</div>'; // v28.xx (cw-cx-wholerun): ended advances the playlist.
'@

SubRx @'
function attShow(src){
  var d=attZ(attEl()), v=d.querySelector('video');
  try{ var _ap=d.querySelector('.attpress'); if(_ap) _ap.textContent=padOn()?'PRESS ANY BUTTON':'PRESS ANY KEY'; }catch(_apx){}   // v21.59: on a controller it says button
  if(!src) return false;
  ATT.on=true; d.style.display='block';
  if(v.getAttribute('src')!==src) v.setAttribute('src',src);
  try{ var pr=v.play(); if(pr&&pr.catch) pr.catch(function(){}); }catch(e){}
  return true;
}
function attProbe(list,cb){
  if(!list.length) return cb(null);
  var t=document.createElement('video'), u=list[0], done=false;
  t.muted=true; t.preload='metadata';
  t.onloadedmetadata=function(){ if(done) return; done=true; cb(u); };
  t.onerror=function(){ if(done) return; done=true; attProbe(list.slice(1),cb); };
  t.src=u;
}
function attIdle(){ if(FSG.open) return false; return attTitleUp()&&Date.now()-ATT.last>=ATTRACT_IDLE*1000; }   // v35.02 (cw-fsgate): no attract clip over the fullscreen gate
function attStart(){
  if(ATT.src) return attShow(ATT.src);
  if(ATT.tried) return false;   // looked once and found no clip; a new recording clears this
  ATT.tried=true;
  attClipGet(function(b){
    if(b){ try{ if(ATT.url) URL.revokeObjectURL(ATT.url); ATT.url=URL.createObjectURL(b); ATT.src=ATT.url; }catch(e){} }
    if(ATT.src){ if(attIdle()) attShow(ATT.src); return; }
    attProbe(['attract.mp4','attract.webm'],function(s){ ATT.src=s; if(s&&attIdle()) attShow(s); });
  });
  return false;
}
function attStop(){ ATT.on=false; if(ATT.el){ ATT.el.style.display='none'; try{ ATT.el.querySelector('video').pause(); }catch(e){} } }
function attTick(){
  var gp, i, j, a;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeAttTick(); }catch(_aat){} return; }   // v23.24 (arcade5)
  try{ gp=navigator.getGamepads?navigator.getGamepads():[];
       for(i=0;gp&&i<gp.length;i++){ a=gp[i]; if(!a) continue;
         for(j=0;j<a.buttons.length;j++) if(a.buttons[j]&&a.buttons[j].pressed){ attPoke(); return; }
         for(j=0;j<a.axes.length;j++) if(Math.abs(a.axes[j])>0.45){ attPoke(); return; } } }catch(e){}
  if(!attTitleUp()){ if(ATT.on) attStop(); ATT.last=Date.now(); return; }
  if(!ATT.on&&attIdle()) attStart();
}
['keydown','mousedown','wheel','touchstart'].forEach(function(evn){
  try{ window.addEventListener(evn,function(e){
    if(typeof G!=='undefined'&&G&&G.carAsk&&easyLive()){ try{ if(easyKey(e)) return; }catch(_eck){} }   // v28.xx (cw-easycareer): Y or N answers the career easy card
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeKeyAtt(e); }catch(_ak){} return; }   // v23.24 (arcade5): in the arcade a press drops the host in
    if(ATT.on){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){} }   // the press that stops the clip does nothing else
    attPoke();
  },true); }catch(_ae){}
});
// v23.24 (arcade5): in the arcade a mousemove never drops in and never stops the demo.
try{ window.addEventListener('mousemove',function(e){ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return; if(ATT.mx<0||Math.abs(e.clientX-ATT.mx)+Math.abs(e.clientY-ATT.my)>12){ ATT.mx=e.clientX; ATT.my=e.clientY; attPoke(); } },true); }catch(_am){}
try{ setInterval(attTick,500); }catch(_ai){}

'@ @'
// v28.xx (cw-cx-wholerun): show decoded, playing footage only. Errors advance without a black overlay.
function attShow(src){
  if(!src||!attIdle()) return false;
  var d=attZ(attEl()), v=d.querySelector('video'), token=++ATT.gen;
  clearTimeout(ATT.timer);
  ATT.src=src; ATT.pending=true; ATT.playing=false;
  var arcade=!!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on);
  var ap=d.querySelector('.attpress'); if(ap&&!arcade) ap.textContent=padOn()?'press any button':'press any key';
  if(!arcade) d.style.display='none';
  v.style.visibility='hidden'; v.loop=false; v.muted=true;
  function live(){ return token===ATT.gen; }
  function failed(){ if(live()) attNext(true); }
  function wait(){ if(!live()) return; ATT.playing=false; ATT.pending=true; if(!arcade) d.style.display='none'; v.style.visibility='hidden'; clearTimeout(ATT.timer); ATT.timer=setTimeout(failed,10000); }
  v.onplaying=function(){
    if(!live()) return;
    if(!attIdle()){ attStop(); return; }
    clearTimeout(ATT.timer); ATT.pending=false; ATT.playing=true; ATT.on=true;
    var ap=d.querySelector('.attpress'); if(ap&&!arcade) ap.textContent=padOn()?'press any button':'press any key';
    v.style.visibility=''; d.style.display='block';
  };
  v.onended=function(){ if(live()) attNext(false); };
  v.onerror=failed; v.onwaiting=wait; v.onstalled=wait;
  ATT.timer=setTimeout(failed,10000);
  try{ v.setAttribute('src',src); v.load(); var p=v.play(); if(p&&p.catch) p.catch(failed); }catch(e){ failed(); }
  return true;
}
function attNext(failed){
  var list=ATT.list||[], i, at=-1, count=list.length;
  if(failed&&list[ATT.ix]) list[ATT.ix].bad=true;
  for(i=1;i<=count;i++){ var n=(ATT.ix+i+count)%count; if(!list[n].bad&&!list[n].fallback){ at=n; break; } }
  if(at<0) for(i=0;i<count;i++) if(!list[i].bad&&list[i].fallback){ at=i; break; }
  if(at<0){ ATT.exhausted=true; attStop(); return false; }
  ATT.ix=at; return attShow(list[at].src);
}
function attIdle(){ return attAllowed()&&Date.now()-ATT.last>=ATTRACT_IDLE*1000; }
function attStart(){
  if(!attIdle()||ATT.loading||ATT.pending||ATT.playing||ATT.exhausted) return false;
  if(ATT.ready){ ATT.ix=-1; return attNext(false); }
  if(ATT.tried) return false;
  ATT.tried=true; ATT.loading=true;
  var token=++ATT.gen;
  attClipList(function(rows){
    if(token!==ATT.gen) return;
    attDiskList(function(files){
      if(token!==ATT.gen) return;
      ATT.loading=false; attMakeList(rows,files);
      if(attIdle()) attNext(false);
    });
  });
  return false;
}
function attStop(){
  if(ATT.loading) ATT.tried=false;
  ATT.gen++; clearTimeout(ATT.timer);
  ATT.on=false; ATT.pending=false; ATT.playing=false; ATT.loading=false; ATT.src=null; ATT.ix=-1;
  if(ATT.el){ ATT.el.style.display='none'; try{ var v=ATT.el.querySelector('video'); v.onplaying=v.onended=v.onerror=v.onwaiting=v.onstalled=null; v.pause(); v.removeAttribute('src'); v.load(); v.style.visibility=''; }catch(e){} }
}
function attTick(){
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeAttTick(); }catch(_aat){} return; }
  if(!attAllowed()){ if(ATT.on||ATT.pending||ATT.loading) attStop(); ATT.last=Date.now(); return; }
  if(!ATT.on&&attIdle()) attStart();
}
['keydown','mousedown','wheel','touchstart'].forEach(function(evn){
  try{ window.addEventListener(evn,function(e){
    // v28.xx (cw-cx-wholerun): the wake press, including the click following a mouse down, never reaches the game.
    var arcade=!!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on);
    if(ATT.playing||ATT.pending||ATT.loading||(ATT.on&&!arcade)){
      try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
      if(evn==='mousedown'||evn==='touchstart') ATT.eatClick=Date.now()+800;
      if(evn==='keydown') ATT.wakeCode=e.code;
      attPoke(); return;
    }
    if(evn==='keydown'&&ATT.wakeCode===e.code&&e.repeat){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){} return; }
    ATT.last=Date.now();
    if(typeof G!=='undefined'&&G&&G.carAsk&&easyLive()){ try{ if(easyKey(e)) return; }catch(_eck){} }
    if(arcade){ try{ arcadeKeyAtt(e); }catch(_ak){} return; }
  },true); }catch(_ae){}
});
try{ window.addEventListener('keyup',function(e){ if(ATT.wakeCode===e.code){ ATT.wakeCode=null; e.preventDefault(); e.stopImmediatePropagation(); } },true);
  window.addEventListener('click',function(e){ if(Date.now()<(ATT.eatClick||0)){ e.preventDefault(); e.stopImmediatePropagation(); ATT.eatClick=0; } },true);
  window.addEventListener('mousemove',function(e){ if(ATT.mx<0||Math.hypot(e.clientX-ATT.mx,e.clientY-ATT.my)>12){ ATT.mx=e.clientX; ATT.my=e.clientY; if(ATT.playing||ATT.pending||ATT.loading||!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) attPoke(); else ATT.last=Date.now(); } },true);
}catch(_am){}
try{ setInterval(attTick,500); }catch(_ai){}

'@

SubRx @'
var REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:180};
'@ @'
var REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:1800,fileStamp:'',fileCount:0}; // v28.xx (cw-cx-wholerun): 30 minute safety stop only.
'@

SubRx @'
function recDraw(){
  if(!REC.on) return;
  var c=REC.cv, x=REC.cx;
  try{
    x.fillStyle='#000'; x.fillRect(0,0,c.width,c.height);
    if(cv&&cv.width) x.drawImage(cv,0,0,c.width,c.height);
    if(hcv&&hcv.width&&hcv.style.display!=='none') x.drawImage(hcv,0,0,c.width,c.height);
  }catch(e){}
  // v21.48: THE REC MARK SAYS HOW LONG, so the 3 minute stop is never a surprise (it is a page element, never in the clip)
  if(REC.mark){ var _rs=Math.floor((Date.now()-REC.t0)/1000), _rt='&#9679; REC '+fmtClock(_rs)+' / '+fmtClock(REC.max); if(REC.mark._t!==_rt){ REC.mark._t=_rt; REC.mark.innerHTML=_rt; } }
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
  if(typeof attTitleUp==='function'&&attTitleUp()){ recStop(); return; }   // v21.50: back on the title the canvas is empty, so a running recording stops there instead of filling with black
  REC.raf=requestAnimationFrame(recDraw);
}
function recStart(){
  var w, h, mt='', o;
  if(REC.on) return false;
  // v21.49: NOT ON THE TITLE. The title is page elements over an empty canvas, so F9 there recorded a black clip, and that clip then
  // became the one the title plays when nobody is playing. It says where to press it instead.
  if(typeof attTitleUp==='function'&&attTitleUp()){
    var _rt=document.getElementById('recmark'); recMark(true);
    if(REC.mark){ REC.mark.innerHTML='Press F9 in a raid or the Undercroft to record'; setTimeout(function(){ if(!REC.on){ recMark(false); REC.mark.innerHTML='&#9679; REC'; } },2600); }
    return false;
  }
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ recTell('THIS BROWSER CANNOT RECORD'); return false; }
  w=Math.min(1920,(cv&&cv.width)||1920); h=Math.round(w*(((cv&&cv.height)||1080)/((cv&&cv.width)||1920)));
  REC.cv=document.createElement('canvas'); REC.cv.width=w; REC.cv.height=h; REC.cx=REC.cv.getContext('2d');
  ['video/webm;codecs=vp9','video/webm;codecs=vp8','video/webm'].forEach(function(m){ try{ if(!mt&&MediaRecorder.isTypeSupported(m)) mt=m; }catch(_t){} });
  o={videoBitsPerSecond:3500000}; if(mt) o.mimeType=mt;
  try{ REC.mr=new MediaRecorder(REC.cv.captureStream(30),o); }catch(e){ recTell('THIS BROWSER CANNOT RECORD'); return false; }
  REC.chunks=[];
  REC.mr.ondataavailable=function(ev){ if(ev.data&&ev.data.size) REC.chunks.push(ev.data); };
  REC.mr.onstop=recSave;
  REC.on=true; REC.t0=Date.now();
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; recTell('THIS BROWSER CANNOT RECORD'); return false; }
  recDraw(); recMark(true);
  recTell('RECORDING','[F9] STOP  \u00b7  3:00 MAX');   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
  return true;
}
function recStop(){
  if(!REC.on) return false;
  REC.on=false;
  try{ cancelAnimationFrame(REC.raf); }catch(e){}
  recMark(false);
  try{ REC.mr.stop(); }catch(e){ recSave(); }
  return true;
}
function recSave(){
  var b=null, a;
  try{ b=new Blob(REC.chunks,{type:'video/webm'}); }catch(e){ b=null; }
  REC.chunks=[];
  if(!b||b.size<20000){ recTell('RECORDING TOO SHORT TO KEEP'); return; }   // v22.xx (R55): a system label in caps
  attClipPut(b,function(ok){ recTell(ok?'RECORDING KEPT':'RECORDING NOT KEPT','SAVED TO DOWNLOADS'); });   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
  try{ a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='pillagers-attract.webm'; document.body.appendChild(a); a.click();
       setTimeout(function(){ try{ URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }catch(_r){} },5000); }catch(e){}
}

'@ @'
// v28.xx (cw-cx-wholerun): pause, map and backpack leave recording running; only the run end, F9 or safety timer stop it.
function recDraw(){
  if(!REC.on) return;
  var c=REC.cv, x=REC.cx;
  try{
    x.fillStyle='#000'; x.fillRect(0,0,c.width,c.height);
    if(cv&&cv.width) x.drawImage(cv,0,0,c.width,c.height);
    if(hcv&&hcv.width&&hcv.style.display!=='none') x.drawImage(hcv,0,0,c.width,c.height);
  }catch(e){}
  if(REC.mark){ var text='rec '+fmtClock((Date.now()-REC.t0)/1000); if(REC.mark.textContent!==text) REC.mark.textContent=text; }
  if(Date.now()-REC.t0>=REC.max*1000||(typeof attTitleUp==='function'&&attTitleUp())){ recStop(); return; }
  REC.raf=requestAnimationFrame(recDraw);
}
function recStart(){
  var w, h, mt='', o;
  if(REC.on) return false;
  if(typeof attTitleUp==='function'&&attTitleUp()){
    recMark(true);
    if(REC.mark){ REC.mark.textContent='f9 in a raid or the undercroft'; setTimeout(function(){ if(!REC.on) recMark(false); },2600); }
    return false;
  }
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ recTell('this browser cannot record'); return false; }
  w=Math.min(1920,(cv&&cv.width)||1920); h=Math.round(w*(((cv&&cv.height)||1080)/((cv&&cv.width)||1920)));
  REC.cv=document.createElement('canvas'); REC.cv.width=w; REC.cv.height=h; REC.cx=REC.cv.getContext('2d');
  ['video/webm;codecs=vp9','video/webm;codecs=vp8','video/webm'].forEach(function(m){ try{ if(!mt&&MediaRecorder.isTypeSupported(m)) mt=m; }catch(_t){} });
  o={videoBitsPerSecond:3500000}; if(mt) o.mimeType=mt;
  try{ REC.mr=new MediaRecorder(REC.cv.captureStream(30),o); }catch(e){ recTell('this browser cannot record'); return false; }
  var chunks=REC.chunks=[], recorder=REC.mr;
  recorder.ondataavailable=function(ev){ if(ev.data&&ev.data.size) chunks.push(ev.data); };
  recorder.onstop=function(){ recSave(chunks,recorder); };
  REC.on=true; REC.t0=Date.now();
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; recTracks(); recTell('this browser cannot record'); return false; }
  REC.guard=setTimeout(function(){ if(REC.on&&REC.mr===recorder) recStop(); },REC.max*1000);
  recMark(true); recDraw();
  recTell('recording','[f9] stop');
  return true;
}
function recTracks(mr){ try{ mr=mr||REC.mr; if(mr&&mr.stream) mr.stream.getTracks().forEach(function(t){ t.stop(); }); }catch(_s){} }
function recStop(){
  if(!REC.on) return false;
  REC.on=false;
  clearTimeout(REC.guard);
  try{ cancelAnimationFrame(REC.raf); }catch(e){}
  recMark(false);
  try{ REC.mr.stop(); recTracks(REC.mr); }catch(e){ recSave(REC.chunks,REC.mr); }
  return true;
}
function recFileName(){
  var d=new Date(), p=function(n){ return ('0'+n).slice(-2); }, stamp=d.getFullYear()+p(d.getMonth()+1)+p(d.getDate())+'-'+p(d.getHours())+p(d.getMinutes());
  if(REC.fileStamp===stamp) REC.fileCount++; else { REC.fileStamp=stamp; REC.fileCount=1; }
  return 'pillagers-attract-'+stamp+(REC.fileCount>1?'-'+REC.fileCount:'')+'.webm';
}
function recSave(chunks,mr){
  var b=null, a;
  chunks=chunks||REC.chunks; mr=mr||REC.mr;
  try{ b=new Blob(chunks,{type:'video/webm'}); }catch(e){ b=null; }
  if(REC.chunks===chunks) REC.chunks=[];
  recTracks(mr);
  if(!b||!b.size){ recTell('recording too short to keep'); return; }
  attClipPut(b,function(ok){ recTell(ok?'recording kept':'recording not kept','saved to downloads'); });
  try{ a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download=recFileName(); document.body.appendChild(a); a.click();
       setTimeout(function(){ try{ URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }catch(_r){} },5000); }catch(e){}
}

'@

SubRx @'
    REC.mark.innerHTML='&#9679; REC';
'@ @'
    REC.mark.textContent='rec 0:00'; // v28.xx (cw-cx-wholerun): elapsed time only, lower case.
'@

SubRx @'
function endRaid(how){
  if(G.over) return;
'@ @'
function endRaid(how){
  if(G.over) return;
  try{ if(!G.sim) recStop(); }catch(_rec){} // v28.xx (cw-cx-wholerun): save on extract, death or abandon before any teardown.
'@

SubRx @'
function arcadeRaidStop(why){
  if(!G||!G.arcade) return false;
'@ @'
function arcadeRaidStop(why){
  if(!G||!G.arcade) return false;
  try{ recStop(); }catch(_rec){} // v28.xx (cw-cx-wholerun): every arcade run exit saves, including quit and leave.
'@

SubRx @'
  PAD.on=true; padBodyCls();   // v19.70: the page knows the pad is on (body.padon)
'@ @'
  PAD.on=true; padBodyCls();   // v19.70: the page knows the pad is on (body.padon)
  if(typeof attPad==='function'&&attPad(gp)){ padRelease(); return; } // v28.xx (cw-cx-wholerun): this pad wakes footage without acting beneath it.
'@

SubRx @'
function arcadeAttShow(){
'@ @'
function arcadeAttShow(){
  if(attBlocked()){ if(ATT.on||ATT.pending||ATT.loading) attStop(); return false; } // v28.xx (cw-cx-wholerun): text entry and fullscreen gate stay clear.
'@

SubRx @'
  if(ATT.src){
    if(v.getAttribute('src')!==ATT.src) v.setAttribute('src',ATT.src);
    if(v.paused){ try{ pr=v.play(); if(pr&&pr.catch) pr.catch(function(){}); }catch(_vp){} }
  } else if(!ATT.tried){ try{ attStart(); }catch(_st){} }
'@ @'
  if(attIdle()&&!ATT.playing&&!ATT.pending&&!ATT.loading) attStart(); // v28.xx (cw-cx-wholerun): the arcade keeps its pages and plays every capture during its idle beat.
'@

SubRx @'
clip=!!ATT.src, d=attZ(attEl())
'@ @'
clip=!!ATT.playing, d=attZ(attEl())
'@

SubRx @'
var VER='36.58';
'@ @'
var VER='36.59';
'@

$pat = "(?m)^  now:'v36\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.59: F9 saves on run end, keeps every recording, and idle title, hub and arcade playback advances through browser and disk captures. LOCAL: no linked review. Retarget checks 21.48, 21.49, 21.59 and 21.17 for elapsed-only recording, lower case, decoded video and hub playback. Check 36.59 fails on v36.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
