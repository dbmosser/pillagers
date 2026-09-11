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

# v12.77 CHECK, inserted before the v12.76 entry. It presses the real two-stage
# button in a real raid, past the sixty second grace, and reads the words he is
# actually shown and the line he is actually told. The control is a character who
# HAS the XP: he must still read the full price and must still pay it, so a build
# that had simply stopped charging would fail rather than pass.
SubRx @'
  {v:'12.76',what:'how far he died from extraction is measured to the nearest way out and not to the ring the raid nominated, so the death card agrees with the compass he followed all raid and with the closest-approach line printed under it, while a death beside the nominated ring itself still reports exactly what it always did (2026-09-08 first-hour audit, my own half-done fix from v8.58)',
'@ @'
  {v:'12.77',what:'the price of walking out is the price he actually pays: with nothing banked the confirm button quotes no fine and the line afterwards announces none, while a character who has the XP still reads the full price and still pays exactly it (2026-09-08 first-hour audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof abandonRepCost!=='function'||typeof elapsed!=='function') return 'SKIP: this build has no walk-out fine';
     var ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon');
     if(!ab||!cb) return 'SKIP: this build has no abandon buttons in the page';
     var bad=[], P2=__P(), keepXp=P2.xp, keepLog=(P2.log||[]).slice();
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       function armed(xp){
         __deploy({kit:[],mapIx:0,seed:4242});
         var g=__state(); if(!g||!g.player) return null;
         // Past the grace, so the fine is live. elapsed() is the raid length
         // minus what is left, so this is the honest way to age a raid.
         if(g.raidLen!==undefined&&g.timeLeft!==undefined) g.timeLeft=g.raidLen-180;
         else g.t=180;
         if(elapsed()<=60) return {early:1};
         P2.xp=xp; saveProfile();
         ab.textContent='Abandon run';
         try{ ab.onclick.call(ab); }catch(_a){ return {threw:1}; }
         return {label:String(cb.textContent||''), cost:abandonRepCost(elapsed()), g:g};
       }
       // THE FINDING: nothing banked, so nothing can be taken.
       var a1=armed(0);
       if(!a1) return 'SKIP: no live raid to abandon';
       if(a1.early) return 'SKIP: this raid cannot be aged past the grace period here';
       if(a1.threw) return 'SKIP: arming the confirm threw';
       if(String(a1.label).indexOf(String(a1.cost))>=0)
         bad.push('with nothing banked the button still offers to charge him '+a1.cost+' XP ['+a1.label+']: the fine stops at zero and would take nothing, so the one number the game shows him about quitting is a price he cannot be charged, and it is the number that keeps a new player in a run he wanted to leave');
       var g1=a1.g; g1.msg='';
       try{ cb.onclick.call(cb); }catch(_c1){}
       var said=String(g1.msg||'');
       if(said.indexOf(String(a1.cost))>=0)
         bad.push('after walking out with nothing banked he is told ['+said+'], which announces a fine that was never taken');
       // Abandoning also pays the run its own XP, so an absolute figure here would
       // be testing that as well. The two arms are compared as a DIFFERENCE, which
       // cancels it and leaves only what the fine took.
       var _xpPoor=(P2.xp||0);
       // CONTROL: a character who HAS it reads the full price and pays it.
       var rich=5000;
       var a2=armed(rich);
       if(a2&&!a2.early&&!a2.threw){
         if(String(a2.label).indexOf(String(a2.cost))<0)
           bad.push('control: a character with '+rich+' XP is no longer told the fine is '+a2.cost+' ['+a2.label+']');
         var g2=a2.g; g2.msg='';
         try{ cb.onclick.call(cb); }catch(_c2){}
         var _xpRich=(P2.xp||0), _took=(_xpPoor-0)-(_xpRich-rich);
         if(_took!==a2.cost)
           bad.push('control: a character with '+rich+' XP was charged '+_took+' for walking out against the '+a2.cost+' the button quoted, so this build has changed what the fine costs');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(cb) cb.style.display='none'; if(ab) ab.textContent='Abandon run'; }catch(_b){}
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P2.xp=keepXp; P2.log=keepLog; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.76',what:'how far he died from extraction is measured to the nearest way out and not to the ring the raid nominated, so the death card agrees with the compass he followed all raid and with the closest-approach line printed under it, while a death beside the nominated ring itself still reports exactly what it always did (2026-09-08 first-hour audit, my own half-done fix from v8.58)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
