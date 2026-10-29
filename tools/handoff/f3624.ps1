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

if ($s.Contains("  {v:'36.24',what:")) { throw "check 36.24 is in the fixture already" }

SubRx @'
  {v:'36.23',what:
'@ @'
  {v:'36.24',what:'extract sound starts only in the first/last 3 s in both seats, mute stays silent, and the full-strength enemy pull keeps running through the quiet middle and landed hold',
   run:function(){
     if(!window.__deploy||!window.__state||!window.__endRaid||typeof tickExtractPoints!=='function') return 'SKIP: no raid here';
     var bad=[], g, z, i, seat, muted, before, age, hits=[], wakes=[], rb=blip, rs=sfxHere, rp=ping, rt=styTone, tones=0, keep={}, k,
         xa=CFG.xAlarm, ew=CFG.extractWait, sp=CFG.siegePull, ec=CFG.siegeEcho, r, m, ents;
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function restoreNet(){ var j; for(j in NET) if(Object.prototype.hasOwnProperty.call(NET,j)&&!Object.prototype.hasOwnProperty.call(keep,j)) delete NET[j]; for(j in keep) NET[j]=keep[j]; }
     function record(type){ hits.push({type:type,left:before,age:age}); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player||!g.zones.length) return 'SKIP: staging: no live ring';
       g.player.iv=999; g.timeLeft=600; ents=g.ents;
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].hold=null; g.zones[i].closeAt=undefined; }
       z=g.zones[0]; g.active=z; g.player.x=z.x; g.player.y=z.y;
       CFG.extractWait=20; CFG.siegePull=1; CFG.siegeEcho=1;
       blip=function(type){ record(type); };
       sfxHere=function(type){ record(type); };
       ping=function(x,y,s,h,q,src,typ){ if(x===z.x&&y===z.y&&h===true&&src==='env'&&typ==='fire') wakes.push({left:before,strength:s}); };
       styTone=function(){ tones++; return true; };
       for(seat=0;seat<2;seat++) for(muted=0;muted<2;muted++){
         NET.on=true; NET.same=seat?'p2':'p1'; NET.role=seat?'join':'host'; NET.seat=seat; NET.upSeed=g.seed>>>0; NET.peers=[]; NET.up=[]; NET.specTick=false;
         CFG.xAlarm=muted?0:1; hits=[]; wakes=[];
         z.open=true; z.beaconT=20; z.hold=null; z.alarmAge=0; z.alarmT=undefined; z.pingT=0;
         z.siegeGreed=0; z.siegeSpawned=999; z.siegeSpawnT=0; z.siege=0; z.pullN=0; z.pinged=0;
         r={kind:'raider',x:z.x+100,y:z.y,state:'idle',alert:0,hp:100};
         m={kind:'sentry',x:z.x+120,y:z.y,state:'idle',alert:0,hp:100}; g.ents=[r,m];
         for(i=0;i<399;i++){
           before=z.beaconT; age=20-before;
           r.state=m.state='idle'; r.alert=m.alert=0;
           var n=wakes.length; tickExtractPoints(0.05);
           if(wakes.length>n&&(r.state!=='investigate'||m.state!=='investigate'||r.alert<2.4||m.alert<2.4)) bad.push('seat '+seat+': a beacon ping did not pull both enemy kinds');
         }
         var early=0,late=0,mid=0,ep=0,lp=0,midPull=0;
         for(i=0;i<hits.length;i++){
           var h=hits[i]; if(h.age<3.001) { early++; if(h.type==='inbound') ep++; }
           else if(h.left<=3.001) { late++; if(h.type==='inbound') lp++; } else mid++;
         }
         if(muted&&hits.length) bad.push('seat '+seat+': muted extract made '+hits.length+' sounds');
         if(!muted&&(!early||!late||!ep||!lp)) bad.push('seat '+seat+': missing opening/approach sounds ('+early+','+late+','+ep+','+lp+')');
         if(mid) bad.push('seat '+seat+': '+mid+' extract sounds started in the quiet middle');
         for(i=0;i<wakes.length;i++){
           if(wakes[i].strength!==1200) bad.push('seat '+seat+': the beacon wake strength changed');
           if(wakes[i].left<17&&wakes[i].left>3) midPull++;
         }
         if(wakes.length!==9||midPull<6) bad.push('seat '+seat+': two-second enemy pull stopped ('+wakes.length+' total, '+midPull+' in middle)');
         // v28.xx (cw-cx-extractquiet): exercise the sound path of an alert delayed into the middle by the queue.
         z.beaconT=10; z.alarmAge=10; tones=0;
         alertShow('EXTRACTION CALLED','ext',{key:'xcall'},0); alertShow('SIEGE INCOMING','warn',{key:'siege'},0);
         alertShow('EXTRACTION A CLOSING','ext',{},0);
         if(tones) bad.push('seat '+seat+': queued extract alerts sounded in the middle');
         tones=0; alertShow('UNRELATED WARNING','warn',{key:'other'},0);
         if(!tones) bad.push('unrelated alert lost its sound');
         z.beaconT=2.5; z.alarmAge=17.5; tones=0; alertShow('EXTRACTION CALLED','ext',{key:'xcall'},0);
         if((muted&&tones)||(!muted&&!tones)) bad.push('seat '+seat+': approach alert did not follow extract mute');
         hits=[]; wakes=[]; z.beaconT=0; z.hold=20; z.siege=0;
         for(i=0;i<60;i++){ before=0; age=20; tickExtractPoints(0.05); }
         if(hits.some(function(h){ return h.type==='xalarm'||h.type==='inbound'; })) bad.push('looping extract sound during landed hold');
         if(wakes.length!==1) bad.push('enemy pull stopped during landed hold');
       }
       // v28.xx (cw-cx-extractquiet): a mid-countdown snapshot must not replay the opening sounds.
       NET.on=true; NET.role='join'; NET.same='p2'; NET.upSeed=g.seed>>>0;
       CFG.xAlarm=1; z.beaconT=null; z.pullT=null; z.netCallAt=undefined; z.alarmAge=0;
       var packet={sd:g.seed>>>0,z:[[true,10,null,null,null]],ai:0};
       if(netWorldTake({state:'in'},packet)!=='wd') bad.push('player 2 did not accept the world snapshot');
       hits=[]; before=10; age=10; tickExtractPoints(0.05);
       if(hits.length) bad.push('player 2 replayed opening sounds on a mid-wait snapshot');
       if(XALARM_LEN!==3) bad.push('the sound window is not 3 seconds');
       if(typeof extWaitSoundOn==='function'){
         CFG.xAlarm=1; z.beaconT=10; z.alarmAge=10;
         if(extWaitSoundOn(z)) bad.push('middle sound gate open');
         z.alarmAge=2.8; z.beaconT=17.2;
         if(extWaitSoundOn(z,0.46)||extWaitSoundOn(z,1)) bad.push('opening sound tail can leak into the quiet middle');
       }
       return bad.length?bad.join('; '):null;
     } finally {
       blip=rb; sfxHere=rs; ping=rp; styTone=rt; restoreNet();
       if(g&&ents) g.ents=ents;
       CFG.xAlarm=xa; CFG.extractWait=ew; CFG.siegePull=sp; CFG.siegeEcho=ec;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     }
   }},
  {v:'36.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
