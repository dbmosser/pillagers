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

if ($s.Contains("  {v:'35.86',what:")) { throw "check 35.86 is in the fixture already" }

SubRx @'
  {v:'35.85',what:
'@ @'
  {v:'35.86',what:'a real gunshot ends sprint until a fresh sprint press, on both Shift keys and pad hold/toggle in both windows; melee and dry triggers keep sprint',
   run:function(){
     var bad=[], ng=navigator.getGamepads, own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
         pk=Object.assign({},PAD),nk=Object.assign({},NET),rk=Object.assign({},RUMBLE),cp=Object.assign({},CFG),
         kk=keys,mm=Object.assign({},mouse),nf=netPadFocused,np=netSamePost,g,p,pads,ix,side,c,j,down,shift,mode,usePad,x,y;
     function pad(i){var b=[],k;for(k=0;k<17;k++)b.push({pressed:false,value:0});return {connected:true,id:'Xbox Wireless Controller',index:i,mapping:'standard',axes:[1,0,1,0],buttons:b,timestamp:1};}
     function step(s,fire){
       if(usePad){for(var k=0;k<17;k++){var b=pads[ix].buttons[k];b.pressed=(k===10&&s)||(k===7&&fire);b.value=b.pressed?1:0;}pads[ix].timestamp++;pollPad();}
       else {keys={KeyW:true};keys[shift]=s;mouse.down=fire;}
       p.x=x;p.y=y;g.t+=0.016;updatePlayer(0.016);
     }
     function ok(v,msg){if(!v)bad.push((side?'p2':'host')+'/'+c+': '+msg);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});
       g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.ents=[];g.bagOpen=false;g.mapOpen=false;g.mapFirst=0;g.paused=false;g.trade=null;g.forgeUI=null;
       var slots=hotbarSlots(),active=-1;
       for(j=0;j<slots.length;j++)if(slots[j].kind==='gun'&&slots[j].inHand){active=j;break;}
       if(active<0)return 'no equipped pistol slot';setHot(active);
       p.wep=cloneObj(WEAPONS.pistol);p.hand=null;p.downed=false;p.roll=0;p.iv=999;p.drawT=0;p.reloading=0;p.jam=0;p.stimT=0;
       x=p.x;y=p.y;CFG.autoRel=0;P.padmap=null;P.padSticks='';
       netPadFocused=function(){return true;};netSamePost=function(){return true;};NET.on=false;
       pads=[pad(0),pad(1)];navigator.getGamepads=function(){return pads;};
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.pair='cx-shotendssprint';NET.padIx=-1;NET.padOther=-1;NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;ix=side?0:1;
         for(c=0;c<5;c++){
           usePad=c>=3;mode=(c===2||c===4)?1:0;shift=c===1?'ShiftRight':'ShiftLeft';
           padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;PAD.adsT=0;PAD.adsing=0;PAD.afire=0;
           keys={};mouse.down=false; // v28.xx (cw-cx-shotendssprint): each input case starts released; a pad must not inherit the preceding keyboard trigger or Shift hold.
           CFG.sprintTgl=mode;g.sprintOn=false;g.shWas=false;g.crouchTog=false;p.shotSprintRelease=false;p.stam=100;p.stamLock=false;p.stamRelease=0;p.ads=false;p.ammo=12;p.reserve=0;p.lastShot=-1e9;p.fired=false;p.reloading=0;
           step(false,false);step(true,false);
           if(c===4)step(false,false);
           ok(g.sprinting,'sprint did not start');if(usePad)ok(PAD.ix===ix,'wrong controller slot');
           var before=p.ammo;step(c!==4,true);
           ok(p.ammo===before-1,'trigger did not fire one real round');ok(!g.sprinting&&!g.sprintOn,'shot did not end sprint immediately');
           if(usePad)ok(!p.ads,'RT entered focus aim');
           var stam=p.stam;
           for(j=0;j<50;j++)step(c!==4,false);
           ok(!g.sprinting&&!g.sprintOn,'sprint resumed without a fresh press after 0.8 seconds');ok(p.stam>stam,'stamina did not recover');
           if(c!==4){g.crouchTog=true;step(true,false);ok(g.crouchTog,'held sprint after firing cleared crouch');g.crouchTog=false;}
           step(false,false);ok(!g.sprinting,'release restarted sprint');step(true,false);ok(g.sprinting,'fresh press did not restart sprint');
           ok(meleeStrike(),'crowbar swing did not stage');step(true,false);ok(g.sprinting,'crowbar swing cancelled sprint');
           fireWeapon(p,WEAPONS.fists,p.x+100,p.y,true);step(true,false);ok(g.sprinting,'bare hands cancelled sprint');
           p.ammo=0;step(true,true);ok(g.sprinting,'dry trigger cancelled sprint');step(true,false);
           p.ammo=12;p.reloading=500;step(true,true);ok(g.sprinting,'blocked trigger during reload cancelled sprint');p.reloading=0;
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       netPadFocused=nf;netSamePost=np;
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(RUMBLE,rk);Object.assign(CFG,cp);keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'35.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
