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

if ($s.Contains("  {v:'35.51',what:")) { throw "check 35.51 is in the fixture already" }

SubRx @'
  {v:'35.50',what:
'@ @'
  {v:'35.51',what:'RT keeps pad spread without aim, scope or walk slowdown; held and toggled LS sprint survive; LT still aims and cuts sprint in both pad windows',
   run:function(){
     var bad=[], ng=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
         pk=Object.assign({},PAD), nk=Object.assign({},NET), rk=Object.assign({},RUMBLE), kk=keys, mm=Object.assign({},mouse),
         nf=netPadFocused, np=netSamePost, rn=rnd, cp=Object.assign({},CFG), g, p, pads, side, ix, q, mode, bounds;
     function pad(i){var b=[],j;for(j=0;j<17;j++)b.push({pressed:false,value:0});return {connected:true,id:'Xbox Wireless Controller',index:i,mapping:'standard',axes:[1,0,1,0],buttons:b,timestamp:1};}
     function poll(down){var j,b;for(j=0;j<17;j++){b=pads[ix].buttons[j];b.pressed=down.indexOf(j)>=0;b.value=b.pressed?1:0;}pads[ix].timestamp++;pollPad();}
     function step(down){poll(down);updatePlayer(0.016);}
     function spread(){bounds=null;rnd=function(a,b){if(!bounds)bounds=[a,b];return (a+b)/2;};try{fireWeapon(p,p.wep,p.x+300,p.y,true);}finally{rnd=rn;}return bounds?bounds[1]:NaN;}
     function near(a,b){return isFinite(a)&&isFinite(b)&&Math.abs(a-b)<0.000001;}
     function bloom(aim,t){p.ads=aim;PAD.adsT=t;p.bloom=0;p.bloomK=0.4;p.bloomPend=0;p.bloomQ=0;p.blmX=p.x-2;p.blmY=p.y;g.sprinting=false;g.pCrouch=false;bloomTick(p,0.016);return [p.bloom,bloomCone(p,p.wep),spread()];}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_sniper'],safe:null,mapIx:0,seed:4242});
       g=__state();p=g&&g.player;if(!p||g.over) return 'no live raid';
       g.ents=[];g.bagOpen=false;g.mapOpen=false;g.mapFirst=0;g.paused=false;g.trade=null;g.forgeUI=null;
       p.wep=cloneObj(WEAPONS.sniper);p.hand=null;p.downed=false;p.roll=0;p.iv=999;p.ammo=50;p.reserve=50;p.drawT=0;p.reloading=0;p.jam=0;
       if(!(p.wep.optic>1))return 'scoped rifle staging has no optic';
       CFG.xfPix=0;P.padmap=null;P.padSticks='';
       netPadFocused=function(){return true;};netSamePost=function(){return true;};NET.on=false;
       pads=[pad(0),pad(1)];navigator.getGamepads=function(){return pads;};
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.pair='cx-rtsteady';NET.padIx=-1;NET.padOther=-1;NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;
         ix=side?0:1;padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;PAD.adsT=0;PAD.adsing=0;
         keys={};p.ads=false;poll([]);
         if(PAD.ix!==ix)bad.push(NET.same+': wrong pad slot');
         for(mode=0;mode<2;mode++){
           CFG.sprintTgl=mode;g.sprintOn=false;g.shWas=false;p.stam=100;p.stamLock=false;p.stamRelease=0;p.ads=false;g.crouchTog=false;
           step([]);step([10]);if(mode)step([]);
           if(!g.sprinting)bad.push(NET.same+': LS did not start '+mode+' sprint');
           for(q=0;q<3;q++){
             step(mode?[7]:[7,10]);
             if(!mouse.down||!PAD.firing)bad.push(NET.same+': RT did not fire');
             if(p.ads||opticMag()!==1)bad.push(NET.same+': RT entered aim or scope');
             if(!g.sprinting||(mode&&!g.sprintOn))bad.push(NET.same+': RT cut '+mode+' sprint');
             step(mode?[]:[10]);
             if(p.ads||opticMag()!==1||!g.sprinting)bad.push(NET.same+': RT settle changed sprint or scope');
           }
           step(mode?[6]:[6,10]);
           if(!p.ads||opticMag()!==p.wep.optic||g.sprinting||(mode&&g.sprintOn))bad.push(NET.same+': LT did not aim and cut sprint');
           step(mode?[]:[10]);
           if(p.ads||opticMag()!==1||(!mode&&!g.sprinting))bad.push(NET.same+': LT release did not restore held sprint');
           step([]);
         }
         CFG.sprintTgl=0;g.sprintOn=false;g.shWas=false;p.stam=100;
         poll([]);var x=p.x,y=p.y;updatePlayer(0.016);var walk=Math.hypot(p.x-x,p.y-y);
         p.x=x;p.y=y;poll([7]);updatePlayer(0.016);var shooting=Math.hypot(p.x-x,p.y-y);
         if(!(walk>0)||!near(shooting,walk))bad.push(NET.same+': RT changed walk speed '+walk+'/'+shooting);
         poll([7]);var rt=bloom(false,0.35),lt=bloom(true,0),hip=bloom(false,0);
         for(q=0;q<3;q++)if(!near(rt[q],lt[q]))bad.push(NET.same+': RT lost steady spread component '+q);
         if(!(rt[2]<hip[2])||!(rt[1]<hip[1])||!(rt[0]<hip[0]))bad.push(NET.same+': RT has hip spread');
         p.ads=false;PAD.adsT=0.35;padRelease();
         if(PAD.adsT>0)bad.push(NET.same+': released pad kept its settle');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       rnd=rn;netPadFocused=nf;netSamePost=np;
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(RUMBLE,rk);Object.assign(CFG,cp);keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'35.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
