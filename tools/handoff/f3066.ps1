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

if ($s.Contains("  {v:'30.66',what:")) { throw "check 30.66 is in the fixture already" }

SubRx @'
  {v:'30.65',what:
'@ @'
  {v:'30.66',what:'prompts follow the last input device in real time: a key press puts the key prompts up, a pad button or stick puts the pad prompts up, a pad that is only plugged in or drifting changes nothing, in the raid hint and the DOM hints (his order: Fortnite style glyph switching)',
   run:function(){
     if(typeof INDEV!=='object'||!INDEV||typeof indevPadTick!=='function') return 'prompts do not follow the last input device (no INDEV tracker)';
     if(typeof pollPad!=='function'||typeof drawHUD!=='function'||typeof PAD!=='object'||!PAD||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: no pad or raid code here';
     var NG=navigator.getGamepads, ownNG=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), pad=null, bad=[], g, seen=[], t1, t2, t3, t4, cs,
         on0=PAD.on, br0=PAD.brand, an0=PAD.announced, mx0=mouse.x, my0=mouse.y, lg0=INDEV.legacy, dv0=INDEV.dev, ns0=NET.same,
         hadT=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText;
     function mk(btn,ax){ var bt=[], j; for(j=0;j<17;j++) bt.push({pressed:(j===btn),value:(j===btn)?1:0,touched:(j===btn)}); return {connected:true,id:'glyph check pad',index:0,mapping:'standard',timestamp:1,buttons:bt,axes:ax||[0,0,0,0]}; }
     function poll(btn,ax){ pad=mk(btn,ax); pollPad(); }
     function key(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'F13',key:'F13',bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'F13',key:'F13',bubbles:true})); }
     function st(){ return INDEV.dev+' padOn='+padOn()+' body.padon='+document.body.classList.contains('padon'); }
     function grab(){ seen=[]; ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); }; try{ drawHUD(); }catch(_h){} if(hadT) ctx.fillText=oFT; else delete ctx.fillText; return seen.filter(function(s){ return /backpack$/i.test(s); }).join('|').toLowerCase(); }
     function strip(){ var m=document.getElementById('settingsmodal'), c; if(!m) return 'nomodal'; c=getComputedStyle(m,'::after').content; return String(c).replace(/["']/g,'').replace(/\s+/g,' ').toLowerCase(); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       INDEV.legacy=false; INDEV.dev='kb'; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; NET.same=null; PAD.announced=true;
       navigator.getGamepads=function(){ return [pad]; };
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       g.player.roll=0; g.player.downed=false; g.bagOpen=false; g.mapOpen=false; g.trade=null; g.searching=null; mouse.x=Math.round(W*0.5); mouse.y=Math.round(H*0.4);
       // 1. a pad that is only plugged in: nothing changes
       poll(-1);
       if(!PAD.on) return 'SKIP: staging: the stub pad did not come on';
       t1=grab(); cs=strip();
       if(st()!=='kb padOn=false body.padon=false') bad.push('a pad that is only plugged in already shows the pad prompts ('+st()+')');
       if(keyLabel('KeyE','E')!=='E') bad.push('the use key reads '+keyLabel('KeyE','E')+' with the pad only plugged in');
       if(/view/.test(t1)||!/b \/ i/.test(t1)) bad.push('the raid backpack hint reads "'+t1+'" with the pad only plugged in, not B / I');
       if(/a\s+change/.test(cs)) bad.push('the settings hint strip reads "'+cs+'" with the pad only plugged in');
       // 2. a pad button press: the pad prompts, at once, in the raid and in the DOM
       poll(5);
       t2=grab(); cs=strip();
       if(st()!=='pad padOn=true body.padon=true') bad.push('a pad button press did not put the pad prompts up ('+st()+')');
       if(keyLabel('KeyE','E')==='E') bad.push('the use key still reads E after a pad press');
       if(!/view/.test(t2)) bad.push('the raid backpack hint reads "'+t2+'" after a pad press, not VIEW');
       if(!/a\s+change/.test(cs)) bad.push('the settings hint strip reads "'+cs+'" after a pad press, not the pad buttons');
       // 3. a key press: the key prompts, on the very next frame, and the pad button still held does not take them back
       key();
       if(st()!=='kb padOn=false body.padon=false') bad.push('a key press did not take the pad prompts down ('+st()+')');
       poll(5);
       if(INDEV.dev!=='kb') bad.push('a pad button held down since before the key press took the key prompts back');
       t3=grab(); cs=strip();
       if(t3!==t1) bad.push('the raid backpack hint reads "'+t3+'" after a key press, it read "'+t1+'" before');
       if(/a\s+change/.test(cs)) bad.push('the settings hint strip reads "'+cs+'" after a key press');
       // 4. drift never flips; a real stick push does; a stick held where it is does not flip back after a key
       poll(-1,[0.22,-0.18,0.15,0.1]);
       if(INDEV.dev!=='kb') bad.push('stick drift put the pad prompts up');
       poll(-1,[0,0,0.9,0]);
       if(INDEV.dev!=='pad') bad.push('a stick push did not put the pad prompts up');
       key(); poll(-1,[0,0,0.9,0]);
       if(INDEV.dev!=='kb') bad.push('a stick held in place took the key prompts back after a key press');
       poll(-1,[0,0,0,0]); poll(-1,[0,0,0,0.8]);
       if(INDEV.dev!=='pad') bad.push('the other stick did not put the pad prompts up');
       // 5. the mouse: jitter is ignored, a real move and a click win; made up and pad made events do not
       INDEV.ax=300; INDEV.ay=300; indevMouse(300,300,0,0);
       if(INDEV.dev!=='pad') bad.push('a mouse event with no move took the pad prompts down');
       indevMouse(303,301,3,1);
       if(INDEV.dev!=='pad') bad.push('3 pixels of mouse jitter took the pad prompts down');
       window.dispatchEvent(new MouseEvent('mousemove',{clientX:900,clientY:700,bubbles:true}));
       window.dispatchEvent(new MouseEvent('mousedown',{clientX:900,clientY:700,button:0,bubbles:true}));
       if(INDEV.dev!=='pad') bad.push('a mouse event the page made up took the pad prompts down');
       indevMouse(340,320,40,20);
       if(INDEV.dev!=='kb') bad.push('a 40 pixel mouse move did not put the key prompts up');
       // 6. the player 2 window has no keyboard or mouse of its own: it keeps the pad prompts
       indevSet('kb'); NET.same='p2';
       key();
       if(INDEV.dev!=='kb'||!padOn()) bad.push('the player 2 window lost its pad prompts ('+st()+')');
       NET.same=null;
       if(padOn()) bad.push('the pad prompts stayed up after leaving the player 2 window');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadT) ctx.fillText=oFT; else delete ctx.fillText;
       if(ownNG) navigator.getGamepads=NG; else { try{ delete navigator.getGamepads; }catch(_d){} if(navigator.getGamepads!==NG) navigator.getGamepads=NG; }
       keys={}; try{ padRelease(); }catch(_pr){}
       INDEV.legacy=lg0; INDEV.dev=dv0; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; NET.same=ns0;
       PAD.on=on0; PAD.brand=br0; PAD.announced=an0; PAD.prev=[]; mouse.x=mx0; mouse.y=my0;
       try{ padBodyCls(); }catch(_bc){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'30.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
