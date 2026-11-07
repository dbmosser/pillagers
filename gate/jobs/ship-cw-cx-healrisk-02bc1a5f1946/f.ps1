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

if ($s.Contains("  {v:'37.49',what:")) { throw "check 37.49 is in the fixture already" }

SubRx @'
  {v:'37.48',what:
'@ @'
  {v:'37.49',what:'medical wind-ups halve walking and cancel every sprint mode for both seats; only landed incoming hits of 30 or more interrupt, leaving plates and flowing heals alone',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid fixture';
     var g,p,x,y,dir,D,d,side,mode,i,j,k,tag,bad=[],cp=Object.assign({},CFG),nk=Object.assign({},NET),pk=Object.assign({},PAD),kk=keys,mm=Object.assign({},mouse),kid=P.kidDmg,ss=say;
     function ok(v,s){if(!v)bad.push(tag+': '+s);}
     function reset(){
       keys={};mouse.down=false;mouse.right=false;PAD.on=false;PAD.mx=0;PAD.my=0;PAD.held={};
       p.x=x;p.y=y;p.okx=x;p.oky=y;p.hp=50;p.maxhp=100;p.armor=0;p.iv=0;p.downed=false;p.dying=false;p.specOut=false;
       p.prep=null;p.prepA=null;p.healQ=0;p.healRate=0;p.healHi=0;p.healLo=undefined;p.healCap=undefined;
       p.hand=null;p.reloading=0;p.roll=0;p.rollWet=false;p.rollCd=0;p.stimT=0;p.ads=false;p.autoJog=false;p.kickT=0;p.wm=null;
       p.stam=100;p.stamLock=0;p.stamRelease=0;p.shotSprintRelease=false;p.cooking=false;
       g.sprintOn=false;g.sprinting=false;g.shWas=false;g.shWasPad=false;g.crouchTog=false;g.pCrouch=false;g.deathBeat=null;
       g.wheel=null;g.bag=['bandage','bandage','medkit','plate'];HHOLD.arm=0;
     }
     function walk(shift){keys={};keys[dir]=true;if(shift)keys.ShiftLeft=true;for(var q=0;q<25;q++)updatePlayer(0.02);keys={};return Math.hypot(p.x-x,p.y-y);}
     function hit(a){damagePlayer(a,'raider','probe',p.x+100,p.y);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no raid';
       g.ents=[];g.zones=[];g.mapOpen=false;g.bagOpen=false;g.paused=false;g.mapFirst=0;g.sim=true;NET.on=false;
       CFG.xfPix=0;CFG.healPrep=1.5;CFG.armorPrep=2;CFG.healOverTime=1;CFG.eDmg=1;CFG.autoRel=0;CFG.sprintTgl=0;
       x=p.x;y=p.y;tag='control';D=0;
       var dirs=['KeyW','KeyD','KeyS','KeyA'];
       for(i=0;i<dirs.length;i++){reset();dir=dirs[i];d=walk(false);if(d>D){D=d;k=dir;}}
       dir=k;if(!(D>30))return 'movement control could not walk clear of spawn';
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.role=side?'join':'host';NET.seat=side;g.netWasJoin=!!side;
         for(mode=0;mode<3;mode++){
           tag=NET.same+' sprint '+mode;CFG.sprintTgl=mode;reset();useMedical();d=walk(true);
           ok(d/D>=0.45&&d/D<=0.55,'healing distance ratio '+(d/D));ok(!g.sprinting&&!g.sprintOn,'sprint remained on');
         }
         CFG.sprintTgl=0;tag=NET.same;
         reset();startPrep('armor','plate');d=walk(false);ok(Math.abs(d/D-1)<0.05,'plate slowed walking');
         reset();g.bag=['medkit'];useMedical();d=walk(true);ok(Math.abs(d/D-0.5)<0.05,'medkit speed');
         reset();useMedical();p.prep.aid=1;d=walk(true);ok(Math.abs(d/D-0.5)<0.05,'teammate aid speed');
         reset();useMedical();keys={ShiftLeft:true};keys[dir]=true;g.crouchTog=true;updatePlayer(0.02);ok(g.crouchTog,'healing sprint cleared crouch');
         reset();useMedical();startPrep('armor','plate');hit(40);ok(!p.prep&&p.prepA,'big hit did not stop only medical');
         var hp=p.hp;tickHeal(2);ok(p.hp===hp&&!p.healQ,'interrupted bandage healed');ok(g.bag.length===3,'interrupted item refunded');
         reset();useMedical();hit(10);ok(!!p.prep,'small hit interrupted');hp=p.hp;tickHeal(2);ok(p.hp>hp,'small-hit bandage did not land');
         reset();useMedical();hit(29);ok(!!p.prep,'29 interrupted');
         reset();useMedical();hit(30);ok(!p.prep,'30 did not interrupt');
         reset();useMedical();p.iv=1;hit(40);ok(!!p.prep,'roll invulnerability interrupted');
         reset();useMedical();g.arcade=true;p.arcSh=true;hit(40);ok(!!p.prep,'spawn shield interrupted');p.arcSh=false;g.arcade=false;
         reset();useMedical();tickHeal(1.6);ok(!p.prep&&p.healQ>0,'no flowing-heal control');d=walk(false);ok(Math.abs(d/D-1)<0.05,'flowing heal slowed walking');
         p.hp=100;var hq=p.healQ;hit(40);ok(p.healQ===hq,'big hit cleared flowing heal');
         reset();g.arcade=true;useMedical();hit(30);ok(!p.prep,'demo cut changed threshold');g.arcade=false;
         reset();g.easyC=true;useMedical();hit(30);ok(!p.prep,'easy cut changed threshold');g.easyC=false;
         if(side){reset();P.kidDmg=KID_MIN;NET.kidHost=KID_MIN;useMedical();hit(30);ok(!p.prep,'kid cut changed threshold');P.kidDmg=kid;}
         reset();useMedical();var warns=0;say=function(t,c){if(t==='heal interrupted'&&c==='warn')warns++;};
         hit(30);ok(warns===0,'simulation emitted interruption warning');
         reset();g.sim=false;useMedical();hit(30);hit(1);ok(warns===1,'live interruption warning count '+warns);g.sim=true;say=ss;
       }
       ok(typeof bigHit==='function'&&bigHit(30)&&!bigHit(29),'shared big-hit threshold');
       return bad.length?bad.join('; '):null;
     } finally {
       if(g){g.sim=false;g.arcade=false;g.netWasJoin=false;if(p){p.prep=null;p.prepA=null;p.healQ=0;p.arcSh=false;}}
       try{__endRaid('abandon');}catch(_e){}__topClear();
       say=ss;Object.assign(CFG,cp);Object.assign(NET,nk);Object.assign(PAD,pk);keys=kk;Object.assign(mouse,mm);P.kidDmg=kid;
     }
   }},
  {v:'37.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
