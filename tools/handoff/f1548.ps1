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
  {v:'15.47',what:
'@ @'
  {v:'15.48',what:'while the site burns or a death plays out, the pause box offers no abandon and no extract: paused with P in the first frame of the burn after the clock ran out it hides Abandon run and pressing it arms nothing, and paused down in the burn or over the death beat it neither reads BLEEDING OUT nor shows the downed line, even after pressing Abandon run, while on his feet it still offers and arms Abandon run and downed it still reads BLEEDING OUT with the downed line (pause audit finding 8)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy and step a live frame';
     if(typeof togglePauseBox!=='function'||typeof raidKey!=='function'||typeof disarmAbandon!=='function') return 'SKIP: no pause box, raid keys or abandon disarm in this build';
     if(typeof tickNuke!=='function'||typeof killPlayer!=='function'||typeof raidClockOn!=='function'||typeof lastTs!=='number'||typeof keys==='undefined') return 'SKIP: no burn, death, raid clock, frame clock or keys in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon'), bl=document.getElementById('pausebleed'), pb=document.getElementById('pausebox'), h3=document.querySelector('#pausebox h3');
     if(!ab||!cb||!bl||!pb||!h3||typeof ab.onclick!=='function') return 'SKIP: this build has no abandon button, confirm, downed line or title in the pause box';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, keepTs=lastTs;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Assembled, never written whole: the title the box must not read over the burn or a death.
     var BLEED='BLEED'+'ING OUT';
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; }catch(_k){} }
     // P opens the box the way he does; its title, Abandon run and the downed line are read; Abandon run is pressed once and
     // what that did is read; then the button is put back to sleep and P closes the box.
     function look(){
       clearKeys();
       raidKey('KeyP',false,null);
       var o={open:pb.classList.contains('on'), title:String(h3.textContent||''), offered:ab.style.display!=='none', line:bl.style.display!=='none'};
       ab.onclick.call(ab);
       o.armed=cb.style.display!=='none'; o.lineAfter=bl.style.display!=='none';
       disarmAbandon();
       clearKeys();
       if(pb.classList.contains('on')) raidKey('KeyP',false,null);
       clearKeys();
       o.closed=!pb.classList.contains('on');
       return o;
     }
     function tell(o){ return '['+o.title+'], Abandon run '+(o.offered?'offered':'hidden')+', the downed line '+(o.line?'shown':'hidden')+', the press '+(o.armed?'armed':'did not arm')+' the confirm'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.ents) return 'SKIP: no live raid';
       p=g.player;
       keep={hp:p.hp,iv:p.iv,downT:p.downT,dying:p.dying,pendKiller:p.pendKiller,timeLeft:g.timeLeft,beat:g.deathBeat,
             killer:g.tel?g.tel.deathKiller:undefined,dwm:g.tel?g.tel.diedWithMed:undefined};
       keepEnts=g.ents.slice();
       g.ents.length=0; p.iv=99;
       // CONTROL: this raid runs a clock, no call is made, and it is a fresh raid on his feet that is not already ending.
       if(!raidClockOn()) return 'SKIP: the raid clock is off here, so the site never burns';
       if(g.beaconT!==null||g.nuking||g.over||p.downed||!(p.hp>0)||(g.deathBeat!==undefined&&g.deathBeat!==null)) return 'SKIP: the raid was not a fresh one on his feet with no call made here';
       // CONTROL: on his feet the box reads RAID PAUSED, offers Abandon run with no downed line, and the press arms the confirm.
       var up=look();
       if(!up.open||!up.closed) return 'SKIP: P did not open and close the pause box here';
       if(up.title.indexOf('RAID PAUSED')<0||!up.offered||up.line||!up.armed) return 'SKIP: on his feet the pause box read '+tell(up)+', so the box cannot be read here';
       // CONTROL: really downed, it reads BLEEDING OUT with the downed line and no Abandon run, and the press arms nothing.
       p.downed=true; p.downT=0; p.hp=0;
       var dn=look();
       p.downed=false; p.downT=keep.downT; p.hp=keep.hp;
       if(!dn.open||!dn.closed) return 'SKIP: P did not open and close the pause box while downed here';
       if(dn.title.indexOf(BLEED)<0||dn.offered||!dn.line||dn.armed) return 'SKIP: downed the pause box read '+tell(dn)+', so the downed box cannot be read here';
       // The clock runs out with no call made: one live frame through the loop with 0.01 seconds left starts the burn.
       clearKeys(); g.timeLeft=0.01;
       __loop(lastTs+16);
       // CONTROL: that frame started the burn on the loop branch of its own, and he is not down yet.
       if(!g.nuking||g.over) return 'SKIP: a live frame with 0.01 seconds on the clock did not start the burn here (nuking '+g.nuking+', over '+g.over+')';
       if(p.downed||!(p.hp>0)) return 'SKIP: he was already down in the first frame of the burn here';
       var b1=look();
       if(!b1.open) return 'SKIP: P did not open the pause box in the first frame of the burn here';
       // THE FIX, ONE: in the first frame of the burn, where the raid can only end in death, there is no Abandon run to take.
       if(b1.offered) bad.push('paused with P in the first frame of the burn after the clock ran out, the pause box still offered Abandon run');
       if(b1.armed) bad.push('pressing Abandon run in the first frame of the burn armed YES, ABANDON THIS RUN, so a certain timer death could be turned into an abandon that keeps the armoury guns and counts no death');
       if(b1.line||b1.lineAfter) bad.push('paused in the first frame of the burn the pause box showed the downed line that says he can extract');
       // Later in the burn he goes down: the burn step of the game itself, carried past 1.15 seconds.
       tickNuke(1.2);
       // CONTROL: down in the burn, the burn still running and the raid not over.
       if(!p.downed||!g.nuking||g.over) return skip('the burn did not put him down before it ended here');
       var b2=look();
       if(!b2.open) return skip('P did not open the pause box down in the burn here');
       // THE FIX, TWO: down in the burn nothing can be extracted, so the box does not say he is bleeding out or that he can extract.
       if(b2.title.indexOf(BLEED)>=0||b2.line||b2.lineAfter) bad.push('paused down in the burn, where nothing can be extracted, the pause box read '+tell(b2)+(b2.lineAfter&&!b2.line?' and the press brought up the downed line':''));
       if(b2.offered||b2.armed) bad.push('paused down in the burn the pause box read '+tell(b2));
       // Out of the burn, back on his feet, before the death beat.
       g.nuking=0; g.nukeT=0; g.nukeAcc=0; g.timeLeft=keep.timeLeft;
       p.downed=false; p.downT=keep.downT; p.hp=keep.hp; p.pendKiller=keep.pendKiller;
       if(g.tel) g.tel.deathKiller=keep.killer;
       // Killed where he stands: the death beat.
       killPlayer('crawler');
       // CONTROL: hp 0, not downed, the beat running and the raid not over.
       if(!(g.deathBeat>0)||p.downed||p.hp>0||g.over) return skip('killPlayer opened no death beat here');
       var d1=look();
       if(!d1.open) return skip('P did not open the pause box over the death beat here');
       // THE FIX, THREE: over a dead man the box does not say he is bleeding out or that he can extract, even after the press.
       if(d1.title.indexOf(BLEED)>=0||d1.line) bad.push('paused over the death beat, already dead, the pause box read '+tell(d1));
       else if(d1.lineAfter) bad.push('pressing Abandon run over the death beat brought up the downed line that says he can extract, over a dead man');
       if(d1.offered||d1.armed) bad.push('paused over the death beat the pause box read '+tell(d1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ mouse.down=false; }catch(_m){}
       try{ disarmAbandon(); }catch(_b){}
       try{ if(pb.classList.contains('on')) togglePauseBox(false); }catch(_pb){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ if(g&&keep){ g.nuking=0; g.nukeT=0; g.nukeAcc=0; g.deathBeat=keep.beat; g.timeLeft=keep.timeLeft; if(g.tel){ g.tel.deathKiller=keep.killer; g.tel.diedWithMed=keep.dwm; } } }catch(_g){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.downed=false; p.downT=keep.downT; p.dying=keep.dying; p.hp=keep.hp; p.iv=keep.iv; p.pendKiller=keep.pendKiller; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
