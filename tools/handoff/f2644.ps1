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

if ($s.Contains("  {v:'26.44',what:")) { throw "check 26.44 is in the fixture already" }

SubRx @'
  {v:'26.43',what:
'@ @'
  {v:'26.44',what:'settings4, his order 2026-10-14: CONTROLS has AUTO-RELOAD WHEN EMPTY (on) and PAUSE WHEN THE WINDOW LOSES FOCUS (off): with auto-reload off the trigger on an empty magazine only clicks and R still reloads; with the pause row on a solo raid opens the pause box when the window blurs, and a party or a same machine pair never does',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows&&window.__blipCount)) return 'SKIP: this fixture cannot deploy or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no pause box here';
     if(typeof focusPause!=='function') return 'a lost window never pauses: there is no focus pause';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kR=CFG.autoRel, kB=CFG.pauseBlur, rows, hasNet=(typeof NET==='object'&&!!NET), kSame=hasNet?NET.same:undefined, dry0, i;
     function secOf(id){ var e=document.getElementById(id), s=e&&e.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function rowOf(z){ for(var y=0;y<rows.length;y++) if(rows[y].k===z) return rows[y]; return null; }
     function steps(n){ for(var s=0;s<n;s++) __sim(0.05); }
     function dryN(){ return (__blipCount()['dry']||0); }
     function gun(){ p.wep=Object.assign({},WEAPONS.rifle); p.drawRef=p.wep; p.ammo=0; p.reserve=60; p.reloading=0; p.drawT=0; p.hand=null; p.jam=0; p.fired=false; p.dryTold=0; p.lastShot=-1e9; p.trigYield=0; p.cooking=false; g.hot=0; keys={}; mouse.down=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; g.wheel=null;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       // ONE: the rows, in CONTROLS, defaulting to today, stepping and saving
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       [['autoReload','autoRel',1,0],['pauseBlur','pauseBlur',0,1]].forEach(function(w){
         var rr=rowOf(w[0]);
         if(!rr){ bad.push('ONE: Settings has no '+w[0]+' row'); return; }
         if(CFG[w[1]]!==w[2]) bad.push('ONE: a fresh profile has '+w[1]+' '+CFG[w[1]]+', not '+w[2]);
         if(gameOptLive(w[0])!==rr.def) bad.push('ONE: the '+w[0]+' row reads CUSTOM on a fresh profile');
         if(secOf('go_'+w[0])!=='CONTROLS') bad.push('ONE: the '+w[0]+' row sits under '+secOf('go_'+w[0])+', not CONTROLS');
         __opts.cycle(w[0]); if(CFG[w[1]]!==w[3]) bad.push('ONE: one click on '+w[0]+' left '+w[1]+' at '+CFG[w[1]]);
         if(typeof P.gameOpts[w[0]]!=='number') bad.push('ONE: the '+w[0]+' pick was not saved');
       });
       P.gameOpts={}; __opts.apply();
       md.classList.remove('on');   // an open window owns the trigger
       // TWO: auto-reload. On is today (the trigger on an empty gun reloads); off clicks, and R still reloads
       CFG.autoRel=1; gun(); mouse.down=true; dry0=dryN(); steps(3);
       if(!(p.reloading>0)) bad.push('TWO: control: the trigger on an empty magazine did not reload it');
       gun(); mouse.down=true; steps(2); mouse.down=false; p.reloading=0; p.fired=false; p.dryTold=0; mouse.down=true; steps(2);
       CFG.autoRel=0; gun(); mouse.down=true; dry0=dryN(); steps(4);
       if(p.reloading>0) bad.push('TWO: with AUTO-RELOAD off the trigger on an empty magazine still reloaded it');
       if(dryN()<=dry0) bad.push('TWO: with AUTO-RELOAD off the empty gun made no dry click');
       mouse.down=false; steps(1); keys['KeyR']=true; steps(2); keys['KeyR']=false;
       if(!(p.reloading>0)) bad.push('TWO: with AUTO-RELOAD off the reload key did not reload');
       gun(); mouse.down=true; p.fired=false; CFG.autoRel=0; steps(2); if(p.reloading>0) bad.push('TWO: with AUTO-RELOAD off a held trigger reloaded');
       mouse.down=false; keys={}; CFG.autoRel=1; gun();
       // THREE: the focus pause
       CFG.pauseBlur=0; pauseOpen=false; window.dispatchEvent(new Event('blur'));
       if(pauseOpen) bad.push('THREE: control: a lost window paused with the row off');
       CFG.pauseBlur=1; pauseOpen=false; window.dispatchEvent(new Event('blur'));
       if(!pauseOpen) bad.push('THREE: a lost window did not open the pause box with the row on');
       if(pauseOpen&&!g.paused) bad.push('THREE: the pause box is up but the raid is not paused');
       togglePauseBox(false); if(pauseOpen) bad.push('THREE: staging: the box would not close');
       if(hasNet){
         NET.same='host'; if(focusPause()||pauseOpen) bad.push('THREE: a same machine pair paused when the window lost focus'); NET.same=kSame;
         if(pauseOpen) togglePauseBox(false);
       }
       g.over=true; pauseOpen=false; if(focusPause()||pauseOpen) bad.push('THREE: an ended raid paused'); g.over=false;
       if(pauseOpen) togglePauseBox(false);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys={}; mouse.down=false; CFG.autoRel=kR; CFG.pauseBlur=kB; if(hasNet) NET.same=kSame; if(pauseOpen) togglePauseBox(false); var g1=__state(); if(g1) g1.over=false; }catch(_c){}
       try{ P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
