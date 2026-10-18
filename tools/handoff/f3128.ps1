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

if ($s.Contains("  {v:'31.28',what:")) { throw "check 31.28 is in the fixture already" }

SubRx @'
  {v:'31.27',what:
'@ @'
  {v:'31.28',what:'cw-p2prompt, his order 2026-10-18 (live key and pad prompts): the player 2 attract prompt reads the device player 2 used last, as player 1 does: after a key press it says player 2: press any key, after a press on its pad it says player 2: press a, and back to press any key on the next key; player 1 keeps press any key and press any button',
   run:function(){
     if(typeof arcadeAttShow!=='function'||typeof arcadeEnter!=='function'||typeof arcadeAttStart!=='function'||typeof ARCADE!=='object'||typeof NET!=='object'||!NET) return 'SKIP: no arcade attract in this build';
     if(typeof INDEV!=='object'||!INDEV||typeof indevPadTick!=='function'||typeof padB!=='function') return 'SKIP: no input device tracker in this build';
     var bad=[], sv=null, src0, tried0, role0, ap, on0=PAD.on, br0=PAD.brand, lg0=INDEV.legacy, dv0=INDEV.dev, oPost=netSamePost, here=false, t;
     function mk(btn){ var bt=[], j; for(j=0;j<17;j++) bt.push({pressed:(j===btn),value:(j===btn)?1:0,touched:(j===btn)}); return {connected:true,id:'p2 prompt check pad',index:0,mapping:'standard',timestamp:1,buttons:bt,axes:[0,0,0,0]}; }
     function key(){ netSamePost=function(){ return true; }; try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:'F13',key:'F13',bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'F13',key:'F13',bubbles:true})); } finally { netSamePost=oPost; } ARCADE.wantIn=0; ARCADE.askAt=0; }
     function read(){ arcadeAttShow(); ap=ATT.el?ATT.el.querySelector('.attpress'):null; return ap?String(ap.textContent).toLowerCase():'(no prompt)'; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;
       if(!arcadeEnter('host')) return 'SKIP: arcadeEnter(host) failed';
       here=true; arcadeAttStart();
       INDEV.legacy=false; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; INDEV.dev='kb'; PAD.on=true; PAD.brand='xbox';
       // player 1 (the host window), unchanged: the key words after a key, the button words after the pad
       role0=ARCADE.role; ARCADE.role='host';
       t=read(); if(t!=='press any key') bad.push('ZERO: control: player 1 with a pad only plugged in reads ['+t+'], not press any key');
       indevPadTick(mk(5)); t=read(); if(t!=='press any button') bad.push('ZERO: control: player 1 after a pad press reads ['+t+'], not press any button');
       // player 2: the same, by its own last device
       ARCADE.role='p2'; ARCADE.wantIn=0; INDEV.dev='kb'; INDEV.pb=[]; INDEV.pa=[];
       t=read(); if(t!=='player 2: press any key') bad.push('ONE: player 2 with a pad only plugged in reads ['+t+'], not player 2: press any key');
       indevPadTick(mk(5)); t=read();
       if(t!=='player 2: press a') bad.push('TWO: player 2 after a press on its pad reads ['+t+'], not player 2: press a');
       key(); t=read();
       if(t!=='player 2: press any key') bad.push('THREE: player 2 after a key press reads ['+t+'], not player 2: press any key');
       indevPadTick(mk(-1)); indevPadTick(mk(6)); t=read();
       if(t!=='player 2: press a') bad.push('FOUR: player 2 after its pad again reads ['+t+'], not player 2: press a');
       PAD.brand='ps'; t=read();
       if(t!==('player 2: press '+padB('A')).toLowerCase()) bad.push('FIVE: player 2 on a PlayStation pad reads ['+t+'], not the pad name for A ('+padB('A').toLowerCase()+')');
       PAD.brand='xbox';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSamePost=oPost;
       try{ if(role0!==undefined) ARCADE.role=role0; ARCADE.wantIn=0; ARCADE.askAt=0; ARCADE.scSeen=0; ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; }catch(_r){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; ATT.src=src0; ATT.tried=tried0; } }catch(_n){}
       try{ INDEV.legacy=lg0; INDEV.dev=dv0; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; PAD.on=on0; PAD.brand=br0; PAD.prev=[]; padBodyCls(); }catch(_i){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
