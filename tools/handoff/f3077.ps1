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

if ($s.Contains("  {v:'30.77',what:")) { throw "check 30.77 is in the fixture already" }

SubRx @'
  {v:'30.76',what:
'@ @'
  {v:'30.77',what:'the player 2 window follows the last input device like any other window: the window in front plays the keys (cw-p2keys), so a key press in the player 2 window puts the key prompts up there, its pad puts the pad prompts up, a click or a real move of its mouse puts the key prompts up, and a pointer only crossing a window that has not the keyboard does not',
   run:function(){
     if(typeof INDEV!=='object'||!INDEV||typeof indevPadTick!=='function') return 'SKIP: no input device tracker in this build';
     if(typeof NET!=='object'||!NET||typeof keyLabel!=='function') return 'SKIP: no net or key label code here';
     var bad=[], pad=null, on0=PAD.on, br0=PAD.brand, lg0=INDEV.legacy, dv0=INDEV.dev, ns0=NET.same, hadHF=Object.prototype.hasOwnProperty.call(document,'hasFocus'), oHF=document.hasFocus;
     function mk(btn,ax){ var bt=[], j; for(j=0;j<17;j++) bt.push({pressed:(j===btn),value:(j===btn)?1:0,touched:(j===btn)}); return {connected:true,id:'glyph check pad',index:0,mapping:'standard',timestamp:1,buttons:bt,axes:ax||[0,0,0,0]}; }
     function key(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'F13',key:'F13',bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'F13',key:'F13',bubbles:true})); }
     function st(){ return INDEV.dev+' padOn='+padOn()+' body.padon='+document.body.classList.contains('padon')+' use='+keyLabel('KeyE','E'); }
     try{
       __runPrep(); __topClear();
       INDEV.legacy=false; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; INDEV.dev='kb'; PAD.on=true; PAD.brand='xbox'; NET.same='p2'; try{ padBodyCls(); }catch(_b0){}
       // 1. the player 2 window with a pad that is only plugged in: key prompts
       if(padOn()||keyLabel('KeyE','E')!=='E') bad.push('a pad only plugged in already shows the pad prompts in the player 2 window ('+st()+')');
       // 2. its pad is pressed: the pad prompts, in the canvas reader and in the DOM
       indevPadTick(mk(5)); try{ padBodyCls(); }catch(_b1){}
       if(INDEV.dev!=='pad'||!padOn()||keyLabel('KeyE','E')==='E'||!document.body.classList.contains('padon')) bad.push('a pad press in the player 2 window did not put the pad prompts up ('+st()+')');
       // 3. a key press in it: the key prompts, on the spot (cw-p2keys: the keys the player 2 window gets are its own)
       key();
       if(INDEV.dev!=='kb'||padOn()||keyLabel('KeyE','E')!=='E'||document.body.classList.contains('padon')) bad.push('a key press in the player 2 window left the pad prompts up ('+st()+')');
       // 4. the pad again, then a real move of the mouse in it: the key prompts
       indevPadTick(mk(-1)); indevPadTick(mk(6));
       if(INDEV.dev!=='pad') bad.push('staging: the second pad press did not put the pad prompts up ('+st()+')');
       indevMouse(300,300,2,2); indevMouse(303,301,3,1);
       if(INDEV.dev!=='pad') bad.push('3 pixels of mouse jitter in the player 2 window took the pad prompts down');
       indevMouse(360,330,57,29);
       if(INDEV.dev!=='kb'||padOn()) bad.push('a 60 pixel mouse move in the player 2 window did not put the key prompts up ('+st()+')');
       // 5. the same in the player 1 window (no pair), unchanged
       NET.same=null; indevPadTick(mk(-1)); indevPadTick(mk(7));
       if(INDEV.dev!=='pad'||!padOn()) bad.push('a pad press in the player 1 window did not put the pad prompts up');
       key();
       if(INDEV.dev!=='kb'||padOn()) bad.push('a key press in the player 1 window left the pad prompts up');
       // 6. a pointer that only crosses a window without the keyboard is not a hand on its mouse; a window with it is
       if(typeof indevMoveOk!=='function') bad.push('there is no test for a mouse move in a window without the keyboard (indevMoveOk)');
       else {
         document.hasFocus=function(){ return false; };
         if(indevMoveOk({isTrusted:true})) bad.push('a real mouse move in a window that has not the keyboard counted');
         document.hasFocus=function(){ return true; };
         if(!indevMoveOk({isTrusted:true})) bad.push('a real mouse move in a window that has the keyboard did not count');
         if(indevMoveOk({isTrusted:false})) bad.push('a mouse move the page made up counted');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(hadHF) document.hasFocus=oHF; else { try{ delete document.hasFocus; }catch(_d){} }
       keys={}; try{ padRelease(); }catch(_pr){}
       INDEV.legacy=lg0; INDEV.dev=dv0; INDEV.pb=[]; INDEV.pa=[]; INDEV.ax=null; INDEV.ay=null; INDEV.lx=null; INDEV.ly=null; NET.same=ns0;
       PAD.on=on0; PAD.brand=br0; PAD.prev=[];
       try{ padBodyCls(); }catch(_bc){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'30.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
