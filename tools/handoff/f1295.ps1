$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.95 CHECK, inserted before the v12.94 entry.
#
# IT PRESSES THE REAL KEYS through the real listener, on window only, and clears the
# key table first: window plus document doubles every press, and a latched key from
# an earlier check has made a correct control look broken twice.
#
# EVERY ARM IS PAIRED WITH ITS OWN CONTROL, in the same run: each key is pressed
# once with the box up and once with it down, and the box-down press is required to
# WORK. A lockout that simply broke these keys for everybody would pass a check that
# only tested the paused half.
#
# ESC IS NOT USED TO RAISE OR LOWER THE BOX HERE. togglePauseBox is called directly,
# because a synthetic ESC on window reaches the main listener before the v11.04
# Escape closer and the two undo each other in one press. P is used for the closing
# control, which does not have that problem.
SubRx @'
  {v:'12.94',what:'going down inside a landed extraction
'@ @'
  {v:'12.95',what:'the Undercroft pause box owns the keyboard: SPACE stores no roll, TAB and I do not open the backpack underneath it, H does not flip the controls panel and ENTER does not spend the unread update card, while P still closes the box and every one of those keys still works with the box down (audit finding 10, 2026-09-11, the floor twin of v12.22)',
   run:function(){
     if(!(window.__hubEnter&&window.__hub&&window.__hubP&&window.__keysRef&&window.__hubBag))
       return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof togglePauseBox!=='function') return 'SKIP: this build has no pause box to raise';
     var pb=document.getElementById('pausebox');
     if(!pb) return 'SKIP: this build has no pause box element';
     var bad=[];
     function tap(c){
       var K=__keysRef(); for(var k in K) K[k]=false;
       window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true}));
     }
     function boxUp(){ return pb.classList.contains('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __hubEnter();
       var HBx=__hub();
       if(!HBx||!HBx.player) return 'SKIP: the floor has no walking character to test';
       // Each key: once with the box up, which must do nothing, and once with it
       // down, which must do the thing. The second half is the control.
       function paired(code,read,reset){
         reset();
         togglePauseBox(true);
         if(!boxUp()){ bad.push('control: the pause box would not open on the floor, so nothing here is being tested'); return; }
         tap(code);
         var whilePaused=read();
         togglePauseBox(false); pb.classList.remove('on');
         reset();
         tap(code);
         var whileFree=read();
         reset();
         return {paused:whilePaused,free:whileFree};
       }
       // SPACE: a roll stored behind the box is spent the instant he closes it, so
       // his character dodge-rolls out of nothing on resume.
       var r=paired('Space',function(){ return (__hubP()&&__hubP().rollT)||0; },
                    function(){ var q=__hubP(); if(q){ q.rollT=0; } });
       if(r){
         if(r.paused>0) bad.push('SPACE while the pause box is up stores a roll, and the floor is frozen so it is not spent until he closes the box: his character dodge-rolls out of nothing the moment the game resumes');
         if(!(r.free>0)) bad.push('control: with the box down SPACE no longer rolls at all, so the key has been taken away rather than held back');
       }
       // TAB and I: the backpack opens invisibly under a 90 percent overlay, so
       // closing the box reveals a backpack he never opened.
       var _bagKeys=['Tab','KeyI'], bi;
       for(bi=0;bi<_bagKeys.length;bi++){
         var rb=paired(_bagKeys[bi],function(){ return !!__hubBag(); },function(){ __hubBag(false); });
         if(rb){
           if(rb.paused) bad.push('['+_bagKeys[bi]+'] while the pause box is up opens the backpack underneath it, so closing the box reveals a backpack he never saw open');
           if(!rb.free) bad.push('control: with the box down ['+_bagKeys[bi]+'] no longer opens the backpack');
         }
       }
       // H: the controls panel flips under the box.
       var rh=paired('KeyH',function(){ return !!(__hub()&&__hub().legend); },
                     function(){ var q=__hub(); if(q) q.legend=false; });
       if(rh){
         if(rh.paused) bad.push('H while the pause box is up flips the controls panel behind it');
         if(!rh.free) bad.push('control: with the box down H no longer shows the controls');
       }
       // ENTER: the unread update card behind the box is spent. Only a returning
       // player has one, because a profile with no runs has it stamped seen.
       if(typeof WNSEEN!=='undefined'){
         var re=paired('Enter',function(){ return !!WNSEEN; },function(){ WNSEEN=0; });
         if(re){
           if(re.paused) bad.push('ENTER while the pause box is up marks the update card read, and the card is behind the box, so he never sees what he has just thrown away');
           if(!re.free) bad.push('control: with the box down ENTER no longer dismisses the update card');
         }
         try{ WNSEEN=1; }catch(_w){}
       }
       // CONTROL: P STILL CLOSES THE BOX. A lockout that stopped its own two keys
       // would leave him unable to unpause.
       togglePauseBox(true);
       if(boxUp()){
         tap('KeyP');
         if(boxUp()) bad.push('control: with the box up P no longer closes it, so the lockout has taken the two keys the box itself names');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(pb.classList.contains('on')){ togglePauseBox(false); pb.classList.remove('on'); } }catch(_b){}
       try{ __hubBag(false); var q2=__hub(); if(q2){ q2.legend=false; if(q2.player) q2.player.rollT=0; } }catch(_h){}
       try{ var K2=__keysRef(); for(var k2 in K2) K2[k2]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.94',what:'going down inside a landed extraction
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
