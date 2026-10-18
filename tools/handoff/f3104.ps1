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

if ($s.Contains("  {v:'31.04',what:")) { throw "check 31.04 is in the fixture already" }

SubRx @'
  {v:'31.03',what:
'@ @'
  {v:'31.04',what:'cw-shkey, his note (2026-10-18) "superhot mode needs a toggle key": the key left of 1 turns Superhot on and off in a raid once per press and moves the same dial as the one Settings row, the line on screen always says the state just set (also on three quick presses), the F1 list and the pane beside the Settings row name the key, and a linked window refuses its own press and says it when the host flips Superhot',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame)) return 'SKIP: this fixture cannot deploy, step the loop or draw a frame';
     if(typeof cycleGameOpt!=='function'||typeof applyGameOpts!=='function'||typeof GAMEOPTS==='undefined'||typeof keys==='undefined'||typeof KeyboardEvent==='undefined') return 'SKIP: no Superhot row or keys in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     if(typeof __vpAlive==='function'&&!__vpAlive()) return 'SKIP: the page has no laid out viewport, so the Settings pane and the controls list cannot be read';
     var bad=[], g=null, i, r, txt, proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, w, row, sl, hadGo=!!P.gameOpts, go0=P.gameOpts?JSON.parse(JSON.stringify(P.gameOpts)):null, ls0=null, seen;
     var hasNet=(typeof NET==='object'&&NET&&typeof netShTake==='function'&&typeof netShDrop==='function'), NK={}, k, netTouched=false;
     function el(id){ return document.getElementById(id); }
     function on(e){ return !!(e&&e.classList.contains('on')); }
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; mouse.down=false; }catch(_k){} }
     // The key as it arrives: a keydown on the window, and a keyup, with the repeat flag a held key sends.
     function bq(rep){ clearKeys(); window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backquote',key:'`',repeat:!!rep,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'Backquote',key:'`',bubbles:true,cancelable:true})); clearKeys(); }
     function setSuper(v){ P.gameOpts=P.gameOpts||{}; P.gameOpts.superhot=v; applyGameOpts(); }
     function topMsg(){ return g&&g.msg; }
     // Every Superhot line the player can see: the two message rows over the screen and the lines of the left feed.
     function shLines(){ return (g.feed||[]).map(function(f){ return f&&f.m; }).concat(((g.fd&&g.fd.lines)||[]).map(function(l){ return l&&l.txt; })).filter(function(m){ return /^SUPERHOT/.test(m||''); }); }
     function wipe(){ g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.fd={t:0,seq:0,lines:[]}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(typeof state==='undefined'||state!=='raid') return 'SKIP: the page is not in a raid here';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ m.classList.remove('on'); });
       if(typeof togglePauseBox==='function'&&on(el('pausebox'))) togglePauseBox(false);
       setSuper(0);
       // ONE CONTROL: Superhot has one Settings row; the key moves the same dial and the same saved word, it is not a second setting.
       if(GAMEOPTS.filter(function(o){ return o.k==='superhot'; }).length!==1) bad.push('Superhot has '+GAMEOPTS.filter(function(o){ return o.k==='superhot'; }).length+' Settings rows, not one');
       // THE KEY: the key left of 1 turns Superhot on and off in a raid, once per press, and a held key (repeat) does nothing more.
       bq(false);
       if(CFG.superhot!==1||P.gameOpts.superhot!==1) bad.push('the key left of 1 did not turn Superhot on in a raid (dial '+CFG.superhot+', saved '+P.gameOpts.superhot+')');
       if(topMsg()!=='SUPERHOT ON') bad.push('the first press said "'+topMsg()+'", not SUPERHOT ON');
       bq(true);
       if(CFG.superhot!==1) bad.push('a held key (repeat) flipped Superhot again');
       // THE TOAST TELLS THE TRUTH on three quick presses: the line on top is the state the last press set, not the one before it.
       bq(false);
       if(CFG.superhot!==0||topMsg()!=='SUPERHOT OFF') bad.push('the second press said "'+topMsg()+'" with the dial at '+CFG.superhot+', not SUPERHOT OFF');
       bq(false);
       if(CFG.superhot!==1) bad.push('the third press did not turn Superhot on again');
       if(topMsg()!=='SUPERHOT ON') bad.push('on three quick presses the line on top said "'+topMsg()+'" with Superhot ON, so the toast shows the state before the last press');
       seen=shLines();
       if(seen.some(function(m){ return m!=='SUPERHOT ON'; })) bad.push('three quick presses (on, off, on) left the lines "'+seen.join('", "')+'" on screen, so one of them says OFF with Superhot ON');
       // THE SETTINGS ROW follows the key: with Settings open the Superhot row shows the state the key set.
       if(typeof openSettings==='function'&&el('settingsmodal')){
         openSettings();
         row=el('go_superhot');
         if(!row) bad.push('the Settings list has no Superhot row to follow the key');
         else{
           w=row.textContent;
           bq(false);
           if(CFG.superhot!==0) bad.push('the key did not turn Superhot off with Settings open');
           row=el('go_superhot');
           if(!row||row.textContent===w) bad.push('the Superhot row did not change when the key moved the dial with Settings open');
           bq(false);
         }
         // THE ROW NAMES ITS KEY: the pane beside the list says which key does what the row does.
         sl=el('setlist'); row=el('go_superhot');
         if(row&&sl&&typeof window.__setDetailSync==='function'){
           try{ row.scrollIntoView({block:'center'}); }catch(_si){}
           row.dispatchEvent(new MouseEvent('mouseover',{bubbles:true}));
           window.__setDetailSync();
           w=(el('setdetail')||{}).textContent||'';
           if(w.indexOf('`')<0) bad.push('the pane beside the Settings list does not name the key for Superhot ('+w.slice(0,80)+')');
         }
         el('settingsmodal').classList.remove('on');
       }
       // THE F1 LIST names the key and the word.
       setSuper(0); wipe(); g.legendOn=2; g.bagOpen=false; txt=[];   // the feed is cleared: the lines the key just said would answer for the list
       proto.fillText=function(){ txt.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ __frame(0.016); } finally { proto.fillText=oFt; }
       if(!txt.some(function(s){ return /superhot/i.test(s); })) bad.push('the F1 controls list does not mention Superhot');
       if(txt.indexOf('`')<0) bad.push('the F1 controls list does not show the key left of 1');
       g.legendOn=1;
       // THE PLAYER 2 WINDOW: it follows the host. Its own press says so and changes nothing; the host flipping it mid raid is said there too.
       if(hasNet){
         for(k in NET) NK[k]=NET[k]; netTouched=true;
         NET.on=true; NET.role='join'; NET.shHost=null; NET.shOwn=null; setSuper(0); CFG.superhot=0;
         netShTake(0);
         bq(false);
         if(CFG.superhot!==0) bad.push('a linked window changed Superhot on its own key press (dial '+CFG.superhot+')');
         wipe();
         netShTake(1);
         if(CFG.superhot!==1) bad.push('the linked window did not follow the host to Superhot ON');
         if(topMsg()!=='SUPERHOT ON') bad.push('the host turned Superhot on mid raid and the linked window said "'+topMsg()+'"');
         wipe();
         netShTake(1);
         if(topMsg()) bad.push('the linked window said "'+topMsg()+'" when the host word did not change');
         netShTake(0);
         if(CFG.superhot!==0||topMsg()!=='SUPERHOT OFF') bad.push('the host turning Superhot off mid raid left the linked window at '+CFG.superhot+' saying "'+topMsg()+'"');
         netShDrop();
       }
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fillText=oFt;
       if(netTouched){ try{ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){} }
       clearKeys();
       try{ var _sm=el('settingsmodal'); if(_sm) _sm.classList.remove('on'); }catch(_e0){}
       if(hadGo) P.gameOpts=go0; else delete P.gameOpts;
       try{ applyGameOpts(); saveProfile(); }catch(_e4){}
       try{ __endRaid('abandon'); }catch(_e5){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'31.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
