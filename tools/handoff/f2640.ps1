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

if ($s.Contains("  {v:'26.40',what:")) { throw "check 26.40 is in the fixture already" }

SubRx @'
  {v:'26.39',what:
'@ @'
  {v:'26.40',what:'settings2, his order 2026-10-14: CONTROLS has AIM (right mouse), CROUCH and SPRINT rows, HOLD or TOGGLE, defaulting to today (hold, toggle, hold): a toggled aim stays on after the button is let go and the next press ends it, a held crouch stands up with the key (and a pad tap still toggles), a toggled sprint runs on after the key is let go until the next press, until you stop, and each row steps and saves',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof raidKey!=='function'||typeof cv==='undefined') return 'SKIP: no raid keys here';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kA=CFG.aimTgl, kC=CFG.crouchHold, kS=CFG.sprintTgl, rows, ev={preventDefault:function(){},stopPropagation:function(){}}, i;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function mdn(b){ cv.dispatchEvent(new MouseEvent('mousedown',{button:b,bubbles:true,cancelable:true,clientX:300,clientY:300})); }
     function mup(b){ window.dispatchEvent(new MouseEvent('mouseup',{button:b,bubbles:true,cancelable:true})); }
     function kup(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true})); }
     function steps(n){ for(var s=0;s<n;s++) __sim(0.05); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false; p.stam=100;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in CONTROLS, defaulting to today, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['aimMode','aimTgl',0],['crouchMode','crouchHold',0],['sprintMode','sprintTgl',0]].forEach(function(w){
         var rr=rowOf(w[0]);
         if(!rr){ bad.push('ONE: Settings has no '+w[0]+' row'); return; }
         if(CFG[w[1]]!==w[2]) bad.push('ONE: a fresh profile has '+w[1]+' '+CFG[w[1]]+', not '+w[2]);
         if(gameOptLive(w[0])!==rr.def) bad.push('ONE: the '+w[0]+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+w[0])!=='CONTROLS') bad.push('ONE: the '+w[0]+' row sits under '+secOf('go_'+w[0])+', not CONTROLS');
         __opts.cycle(w[0]); if(CFG[w[1]]!==1) bad.push('ONE: one click on '+w[0]+' left '+w[1]+' at '+CFG[w[1]]);
         if(typeof P.gameOpts[w[0]]!=='number') bad.push('ONE: the '+w[0]+' pick was not saved');
         __opts.cycle(w[0]); if(CFG[w[1]]!==0) bad.push('ONE: a second click on '+w[0]+' did not come back');
       });
       P.gameOpts={}; __opts.apply();
       // TWO: aim. Hold is today (down aims, up stops); toggle holds on after the button is let go
       p.ads=false; mdn(2); if(!p.ads) bad.push('TWO: control: the right button did not aim'); mup(2); if(p.ads) bad.push('TWO: control: letting go of the right button did not stop the aim');
       CFG.aimTgl=1; p.ads=false;
       mdn(2); mup(2); steps(3); if(!p.ads) bad.push('TWO: a toggled aim did not stay on after the button was let go');
       mdn(2); mup(2); if(p.ads) bad.push('TWO: the second press of a toggled aim did not end it');
       CFG.aimTgl=0; p.ads=false;
       // THREE: crouch. Toggle is today; hold stands up with the key; a pad tap (no event) still toggles
       g.crouchTog=false; raidKey('ControlLeft',false,ev); kup('ControlLeft'); if(!g.crouchTog) bad.push('THREE: control: Ctrl then letting go did not leave the crouch on');
       raidKey('ControlLeft',false,ev); kup('ControlLeft'); if(g.crouchTog) bad.push('THREE: control: a second Ctrl press did not stand up');
       CFG.crouchHold=1; g.crouchTog=false;
       raidKey('ControlLeft',false,ev); if(!g.crouchTog) bad.push('THREE: CROUCH HOLD did not crouch on the press');
       kup('ControlLeft'); if(g.crouchTog) bad.push('THREE: CROUCH HOLD did not stand up when Ctrl was let go');
       raidKey('KeyC',false,ev); if(!g.crouchTog) bad.push('THREE: CROUCH HOLD did not crouch on C');
       kup('KeyC'); if(g.crouchTog) bad.push('THREE: CROUCH HOLD did not stand up when C was let go');
       raidKey('ControlLeft',false,null); if(!g.crouchTog) bad.push('THREE: a pad tap did not crouch under CROUCH HOLD');
       raidKey('ControlLeft',false,null); if(g.crouchTog) bad.push('THREE: a second pad tap did not stand up under CROUCH HOLD');
       raidKey('KeyC',false,ev); releaseAllKeys(); if(g.crouchTog) bad.push('THREE: letting go of every key left a held crouch on');
       CFG.crouchHold=0; g.crouchTog=false;
       // FOUR: sprint. Hold is today; toggle runs on after the key is let go, ends with a press, with the stop, and with the breath
       CFG.sprintTgl=0; g.sprintOn=false; g.shWas=false; p.ads=false; p.stam=100; keys={}; keys['KeyD']=true; keys['ShiftLeft']=true; steps(3);
       if(!g.sprinting) bad.push('FOUR: control: a held Shift did not sprint');
       keys['ShiftLeft']=false; steps(3); if(g.sprinting) bad.push('FOUR: control: Shift let go still sprints on HOLD');
       CFG.sprintTgl=1; g.sprintOn=false; g.shWas=false; p.stam=100; keys={}; keys['KeyD']=true;
       keys['ShiftLeft']=true; steps(2); keys['ShiftLeft']=false; steps(3);
       if(!g.sprinting) bad.push('FOUR: a toggled sprint stopped when the key was let go');
       keys['ShiftLeft']=true; steps(2); keys['ShiftLeft']=false; steps(3);
       if(g.sprinting) bad.push('FOUR: the second press did not end a toggled sprint');
       keys['ShiftLeft']=true; steps(2); keys['ShiftLeft']=false; steps(2); keys['KeyD']=false; steps(3); keys['KeyD']=true; steps(3);
       if(g.sprinting) bad.push('FOUR: a toggled sprint carried on after stopping');
       g.sprintOn=true; g.shWas=false; p.stam=1; steps(2); p.stam=100; keys['KeyD']=true; steps(3);
       if(g.sprinting) bad.push('FOUR: a toggled sprint carried on through running out of breath');
       keys={}; CFG.sprintTgl=0;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys={}; CFG.aimTgl=kA; CFG.crouchHold=kC; CFG.sprintTgl=kS; var g1=__state(); if(g1){ g1.crouchTog=false; g1.sprintOn=false; g1.shWas=false; if(g1.player) g1.player.ads=false; } }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
