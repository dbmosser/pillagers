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

# v12.68 CHECK, inserted before the v12.67 entry. It presses the real footer
# button and the real answers, and reads whether the bench is on screen after
# each, because the whole finding is about which window he is left looking at.
# Both answers are driven, since the fault is different on each: declining costs
# him the window, and accepting redraws it where he cannot see it. The control
# is a card raised by nothing, which must still close onto the floor.
SubRx @'
  {v:'12.67',what:'selling salvage moves the level and the racks it gates, at the counter, instead of leaving the card showing a level that disagrees with the XP printed under it until the next raid ends (2026-09-08 audit)',
'@ @'
  {v:'12.68',what:'answering the hire bench question leaves him at the bench: pressing Hire nobody and then either answer puts the bench back on screen, and the HIRED pill is cleared where it can be seen, while a card raised by nothing still closes onto the floor (2026-09-08 audit, my defect from v8.17)',
   run:function(){
     if(!(window.__P&&window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot reach the bench';
     if(typeof openTrader!=='function'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this build has no hire bench';
     var tm=document.getElementById('tradermodal'), am=document.getElementById('askmodal');
     var mc=document.getElementById('mercclear'), ay=document.getElementById('askyes'), an=document.getElementById('askno');
     if(!tm||!am||!mc||!ay||!an) return 'SKIP: this build has no confirm card on the bench';
     var bad=[], P2=__P(), keepMerc=P2.merc;
     function on(el){ return !!(el&&el.classList.contains('on')); }
     function ask(){
       __showScreen('hub'); __hubEnter();
       P2.merc=IDENTITIES[0].id;
       openTrader('hire');
       if(!on(tm)) return 'the bench would not open';
       mc.click();
       if(!on(am)) return 'the footer button raised no question';
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // THE FINDING, DECLINING: a question he said no to must not cost him the
       // window he asked it from.
       var e1=ask();
       if(e1) return 'SKIP: '+e1;
       if(on(tm)) bad.push('staging: the bench stayed open behind the question, so this check is not reading the state the finding is about');
       an.click();
       if(!on(tm))
         bad.push('saying no to the hire question left him on the bare floor: the bench, the tab and the man he was reading about are all gone for a question he declined, and he has to walk back to the station');
       if(on(am)) bad.push('the question is still up after he answered it');
       // THE FINDING, ACCEPTING: the result of the one irreversible action on
       // that bench has to be visible where the action was taken.
       var e2=ask();
       if(e2) return 'SKIP: '+e2;
       ay.click();
       if(!on(tm))
         bad.push('letting the hire go closed the bench, so the pill clearing is drawn where nobody can see it and the only word he gets is a toast that fades');
       if(P2.merc) bad.push('control: letting the hire go did not actually clear the hire');
       // CONTROL: a card raised by nothing to go back to must still close onto
       // the floor, so this build has not made every question sticky.
       __showScreen('hub'); __hubEnter();
       am.classList.add('on');
       an.click();
       if(on(tm)) bad.push('control: a question raised with no window behind it put the bench up anyway, so the restore is firing on cards that never asked for it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(am) am.classList.remove('on'); if(tm) tm.classList.remove('on'); }catch(_m){}
       try{ P2.merc=keepMerc; saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.67',what:'selling salvage moves the level and the racks it gates, at the counter, instead of leaving the card showing a level that disagrees with the XP printed under it until the next raid ends (2026-09-08 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
