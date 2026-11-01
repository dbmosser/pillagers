$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'37.03',what:")) { throw "check 37.03 is in the fixture already" }

SubRx @'
  {v:'37.02',what:
'@ @'
  {v:'37.03',what:'the profile keeps a second copy in IndexedDB: a save is mirrored, a cleared or unreadable localStorage save comes back from the copy, an erased save does not, and the browser is asked once to keep the storage',
   run:function(){
     if(typeof saveCopyPut!=='function'||typeof saveCopyRestore!=='function'||typeof savePersistAsk!=='function') return 'the profile has no second copy (no saveCopyPut, saveCopyRestore or savePersistAsk)';
     var q=[], fake, od=Object.getOwnPropertyDescriptor(window,'indexedDB'), ls0=null, slot3=null, un0=null, origRestore=saveCopyRestore, calls=0, got=null, raw, per=0, asked0=SAVE_PERSIST.asked, DB='pillagers-save';
     function drain(){ var n=0; while(q.length&&n++<500) q.shift()(); }
     function mkReq(){ return {}; }
     fake={data:{},open:function(name){
       var r=mkReq(), db=fake.data[name], fresh=!db, dbo;
       if(!db) db=fake.data[name]={};
       dbo={close:function(){},createObjectStore:function(n){ db[n]=db[n]||{}; return {}; },
         transaction:function(n){
           var tx={}, os={
             put:function(v,k){ db[n][k]=v; q.push(function(){ if(tx.oncomplete) tx.oncomplete(); }); return {}; },
             delete:function(k){ delete db[n][k]; q.push(function(){ if(tx.oncomplete) tx.oncomplete(); }); return {}; },
             openCursor:function(){
               var rq={}, keys=Object.keys(db[n]), at=-1;
               function step(){ at++;
                 rq.result=(at<keys.length)?{key:keys[at],value:db[n][keys[at]],continue:function(){ q.push(step); }}:null;
                 if(rq.onsuccess) rq.onsuccess(); }
               q.push(step); return rq; }
           };
           tx.objectStore=function(){ return os; };
           return tx; }};
       r.result=dbo;
       q.push(function(){ if(fresh&&r.onupgradeneeded) r.onupgradeneeded(); if(r.onsuccess) r.onsuccess(); });
       return r; }};
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       ls0=localStorage.getItem(SKEY); slot3=localStorage.getItem('salvagerun:profile:3'); un0=localStorage.getItem(SKEY+':unreadable');
       Object.defineProperty(window,'indexedDB',{configurable:true,value:fake});
       if(SAVE_COPY.timer){ clearTimeout(SAVE_COPY.timer); SAVE_COPY.timer=0; } SAVE_COPY.pending=null;
       // 1. a save is mirrored
       raw=JSON.stringify(P);
       storeSet(raw); saveCopyFlush(); drain();
       if(!fake.data[DB]||!fake.data[DB].profile||!fake.data[DB].profile[SKEY]||fake.data[DB].profile[SKEY].raw!==raw) return 'a save did not reach the IndexedDB copy';
       // 2. localStorage cleared: the boot read comes from the copy and puts it back
       localStorage.removeItem(SKEY);
       saveCopyRestore=function(b,cb){ calls++; return origRestore(b,cb); };
       storeGet(); drain();
       if(calls!==1) return 'storeGet did not fall back to the copy when localStorage had no save';
       if(localStorage.getItem(SKEY)!==raw) return 'the copy was not put back into localStorage after a cleared save';
       storeGet(); drain();
       if(calls!==1) return 'storeGet went to the copy although localStorage held a good save';
       saveCopyRestore=origRestore;
       // 3. an unreadable save: the copy wins and the bad value is kept aside; a lost numbered save comes back too
       fake.data[DB].profile['salvagerun:profile:3']={raw:raw,t:1}; localStorage.removeItem('salvagerun:profile:3');
       localStorage.setItem(SKEY,'{bad');
       got=null; saveCopyRestore('{bad',function(r){ got=r; }); drain();
       if(!got||got.value!==raw) return 'an unreadable save did not come back from the copy';
       if(localStorage.getItem(SKEY)!==raw) return 'the unreadable save was not replaced by the copy';
       if(localStorage.getItem(SKEY+':unreadable')!=='{bad') return 'the unreadable save was not kept aside';
       if(localStorage.getItem('salvagerun:profile:3')!==raw) return 'a numbered save lost from localStorage was not put back';
       // 4. an erased save does not come back
       saveCopyDel(SKEY); drain();
       localStorage.removeItem(SKEY);
       got='x'; saveCopyRestore(null,function(r){ got=r; }); drain();
       if(got!==null) return 'an erased save still came back from the copy';
       // 5. the browser is asked once
       try{ Object.defineProperty(navigator,'storage',{configurable:true,value:{persist:function(){ per++; return Promise.resolve(true); }}}); }catch(_n){ return 'SKIP: navigator.storage cannot be stubbed'; }
       SAVE_PERSIST.asked=false; savePersistAsk(); savePersistAsk();
       if(per!==1) return 'the browser was asked to keep the storage '+per+' times, not once';
       if(!SAVE_PERSIST.armed&&!asked0) return 'no first-click hook asks the browser to keep the storage';
       return null;
     } finally {
       saveCopyRestore=origRestore;
       try{ if(od) Object.defineProperty(window,'indexedDB',od); else delete window.indexedDB; }catch(_i){}
       try{ delete navigator.storage; }catch(_s){}
       SAVE_PERSIST.asked=asked0;
       if(SAVE_COPY.timer){ clearTimeout(SAVE_COPY.timer); SAVE_COPY.timer=0; } SAVE_COPY.pending=null;
       try{
         if(ls0===null) localStorage.removeItem(SKEY); else localStorage.setItem(SKEY,ls0);
         if(slot3===null) localStorage.removeItem('salvagerun:profile:3'); else localStorage.setItem('salvagerun:profile:3',slot3);
         if(un0===null) localStorage.removeItem(SKEY+':unreadable'); else localStorage.setItem(SKEY+':unreadable',un0);
       }catch(_l){}
       __topClear();
     } }},
  {v:'37.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
