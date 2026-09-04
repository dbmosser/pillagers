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
# ==== ONE SEED IS NOT A SAMPLE, AND ITS OWN CONTROL SAID SO. Seed 9014 alone put
# ==== the bot inside biting distance ONCE in 260 steps, and the control correctly
# ==== refused to draw any conclusion from that. It walks several seeds now and
# ==== stops as soon as it has met enough crawlers to be worth reading.
SubRx @'
     __deploy({kit:[],safe:null,mapIx:1,seed:9014,sim:true});
     var g=__state(); if(!g) return 'SKIP: no raid to step';
     var p=g.player, lo=9, sum=0, n2=0, crouched=0, inReach=0, blind=0, f;
     for(f=0;f<260;f++){
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
         // The OLD rule, written out here on purpose: sight was the ambient range
         // times concealment, with a bonus once alerted. This is the band the
         // v11.07 fix closed, and the question is whether the bot ever enters it.
         if(100*(e.alert>0?1.35:1)*pc < d) blind++;
       }
     }
     if(n2<80) return 'SKIP: the bot only lasted '+n2+' steps here, which is not enough to characterise it';
'@ @'
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
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
