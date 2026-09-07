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

# v12.25 CHECK, inserted before the v12.24 entry. A beacon is set inbound at
# one open ring, the player stands in a second open ring with E up, and one
# tick runs; the called ring must keep the pointer and the clock. Control:
# with no beacon anywhere the ring stood in wins, as it always has.
SubRx @'
  {v:'12.24',what:'with the raid clock switched OFF the boarding window is the full 30 seconds and the call line does not say the clock runs out first; with the clock on at 12 seconds left the window is 11 (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.25',what:'standing in a second open ring while the ship is inbound to another leaves the called ring active with its own clock, and with no beacon anywhere the ring stood in still wins the pointer (2026-09-06 in-raid audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tryExtractTick!=='function') return 'SKIP: no extraction tick in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       if(!g.zones||g.zones.length<2) return 'SKIP: this map has fewer than two extraction rings';
       var A=g.zones[0], B=g.zones[1];
       A.open=true; B.open=true;   // the rule under test is the pointer, not the closing schedule
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].hold=null; g.zones[i].pullT=null; g.zones[i].callT=0; }
       keys={}; p.downed=false;
       // ARM ONE: the ship is inbound to A; he stands in B.
       A.beaconT=CFG.extractWait; A.hold=null; g.active=A; g.beaconT=A.beaconT;
       p.x=B.x; p.y=B.y;
       tryExtractTick(0.1,false);
       if(g.active!==A) bad.push('standing in a second open ring took the pointer off the ring the ship was called to (active is now '+(g.active===B?'the ring stood in':'another ring')+')');
       if(g.beaconT===null||g.beaconT===undefined||Math.abs(g.beaconT-A.beaconT)>0.001) bad.push('the clock shown ('+g.beaconT+') is not the called ring\x27s ('+A.beaconT+')');
       // CONTROL: no beacon anywhere; the ring he stands in wins, as it always has.
       A.beaconT=null; A.hold=null; g.beaconT=null; g.active=A;
       tryExtractTick(0.1,false);
       if(g.active!==B) bad.push('control: with no beacon anywhere the ring stood in did not become the active ring');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.24',what:'with the raid clock switched OFF the boarding window is the full 30 seconds and the call line does not say the clock runs out first; with the clock on at 12 seconds left the window is 11 (2026-09-06 in-raid audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
