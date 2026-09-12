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

# v12.94 CHECK, inserted before the v12.93 entry.
#
# IT READS THE DRAWN SCREEN, because the verb is decided inside the HUD draw and
# there is no way to call it from here. __textTrace catches the strings the frame
# actually paints, which is the same thing his eye gets.
#
# IT STAGES TWO LIVE BEACONS, which is the whole finding: one ring of his own still
# inbound, and a landed ring he did not call. With a single beacon every readout
# agrees and nothing is measurable, so a check that did not build the second one
# would be green on both builds.
#
# TWO CONTROLS. A single landed ring he called himself must behave exactly as v12.81
# left it, or this build has traded one wrong answer for another. And lying outside
# every ring must still offer the surrender, or the guard has simply been turned on
# for everybody and the key he asked for at v9.71 is gone.
SubRx @'
  {v:'12.93',what:'the last-minute warnings name the extraction he actually called
'@ @'
  {v:'12.94',what:'going down inside a landed extraction shows the extract verb and blocks the surrender even when it is not the ring he called himself, while a single ring he did call behaves exactly as v12.81 left it and lying outside every ring still offers the surrender (audit finding 8, 2026-09-11)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__textTrace))
       return 'SKIP: this fixture cannot deploy and read the drawn text';
     if(typeof surrenderBlocked!=='function') return 'SKIP: this build has no surrender guard to read';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||g.zones.length<2) return 'SKIP: this map has fewer than two rings, so two live beacons cannot be staged';
       var p=g.player, mine=g.zones[0], theirs=g.zones[1], i;
       function clear(){
         for(i=0;i<g.zones.length;i++){ g.zones[i].open=true; g.zones[i].beaconT=null; g.zones[i].hold=null; g.zones[i].holdMax=null; }
         g.active=null; g.beaconT=null; g.shipHold=null;
       }
       function lieDown(x,y){
         p.x=x; p.y=y; p.downed=true; p.downT=60; p.hp=0; p.revived=true; p.giveT=0; p.prep=null;
       }
       function drawn(){
         var out=[];
         try{ out=__textTrace(function(){ __frame(0.016); }); }catch(_t){}
         return out.map(function(d){ return String(d.t); }).join(' | ').toUpperCase();
       }
       if(CFG.giveUp===0) return 'SKIP: the surrender is switched off in this build, so there is no prompt to get wrong';
       // TWO LIVE BEACONS: his own still inbound, and a landed one he did not call,
       // which he is lying inside with the self-revive already spent.
       clear();
       mine.beaconT=17; mine.hold=null; g.active=mine; g.beaconT=17;
       theirs.beaconT=0; theirs.hold=12; theirs.holdMax=30;
       lieDown(theirs.x,theirs.y);
       if(surrenderBlocked()!==true)
         bad.push('down inside a landed extraction, the surrender is not blocked because the game is measuring the other one he called himself, so a hand resting on the key ends the raid and loses the backpack in the one situation where being down ends well');
       var txt=drawn();
       if(txt.indexOf('TO SURRENDER')>=0)
         bad.push('the downed screen offers the surrender prompt while he is lying inside a landed extraction that would carry him out with everything');
       if(txt.indexOf('HOLD E TO EXTRACT')<0)
         bad.push('the downed screen never names the one action that saves him: he is inside a landed extraction, holding E boards him with the full backpack, and the screen shows no verb at all because it is measuring the ring he called rather than the ring he is in');
       // CONTROL: ONE RING, HIS OWN, LANDED. Exactly the v12.81 case, which must be
       // untouched: blocked, and the verb shown.
       clear();
       mine.beaconT=0; mine.hold=12; mine.holdMax=30; g.active=mine; g.beaconT=0; g.shipHold=12;
       lieDown(mine.x,mine.y);
       if(surrenderBlocked()!==true)
         bad.push('control: the single-ring case v12.81 fixed is broken again, so a landed extraction he called himself no longer blocks the surrender');
       var txt2=drawn();
       if(txt2.indexOf('HOLD E TO EXTRACT')<0)
         bad.push('control: the single-ring case no longer shows the extract verb either');
       // CONTROL: OUTSIDE EVERY RING the surrender is his, and v9.71 asked for it.
       clear();
       mine.beaconT=17; mine.hold=null; g.active=mine; g.beaconT=17;
       lieDown(mine.x+mine.r+1200,mine.y);
       if(surrenderBlocked()!==false)
         bad.push('control: lying nowhere near a landed extraction the surrender is blocked anyway, so the guard has been turned on for everybody and the key he asked for at v9.71 is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state();
            if(g2){ if(g2.zones) for(var z=0;z<g2.zones.length;z++){ g2.zones[z].beaconT=null; g2.zones[z].hold=null; g2.zones[z].holdMax=null; }
                    g2.active=null; g2.beaconT=null; g2.shipHold=null;
                    if(g2.player){ g2.player.downed=false; g2.player.downT=0; g2.player.giveT=0; }
                    if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.93',what:'the last-minute warnings name the extraction he actually called
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
