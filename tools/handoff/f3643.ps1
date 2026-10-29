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

if ($s.Contains("  {v:'36.43',what:")) { throw "check 36.43 is in the fixture already" }

SubRx @'
  {v:'36.42',what:
'@ @'
  {v:'36.43',what:'his 10-28 order: old default settings load as 20 s, career/demo calls land after exactly 20 s in both seats, with the same siege arrivals and 30 s boarding',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function') return 'SKIP: no extraction fixture';
     var bad=[], g, z, p, mode, seat, i, k, keep={}, arc={}, cfg=cloneObj(CFG), kk=keys, md=mouse.down, oldSend=netSend, oldFast=netSendFast, oldPost=netSamePost;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function netRestore(){ var j; for(j in NET) if(!Object.prototype.hasOwnProperty.call(keep,j)) delete NET[j]; for(j in keep) NET[j]=keep[j]; }
     function clearRing(q){ q.open=true; q.closeAt=undefined; q.beaconT=null; q.hold=null; q.holdMax=null; q.pullT=null; q.callT=0; q.boardT=0; q.siegeSpawned=0; q.siegeSpawnT=0; q.siegeGreed=0; }
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     for(k in ARCADE) if(Object.prototype.hasOwnProperty.call(ARCADE,k)) arc[k]=ARCADE[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       need(DEF.extractWait===20,'default inbound is '+DEF.extractWait+', expected 20');
       applyCfg(DEF,{extractWait:30}); need(CFG.extractWait===20,'old saved 30 s did not load as 20');
       applyCfg(DEF,{extractWait:27}); need(CFG.extractWait===27,'a custom saved wait was changed');
       applyCfg(DEF,PRESETS.C); need(CFG.extractWait===18,'preset C changed');
       need(typeof extractWaitLoad==='function'&&/extractWaitLoad\(m\.cfg\[k\]\)/.test(netUpStart.toString()),'party config bypasses the saved-wait migration');
       netSend=netSendFast=netSamePost=function(){ return true; };
       for(mode=0;mode<2;mode++) for(seat=0;seat<2;seat++){
         NET.on=false; __resetCfg(); __pinDefaults(0); applyCfg(DEF,{extractWait:30});
         if(mode){ ARCADE.role='host'; if(!arcadeDeploy({mapIx:0,seed:4242})) return 'demo did not deploy'; }
         else __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state(); if(!g||g.over||!g.player||!g.zones.length) return 'no live ring';
         p=g.player; p.iv=999; p.downed=false; g.ents=[]; g.timeLeft=600; g.paused=false; g.bagOpen=false; g.mapOpen=false;
         ARCADE.holdT=0; ARCADE.waveT=0; keys={}; mouse.down=false;
         for(i=0;i<g.zones.length;i++) clearRing(g.zones[i]);
         z=g.zones[0]; g.active=z; p.x=z.x+70; p.y=z.y;
         NET.on=true; NET.role=seat?'join':'host'; NET.same=seat?'p2':'host'; NET.seat=seat; NET.upSeed=g.seed>>>0; NET.peers=[]; NET.up=[];
         for(i=0;i<20&&z.beaconT===null;i++) tryExtractTick(0.1,true);
         var tag=(mode?'demo':'career')+' seat '+seat;
         need(z.beaconT===20&&g.beaconT===20,tag+': call started at '+z.beaconT);
         if(!seat){
           clearRing(z);
           need(netBeaconTake({state:'in',seat:1},{i:0,g:0})==='called',tag+': partner call rejected');
           need(z.beaconT===20,tag+': host partner call starts at '+z.beaconT);
         } else {
           z.pullT=null; delete z.netCallAt; z.beaconT=null; g.beaconT=null;
           need(netWorldTake({state:'in'},{sd:g.seed>>>0,z:[[true,20,null,null,null]],ai:0})==='wd',tag+': world timer rejected');
           need(z.beaconT===20&&z.alarmAge===0,tag+': peer timer or sound age is wrong');
         }
         CFG.siegeVol=0.6; z.siegeGreed=0; z.siegeSpawned=999;
         need(Math.abs(siegeIvOf(0)/CFG.siegeVol-(6.4/0.6)*(20/30))<0.00001,tag+': siege rate was not compressed');
         need(Math.floor(20/(siegeIvOf(0)/CFG.siegeVol))===2&&Math.floor(20/(siegeIvOf(1)/CFG.siegeVol))===4,tag+': inbound siege counts changed');
         for(i=0;i<79;i++) tickExtractPoints(0.25);
         need(z.beaconT===0.25&&z.hold===null,tag+': landed before 20 s');
         tickExtractPoints(0.25);
         need(z.beaconT===0&&z.holdMax===30&&z.hold>0,tag+': did not land at 20 s with the full boarding window');
         need(XALARM_LEN===3,tag+': sound window changed');
         z.beaconT=10; z.alarmAge=10; CFG.xAlarm=1;
         need(!extWaitSoundOn(z),tag+': quiet middle is audible');
         try{ __endRaid('abandon'); }catch(_e){}
       }
       return bad.length?bad.join('; '):null;
     } finally {
       netSend=oldSend; netSendFast=oldFast; netSamePost=oldPost;
       NET.on=false; try{ __endRaid('abandon'); }catch(_e){} try{ if(ARCADE.on) arcadeLeave(); }catch(_a){}
       netRestore(); for(k in ARCADE) if(!Object.prototype.hasOwnProperty.call(arc,k)) delete ARCADE[k]; for(k in arc) ARCADE[k]=arc[k];
       CFG=cfg; keys=kk; mouse.down=md; __topClear();
     }
   }},
  {v:'36.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
