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

if ($s.Contains("  {v:'37.51',what:")) { throw "check 37.51 is in the fixture already" }

SubRx @'
  {v:'37.50',what:
'@ @'
  {v:'37.51',what:'blasts shove with collision and never add aim recoil; big non-blast hits nudge actual rounds for 0.25 seconds in both seats',
   run:function(){
     if(typeof BLAST_AT==='undefined'||typeof BLAST_SHOVE_V==='undefined') return 'no blast shove';
     var g,p,x,y,side,i,k,tag,bad=[],cp=Object.assign({},CFG),nk=Object.assign({},NET),pk=Object.assign({},PAD),kk=keys,mm=Object.assign({},mouse),kid=P.kidDmg,af=P.p2Auto,send=netSend,pack=[],peer={state:'in',seat:1},baseW;
     function ok(v,s){if(!v)bad.push(tag+': '+s);}
     function aim(){var z=ZOOM();g.camX=x-W/(2*z);g.camY=y-H*0.54/z;mouse.x=W/2+250*z;mouse.y=H*0.54;}
     function reset(){
       p.x=x;p.y=y;p.okx=x;p.oky=y;p.hp=100;p.maxhp=100;p.armor=0;p.iv=0;p.downed=false;p.dying=false;p.specOut=false;p.arcSh=false;
       p.roll=0;p.rollCd=0;p.prep=null;p.prepA=null;p.healQ=0;p.hand=null;p.drawT=0;p.reloading=0;p.jam=0;p.cooking=false;p.fired=false;p.trigYield=false;
       p.kickT=0;p.aimNudge=0;p.aimNudgeT=0;p.face=0;p.wm=null;p.lastShot=-1e9;p.ammo=30;p.bloomK=0;p.bloomPend=0;p.wep=baseW;p.drawRef=baseW;
       g.map.walls=[];g.map.segs=[];g.wheel=null;g.deathBeat=null;g.pwr=null;g.bullets=[];g.sprintOn=false;g.crouchTog=false;g.hot=0;
       mouse.down=false;mouse.right=false;keys={};BLAST_AT=null;aim();
     }
     function step(t){for(var j=0;j<Math.round(t/0.01);j++)updatePlayer(0.01);}
     function hit(a,sx,sy,r){
       if(side){var m={dmg:a,kind:'raider',name:'probe',seat:1,x:sx,y:sy};if(r)m.bl=r;ok(netHitTake(peer,m)==='hit','received hit rejected');}
       else netHitPlayer(p,a,'raider','probe',sx,sy,0,r);
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle','bandage','frag'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no raid';baseW=p.wep;
       g.sim=false;g.arcade=false;g.easyC=false;g.ents=[];g.zones=[];g.paused=false;g.mapOpen=false;g.bagOpen=false;g.mapFirst=0;
       CFG.xfPix=0;CFG.eDmg=1;CFG.fragR=190;CFG.autoRel=0;P.kidDmg=1;P.p2Auto=0;NET.afHost=0;NET.kidHost=1;PAD.on=false;PAD.afire=0;PAD.aiming=false;
       PAD.mx=0;PAD.my=0;PAD.held={};x=p.x;y=p.y;
       netSend=function(q,m){pack.push(m);return true;};
       for(side=0;side<2;side++){
         tag=side?'join':'host';NET.on=!!side;NET.role=side?'join':'host';NET.seat=side;NET.upSeed=g.seed>>>0;g.netWasJoin=!!side;
         reset();
         if(side)hit(80*(1-60/190)+18,x+60,y,190);else explodeFrag({x:x+60,y:y});
         ok(p.kickT===0.14&&p.kickVx<0,'near blast did not schedule left shove');ok(!p.aimNudgeT,'blast nudged aim');
         step(0.2);ok(x-p.x>=15&&x-p.x<=43,'blast displacement '+(x-p.x));ok(Math.abs(p.face)<0.00001,'blast changed facing');ok(BLAST_AT===null,'blast context leaked');
         reset();explodeFrag({x:x+400,y:y});step(0.2);ok(p.x===x&&!p.aimNudgeT,'distant blast reached player');
         reset();g.map.segs=[{x1:x+30,y1:y-100,x2:x+30,y2:y+100}];explodeFrag({x:x+60,y:y});step(0.2);ok(p.x===x&&!p.aimNudgeT,'blast crossed wall');
         reset();hit(50,x+60,y,190);g.map.walls=[{x:x-32,y:y-100,w:10,h:200}];step(0.2);ok(p.x>=x-22+p.r-0.01,'shove crossed solid wall');
         reset();p.iv=1;hit(45,x+60,y,190);ok(!p.kickT&&!p.aimNudgeT,'invulnerable hit shoved');
         reset();g.arcade=true;p.arcSh=true;hit(45,x+60,y,190);ok(!p.kickT&&!p.aimNudgeT,'shielded hit shoved');g.arcade=false;
         reset();p.hp=1;hit(45,x+60,y,190);ok(!p.kickT&&!p.aimNudgeT,'downing blast shoved');
         reset();hit(45,x,y-200);updatePlayer(0.01);ok(Math.abs(p.face)>0.04&&p.face>0,'big hit did not nudge away from source');
         // The test rifle is already drawn; replacing its object must not stage a fresh 0.825 s gun switch.
         var w=p.wep;p.wep=Object.assign({},w,{spread:0});p.drawRef=p.wep;p.drawT=0;p.bloomK=0;g.bullets=[];mouse.down=true;updatePlayer(0.01);mouse.down=false;
         var b=g.bullets[0];ok(!!b,'no round fired during nudge');if(b)ok(Math.abs(angDiff(Math.atan2(b.vy,b.vx),p.face))<0.005&&Math.abs(Math.atan2(b.vy,b.vx))>0.04,'round ignored nudged facing');p.wep=w;
         step(0.3);ok(Math.abs(p.face)<0.005,'aim failed to recover');
         reset();hit(15,x,y-200);updatePlayer(0.01);ok(!p.aimNudgeT&&Math.abs(p.face)<0.005,'small hit nudged');
         reset();hit(45,x,y+200);ok(p.aimNudge<0,'opposite source used wrong side');hit(30,x,y-200);ok(p.hp>0&&Math.abs(p.aimNudge-0.06)<1e-9&&p.aimNudgeT===0.25,'new survived hit stacked instead of replacing');
         reset();hit(45,x,y-200);keys.KeyQ=true;g.wheel={face:0,t:0,ox:mouse.x,oy:mouse.y};updatePlayer(0.01);ok(!!g.wheel&&p.face===0&&p.aimNudgeT===0.25,'wheel aim moved');g.wheel=null;
         reset();g.sim=true;BLAST_AT={x:x+60,y:y,R:190};try{damagePlayer(45,'raider','probe',x+60,y);}finally{BLAST_AT=null;}ok(!p.kickT&&!p.aimNudgeT,'simulation changed');g.sim=false;
       }
       tag='packet';NET.on=true;NET.role='host';NET.peers=[peer];pack=[];reset();
       netHitPlayer({net:true,seat:1},40,'raider','probe',x+60,y,0,190);
       ok(pack.length===1&&pack[0].bl===190&&pack[0].x===+(x+60).toFixed(1),'blast radius or centre missing in hit packet');
       pack=[];netHitPlayer({net:true,seat:1},40,'lightning','probe',x,y);ok(pack.length===1&&!pack[0].bl,'ordinary hit marked as blast');
       return bad.length?bad.join('; '):null;
     } finally {
       BLAST_AT=null;netSend=send;if(g){g.sim=false;g.netWasJoin=false;g.wheel=null;}
       try{__endRaid('abandon');}catch(_e){}__topClear();
       Object.assign(CFG,cp);Object.assign(NET,nk);Object.assign(PAD,pk);keys=kk;Object.assign(mouse,mm);P.kidDmg=kid;P.p2Auto=af;
     }
   }},
  {v:'37.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
