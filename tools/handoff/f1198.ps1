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

# v11.98 CHECK, inserted before the v11.97 entry. ONE: the boarding window
# has half a second left, a pull is a second in, and one real extraction tick
# of six tenths with E held must end the raid EXTRACTED rather than shut the
# window. TWO: from the edge of the ring, 70 of 78 units out, holding E for
# two seconds must call the ship, which is the anywhere-in-the-ring rule.
SubRx @'
  {v:'11.97',what:'with the backpack closed, a click on the hand cell still only selects, a real drag off the belt puts the gun in the backpack, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)',
'@ @'
  {v:'11.98',what:'a boarding hold that began before the window shut still extracts while E is held, and the ship can be called from the edge of the ring (his orders of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tryExtractTick!=='function') return 'SKIP: no extraction tick in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, Z=null, i;
       for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open extraction ring';
       // TWO first, so the ring is still unclaimed: a call from the edge.
       p.x=Z.x+70; p.y=Z.y; p.downed=false; keys={};
       for(i=0;i<20;i++) tryExtractTick(0.1,true);
       if(Z.beaconT===null||Z.beaconT===undefined) bad.push('holding E for two seconds 70 units from the ring centre (ring radius '+Z.r+') did not call the ship');
       // ONE: the window at its last half second, a pull a second in, one tick past zero.
       p.x=Z.x; p.y=Z.y; Z.beaconT=0; Z.hold=0.5; Z.holdMax=30; Z.pullT=1.0; Z.pullFloor=0; g.active=Z; g.shipHold=0.5;
       tryExtractTick(0.6,true);
       if(g.over!=='extract') bad.push('a pull one second in when the window hit zero did not extract (over '+g.over+', hold '+Z.hold+', pull '+Z.pullT+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.97',what:'with the backpack closed, a click on the hand cell still only selects, a real drag off the belt puts the gun in the backpack, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
