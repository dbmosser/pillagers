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

if ($s.Contains("  {v:'31.99',what:")) { throw "check 31.99 is in the fixture already" }

SubRx @'
  {v:'31.98',what:
'@ @'
  {v:'31.99',what:'J9: RT and LT hysteresis gives one press and release through 0.30,0.40,0.34,0.36,0.30,0.20; a semi-auto fires once',
   run:function(){
     var NG=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),PK=Object.assign({},PAD),ns=NET.same,no=NET.on,pp=P,sv=saveProfile,fw=fireWeapon;
     var pad,g,p,bad=[],shots=0,seq=[0.30,0.40,0.34,0.36,0.30,0.20],expected=[false,true,true,true,true,false];
     function poll(n,value){
       var b=[];for(var i=0;i<17;i++)b.push({pressed:i===n&&value>0.5,value:i===n?value:0});
       pad={connected:true,index:0,id:'Xbox J9',mapping:'standard',buttons:b,axes:[0,0,0,0]};pollPad();
     }
     function trace(n,shoot){
       var presses=0,releases=0,was=false,states=[];
       for(var i=0;i<seq.length;i++){
         poll(n,seq[i]);var down=n===7?!!mouse.down:!!PAD.adsAim;states.push(down);
         if(down&&!was)presses++;if(!down&&was)releases++;was=down;
         if(shoot){p.lastShot=-1e9;p.drawT=0;p.reloading=0;g.t+=0.7;updatePlayer(0.016);}
       }
       if(presses!==1||releases!==1||states.join(',')!==expected.join(','))bad.push((n===7?'RT':'LT')+' edges '+presses+'/'+releases+' states '+states.join(','));
     }
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;NET.on=false;P.padmap=null;
       P.weapons=['magnum'];P.equipped='magnum';P.equippedSec='none';P.devKit=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();__topClear();
       if(!g||!g.player||g.over)return 'staging: no raid';p=g.player;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;g.ents=[];
       if(!p.wep||p.wep.auto||!(p.wep.mag>0))return 'staging: no semi-auto gun';
       keys={};mouse.down=false;p.roll=0;p.downed=false;p.hand=null;p.cooking=null;p.jam=0;p.fired=false;p.trigYield=0;p.ammo=p.wep.mag;p.reserve=0;g.t=10;
       PAD.prev=[];PAD.prevMap=null;PAD.mSpent=null;PAD.held={};PAD.announced=true;PAD.focus=null;PAD.adsT=0;PAD.adsAim=false;PAD.rtHeld=false;PAD.ltHeld=false;PAD.firing=0;PAD.adsing=0;PAD.afire=0;
       navigator.getGamepads=function(){return [pad];};
       fireWeapon=function(sh){if(sh===p)shots++;};
       var ammo=p.ammo;trace(7,true);
       if(shots!==1||ammo-p.ammo!==1)bad.push('semi-auto shots/ammo '+shots+'/'+(ammo-p.ammo)+' instead of 1/1');
       trace(6,false);
       // v28.xx (cw-cx-triggerhyst): exact thresholds retain the current state; only crossing them changes it.
       for(var n=6;n<=7;n++){
         poll(n,0);poll(n,0.35);if(n===7?mouse.down:PAD.adsAim)bad.push(n+' pressed at 0.35');
         poll(n,0.351);if(!(n===7?mouse.down:PAD.adsAim))bad.push(n+' did not press above 0.35');
         poll(n,0.25);if(!(n===7?mouse.down:PAD.adsAim))bad.push(n+' released at 0.25');
         poll(n,0.249);if(n===7?mouse.down:PAD.adsAim)bad.push(n+' held below 0.25');
         poll(n,0.4);padRelease();poll(n,0.3);if(n===7?mouse.down:PAD.adsAim)bad.push(n+' retained latch after padRelease');
         poll(n,0);
       }
       // v28.xx (cw-cx-triggerhyst): hysteresis follows the fire/focus actions after rebinding, including trigger swaps.
       P.padmap={6:7,7:6};poll(6,0.4);poll(6,0.3);if(!mouse.down||PAD.adsAim)bad.push('swapped RT lost its hold or focused');poll(6,0.2);if(mouse.down)bad.push('swapped RT did not release');
       poll(7,0.4);poll(7,0.3);if(!PAD.adsAim||mouse.down)bad.push('swapped LT lost its hold or fired');poll(7,0.2);if(PAD.adsAim)bad.push('swapped LT did not release');
       return bad.length?bad.join('; '):null;
     }finally{
       fireWeapon=fw;
       try{padRelease();__endRaid('abandon');}catch(e){}__topClear();NET.same=ns;NET.on=no;P=pp;saveProfile=sv;
       if(own)navigator.getGamepads=NG;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,PK);
     }
   }},
  {v:'31.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
