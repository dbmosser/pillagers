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

# v12.76 CHECK, inserted before the v12.75 entry. It kills him for real and reads
# the number the card is built from, off the banked run record. The staging is
# asserted rather than assumed: the two rings have to be far enough apart that
# the right answer and the wrong one cannot be confused, and it says so and skips
# if this seed does not offer that. The control kills him beside the nominated
# ring itself, where the old answer and the new one agree, so a build that had
# simply started reporting some other number would fail there.
SubRx @'
  {v:'12.75',what:'the last box before the lift says what actually happens: with nothing equipped it does not promise a sidearm, because the deploy issues a primary and leaves the second slot empty, and it does not list the rig on the line above the warning that he ascends with no armour on, while a character who has a gun equipped still sees that gun named (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.76',what:'how far he died from extraction is measured to the nearest way out and not to the ring the raid nominated, so the death card agrees with the compass he followed all raid and with the closest-approach line printed under it, while a death beside the nominated ring itself still reports exactly what it always did (2026-09-08 first-hour audit, my own half-done fix from v8.58)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     var bad=[], P2=__P(), keepLog=(P2.log||[]).slice(), keepBest=P2.best;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       function lastRec(){ var L=P2.log||[]; return L.length?L[L.length-1]:null; }
       // ONE DEATH, staged: standing beside one open ring with the nomination
       // pointed at a far one. Returns what the card was built from.
       function dieBeside(nearIx,activeIx){
         __deploy({kit:[],mapIx:0,seed:4242});
         var g=__state(); if(!g||!g.player||!g.zones) return null;
         var open=[], i;
         for(i=0;i<g.zones.length;i++) if(g.zones[i]&&g.zones[i].open) open.push(g.zones[i]);
         if(open.length<2) return {few:1};
         // Farthest pair, so the two answers cannot be mistaken for each other.
         var A=open[0], B=open[0], bd=-1, a2, b2;
         for(a2=0;a2<open.length;a2++) for(b2=a2+1;b2<open.length;b2++){
           var d2=dist(open[a2],open[b2]); if(d2>bd){ bd=d2; A=open[a2]; B=open[b2]; }
         }
         var nearRing=(nearIx===0)?A:B, farRing=(nearIx===0)?B:A;
         g.player.x=nearRing.x+40; g.player.y=nearRing.y+40;
         g.active=(activeIx==='near')?nearRing:farRing;
         var dNear=dist(g.player,nearRing), dFar=dist(g.player,farRing);
         g.player.downed=false; g.player.hp=1;
         __endRaid('dead');
         var r=lastRec();
         return {dNear:dNear,dFar:dFar,got:(r?r.deathDistExtract:null)};
       }
       var one=dieBeside(0,'far');
       if(!one) return 'SKIP: no live raid to die in';
       if(one.few) return 'SKIP: this raid built fewer than two open ways out, so there is no nearest to tell from a nominated one';
       if(one.got===null||one.got===undefined) return 'SKIP: the run record carries no death distance to read';
       if(one.dFar-one.dNear<400) return 'SKIP: the two ways out on this seed are '+Math.round(one.dFar-one.dNear)+' units apart, too close to tell the right answer from the wrong one';
       if(Math.abs(one.got-one.dNear)>25)
         bad.push('he died '+Math.round(one.dNear)+' units from the nearest way out and the card was built from '+one.got+', which is the ring the raid nominated at random '+Math.round(one.dFar)+' units away: the compass over his head pointed at the near one all raid, and the closest-approach line printed directly under this one on the same card measures the near one too, so the card disagrees with the compass and with itself');
       // CONTROL: killed beside the nominated ring, where both answers agree.
       var two=dieBeside(0,'near');
       if(two&&two.got!==null&&Math.abs(two.got-two.dNear)>25)
         bad.push('control: a death beside the nominated ring itself now reports '+two.got+' rather than the '+Math.round(two.dNear)+' it always did, so this build has changed the ordinary case as well');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P2.log=keepLog; P2.best=keepBest; saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.75',what:'the last box before the lift says what actually happens: with nothing equipped it does not promise a sidearm, because the deploy issues a primary and leaves the second slot empty, and it does not list the rig on the line above the warning that he ascends with no armour on, while a character who has a gun equipped still sees that gun named (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
