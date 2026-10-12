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

if ($s.Contains("  {v:'23.92',what:")) { throw "check 23.92 is in the fixture already" }

SubRx @'
  {v:'23.91',what:
'@ @'
  {v:'23.92',what:'his mode design and answer 7 (2026-10-12): a DEMO raid runs a 10 minute clock that counts down and reads under the score, at 0 the site burns like a normal raid, and the burn ends the run (RUN OVER with the score as it stood) instead of dropping him back into the fire',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop&&window.__textTrace&&window.__endRaid)) return 'SKIP: this fixture cannot step a raid';
     if(typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof raidClockOn!=='function') return 'SKIP: no arcade here';
     var bad=[], g, f, tr, t0, clk=false, bk=null, hadB=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'';
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(BK){ try{ bk=localStorage.getItem(BK); hadB=true; }catch(_b){} }
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       if(g.raidLen!==600) bad.push('the DEMO raid clock is '+g.raidLen+' s, not 600');
       if(!raidClockOn()) bad.push('the DEMO raid has no running clock');
       t0=g.timeLeft;
       for(f=0;f<20&&__state()===g;f++) __loop(performance.now()+f*16.7);
       if(!(g.timeLeft<t0)) bad.push('the DEMO clock did not run down ('+t0+' to '+g.timeLeft+')');
       if(__state()!==g) return bad.concat(['the DEMO raid ended in its first 20 frames']).join('; ');
       tr=__textTrace(function(){ __loop(performance.now()+400); });
       for(f=0;f<tr.length;f++) if(/^\d{1,2}:\d\d$/.test(tr[f].t)){ clk=true; break; }
       if(!clk) bad.push('no m:ss clock is drawn in the DEMO raid');
       if(raidClockOn()&&bad.length) return bad.join('; ');
       if(!raidClockOn()) return bad.join('; ');
       ARCADE.mine=700; ARCADE.mate=0; g.player.arcSh=0; ARCADE.holdT=0;
       g.timeLeft=0.02;
       for(f=0;f<6&&__state()===g&&!g.nuking;f++) __loop(performance.now()+1000+f*16.7);
       if(__state()!==g) bad.push('the clock running out ended the DEMO raid at once, with no burn');
       else if(g.nuking!==1) bad.push('at 0 the DEMO site is not burning (nuking '+g.nuking+', timeLeft '+g.timeLeft+')');
       else {
         for(f=0;f<500&&__state()===g;f++) __loop(performance.now()+2000+f*16.7);
         if(__state()===g) bad.push('the burn never ended the DEMO raid (nukeT '+g.nukeT+', over '+g.over+')');
         else if(__state()&&__state().arcade) bad.push('the burn dropped him into another DEMO raid');
         if(!ARCADE.over||ARCADE.over.why!=='burn') bad.push('the burn did not end the run (over '+JSON.stringify(ARCADE.over&&ARCADE.over.why)+')');
         else if(ARCADE.over.team!==700) bad.push('the run ended in the burn with the score '+ARCADE.over.team+', not the 700 it had');
         if(!ARCADE.on) bad.push('the burn left the arcade altogether');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
