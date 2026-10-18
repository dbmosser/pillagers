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

if ($s.Contains("  {v:'30.68',what:")) { throw "check 30.68 is in the fixture already" }

SubRx @'
  {v:'30.67',what:
'@ @'
  {v:'30.68',what:'the window in front plays the keyboard as its own player (his order: keys control whatever screen is to the top): a key pressed in the player 2 window is not handed to player 1 and lands in its own keys, a key held there is let go when it loses focus with nothing handed up, a key there asks to drop player 2 into the arcade like A, and its mouse takes the crosshair back from its pad once it is in front',
   run:function(){
     if(typeof netKeyFwd!=='function'||typeof netSamePost!=='function'||typeof netKeyLetGo!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no player 2 window here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var NK={}, k, bad=[], oPost=netSamePost, posts=[], k0=keys, m0=null, co0=null, ar0=null, hf=false, w, rc;
     function words(t){ return posts.filter(function(m){ return m&&m.t===t; }).length; }
     function key(ty,code){ window.dispatchEvent(new KeyboardEvent(ty,{code:code,key:code.replace(/^Key/,'').toLowerCase(),bubbles:true,cancelable:true})); }
     function front(on){ Object.defineProperty(document,'hasFocus',{value:function(){ return on; },configurable:true}); hf=true; }
     for(k in NET) NK[k]=NET[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       keys={}; netKeyHeld={};
       netSamePost=function(m){ posts.push(JSON.parse(JSON.stringify(m))); return true; };
       NET.same='p2'; NET.pair='zqxp2keys';
       // THE KEYBOARD IS PLAYED HERE: W and Shift pressed in the player 2 window are not handed to player 1 and land in this window own keys
       key('keydown','KeyW'); key('keydown','ShiftLeft');
       if(words('key')) bad.push('the player 2 window handed '+words('key')+' key words to player 1 instead of playing the keys itself');
       if(!keys.KeyW) bad.push('W pressed in the player 2 window did not land in its own keys, so player 2 cannot walk from the keyboard');
       if(!keys.ShiftLeft) bad.push('Shift pressed in the player 2 window did not land in its own keys');
       // LET GO WHEN IT LOSES FOCUS: the window blur lets go of the keys held here and hands nothing up to player 1
       posts.length=0; window.dispatchEvent(new Event('blur'));
       if(keys.KeyW||keys.ShiftLeft) bad.push('W or Shift stayed down in the player 2 window after it lost focus, so player 2 keeps walking after a click on the other window');
       if(words('key')) bad.push('the player 2 window lost focus and handed '+words('key')+' key words up to player 1');
       // THE ARCADE ATTRACT: a plain key asks to drop in like A, F11 and Ctrl chords do not
       if(typeof arcadeKeyAtt==='function'&&typeof ARCADE==='object'&&ARCADE){
         ar0={on:ARCADE.on,role:ARCADE.role,wantIn:ARCADE.wantIn,late:ARCADE.late,askAt:ARCADE.askAt};
         ARCADE.on=true; ARCADE.role='p2'; ARCADE.wantIn=0; ARCADE.late=0; ARCADE.askAt=0; posts.length=0;
         w=function(code,ctrl){ return {type:'keydown',code:code,key:code,repeat:false,ctrlKey:!!ctrl,altKey:false,metaKey:false,preventDefault:function(){},stopImmediatePropagation:function(){}}; };
         arcadeKeyAtt(w('F11'));
         if(words('arcjoin')||ARCADE.wantIn) bad.push('F11 in the player 2 window asked to drop player 2 into the arcade');
         arcadeKeyAtt(w('KeyW'));
         if(words('arcjoin')!==1||ARCADE.wantIn!==1) bad.push('a key in the player 2 window on the arcade attract did not ask to drop player 2 in like A does ('+words('arcjoin')+' words, wantIn '+ARCADE.wantIn+')');
         ARCADE.on=ar0.on; ARCADE.role=ar0.role; ARCADE.wantIn=ar0.wantIn; ARCADE.late=ar0.late; ARCADE.askAt=ar0.askAt; ar0=null;   // the arcade attract takes a click for itself, so it is put back before the mouse is tried
       }
       // THE MOUSE: in front it takes the crosshair back from this window pad; a pointer crossing a window not in front leaves the pad crosshair
       if(typeof PAD==='object'&&PAD&&typeof cv!=='undefined'&&cv){
         m0={x:mouse.x,y:mouse.y,down:mouse.down}; co0=PAD.curOwn;
         front(false); PAD.curOwn=1;
         cv.dispatchEvent(new MouseEvent('mousemove',{clientX:50,clientY:60,bubbles:true}));
         if(PAD.curOwn!==1) bad.push('a pointer crossing the player 2 window while it was not in front took the crosshair from its pad');
         front(true);
         cv.dispatchEvent(new MouseEvent('mousemove',{clientX:52,clientY:62,bubbles:true}));
         if(PAD.curOwn) bad.push('the mouse moving over the player 2 window in front did not take the crosshair back from its pad, so the mouse cannot aim there');
         front(false); PAD.curOwn=1;
         rc=cv.getBoundingClientRect();
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,clientX:rc.left+rc.width*0.5,clientY:rc.top+rc.height*0.5,bubbles:true}));
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(PAD.curOwn) bad.push('a click in the player 2 window did not take the crosshair from its pad');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSamePost=oPost; keys=k0||{}; netKeyHeld={};
       if(hf){ try{ delete document.hasFocus; }catch(_hf){} }
       if(ar0){ ARCADE.on=ar0.on; ARCADE.role=ar0.role; ARCADE.wantIn=ar0.wantIn; ARCADE.late=ar0.late; ARCADE.askAt=ar0.askAt; }
       if(m0){ mouse.x=m0.x; mouse.y=m0.y; mouse.down=m0.down; PAD.curOwn=co0; }
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
