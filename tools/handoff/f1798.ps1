$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'17.98',what:")) { throw "check 17.98 is in the fixture already" }

SubRx @'
  {v:'17.97',what:
'@ @'
  {v:'17.98',what:'extraction takes 30 seconds to arrive after the call, his note of 2026-10-03 (it was 25), and the window after it lands is the full 30 seconds',
   run:function(){
     if(typeof DEF==='undefined'||typeof CFG==='undefined') return 'SKIP: no defaults table';
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function') return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, Z=null, i;
     if(DEF.extractWait!==30) bad.push('the defaults say the ship takes '+DEF.extractWait+' seconds');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(CFG.extractWait!==30) bad.push('the live setting says '+CFG.extractWait+' seconds');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player;
       for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open extraction ring';
       p.x=Z.x+70; p.y=Z.y; p.downed=false; keys={};
       for(i=0;i<20&&(Z.beaconT===null||Z.beaconT===undefined);i++) tryExtractTick(0.1,true);
       if(Z.beaconT===null||Z.beaconT===undefined) bad.push('control: holding E at the ring did not call for extraction');
       else if(!(Z.beaconT>29&&Z.beaconT<=30)) bad.push('the call set the ship '+Z.beaconT.toFixed(1)+' seconds out');
       Z.beaconT=0.001; Z.hold=null; Z.holdMax=null; g.active=Z; g.timeLeft=Math.max(g.timeLeft,400);
       tickExtractPoints(0.016);
       if(Z.hold===null||Z.hold===undefined) bad.push('control: the landing set no boarding window');
       else if(Math.abs(Z.holdMax-30)>0.001) bad.push('the boarding window is '+Z.holdMax+' seconds, not 30');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ keys={}; try{ __resetCfg(); }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'17.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
