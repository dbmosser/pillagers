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

# v13.15 CHECK, inserted before the v13.14 entry.
#
# IT KILLS HIM THE WAY THE GAME KILLS HIM, with a real charge at his feet, then
# reads the card that is actually drawn. Asserting on the flag alone would pass a
# build where the flag is set and the line never renders, which is the half that
# matters to a man staring at a death screen.
#
# THREE ARMS BECAUSE THE LINE HAS THREE TRUTHS. It must appear when he died
# carrying medical he never used. It must NOT appear when he used one. It must
# NOT appear when he had none to use. A line that always shows is not feedback,
# it is wallpaper.
SubRx @'
  {v:'13.14',what:'dying to your own charge is recorded as yourself, not as the unidentified bucket, so the export line, the run list, the career killers tally and the damage table all say what killed him (his telemetry of 2026-09-11, run 3)',
'@ @'
  {v:'13.15',what:'the death card says you died carrying medical you never used, and says nothing when you did use one or had none to use (his telemetry: heals 0 and downs 2 on every run)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     // KILL HIM WITH A REAL CHARGE, the shape the release pushes, and finish the
     // bleed-out so killPlayer actually runs. The flag is written in there.
     function killHim(bagItems,healsAlready){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||!g.frags||!g.bag) return null;
       keysOff();
       g.bag.length=0;
       for(var b=0;b<bagItems.length;b++) g.bag.push(bagItems[b]);
       if(healsAlready) g.tel.heals=healsAlready;
       var p=g.player;
       p.hp=12; p.iv=0; p.downed=false; p.pendKiller=null; p.revived=true;
       g.frags.push({x:p.x,y:p.y,t:0,fuse:0.05,mine:1});
       frames(20);
       var s1=__state();
       if(!s1||!s1.player||!s1.player.downed) return null;
       s1.player.downT=0.01;
       frames(6);
       return __state();
       }
     function cardLine(){
       var el=document.getElementById('outcome');
       if(!el) return null;
       return String(el.textContent||'');
       }
     try{
       // ONE: carrying medical, never used it.
       var a=killHim(['bandage','bandage'],0);
       if(!a) return 'SKIP: the charge did not finish him, so there is no card to read';
       if(!a.tel||!a.tel.diedWithMed)
         bad.push('dying with medical still in the backpack and not one applied all raid is not recorded, so the run report cannot carry it and the card has nothing to say');
       frames(6);
       var txt=cardLine();
       if(txt!==null&&txt.indexOf('MEDICAL')<0)
         bad.push('the card never says he died carrying medical he never used, which is the whole of it: the fact is recorded and he is not told');
       try{ G=null; keys={}; showScreen('hub'); }catch(_g1){}

       // TWO: he DID use one. The line must stay away.
       var b2=killHim(['bandage'],1);
       if(b2){
         if(b2.tel&&b2.tel.diedWithMed)
           bad.push('a man who applied medical and still died is told he never used any, so the line is wallpaper rather than feedback');
         frames(6);
         var t2=cardLine();
         if(t2!==null&&t2.indexOf('MEDICAL')>=0)
           bad.push('the card accuses a man who healed of never healing');
         try{ G=null; keys={}; showScreen('hub'); }catch(_g2){}
       }

       // THREE: he had none. The line must stay away.
       var c3=killHim(['scrap'],0);
       if(c3){
         if(c3.tel&&c3.tel.diedWithMed)
           bad.push('a man carrying no medical at all is recorded as having died with medical he never used');
         frames(6);
         var t3=cardLine();
         if(t3!==null&&t3.indexOf('MEDICAL')>=0)
           bad.push('the card tells a man with an empty backpack that he should have healed');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.14',what:'dying to your own charge is recorded as yourself, not as the unidentified bucket, so the export line, the run list, the career killers tally and the damage table all say what killed him (his telemetry of 2026-09-11, run 3)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
