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

if ($s.Contains("  {v:'36.42',what:")) { throw "check 36.42 is in the fixture already" }

SubRx @'
  {v:'36.41',what:
'@ @'
  {v:'36.42',what:'no rolling in water: Space and pad A refuse without stamina or text, and a roll stops at the bank and wades, in both seats and career/arcade',
   run:function(){
     var bad=[],g,p,side,mode,usePad,ix,pads,j,k,tag,stam,x,y,wetX=1060,
         ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),
         pk=Object.assign({},PAD),nk=Object.assign({},NET),rk=Object.assign({},RUMBLE),cp=Object.assign({},CFG),
         kk=keys,mm=Object.assign({},mouse),nf=netPadFocused,np=netSamePost,bs=blip,ss=say,
         pm=P.padmap,ps=P.padSticks,hold=ARCADE.holdT,clanks=0,texts=0;
     function ok(v,msg){if(!v)bad.push(tag+': '+msg);}
     function pad(i){var b=[];for(var q=0;q<17;q++)b.push({pressed:false,value:0});return {connected:true,id:'Xbox Wireless Controller',index:i,mapping:'standard',axes:[1,0,0,0],buttons:b,timestamp:1};}
     function press(down){
       if(usePad){pads[ix].buttons[0].pressed=down;pads[ix].buttons[0].value=down?1:0;pads[ix].timestamp++;pollPad();}
       else document.dispatchEvent(new KeyboardEvent(down?'keydown':'keyup',{code:'Space',key:' ',bubbles:true,cancelable:true}));
     }
     function reset(x0,y0){
       p.x=x0;p.y=y0;p.roll=0;p.rollCd=0;p.rollWet=false;p.stam=100;p.stamLock=0;p.stamRelease=0;p.stimT=0;p.ads=false;
       p.downed=false;p.dying=false;p.drawT=0;p.hand=null;p.cooking=false;p.kickT=0;p.face=0;
       g.crouchTog=false;g.sprintOn=false;g.shWas=false;g.rollSayT=0;keys={KeyD:true};mouse.down=false;
       press(false);clanks=0;texts=0;
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});
       g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.ents=[];g.bagOpen=false;g.mapOpen=false;g.mapFirst=0;g.paused=false;g.trade=null;g.forgeUI=null;g.wheel=null;
       g.map.walls=[];g.map.buildings=[];g.map.water=[{x:wetX,y:850,w:400,h:400}];
       NET.on=false;netPadFocused=function(){return true;};netSamePost=function(){return true;};
       P.padmap=null;P.padSticks='';ARCADE.holdT=0;
       pads=[pad(0),pad(1)];navigator.getGamepads=function(){return pads;};
       blip=function(t){if(t==='clank')clanks++;};say=function(){texts++;};
       for(side=0;side<2;side++)for(mode=0;mode<2;mode++)for(usePad=0;usePad<2;usePad++){
         tag=(side?'p2':'host')+'/'+(mode?'arcade':'career')+'/'+(usePad?'pad':'space');
         NET.same=side?'p2':'host';NET.role=side?'join':'host';NET.seat=side?1:0;NET.pair='cx-waterroll';
         NET.padIx=-1;NET.padOther=-1;NET.padWas={pair:NET.pair,host:1,p2:0};NET.padFwd=null;ix=side?0:1;g.arcade=!!mode;
         padRelease();PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;PAD.lossRaid=null;PAD.lossIx=-1;PAD.lost=null;
         PAD.on=!!usePad;
         for(k=0;k<3;k++){
           reset(wetX+(k===0?1:40),1000);p.stam=k===2?10:100;stam=p.stam;
           press(true);ok(p.roll===0,'roll started in '+(k===0?'shallow':'deep')+' water');
           ok(p.stam===stam,'refused roll spent stamina');ok(clanks===1,'refusal did not make one clank');ok(texts===0,'refusal showed text');press(false);
         }
         reset(wetX-60,1000);press(true);press(false);
         ok(p.roll>0&&p.stam===100-ROLLSTAM,'dry roll did not start or paid the wrong cost');
         if(usePad)ok(PAD.ix===ix,'wrong controller slot');
         for(j=0;j<30&&p.roll>0;j++){g.t+=1/60;updatePlayer(1/60);}
         ok(p.roll===0,'roll did not end');ok(inWater(p.x,p.y),'roll stopped outside the water');
         ok(p.x>=wetX&&p.x<wetX+0.02,'roll crossed the bank at '+p.x);
         x=p.x;y=p.y;g.t+=1/60;updatePlayer(1/60);
         var moved=Math.hypot(p.x-x,p.y-y),want=Math.max(SPEED_FLOOR,CFG.pSpeed*armorById(p.rig).spd*CFG.wadeSpd)/60;
         ok(Math.abs(moved-want)<0.05&&!g.sprinting,'bank entry did not switch to wading speed: '+moved+'/'+want);
         reset(wetX-200,1000);press(true);press(false);
         for(j=0;j<30&&p.roll>0;j++){g.t+=1/60;updatePlayer(1/60);}
         ok(p.x<wetX&&p.x>wetX-90&&!p.rollWet,'ordinary dry roll changed');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       blip=bs;say=ss;netPadFocused=nf;netSamePost=np;ARCADE.holdT=hold;
       try{padRelease();if(g)g.arcade=false;NET.on=false;NET.same='';__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(a){delete PAD[a];});Object.assign(PAD,pk);
       Object.keys(NET).forEach(function(a){delete NET[a];});Object.assign(NET,nk);
       Object.assign(RUMBLE,rk);Object.assign(CFG,cp);P.padmap=pm;P.padSticks=ps;keys=kk;Object.assign(mouse,mm);
     }
   }},
  {v:'36.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
