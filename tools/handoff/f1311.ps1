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

# v13.11 CHECK, inserted before the v13.10 entry.
#
# THE THIRTY SECONDS NOTHING HAS EVER TESTED. Every other check in this corpus
# ends a raid through __endRaid, which jumps straight to the payout and never
# touches the two-stage pull. So the call, the inbound wait, the landing, the
# cancel on release and the board have run in front of a player hundreds of
# times and in front of a test zero times.
#
# IT DRIVES THE REAL KEY FOR THE REAL DURATION. The call is a 1.6 second hold
# and the board is a 1.4 second hold, both accumulated a frame at a time inside
# the player update, so the only honest way to reach either is to hold E through
# ninety-odd real frames. The one shortcut taken is winding the inbound wait
# down to a fraction of a second once the call has been made, because that is a
# countdown this check is not testing and it is minutes long.
SubRx @'
  {v:'13.10',what:'a body lying in an extraction point can be searched: the ring stops hiding it, the prompt names X, X searches it and E still calls the beacon, while off the pad E searches exactly as it always did (his note of 2026-09-12)',
'@ @'
  {v:'13.11',what:'the whole way out actually works on a live raid: holding E for 1.6s calls the ship and a shorter hold does not, the call bar fills while it is held, the ship lands, letting go of E cancels the board, and holding it again for 1.4s ends the raid as an extraction',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||!g.zones.length) return 'SKIP: this map has no extraction point';
       var z=g.zones[0], p=g.player;
       if(!z.open) return 'SKIP: the first extraction point on this landing starts closed';
       p.x=z.x; p.y=z.y; p.downed=false;
       z.beaconT=null; z.hold=null; z.pullT=null; z.callT=0;

       // A TAP IS NOT A CALL, and the bar is what says so.
       keysOff(); __keysRef()['KeyE']=true; frames(48);
       var g1=__state(), z1=g1.zones[0];
       if(z1.beaconT!==null)
         bad.push('a hold of well under the 1.6 seconds the call is meant to cost already called the ship, so the most expensive decision in the raid can be made by brushing a key');
       if(!((z1.callT||0)>0.5))
         bad.push('the call makes no progress while E is held, so the three bars that read it stay empty and the most important hold in the game gives the player nothing back');

       // AND THE FULL HOLD IS A CALL.
       frames(80);
       var g2=__state(), z2=g2.zones[0];
       if(!(z2.beaconT!==null&&z2.beaconT!==undefined&&z2.beaconT>0))
         bad.push('holding E on an open extraction point for well over 1.6 seconds never calls the ship, so there is no way out of a raid at all');
       if(g2.active!==z2)
         bad.push('calling the ship does not move the game idea of the way out onto the point that was called, so every marker and every readout still points at another one');

       // THE SHIP LANDS. The inbound countdown itself is minutes long and is not
       // what this is testing, so it is wound down rather than waited out.
       if(z2.beaconT!==null&&z2.beaconT!==undefined) z2.beaconT=0.2;
       frames(30);
       var g3=__state(), z3=g3.zones[0];
       if(!(z3.hold!==null&&z3.hold!==undefined&&z3.hold>0))
         bad.push('the inbound countdown runs out and no boarding window ever opens, so the ship is called and never arrives');

       // LETTING GO CANCELS. A board that banked would mean four separate taps
       // spread over a minute could leave, which is not a hold at all.
       keysOff(); frames(3);
       var z4=__state().zones[0];
       if((z4.pullT||0)>0)
         bad.push('the boarding hold survives the key being released, so it banks between presses and the last thirty seconds stop being a hold');

       // AND HOLDING IT AGAIN LEAVES.
       keysOff(); __keysRef()['KeyE']=true; frames(130);
       var g5=__state();
       if(!(g5&&g5.over==='extract'))
         bad.push('holding E on a landed ship for well over the 1.4 seconds boarding costs does not end the raid as an extraction, so a raid can be survived and never cashed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.10',what:'a body lying in an extraction point can be searched: the ring stops hiding it, the prompt names X, X searches it and E still calls the beacon, while off the pad E searches exactly as it always did (his note of 2026-09-12)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
