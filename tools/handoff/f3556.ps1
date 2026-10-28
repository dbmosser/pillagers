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

if ($s.Contains("  {v:'35.56',what:")) { throw "check 35.56 is in the fixture already" }

SubRx @'
  {v:'35.55',what:
'@ @'
  {v:'35.56',what:'pad box prompt matches X reload/search and a held X searches after a completed reload in both windows; keyboard, revives and active reload keep their actions',
   run:function(){
     var ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),nk=Object.assign({},NET),
         ik=Object.assign({},INDEV),rk=Object.assign({},RUMBLE),nf=netPadFocused,np=netSamePost,pm=P.padmap,ps=P.padSticks,cp=Object.assign({},CFG),kk=keys,mm=Object.assign({},mouse),hp=hudPrompt,
         g,p,ct,pads,ix,side,q,j,texts=[],bad=[];
     function pd(i){var b=[];for(var k=0;k<17;k++)b.push({pressed:false,value:0});return {connected:true,index:i,id:'Xbox Wireless Controller',mapping:'standard',axes:[0,0,0,0],buttons:b,timestamp:1};}
     function poll(down){pads[ix].buttons[2]={pressed:down,value:down?1:0};pads[ix].timestamp++;pollPad();}
     function step(down){g.t+=0.016;poll(down);updatePlayer(0.016);}
     function prompt(){texts=[];render2D(0);drawHUD();return texts;}
     function has(action){return texts.some(function(t){return t.indexOf('[x] '+action)===0;});}
     function reset(ammo,reserve){
       pads[ix].buttons[7]={pressed:false,value:0};poll(false);padRelease();keys={};PAD.prev=[];PAD.xAfterTrade=0;PAD.xNearN=null;
       p.hand=null;p.downed=false;p.roll=0;p.drawT=0;p.jam=0;p.cd=0;p.ammo=ammo;p.reserve=reserve;p.reloading=0;p.rlTot=0;p.rlArm=0;p.arStk=0;p.arBonus=0;p.lastShot=g.t*1000;p.hurtAt=-100;
       ct.opened=false;ct.prog=0;ct.pulled=0;ct.time=2;ct.loot=['bandage'];g.searching=null;g.searchT=0;g.nearDown=null;
       g.nearContainer=ct;g.nearPad=false;g.nearDoor=null;g.nearForge=null;g.nearPed=null;g.nearSeal=null;g.nearStray=null;
       step(false);INDEV.dev='pad';
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       INDEV.legacy=false; // v28.xx (cw-cx-xreloadsearch): __runPrep enables legacy pad hints; this check also exercises live switching back to keyboard.
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';__topClear();
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;g.ents=[];g.zones=[];g.t=10;p.iv=9999;
       ct=g.containers.filter(function(c){return !c.opened;})[0];if(!ct)return 'no box to stage';
       ct.x=p.x+12;ct.y=p.y;ct.auto=false;g.containers=[ct];p.wep=cloneObj(WEAPONS.rifle);
       CFG.xfPix=0;P.padmap=null;P.padSticks='';NET.on=false;netSamePost=function(){return true;};netPadFocused=function(){return true;};
       pads=[pd(0),pd(1)];navigator.getGamepads=function(){return pads;};
       hudPrompt=function(s){texts.push(String(s).toLowerCase());return hp.apply(this,arguments);};
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';NET.pair='cx-xreloadsearch';NET.padIx=-1;NET.padOther=-1;NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;ix=side?0:1;
         padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;
         for(q=0;q<4;q++){
           reset(q===0?0:2,q===3?1:60);
           if(PAD.ix!==ix)bad.push(NET.same+': wrong pad slot');
           if(g.nearContainer!==ct)return 'box staging is out of reach';
           if(q===2){p.lastShot=-1e9;p.reloading=p.wep.reload/2;p.rlTot=p.wep.reload;p.rlArm=1;}
           prompt();if(!has('reload'))bad.push(NET.same+'/'+q+': box prompt does not name reload');
           if(q===3)pads[ix].buttons[7]={pressed:true,value:1};
           step(true);if(!keys.KeyR||keys.KeyE)bad.push(NET.same+'/'+q+': X did not choose reload');
           for(j=0;j<500&&p.reloading>0;j++){
             if(g.searching)bad.push(NET.same+'/'+q+': searched before reload ended');
             p.lastShot=g.t*1000;step(true);
           }
           pads[ix].buttons[7]={pressed:false,value:0};
           if(p.reloading>0||!(p.reserve<(q===3?1:60)))bad.push(NET.same+'/'+q+': reload did not finish');
           poll(true);prompt();if(!has('search')||has('reload'))bad.push(NET.same+'/'+q+': held X prompt did not change to search');
           step(true);if(g.searching!==ct||!keys.KeyE||keys.KeyR)bad.push(NET.same+'/'+q+': held X did not start search after reload');
         }
         reset(p.wep.mag,60);prompt();if(!has('search'))bad.push(NET.same+': full magazine prompt is not search');
         step(true);if(g.searching!==ct||keys.KeyR)bad.push(NET.same+': full magazine X did not search');
         reset(2,0);prompt();if(!has('search'))bad.push(NET.same+': no reserve prompt is not search');
         step(true);if(g.searching!==ct||keys.KeyR)bad.push(NET.same+': no reserve X did not search');
         reset(2,60);g.nearDown={};poll(true);if(!keys.KeyE||keys.KeyR)bad.push(NET.same+': reload blocked revive');
         reset(2,60);step(true);poll(true);p.reloading=0;poll(true);
         if(PAD.xMode!=='KeyR'||keys.KeyE)bad.push(NET.same+': cancelled reload started search');
         reset(2,60);INDEV.dev='kb';prompt();
         if(padOn()||!texts.some(function(t){return t.indexOf('[e] search ')===0;}))bad.push(NET.same+': keyboard prompt changed: '+texts.join(' / '));
         keys.KeyE=true;updatePlayer(0.016);if(g.searching!==ct)bad.push(NET.same+': keyboard E no longer searches');keys.KeyE=false;
       }
       return bad.length?bad.join('; '):null;
     }finally{
       hudPrompt=hp;netPadFocused=nf;netSamePost=np;
       try{padRelease();NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(k){delete NET[k];});Object.assign(NET,nk);
       Object.assign(INDEV,ik);Object.assign(RUMBLE,rk);Object.assign(CFG,cp);P.padmap=pm;P.padSticks=ps;keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'35.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
