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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'career and demo starts have visible ordinary loot; all 144 isolated starts add one legal 60-600 crate, 142 retain the preferred band, with deterministic loot and unchanged main RNG',
   run:function(){
     var oldCareer=CAREER_ON, nk={}, ak={}, seeds=[4242,17011,28123,39041,50153,61261], bad=[], g, mi, k, j, tested=0, preferred=0;
     for(k in NET) nk[k]=NET[k]; for(k in ARCADE) ak[k]=ARCADE[k];
     function need(v,msg){ if(!v) bad.push(msg); }
     function ordinary(c){ return c&&!c.opened&&!c.dropped&&!c.cache&&!c.strong&&c.type!=='cache'&&c.type!=='vault'&&c.inLocked==null; }
     function legal(m,s,c){ return spotFree(m,c.x,c.y,20)&&navReachable(m,c.x,c.y)&&!shutRoomAt(m,c.x,c.y)&&losClear(s.x,s.y,c.x,c.y,m.segs); }
     function witness(m,s,lo,hi){
       for(var a=0;a<360;a++) for(var r=lo;r<=hi;r+=10){
         var p={x:s.x+Math.cos(a*Math.PI/180)*r,y:s.y+Math.sin(a*Math.PI/180)*r};
         if(legal(m,s,p)) return p;
       }
       return null;
     }
     function coverage(q,tag){
       for(var si=0;si<q.map.spawns.length;si++){
         var s=q.map.spawns[si];
         need(q.containers.some(function(c){
           if(!ordinary(c)) return false;
           var d=Math.hypot(c.x-s.x,c.y-s.y);
           return (d<=340||(c.spawnLootStart===si&&d<=600&&legal(q.map,s,c)))&&losClear(s.x,s.y,c.x,c.y,q.map.segs);
         }),tag+' spawn '+si+' has no visible ordinary box');
       }
       q.containers.forEach(function(c){
         if(c.spawnLootStart==null) return;
         var s=q.map.spawns[c.spawnLootStart], d=s?Math.hypot(c.x-s.x,c.y-s.y):0;
         need(!!s&&ordinary(c)&&c.type==='crate'&&c.time===1&&d>=60-0.00001&&d<=600.00001&&legal(q.map,s,c),tag+' has an illegal added box');
       });
     }
     try{
       NET.on=false; ARCADE.on=false;
       for(mi=0;mi<2;mi++) for(k=0;k<seeds.length;k++){
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(mi); __cleanProfile(); CAREER_ON=1;
         __deploy({kit:['gun_carbine'],safe:null,mapIx:mi,seed:seeds[k],keepLegend:1});
         g=__state(); if(!g||!g.career||g.over) return 'career staging failed';
         var tag='map '+mi+' seed '+seeds[k]; coverage(g,tag);
         if(typeof spawnLootSight==='function'){
           for(j=0;j<g.map.spawns.length;j++){
             var s=g.map.spawns[j], m=Object.assign({},g.map,{spawns:[s]}), solo={seed:g.seed,map:m,containers:[]}, rng=RNGS;
             var made=spawnLootSight(solo), c=solo.containers[0]; tested++;
             need(made===1&&solo.containers.length===1,tag+' spawn '+j+' did not add exactly one box');
             need(RNGS===rng,tag+' placement moved the main random stream');
             if(!c) continue;
             var d=Math.hypot(c.x-s.x,c.y-s.y), inBand=d>=139.99999&&d<=320.00001;
             need(ordinary(c)&&c.type==='crate'&&c.time===1&&d>=59.99999&&d<=600.00001&&legal(m,s,c),tag+' spawn '+j+' added an illegal crate');
             if(inBand) preferred++;
             var enclosed=mi===1&&j===3&&(seeds[k]===39041||seeds[k]===61261);
             need(enclosed?!inBand:inBand,tag+' spawn '+j+' broke the 142 preferred-band starts');
             if(!inBand) need(!witness(m,s,140,320),tag+' skipped a legal preferred-band point');
             if(d>320.00001) need(!witness(m,s,60,140),tag+' skipped a legal inner fallback');
             if(d>480.00001) need(!witness(m,s,320,480),tag+' skipped a legal outer fallback');
             var sig=JSON.stringify(solo.containers), other={seed:g.seed,map:m,containers:[]};
             RNGS=(rng^123456789)>>>0; var rng2=RNGS;
             spawnLootSight(other);
             need(RNGS===rng2&&JSON.stringify(other.containers)===sig,tag+' spawn '+j+' did not reproduce position and crate loot on a different main stream');
             RNGS=rng;
             need(spawnLootSight(solo)===0&&JSON.stringify(solo.containers)===sig,tag+' spawn '+j+' added a second box');
             if(mi===0&&k===0&&j===0){
               var rejects=[{opened:true},{dropped:true},{cache:true},{strong:true},{type:'cache'},{type:'vault'},{inLocked:0}];
               rejects.forEach(function(mod){
                 var fake={seed:g.seed,map:m,containers:[Object.assign({},c,mod)]};
                 need(spawnLootSight(fake)===1&&fake.containers.length===2,'ineligible existing box suppressed a start crate: '+JSON.stringify(mod));
               });
             }
           }
           var n=g.containers.length, rs=RNGS;
           need(spawnLootSight(g)===0&&g.containers.length===n&&RNGS===rs,tag+' repeated post-build changed boxes or RNG');
         }
         __endRaid('abandon');
       }
       if(typeof spawnLootSight==='function'){
         need(tested===144&&preferred===142,'isolated starts: '+tested+' checked, '+preferred+' preferred-band, expected 144 and 142');
         for(mi=0;mi<2;mi++){
           __runPrep(); __topClear(); __resetCfg(); __pinDefaults(mi); __cleanProfile(); CAREER_ON=0;
           __deploy({kit:[],safe:null,mapIx:mi,seed:4242}); g=__state();
           need(g.ents.length===(mi?374:85)&&g.containers.length===(mi?593:165),'non-career seed 4242 fingerprint changed on map '+mi);
           __endRaid('abandon');
           __runPrep(); __topClear(); __resetCfg(); __pinDefaults(mi); __cleanProfile();
           if(!arcadeDeploy({mapIx:mi,seed:4242,role:'host'})) return 'demo staging failed';
           g=__state(); need(!!g.arcade,'demo post-build did not run'); coverage(g,'demo map '+mi);
           arcadeLeave();
         }
       }
       return bad.length?bad.slice(0,20).join('; '):null;
     }finally{
       NET.on=false; try{ if(ARCADE.on) arcadeLeave(); }catch(e){} try{__endRaid('abandon');}catch(e){} __topClear();
       for(k in NET) if(!(k in nk)) delete NET[k]; for(k in nk) NET[k]=nk[k];
       for(k in ARCADE) if(!(k in ak)) delete ARCADE[k]; for(k in ak) ARCADE[k]=ak[k]; CAREER_ON=oldCareer;
     }
   }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
