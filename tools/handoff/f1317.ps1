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

# v13.17 CHECK, inserted before the v13.16 entry.
#
# IT PRESSES THE REAL KEY, dispatched on window ONLY. Dispatching on window and
# document doubles every press and broke a correct control at v11.28.
#
# IT DOES NOT TOUCH ESCAPE. A synthetic Escape is a known bad instrument in this
# file: it runs before the v11.04 closer, so it opens the box it then shuts. B is
# a new key with no such history, which is the one thing that makes this testable.
#
# THE LAST ARM IS THE ONE THAT MATTERS. B with nothing open must NOT raise the
# pause box and must leave the merc order alone, or a key meant to get him out of
# a menu becomes a key that puts him in one.
SubRx @'
  {v:'13.16',what:'a looted armour plate does not turn itself into armour: the bar does not move, the plate is in the backpack, the tactical belt offers it, and only the wind-up puts it on the bar (his note of 2026-09-12)',
'@ @'
  {v:'13.17',what:'B backs out of whatever is in front, in the Undercroft and in a raid, and a B with nothing open does not raise the pause box (his note of 2026-09-12, since Escape is not working for him)',
   run:function(){
     if(typeof backOut!=='function')
       return 'there is no back-out key in this build at all, so B answers nothing and every menu still depends on the key he says is not working for him';
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ try{ var K=__keysRef(); for(var kk in K) K[kk]=false; }catch(_){} }
     // ON WINDOW ONLY. window plus document doubles every press (v11.28).
     function pressB(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyB',bubbles:true})); }
     function paused(){ var el=document.getElementById('pausebox'); return !!(el&&el.classList.contains('on')); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       keysOff(); frames(4);

       // THE RAID BACKPACK.
       var g=__state(); g.mapOpen=false; g.bagOpen=true; g.drag={fake:1};
       pressB(); frames(2);
       var s1=__state();
       if(s1.bagOpen) bad.push('B does not close the backpack in a raid, which is the menu he is most often trying to get out of');
       if(s1.drag) bad.push('B closes the backpack and leaves a held drag behind, so the item he was carrying is stuck to the cursor');

       // THE MAP IS IN FRONT OF THE BACKPACK, same order Escape uses.
       var g2=__state(); g2.bagOpen=true; g2.mapOpen=true;
       pressB(); frames(2);
       var s2=__state();
       if(s2.mapOpen) bad.push('B does not close the map');
       if(!s2.bagOpen) bad.push('B closed the map AND the backpack under it in one press, so one key ate two menus');
       g2.bagOpen=false; g2.mapOpen=false;

       // B WITH NOTHING OPEN MUST NOT PAUSE. This is the arm that matters: a key
       // meant to get him OUT of a menu must never put him into one.
       try{ togglePauseBox(false); }catch(_tp){}
       keysOff(); frames(2);
       pressB(); frames(2);
       if(paused()) bad.push('B with nothing open raises the pause box, so the key he was given to escape a menu opens a menu instead');
       try{ togglePauseBox(false); }catch(_tp2){}
       try{ var ge=__state(); if(ge&&!ge.over){ ge.player.downed=false; __endRaid('abandon'); } }catch(_e1){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_g1){}

       // AND ON THE FLOOR: a window in front of everything.
       frames(2);
       try{ openModal('settingsmodal'); }catch(_om){}
       if(document.querySelectorAll('.modal.on').length){
         pressB();
         if(document.querySelectorAll('.modal.on').length)
           bad.push('B does not close an open window in the Undercroft, so every menu down there still needs the key he says is not working');
       }
       try{ var ms=document.querySelectorAll('.modal.on'); for(var mi=0;mi<ms.length;mi++) ms[mi].classList.remove('on'); }catch(_mc){}
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       keysOff();
       try{ togglePauseBox(false); }catch(_p){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.16',what:'a looted armour plate does not turn itself into armour: the bar does not move, the plate is in the backpack, the tactical belt offers it, and only the wind-up puts it on the bar (his note of 2026-09-12)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
