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

if ($s.Contains("  {v:'24.09',what:")) { throw "check 24.09 is in the fixture already" }

SubRx @'
  {v:'24.08',what:
'@ @'
  {v:'24.09',what:'his answer 18: every raid, career and demo, opens on 3, 2, 1, GO! with the world held until GO',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__loop) return 'SKIP: no raid here';
     var bad=[], g, p, x0, y0, t0, tl0, f, T, gs0=(typeof GO_SEC==='number')?GO_SEC:null, rb=blip, beeps=[], big=[], rf=ctx.fillText, ownF=false, ownB=false;
     function trace(){
       big=[]; ownF=true;
       ctx.fillText=function(s,x,y){ var m=/([\d.]+)px/.exec(String(ctx.font||'')); if(m&&+m[1]>=LH(60)) big.push(String(s)); return rf.apply(this,arguments); };
       try{ __drawHUD(); }finally{ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; ownF=false; }
       return big.slice();
     }
     try{
       __topClear(); __runPrep(); __resetCfg();
       if(gs0!==null) GO_SEC=3;
       blip=function(t){ beeps.push(String(t)+(arguments[3]?'+':'')); }; ownB=true;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player;
       if(!(g.goT>0)) bad.push('a new career raid has no countdown (goT '+g.goT+')');
       else {
         x0=p.x; y0=p.y; t0=g.t; tl0=g.timeLeft;
         keys={}; keys['KeyD']=true; keys['KeyS']=true;
         T=performance.now();
         for(f=0;f<20;f++) __loop(T+=50);
         if(!(g.goT>0.5&&g.goT<2.6)) bad.push('one second in, the count is at '+g.goT);
         if(g.t!==t0) bad.push('the raid time ran during the count ('+t0+' to '+g.t+')');
         if(g.timeLeft!==tl0) bad.push('the raid clock ran during the count');
         if(Math.abs(p.x-x0)+Math.abs(p.y-y0)>0.01) bad.push('he walked during the count');
         var tr=trace(); if(!tr.some(function(s){ return /^[123]$/.test(s); })) bad.push('no big number on the HUD during the count (big text: '+tr.join(',')+')');
         for(f=0;f<70&&g.goT>0;f++) __loop(T+=50);
         if(g.goT>0) bad.push('the count never reached GO');
         var tr2=trace(); if(tr2.indexOf('GO!')<0) bad.push('GO! is not on the HUD after the count (big text: '+tr2.join(',')+')');
         for(f=0;f<12;f++) __loop(T+=50);
         if(!(g.t>t0)) bad.push('the raid time does not run after GO');
         if(!(Math.abs(p.x-x0)+Math.abs(p.y-y0)>1)) bad.push('he cannot walk after GO');
         var lo=beeps.filter(function(b){ return b==='countgo'; }).length, hi=beeps.filter(function(b){ return b==='countgo+'; }).length;
         if(lo!==3||hi!==1) bad.push('the count beeps '+lo+' low and '+hi+' high, not 3 and 1');
       }
       keys={};
       if(__state()&&!__state().over) __endRaid('abandon');
       __topClear();
       if(typeof arcadeDeploy==='function'&&typeof arcadeLeave==='function'){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('arcadeDeploy built no demo raid');
         else { g=__state(); if(!g||!(g.goT>0)) bad.push('a demo run has no countdown (goT '+(g&&g.goT)+')'); }
         arcadeLeave();
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ keys={}; if(ownB) blip=rb; if(ownF){ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; } if(gs0!==null) GO_SEC=gs0; try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&typeof arcadeLeave==='function') arcadeLeave(); }catch(_al){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
