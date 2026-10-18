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

if ($s.Contains("  {v:'31.13',what:")) { throw "check 31.13 is in the fixture already" }

SubRx @'
  {v:'31.12',what:
'@ @'
  {v:'31.13',what:'cw-snip, his order (2026-10-18) an in game snipping tool that pauses the game so he can snip any part of the page and send it, with an option to copy to the clipboard: F8 freezes a raid through the one freeze, dims the screen and draws a cross cursor; a dragged box shows its size; on release a panel has copy (one image/png item on the clipboard at the box size) and save (one POST to the collector feedback route whose PNG is the box size), either then the other, no third button; the game stays frozen until ESC, F8 or a click outside the panel, that click fires no shot and nothing is left held; ESC with nothing done cancels with no copy and no post; F8 is edge only, reserved, and does nothing off this machine',
   run:function(){
     if(typeof DEV_LOCAL==='undefined'||!DEV_LOCAL) return 'SKIP: not a local build, the snip tool is never here';
     if(!(window.__deploy&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__loop&&window.__state&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot drive a raid';
     var bad=[], raided=false, dl0=DEV_LOCAL, te0=CFG.textEdit, go0=JSON.stringify(P.gameOpts||null), fetch0=window.fetch, hadCI=('ClipboardItem' in window), ci0=window.ClipboardItem,
         cd0=Object.getOwnPropertyDescriptor(navigator,'clipboard'), ld0=LOCAL_DROP, dr0=DROP, ff0=fbFiles, fd=[], fmode='ok', posts=[], writes=[], wmode='ok', seen={md:0,mu:0,ck:0,esc:0}, ts=performance.now()+10, sn0=1, i, g, p, a, b, held, bx, pn, btns, it, bl, dm, sp, d0, d1;
     function press(code,rep){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,repeat:!!rep,bubbles:true,cancelable:true})); }
     function rel(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function run(n){ for(var q=0;q<n;q++){ ts+=50; __loop(ts); } }
     function snap(){ var s=0, q; for(q=0;q<g.ents.length;q++) s+=(g.ents[q].x||0)+(g.ents[q].y||0); return {t:g.t,tl:g.timeLeft,px:p.x,py:p.y,es:s}; }
     function mev(type,x,y,tg){ (tg||document.getElementById('snipov')||document.body).dispatchEvent(new MouseEvent(type,{clientX:x,clientY:y,button:0,buttons:type==='mouseup'?0:1,bubbles:true,cancelable:true,view:window})); }
     function th(ok,err){ var o={then:function(f,r){ try{ if(ok){ if(typeof f==='function') f({ok:true}); } else if(typeof r==='function') r(err); }catch(_e){} return o; }}; return o; }
     function dims(u){ var s=String(u||''), c=s.indexOf(','), t; if(c<0) return null; t=atob(s.slice(c+1,c+45)); if(t.slice(1,4)!=='PNG') return null; function n(o){ return t.charCodeAt(o)*16777216+(t.charCodeAt(o+1)<<16)+(t.charCodeAt(o+2)<<8)+t.charCodeAt(o+3); } return {w:n(16),h:n(20)}; }
     function toastTx(){ var e=document.getElementById('hubtoast'); return e?String(e.textContent).toLowerCase():''; }
     function heldKeys(){ return Object.keys(keys).filter(function(k){ return keys[k]; }); }
     function pMd(){ seen.md++; } function pMu(){ seen.mu++; } function pCk(){ seen.ck++; } function pKd(e){ if(e&&e.code==='Escape') seen.esc++; }
     function drag(x0,y0,x1,y1){ mev('mousedown',x0,y0); mev('mousemove',(x0+x1)>>1,(y0+y1)>>1); mev('mousemove',x1,y1); mev('mouseup',x1,y1); }
     try{
       sn0=SNIP.dom; SNIP.dom=0;   // the page layer is drawn from a picture of the page, which a check cannot wait for: it is tried in NINE (starts without a fault) and by camera
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.gameOpts=P.gameOpts||{}; P.gameOpts.textEdit=0; CFG.textEdit=0; keys={}; mouse.down=false;
       window.addEventListener('mousedown',pMd); window.addEventListener('mouseup',pMu); window.addEventListener('click',pCk); window.addEventListener('keydown',pKd);
       LOCAL_DROP='http://localhost:8799/telemetry'; DROP=LOCAL_DROP;   // the fixture points DROP at a black hole; this is the collector as it is on his own machine
       fbFiles=function(t,d,s){ fd.push({t:t,d:d,s:s}); return 'downloaded'; };   // the fallback must not really download files from a check
       window.fetch=function(u,o){ posts.push({u:String(u),m:o&&o.method,b:String((o&&o.body)||'')}); return fmode==='ok'?th(true):th(false,new Error('collector down')); };
       window.ClipboardItem=function(o){ this.o=o; this.types=Object.keys(o); };
       Object.defineProperty(navigator,'clipboard',{configurable:true,get:function(){ return {write:function(items){ writes.push(items); return wmode==='ok'?th(true):th(false,new Error('document is not focused')); }}; }});
       // CONTROL: with no snip up the probes do see a plain mouse press
       window.dispatchEvent(new MouseEvent('mousedown',{bubbles:true,button:0,clientX:5,clientY:5})); window.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,button:0,clientX:5,clientY:5})); window.dispatchEvent(new MouseEvent('click',{bubbles:true,button:0,clientX:5,clientY:5}));
       mouse.down=false; keys={};
       if(seen.md!==1||seen.mu!==1||seen.ck!==1) return 'SKIP: the probes did not see a plain mouse press ('+seen.md+','+seen.mu+','+seen.ck+')';
       seen.md=seen.mu=seen.ck=seen.esc=0;
       // ONE: F8 off this machine does nothing; on it, in a menu, it starts a snip and the same key ends it; a held key does not toggle twice; no pause in a menu
       DEV_LOCAL=false; press('F8'); rel('F8'); DEV_LOCAL=dl0;
       if(SNIP.on||document.getElementById('snipov')) bad.push('ONE: F8 started a snip in a build that is not local');
       press('F8'); rel('F8');
       if(!SNIP.on||!document.getElementById('snipov')) bad.push('ONE: F8 in a menu did not start a snip (no overlay)');
       else{
         if(String(document.getElementById('snipov').style.cursor)!=='crosshair') bad.push('ONE: the cursor over the snip is not a cross');
         if(keys.F8) bad.push('ONE: F8 also reached the game as a key press');
         press('F8',true);
         if(!SNIP.on) bad.push('ONE: a held F8 (key repeats) ended the snip');
         press('F8'); rel('F8');
         if(SNIP.on||document.getElementById('snipov')) bad.push('ONE: a second F8 did not end the snip');
         if(toastTx().indexOf('snip cancelled')<0) bad.push('ONE: no snip cancelled toast on ending with nothing done');
       }
       // TWO: F8 is reserved, so no action can be bound to it
       if(typeof keysBind==='function'&&keysBind('KeyR','F8')) bad.push('TWO: the Keys window let reload be bound to F8, the snip key');
       // THREE: in a raid F8 freezes the world through the one pause (no pause box), a staged drag draws the box with its size and opens a panel with copy and save
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); raided=true;
       g=__state(); if(!g||g.sim||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; keys={}; mouse.down=false;
       a=snap(); keys.KeyD=true; run(8); b=snap(); keys={};
       if(!(b.t>a.t+0.2)) return 'SKIP: the raid clock did not run in 8 frames before the snip (G.t '+a.t+' to '+b.t+')';
       run(10);
       press('F8'); rel('F8');
       if(!SNIP.on) bad.push('THREE: F8 in a raid did not start a snip');
       if(!g.paused) bad.push('THREE: the raid is not paused while the snip is up');
       if(pauseOpen||document.getElementById('pausebox').classList.contains('on')) bad.push('THREE: the pause box opened over the screen');
       keys.KeyD=true; mouse.down=true;
       a=snap(); run(8); b=snap();
       if(b.t!==a.t||b.tl!==a.tl) bad.push('THREE: the raid time or clock moved while the snip was up (G.t '+a.t+' to '+b.t+', clock '+a.tl+' to '+b.tl+')');
       if(b.px!==a.px||b.py!==a.py) bad.push('THREE: the player moved while the snip was up with D held');
       if(b.es!==a.es) bad.push('THREE: an enemy moved while the snip was up');
       drag(200,150,440,330);
       if(!SNIP.box||SNIP.box.x!==200||SNIP.box.y!==150||SNIP.box.w!==240||SNIP.box.h!==180) bad.push('THREE: the dragged box is '+JSON.stringify(SNIP.box)+', not 200,150 240x180');
       bx=document.getElementById('snipbox');
       if(!bx||bx.style.display==='none'||bx.style.left!=='200px'||bx.style.top!=='150px'||bx.style.width!=='240px'||bx.style.height!=='180px') bad.push('THREE: no outline drawn at the dragged box');
       if(!document.getElementById('snipsz')||String(document.getElementById('snipsz').textContent).indexOf('240 x 180')<0) bad.push('THREE: the box size 240 x 180 is not shown');
       pn=document.getElementById('snippanel');
       btns=pn?[].slice.call(pn.querySelectorAll('button')):[];
       if(!pn) bad.push('THREE: no panel after the box was dragged');
       else{
         if(btns.length!==2||btns[0].textContent!=='copy'||btns[1].textContent!=='save') bad.push('THREE: the panel buttons are ['+btns.map(function(x){ return x.textContent; }).join(',')+'], not copy and save');
         var pr0=pn.getBoundingClientRect();
         if(pr0.left<0||pr0.top<0||pr0.right>window.innerWidth||pr0.bottom>window.innerHeight) bad.push('THREE: the panel is partly off the screen');
       }
       if(seen.md||seen.mu||seen.ck) bad.push('THREE: the drag reached the game ('+seen.md+' presses, '+seen.mu+' releases, '+seen.ck+' clicks)');
       // FOUR: copy gives ONE image/png item at the box size; a refusal says why; the game stays frozen with the panel up
       if(btns[0]){
         btns[0].click();
         if(writes.length!==1) bad.push('FOUR: copy made '+writes.length+' clipboard writes, not 1');
         else{
           it=writes[0]&&writes[0].length===1?writes[0][0]:null;
           bl=it&&it.o?it.o['image/png']:null;
           if(!it||it.types.join(',')!=='image/png') bad.push('FOUR: the clipboard item is not exactly one image/png');
           else if(!(bl instanceof Blob)||bl.type!=='image/png') bad.push('FOUR: the clipboard picture is not a png blob');
           dm=dims(SNIP.png);
           if(!dm||dm.w!==Math.round(240*DPRH)||dm.h!==Math.round(180*DPRH)) bad.push('FOUR: the copied picture is '+(dm?dm.w+'x'+dm.h:'not a png')+', not the box at '+DPRH+'x ('+Math.round(240*DPRH)+'x'+Math.round(180*DPRH)+')');
           else if(bl instanceof Blob&&bl.size!==atob(SNIP.png.slice(SNIP.png.indexOf(',')+1)).length) bad.push('FOUR: the clipboard blob is not the cut picture ('+bl.size+' bytes)');
         }
         if(toastTx().indexOf('snip copied')<0) bad.push('FOUR: no snip copied toast');
         wmode='no'; btns[0].click(); wmode='ok';
         if(toastTx().indexOf('copy refused: document is not focused')<0) bad.push('FOUR: a refused copy does not say why ('+toastTx()+')');
         if(!g.paused||!SNIP.on) bad.push('FOUR: the snip ended or the game ran on after a copy');
       }
       // FIVE: save makes ONE post to the collector feedback route whose png is the box size; copy again after save still works
       if(btns[1]){
         btns[1].click();
         if(posts.length!==1) bad.push('FIVE: save made '+posts.length+' posts, not 1');
         else{
           var want=LOCAL_DROP.replace(/telemetry$/,'feedback'), mk='\n----PILLAGERS-PNG----\n', ix=posts[0].b.indexOf(mk), head=ix>=0?posts[0].b.slice(0,ix):'', tail=ix>=0?posts[0].b.slice(ix+mk.length):'';
           if(posts[0].u!==want||posts[0].m!=='POST') bad.push('FIVE: the post went to '+posts[0].u+' ('+posts[0].m+'), not '+want);
           if(ix<0||tail.indexOf('data:image/png;base64,')!==0) bad.push('FIVE: the post has no png after the marker');
           dm=dims(tail);
           if(!dm||dm.w!==Math.round(240*DPRH)||dm.h!==Math.round(180*DPRH)) bad.push('FIVE: the saved picture is '+(dm?dm.w+'x'+dm.h:'not a png')+', not the box');
           if(head.toLowerCase().indexOf('snip')<0||head.indexOf(String(VER))<0||head.indexOf('240x180')<0) bad.push('FIVE: the saved note does not name the snip, the build and the box');
         }
         if(toastTx().indexOf('snip saved')<0) bad.push('FIVE: no snip saved toast ('+toastTx()+')');
         var w1=writes.length; btns[0].click();
         if(writes.length!==w1+1) bad.push('FIVE: copy after save did not make a second write');
         if(!g.paused||!SNIP.on) bad.push('FIVE: the snip ended or the game ran on after a save');
         fmode='down'; btns[1].click(); fmode='ok';
         if(fd.length!==1) bad.push('FIVE: with the collector down save made '+fd.length+' file downloads, not 1');
         else{ dm=dims(fd[0].d); if(!dm||dm.w!==Math.round(240*DPRH)||dm.h!==Math.round(180*DPRH)) bad.push('FIVE: the fallback download is not the box picture'); }
         if(toastTx().indexOf('snip saved to downloads')<0) bad.push('FIVE: no saved to downloads toast with the collector down ('+toastTx()+')');
       }
       a=snap(); run(4); b=snap();
       if(b.t!==a.t||b.px!==a.px) bad.push('FIVE: the game moved with the panel up');
       // SIX: a click outside the panel ends it; the game carries on; that click fires no shot and nothing is left held; the rest of the click is eaten
       mev('mousedown',900,700);
       if(SNIP.on||document.getElementById('snipov')||document.getElementById('snippanel')||document.getElementById('snipbox')) bad.push('SIX: a click outside the panel did not end the snip');
       mev('mouseup',900,700,document.body); document.body.dispatchEvent(new MouseEvent('click',{clientX:900,clientY:700,button:0,bubbles:true,cancelable:true,view:window}));
       if(seen.md||seen.mu||seen.ck) bad.push('SIX: the click that ended the snip reached the game ('+seen.md+' presses, '+seen.mu+' releases, '+seen.ck+' clicks)');
       if(g.paused) bad.push('SIX: the raid is still paused after the snip ended');
       if(mouse.down) bad.push('SIX: the mouse button was left held (a shot would follow)');
       held=heldKeys(); if(held.length) bad.push('SIX: keys were left held: '+held.join(','));
       if(toastTx().indexOf('snip cancelled')>=0) bad.push('SIX: ending after a copy and a save said cancelled');
       a=snap(); run(8); b=snap();
       if(!(b.t>a.t+0.2)) bad.push('SIX: the raid time did not move again after the snip (G.t '+a.t+' to '+b.t+')');
       if(Math.abs(b.px-a.px)>2) bad.push('SIX: the player walked '+(b.px-a.px).toFixed(1)+' after the snip with nothing held');
       window.dispatchEvent(new MouseEvent('click',{bubbles:true,button:0})); if(seen.ck!==1) bad.push('SIX: the click eater stayed on and ate a later click');
       seen.md=seen.mu=seen.ck=seen.esc=0;
       // SEVEN: ESC with nothing done cancels, with no copy and no post, and does not open the pause box or reach the game
       w1=writes.length; var p1=posts.length;
       press('F8'); rel('F8');
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       if(SNIP.on||document.getElementById('snipov')) bad.push('SEVEN: ESC did not end the snip');
       if(seen.esc) bad.push('SEVEN: ESC reached the game');
       if(pauseOpen||document.getElementById('pausebox').classList.contains('on')) bad.push('SEVEN: ESC opened the pause box');
       if(toastTx().indexOf('snip cancelled')<0) bad.push('SEVEN: no snip cancelled toast');
       if(writes.length!==w1||posts.length!==p1) bad.push('SEVEN: cancelling made a copy or a post');
       if(g.paused) bad.push('SEVEN: the raid is still paused after ESC');
       // EIGHT: a click with no drag keeps waiting (no panel); a drag, then ESC, closes with the cancelled toast; F8 also ends it
       press('F8'); rel('F8');
       mev('mousedown',300,300); mev('mouseup',301,301);
       if(!SNIP.on||SNIP.ph!=='pick'||document.getElementById('snippanel')) bad.push('EIGHT: a click with no drag opened a panel or ended the snip');
       drag(100,100,260,220);
       if(!document.getElementById('snippanel')) bad.push('EIGHT: no panel after a drag');
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       if(SNIP.on||document.getElementById('snippanel')) bad.push('EIGHT: ESC with the panel up did not end the snip');
       if(writes.length!==w1||posts.length!==p1) bad.push('EIGHT: cancelling after a drag made a copy or a post');
       press('F8'); rel('F8'); drag(100,100,260,220); press('F8'); rel('F8');
       if(SNIP.on||document.getElementById('snippanel')) bad.push('EIGHT: F8 with the panel up did not end the snip');
       // NINE: with the page layer on, a snip starts without a fault and the layer is pending (it is looked at by camera, not here)
       SNIP.dom=1; press('F8'); rel('F8');
       if(!SNIP.on) bad.push('NINE: F8 with the page layer on did not start a snip');
       else if(SNIP.domState!=='busy') bad.push('NINE: the page layer did not start (state '+SNIP.domState+')');
       press('F8'); rel('F8'); SNIP.dom=0;
       if(SNIP.on) bad.push('NINE: the snip with the page layer did not end');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(SNIP.on) snipEnd('esc'); }catch(_s){}
       try{ DEV_LOCAL=dl0; }catch(_d){}
       try{ SNIP.dom=sn0; }catch(_n){}
       try{ window.removeEventListener('mousedown',pMd); window.removeEventListener('mouseup',pMu); window.removeEventListener('click',pCk); window.removeEventListener('keydown',pKd); }catch(_r){}
       try{ window.fetch=fetch0; LOCAL_DROP=ld0; DROP=dr0; fbFiles=ff0; }catch(_f){}
       try{ if(hadCI) window.ClipboardItem=ci0; else delete window.ClipboardItem; }catch(_c){}
       try{ if(cd0) Object.defineProperty(navigator,'clipboard',cd0); else delete navigator.clipboard; }catch(_cd){}
       try{ keys={}; mouse.down=false; }catch(_k){}
       try{ if(raided) __endRaid('abandon'); }catch(_e){}
       try{ var gj=JSON.parse(go0); if(gj===null) delete P.gameOpts; else P.gameOpts=gj; CFG.textEdit=te0; }catch(_g){}
       try{ saveProfile(); }catch(_sv){}
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
