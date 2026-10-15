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

if ($s.Contains("  {v:'27.25',what:")) { throw "check 27.25 is in the fixture already" }

SubRx @'
  {v:'27.24',what:
'@ @'
  {v:'27.25',what:'coop7, the two player first: a player on a controller (player 2) can arm and cancel the air strike: both bumpers together arm it when the meter is full, neither bumper walks the belt for it, a single bumper tap still walks the belt, and the ready line names the chord',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pollPad!=='function'||typeof airKey!=='function'||typeof beltStep!=='function'||typeof PAD==='undefined') return 'SKIP: no arcade, pad or air strike in this fixture';
     var bad=[], g=null, p=null, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, oBS=beltStep, steps=0, gp, kPAD={on:PAD.on,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand,aimA:PAD.aimA}, A, i, lines=[], rs=say, own=false, oIv, oSh, oAr, hint=null;
     function mkpad(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function poll(down){ gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.iv=99; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.wheel=null; g.trade=null; mouse.down=false;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       beltStep=function(){ steps++; };
       A=airS(); A.m=AIR.need; A.aim=0; A.rdy=1;
       PAD.prev=[]; PAD.airChord=0; PAD.lbAt=null; PAD.rbAt=null;
       poll([]);
       // ONE: both bumpers together arm the air strike, and walk no belt
       poll([4,5]);
       if(!A.aim) bad.push('ONE: both bumpers together did not arm the air strike');
       poll([4,5]); poll([]);
       if(steps!==0) bad.push('ONE: the chord walked the belt '+steps+' times');
       // TWO: the same chord again cancels the aim
       poll([4,5]); poll([]);
       if(A.aim) bad.push('TWO: the chord again did not cancel the aim');
       // THREE: one bumper alone still walks the belt, once, on the let go
       steps=0; poll([5]); poll([]);
       if(hotbarSlots().length>0&&steps!==1) bad.push('THREE: a tap of one bumper walked the belt '+steps+' times, not 1');
       if(A.aim) bad.push('THREE: a single bumper armed the air strike');
       // FOUR: the ready line names the chord on a pad, the key without one
       hint=airHint();
       if(!/LB/.test(String(hint))||!/RB/.test(String(hint))) bad.push('FOUR: on a pad the ready line says '+hint);
       delete navigator.getGamepads; PAD.on=false;
       if(hadOwn) navigator.getGamepads=kNG;
       hint=airHint();
       if(hint!=='PRESS G') bad.push('FOUR: with no pad the ready line says '+hint);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       beltStep=oBS;
       try{ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ PAD.prev=[]; PAD.airChord=0; PAD.lbAt=null; PAD.rbAt=null; PAD.lbHeld=0; PAD.rbHeld=0; PAD.on=kPAD.on; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.aimA=kPAD.aimA; if(typeof padRelease==='function') padRelease(); }catch(_p){}
       keys={}; mouse.down=false;
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
