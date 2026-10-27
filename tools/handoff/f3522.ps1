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

if ($s.Contains("  {v:'35.22',what:")) { throw "check 35.22 is in the fixture already" }

SubRx @'
  {v:'35.21',what:
'@ @'
  {v:'35.22',what:'cw-restfreeze, his note of 2026-10-27 on build 35.19 with Superhot on ("it says i\'m recovering to 85 when I\'m not"): on real frames, with Superhot on and no input, time and health stand still and the RECOVERING mark goes dark; it shows while time moves and points land, with Superhot on (a key held) and off',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)||typeof lastTs!=='number') return 'SKIP: this fixture cannot step a live raid frame';
     if(typeof statusLive!=='function'||typeof STATUSL==='undefined'||typeof tickRegen!=='function'||typeof CFG!=='object'||typeof CFG.superhot==='undefined') return 'SKIP: no status column or no Superhot in this build';
     var bad=[], g=null, p=null, E0=null, rest=null, kTs=lastTs, kSH=CFG.superhot, kCap=CFG.fpsCap, kNAA=netAnyActing, kNow=(typeof statusNow==='function')?statusNow:null, clk=0, i, h1, h2, tF, hF, onB=0, top;
     function keysOff(){ var K=__keysRef(), q; for(q in K) K[q]=false; if(typeof mouse!=='undefined'&&mouse) mouse.down=false; }
     // one raid frame on the real loop and a real clock moved by step seconds; hold is a key nothing else reads, so Superhot lets time run
     function frame(hold,step){ keysOff(); if(hold) __keysRef().KeyK=true; clk+=step; p.iv=99; p.combatT=Math.max(p.combatT||0,CFG.regenDelay+1); g.waveT=-1e9; try{ __loop(lastTs+1000/60); } finally{ keysOff(); } statusLive(p); }
     function untilPoint(hold,from,max){ var n=0; while(n<max&&!(p.hp>from)){ frame(hold,1/60); n++; } return p.hp>from; }
     try{
       for(i=0;i<STATUSL.length;i++) if(STATUSL[i].id==='rest') rest=STATUSL[i];
       if(!rest) return 'staging: no RECOVERING entry in the status list';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents) return 'SKIP: no live raid';
       g.paused=false; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; p.downed=false; p.dying=false; p.roll=0; p.reloading=0; p.prep=null; p.prepA=null; p.stimT=0; p.healQ=0;
       E0=g.ents; g.ents=[];
       clk=(kNow?kNow():0); if(kNow) statusNow=function(){ return clk; };
       netAnyActing=function(){ return false; };
       top=healCeil(ITEMS.bandage);
       CFG.superhot=1; CFG.fpsCap=0;
       p.hp=60; p.regenAcc=CFG.regenSec-0.1; p.crAcc=0;
       // ONE (control): Superhot on and a key held, so time runs: a point lands and the mark shows
       if(!untilPoint(true,60,40)) return 'staging: with a key held under Superhot no regen point landed from 60 in 40 frames (hp '+(+p.hp).toFixed(2)+', combat '+(+p.combatT).toFixed(1)+')';
       h1=p.hp;
       if(!rest.on) bad.push('control: Superhot on, a key held, health just climbed to '+h1+' of '+top+': RECOVERING is not showing');
       // TWO (his note): no input for 6 s of real time, Superhot holds the raid clock and his health still
       tF=g.t; hF=p.hp;
       for(i=0;i<24;i++){ frame(false,0.25); if(i>=4&&rest.on) onB++; }
       if(Math.abs(g.t-tF)>1e-9) bad.push('staging: with no input under Superhot the raid clock still moved '+(g.t-tF).toFixed(3)+' s');
       if(Math.abs(p.hp-hF)>1e-9) bad.push('staging: with time held still his health still moved from '+hF+' to '+p.hp);
       if(onB) bad.push('with Superhot holding time still and his health standing at '+Math.round(p.hp)+' for 6 s of real time, the left column still says recovering to '+top+' ('+onB+' of the last 20 frames)');
       // THREE (control): he acts again, time runs, the next point lands and the mark is back
       h2=p.hp;
       if(!untilPoint(true,h2,240)) bad.push('staging: time moving again landed no regen point in 4 s (hp '+(+p.hp).toFixed(2)+')');
       else if(!rest.on) bad.push('control: time moving again and health climbing to '+p.hp+': RECOVERING is not showing');
       // FOUR (control): Superhot off, no input, time runs on its own: points land and the mark shows
       CFG.superhot=0; h2=p.hp;
       if(!untilPoint(false,h2,240)) bad.push('staging: Superhot off, no regen point in 4 s (hp '+(+p.hp).toFixed(2)+')');
       else if(!rest.on) bad.push('control: Superhot off, health climbing to '+p.hp+': RECOVERING is not showing');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(kNow) statusNow=kNow; }catch(_n){}
       try{ netAnyActing=kNAA; }catch(_a){}
       try{ CFG.superhot=kSH; CFG.fpsCap=kCap; }catch(_c){}
       try{ keysOff(); }catch(_k){}
       try{ lastTs=kTs; }catch(_t){}
       try{ var gb=__state(); if(gb){ if(E0) gb.ents=E0; if(!gb.over){ gb.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
