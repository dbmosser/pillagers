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
  {v:'15.64',what:
'@ @'
  {v:'15.65',what:'Ctrl with the mouse wheel sizes the HUD without toggling crouch: in a raid at seed 4242, standing, Ctrl held with the wheel rolled a notch up and a notch down sizes the HUD a step up and back and leaves him standing once Ctrl is let go, and crouched to hide the same gesture leaves him crouched, while a plain Ctrl press and release still crouches him, and after a controller right stick click a Ctrl wheel with no Ctrl key held, the way a trackpad pinch arrives, sizes the HUD and keeps that crouch (stealth audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof raidKey!=='function'||typeof hudSizeStep!=='function'||typeof updatePlayer!=='function'||typeof uiScale!=='function'||typeof applyMenuZoom!=='function') return 'SKIP: no raid keys, HUD size step or player update in this build';
     if(typeof UISCALES==='undefined'||!UISCALES||UISCALES.length<3) return 'SKIP: this build has no HUD size steps';
     if(typeof keys==='undefined'||!keys||typeof mouse==='undefined'||!mouse||typeof cv==='undefined'||!cv) return 'SKIP: no keys, mouse or game canvas in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, g=null, p=null, keep=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // Ctrl pressed or let go, dispatched at window only, where the raid key listener hears it once.
     function key(type,code){ window.dispatchEvent(new KeyboardEvent(type,{code:code,key:'Control',ctrlKey:(type==='keydown'),bubbles:true,cancelable:true})); }
     // One wheel notch on the game canvas with ctrlKey set, which is how the browser sends Ctrl with the wheel and a trackpad pinch.
     function wheel(dy){ cv.dispatchEvent(new WheelEvent('wheel',{deltaY:dy,deltaMode:0,bubbles:true,cancelable:true,ctrlKey:true})); }
     function hudIx(){ var u=uiScale(); for(var i=0;i<UISCALES.length;i++) if(Math.abs(UISCALES[i]-u)<0.001) return i; return -1; }
     // One frame standing still with every key up, so G.pCrouch shows the stance the toggle gives him.
     function frame(){
       clearKeys(); mouse.down=false;
       p.x=keep.x; p.y=keep.y; p.vx=0; p.vy=0; p.roll=0; p.downed=false; p.autoJog=false;
       updatePlayer(1/60);
       return {tog:!!g.crouchTog, low:!!g.pCrouch};
     }
     function says(r){ return '(crouch toggle '+r.tog+', crouched '+r.low+')'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state!=='undefined'&&state!=='raid') return 'SKIP: the page is not in a raid here';
       if(typeof pauseOpen!=='undefined'&&pauseOpen) return 'SKIP: the pause box is up over the raid here';
       p=g.player;
       keep={x:p.x,y:p.y,mx:mouse.x,my:mouse.y,md:mouse.down};
       g.emoteBar=false;
       // The middle HUD size, so a step either way is possible.
       var mid=Math.floor(UISCALES.length/2);
       __P().uiScale=UISCALES[mid];
       if(hudIx()!==mid) return 'SKIP: the HUD size did not take the middle step here';
       // CONTROL: a plain Ctrl press crouches him through the real key listener, on either build (v9.92, v10.07).
       g.crouchTog=false; frame();
       key('keydown','ControlLeft');
       if(!g.crouchTog) return 'SKIP: a Ctrl press dispatched at window did not reach the crouch toggle here';
       key('keyup','ControlLeft');
       var c0=frame();
       if(!c0.tog||!c0.low) bad.push('control: a plain Ctrl press and release no longer leaves him crouched '+says(c0));
       // THE FINDING, standing: Ctrl held, the wheel a notch up and a notch down, Ctrl let go.
       g.crouchTog=false; frame();
       var i0=hudIx();
       key('keydown','ControlLeft');
       if(!g.crouchTog) return skip('the Ctrl press that starts the HUD gesture did not reach the crouch toggle here');
       wheel(-100);
       var i1=hudIx();
       if(i1!==i0+1) return skip('Ctrl with the wheel rolled up moved the HUD from step '+i0+' to '+i1+' rather than one step up here');
       wheel(100);
       if(hudIx()!==i0) return skip('Ctrl with the wheel rolled back down did not put the HUD back on step '+i0+' here');
       key('keyup','ControlLeft');
       var a1=frame();
       if(a1.tog||a1.low) bad.push('standing, Ctrl held and the wheel rolled a notch up and a notch down to size the HUD left him crouched once Ctrl was let go '+says(a1)+', a crouch he never asked for');
       // THE FINDING, crouched to hide: the same gesture must leave him crouched.
       g.crouchTog=true; frame();
       key('keydown','ControlLeft');
       if(g.crouchTog) return skip('crouched, the Ctrl press did not stand him up in the crouch toggle here');
       wheel(100);
       if(hudIx()!==i0-1) return skip('crouched, Ctrl with the wheel rolled down did not size the HUD one step down here');
       wheel(-100);
       key('keyup','ControlLeft');
       var a2=frame();
       if(!a2.tog||!a2.low) bad.push('crouched to hide, Ctrl held and the wheel rolled a notch down and a notch up to size the HUD stood him up once Ctrl was let go '+says(a2)+', giving the hide away');
       // CONTROL: a controller right stick click is a crouch press with no Ctrl key held (v13.36), and a Ctrl wheel after it
       // with no Ctrl key down, the way a trackpad pinch arrives, sizes the HUD and keeps the crouch the click made.
       g.crouchTog=false; frame();
       raidKey('ControlLeft',false,null); keys['ControlLeft']=false;
       if(!g.crouchTog) bad.push('control: the controller right stick click no longer crouches him');
       else {
         var i2=hudIx();
         wheel(-100);
         if(hudIx()!==i2+1) bad.push('control: a Ctrl wheel with no Ctrl key held no longer sizes the HUD');
         wheel(100);
         var a3=frame();
         if(!a3.tog||!a3.low) bad.push('control: after a controller right stick click, a Ctrl wheel with no Ctrl key held (a trackpad pinch) stood him up '+says(a3));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); if(keep){ mouse.x=keep.mx; mouse.y=keep.my; mouse.down=keep.md; } }catch(_k){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.vx=0; p.vy=0; } }catch(_p){}
       try{ if(g){ g.crouchTog=false; g.pCrouch=false; g.ctrlUndo=null; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
       try{ applyMenuZoom(); }catch(_z){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
