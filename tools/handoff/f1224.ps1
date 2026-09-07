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

# v12.24 CHECK, inserted before the v12.23 entry. The clock is switched off
# the way Settings does it (raidSec 0, timeLeft 0), the ship is called by
# holding E at the ring edge (the 11.98 idiom), and the call line and the
# landed hold are read. Control: with the clock on and 12 seconds left the
# hold is 11, so the clock rule still binds when there is a clock.
SubRx @'
  {v:'12.23',what:'going down lets go of a cooking grenade: the throw leaves the hand with the fuse it has burned, no COOKING clock is painted over the man on the floor, and the self-revive does not stand him up holding a live cook (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.24',what:'with the raid clock switched OFF the boarding window is the full 30 seconds and the call line does not say the clock runs out first; with the clock on at 12 seconds left the window is 11 (2026-09-06 in-raid audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function') return 'SKIP: no extraction tick in this build';
     var bad=[], warn='runs out '+'first', warn2='closes in '+'two minutes';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // THE CLOCK OFF, as Settings leaves it, BEFORE the raid is built: no seconds, the count at zero, and no ring with a closing time.
       CFG.raidSec=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, Z=null, i;
       if(g.timeLeft!==0) bad.push('control: with the clock off the raid was built with '+g.timeLeft+' seconds on it');
       for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open extraction ring';
       for(i=0;i<g.zones.length;i++) if(g.zones[i].closeAt!==undefined) bad.push('with the clock off ring '+i+' carries a closing time of '+g.zones[i].closeAt);
       p.x=Z.x+70; p.y=Z.y; p.downed=false; keys={}; window.__lastSay=null;
       var line=null, first=null;
       for(i=0;i<20&&(Z.beaconT===null||Z.beaconT===undefined);i++){ tryExtractTick(0.1,true); if(first===null) first=String(window.__lastSay||''); if(Z.beaconT!==null&&Z.beaconT!==undefined) line=String(window.__lastSay||''); }
       if(first&&first.indexOf(warn2)>=0) bad.push('with the clock off the drop warned that a ring '+warn2);
       if(Z.beaconT===null||Z.beaconT===undefined) bad.push('control: holding E two seconds at the ring edge did not call for extraction');
       if(line===null||line.indexOf('Pulled')!==0) bad.push('control: the call did not say Pulled (said "'+String(line).slice(0,60)+'")');
       else if(line.indexOf(warn)>=0) bad.push('with the clock off the call still says the raid clock '+warn);
       // EXTRACTION LANDS: one tick past the end of the inbound wait sets the window.
       Z.beaconT=0.001; Z.hold=null; Z.holdMax=null; g.active=Z;
       tickExtractPoints(0.016);
       if(Z.hold===null||Z.hold===undefined) bad.push('control: the landing set no boarding window');
       else if(Math.abs(Z.holdMax-30)>0.001) bad.push('with the clock off the boarding window is '+Z.holdMax+' seconds, not 30');
       // CONTROL: with the clock on and 12 seconds left, the window is 11.
       CFG.raidSec=540; g.timeLeft=12; g.raidLen=540;
       Z.beaconT=0.001; Z.hold=null; Z.holdMax=null;
       tickExtractPoints(0.016);
       if(Z.hold===null||Z.hold===undefined||Math.abs(Z.holdMax-11)>0.001) bad.push('control: with the clock on at 12 s left the window is '+Z.holdMax+', not 11');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ __resetCfg(); }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.23',what:'going down lets go of a cooking grenade: the throw leaves the hand with the fuse it has burned, no COOKING clock is painted over the man on the floor, and the self-revive does not stand him up holding a live cook (2026-09-06 in-raid audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
