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

if ($s.Contains("  {v:'36.66',what:")) { throw "check 36.66 is in the fixture already" }

SubRx @'
  {v:'36.65',what:
'@ @'
  {v:'36.66',what:'fresh sprint mode holds on keys and toggles on the local pad, with saved choices preserved for both seats',
   run:function(){
     var bad=[],ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
       pk=Object.assign({},PAD),nk=Object.assign({},NET),rk=Object.assign({},RUMBLE),kk=keys,mm=Object.assign({},mouse),cp=Object.assign({},CFG),
       nf=netPadFocused,np=netSamePost,po=P.gameOpts,pt=P.tuned,pm=P.padmap,ps=P.padSticks,g,p,pads,side,ix,q;
     function pad(i){var b=[],j;for(j=0;j<17;j++)b.push({pressed:false,value:0});return {connected:true,id:'Xbox Wireless Controller',index:i,mapping:'standard',axes:[1,0,1,0],buttons:b,timestamp:1};}
     function step(down){for(var j=0;j<17;j++){var b=pads[ix].buttons[j];b.pressed=down.indexOf(j)>=0;b.value=b.pressed?1:0;}pads[ix].timestamp++;pollPad();updatePlayer(0.016);}
     function ok(v,s){if(!v)bad.push((side?'p2':'host')+': '+s);}
     function reset(){padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;PAD.adsT=0;PAD.adsing=0;keys={};mouse.down=false;g.sprintOn=false;g.shWas=false;g.shWasPad=false;g.crouchTog=false;p.stam=100;p.stamLock=0;p.stamRelease=0;p.shotSprintRelease=false;p.ads=false;p.roll=0;p.rollWet=false;p.downed=false;p.prep=null;p.prepA=null;p.hand=null;p.jam=0;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.ents=[];g.bagOpen=false;g.mapOpen=false;g.mapFirst=0;g.paused=false;g.trade=null;g.forgeUI=null;p.iv=999;
       P.padmap=null;P.padSticks='';netPadFocused=function(){return true;};netSamePost=function(){return true;};NET.on=false;
       pads=[pad(0),pad(1)];navigator.getGamepads=function(){return pads;};
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.pair='cx-pad-sprint';NET.padIx=-1;NET.padOther=-1;NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;ix=side?0:1;
         P.gameOpts={};P.tuned={};applyGameOpts();CFG.xfPix=0;
         ok(CFG.sprintTgl===2&&gameOptLive('sprintMode')===2,'fresh profile is not hold, pad toggle');
         reset();step([]);ok(PAD.ix===ix,'wrong pad slot');step([10]);ok(g.sprinting,'LS did not start sprint');step([]);
         for(q=0;q<3;q++)step([]);ok(g.sprinting&&g.sprintOn,'LS release ended default sprint');
         step([10]);ok(!g.sprinting,'second LS click did not stop sprint');step([]);
         step([10]);step([]);pads[ix].axes[0]=0;step([]);ok(!g.sprinting&&!g.sprintOn,'stick release did not stop sprint');pads[ix].axes[0]=1;
         step([10]);step([]);step([6]);ok(p.ads&&!g.sprinting&&!g.sprintOn,'LT did not end sprint');step([]);ok(!g.sprinting,'LT release resumed sprint');
         step([10]);step([]);p.stam=1;step([]);ok(!g.sprinting&&!g.sprintOn,'exhaustion did not end sprint');
         reset();step([]);step([10]);step([]);p.wep=cloneObj(WEAPONS.rifle);p.drawT=0;p.reloading=0;p.ammo=30;p.lastShot=-1e9;p.trigYield=0;
         fireWeapon(p,p.wep,p.x+300,p.y,true);ok(!g.sprintOn,'gunshot kept toggle on');step([]);ok(!g.sprinting,'gunshot resumed sprint');
         reset();PAD.on=false;PAD.mx=0;PAD.my=0;keys.KeyD=true;keys.ShiftLeft=true;updatePlayer(0.016);ok(g.sprinting,'keyboard hold did not sprint');keys.ShiftLeft=false;updatePlayer(0.016);ok(!g.sprinting,'keyboard release kept sprinting');
         for(var mode=0;mode<2;mode++){
           P.gameOpts.sprintMode=mode;applyGameOpts();ok(CFG.sprintTgl===mode&&gameOptIx('sprintMode')===mode,'saved pick '+mode+' changed');
           reset();step([]);step([10]);ok(g.sprinting,'saved mode '+mode+' failed to sprint');step([]);ok(!!g.sprinting===!!mode,'saved mode '+mode+' changed release behavior');
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       netPadFocused=nf;netSamePost=np;
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(RUMBLE,rk);Object.assign(CFG,cp);keys=kk;Object.assign(mouse,mm);P.gameOpts=po;P.tuned=pt;P.padmap=pm;P.padSticks=ps;
     }
   }},
  {v:'36.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
