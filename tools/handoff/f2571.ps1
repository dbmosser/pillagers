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

if ($s.Contains("  {v:'25.71',what:")) { throw "check 25.71 is in the fixture already" }

SubRx @'
  {v:'25.70',what:
'@ @'
  {v:'25.71',what:'his remap screen: every action has a REBIND control (Q and F among them, not P), rebinding SEARCH to F makes F search and E not, the prompt reads F, the clash with the action on F is shown and swapped, ESC cancels and a reserved key (P, ESC) is refused, a side mouse button binds, the binding survives a profile save and load, and RESET TO DEFAULTS puts E back',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__P||!window.__applyLoaded||typeof keysBind!=='function'||typeof keysOpen!=='function'||typeof updatePlayer!=='function') return 'SKIP: this fixture cannot stage the remap screen';
     var bad=[], g=null, p=null, ct=null, snap=null, km0=null, kmv0, kSay=say, kFXS=FXS, nB='band'+'age', i, b, bk, q;
     function dn(code){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function upk(code){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }
     function fr(n){ for(var j=0;j<n;j++) updatePlayer(0.05); }
     function clr(){ for(var z in keys) keys[z]=false; }
     function note(){ return String((typeof KEYS==='object'&&KEYS&&KEYS.note&&KEYS.note.s)||''); }
     function el(sel){ return document.querySelector(sel); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       km0=P.keymap?JSON.parse(JSON.stringify(P.keymap)):null; kmv0=P.keymapV;
       P.keymap={}; KEYS.inv=null; keysInv();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.containers) return 'SKIP: no live raid';
       for(i=0;i<g.containers.length;i++){ if(!g.containers[i].opened&&g.containers[i].loot&&g.containers[i].loot.length&&!g.containers[i].mercSrc){ ct=g.containers[i]; break; } }
       if(!ct) return 'SKIP: no container';
       g.paused=false; p.downed=false; p.dying=false; p.roll=0; p.iv=99; g.searching=null; g.trade=null; clr();
       for(i=0;i<g.zones.length;i++) g.zones[i].open=false;
       p.x=ct.x+18; p.y=ct.y; ct.opened=false; ct.time=60; ct.prog=0; ct.pulled=0;
       // 1. SEARCH onto F: the clash is shown and the two swap
       if(!keysBind('KeyE','KeyF')) bad.push('binding search onto F was refused');
       if(keysOf('KeyE')!=='KeyF'||keysOf('KeyF')!=='KeyE') bad.push('search and next gun did not swap ('+JSON.stringify(P.keymap)+')');
       if(note().indexOf('SWAPPED')<0||note().indexOf('CLASH')<0) bad.push('the clash was not shown ('+note()+')');
       // 2. F searches, E does not, the prompt reads F
       dn('KeyF'); fr(20); upk('KeyF'); clr();
       if(!(ct.prog>0)) bad.push('F did not search after search was put on it');
       ct.prog=0; ct.pulled=0; g.searching=null; clr();
       dn('KeyE'); fr(20); upk('KeyE'); clr();
       if(ct.prog>0) bad.push('E still searched after search was put on F');
       if(!(typeof padOn==='function'&&padOn())&&keyLabel('KeyE','E')!=='F') bad.push('the search prompt reads '+keyLabel('KeyE','E')+', not F');
       // 3. the binding survives a profile save and load
       snap=JSON.parse(JSON.stringify(P));
       keysReset();
       if(keysOf('KeyE')!=='KeyE') bad.push('keysReset did not put search back on E');
       __applyLoaded(snap);
       if(keysOf('KeyE')!=='KeyF') bad.push('the binding did not come back with the loaded profile ('+JSON.stringify(P.keymap)+')');
       if(keyRemap('KeyF')!=='KeyE'||keyRemap('KeyE')!=='KeyF') bad.push('after a profile load F reads as '+keyRemap('KeyF')+' and E as '+keyRemap('KeyE')+' (the key translation was not rebuilt)');
       // 4. the window: a REBIND on every action, Q and F on the list, not P; ESC cancels; P and ESC are refused; a free key binds
       keysReset(); keysOpen();
       if(KEYS_ACTS.some(function(a){ return a[0]==='KeyP'; })) bad.push('the pause key is on the rebind list');
       ['KeyQ','KeyF','KeyE','KeyX','KeyG','KeyH','F1'].forEach(function(c){ if(!KEYS_ACTS.some(function(a){ return a[0]===c; })) bad.push(c+' is not on the rebind list'); });
       if(document.querySelectorAll('#keyslist .rebind').length!==KEYS_ACTS.length||document.querySelectorAll('#keyslist .keybtn').length!==KEYS_ACTS.length) bad.push('the list has '+document.querySelectorAll('#keyslist .rebind').length+' REBIND controls for '+KEYS_ACTS.length+' actions');
       b=el('#keyslist .rebind[data-k="KeyE"]');
       if(b){ b.click(); if(KEYS.waiting!=='KeyE') bad.push('REBIND did not wait for a key'); bk=el('#keyslist .keybtn[data-k="KeyE"]'); if(!bk||bk.textContent.indexOf('PRESS A KEY')<0) bad.push('the key did not say PRESS A KEY');
         dn('Escape'); if(KEYS.waiting) bad.push('ESC did not cancel the wait'); if(keysOf('KeyE')!=='KeyE') bad.push('ESC changed the binding');
         b=el('#keyslist .rebind[data-k="KeyE"]'); b.click();
         dn('KeyP'); if(keysOf('KeyE')!=='KeyE'||keyRemap('KeyP')!=='KeyP') bad.push('P was taken by an action'); if(KEYS.waiting!=='KeyE') bad.push('a reserved key ended the wait');
         dn('KeyJ'); if(keysOf('KeyE')!=='KeyJ') bad.push('a free key (J) did not bind ('+keysOf('KeyE')+')'); if(KEYS.waiting) bad.push('the wait went on after a key bound'); }
       else bad.push('there is no REBIND control for search');
       if(keysBind('KeyE','Escape')) bad.push('ESC was bindable');
       if(keysBind('KeyE','KeyP')) bad.push('P was bindable');
       b=el('#keysreset'); if(b) b.click(); else bad.push('no RESET TO DEFAULTS button');
       if(keysOf('KeyE')!=='KeyE'||keyRemap('KeyF')!=='KeyF'||Object.keys(P.keymap||{}).length) bad.push('RESET TO DEFAULTS left a binding ('+JSON.stringify(P.keymap)+')');
       try{ var mm=document.getElementById('keysmodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       // 5. a side mouse button binds and acts as its key; unbound it does nothing
       if(keyName('Mouse3')!=='MOUSE 4') bad.push('the side button is named '+keyName('Mouse3'));
       if(!keysBind('KeyH','Mouse3')) bad.push('a side mouse button could not be bound');
       g.bag.length=0; g.bag.push(nB); p.hp=50; p.healQ=0; p.prep=null; clr();
       window.dispatchEvent(new MouseEvent('mousedown',{button:3,bubbles:true,cancelable:true})); window.dispatchEvent(new MouseEvent('mouseup',{button:3,bubbles:true,cancelable:true}));
       if(!p.prep||p.prep.kind!=='heal') bad.push('the side button bound to quick heal did not heal ('+JSON.stringify(p.prep)+')');
       keysReset(); g.bag.length=0; g.bag.push(nB); p.hp=50; p.healQ=0; p.prep=null; clr();
       window.dispatchEvent(new MouseEvent('mousedown',{button:3,bubbles:true,cancelable:true})); window.dispatchEvent(new MouseEvent('mouseup',{button:3,bubbles:true,cancelable:true}));
       if(p.prep) bad.push('an unbound side button healed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=kSay; }catch(_s){}
       try{ FXS=kFXS; }catch(_fx){}   // the cosmetic stream is left where it was found, so a check after this one draws what it always drew
       try{ var m2=document.getElementById('keysmodal'); if(m2) m2.classList.remove('on'); KEYS.waiting=null; }catch(_w){}
       try{ if(km0) P.keymap=km0; else P.keymap={}; P.keymapV=kmv0; KEYS.inv=null; keysInv(); keysLegendApply(); }catch(_k){}
       try{ for(q in keys) keys[q]=false; }catch(_q){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
