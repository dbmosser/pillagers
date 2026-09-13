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

# v13.39 CHECK, inserted before the v13.38 entry.
#
# ON THE PLAY PATH: E held through one player update beside a survivor, the same test
# the key handler feeds, so strayGive runs where a player runs it. Controls: he was
# helped, and notoriety fell from 2 to 1. Machines and waves removed, crates in reach
# marked opened, and a landing inside an extraction ring skips, because E calls the
# ship there. Notoriety and Credits are restored in finally.
SubRx @'
  {v:'13.38',what:'a real player round that kills the last pillager a kill contract needs shows the contract line and then the grudge line, in that order, so the grudge line no longer writes over the only in-raid word that the contract is done',
'@ @'
  {v:'13.39',what:'helping the survivor while carrying notoriety shows the line about the cache, the pay and the salvage he hands over, and the notoriety line follows it when that one runs out instead of writing over it in the same frame (2026-09-13 hunt)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__P&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__vpAlive)) return 'SKIP: this fixture cannot deploy, step the loop or read the profile';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof strayGive!=='function'||typeof mkStray!=='function'||typeof updatePlayer!=='function') return 'SKIP: this build has no survivor or no player update';
     if(!ITEMS.bandage) return 'SKIP: this build has no bandage to hand him';
     var bad=[], P2=__P(), noto0=P2.notoriety||0, cred0=P2.credits||0;
     // Assembled, never written whole: the pay clause and the notoriety line.
     var PAID=['He','pays','you'].join(' '), WORD=['Word','of','that'].join(' ');
     var endAny=function(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} };
     var show=function(s){ return s.join(' | ').slice(0,220); };
     try{
       keys={};
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||g.over||g.sim) return 'SKIP: staging: no live raid started';
       var t0=performance.now(), f=0, i;
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }   // landing says what it says first
       g=__state(); if(!g||g.over||g.sim) return 'SKIP: staging: the raid ended while landing settled';
       var p=g.player;
       // Nothing else may use the E press or the message line: no machines, no wave
       // (the r1334c lesson), no unopened crate in reach, and not inside a ring, where E calls the ship.
       g.ents.length=0; g.waveT=-1e9;
       for(i=0;i<g.zones.length;i++) if(dist(p,g.zones[i])<g.zones[i].r) return 'SKIP: staging: the player landed inside an extraction ring, where E calls the ship';
       for(i=0;i<g.containers.length;i++) if(!g.containers[i].opened&&dist(p,g.containers[i])<90) g.containers[i].opened=1;
       p.downed=false; p.roll=0;
       var e=mkStray(p.x+30,p.y); g.ents.push(e);
       e.want='bandage'; e.helped=0; e.hostile=false; e.downed=false;
       g.bag=['bandage'];
       P2.notoriety=2;
       g.msgQ=[]; g.msgT=0; g.msg='';
       var seen=[];
       var note=function(){ var g1=__state(); if(g1&&g1.msg&&(seen.length===0||seen[seen.length-1]!==g1.msg)) seen.push(String(g1.msg)); };
       // THE PLAYER PATH: E held through one player update beside him, the same
       // test the key handler feeds (updatePlayer, the stray scan and strayLock).
       g.strayLock=0; keys['KeyE']=true;
       updatePlayer(0.016);
       keys={};
       note();
       if(!e.helped) bad.push('control: the E press beside the survivor did not help him (bag '+g.bag.join(',')+')');
       if((P2.notoriety||0)!==1) bad.push('control: helping the survivor at notoriety 2 left it at '+(P2.notoriety||0));
       g.ents.length=0;   // he walks out, and nothing of his may speak during the measurement
       for(i=0;i<600;i++){
         var gs=__state(); if(!gs||gs.over) break;
         __loop(t0+(++f)*16.7); note();
       }
       var at=function(nn){ for(var k=0;k<seen.length;k++) if(seen[k].indexOf(nn)>=0) return k; return -1; };
       var a=at(PAID), b=at(WORD);
       if(e.helped&&a<0) bad.push('the line saying the survivor paid him and what he handed over was written over in the same frame and never shown [shown: '+show(seen)+']');
       if(e.helped&&b<0) bad.push('the notoriety line was never shown [shown: '+show(seen)+']');
       if(a>=0&&b>=0&&!(a<b)) bad.push('the notoriety line was shown before the line about the pay [shown: '+show(seen)+']');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       endAny();
       try{ var P3=__P(); P3.notoriety=noto0; P3.credits=cred0; }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.38',what:'a real player round that kills the last pillager a kill contract needs shows the contract line and then the grudge line, in that order, so the grudge line no longer writes over the only in-raid word that the contract is done',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
