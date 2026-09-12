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

# v13.03 CHECK, inserted before the v13.02 entry.
#
# THE CARD IS WHERE MOST OF HIS EDITS LIVE and it was outside the v13.02 sweep, because
# that sweep draws panels that need no raid and the card needs a finished one.
#
# HIS CARD EDITS ARE PATTERN EDITS, which is why the v13.02 rule does not reach them.
# The lines carry a haul and an XP figure, so the exact sentence is different every
# run; the game strips the numbers, matches the shape, and fills his numbers back in.
# So the test is not "is the raw sentence visible" but "did the shape get his wording".
#
# IT STAGES AN ABANDON WITH A HAUL, because that is the line he rewrote and it only
# exists on that outcome. A clean extraction never prints it, which is why three
# attempts at this from outside the closure read a card that could not have carried it.
SubRx @'
  {v:'13.03',what:'the experimental warning on the Undercroft floor
'@ @'
  {v:'13.04',what:'the outcome card carries his wording too: an abandoned run with a haul prints the line as he rewrote it, and the card is checked by shape rather than by exact text because its lines carry numbers that change every run (widens the v13.02 guard)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__loop&&window.__keysRef))
       return 'SKIP: this fixture cannot finish a raid';
     if(!(window.__tx&&window.__tx.ship&&window.__tx.dom)) return 'SKIP: this fixture cannot read his baked edits';
     var M=null; try{ M=__tx.ship(); }catch(_m){}
     if(!M) return 'SKIP: his baked edits are not readable here';
     // HIS OWN ENTRY for the abandoned-run line, found by its opening rather than
     // written down, so editing it again does not strand this row.
     var key=null,k;
     for(k in M) if(k.indexOf('Run abandoned.')===0){ key=k; break; }
     if(!key) return 'SKIP: he has no baked edit for the abandoned-run line';
     // What his version adds, with the numbers taken out of both sides so the shape
     // is what is compared. This is the same reduction the game itself makes.
     function shape(x){ return String(x).replace(/-?\d[\d.,]*/g,'#'); }
     var wantShape=shape(M[key]), rawShape=shape(key);
     if(wantShape===rawShape) return 'SKIP: his edit for that line differs only in its numbers, so there is no wording to look for';
     var bad=[], P2=__P(), keepLog=(P2.log||[]).slice();
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // __startRaid rather than __deploy: an abandon staged straight off a deploy does
       // not raise the card, and 12.87 proved this is the path that ends a raid.
       __startRaid({mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) return 'SKIP: the raid did not start';
       // A REAL RUN BEHIND IT, or the abandon takes the empty-run discard path and
       // never draws a card at all. That sentence is written into the verify chain and
       // it is the whole reason five hand-staged attempts read a blank panel: walk to
       // the nearest container that has something in it and hold the use key.
       var best=null,bd=1e9,ci;
       for(ci=0;ci<(g.containers||[]).length;ci++){
         var c=g.containers[ci], d=Math.sqrt((c.x-g.player.x)*(c.x-g.player.x)+(c.y-g.player.y)*(c.y-g.player.y));
         if(d<bd&&c.loot&&c.loot.length){ bd=d; best=c; }
       }
       if(!best) return 'SKIP: this landing has no container with anything in it, so no real run can be staged here';
       g.player.x=best.x; g.player.y=best.y+4;
       var K=__keysRef(); for(var kk in K) K[kk]=false; K['KeyE']=true;
       var _t1=performance.now();
       try{ for(var _lf2=0;_lf2<420;_lf2++) __loop(_t1+_lf2*16.7); }catch(_pe){}
       K['KeyE']=false;
       g.player.downed=false;
       __endRaid('abandon');
       // THE CARD IS DRAWN BY THE LOOP, NOT BY endRaid. Reading it in the same
       // synchronous turn finds an empty panel, which is the same mistake as reading
       // before the pass that applies his wording has run: three staged attempts said
       // the card had not opened when it simply had not been drawn yet.
       var _t0=performance.now();
       try{ for(var _f=0;_f<30;_f++) __loop(_t0+_f*16.7); }catch(_lf){}
       try{ __tx.dom(document.getElementById('root')); }catch(_d){}
       var oc=document.getElementById('outcome');
       var txt=((oc&&oc.textContent)||'').replace(/\s+/g,' ');
       if(txt.indexOf('ABANDONED')<0)
         return 'SKIP: the card did not open on an abandoned run, so there is no card here to read';
       if(txt.indexOf('Run abandoned')<0)
         return 'SKIP: the abandoned card printed no haul line, so the line he rewrote was not on it to check';
       var lineShape=shape(txt);
       if(lineShape.indexOf(wantShape)<0){
         if(lineShape.indexOf(rawShape)>=0)
           bad.push('the outcome card prints the game wording for the abandoned-run line and not his: he rewrote that sentence and the card shows the original, so his edit is not reaching the one screen he reads after every raid');
         else
           bad.push('the outcome card prints neither his wording for the abandoned-run line nor the original shape it was written against, so that sentence has been reworded and his edit for it is now keyed on something the game no longer says');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       // THE RAID MUST NOT SURVIVE THIS CHECK. A finished raid blocks the floor pause
       // box outright, so leaving one here breaks 12.95 three checks later; the game
       // own return path drops the raid rather than leaving it over, and this is that.
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ P2.log=keepLog; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.03',what:'the experimental warning on the Undercroft floor
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
