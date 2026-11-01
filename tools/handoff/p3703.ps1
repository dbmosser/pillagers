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

# THE PROFILE KEEPS A SECOND COPY IN INDEXEDDB AND ASKS THE BROWSER TO KEEP IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function storeSet(v){
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   // v23.20 (arcade1): an arcade session never writes his save, by any path

'@ @'
// v37.xx (cw-savecopy): THE PROFILE KEEPS A SECOND COPY IN INDEXEDDB. On itch.io's default domain every game shares one storage area that
// other games can read or clear, and Safari can delete script data after a week without a click. localStorage stays the save (same key,
// same shape, no migration); every save is also mirrored into IndexedDB (database pillagers-save, store profile, record key = the save key),
// and the boot reads the copy back only when localStorage has no save or one that will not parse. Erasing a save on the title erases its copy.
var SAVE_COPY={pending:null,timer:0,puts:0,restored:'',state:'idle'};
var SAVE_COPY_KEY=/^salvagerun:profile(?::[2-8])?$/;
function saveCopyOn(){ try{ return !NETSLOT&&typeof indexedDB!=='undefined'&&!!indexedDB; }catch(_e){ return false; } }
function saveCopyValid(raw){
  if(typeof raw!=='string'||raw.charAt(0)!=='{') return false;
  try{ var d=JSON.parse(raw); return !!(d&&typeof d.credits==='number'&&isFinite(d.credits)); }catch(_e){ return false; }
}
function saveCopyDb(cb){
  var done=false;
  function fin(db){ if(done){ try{ if(db) db.close(); }catch(_c){} return; } done=true; cb(db); }
  if(!saveCopyOn()) return cb(null);
  try{ var r=indexedDB.open('pillagers-save',1);
       r.onupgradeneeded=function(){ try{ r.result.createObjectStore('profile'); }catch(_u){} };
       r.onsuccess=function(){ fin(r.result); }; r.onerror=function(){ fin(null); }; }
  catch(e){ fin(null); }
}
function saveCopyPut(key,raw,cb){
  saveCopyDb(function(db){
    if(!db){ SAVE_COPY.state='no copy store'; if(cb) cb(false); return; }
    var done=false;
    function fin(ok){ if(done) return; done=true; try{ db.close(); }catch(_c){} if(ok){ SAVE_COPY.puts++; SAVE_COPY.state='kept'; } else SAVE_COPY.state='copy failed'; if(cb) cb(ok); }
    try{ var tx=db.transaction('profile','readwrite'); tx.objectStore('profile').put({raw:raw,t:Date.now()},key);
         tx.oncomplete=function(){ fin(true); }; tx.onabort=function(){ fin(false); }; tx.onerror=function(){ fin(false); }; }
    catch(e){ fin(false); }
  });
}
function saveCopyDel(key,cb){
  if(SAVE_COPY.pending&&SAVE_COPY.pending.key===key) SAVE_COPY.pending=null;
  saveCopyDb(function(db){
    if(!db){ if(cb) cb(false); return; }
    var done=false;
    function fin(ok){ if(done) return; done=true; try{ db.close(); }catch(_c){} if(cb) cb(ok); }
    try{ var tx=db.transaction('profile','readwrite'); tx.objectStore('profile').delete(key);
         tx.oncomplete=function(){ fin(true); }; tx.onabort=function(){ fin(false); }; tx.onerror=function(){ fin(false); }; }
    catch(e){ fin(false); }
  });
}
// Saves come often, so the copy is written once the saves go quiet (400 ms), and at once when the page is hidden or closed.
function saveCopyFlush(){
  var p=SAVE_COPY.pending; SAVE_COPY.pending=null;
  if(SAVE_COPY.timer){ clearTimeout(SAVE_COPY.timer); SAVE_COPY.timer=0; }
  if(p) saveCopyPut(p.key,p.raw);
}
function saveCopyQueue(raw){
  if(!saveCopyOn()||typeof raw!=='string'||raw.charAt(0)!=='{') return;
  SAVE_COPY.pending={key:SKEY,raw:raw};
  if(!SAVE_COPY.timer) SAVE_COPY.timer=setTimeout(saveCopyFlush,400);
}
try{ window.addEventListener('pagehide',function(){ saveCopyFlush(); }); document.addEventListener('visibilitychange',function(){ if(document.visibilityState==='hidden') saveCopyFlush(); }); }catch(_scp){}
// Boot: localStorage held no save, or one that will not parse (badRaw). Hand back the copy of this save if there is one, and put back
// every other save (slots 2 to 8) that localStorage lost. An unreadable value is kept aside under SKEY:unreadable, as it always was.
function saveCopyRestore(badRaw,cb){
  var fired=false, tm=0, found=null, ended=false;
  function fb(){ return badRaw===null?null:{key:SKEY,value:badRaw}; }
  function fin(r){ if(fired) return; fired=true; clearTimeout(tm); cb(r); }
  tm=setTimeout(function(){ fin(fb()); },2500);
  saveCopyDb(function(db){
    if(!db) return fin(fb());
    function end(){
      if(ended) return; ended=true;
      try{ db.close(); }catch(_c){}
      if(found===null) return fin(fb());
      if(badRaw!==null){ try{ localStorage.setItem(SKEY+':unreadable',String(badRaw)); }catch(_u){} }
      try{ localStorage.setItem(SKEY,found); }catch(_w){}
      SAVE_COPY.restored=SKEY; SAVE_COPY.state='restored from the copy';
      fin({key:SKEY,value:found});
    }
    try{
      var tx=db.transaction('profile','readonly'), q=tx.objectStore('profile').openCursor();
      q.onsuccess=function(){
        var c=q.result, k, v;
        if(!c) return end();
        k=String(c.key); v=c.value&&c.value.raw;
        if(SAVE_COPY_KEY.test(k)&&saveCopyValid(v)){
          if(k===SKEY) found=v;
          else { try{ if(localStorage.getItem(k)===null) localStorage.setItem(k,v); }catch(_s){} }
        }
        c.continue();
      };
      q.onerror=function(){ end(); }; tx.onabort=function(){ end(); };
    }catch(e){ end(); }
  });
}
// Ask the browser to keep this site's storage, once, after the first click, key or touch (a browser may refuse; nothing depends on it).
var SAVE_PERSIST={asked:false,armed:false,result:null};
function savePersistAsk(){
  if(SAVE_PERSIST.asked) return; SAVE_PERSIST.asked=true;
  try{ if(navigator.storage&&navigator.storage.persist){ var p=navigator.storage.persist(); if(p&&p.then) p.then(function(g){ SAVE_PERSIST.result=!!g; },function(){}); } }catch(_pe){}
}
try{
  (function(){
    var ev=['pointerdown','keydown','touchend'], i;
    function go(){ for(var j=0;j<ev.length;j++) window.removeEventListener(ev[j],go,true); savePersistAsk(); }
    for(i=0;i<ev.length;i++) window.addEventListener(ev[i],go,true);
    SAVE_PERSIST.armed=true;
  })();
}catch(_spa){}
function storeSet(v){
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return;   // v23.20 (arcade1): an arcade session never writes his save, by any path
  saveCopyQueue(v);   // v37.xx (cw-savecopy): the second copy, written even if localStorage is full

'@

SubRx @'
  try{
    var v=localStorage.getItem(SKEY);
    return Promise.resolve(v===null?null:{key:SKEY,value:v});
  }catch(e2){ return Promise.resolve(null); }

'@ @'
  // v37.xx (cw-savecopy): a missing or unparsable localStorage save falls back to the IndexedDB copy (saveCopyRestore).
  var v=null;
  try{ v=localStorage.getItem(SKEY); }catch(e2){ v=null; }
  if(saveCopyValid(v)||!saveCopyOn()) return Promise.resolve(v===null?null:{key:SKEY,value:v});
  return new Promise(function(res){ saveCopyRestore(v,res); });

'@

SubRx @'
        try{ localStorage.removeItem(slotKey(armed)); }catch(e){}

'@ @'
        try{ localStorage.removeItem(slotKey(armed)); }catch(e){}
        try{ saveCopyDel(slotKey(armed)); }catch(_scd){}   // v37.xx (cw-savecopy): an erased save takes its second copy with it, or the next boot would bring it back

'@

SubRx @'
var VER='37.02';
'@ @'
var VER='37.03';
'@

$pat = "(?m)^  now:'v37\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.03: The save now has a second copy the browser keeps apart from the main one, so another game on the same site clearing the storage no longer wipes progress. Watch for: a save you erased on the title staying gone, and no change at all in a normal load. Firefox may show a small permission box about keeping storage after the first click. Check 37.03 fails on v37.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
