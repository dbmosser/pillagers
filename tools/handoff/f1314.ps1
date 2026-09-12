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

# v13.14 CHECK, inserted before the v13.13 entry.
#
# IT PUSHES THE SHAPE THE THROW ACTUALLY PUSHES. A charge the player released is
# {x,y,t,fuse,mine:1} with no thrower on it, and the blast decides whose it was
# by the absence of that thrower. Inventing a different shape would be testing a
# shape I chose.
#
# IT ASSERTS ON THE PENDING KILLER RATHER THAN ON A FINISHED DEATH, because that
# is the field the record is built from and it is written the moment he goes
# down, which keeps the check to twenty frames instead of a bleed-out.
#
# THE CONTROL IS v8.23. That build gave an enemy grenade a real thrower after it
# had been reported as the player's own for months. A fix that swallowed it again
# would be a straight regression, so the second arm throws one.
SubRx @'
  {v:'13.13',what:'calling the ship costs something: a siege builds through the inbound wait, and the control is an identical raid of the same length with no call, which must bring nobody',
'@ @'
  {v:'13.14',what:'dying to your own charge is recorded as yourself, not as the unidentified bucket, so the export line, the run list, the career killers tally and the damage table all say what killed him (his telemetry of 2026-09-11, run 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     function land(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||!g.frags) return null;
       keysOff();
       g.player.hp=12; g.player.iv=0; g.player.downed=false; g.player.pendKiller=null;
       return g;
     }
     try{
       // HIS CHARGE. The shape the release pushes, no thrower on it.
       var g=land();
       if(!g) return 'SKIP: this fixture cannot stage a charge';
       g.frags.push({x:g.player.x,y:g.player.y,t:0,fuse:0.05,mine:1});
       frames(20);
       var s1=__state();
       if(!s1||!s1.player||!s1.player.downed)
         return 'SKIP: the charge did not put him down, so there is no killer to read';
       var who=s1.player.pendKiller;
       if(who==='other')
         bad.push('dying to your own charge is filed under the bucket for a source the game could not identify, so the export line, the run list, the career killers tally and the damage table all refuse to say what killed him while the death card in front of him names it exactly');
       else if(who!=='yourself')
         bad.push('dying to your own charge is recorded as '+String(who)+', which is neither him nor a thrower');
       if(s1.tel&&s1.tel.lastHitName!=='YOUR OWN CHARGE')
         bad.push('the death card no longer names the charge either, so the one place that got this right has been broken as well');
       if(s1.tel&&s1.tel.dmg&&!(s1.tel.dmg.yourself>0))
         bad.push('the damage he did to himself is not booked against him, so the damage-by-source table cannot show it');
       try{ var ga=__state(); if(ga&&!ga.over){ ga.player.downed=false; __endRaid('abandon'); } }catch(_a){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_ga){}

       // THE CONTROL, and it is v8.23: a charge with a thrower is still his.
       var g2=land();
       if(!g2) return 'SKIP: the control landing could not be staged';
       var foe=null;
       for(var i=0;i<g2.ents.length;i++){
         var e=g2.ents[i];
         if(e&&e.kind&&!e.downed&&!e.finished){ foe=e; break; }
       }
       if(foe){
         g2.frags.push({x:g2.player.x,y:g2.player.y,t:0,fuse:0.05,by:foe});
         frames(20);
         var s2=__state();
         if(s2&&s2.player&&s2.player.downed){
           if(s2.player.pendKiller==='yourself')
             bad.push('control: a charge thrown BY somebody else is recorded as his own, which is the fault v8.23 fixed coming back the other way round');
           if(s2.tel&&String(s2.tel.lastHitName||'').indexOf('YOUR OWN')>=0)
             bad.push('control: somebody else charge is named as his own on the death card, which is exactly what v8.23 removed');
         }
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.13',what:'calling the ship costs something: a siege builds through the inbound wait, and the control is an identical raid of the same length with no call, which must bring nobody',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
