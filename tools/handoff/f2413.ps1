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

if ($s.Contains("  {v:'24.13',what:")) { throw "check 24.13 is in the fixture already" }

SubRx @'
  {v:'24.12',what:
'@ @'
  {v:'24.13',what:'his answer 19: the final minute plays a sting and the clock is red from 1:00 and pops each second, in the career clock and the demo clock',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tickClockWarn!=='function') return 'SKIP: no raid here';
     var bad=[], g, keep=null, heard=[], rb=blip, rs=say, ownB=false, ownF=false, rf=ctx.fillText, clk=[], osc=0;
     function clock(left,fn){
       g.timeLeft=left; clk.length=0; ownF=true;
       ctx.fillText=function(t){ var tr=ctx.getTransform?ctx.getTransform():{a:1}; clk.push({t:String(t),c:String(ctx.fillStyle).toLowerCase(),k:tr.a}); return rf.apply(this,arguments); };
       try{ fn(); }catch(_h){} finally{ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; ownF=false; }
       for(var i=0;i<clk.length;i++) if((/^\d+:\d\d$/).test(clk[i].t)) return clk[i];
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!raidClockOn()) return 'SKIP: the raid clock is off here';
       keep={timeLeft:g.timeLeft,warnPrev:g.warnPrev};
       blip=function(k){ heard.push(String(k)); }; say=function(){}; ownB=true;
       tickClockWarn(60.02,59.98);
       if(heard.indexOf('lastmin')<0) bad.push('the one minute mark plays '+(heard.join(',')||'nothing')+', no final minute sting');
       heard.length=0; tickClockWarn(120.02,119.98);
       if(heard.indexOf('clockwarn')<0||heard.indexOf('lastmin')>=0) bad.push('the two minute mark plays '+(heard.join(',')||'nothing')+', not the clock siren');
       blip=rb; say=rs; ownB=false;
       var c61=clock(61,drawHUD), c60=clock(60,drawHUD), c45=clock(45,drawHUD), cA=clock(59.96,drawHUD), cB=clock(59.2,drawHUD);
       if(!c61||!c60||!c45||!cA||!cB) return 'SKIP: the clock was not drawn here';
       if(c61.c==='#ff5a4a') bad.push('1:01 is already red');
       if(c60.t!=='1:00'||c60.c!=='#ff5a4a') bad.push('with 60 s left the clock reads '+c60.t+' in '+c60.c+', not 1:00 in red');
       if(c45.c!=='#ff5a4a') bad.push('0:45 is not red');
       if(!(cA.k>cB.k*1.08)) bad.push('the red clock does not pop as a second turns (scale '+cA.k.toFixed(3)+' just after, '+cB.k.toFixed(3)+' late in the second)');
       if(typeof __audio==='object'&&__audio.record&&__audio.blipRaw){
         var lg=__audio.record(function(){ __audio.blipRaw('lastmin'); });
         osc=(lg&&lg.osc)?lg.osc.length:0;
         if(osc<3) bad.push('the final minute sting makes '+osc+' oscillators, so it plays nothing');
       }
       g.timeLeft=keep.timeLeft; g.warnPrev=keep.warnPrev;
       __endRaid('abandon'); __topClear();
       if(typeof arcadeDeploy==='function'&&typeof arcadeLeave==='function'&&typeof arcadeScoreHud==='function'){
         if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('arcadeDeploy built no demo raid');
         else {
           g=__state();
           if(raidClockOn()){
             var d61=clock(61,function(){ arcadeScoreHud(60,1); }), d60=clock(60,function(){ arcadeScoreHud(60,1); });
             if(!d61||!d60) bad.push('the demo clock was not drawn');
             else { if(d61.c==='#ff5a4a') bad.push('the demo clock is red at 1:01'); if(d60.c!=='#ff5a4a') bad.push('the demo clock is not red at 1:00'); }
           }
         }
         arcadeLeave();
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(ownB){ blip=rb; say=rs; } if(ownF){ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; } try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&typeof arcadeLeave==='function') arcadeLeave(); }catch(_al){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
