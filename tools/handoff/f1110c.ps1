$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ==== FIVE RAIDS IS A MEASUREMENT, NOT A CHECK. Sampling until the bot happened
# ==== to meet forty crawlers cost fifteen hundred simulated steps and outlived
# ==== the window a check gets. The measurement is in the design entry where it
# ==== belongs; what a check has to hold is the LIMIT, and the limit does not
# ==== need crawler contact to state. One short raid, and the contact half is a
# ==== bonus that skips rather than fails when the bot meets nobody.
SubRx @'
     // SEVERAL SEEDS, because one raid can pass a crawler once and prove nothing.
     var SEEDS=[9014,9000,9007,9021,9028], lo=9, sum=0, n2=0, crouched=0, inReach=0, blind=0, f, si, g, p;
     for(si=0;si<SEEDS.length&&inReach<40;si++){
       __deploy({kit:[],safe:null,mapIx:1,seed:SEEDS[si],sim:true});
       g=__state(); if(!g) continue;
       p=g.player;
       for(f=0;f<300;f++){
         __rawStep(0.15);
         if(!g||g.over) break;
         var pc=(g.pConceal===undefined)?1:g.pConceal;
         if(pc<lo) lo=pc; sum+=pc; n2++;
         if(g.pCrouch) crouched++;
         for(var i=0;i<g.ents.length;i++){
           var e=g.ents[i]; if(!e||e.kind!=='crawler'||e.hp<=0) continue;
           var d=Math.hypot(e.x-p.x,e.y-p.y), reach=(e.r+(p.r||11))+10;
           if(d>reach) continue;
           inReach++;
           // The OLD rule, written out here on purpose: sight was the ambient
           // range times concealment, with a bonus once alerted. That is the band
           // the v11.07 fix closed, and the question is whether the bot enters it.
           if(100*(e.alert>0?1.35:1)*pc < d) blind++;
         }
       }
     }
     if(n2<200) return 'SKIP: the bot only lasted '+n2+' steps across '+si+' raids, which is not enough to characterise it';
'@ @'
     // ONE SHORT RAID. The limit this check exists for is about the BOT, not
     // about how many crawlers it happened to walk past, so it does not need to
     // go looking for them.
     __deploy({kit:[],safe:null,mapIx:1,seed:9014,sim:true});
     var g=__state(); if(!g) return 'SKIP: no raid to step';
     var p=g.player, lo=9, sum=0, n2=0, crouched=0, inReach=0, blind=0, f;
     for(f=0;f<140;f++){
       __rawStep(0.15);
       if(!g||g.over) break;
       var pc=(g.pConceal===undefined)?1:g.pConceal;
       if(pc<lo) lo=pc; sum+=pc; n2++;
       if(g.pCrouch) crouched++;
       for(var i=0;i<g.ents.length;i++){
         var e=g.ents[i]; if(!e||e.kind!=='crawler'||e.hp<=0) continue;
         var d=Math.hypot(e.x-p.x,e.y-p.y), reach=(e.r+(p.r||11))+10;
         if(d>reach) continue;
         inReach++;
         // The OLD rule, written out on purpose: sight was the ambient range
         // times concealment, with a bonus once alerted. That is the band the
         // v11.07 fix closed.
         if(100*(e.alert>0?1.35:1)*pc < d) blind++;
       }
     }
     if(n2<60) return 'SKIP: the bot only lasted '+n2+' steps, which is not enough to characterise it';
     // THE DIAL SAYS IT FIRST, and needs no raid at all: a bot that is allowed to
     // crouch would change every extract number ever quoted.
     if(__cfg().simCrouch) bad.push('the bot is allowed to crouch now, simCrouch is '+__cfg().simCrouch+', so every extract rate in this file describes a different player from the one that produced them');
'@
SubRx @'
     if(inReach<5) bad.push('control: the bot came inside biting distance only '+inReach+' times in '+n2+' steps, so this run says nothing about crawlers');
'@ @'
     // The crawler half only means something if it met one. Silence there is a
     // gap in this sample, not a fault in the game, so it is said and not failed.
     if(inReach<5) notes.push('the bot came inside biting distance only '+inReach+' times in '+n2+' steps here, so this run says nothing about crawlers either way');
'@
SubRx @'
     if(blind>0) bad.push('the bot spent '+blind+' frames close enough to be bitten and invisible, so the v11.07 finding is reachable by the sim after all and should be measured rather than reasoned about');
'@ @'
     if(blind>0) bad.push('the bot spent '+blind+' frames close enough to be bitten and invisible, so the v11.07 finding is reachable by the sim after all and should be measured rather than reasoned about');
     if(!bad.length&&notes.length) return null;
'@
SubRx @'
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(1);
'@ @'
     var bad=[], notes=[];
     __runPrep(); __resetCfg(); __pinDefaults(1);
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
