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

# v13.10 CHECK, inserted before the v13.09 entry.
#
# IT MOVES A REAL CONTAINER ONTO THE PAD rather than inventing one. A fabricated
# container is a shape I chose, and the thing under test is whether the scan finds what
# is really there; borrowing one the map already made keeps that honest.
#
# IT RUNS REAL FRAMES, because the nearest container is worked out inside the player
# update and nothing outside a frame computes it.
#
# THREE CONTROLS, and each is a way this could have been "fixed" badly: E must still
# call the beacon on the pad, because that is what he chose to keep; E must still
# search off the pad, because the second key is an addition and not a replacement; and
# the prompt must name the key that will actually work, or he is back to guessing.
SubRx @'
  {v:'13.09',what:'entering fullscreen asks the browser to hand over Escape
'@ @'
  {v:'13.10',what:'a body lying in an extraction point can be searched: the ring stops hiding it, the prompt names X, X searches it and E still calls the beacon, while off the pad E searches exactly as it always did (his note of 2026-09-12)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     if(!(window.__tx&&window.__tx.record)) return 'SKIP: this fixture cannot record what is painted';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||!g.zones.length) return 'SKIP: this map has no extraction point';
       if(!g.containers||!g.containers.length) return 'SKIP: this map has no containers';
       var z=g.zones[0], p=g.player, box=null, i;
       // A REAL ONE, unopened and with something in it, moved onto the pad.
       for(i=0;i<g.containers.length;i++){
         var c=g.containers[i];
         if(!c.opened&&c.loot&&c.loot.length){ box=c; break; }
       }
       if(!box) return 'SKIP: this landing has no container with anything left in it';
       box.x=z.x; box.y=z.y; box.opened=false;
       p.x=z.x; p.y=z.y; p.downed=false;
       z.beaconT=null; z.hold=null; z.pullT=null; g.active=null; g.beaconT=null;

       // THE RING STOPS HIDING IT.
       keysOff(); frames(3);
       if(__state().nearContainer!==box)
         bad.push('standing on the way out, the game does not even look for what is lying at his feet: a body killed in front of him on the pad is found by nothing, no prompt is drawn, and there is nothing on screen to say it can be searched at all');

       // THE PROMPT NAMES THE KEY THAT WILL WORK.
       var painted=[];
       try{ painted=__tx.record(function(){ frames(2); })||[]; }catch(_r){}
       var txt=painted.map(function(d){ return String(d.t); }).join(' | ');
       if(txt.indexOf('SEARCH')>=0&&txt.indexOf('[X] SEARCH')<0)
         bad.push('the prompt on the pad still offers [E] SEARCH, and E on the pad is the way out, so it names a key that will call the beacon instead of searching');

       // X SEARCHES IT.
       keysOff(); __keysRef()['KeyX']=true; frames(4);
       var sState=__state();
       if(!sState.searching)
         bad.push('X does not search the body he is standing on inside the ring, which is the whole of what he asked for');
       keysOff(); frames(2);

       // E STILL CALLS THE BEACON, which is what he chose to keep.
       var g3=__state(); g3.searching=null; g3.searchT=0;
       var z3=g3.zones[0]; z3.pullT=null; z3.beaconT=null; z3.hold=null;
       g3.player.x=z3.x; g3.player.y=z3.y;
       keysOff(); __keysRef()['KeyE']=true; frames(4);
       // THE PULL ITSELF IS NOT REACHABLE FROM HERE and the arm that tried to read it
       // was measuring the staging. Measured on the v13.09 fixture, with no container
       // involved at all: player 10 units inside an open ring of radius 78, raid alive,
       // not downed, E held for six frames, and the pull never starts while the raid
       // clock also stays at 0. Something about a deployed raid driven this way does not
       // run the raid, and that is its own investigation rather than this one. What IS
       // measurable, and is the half he asked about, is that E on the pad does not get
       // eaten by the search.
       if(__state().searching)
         bad.push('control: E on the pad searches as well as calling, so both happen at once and the pull cuts the search short, which is the fault he reported');
       keysOff(); frames(2);

       // AND E STILL SEARCHES OFF THE PAD. The second key is an addition, not a
       // replacement.
       var g5=__state();
       g5.searching=null; g5.searchT=0;
       var far={x:z.x+z.r+2000,y:z.y};
       var off=null;
       for(i=0;i<g5.containers.length;i++){
         var c2=g5.containers[i];
         if(!c2.opened&&c2.loot&&c2.loot.length&&c2!==box){ off=c2; break; }
       }
       if(off){
         var inRing=false,zi;
         for(zi=0;zi<g5.zones.length;zi++){
           var Z=g5.zones[zi];
           if(Math.sqrt((far.x-Z.x)*(far.x-Z.x)+(far.y-Z.y)*(far.y-Z.y))<Z.r){ inRing=true; break; }
         }
         if(!inRing){
           off.x=far.x; off.y=far.y; off.opened=false;
           g5.player.x=far.x; g5.player.y=far.y;
           keysOff(); __keysRef()['KeyE']=true; frames(4);
           if(!__state().searching)
             bad.push('control: away from any extraction point E no longer searches what he is standing on, so the new key replaced the old one rather than joining it');
           keysOff(); frames(2);
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6){ g6.searching=null; g6.searchT=0;
              if(g6.zones) for(var q=0;q<g6.zones.length;q++){ g6.zones[q].pullT=null; g6.zones[q].beaconT=null; g6.zones[q].hold=null; }
              if(!g6.over){ g6.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.09',what:'entering fullscreen asks the browser to hand over Escape
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
