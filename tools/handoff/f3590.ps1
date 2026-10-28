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

if ($s.Contains("  {v:'35.90',what:")) { throw "check 35.90 is in the fixture already" }

SubRx @'
  {v:'35.89',what:
'@ @'
  {v:'35.90',what:'distant wall hits wake a patrol at the impact in both window roles; open range, nearby hits, glass, rockets and enemy rounds add no impact noise',
   run:function(){
     if(typeof impactNoise!=='function'||typeof IMPACT_NOISE==='undefined') return 'wall hits have no AI impact noise';
     var g,p,e,k,n,w,b,old={},nk={},staged=false,bad=[],sent=[],calls=[],msg;
     var op=ping,os=netSend,of=netSendFast,orb=rocketBlast;
     function reset(role,kind,near){
       g.t+=2; delete g.impNzT; calls=[]; sent=[];
       NET.on=role!=='solo'; NET.role=role==='join'?'join':'host'; NET.seat=role==='join'?1:0;
       NET.upSeed=g.seed>>>0; NET.specG=null; NET.nzQ=[]; NET.nzAcc=0; NET.fxQ=[]; NET.fxAcc=0;
       NET.peers=[{seat:role==='join'?0:1,state:'in'}];
       p.x=near?1400:1000; p.y=1000; p.face=0; p.iv=99;
       w={x:1600,y:900,w:24,h:200};
       if(kind==='wood') w.furn=true;
       if(kind==='glass') w.win=true;
       if(kind==='metal') w.wreck=true;
       g.map.walls=kind==='open'?[]:[w];
       g.map.segs=(kind==='open'||kind==='glass')?[]:[
         {x1:1600,y1:900,x2:1600,y2:1100},{x1:1624,y1:900,x2:1624,y2:1100},
         {x1:1600,y1:900,x2:1624,y2:900},{x1:1600,y1:1100,x2:1624,y2:1100}];
       g.grid=buildSegGrid(g.map.segs,WORLD_W,WORLD_H);
       g.wgrid=buildWallGrid(g.map.walls,WORLD_W,WORLD_H); g.vseg=g.map.segs;
       e=mkSentry(1720,1000); e.state='patrol'; e.alert=0; e.face=0; g.ents=[e];
       g.bullets=[]; g.brl=[]; g.pings=[];
     }
     function shoot(extra){
       var gun={},j; for(j in WEAPONS.pistol) gun[j]=WEAPONS.pistol[j];
       // v28.xx (cw-cx-wallnoise): only this staged shot has 900 range to reach the requested 600-unit wall; pistol noise stays 330.
       gun.rng=900; gun.spread=0;
       fireWeapon(p,gun,1800,1000,true); b=g.bullets[g.bullets.length-1];
       b.x=p.x+17; b.y=p.y; b.vx=1180; b.vy=0;
       if(extra) for(j in extra) b[j]=extra[j];
       for(n=0;n<70&&g.bullets.length;n++){ g.t+=1/60; updateBullets(1/60); if(b._pen&&!b.rkt) break; }
     }
     function heard(tag){
       if(e.state!=='investigate'||Math.hypot(e.tx-1600,e.ty-1000)>30) bad.push(tag+': patrol did not investigate the impact');
     }
     function impacts(){ return calls.filter(function(a){return a[5]==='player'&&a[6]==='move'&&a[8]===1;}); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid'; p=g.player;
       for(k in NET) nk[k]=NET[k]; staged=true;
       ['map','grid','wgrid','vseg','ents','brl','wx','wxNext','wxT','sim'].forEach(function(q){old[q]=g[q];});
       g.map=Object.assign({},g.map); g.sim=false; g.wx={noise:1}; g.wxNext=null;
       CFG.xfPix=0; CFG.noiseMult=1; CFG.destruct=0; CFG.penetrate=1;
       ping=function(){calls.push(Array.prototype.slice.call(arguments)); return op.apply(this,arguments);};
       netSendFast=function(q,m){sent.push(JSON.parse(JSON.stringify(m)));return true;};
       netSend=function(){return true;}; rocketBlast=function(){};
       ['solo','host','join'].forEach(function(role){
         reset(role,'concrete',false);
         if(losClear(p.x,p.y,e.x,e.y,g.map.segs)) bad.push(role+': wall does not block sight');
         shoot();
         if(impacts().length!==1) bad.push(role+': expected one wall noise');
         if(role==='join'){
           if(e.state!=='patrol') bad.push('join: local mirror ran AI');
           netFxStep(.11); msg=sent.filter(function(m){return m.k==='z';})[0];
           if(!msg||!msg.z.some(function(a){return Math.abs(a[0]-1600)<2&&a[2]===200&&a[4]==='move';})) bad.push('join: impact was not sent to host');
           else{NET.role='host';NET.seat=0;NET.peers=[{seat:1,state:'in'}]; if(netFxTake(NET.peers[0],msg)!=='fx:z') bad.push('host refused peer noise');}
         }
         heard(role);
         if(g.pings.length) bad.push(role+': impact drew a player noise ring');
         reset(role,'open',false); shoot({life:WEAPONS.pistol.rng/1180});
         if(e.state!=='patrol'||impacts().length||g.bullets.length) bad.push(role+': open range expiry woke patrol or did not expire');
       });
       ['wood','metal'].forEach(function(mat){reset('solo',mat,false);shoot();heard(mat);if(impacts().length!==1)bad.push(mat+': missing impact noise');});
       reset('solo','concrete',true); shoot(); if(impacts().length) bad.push('nearby wall added impact noise');
       reset('solo','glass',false); shoot(); if(impacts().length) bad.push('glass added impact noise');
       reset('solo','concrete',false); shoot({player:false}); if(impacts().length) bad.push('enemy round added player impact noise');
       reset('solo','concrete',false); shoot({rkt:1,_pen:99}); if(impacts().length) bad.push('rocket added impact noise');
       reset('solo','open',false); calls=[]; CFG.noiseMult=1.2; g.wx.noise=1.25;
       impactNoise(1220,1000,1000,1000);
       if(impacts().length) bad.push('220-unit boundary added noise');
       impactNoise(1600,1000,1000,1000); impactNoise(1605,1000,1000,1000);
       g.t+=.199; impactNoise(1610,1000,1000,1000);
       if(impacts().length!==1) bad.push('impact noise was not capped per window');
       g.t+=.002; impactNoise(1620,1000,1000,1000);
       var a=impacts(); if(a.length!==2) bad.push('impact noise did not resume after 0.2 seconds');
       if(IMPACT_NOISE!==200||!a.length||Math.abs(a[0][2]-300)>1e-6||a[0][3]||a[0][4]||a[0][7]!==null) bad.push('impact radius, scaling or ping flags differ');
       return bad.length?bad.join('; '):null;
     }catch(err){return 'wall impact check threw: '+String(err&&err.stack||err).slice(0,500);}
     finally{
       ping=op; netSend=os; netSendFast=of; rocketBlast=orb;
       if(staged){for(k in NET)if(!(k in nk))delete NET[k];for(k in nk)NET[k]=nk[k];}
       if(g&&old.map){for(k in old)g[k]=old[k];g.bullets=[];}
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'35.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
