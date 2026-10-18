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

if ($s.Contains("  {v:'30.99',what:")) { throw "check 30.99 is in the fixture already" }

SubRx @'
  {v:'30.98',what:
'@ @'
  {v:'30.99',what:'cw-pausesets, his note on Settings from the pause menu (2026-10-18): Settings opened from the pause box starts at the top every visit, the raid stands still under it with Superhot on and a key held, a row click, CLOSE and ESC leave the box and the pause as they should, the player 2 window does the same, and the window air is its own margin and not a share of the screen height',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(typeof togglePauseBox!=='function'||typeof openSettings!=='function'||typeof cycleGameOpt!=='function'||typeof applyGameOpts!=='function') return 'SKIP: no pause box, Settings window or Settings rows in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no keys, mouse or keyboard events in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(typeof __vpAlive==='function'&&!__vpAlive()) return 'SKIP: the page has no laid out viewport, so Settings cannot be measured';
     function el(id){ return document.getElementById(id); }
     var pb=el('pausebox'), sm=el('settingsmodal'), sb=el('pausesetbtn'), sl=el('setlist'), cl=el('closesettings');
     if(!pb||!sm||!sb||!sl||!cl) return 'SKIP: this build has no pause box, Settings window, Settings button or list';
     var bad=[], g=null, k0=keys, md0=mouse.down, i, w, r, sent=[], max, deep, kw0, sizeW=W, sizeH=H, mz0=P.menuZoom, hadGo=!!P.gameOpts, go0=P.gameOpts?JSON.parse(JSON.stringify(P.gameOpts)):null, sized=false;
     var hasNet=(typeof NET==='object'&&NET&&typeof netSamePost==='function');
     var keepNet=hasNet?{same:NET.same,pair:NET.pair}:null, oPost=hasNet?netSamePost:null;
     function on(e){ return !!(e&&e.classList.contains('on')); }
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     // P goes to the window and ESC to the body, the way a real key arrives, so the pause box listener runs first for ESC.
     function press(code,dest){ clearKeys(); (dest||window).dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); (dest||window).dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); clearKeys(); }
     function esc(){ press('Escape',document.body); }
     function shut(){ clearKeys(); sm.classList.remove('on'); if(on(pb)) togglePauseBox(false); clearKeys(); }
     // The raid clock and the player over n loop frames; synthetic stamps, because a hidden pane never fires its own frames.
     function adv(n){
       var t0=g.t, tl0=g.timeLeft, x0=g.player.x, y0=g.player.y, base=Math.max(+__gx('lastTs')||0,performance.now())+50, j;
       for(j=1;j<=n;j++) __loop(base+j*16.7);
       return {t:g.t-t0, tl:tl0-g.timeLeft, mv:Math.hypot(g.player.x-x0,g.player.y-y0)};
     }
     function still(a){ return Math.abs(a.t)<1e-9&&Math.abs(a.tl)<1e-9&&a.mv<1e-6; }
     function setSuper(v){ P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=v; applyGameOpts(); }
     function openPause(){ shut(); press('KeyP'); return on(pb)&&g.paused; }
     function openSet(){ sb.click(); return on(sm)&&on(pb); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here';
       g.mapOpen=false; g.bagOpen=false; g.emoteBar=false; g.trade=null; g.drag=null;
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       // CONTROL: with the box shut and a key held, the loop moves the raid clock and the player, with Superhot off and on, so "still" below means something.
       for(i=0;i<2;i++){
         setSuper(i); shut(); clearKeys(); keys.KeyD=true;
         r=adv(8); clearKeys();
         if(!(r.t>0.05)) return 'SKIP: the loop does not move the raid clock here with Superhot '+(i?'ON':'OFF')+' and a key held ('+r.t.toFixed(4)+'), so a frozen clock cannot be read';
       }
       setSuper(0);
       // THE REPORT: Settings from the pause box, in the order he does it: P, the Settings button, a row, scroll, CLOSE, Settings again.
       if(!openPause()) return 'SKIP: P did not open the pause box in the raid';
       if(!openSet()) bad.push('the Settings button on the pause box did not put Settings over the open box');
       if(sl.scrollTop!==0) bad.push('a first visit to Settings opened scrolled to '+sl.scrollTop);
       max=sl.scrollHeight-sl.clientHeight;
       if(!(max>300)) bad.push('the Settings list is only '+Math.round(max)+' px longer than its window, so it cannot be scrolled here');
       // THE WORLD STANDS STILL under Settings with Superhot ON, a key and the mouse held (Superhot lets time run for a held key, a pause must not).
       setSuper(1);
       if(!openPause()||!openSet()) bad.push('the pause box and Settings did not open with Superhot ON');
       keys.KeyD=true; mouse.down=true; r=adv(8); clearKeys();
       if(!still(r)) bad.push('with Superhot ON and a key held, the raid moved on under Settings (clock '+r.t.toFixed(3)+' s, player '+r.mv.toFixed(1)+' px)');
       if(!g.paused) bad.push('the raid was not paused under the pause box and Settings with Superhot ON');
       // A ROW: the Superhot row is clicked in the open window; Settings and the box stay up and the raid stays still.
       w=el('go_superhot');
       if(!w) bad.push('the Settings list has no Superhot row');
       else{
         i=CFG.superhot; w.click();
         if(CFG.superhot===i) bad.push('the Superhot row did not change the dial');
         if(!on(sm)||!on(pb)) bad.push('a click on a Settings row shut Settings or the pause box behind it');
         if(!g.paused) bad.push('a click on a Settings row unpaused the raid');
         keys.KeyD=true; r=adv(8); clearKeys();
         if(!still(r)) bad.push('after a Settings row click the raid moved on under Settings (clock '+r.t.toFixed(3)+' s)');
       }
       // SCROLL, CLOSE, OPEN AGAIN: a window opened again starts at the top, the way it does on a first visit.
       setSuper(0);
       if(!openPause()||!openSet()) bad.push('the pause box and Settings did not open for the scroll part');
       else{
         deep=Math.min(600,Math.max(0,sl.scrollHeight-sl.clientHeight)); sl.scrollTop=deep;
         if(Math.abs(sl.scrollTop-deep)>2) bad.push('the Settings list would not scroll to '+deep);
         cl.click();
         if(on(sm)) bad.push('CLOSE did not shut Settings');
         if(!on(pb)||!g.paused) bad.push('CLOSE on Settings shut the pause box behind it or unpaused the raid');
         if(!openSet()) bad.push('Settings did not open a second time from the pause box');
         else if(sl.scrollTop>2) bad.push('Settings opened a second time from the pause box scrolled to '+sl.scrollTop+', where it was left, instead of at the top');
         // A tab or a jump inside the open window keeps its place: only a fresh open resets.
         if(on(sm)&&max>300){
           sl.scrollTop=300; openSettings('display');
           if(Math.abs(sl.scrollTop-300)>2) bad.push('openSettings on the open window moved the list from 300 to '+sl.scrollTop);
         }
       }
       // ESC SHUTS SETTINGS FIRST, then the box, and then the raid runs on.
       if(on(sm)){
         esc();
         if(on(sm)) bad.push('ESC on Settings over the pause box left Settings up');
         if(!on(pb)||!g.paused) bad.push('ESC on Settings shut the pause box too, so the raid ran on under Settings');
         esc();
         if(on(pb)||g.paused) bad.push('a second ESC did not shut the pause box and resume the raid');
         setSuper(1); keys.KeyD=true; r=adv(8); clearKeys();
         if(!(r.t>0.05)) bad.push('after resuming from Settings the raid did not run on with Superhot ON and a key held ('+r.t.toFixed(3)+' s)');
       }
       // THE PLAYER 2 WINDOW opens and shuts Settings from its own pause box the same way, and the ESC is not handed to player 1.
       if(hasNet){
         setSuper(0);
         if(!openPause()||!openSet()) bad.push('the pause box and Settings did not open in the player 2 window');
         else{
           netSamePost=function(m){ sent.push(m); return true; };
           NET.same='p2'; NET.pair='zqxpausesets'; sent.length=0;
           sl.scrollTop=Math.min(600,Math.max(0,sl.scrollHeight-sl.clientHeight));
           cl.click();
           if(!openSet()) bad.push('Settings did not open a second time in the player 2 window');
           else if(sl.scrollTop>2) bad.push('in the player 2 window Settings opened a second time scrolled to '+sl.scrollTop+' instead of the top');
           esc();
           if(on(sm)) bad.push('in the player 2 window ESC on Settings left Settings up');
           if(!on(pb)) bad.push('in the player 2 window ESC on Settings shut the pause box too');
           kw0=sent.filter(function(m){ return m&&m.t==='key'&&m.code==='Escape'; }).length;
           if(kw0) bad.push('in the player 2 window the ESC that shut Settings was also handed to player 1 ('+kw0+' key words)');
           NET.same=keepNet.same; NET.pair=keepNet.pair; netSamePost=oPost;
         }
       }
       // THE WINDOW FITS: at 1080p and at the menu zoom he runs, the list and CLOSE sit inside the screen and the list is not squeezed to a sliver.
       // (This was the collapse seen at 4K: the padding came from an unzoomed 100vh inside a zoomed window. Its rule is dead since v30.89 and is gone here.)
       shut(); setSuper(0);
       if(openPause()&&openSet()){
         sized=true;
         for(i=0;i<2;i++){
           P.menuZoom=i?1.1:1.3; __forceSize(1920,1080); applyMenuZoom();
           r=sl.getBoundingClientRect(); w=cl.getBoundingClientRect();
           if(r.top<-1||r.bottom>innerHeight+1) bad.push('at 1080p and menu zoom '+P.menuZoom+' the Settings list runs off the screen ('+Math.round(r.top)+' to '+Math.round(r.bottom)+' of '+innerHeight+')');
           if(r.height<innerHeight*0.3) bad.push('at 1080p and menu zoom '+P.menuZoom+' the Settings list is only '+Math.round(r.height)+' px tall in a '+innerHeight+' px window');
           if(w.bottom>innerHeight+1||w.top<-1) bad.push('at 1080p and menu zoom '+P.menuZoom+' CLOSE sits off the screen');
         }
         // The air above and below the card is the window own margin and not a share of the screen height: a share of 100vh is not divided by the
         // zoom of a zoomed window, so on a screen taller than 1080p it grew until the list was squeezed to nothing.
         w=parseFloat(getComputedStyle(sm).paddingTop); r=parseFloat(getComputedStyle(sm).getPropertyValue('--sp-5'));
         if(r>0&&w>r+1) bad.push('the Settings window keeps '+Math.round(w)+' px of air above its card, more than its own margin of '+Math.round(r)+' px, so a tall screen squeezes the list');
       }
       // THE DEAD RULE: no rule on the Settings or Keys window sets its padding from a bare 100vh, which a zoomed window does not divide.
       (function walk(rules){
         var q, rl;
         for(q=0;q<rules.length;q++){
           rl=rules[q];
           if(rl.cssRules&&!rl.selectorText){ try{ walk(rl.cssRules); }catch(_w){} continue; }
           if(rl.selectorText&&/settingsmodal|keysmodal/.test(rl.selectorText)&&rl.style&&/100vh/.test(rl.style.getPropertyValue('--py')||'')) bad.push('a rule still sets the padding of Settings from 100vh ('+rl.selectorText.slice(0,60)+')');
         }
       })((function(){ var out=[], s, j; for(j=0;j<document.styleSheets.length;j++){ s=document.styleSheets[j]; try{ [].forEach.call(s.cssRules,function(x){ out.push(x); }); }catch(_s){} } return out; })());
       return bad.length?bad.join('; '):null;
     } finally {
       if(hasNet){ NET.same=keepNet.same; NET.pair=keepNet.pair; netSamePost=oPost; }
       clearKeys(); mouse.down=md0;
       try{ shut(); }catch(_e1){}
       P.menuZoom=mz0; if(sized){ try{ __forceSize(sizeW||1920,sizeH||1080); }catch(_e2){} } try{ applyMenuZoom(); }catch(_e3){}
       if(hadGo) P.gameOpts=go0; else delete P.gameOpts;
       try{ applyGameOpts(); saveProfile(); }catch(_e4){}
       try{ __endRaid('abandon'); }catch(_e5){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'30.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
