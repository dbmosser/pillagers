$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.63',what:
'@ @'
  {v:'15.64',what:'C crouches with Shift held when no sprint can start: crouched with Shift and W held, one frame out of breath with the release latch set, one frame aiming and one frame wading in deep water each leave him crouched and not sprinting, while the same frame with full breath on dry ground and not aiming still stands him up into a sprint (stealth audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof updatePlayer!=='function'||typeof inWaterDeep!=='function') return 'SKIP: no player update or deep water test in this build';
     if(typeof keys==='undefined'||!keys||typeof mouse==='undefined'||!mouse||typeof CFG==='undefined') return 'SKIP: no keys, mouse or dials in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, g=null, p=null, keep=null, mouseWas=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // One frame crouched with Shift and W held, from the spot given, with the breath and the aim given.
     function frame(x,y,stam,lock,ads){
       clearKeys(); mouse.down=false;
       p.x=x; p.y=y; p.vx=0; p.vy=0; p.roll=0; p.downed=false; p.autoJog=false;
       p.stam=stam; p.stamLock=lock; p.stamRelease=lock; p.ads=!!ads;
       g.crouchTog=true; g.sprinting=false; g.pCrouch=false;
       keys['ShiftLeft']=true; keys['KeyW']=true;
       updatePlayer(1/60);
       clearKeys();
       return {tog:!!g.crouchTog, low:!!g.pCrouch, run:!!g.sprinting};
     }
     function says(r){ return '(crouch toggle '+r.tog+', crouched '+r.low+', sprinting '+r.run+')'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player||!g.map||g.over) return 'SKIP: no live raid';
       p=g.player;
       keep={x:p.x,y:p.y,stam:p.stam,lock:p.stamLock,rel:p.stamRelease,ads:p.ads};
       mouseWas={x:mouse.x,y:mouse.y,down:mouse.down};
       var sx=p.x, sy=p.y, inset=(CFG.wadeInset===undefined?11:CFG.wadeInset);
       if(inWaterDeep(sx,sy,inset)) return 'SKIP: he starts in deep water here, so the dry frames cannot run';
       // CONTROL: full breath, dry ground, not aiming: Shift and W stand him up into a sprint on either build (his v11.53 note).
       var c0=frame(sx,sy,100,0,false);
       if(c0.tog||c0.low||!c0.run) return 'SKIP: with full breath, crouched, Shift and W did not stand him up into a sprint here '+says(c0);
       // THE FINDING: out of breath with Shift still held, the release latch refuses the sprint, so C must keep him crouched.
       var a1=frame(sx,sy,0,1,false);
       if(a1.run) return skip('out of breath with the release latch set he still sprinted here, so the breath did not take');
       if(!a1.tog||!a1.low) bad.push('out of breath with Shift and W still held, crouched, one frame stood him up with no sprint '+says(a1)+', so C does nothing when he presses it to break a chase');
       // Aiming refuses the sprint too, so the crouch stays.
       var a2=frame(sx,sy,100,0,true);
       if(a2.run) return skip('aiming with Shift and W held he sprinted here, so the aim did not take');
       if(!a2.tog||!a2.low) bad.push('aiming with Shift and W held, crouched, one frame stood him up with no sprint '+says(a2));
       // Deep water refuses the sprint too: the middle of the first pool deep enough to wade, if this map has one.
       var ws=g.map.water||[], wq=null, i, q;
       for(i=0;i<ws.length;i++){ q=ws[i]; if(q&&q.w>inset*2+40&&q.h>inset*2+40&&inWaterDeep(q.x+q.w/2,q.y+q.h/2,inset)){ wq=q; break; } }
       if(wq){
         var a3=frame(wq.x+wq.w/2,wq.y+wq.h/2,100,0,false);
         if(a3.run) bad.push('wading in deep water with Shift and W held he sprinted');
         else if(!a3.tog||!a3.low) bad.push('wading in deep water with Shift and W held, crouched, one frame stood him up with no sprint '+says(a3));
       }
       // CONTROL: the full breath frame again, so nothing above switched off his rule that a sprint that starts stands him up.
       var c1=frame(sx,sy,100,0,false);
       if(c1.tog||c1.low||!c1.run) bad.push('control: with full breath on dry ground, crouched, Shift and W no longer stood him up into a sprint '+says(c1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); if(mouseWas){ mouse.x=mouseWas.x; mouse.y=mouseWas.y; mouse.down=mouseWas.down; } }catch(_k){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.vx=0; p.vy=0; p.stam=keep.stam; p.stamLock=keep.lock; p.stamRelease=keep.rel; p.ads=keep.ads; } }catch(_p){}
       try{ if(g){ g.crouchTog=false; g.sprinting=false; g.pCrouch=false; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
