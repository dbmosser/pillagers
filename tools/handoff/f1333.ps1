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

# v13.33 CHECK, inserted before the v13.32 entry.
#
# ON THE PLAY PATH FOR TIME: it starts a real raid, shows a message with say(), queues
# two lines behind it, and steps the real frame loop, __loop, for about twelve seconds,
# recording every message shown. All three must appear, in order, none lost. On v13.32
# there is no sayWhenFree, so the check drives the old path the rival warning used, a
# plain say() for each line in the same moment, and the first two are lost.
SubRx @'
  {v:'13.32',what:'the quick ascent, which skips the sector page, tells a player who lands with a loaner that his own gun waits in his stash and how to take it, after the weather line rather than over it, and only when his stash holds a gun and nothing of his own is equipped',
'@ @'
  {v:'13.33',what:'a line that must not be lost waits its turn: with a message showing, two more queued behind it are each shown when the one before runs out, in order and none written over, which is how the rival warning and the loaner line reach the player',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__loop&&window.__showScreen)) return 'SKIP: this fixture cannot start a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof startRaid!=='function'||typeof say!=='function') return 'SKIP: this build has no raid to start or no message line';
     var bad=[];
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       startRaid();
       var G2=__state(); if(!G2||G2.over||G2.sim) return 'SKIP: staging: no live raid started';
       var t0=performance.now(), f=0, i;
       // Let landing say what it says, so the queue starts empty.
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }
       G2.msgQ=[]; G2.msgT=0;
       var L1=['first','line','of','three'].join(' '), L2=['second','line','of','three'].join(' '), L3=['third','line','of','three'].join(' ');
       say(L1);
       if(typeof sayWhenFree==='function'){ sayWhenFree(L2); sayWhenFree(L3); }
       else { say(L2); say(L3); }   // v13.32 and earlier: the direct say the rival warning used
       var seen=[];
       function note(){ var g=__state(); if(g&&g.msg&&(seen.length===0||seen[seen.length-1]!==g.msg)) seen.push(String(g.msg)); }
       note();
       for(i=0;i<720;i++){ __loop(t0+(++f)*16.7); note(); }
       var order=[L1,L2,L3].map(function(l){ return seen.indexOf(l); });
       if(order[0]<0) bad.push('the line shown first was never on screen');
       if(order[1]<0) bad.push('a second line said while the first was showing was written over and never shown [shown: '+seen.join(' | ').slice(0,200)+']');
       if(order[2]<0) bad.push('a third line queued behind the second was lost [shown: '+seen.join(' | ').slice(0,200)+']');
       if(order[0]>=0&&order[1]>=0&&order[2]>=0&&!(order[0]<order[1]&&order[1]<order[2]))
         bad.push('the queued lines were shown out of order ['+seen.join(' | ').slice(0,200)+']');
       // CONTROL: with nothing showing, sayWhenFree says at once rather than waiting.
       if(typeof sayWhenFree==='function'){
         G2.msgQ=[]; G2.msgT=0;
         var L4=['said','at','once'].join(' ');
         sayWhenFree(L4);
         if(__state().msg!==L4) bad.push('control: with nothing showing, a line through the queue was held back instead of said at once');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.32',what:'the quick ascent, which skips the sector page, tells a player who lands with a loaner that his own gun waits in his stash and how to take it, after the weather line rather than over it, and only when his stash holds a gun and nothing of his own is equipped',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
