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

if ($s.Contains("  {v:'30.75',what:")) { throw "check 30.75 is in the fixture already" }

SubRx @'
  {v:'30.74',what:
'@ @'
  {v:'30.75',what:'the arcade and Undercroft prompts that named both devices follow the last input device: press any key or press any button on the attract and the idle callouts, Y yes and N no or A yes and B no on the easy mode question, the initials hint on the card and in the raid, and T or Y on a trade offer (his order: Fortnite style real time glyph switching)',
   run:function(){
     if(typeof INDEV!=='object'||!INDEV||typeof indevSet!=='function') return 'SKIP: no input device tracker in this build';
     if(typeof easyHud!=='function'||typeof arcadeIniHud!=='function'||typeof arcadeIniDraw!=='function'||typeof arcadeAttShow!=='function'||typeof arcadeIdleTick!=='function'||typeof drawHubGiftLine!=='function'||typeof netHubGiftTake!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: no arcade or Undercroft prompt code here';
     var bad=[], seen=[], lines=[], sv={}, ak=['on','solo','role','deaths','ext','easy','easyAsk','easyAsked','ini','over','ownAt','mateAt','idleSaid'], k, g, gA, c, q, ap, t1, t2, t3, now, r, peer,
         on0=PAD.on, br0=PAD.brand, lg0=INDEV.legacy, dv0=INDEV.dev, ns0=NET.same, hg0=NET.hg, nOn0=NET.on, nUp0=NET.up, oSay=say, oSay2=say2,
         hadT=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText;
     function kb(){ PAD.on=true; PAD.brand='xbox'; indevSet('kb'); }
     function pd(){ PAD.on=true; PAD.brand='xbox'; indevSet('pad'); }
     function key(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'F13',key:'F13',bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'F13',key:'F13',bubbles:true})); }
     function cap(fn){ seen=[]; ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); }; try{ fn(); }catch(_h){ seen.push('threw '+(_h&&_h.message||_h)); } if(hadT) ctx.fillText=oFT; else delete ctx.fillText; return seen.join(' | ').toLowerCase(); }
     function ini(){ return document.querySelector('#attract .arcover .aoq'); }
     function last(){ return lines.length?lines[lines.length-1]:''; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       INDEV.legacy=false; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; NET.same=null; kb();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       for(k=0;k<ak.length;k++) sv[ak[k]]=ARCADE[ak[k]];
       gA=g.arcade; say=function(){};
       // 1. the easy mode question: Y yes N no on the keyboard, A yes B no on the pad, never both at once
       ARCADE.on=1; ARCADE.solo=0; ARCADE.easy=0; ARCADE.easyAsk=null; ARCADE.easyAsked=0; ARCADE.ext=0; ARCADE.deaths=2; g.arcade=1;
       if(!easyAskMaybe('dead')||!easyLive()) return 'SKIP: staging: the easy mode question did not come up';
       kb(); t1=cap(easyHud);
       if(padOn()) bad.push('staging: the pad prompts are up for the keyboard');
       if(!/\by yes\b/.test(t1)||!/\bn no\b/.test(t1)) bad.push('with the keyboard in use the easy mode card reads "'+t1+'", not Y yes and N no');
       if(/\ba yes\b|\bb no\b|\by or a\b|\bn or b\b/.test(t1)) bad.push('with the keyboard in use the easy mode card still names the pad buttons: "'+t1+'"');
       pd(); t2=cap(easyHud);
       if(!padOn()) bad.push('staging: the pad prompts are not up for the pad');
       if(!/\ba yes\b/.test(t2)||!/\bb no\b/.test(t2)) bad.push('with the pad in use the easy mode card reads "'+t2+'", not A yes and B no');
       if(/\by yes\b|\bn no\b|\by or a\b|\bn or b\b/.test(t2)) bad.push('with the pad in use the easy mode card still names the keys: "'+t2+'"');
       ARCADE.easyAsk=null;
       // 2. the initials card in the raid (canvas)
       ARCADE.ini={run:'zz',raid:1,l:['A','B','C'],pos:1,at:Date.now(),touched:0,mirror:0,who:1};
       if(!arcadeIniRaid()) return 'SKIP: staging: the initials card is not live in the raid';
       kb(); t1=cap(arcadeIniHud);
       if(!/enter done/.test(t1)||!/backspace back/.test(t1)) bad.push('with the keyboard in use the initials card in the raid reads "'+t1+'", not the keys Enter and Backspace');
       if(/menu|a next|\bb back/.test(t1)) bad.push('with the keyboard in use the initials card in the raid still names pad buttons: "'+t1+'"');
       pd(); t2=cap(arcadeIniHud);
       if(!/a next/.test(t2)||!/b back/.test(t2)||!/menu done/.test(t2)) bad.push('with the pad in use the initials card in the raid reads "'+t2+'", not the pad buttons');
       if(/enter done|backspace|space next/.test(t2)) bad.push('with the pad in use the initials card in the raid still names keys: "'+t2+'"');
       ARCADE.ini=null; g.arcade=gA;
       // 3. the initials card on the attract (DOM): built with the hint of the device in use, and the hint changes in place when the device does
       kb(); c=document.createElement('div'); arcadeIniDraw(c,{l:['A','B','C'],pos:1,who:1}); q=c.querySelector('.aoq'); t1=q?q.textContent.toLowerCase():'nothing';
       pd(); c=document.createElement('div'); arcadeIniDraw(c,{l:['A','B','C'],pos:1,who:1}); q=c.querySelector('.aoq'); t2=q?q.textContent.toLowerCase():'nothing';
       if(!/enter done/.test(t1)||/menu/.test(t1)) bad.push('a card built with the keyboard in use reads "'+t1+'"');
       if(!/menu done/.test(t2)||/enter/.test(t2)) bad.push('a card built with the pad in use reads "'+t2+'"');
       ARCADE.on=1; ARCADE.over=null; ARCADE.ini={run:'zz',l:['A','B','C'],pos:1,at:Date.now(),touched:0,mirror:1,who:1};
       kb(); r=arcadeOverSync();
       if(!r||!ini()) bad.push('staging: the initials card did not come up on the attract');
       else {
         t1=ini().textContent.toLowerCase();
         pd(); arcadeOverSync(); t2=ini()?ini().textContent.toLowerCase():'nothing';
         key(); arcadeOverSync(); t3=ini()?ini().textContent.toLowerCase():'nothing';
         if(INDEV.dev!=='kb') bad.push('a key press left the pad as the last device');
         if(!/enter done/.test(t1)) bad.push('the open initials card reads "'+t1+'" with the keyboard in use');
         if(!/menu done/.test(t2)||/enter/.test(t2)) bad.push('the open initials card reads "'+t2+'" after the pad took over, it did not follow');
         if(!/enter done/.test(t3)||/menu/.test(t3)) bad.push('the open initials card reads "'+t3+'" after a key press, it did not follow back');
       }
       ARCADE.ini=null; try{ arcadeOverSync(); }catch(_o){}
       // 4. the trade offer the taker sees in the Undercroft: one key
       peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}};
       say2=function(m){ lines.push(String(m)); };
       NET.hg={in:{id:'q',k:'frag',from:1,t:Date.now()}};
       kb(); t1=String(drawHubGiftLine()||'');
       pd(); t2=String(drawHubGiftLine()||'');
       if(!/ t to take it/i.test(t1)||/ or /.test(t1)) bad.push('the offer line reads "'+t1+'" with the keyboard in use, not one key T');
       if(!/ y to take it/i.test(t2)||/ or /.test(t2)) bad.push('the offer line reads "'+t2+'" with the pad in use, not one key Y');
       NET.hg=null; kb(); lines=[]; netHubGiftTake(peer,{t:'gift',op:'offer',id:'q1',k:'frag',hub:1,from:1},1); t1=last();
       NET.hg=null; pd(); lines=[]; netHubGiftTake(peer,{t:'gift',op:'offer',id:'q2',k:'frag',hub:1,from:1},1); t2=last();
       if(!/press t to take it/i.test(t1)) bad.push('the offer message reads "'+t1+'" with the keyboard in use');
       if(!/press y to take it/i.test(t2)) bad.push('the offer message reads "'+t2+'" with the pad in use');
       NET.hg=hg0; say2=oSay2;
       // 5. the arcade: the idle callouts and the attract
       for(k=0;k<ak.length;k++) ARCADE[ak[k]]=sv[ak[k]];
       g.arcade=gA; try{ __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep(); INDEV.legacy=false; NET.same=null; kb();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.mateAt=0; now=Date.now();
       say=function(m,kk,o){ lines.push(String(m)+'|'+String(kk||'')+'|'+String((o&&o.sub)||'')); };
       kb(); lines=[]; ARCADE.idleSaid=0; ARCADE.ownAt=now-91000; arcadeIdleTick(now); t1=last();
       pd(); lines=[]; ARCADE.idleSaid=0; ARCADE.ownAt=now-91000; arcadeIdleTick(now); t2=last();
       if(t1.toLowerCase()!=='still playing?|warn|press any key') bad.push('the idle question reads "'+t1+'" with the keyboard in use');
       if(t2.toLowerCase()!=='still playing?|warn|press any button') bad.push('the idle question reads "'+t2+'" with the pad in use');
       kb(); lines=[]; ARCADE.idleSaid=0; ARCADE.ownAt=now-125000; arcadeIdleTick(now); t1=last();
       pd(); lines=[]; ARCADE.idleSaid=0; ARCADE.ownAt=now-125000; arcadeIdleTick(now); t2=last();
       if(t1.toLowerCase()!=='run ends in 25|warn|press any key') bad.push('the run ends callout reads "'+t1+'" with the keyboard in use');
       if(t2.toLowerCase()!=='run ends in 25|warn|press any button') bad.push('the run ends callout reads "'+t2+'" with the pad in use');
       // player 1 idle while player 2 plays: benched under the attract that says what presses
       kb(); ARCADE.ownAt=now;
       NET.on=true; NET.up=[{seat:(NET.seat|0)+1,x:g.player.x+80,y:g.player.y,dn:0}];
       ARCADE.mateAt=now; ARCADE.ownAt=now-151000; r=arcadeIdleTick(now);
       NET.on=nOn0; NET.up=nUp0;
       ap=attEl().querySelector('.attpress');
       if(r!=='bench'||!g.player.specOut||!ap) bad.push('staging: player 1 was not benched under the attract ('+r+')');
       else {
         t1=ap.textContent;
         pd(); arcadeAttShow(); t2=ap.textContent;
         kb(); arcadeAttShow(); t3=ap.textContent;
         if(t1.toLowerCase()!=='player 1: press any key') bad.push('the bench attract reads "'+t1+'" with the keyboard in use');
         if(t2.toLowerCase()!=='player 1: press any button') bad.push('the bench attract reads "'+t2+'" after the pad took over');
         if(t3.toLowerCase()!=='player 1: press any key') bad.push('the bench attract reads "'+t3+'" after a key press');
         g.player.specOut=0; try{ attStop(); }catch(_as){}
         kb(); arcadeAttShow(); t1=ap.textContent;
         pd(); arcadeAttShow(); t2=ap.textContent;
         if(t1.toLowerCase()!=='press any key') bad.push('the attract reads "'+t1+'" with the keyboard in use');
         if(t2.toLowerCase()!=='press any button') bad.push('the attract reads "'+t2+'" with the pad in use');
         try{ attStop(); }catch(_as2){}
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadT) ctx.fillText=oFT; else delete ctx.fillText;
       say=oSay; say2=oSay2; NET.hg=hg0; NET.on=nOn0; NET.up=nUp0;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.ini=null; arcadeOverSync(); }catch(_o2){}
       __topClear(); keys={};
       INDEV.legacy=lg0; INDEV.dev=dv0; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; NET.same=ns0;
       PAD.on=on0; PAD.brand=br0; PAD.prev=[];
       try{ padBodyCls(); }catch(_bc){}
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'30.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
