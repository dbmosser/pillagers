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

if ($s.Contains("  {v:'36.65',what:")) { throw "check 36.65 is in the fixture already" }

SubRx @'
  {v:'36.64',what:
'@ @'
  {v:'36.65',what:'machine openings remove front soak, the fourth bulwark shot charges and hits harder, and hidden targeted windups draw a streak at the feet in both roles',
   run:function(){
     var g,p,e,bad=[],oFire=fireWeapon,oBoss=bossTick,oStroke=wc.stroke,oMove=wc.moveTo,oWeak=weakHit,oShot=netShotSend;
     var nk={},k,shots=[],sent=[],start=null,near=0,cfg={w:CFG.xfWarden,t:CFG.xfTell,p:CFG.xfPix};
     for(k in NET) nk[k]=NET[k];
     function expect(v,s){ if(!v) bad.push(s); }
     function step(t){ for(var i=0;i<Math.ceil(t/0.01);i++) updateEnts(0.01); }
     function hit(q,peer){
       var hp=q.hp; g.bullets=[{x:q.x+q.r*machMul(q)+8,y:q.y,vx:-1000,vy:0,dmg:100,player:true,owner:p,tint:'#ffffff',el:'',thru:0,life:1,rng:500,dist:0,ox:p.x,oy:p.y}];
       sent=[]; updateBullets(0.08); g.bullets=[];
       return peer?(sent.length?sent[0]:-1):hp-q.hp;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g.player;
       NET.on=false; CFG.xfWarden=1; CFG.xfTell=1; CFG.xfPix=0; xfSnap();
       g.sim=true; g.map.walls=[]; g.map.segs=[]; g.grid=null; g.vseg=[]; g.vgrid=null; g.brl=[]; g.containers=[]; g.pCrouch=false; p.downed=0; p.hp=100; p.face=Math.PI;
       p.x=2000; p.y=1600; bossTick=function(){}; weakHit=function(){return null;};
       fireWeapon=function(a,w){shots.push({a:a,dmg:w.dmg});};
       e=mkWarden(p.x-200,p.y); e.boss=0; e.face=0; e.spd=0; e.seenYou=true; e.announced=true; e.windup=0.01; e.cd=0; e.tx=e.x; e.ty=e.y; g.ents=[e];
       updateEnts(0.02); expect(shots.length===1&&e.openT>0,'warden shot did not open');
       step(0.3); expect(Math.abs(hit(e,false)-100)<0.01,'warden front round at 0.3s was soaked');
       step(0.9); expect(Math.abs(hit(e,false)-40)<0.01,'warden front round at 1.2s was not soaked to 0.4');
       e=mkBulwark(p.x-200,p.y); e.elite=0; e.affix=null; e.face=0; e.spd=0; e.state='chase'; e.alert=10; e.shotN=0; e.cd=0; e.tx=e.x; e.ty=e.y; g.ents=[e]; shots=[];
       for(var n=1;n<=4;n++){
         e.cd=0; e.windup=null; updateEnts(0.01);
         expect(Math.abs(e.windup-(n===4?0.7:0.4))<0.001,'bulwark windup '+n+' has wrong length');
         if(n===4){ var lane=telegraphLane(e); expect(lane&&lane.w===8&&e.bigW,'big windup has no wide lane'); }
         e.windup=0.001; updateEnts(0.01);
         expect(shots.length===n,'bulwark shot '+n+' did not fire');
         if(shots[n-1]) expect(Math.abs(shots[n-1].dmg-e.dmg*(n===4?2.5:1))<0.01,'bulwark shot '+n+' damage');
       }
       expect(e.openT>0&&!e.bigW,'bulwark big shot did not open and clear windup');
       expect(Math.abs(hit(e,false)-100)<0.01,'open bulwark front round was soaked');
       step(1.01); expect(Math.abs(hit(e,false)-100*(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak))<0.01,'bulwark shield did not close');
       // A real row round trip preserves all three old low bits and both new bits.
       e.openT=1; e.bigW=1; e.windup=0.5; e.glint=0.1; e.burnT=1; e.downed=1; e.getUp=1;
       var row=netEntRow(e),copy=netEntMake(123,'bulwark',e.x,e.y); netEntFlagsApply(copy,row[7],row[8]);
       expect((row[8]&31)===31&&copy.openT>0&&copy.bigW&&copy.windup===0.7&&copy.burnT>0&&copy.getUp>0,'ninth field bits did not round trip');
       copy.downed=0; copy.hp=1000; copy.face=0; copy.rng=620; copy.nid=123; g.ents=[copy];
       g.sim=false; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.entMap={123:copy};
       netShotSend=function(q,d){sent.push(d);};
       expect(Math.abs(hit(copy,true)-100)<0.01,'peer front round was soaked during open beat');
       netEntFlagsApply(copy,0,0); expect(!copy.bigW&&!copy.openT&&copy.windup===null,'snapshot did not clear opening');
       expect(Math.abs(hit(copy,true)-100*(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak))<0.01,'peer closed shield did not soak');
       NET.on=false; g.sim=false; e=mkWarden(p.x-300,p.y); e.face=0; e.windup=0.35; e.seen=false; g.ents=[e];
       var t=unseenTell(e,p); expect(t&&Math.abs(t.x1-(p.x-14))<0.01&&Math.abs(t.x2-(p.x-78))<0.01&&t.f===0.5,'unseen warden streak direction or progress');
       e.seen=true; expect(unseenTell(e,p)===null,'visible machine has hidden streak'); e.seen=false;
       CFG.xfTell=0; xfSnap(); expect(unseenTell(e,p)===null,'tell switch off still warns'); CFG.xfTell=1; xfSnap();
       p.downed=1; expect(unseenTell(e,p)===null,'downed player warned'); p.downed=0;
       p.face=0; // machine is behind the local view; render must leave it unseen.
       wc.moveTo=function(x,y){start={x:x,y:y};return oMove.apply(this,arguments);};
       wc.stroke=function(){if(start&&String(wc.strokeStyle).replace(/\s/g,'')==='#ff241c'&&wc.lineWidth===0.5&&Math.hypot(start.x-p.x,start.y-p.y)<80)near++;return oStroke.apply(this,arguments);};
       render2D(0); expect(near>0,'ground pass did not stroke at the player feet');
       // Target filtering in each role: a closer teammate owns the warning.
       for(var role=0;role<2;role++){
         NET.on=true; NET.role=role?'join':'host'; NET.seat=role?1:0; NET.max=4; NET.specG=null;
         NET.roster=[{seat:0,name:'a'},{seat:1,name:'b'}]; NET.peers=[{seat:role?0:1,state:'in'}];
         NET.up=[{seat:role?0:1,n:5,age:0,sd:g.seed>>>0,tx:e.x+20,ty:e.y,tf:0,dn:0,mv:0}];
         e.seen=false; e.windup=0.35;
         expect(netTargetFor(e)!==p&&unseenTell(e,p)===null,'wrong-target streak in '+NET.role);
         NET.up[0].tx=p.x+1200;
         expect(netTargetFor(e)===p&&unseenTell(e,p)!==null,'own-target streak missing in '+NET.role);
       }
     }catch(ex){bad.push('threw: '+(ex.message||ex));}
     finally{
       fireWeapon=oFire; bossTick=oBoss; weakHit=oWeak; netShotSend=oShot; wc.stroke=oStroke; wc.moveTo=oMove;
       for(k in NET) if(!(k in nk)) delete NET[k]; for(k in nk) NET[k]=nk[k];
       CFG.xfWarden=cfg.w; CFG.xfTell=cfg.t; CFG.xfPix=cfg.p; xfSnap();
       try{__endRaid('abandon');}catch(_end){} __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
