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

if ($s.Contains("  {v:'31.05',what:")) { throw "check 31.05 is in the fixture already" }

SubRx @'
  {v:'31.04',what:
'@ @'
  {v:'31.05',what:'cw-txkey, his order (2026-10-18) add a toggle key for text editing mode so that I can edit text at anytime e.g middle of a raid, and when it is on the game pauses so whatever is on screen stays there: F2 flips the one Edit the words setting from anywhere on an edge press only; in a raid it freezes the world, the raid clock and movement while the screen keeps drawing, and turning it off resumes with no key or button left held; the tag says it is on; F2 cannot be rebound; a word edited in the arcade is kept',
   run:function(){
     if(typeof DEV_LOCAL==='undefined'||!DEV_LOCAL) return 'SKIP: not a local build, the word editor is never here';
     if(!(window.__deploy&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__loop&&window.__state&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot drive a raid';
     if(typeof cycleGameOpt!=='function'||typeof gameOptLive!=='function'||typeof txRecord!=='function'||typeof txFind!=='function'||typeof txOpen!=='function') return 'SKIP: no words editor here';
     var bad=[], raided=false, te0=CFG.textEdit, go0=JSON.stringify(P.gameOpts||null), tu0=JSON.stringify(P.tuned||null), km0=JSON.stringify(P.keymap||{}), kv0=P.keymapV,
         txt0=JSON.stringify(P.txt||null), txp0=JSON.stringify(P.txp||null), dl0=DEV_LOCAL, ao0=ARCADE.on, ar0=ARCADE.realJs, ts=performance.now()+10, i, g, p, a, b, c, walk, hits, el, held;
     function press(code,rep){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,repeat:!!rep,bubbles:true,cancelable:true})); }
     function rel(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function run(n){ for(var q=0;q<n;q++){ ts+=50; __loop(ts); } }
     function snap(){ var s=0, q; for(q=0;q<g.ents.length;q++) s+=(g.ents[q].x||0)+(g.ents[q].y||0); return {t:g.t,tl:g.timeLeft,px:p.x,py:p.y,es:s}; }
     function tagUp(){ var e=document.getElementById('txtag'); return !!(e&&e.style.display!=='none'&&/edit words: on \(f2\)/.test(String(e.textContent))); }
     function heldKeys(){ return Object.keys(keys).filter(function(k){ return keys[k]; }); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.gameOpts=P.gameOpts||{}; P.gameOpts.textEdit=0; CFG.textEdit=0; keys={}; mouse.down=false;
       // ONE: from a menu (no raid up): an edge press flips the one setting, the Settings row and the profile read it, a held key does not flip it twice
       DEV_LOCAL=false; press('F2'); rel('F2'); DEV_LOCAL=dl0;
       if(CFG.textEdit===1) bad.push('ONE: F2 turned the mode on in a build that is not local');
       press('F2'); rel('F2');
       if(CFG.textEdit!==1) bad.push('ONE: F2 did not turn Edit the words on (CFG.textEdit is '+CFG.textEdit+')');
       if(keys.F2) bad.push('ONE: F2 also reached the game as a key press');
       if(gameOptLive('textEdit')!==1||(P.gameOpts&&P.gameOpts.textEdit)!==1) bad.push('ONE: the Settings row and the profile do not read On after the key');
       try{ renderSettings(); var gb=document.getElementById('go_textEdit'); if(gb&&String(gb.textContent).trim().toLowerCase()!=='on') bad.push('ONE: the Settings row button reads '+String(gb.textContent).trim()+' after the key, not On'); }catch(_rs){}
       press('F2',true); press('F2',true);
       if(CFG.textEdit!==1) bad.push('ONE: a held F2 (key repeats) flipped the mode again');
       press('F2'); rel('F2');
       if(CFG.textEdit!==0) bad.push('ONE: a second F2 did not turn it off');
       // TWO: F2 is reserved, so no action can be bound to it
       if(typeof keysBind==='function'&&keysBind('KeyR','F2')) bad.push('TWO: the Keys window let reload be bound to F2, the key that turns Edit the words on');
       // THREE: in a raid, with the mode off the raid runs (control), on it stands still while the screen keeps drawing
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); raided=true;
       g=__state(); if(!g||g.sim||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; keys={}; mouse.down=false;
       a=snap(); keys.KeyD=true; run(8); b=snap(); keys={};
       if(!(b.t>a.t+0.2)) return 'SKIP: the raid clock did not run in 8 frames with the mode off (G.t '+a.t+' to '+b.t+')';
       if(!(b.px>a.px+1)) return 'SKIP: the player did not walk with D held in 8 frames';
       walk=b.px-a.px; run(10);   // any easing out of the walk settles before the mode goes on
       press('F2'); rel('F2');
       var ht=document.getElementById('hubtoast'), tt=ht?String(ht.textContent).toLowerCase():'';
       if(CFG.textEdit!==1) bad.push('THREE: F2 in a raid did not turn Edit the words on');
       if(keys.F2) bad.push('THREE: F2 also reached the raid as a key press');
       if(pauseOpen||document.getElementById('pausebox').classList.contains('on')) bad.push('THREE: the pause box opened over the screen');
       if(!g.paused) bad.push('THREE: the raid is not paused while the mode is on');
       keys.KeyD=true; mouse.down=true;
       a=snap(); run(8); b=snap();
       if(b.t!==a.t) bad.push('THREE: the raid time moved while frozen (G.t '+a.t+' to '+b.t+')');
       if(b.tl!==a.tl) bad.push('THREE: the raid clock ran while frozen ('+a.tl+' to '+b.tl+')');
       if(b.px!==a.px||b.py!==a.py) bad.push('THREE: the player moved while frozen with D held');
       if(b.es!==a.es) bad.push('THREE: an enemy moved while frozen');
       hits=txRecord(function(){ run(1); });
       if(hits.length<5) bad.push('THREE: a frozen frame drew only '+hits.length+' strings, the screen is not kept for a click to find');
       for(i=0,c=null;i<hits.length;i++){ if(hits[i].o&&String(hits[i].o).length>=3&&hits[i].w>=10&&hits[i].cv&&hits[i].cv.getBoundingClientRect().width>0){ c=hits[i]; break; } }
       if(c){
         var bx=txBox(c), rc=c.cv.getBoundingClientRect(), fx=rc.left+(bx.x+bx.w/2)*(rc.width/c.cv.width), fy=rc.top+(bx.y+bx.h/2)*(rc.height/c.cv.height);
         if(!txFind(fx,fy)) bad.push('THREE: a click on the string '+String(c.o).slice(0,30)+' in the frozen frame finds nothing');
       }
       if(!tagUp()) bad.push('THREE: no "edit words: on (f2)" tag while the mode is on');
       if(tt.indexOf('edit words on')<0) bad.push('THREE: no short "edit words on" toast on turning it on');
       // FOUR: off again: the raid carries on, nothing held is left latched, the tag goes, the toast says off
       press('F2'); rel('F2');
       ht=document.getElementById('hubtoast'); tt=ht?String(ht.textContent).toLowerCase():'';
       if(CFG.textEdit!==0) bad.push('FOUR: the second F2 in the raid did not turn it off');
       if(g.paused) bad.push('FOUR: the raid is still paused after the mode went off');
       held=heldKeys();
       if(held.length||mouse.down) bad.push('FOUR: a key or the mouse button was left held ('+held.join(',')+', mouse.down '+mouse.down+')');
       a=snap(); run(8); b=snap();
       if(!(b.t>a.t+0.2)) bad.push('FOUR: the raid time did not move again after turning it off (G.t '+a.t+' to '+b.t+')');
       if(Math.abs(b.px-a.px)>walk*0.2) bad.push('FOUR: the player walked '+(b.px-a.px).toFixed(1)+' after resume with nothing held, a held D was latched');
       if(tagUp()) bad.push('FOUR: the tag stayed up after the mode went off');
       if(tt.indexOf('edit words off')<0) bad.push('FOUR: no short "edit words off" toast on turning it off');
       // FIVE: F2 typed while the words editor has the focus still turns the mode off and closes the editor
       press('F2'); rel('F2');
       el=txOpen('zqx probe line','zqx probe line',0,0,50,14);
       if(el){ el.dispatchEvent(new KeyboardEvent('keydown',{code:'F2',key:'F2',bubbles:true,cancelable:true}));
         if(CFG.textEdit!==0) bad.push('FIVE: F2 inside the words editor did not turn the mode off');
         if(typeof TXBOX!=='undefined'&&TXBOX) bad.push('FIVE: the words editor stayed open after F2 turned the mode off'); }
       else bad.push('FIVE: the words editor did not open');
       // SIX: a word edited in the arcade is also written into his own profile string, so leaving the arcade keeps it
       if(typeof txSet==='function'){
         ARCADE.on=1; ARCADE.realJs=JSON.stringify({pname:'zqx',txt:{'zqx old line':'zqx old words'}});
         txSet('zqx probe line','zqx probe words');
         var rj=null; try{ rj=JSON.parse(ARCADE.realJs); }catch(_pj){}
         if(!rj||!rj.txt||rj.txt['zqx probe line']!=='zqx probe words') bad.push('SIX: a word edited in the arcade is not in his own profile, so leaving the arcade loses it');
         if(!rj||!rj.txt||rj.txt['zqx old line']!=='zqx old words') bad.push('SIX: the arcade copy of an edit wiped another of his words');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ DEV_LOCAL=dl0; }catch(_d){}
       try{ ARCADE.on=ao0; ARCADE.realJs=ar0; }catch(_a){}
       try{ txClose(); }catch(_c){}
       try{ keys={}; mouse.down=false; }catch(_k){}
       try{ if(raided) __endRaid('abandon'); }catch(_e){}
       try{ var tj=JSON.parse(txt0); if(tj===null) delete P.txt; else P.txt=tj; tj=JSON.parse(txp0); if(tj===null) delete P.txp; else P.txp=tj; }catch(_t){}
       try{ var gj=JSON.parse(go0); if(gj===null) delete P.gameOpts; else P.gameOpts=gj; P.tuned=JSON.parse(tu0)||{}; P.keymap=JSON.parse(km0); P.keymapV=kv0; KEYS.inv=null; keysInv(); }catch(_g){}
       try{ CFG.textEdit=te0; if(typeof txTagSync==='function') txTagSync(); }catch(_x){}
       try{ saveProfile(); }catch(_s){}
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
