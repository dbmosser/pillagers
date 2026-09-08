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

# v12.33 CHECK, inserted before the v12.32 entry. The stall is opened the way
# he opens it, with a real E through the real frame loop, and then sixty frames
# are driven three times. Every assertion is a RATIO against the raid clock
# measured in the same frames, so a slow driver cannot fake a pass, and two
# controls stand behind it: the raid clock must have run at all, and the same
# extraction clock must move once the stall is shut.
SubRx @'
  {v:'12.32',what:'sprinting lays one trail of boot prints and not two: his own scent marks are no longer painted over his real footprints, a pillager marks still paint, and the scent list itself still fills for the trackers that smell it (his note of 2026-09-07: many footprints while running vertically)',
'@ @'
  {v:'12.33',what:'the Peddler stall is not a pause: with the trade window open the inbound extraction still counts down, a landed extraction still spends its boarding window, and a point whose closing time passes while he shops shuts (2026-09-07 audit, trade-freeze)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys&&window.__forceSize&&window.__pinDPR)) return 'SKIP: this fixture cannot deploy and drive the live loop';
     if(typeof mkPeddler!=='function'||typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function'||typeof extLetter!=='function') return 'SKIP: no stall or extraction tick in this build';
     var bad=[], K=null, hid=[], i, f, base=performance.now()+50;
     function drive(nf){ for(f=0;f<nf;f++){ base+=16.7; __loop(base); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); __forceSize(1920,1080);
       CFG.superhot=0;                       // a Settings dial that would zero dt with no key held
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.zones||!g.zones.length) return 'SKIP: no raid with extraction points';
       var p=g.player, Z=null;
       for(i=0;i<g.zones.length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open extraction point';
       K=__keys(); for(var k0 in K) K[k0]=false;
       p.downed=false; p.hp=p.maxhp; p.iv=999;
       // The crates by his feet are marked searched so the stall wins E, which is
       // the resolution the game itself uses. Every one is put back in the finally.
       for(i=0;i<g.containers.length;i++){ var CU=g.containers[i]; if(!CU.opened&&dist(CU,p)<220){ CU.opened=true; hid.push(CU); } }
       var pd=mkPeddler(p.x+30,p.y,g.map); g.ents.push(pd);
       // OPEN THE STALL THE WAY HE DOES: one frame with E down, one with it up.
       K['KeyE']=true; drive(1); K['KeyE']=false; drive(1);
       if(g.trade!==pd){ bad.push('staging: E beside the stall did not open the trade window through the real loop, so the arms below ran with it set by hand'); g.trade=pd; }
       // ARM ONE, THE INBOUND EXTRACTION. 17.5 seconds out on a 411 second clock:
       // two numbers no default produces (the wait is 25 and the raid is 540).
       g.timeLeft=411;
       Z.beaconT=17.5; Z.hold=null; Z.holdMax=null; Z.pullT=null; Z.pinged=0; g.active=Z; g.beaconT=17.5;
       var tl0=g.timeLeft, b0=Z.beaconT;
       drive(60);
       var bNow=(Z.beaconT===null||Z.beaconT===undefined)?0:Z.beaconT;
       var tlD=tl0-g.timeLeft, bD=b0-bNow;
       if(g.trade!==pd) bad.push('control: the stall shut during the first arm, so nothing was measured');
       else if(tlD<0.2) bad.push('control: the raid clock did not run in the frames driven (it fell '+tlD.toFixed(2)+'s), so this ruler cannot see a frozen clock');
       else if(bD<tlD*0.5) bad.push('with the stall open the raid clock fell '+tlD.toFixed(2)+'s and the inbound extraction fell '+bD.toFixed(2)+'s: the point still reads EXTRACT '+extLetter(Z)+' INBOUND '+Math.ceil(bNow)+'s and nothing is getting any closer');
       // ARM TWO, THE LANDED EXTRACTION: on the ground with 9.5 s of window left.
       Z.beaconT=0; Z.hold=9.5; Z.holdMax=30; Z.pullT=null; g.active=Z; g.shipHold=9.5;
       var tl1=g.timeLeft, h0=Z.hold;
       drive(60);
       var hNow=(Z.hold===null||Z.hold===undefined)?0:Z.hold;
       var tlD1=tl1-g.timeLeft, hD=h0-hNow;
       if(g.trade===pd&&tlD1>=0.2&&hD<tlD1*0.5) bad.push('with the stall open a landed extraction held its '+h0+'s boarding window through '+tlD1.toFixed(2)+'s of raid clock, so it waits for as long as he shops');
       // ARM THREE, THE CLOSING POINT, which needs no call at all and is the
       // commoner case: a point whose closing time passes while he trades shuts.
       var CZ=null;
       for(i=0;i<g.zones.length&&!CZ;i++) if(g.zones[i]!==Z&&g.zones[i].open&&g.zones[i].closeAt!==undefined) CZ=g.zones[i];
       if(CZ){
         Z.beaconT=null; Z.hold=null; Z.pullT=null; g.beaconT=null; g.shipHold=null;
         CZ.warned=1; g.timeLeft=CZ.closeAt+0.4;
         drive(60);
         if(g.trade===pd&&g.timeLeft<=CZ.closeAt&&CZ.open) bad.push('with the stall open extraction '+extLetter(CZ)+' is still marked open at '+g.timeLeft.toFixed(1)+'s against a closing time of '+CZ.closeAt+', so the map keeps offering a point that has gone');
       }
       // THE CONTROL: shut the stall and the same frames move the same clock.
       g.trade=null;
       g.timeLeft=411; Z.beaconT=17.5; Z.hold=null; Z.holdMax=null; Z.pullT=null; g.active=Z; g.beaconT=17.5;
       var tl2=g.timeLeft, b2=Z.beaconT;
       drive(60);
       var b2Now=(Z.beaconT===null||Z.beaconT===undefined)?0:Z.beaconT;
       var tlD2=tl2-g.timeLeft, bD2=b2-b2Now;
       if(tlD2<0.2) bad.push('control: the raid clock did not run with the stall shut either, so the driver is broken and the arms above prove nothing');
       else if(bD2<tlD2*0.5) bad.push('control: with the stall SHUT the inbound extraction still did not move (raid clock '+tlD2.toFixed(2)+'s, extraction '+bD2.toFixed(2)+'s), so the arms above prove nothing');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(K) for(var k1 in K) K[k1]=false; }catch(_k){}
       for(i=0;i<hid.length;i++) hid[i].opened=false;
       try{ var g2=__state(); if(g2){ g2.trade=null; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       try{ __resetCfg(); }catch(_c){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.32',what:'sprinting lays one trail of boot prints and not two: his own scent marks are no longer painted over his real footprints, a pillager marks still paint, and the scent list itself still fills for the trackers that smell it (his note of 2026-09-07: many footprints while running vertically)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
