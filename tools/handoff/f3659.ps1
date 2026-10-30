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

if ($s.Contains("  {v:'36.59',what:")) { throw "check 36.59 is in the fixture already" }

SubRx @'
  {v:'36.58',what:
'@ @'
  {v:'36.59',what:'F9 records beyond three minutes and saves on extract; every clip is kept; idle hub footage advances and a wake key is consumed',
   run:function(){
     var bad=[], oldDb=attDb, oldDisk=typeof attDiskList==='function'?attDiskList:null, oldEl=attEl, oldMark=REC.mark, oldTell=recTell, oldMr=window.MediaRecorder, oldNow=Date.now, oldRaf=window.requestAnimationFrame, oldCancel=window.cancelAnimationFrame,
         oldPut=attClipPut, oldCreate=document.createElement, oldAtt=ATT, oldRec=REC, oldF=FSG.open, oldPad=PAD.on, oldArc=ARCADE.on, saved=0, store={main:new Blob(['legacy'])}, rows=null, downloads=[], plays=[], g, clock=1700000000000;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over) return 'staging: no raid';
       ARCADE.on=false; FSG.open=false; PAD.on=false;
       if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
       Date.now=function(){ return clock; }; window.requestAnimationFrame=function(){ return 1; }; window.cancelAnimationFrame=function(){};
       REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:oldRec.max,saving:false,fileStamp:'',fileCount:0}; recTell=function(){};
       window.MediaRecorder=function(stream){ this.stream=stream; this.start=function(){}; this.stop=function(){ if(this.ondataavailable) this.ondataavailable({data:new Blob(['capture-'+saved])}); saved++; if(this.onstop) this.onstop(); }; };
       window.MediaRecorder.isTypeSupported=function(){ return true; };
       attDb=function(cb){ cb({close:function(){},transaction:function(){
         var tx={objectStore:function(){ return {put:function(b,k){ store[k]=b; },add:function(b,k){ if(store[k]) throw new Error('duplicate clip key'); store[k]=b; return {}; },openCursor:function(){ var q={}, ks=Object.keys(store), ix=0, fn; function step(){ q.result=ix<ks.length?{key:ks[ix],value:store[ks[ix]],continue:function(){ ix++; step(); }}:null; fn(); } Object.defineProperty(q,'onsuccess',{set:function(f){ fn=f; step(); }}); return q; }}; }};
         Object.defineProperty(tx,'oncomplete',{set:function(f){ f(); }}); return tx;
       }}); };
       document.createElement=function(tag){ if(tag==='a'){ var a=oldCreate.call(document,tag); a.click=function(){ downloads.push(a.download); }; return a; } return oldCreate.apply(document,arguments); };
       if(!recStart()) return 'recording would not start';
       clock+=185000; g.paused=true; g.mapOpen=true; g.bagOpen=true; recDraw();
       if(!REC.on) bad.push('the recording stopped after 180 seconds or in a page menu');
       if(!REC.mark||REC.mark.textContent!=='rec 3:05') bad.push('elapsed mark is not rec 3:05');
       g.paused=false; g.mapOpen=false; g.bagOpen=false;
       __endRaid('extract');
       if(REC.on||saved!==1) bad.push('extract did not stop and save');
       __hubEnter(); __topClear();
       if(!recStart()) bad.push('second recording would not start'); else { clock+=1000; recStop(); }
       attClipList(function(r){ rows=r; });
       if(!rows||rows.length!==3||Object.keys(store).filter(function(k){ return k.indexOf('clip-')===0; }).length!==2) bad.push('two new captures and legacy main were not all retained');
       if(downloads.length!==2||downloads[0]===downloads[1]||!/^pillagers-attract-\d{8}-\d{4}(?:-\d+)?\.webm$/.test(downloads[0])) bad.push('download names are not unique dated names');
       if(rows&&rows[0].key==='main') bad.push('legacy main is not oldest');
       if(typeof attMakeList!=='function') return bad.concat('no playlist loader').join('; ');
       var autoPlay=false, d=oldCreate.call(document,'div'), v={style:{},setAttribute:function(k,s){ this[k]=s; plays.push(s); },removeAttribute:function(k){ delete this[k]; },load:function(){},play:function(){ if(autoPlay&&this.onplaying) this.onplaying(); return {catch:function(){}}; },pause:function(){}};
       d.querySelector=function(sel){ return sel==='video'?v:null; }; attEl=function(){ return d; };
       ATT={last:clock-31000,on:false,el:d,src:null,tried:false,list:[],ix:-1,gen:0,ready:false,playing:false,pending:false,mx:0,my:0,keyTime:0};
       attDiskList=function(cb){ cb([{src:'attract/duplicate.webm',size:rows[0].blob.size},{src:'attract/disk.webm',size:9999}]); };
       attTick();
       if(ATT.on||d.style.display!=='none'||v.style.visibility!=='hidden') bad.push('overlay showed before footage decoded');
       autoPlay=true; if(v.onplaying) v.onplaying();
       if(!ATT.on||plays.length!==1||ATT.list.length!==6||ATT.list.some(function(c){ return c.src==='attract/duplicate.webm'; })) bad.push('30 idle seconds in hub did not load every capture and deduplicate the disk copy');
       var first=ATT.src; if(v.onended) v.onended();
       if(!ATT.on||plays.length!==2||first===ATT.src) bad.push('ended did not advance to the second capture');
       if(v.onerror) v.onerror();
       if(plays.length!==3||!ATT.on) bad.push('a broken capture was not skipped');
       if(v.onended) v.onended(); if(v.onended) v.onended();
       if(ATT.src!==first) bad.push('playlist did not wrap to newest capture');
       var leaked=false, onKey=function(){ leaked=true; }; window.addEventListener('keydown',onKey);
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyQ',key:'q',bubbles:true,cancelable:true})); window.removeEventListener('keydown',onKey);
       if(ATT.on||d.style.display!=='none'||leaked) bad.push('wake key was not consumed');
       ATT.last=clock-31000; FSG.open=true; attTick(); if(ATT.on) bad.push('clip showed over fullscreen gate'); FSG.open=false;
       var input=oldCreate.call(document,'input'); document.body.appendChild(input); input.focus(); ATT.last=clock-31000; attTick(); if(ATT.on) bad.push('clip showed over text entry'); input.remove();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); ATT.last=clock-31000; attTick(); if(ATT.on) bad.push('clip showed in raid');
       if(!recStart()) bad.push('safety staging failed'); else { clock+=1800001; recDraw(); if(REC.on) bad.push('30 minute safety stop failed'); }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(REC.on) recStop(); recMark(false); if(REC.mark&&REC.mark!==oldMark) REC.mark.remove(); attStop(); (ATT.list||[]).forEach(function(c){ if(c.owned) URL.revokeObjectURL(c.src); }); }catch(_c){}
       attDb=oldDb; if(oldDisk) attDiskList=oldDisk; attClipPut=oldPut; attEl=oldEl; recTell=oldTell; document.createElement=oldCreate; window.MediaRecorder=oldMr; Date.now=oldNow; window.requestAnimationFrame=oldRaf; window.cancelAnimationFrame=oldCancel;
       ATT=oldAtt; REC=oldRec; FSG.open=oldF; PAD.on=oldPad; ARCADE.on=oldArc;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'36.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
