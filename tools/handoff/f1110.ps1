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

SubRx @'
  {v:'11.09',what:'every menu in the document is set in the game font
'@ @'
  {v:'11.10',what:'the bot never hides, so no number it produces describes careful play, and it cannot show the crawler bug at all',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__rawStep)) return 'SKIP: this fixture cannot step the bot';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(1);
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
     // 1. THE BOT DOES NOT HIDE. Measured: zero crouched frames out of 300, a
     //    concealment floor of 0.40 and a mean of 0.884.
     if(crouched>0) bad.push('the bot crouched in '+crouched+' of '+n2+' frames, so the note that it never hides is out of date and every sim number needs re-reading');
     if(lo<0.30) bad.push('the bot reached a concealment of '+lo.toFixed(2)+', which is inside the band the v11.07 crawler fix exists for, so the sim CAN now see that class of bug and the note saying it cannot is wrong');
     // 2. AND THEREFORE IT NEVER MEETS THE BUG. Measured: 693 frames inside
     //    biting distance across three raids and not one of them blind.
     if(blind>0) bad.push('the bot spent '+blind+' frames close enough to be bitten and invisible, so the v11.07 finding is reachable by the sim after all and should be measured rather than reasoned about');
     // 3. CONTROLS. The bot has to have MET a crawler, or none of the above is
     //    a statement about anything.
     if(inReach<5) bad.push('control: the bot came inside biting distance only '+inReach+' times in '+n2+' steps, so this run says nothing about crawlers');
     // AND THE INSTRUMENT MUST BE ABLE TO SEE THE BAND. The same arithmetic is
     // run against a hidden man, and it must come back blind, or the test above
     // is passing because it cannot detect the thing it is looking for.
     var probe=100*1*0.05, reach0=(15+11)+10;
     if(!(probe<reach0*0.85)) bad.push('control: the blind band cannot be detected by this arithmetic at all, so the zero above means nothing');
     return bad.length?bad.join('; '):null; }},
  {v:'11.09',what:'every menu in the document is set in the game font
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
