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

if ($s.Contains("  {v:'31.37',what:")) { throw "check 31.37 is in the fixture already" }

SubRx @'
  {v:'31.36',what:
'@ @'
  {v:'31.37',what:'cw-partykeys, the coordinator: at the party (?party=1, and the 2 player arcade demo played from it) a guest can hit F2 or F8 by accident, the F keys sit above the gun numbers, and freeze a raid he cannot read: there a plain F2 or F8 does nothing, Ctrl+F2 still edits the words (tag edit words: on (ctrl f2)) and Ctrl+F8 still snips, the chord does not flip the crouch, and outside party mode F2 and F8 stay as they were while a Ctrl chord does nothing',
   run:function(){
     if(typeof DEV_LOCAL==='undefined'||!DEV_LOCAL) return 'SKIP: not a local build, the word editor and the snip tool are never here';
     if(typeof PARTY==='undefined'||typeof SNIP!=='object'||!SNIP) return 'SKIP: no party flag or no snip tool in this build';
     if(!(window.__deploy&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__loop&&window.__state&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot drive a raid';
     var bad=[], raided=false, p0=PARTY, te0=CFG.textEdit, go0=JSON.stringify(P.gameOpts||null), sn0=SNIP.dom, ts=performance.now()+10, g, p, a, b, cr0, chg, t0;
     function tap(code,m){ m=m||{}; var o={code:code,key:code,ctrlKey:!!m.c,altKey:!!m.a,shiftKey:!!m.s,bubbles:true,cancelable:true}; window.dispatchEvent(new KeyboardEvent('keydown',o)); window.dispatchEvent(new KeyboardEvent('keyup',o)); }
     function cdown(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'ControlLeft',key:'Control',ctrlKey:true,bubbles:true,cancelable:true})); }
     function cup(){ window.dispatchEvent(new KeyboardEvent('keyup',{code:'ControlLeft',key:'Control',bubbles:true,cancelable:true})); }
     function esc(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true})); }
     function run(n){ for(var q=0;q<n;q++){ ts+=50; __loop(ts); } }
     function snap(){ var s=0, q; for(q=0;q<g.ents.length;q++) s+=(g.ents[q].x||0)+(g.ents[q].y||0); return {t:g.t,tl:g.timeLeft,px:p.x,py:p.y,es:s}; }
     function tagTx(){ var e=document.getElementById('txtag'); return (e&&e.style.display!=='none')?String(e.textContent):''; }
     function snipUp(){ return !!(SNIP.on&&document.getElementById('snipov')); }
     function toastTx(){ var e=document.getElementById('hubtoast'); return e?String(e.textContent).toLowerCase():''; }
     function rmTag(){ try{ var tg=document.getElementById('txtag'); if(tg&&tg.parentNode) tg.parentNode.removeChild(tg); }catch(_tg){} }   // the plate is made once with the words for the flag it was made under, so each arm starts without it
     try{
       SNIP.dom=0;   // the page layer is a picture of the page, which a check cannot wait for
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.gameOpts=P.gameOpts||{}; P.gameOpts.textEdit=0; CFG.textEdit=0; keys={}; mouse.down=false;
       if(SNIP.on) snipEnd('esc');
       // ONE (control): outside party mode F2 and F8 are as they were: plain keys work, a Ctrl chord does nothing
       rmTag(); PARTY=false;
       tap('F2',{c:true}); tap('F8',{c:true});
       if(CFG.textEdit!==0||tagTx()) bad.push('ONE: Ctrl+F2 outside party mode changed the words mode');
       if(snipUp()) bad.push('ONE: Ctrl+F8 outside party mode started a snip');
       tap('F2');
       if(CFG.textEdit!==1||!/edit words: on \(f2\)/.test(tagTx())) bad.push('ONE: plain F2 outside party mode did not turn the words mode on with the f2 tag ('+CFG.textEdit+', '+tagTx()+')');
       tap('F2');
       if(CFG.textEdit!==0) bad.push('ONE: a second plain F2 outside party mode did not turn it off');
       tap('F8');
       if(!snipUp()) bad.push('ONE: plain F8 outside party mode did not start a snip');
       tap('F8');
       if(snipUp()) bad.push('ONE: a second plain F8 outside party mode did not end the snip');
       // TWO: in party mode, in a menu, a plain F2 or F8 does nothing at all; Ctrl+Shift and Ctrl+Alt do nothing either
       PARTY=true;
       t0=toastTx();
       tap('F2');
       if(CFG.textEdit!==0) bad.push('TWO: plain F2 in party mode turned the words mode on');
       if(tagTx()) bad.push('TWO: plain F2 in party mode raised the tag ('+tagTx()+')');
       tap('F8');
       if(snipUp()) bad.push('TWO: plain F8 in party mode started a snip');
       tap('F2',{c:true,s:true}); tap('F2',{c:true,a:true}); tap('F8',{c:true,s:true}); tap('F8',{c:true,a:true});
       if(CFG.textEdit!==0||snipUp()) bad.push('TWO: a Ctrl chord with Shift or Alt did something in party mode');
       if(toastTx()!==t0) bad.push('TWO: a plain key in party mode put up a toast ('+toastTx()+')');
       // THREE: in party mode Ctrl+F2 turns the words mode on with the key named in the tag, a plain F2 does not turn it off, Ctrl+F2 does; the same for the snip with Ctrl+F8, ESC ends it
       rmTag();   // the plate made in ONE (party off) says f2; in the real page the flag never changes, so it is made once with the right words
       tap('F2',{c:true});
       if(CFG.textEdit!==1) bad.push('THREE: Ctrl+F2 in party mode did not turn the words mode on');
       if(tagTx()!=='edit words: on (ctrl f2)') bad.push('THREE: the tag in party mode reads "'+tagTx()+'", not "edit words: on (ctrl f2)"');
       if(toastTx().indexOf('edit words on')<0) bad.push('THREE: no edit words on toast for Ctrl+F2');
       tap('F2');
       if(CFG.textEdit!==1||!tagTx()) bad.push('THREE: a plain F2 turned the words mode off in party mode');
       tap('F2',{c:true});
       if(CFG.textEdit!==0||tagTx()) bad.push('THREE: Ctrl+F2 did not turn the words mode off in party mode');
       tap('F8',{c:true});
       if(!snipUp()) bad.push('THREE: Ctrl+F8 in party mode did not start a snip');
       tap('F8');
       if(!snipUp()) bad.push('THREE: a plain F8 ended the snip in party mode');
       esc();
       if(snipUp()) bad.push('THREE: ESC did not end the snip in party mode');
       tap('F8',{c:true}); tap('F8',{c:true});
       if(snipUp()) bad.push('THREE: a second Ctrl+F8 did not end the snip in party mode');
       // FOUR: in a raid at the party, plain F2 and F8 leave the raid running; Ctrl+F2 and Ctrl+F8 freeze it and give the crouch back
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); raided=true;
       g=__state(); if(!g||g.sim||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; keys={}; mouse.down=false;
       a=snap(); run(8); b=snap();
       if(!(b.t>a.t+0.2)) return 'SKIP: the raid clock did not run in 8 frames before the keys (G.t '+a.t+' to '+b.t+')';
       tap('F2'); tap('F8');
       if(g.paused||CFG.textEdit===1||snipUp()) bad.push('FOUR: a plain F2 or F8 in a party raid froze it (paused '+g.paused+', words '+CFG.textEdit+', snip '+snipUp()+')');
       a=snap(); run(8); b=snap();
       if(!(b.t>a.t+0.2)) bad.push('FOUR: the party raid clock stopped after plain F2 and F8 (G.t '+a.t+' to '+b.t+')');
       cr0=!!g.crouchTog; cdown(); chg=(!!g.crouchTog!==cr0);
       tap('F2',{c:true});
       if(!g.paused||CFG.textEdit!==1) bad.push('FOUR: Ctrl+F2 in a party raid did not freeze it (paused '+g.paused+', words '+CFG.textEdit+')');
       if(chg&&!!g.crouchTog!==cr0) bad.push('FOUR: Ctrl+F2 left the crouch flipped, the chord did not give back the Ctrl press change (ctrlUndo '+g.ctrlUndo+', crouch '+cr0+' to '+g.crouchTog+')');
       a=snap(); run(8); b=snap();
       if(b.t!==a.t||b.tl!==a.tl||b.es!==a.es) bad.push('FOUR: the raid moved while Ctrl+F2 held it (G.t '+a.t+' to '+b.t+')');
       cup(); cdown();
       tap('F2',{c:true});
       if(g.paused||CFG.textEdit!==0) bad.push('FOUR: the second Ctrl+F2 did not let the party raid go (paused '+g.paused+', words '+CFG.textEdit+')');
       if(chg&&!!g.crouchTog!==cr0) bad.push('FOUR: the second Ctrl+F2 left the crouch flipped');
       cup(); keys={};
       a=snap(); run(8); b=snap();
       if(!(b.t>a.t+0.2)) bad.push('FOUR: the party raid did not run again after the second Ctrl+F2');
       tap('F8',{c:true});
       if(!snipUp()||!g.paused) bad.push('FOUR: Ctrl+F8 in a party raid did not freeze it with a snip up (snip '+snipUp()+', paused '+g.paused+')');
       esc();
       if(snipUp()||g.paused) bad.push('FOUR: ESC did not end the snip and let the party raid go');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ PARTY=p0; }catch(_p){}
       try{ if(SNIP.on) snipEnd('esc'); }catch(_s){}
       try{ SNIP.dom=sn0; }catch(_n){}
       try{ keys={}; mouse.down=false; }catch(_k){}
       try{ if(raided) __endRaid('abandon'); }catch(_e){}
       try{ var gj=JSON.parse(go0); if(gj===null) delete P.gameOpts; else P.gameOpts=gj; CFG.textEdit=te0; if(typeof txTagSync==='function') txTagSync(); rmTag(); }catch(_g){}
       try{ saveProfile(); }catch(_sv){}
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
