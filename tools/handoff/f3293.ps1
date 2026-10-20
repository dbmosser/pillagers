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

if ($s.Contains("  {v:'32.93',what:")) { throw "check 32.93 is in the fixture already" }

SubRx @'
  {v:'32.92',what:
'@ @'
  {v:'32.93',what:'cw-demoreport, his answer 66: a finished demo run posts one run report to the local collector tagged demo and its seat after the card is up, a failed post makes no download and no banner, off localhost nothing is sent, a career run end is unchanged',
   run:function(){
     if(typeof demoReportEnd!=='function'||typeof demoReportPost!=='function') return 'a demo run end posts nothing: no demoReportEnd in this build';
     if(!(window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot run a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof arcadeRunEnd!=='function'||typeof ARCADE!=='object'||typeof NET!=='object') return 'SKIP: no arcade here';
     var bad=[], posts=[], timers=[], dls=0, ae=0, of=window.fetch, ost=window.setTimeout, oce=document.createElement, nsp=netSamePost, rs=say, dE=downloadExport, aE=autoExport, ld=LOCAL_DROP, URL1='http://localhost:8799/telemetry',
         nsv=null, k, src0, tried0, ownAtt=false, r, p;
     function mkFetch(mode){ return function(u,o){ posts.push({u:String(u),b:String((o&&o.body)||''),m:o&&o.method}); if(mode==='throw') throw new Error('x'); return mode==='fail'?Promise.reject(new Error('down')):Promise.resolve({ok:true}); }; }
     function hold(){ timers.length=0; window.setTimeout=function(f,d){ if(d===333){ timers.push(f); return 0; } return ost.apply(window,arguments); }; }
     function release(){ window.setTimeout=ost; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       say=function(){};
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(m){},close:function(){}}; NET.pair='tp';
       netSamePost=function(m){ return true; };
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       downloadExport=function(){ dls++; }; autoExport=function(){ ae++; };
       document.createElement=function(t){ if(String(t).toLowerCase()==='a') dls++; return oce.apply(document,arguments); };
       LOCAL_DROP=URL1;
       ARCADE.ini=null; ARCADE.over=null;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.role='host'; ARCADE.solo=1;
       // ONE: the real run end, window 1
       window.fetch=mkFetch('ok'); hold();
       ARCADE.mine=777; ARCADE.mate=0; ARCADE.kills=3;
       arcadeRunEnd('idle');
       release();
       if(posts.length) bad.push('ONE: the report was posted before the card was up (not deferred)');
       if(timers.length!==1) bad.push('ONE: a demo run end queued '+timers.length+' posts, not 1');
       else {
         timers[0]();
         if(posts.length!==1) bad.push('ONE: the run end made '+posts.length+' posts, not 1');
         else {
           if(posts[0].u!==URL1||posts[0].m!=='POST') bad.push('ONE: the post went to '+posts[0].u+' by '+posts[0].m);
           if(!/=== DEMO RUN ===/.test(posts[0].b)||!/demo: yes/.test(posts[0].b)) bad.push('ONE: the post carries no demo tag');
           if(!/seat: p1/.test(posts[0].b)) bad.push('ONE: the host window is not tagged seat p1');
           if(!/FLIGHT RECORDER/.test(posts[0].b)) bad.push('ONE: the post is not the run report');
         }
       }
       // TWO: window 2 is told apart
       if(ARCADE.on){
         ARCADE.role='p2'; posts.length=0; window.fetch=mkFetch('ok'); hold();
         r=demoReportEnd('end'); release();
         if(!r||timers.length!==1) bad.push('TWO: player 2 queued '+timers.length+' posts');
         else { timers[0](); if(posts.length!==1||!/seat: p2/.test(posts[0].b)) bad.push('TWO: player 2 report is not tagged seat p2 ('+posts.length+' posts)'); }
         ARCADE.role='host';
         // THREE: collector down (rejected and thrown): no file, no banner, no profile autoExport
         dls=0; ae=0;
         ['fail','throw'].forEach(function(mode){
           posts.length=0; window.fetch=mkFetch(mode); hold(); demoReportEnd('end'); release();
           try{ if(timers.length) timers[0](); }catch(_t){ bad.push('THREE: a '+mode+' post threw out of the run end'); }
         });
         if(dls||ae) bad.push('THREE: a failed demo post made '+dls+' download(s) and '+ae+' autoExport call(s)');
         if(/downloadExport|fallback|say2?\(/.test(String(demoReportPost)+String(demoReportEnd))) bad.push('THREE: the demo post code reaches for a download or a banner');
         // FOUR: off localhost nothing is sent
         LOCAL_DROP=null; posts.length=0; window.fetch=mkFetch('ok'); hold();
         r=demoReportEnd('end'); release();
         if(r||timers.length||posts.length) bad.push('FOUR: off localhost a demo run end still queued or sent a post');
         LOCAL_DROP=URL1;
       } else bad.push('TWO: the arcade went off after the run end');
       // FIVE: a career run end (no arcade) posts nothing
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       posts.length=0; window.fetch=mkFetch('ok'); hold();
       r=demoReportEnd('end'); release();
       if(r||timers.length||posts.length) bad.push('FIVE: with no arcade a run end queued a demo post');
       if(/demoReport|DEMOREP/.test(String(aE))||/demoReport|DEMOREP/.test(String(ocCommit))) bad.push('FIVE: the career report path calls the demo post');
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       release(); window.fetch=of; LOCAL_DROP=ld;
       try{ document.createElement=oce; }catch(_c){}
       try{ netSamePost=nsp; downloadExport=dE; autoExport=aE; }catch(_n0){}
       say=rs;
       try{ NET.on=false; NET.role=''; }catch(_o){}
       try{ ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.ini=null; ARCADE.over=null; }catch(_z){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l2){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.solo=0; ARCADE.role=''; ARCADE.idleSaid=0; ARCADE.wantIn=0; }catch(_m){}
       try{ var oc=document.querySelector('#attract .arcover'); if(oc) oc.style.display='none'; }catch(_oc){}
       __topClear();
     } }},
  {v:'32.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
