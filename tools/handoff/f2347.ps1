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

if ($s.Contains("  {v:'23.47',what:")) { throw "check 23.47 is in the fixture already" }

SubRx @'
  {v:'23.46',what:
'@ @'
  {v:'23.47',what:'arcade24, his yes 2026-10-11: screen wake lock, with a stubbed navigator.wakeLock entering the arcade asks for a screen lock once, entering again asks nothing more, a lock the browser dropped is asked for again when the tab is visible, leaving releases it and asks nothing after, a refused or missing API leaves the arcade working, and with the arcade off nothing is asked',
   run:function(){
     var bad=[], nReq=0, nRel=0, types=[], last=null, mode='ok', had=Object.prototype.hasOwnProperty.call(navigator,'wakeLock'),
         own=false, WL=null, stub;
     try{ WL=navigator.wakeLock; }catch(_g){ WL=null; }
     function sent(){ var s={released:false,type:'screen',release:function(){ nRel++; s.released=true; return {then:function(f){ if(f) f(); return this; },catch:function(){ return this; }}; },addEventListener:function(){},removeEventListener:function(){}}; return s; }
     stub={request:function(t){ nReq++; types.push(t);
       if(mode==='throw') throw new Error('refused');
       if(mode==='reject') return {then:function(f,r){ if(r) r(new Error('refused')); return this; },catch:function(){ return this; }};
       last=sent(); var s=last; return {then:function(f){ if(f) f(s); return this; },catch:function(){ return this; }}; }};
     function vis(){ document.dispatchEvent(new Event('visibilitychange')); }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof ARCADE!=='object') return 'no arcadeEnter in this build';
       if(typeof arcadeWakeOn!=='function'||typeof ARCADE_WAKE!=='object') return 'no arcade wake lock in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       try{ Object.defineProperty(navigator,'wakeLock',{value:stub,configurable:true,writable:true}); own=true; }catch(_d){ return 'SKIP: navigator.wakeLock cannot be stubbed here'; }
       if(navigator.wakeLock!==stub) return 'SKIP: the navigator.wakeLock stub did not take';
       ARCADE_WAKE.lock=null; ARCADE_WAKE.pend=0; ARCADE_WAKE.want=0;
       // the arcade off: nothing is asked
       vis();
       if(nReq) bad.push('a visibilitychange with the arcade off asked for a wake lock');
       // entering asks once, for the screen
       if(!arcadeEnter('host')||!ARCADE.on) return bad.concat(['SKIP: arcadeEnter did not turn the arcade on']).join('; ');
       ARCADE.ownAt=Date.now();
       if(nReq!==1) bad.push('entering the arcade asked '+nReq+' times, not once');
       if(types[0]!=='screen') bad.push('the wake lock asked for '+types[0]+', not screen');
       if(!last||ARCADE_WAKE.lock!==last) bad.push('the granted wake lock was not kept');
       // entering again while the lock is held asks nothing more; nor does a visible tab
       arcadeEnter('host'); vis();
       if(nReq!==1) bad.push('a held lock was asked for again ('+nReq+' asks)');
       // the browser drops the lock when the tab is hidden; back on a visible tab it is asked for again
       if(!document.hidden){   // a hidden gate tab cannot stage the visible return; the rest still runs
         if(last) last.released=true;
         vis();
         if(nReq!==2) bad.push('a dropped lock was not asked for again on a visible tab ('+nReq+' asks)');
         if(!last||last.released||ARCADE_WAKE.lock!==last) bad.push('the second lock was not kept');
       }
       // leaving releases it, and nothing is asked after
       var n0=nReq, held=last;
       arcadeLeave();
       if(ARCADE.on) bad.push('arcadeLeave left the arcade on');
       if(nRel!==1||!held||!held.released) bad.push('leaving released '+nRel+' locks, not 1');
       if(ARCADE_WAKE.lock) bad.push('the lock is still kept after leave');
       vis();
       if(nReq!==n0) bad.push('a visibilitychange after leave asked for a wake lock');
       // a refused request: the arcade still enters and leaves
       mode='reject';
       if(!arcadeEnter('host')||!ARCADE.on) bad.push('a refused wake lock stopped the arcade');
       if(ARCADE_WAKE.lock||ARCADE_WAKE.pend) bad.push('a refused wake lock left state behind');
       arcadeLeave();
       mode='throw';
       if(!arcadeEnter('host')||!ARCADE.on) bad.push('a throwing wake lock stopped the arcade');
       arcadeLeave();
       // a missing API: the arcade still enters and leaves
       navigator.wakeLock=undefined;
       if(!arcadeEnter('host')||!ARCADE.on) bad.push('a missing wake lock API stopped the arcade');
       arcadeLeave();
       if(ARCADE.on) bad.push('the arcade did not leave without a wake lock API');
       // a normal raid asks nothing
       navigator.wakeLock=stub; mode='ok'; n0=nReq;
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(__state()&&__state().arcade) bad.push('a normal raid is flagged arcade');
       vis();
       if(nReq!==n0) bad.push('a normal raid asked for a wake lock');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(own){ delete navigator.wakeLock; if(had&&navigator.wakeLock!==WL) Object.defineProperty(navigator,'wakeLock',{value:WL,configurable:true,writable:true}); } }catch(_r){}
       try{ if(typeof ARCADE_WAKE==='object'){ ARCADE_WAKE.lock=null; ARCADE_WAKE.pend=0; ARCADE_WAKE.want=0; } }catch(_w){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
