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

# v12.89 CHECK, inserted before the v12.88 entry.
#
# IT PRESSES THE REAL KEYS. Synthetic keydown on window ONLY, because the pane
# delivers no real keypresses while it is hidden and because window plus document
# doubled every press and broke a correct control at v11.28. Keys are cleared
# first: a latched key from an earlier check made ENTER look broken twice.
#
# IT OPENS THE PANELS WITH THEIR OWN KEYS rather than setting the flags, so a
# build where TAB stopped opening the backpack cannot pass this by having nothing
# to close.
#
# THE CONTROLS ARE BUILT ON P, NOT ON ESC, and that is measured rather than
# assumed. ESC WITH NOTHING OPEN CANNOT BE ASSERTED FROM A SYNTHETIC PRESS: the
# v11.04 Escape listener is registered on window after the main one, so for an
# event dispatched AT window both are at-target and run in registration order,
# raidKey first. It therefore sees the box raidKey has just opened and closes it
# again in the same press. In real play that listener runs in the capture phase,
# before raidKey, and does nothing. Measured here: P raises the box, ESC with the
# box up closes it, ESC with the box down leaves it down. That last one is the
# instrument, not the build, so this check does not pretend to read it.
#
# SO THE CONTROLS USE P: with the backpack open P must still raise the box, which
# proves the new branch has not taken the pause key away; then ESC must close the
# BOX and leave the backpack alone, which is the whole reason the guard tests
# pauseOpen; then ESC must close the backpack. That last press is what fails on
# v12.88, where it raises the box again instead.
SubRx @'
  {v:'12.88',what:'a friend imported from a run report
'@ @'
  {v:'12.89',what:'in a raid ESC closes what is in front: the map first, then the backpack, and only with neither open does it raise the pause box, while ESC with the box already up closes the box and leaves the panel behind it alone (audit finding 9, 2026-09-11, the raid twin of v12.11)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__keysRef)) return 'SKIP: this fixture cannot deploy a raid';
     var pb=document.getElementById('pausebox');
     if(!pb) return 'SKIP: this build has no pause box';
     var bad=[];
     function tap(c){
       window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:(c==='Escape'?'Escape':c),bubbles:true,cancelable:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:(c==='Escape'?'Escape':c),bubbles:true,cancelable:true}));
     }
     function boxUp(){ return pb.classList.contains('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g) return 'SKIP: the raid did not start';
       var K=__keysRef(); for(var k in K) K[k]=false;
       // THE BACKPACK, opened with its own key.
       tap('Tab');
       if(!g.bagOpen){ bad.push('control: TAB did not open the backpack, so there is nothing here for ESC to close'); }
       else {
         tap('Escape');
         if(g.bagOpen) bad.push('ESC over the open backpack did not close it, so the gesture every other window in this game teaches him does nothing to the one panel he has open');
         if(boxUp()) bad.push('ESC over the open backpack raised the pause box instead, so the raid froze under the panel he was trying to back out of and a second press would close the box and leave the panel sitting there');
       }
       if(boxUp()){ tap('Escape'); }
       g.bagOpen=false; g.mapOpen=false;
       // THE MAP, opened with its own key.
       tap('KeyM');
       if(!g.mapOpen){ bad.push('control: M did not open the map'); }
       else {
         tap('Escape');
         if(g.mapOpen) bad.push('ESC over the open map did not close it');
         if(boxUp()) bad.push('ESC over the open map raised the pause box instead');
       }
       if(boxUp()){ tap('Escape'); }
       g.bagOpen=false; g.mapOpen=false;
       // BOTH OPEN: the map is drawn in front, so it goes first and one press
       // must not take them both.
       tap('Tab'); tap('KeyM');
       if(g.bagOpen&&g.mapOpen){
         tap('Escape');
         if(g.mapOpen) bad.push('with both open ESC did not close the map, which is the one drawn in front');
         if(!g.bagOpen) bad.push('one press of ESC closed the map and the backpack together, so he loses the panel he was not backing out of');
         if(boxUp()) bad.push('with both open ESC raised the pause box');
         tap('Escape');
         if(g.bagOpen) bad.push('the second press of ESC did not close the backpack behind the map');
       }
       if(boxUp()){ tap('Escape'); }
       g.bagOpen=false; g.mapOpen=false;
       // THE THREE LAYERS, DRIVEN BY P BECAUSE ESC WITH NOTHING OPEN IS NOT
       // READABLE FROM A SYNTHETIC PRESS. The v11.04 Escape listener is registered
       // on window after the main one, so an event dispatched AT window reaches
       // raidKey first and that listener second, where it closes the box raidKey
       // just opened. In real play it runs in the capture phase, before raidKey,
       // and does nothing. What IS readable is the order of the three layers.
       tap('Tab');
       if(!g.bagOpen){ bad.push('control: TAB did not re-open the backpack'); }
       else {
         tap('KeyP');
         if(!boxUp()) bad.push('control: with the backpack open P no longer raises the pause box, so the pause key has been taken away rather than the panel given its own');
         if(!g.bagOpen) bad.push('control: raising the pause box closed the backpack behind it');
         tap('Escape');
         if(boxUp()) bad.push('control: ESC did not close the pause box, which is in front of everything');
         if(!g.bagOpen) bad.push('ESC with the box up closed the backpack behind it rather than the box in front, so the panels answer the key out of order');
         tap('Escape');
         if(g.bagOpen) bad.push('once the box is down ESC still does not reach the backpack: it raises the box again instead, which is the whole defect');
         if(boxUp()) bad.push('the press that should have closed the backpack raised the pause box over it again');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(pb.classList.contains('on')){ if(typeof togglePauseBox==='function') togglePauseBox(false); pb.classList.remove('on'); } }catch(_b){}
       try{ var g2=__state(); if(g2){ g2.bagOpen=false; g2.mapOpen=false; g2.drag=null; if(!g2.over){ g2.player.downed=false; __endRaid('extract'); } } }catch(_e){}
       try{ var K2=__keysRef(); for(var k2 in K2) K2[k2]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.88',what:'a friend imported from a run report
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
