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

# v12.09 CHECK, inserted before the v12.08 entry. The floor backpack is
# opened, ESC is pressed on the window (the only place a real key lands on
# the floor), and the backpack must be closed with no pause box; a second
# ESC with the backpack closed must still pause.
SubRx @'
  {v:'12.08',what:'taking the freebie kit at the lift clears the tactical belt plan the same as the stash screen button does, so no key points at an item left in the stash (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.09',what:'ESC over the open Undercroft backpack closes the backpack instead of raising the pause box, and ESC with it closed still pauses (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot enter the floor';
     if(typeof hubBagOpenSet!=='function'||typeof togglePauseBox!=='function') return 'SKIP: no floor backpack or pause box in this build';
     var bad=[], pb=document.getElementById('pausebox');
     try{
       __topClear(); __runPrep(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       var t=document.getElementById('title'); if(t) t.classList.remove('on');
       if(pb&&pb.classList.contains('on')) togglePauseBox(false);
       hubBagOpenSet(true);
       if(!hubBagOpen) bad.push('control: the backpack did not open');
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       if(hubBagOpen) bad.push('ESC left the backpack open');
       if(pb&&pb.classList.contains('on')) bad.push('ESC raised the pause box over the open backpack');
       // CONTROL: with the backpack closed, ESC still pauses.
       if(hubBagOpen) hubBagOpenSet(false);
       if(pb&&pb.classList.contains('on')) togglePauseBox(false);
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       if(!(pb&&pb.classList.contains('on'))) bad.push('control: ESC with the backpack closed did not raise the pause box');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ if(pb&&pb.classList.contains('on')) togglePauseBox(false); }catch(_p){} try{ if(hubBagOpen) hubBagOpenSet(false); }catch(_b){} keys={}; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.08',what:'taking the freebie kit at the lift clears the tactical belt plan the same as the stash screen button does, so no key points at an item left in the stash (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
