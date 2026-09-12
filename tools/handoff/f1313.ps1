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

# v13.13 CHECK, inserted before the v13.12 entry.
#
# THE PRICE OF CALLING. A siege building through the inbound wait is the whole
# reason calling the ship is a decision rather than a formality. If it ever
# stopped happening the raid would get quietly easier and nothing on screen
# would say so, which is the class of fault this corpus exists to catch.
#
# IT HAS A REAL CONTROL, and the control is the arm that matters: the same
# landing, the same number of frames, no call. If that arm also produced siege
# hostiles then the first arm would be measuring the clock rather than the call.
SubRx @'
  {v:'13.12',what:'a weather turn that keeps drawing the sky already overhead costs one round of draws and then waits, instead of redrawing thirteen times every frame for the rest of the raid and pulling two paired runs onto different seeded streams (the unpinned twin of the v12.58 bug)',
'@ @'
  {v:'13.13',what:'calling the ship costs something: a siege builds through the inbound wait, and the control is an identical raid of the same length with no call, which must bring nobody',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     function born(){ var st=__state(); if(!st||!st.ents) return -1; var c=0;
       for(var i=0;i<st.ents.length;i++) if(st.ents[i].siegeBorn) c++; return c; }
     function land(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||!g.zones.length||!g.zones[0].open) return null;
       g.player.x=g.zones[0].x; g.player.y=g.zones[0].y; g.player.downed=false;
       keysOff();
       return g;
     }
     try{
       // ARM ONE: call, then stand through part of the wait.
       var g=land();
       if(!g) return 'SKIP: the first extraction point on this landing starts closed';
       if(born()!==0) return 'SKIP: this landing starts with siege-born hostiles on it, so nothing here is attributable';
       keysOff(); __keysRef()['KeyE']=true; frames(120);
       var z=__state().zones[0];
       if(!(z.beaconT!==null&&z.beaconT!==undefined&&z.beaconT>0))
         return 'SKIP: the call did not go in, so the price of it cannot be measured';
       keysOff(); frames(600);
       var withCall=born(), flag=__state().zones[0].siegeSpawned||0;
       if(!(withCall>0))
         bad.push('calling the ship brings nobody, so the loudest thing you do all raid costs nothing and the decision the whole ending is built on is free');
       if(!(flag>0))
         bad.push('the extraction point does not count the siege it spawned, so every readout and every later spawn decision is working from zero');
       try{ var ga=__state(); if(ga&&!ga.over){ ga.player.downed=false; __endRaid('abandon'); } }catch(_a){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_ga){}

       // ARM TWO, THE CONTROL: the same landing and the same frames, no call.
       var g2=land();
       if(!g2) return 'SKIP: the control landing has no open extraction point';
       keysOff(); frames(720);
       var noCall=born();
       if(noCall>0)
         bad.push('control: a raid of the same length with no call brings '+noCall+' siege-born hostiles anyway, so the first arm is measuring the clock rather than the call and proves nothing about the price of calling');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.12',what:'a weather turn that keeps drawing the sky already overhead costs one round of draws and then waits, instead of redrawing thirteen times every frame for the rest of the raid and pulling two paired runs onto different seeded streams (the unpinned twin of the v12.58 bug)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
