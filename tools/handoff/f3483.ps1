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

if ($s.Contains("  {v:'34.83',what:")) { throw "check 34.83 is in the fixture already" }

SubRx @'
  {v:'34.82',what:
'@ @'
  {v:'34.83',what:'cw-drscap, his answer of 2026-10-25 ("Yes picture quality should reduce to chase a higher cap", "Eg dynamic resolution"): with a cap above 60 auto resolution steps down to hold the cap but never past the screen rate; cap off and caps on a 60 Hz screen keep the 60 rule; the cadence a cap makes on a faster screen is not read as slow; quality climbs back once the cap holds; the screen rate is measured from every browser frame',
   run:function(){
     if(typeof drsTick!=='function'||typeof DRS==='undefined'||typeof drsBeginRaid!=='function'||typeof frameCapSkip!=='function'||typeof DRSSESSION==='undefined') return 'SKIP: no auto resolution here';
     var d0=JSON.stringify(DRS), c0=JSON.stringify(CFG), q0=JSON.stringify(GFXQ), sess0={raid:DRSSESSION.raid,settled:DRSSESSION.settled}, os=sayWhenFree, cl0=CAP_LAST, hasV=(typeof VSYNC!=='undefined'), v0=hasV?JSON.stringify(VSYNC):null, bad=[], t=100000, events=[], i, k, ts, last, dn, up, T;
     function screen(hz){ if(hasV) VSYNC.ms=hz?1000/hz:0; }
     function reset(){ DRSSESSION.settled=null; drsBeginRaid(t); DRS.said=1; events=[]; }
     function note(oq,sc){ if(oq!==DRS.q||sc!==DRS.scale) events.push({t:t,dir:(DRS.q>oq||DRS.scale<sc)?-1:1}); if(DRS.scale<0.75-1e-6) bad.push('under the 75 percent floor'); }
     function feed(gap,ms,work){ var end=t+ms, oq, sc; while(t<end){ t+=gap; oq=DRS.q; sc=DRS.scale; drsTick(gap,t,work); note(oq,sc); } }
     function capped(cap,hz,ms,work){ var end=t+ms, step=1000/hz, oq, sc; CFG.fpsCap=cap; CAP_LAST=0; last=0; while(t<end){ t+=step; if(frameCapSkip(t)) continue; if(last>0){ oq=DRS.q; sc=DRS.scale; drsTick(t-last,t,work); note(oq,sc); } last=t; } }
     function downs(){ var n=0, j; for(j=0;j<events.length;j++) if(events[j].dir<0) n++; return n; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); sayWhenFree=function(){};
       CFG.gfxAuto=1; CFG.gfxScale=1;
       if(!hasV) bad.push('the game does not measure the screen rate');
       // 1. a 144 cap on a 144 Hz screen that only makes 90 frames steps quality down (it used to keep full quality, his old 2.43 a)
       screen(144); CFG.fpsCap=144; reset(); feed(11,30000,6);
       if(!downs()) bad.push('a 144 cap at 90 fps on a 144 Hz screen did not step quality down');
       // 2. a 120 cap making 72 frames on a 144 Hz screen steps down too
       screen(144); CFG.fpsCap=120; reset(); feed(1000/72,30000,6);
       if(!downs()) bad.push('a 120 cap at 72 fps on a 144 Hz screen did not step quality down');
       // 3. a cap above the screen rate aims at the screen rate: 240 on 144 Hz at a steady 144 keeps full quality
       screen(144); CFG.fpsCap=240; reset(); feed(1000/144,30000,3);
       if(events.length) bad.push('a 240 cap on a 144 Hz screen running at 144 fps moved quality '+events.length+' times');
       // 4. on a 60 Hz screen a 144 cap keeps the 60 rule
       screen(60); CFG.fpsCap=144; reset(); feed(1000/60,30000,6);
       if(events.length) bad.push('a 144 cap on a 60 Hz screen running at 60 fps moved quality');
       // 5. cap off still aims at 60: 90 fps on a 144 Hz screen keeps full quality
       screen(144); CFG.fpsCap=0; reset(); feed(11,30000,6);
       if(events.length) bad.push('with the cap off 90 fps on a 144 Hz screen moved quality');
       // 6. the cadence a cap makes on a faster screen (one and two refresh gaps mixed) is not slow
       T=[[120,144],[90,144],[75,144],[165,144],[120,165],[90,120]];
       for(k=0;k<T.length;k++){ screen(T[k][1]); reset(); capped(T[k][0],T[k][1],30000,3); if(downs()) bad.push('a '+T[k][0]+' cap on a light game on a '+T[k][1]+' Hz screen stepped quality down'); }
       // 7. once the game holds the cap again with headroom, quality climbs back
       screen(144); CFG.fpsCap=144; reset(); feed(11,30000,6); dn=downs(); feed(1000/144,90000,2); up=events.length-dn;
       if(dn&&up<1) bad.push('quality never climbed back after 90 seconds holding the cap');
       // 8. no measured screen rate yet: the old 60 rule
       screen(0); CFG.fpsCap=144; reset(); feed(11,30000,6);
       if(events.length) bad.push('with no measured screen rate a 144 cap at 90 fps moved quality');
       // 9. the screen rate measure: 144 Hz browser frames read near 6.94 ms, a heavy spell does not double it, a move to a 60 Hz screen is followed, a pause is ignored
       if(hasV&&typeof vsyncNote==='function'){
         VSYNC.ms=0; VSYNC.g=[]; VSYNC.n=0; VSYNC.last=0; ts=500000;
         for(i=0;i<300;i++){ ts+=1000/144+((i%3)-1)*0.2; vsyncNote(ts); }
         if(!(Math.abs(VSYNC.ms-1000/144)<0.4)) bad.push('144 Hz browser frames read as '+(+VSYNC.ms).toFixed(2)+' ms');
         for(i=0;i<300;i++){ ts+=2000/144; vsyncNote(ts); }
         if(!(VSYNC.ms<8.5)) bad.push('four seconds of two refresh frames moved the 144 Hz screen rate to '+(+VSYNC.ms).toFixed(2)+' ms');
         for(i=0;i<4000;i++){ ts+=1000/60; vsyncNote(ts); }
         if(!(VSYNC.ms>15)) bad.push('a minute on a 60 Hz screen still reads '+(+VSYNC.ms).toFixed(2)+' ms');
         k=VSYNC.ms; vsyncNote(ts+5000); if(VSYNC.ms!==k) bad.push('a five second pause changed the screen rate');
       }else if(hasV) bad.push('no screen rate measure function');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       sayWhenFree=os; CAP_LAST=cl0;
       try{
         DRSSESSION.raid=sess0.raid; DRSSESSION.settled=sess0.settled;
         var ds=JSON.parse(d0), cs=JSON.parse(c0), qs=JSON.parse(q0), kk;
         for(kk in DRS) if(!(kk in ds)) delete DRS[kk]; for(kk in ds) DRS[kk]=ds[kk]; for(kk in cs) CFG[kk]=cs[kk]; for(kk in qs) GFXQ[kk]=qs[kk];
         if(hasV){ var vs=JSON.parse(v0); for(kk in vs) VSYNC[kk]=vs[kk]; }
         gfxqApply();
       }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
