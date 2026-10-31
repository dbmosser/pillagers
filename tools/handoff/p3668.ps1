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

# RECORD EVERY RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'fogWar', label:'Fog of war',
   hint:'Unexplored ground stays black, in the raid and on the map.',   // v35.xx (cw-fogwar): his order of 10-27
   opts:[
     {n:'Off', cfg:{fogWar:0}},
     {n:'On',  cfg:{fogWar:1}}
   ], def:0},
'@ @'
  {k:'fogWar', label:'Fog of war',
   hint:'Unexplored ground stays black, in the raid and on the map.',   // v35.xx (cw-fogwar): his order of 10-27
   opts:[
     {n:'Off', cfg:{fogWar:0}},
     {n:'On',  cfg:{fogWar:1}}
   ], def:0},
  // v28.xx (cw-autorec), HIS ORDER (2026-10-31): "can you please set up the main pc to just record all my in-raid gameplay and use that as the idle screen?
  // I cant be bothered to remember to click record each time". On by default on his own PCs (DEV_LOCAL), off for everyone else (itch).
  {k:'autoRec', label:'record every raid',
   hint:'your raids play on the idle screen',
   opts:[
     {n:'Off', cfg:{autoRec:0}},
     {n:'On',  cfg:{autoRec:1}}
   ], def:(DEV_LOCAL?1:0)},
'@

SubRx @'
var REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:1800,fileStamp:'',fileCount:0}; // v28.xx (cw-cx-wholerun): 30 minute safety stop only.
function fmtClock(s){ s=Math.max(0,Math.floor(s)); return Math.floor(s/60)+':'+('0'+(s%60)).slice(-2); }   // v21.48: m:ss for the REC mark
function recTell(s,sub){ try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) say(s,'sys',sub?{sub:sub}:null); else if(typeof hubToast==='function') hubToast(s+(sub?('  \u00b7  '+sub):'')); }catch(e){} }   // v22.xx (R55): a caps label with a short detail
function recMark(on){
  if(!REC.mark){
    REC.mark=document.createElement('div'); REC.mark.id='recmark';
    // v28.xx (cw-cx-capturechrome): the elapsed badge keeps its 20px reading size at 1080p and 40px at 4K.
    REC.mark.style.cssText='position:fixed;left:clamp(24px,2.222222vh,96px);top:clamp(24px,2.222222vh,96px);z-index:9001;display:none;padding:.4em .8em;border:1px solid var(--ui-line-hi);border-radius:var(--rad);background:var(--ui-panel);'+
      'color:#ff5a4a;font:700 clamp(20px,1.851852vh,80px) var(--f-cond);letter-spacing:var(--track);pointer-events:none';
    REC.mark.textContent='rec 0:00'; // v28.xx (cw-cx-wholerun): elapsed time only, lower case.
    document.body.appendChild(REC.mark);
  }
  REC.mark.style.display=on?'block':'none';
}
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
try{ window.addEventListener('keydown',function(e){ if(e.code!=='F9'||e.repeat) return; try{ e.preventDefault(); }catch(_p){} if(REC.on) recStop(); else recStart(); }); }catch(_rk){}
'@ @'
var REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:1800,fileStamp:'',fileCount:0,auto:false,trk:null,next:0}; // v28.xx (cw-cx-wholerun): 30 minute safety stop only.
// v28.xx (cw-autorec), HIS ORDER (2026-10-31): "can you please set up the main pc to just record all my in-raid gameplay and use that as the idle screen? I cant be
// bothered to remember to click record each time". The record every raid row starts the recorder as a raid starts, in the player 1 window only. An auto clip stays
// in the browser for the idle screen (no download), a run under a minute is not kept, and the store keeps the newest 15 clips and 3 GB at most.
// Frame rate first: a hardware codec first (H.264), vp9 last, 2.5 Mbps, composed at 1600 wide at most and only 30 times a second, whatever the screen rate.
var REC_CFG={w:1600,fps:30,bps:2500000,minKeep:60,keepN:15,keepBytes:3*1024*1024*1024,types:['video/mp4;codecs=avc1.640028','video/webm;codecs=h264','video/webm;codecs=vp8','video/webm;codecs=vp9','video/webm']};
function fmtClock(s){ s=Math.max(0,Math.floor(s)); return Math.floor(s/60)+':'+('0'+(s%60)).slice(-2); }   // v21.48: m:ss for the REC mark
function recTell(s,sub){ try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) say(s,'sys',sub?{sub:sub}:null); else if(typeof hubToast==='function') hubToast(s+(sub?('  \u00b7  '+sub):'')); }catch(e){} }   // v22.xx (R55): a caps label with a short detail
// v28.xx (cw-capturechrome): the elapsed badge keeps its 20px reading size at 1080p and 40px at 4K.
var REC_MARK_BIG='position:fixed;left:clamp(24px,2.222222vh,96px);top:clamp(24px,2.222222vh,96px);z-index:9001;display:none;padding:.4em .8em;border:1px solid var(--ui-line-hi);border-radius:var(--rad);background:var(--ui-panel);'+
  'color:#ff5a4a;font:700 clamp(20px,1.851852vh,80px) var(--f-cond);letter-spacing:var(--track);pointer-events:none';
// v28.xx (cw-autorec): an auto recording shows only a small dim rec dot in the corner (a page element, never in the clip).
var REC_MARK_AUTO='position:fixed;left:clamp(10px,.925926vh,40px);top:clamp(8px,.740741vh,32px);z-index:9001;display:none;'+
  'color:rgba(255,90,74,.5);font:700 clamp(12px,1.111111vh,48px) var(--f-cond);letter-spacing:var(--track);pointer-events:none';
function recMark(on,auto){
  if(!REC.mark){
    REC.mark=document.createElement('div'); REC.mark.id='recmark';
    REC.mark.style.cssText=REC_MARK_BIG;
    REC.mark.textContent='rec 0:00'; // v28.xx (cw-cx-wholerun): elapsed time only, lower case.
    document.body.appendChild(REC.mark);
  }
  if(on){
    if(auto){ REC.mark.dataset.auto='1'; REC.mark.style.cssText=REC_MARK_AUTO; REC.mark.textContent='\u25cf rec'; }
    else if(REC.mark.dataset.auto==='1'){ REC.mark.dataset.auto=''; REC.mark.style.cssText=REC_MARK_BIG; }
  }
  REC.mark.style.display=on?'block':'none';
}
// v28.xx (cw-cx-wholerun): pause, map and backpack leave recording running; only the run end, F9 or safety timer stop it.
// v28.xx (cw-autorec): the copy into the recording canvas runs at the recording rate (30 a second), not at every screen frame; an auto recording also stops off the raid screen.
function recDraw(ts){
  if(!REC.on) return;
  var c=REC.cv, x=REC.cx, now=(typeof ts==='number')?ts:performance.now(), gap=1000/REC_CFG.fps;
  if(!REC.next||now>=REC.next-1){
    REC.next=(REC.next&&now-REC.next<gap)?REC.next+gap:now+gap;
    try{
      x.fillStyle='#000'; x.fillRect(0,0,c.width,c.height);
      if(cv&&cv.width) x.drawImage(cv,0,0,c.width,c.height);
      if(hcv&&hcv.width&&hcv.style.display!=='none') x.drawImage(hcv,0,0,c.width,c.height);
    }catch(e){}
    try{ if(REC.trk&&typeof REC.trk.requestFrame==='function') REC.trk.requestFrame(); }catch(_rf){}
  }
  if(REC.mark&&!REC.auto){ var text='rec '+fmtClock((Date.now()-REC.t0)/1000); if(REC.mark.textContent!==text) REC.mark.textContent=text; }
  if(Date.now()-REC.t0>=REC.max*1000||(typeof attTitleUp==='function'&&attTitleUp())||(REC.auto&&state!=='raid')){ recStop(); return; }
  REC.raf=requestAnimationFrame(recDraw);
}
function recStart(auto){
  var w, h, mt='', o, s=null, cw0, ch0;
  if(REC.on) return false;
  if(typeof attTitleUp==='function'&&attTitleUp()){
    if(auto) return false;
    recMark(true);
    if(REC.mark){ REC.mark.textContent='f9 in a raid or the undercroft'; setTimeout(function(){ if(!REC.on) recMark(false); },2600); }
    return false;
  }
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ if(!auto) recTell('this browser cannot record'); return false; }
  cw0=(cv&&cv.width)||1920; ch0=(cv&&cv.height)||1080;
  w=Math.min(REC_CFG.w,cw0); h=Math.round(w*ch0/cw0); w-=w%2; h-=h%2;   // v28.xx (cw-autorec): H.264 wants even sizes
  REC.cv=document.createElement('canvas'); REC.cv.width=w; REC.cv.height=h; REC.cx=REC.cv.getContext('2d');
  REC_CFG.types.forEach(function(m){ try{ if(!mt&&MediaRecorder.isTypeSupported(m)) mt=m; }catch(_t){} });
  o={videoBitsPerSecond:REC_CFG.bps}; if(mt) o.mimeType=mt;
  try{
    s=REC.cv.captureStream(0); REC.trk=s.getVideoTracks()[0]||null;
    if(!REC.trk||typeof REC.trk.requestFrame!=='function'){ try{ s.getTracks().forEach(function(t){ t.stop(); }); }catch(_st){} s=REC.cv.captureStream(REC_CFG.fps); REC.trk=null; }
    REC.mr=new MediaRecorder(s,o);
  }catch(e){ REC.trk=null; if(!auto) recTell('this browser cannot record'); return false; }
  var chunks=REC.chunks=[], recorder=REC.mr;
  recorder.ondataavailable=function(ev){ if(ev.data&&ev.data.size) chunks.push(ev.data); };
  recorder.onstop=function(){ recSave(chunks,recorder); };
  REC.on=true; REC.auto=!!auto; REC.t0=Date.now(); REC.next=0;
  try{ recorder._auto=!!auto; recorder._t0=REC.t0; }catch(_ra){}
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; REC.auto=false; recTracks(); if(!auto) recTell('this browser cannot record'); return false; }
  REC.guard=setTimeout(function(){ if(REC.on&&REC.mr===recorder) recStop(); },REC.max*1000);
  recMark(true,!!auto); recDraw();
  if(!auto) recTell('recording','[f9] stop');
  return true;
}
// v28.xx (cw-autorec): the record every raid row, player 1 window only (never the player 2 window, never a test page unless it asks), never a bot raid.
function recAutoOk(){
  try{
    if(!(CFG&&CFG.autoRec)) return false;
    if(window.__isFixture&&!window.__recForce) return false;
    if(typeof NETP2!=='undefined'&&NETP2) return false;
    if(typeof NET==='object'&&NET&&NET.same==='p2') return false;
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='p2') return false;
    return !!(typeof G!=='undefined'&&G&&!G.sim&&!G.over);
  }catch(e){ return false; }
}
function recAuto(){ if(REC.on||!recAutoOk()) return false; return recStart(true); }
function recTracks(mr){ try{ mr=mr||REC.mr; if(mr&&mr.stream) mr.stream.getTracks().forEach(function(t){ t.stop(); }); }catch(_s){} }
function recStop(){
  if(!REC.on) return false;
  REC.on=false; REC.auto=false;
  clearTimeout(REC.guard);
  try{ cancelAnimationFrame(REC.raf); }catch(e){}
  recMark(false);
  try{ if(REC.mr) REC.mr._t1=Date.now(); }catch(_t1){}
  try{ REC.mr.stop(); recTracks(REC.mr); }catch(e){ recSave(REC.chunks,REC.mr); }
  REC.trk=null;
  return true;
}
function recFileName(ty){
  var d=new Date(), p=function(n){ return ('0'+n).slice(-2); }, stamp=d.getFullYear()+p(d.getMonth()+1)+p(d.getDate())+'-'+p(d.getHours())+p(d.getMinutes());
  if(REC.fileStamp===stamp) REC.fileCount++; else { REC.fileStamp=stamp; REC.fileCount=1; }
  return 'pillagers-attract-'+stamp+(REC.fileCount>1?'-'+REC.fileCount:'')+(/mp4/.test(ty||'')?'.mp4':'.webm');
}
// v28.xx (cw-autorec): which kept clips go, newest first: past the newest 15, or once 3 GB is reached; the old main clip sorts oldest, so it goes first.
function attPrunePick(rows,keepN,keepBytes){
  var r=(rows||[]).slice().sort(function(a,b){ return b.time-a.time; }), out=[], tot=0, full=false, i, sz;
  for(i=0;i<r.length;i++){
    sz=(r[i].blob&&r[i].blob.size)||0;
    if(full||i>=keepN||(i>0&&tot+sz>keepBytes)){ full=true; out.push(r[i].key); } else tot+=sz;
  }
  return out;
}
function attPrune(cb){
  attClipList(function(rows){
    var del=attPrunePick(rows,REC_CFG.keepN,REC_CFG.keepBytes);
    if(!del.length){ if(cb) cb(0); return; }
    attDb(function(db){
      if(!db){ if(cb) cb(0); return; }
      var done=false;
      function fin(n){ if(done) return; done=true; try{ db.close(); }catch(_c){} ATT.tried=false; ATT.ready=false; ATT.exhausted=false; if(cb) cb(n); }
      try{ var tx=db.transaction('clips','readwrite'), st=tx.objectStore('clips');
        del.forEach(function(k){ st.delete(k); });
        tx.oncomplete=function(){ fin(del.length); }; tx.onabort=function(){ fin(0); };
      }catch(e){ fin(0); }
    });
  });
}
function recSave(chunks,mr){
  var b=null, a, auto, dur, ty;
  chunks=chunks||REC.chunks; mr=mr||REC.mr;
  auto=!!(mr&&mr._auto); dur=(mr&&mr._t0)?((mr._t1||Date.now())-mr._t0):1e9; ty=String((mr&&mr.mimeType)||'video/webm').split(';')[0]||'video/webm';
  try{ b=new Blob(chunks,{type:ty}); }catch(e){ b=null; }
  if(REC.chunks===chunks) REC.chunks=[];
  recTracks(mr);
  if(auto&&dur<REC_CFG.minKeep*1000) return false;   // v28.xx (cw-autorec): a quick death or a test run is not kept
  if(!b||!b.size){ if(!auto) recTell('recording too short to keep'); return false; }
  attClipPut(b,function(ok){ if(ok){ try{ attPrune(); }catch(_ap){} } if(!auto) recTell(ok?'recording kept':'recording not kept','saved to downloads'); });
  if(auto) return true;   // v28.xx (cw-autorec): an auto clip stays in the browser only
  try{ a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download=recFileName(ty); document.body.appendChild(a); a.click();
       setTimeout(function(){ try{ URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }catch(_r){} },5000); }catch(e){}
  return true;
}
try{ window.addEventListener('keydown',function(e){ if(e.code!=='F9'||e.repeat) return; try{ e.preventDefault(); }catch(_p){} if(REC.on) recStop(); else recStart(); }); }catch(_rk){}
'@

SubRx @'
  try{ if(!G.sim) recStop(); }catch(_rec){} // v28.xx (cw-cx-wholerun): save on extract, death or abandon before any teardown.
'@ @'
  try{ if(!G.sim&&!(G.arcade&&REC.on&&REC.auto)) recStop(); }catch(_rec){} // v28.xx (cw-cx-wholerun): save on extract, death or abandon before any teardown. v28.xx (cw-autorec): an auto recording of a party run goes on through a respawn to the run end.
'@

SubRx @'
  applyGhost();
  showScreen('raid');
'@ @'
  applyGhost();
  showScreen('raid');
  try{ recAuto(); }catch(_rau){}   // v28.xx (cw-autorec): his order of 10-31, every raid records itself when the record every raid row is on
'@

SubRx @'
var VER='36.67';
'@ @'
var VER='36.68';
'@

$pat = "(?m)^  now:'v36\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.68: Frame cost, VM test Chrome 1882x973 (software, about 32 frames a second), two runs each: game work a frame off 3.86 and 4.35 ms, on 3.76 and 4.28 ms; the copy into the recording adds 0.33 to 0.36 ms a frame; frame gaps unchanged at 31.3 ms. Under the 1.5 ms limit, so 1600 wide at 30 frames a second stays. Codec: video/mp4 avc1 (H.264) first, then webm h264, vp8, vp9 last; 2.5 Mbps. The copy runs 30 times a second whatever the screen rate. Auto clips: no download, under 60 s not kept, newest 15 and 3 GB kept. P2 window and test pages never record. Check 36.68 fails on v36.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
