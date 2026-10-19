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

if ($s.Contains("  {v:'31.86',what:")) { throw "check 31.86 is in the fixture already" }

SubRx @'
  {v:'31.85',what:
'@ @'
  {v:'31.86',what:'J2 radial sticks: angle sweep, circular deadzone, full diagonal aim and two-second walk, eight wheel slots and boundaries, menu stepping',
   run:function(){
     var bad=[],g,p,i,j,a,m,q,d,err,stage='prepare',oldP=P,oldDz=CFG.padDz,oldSens=CFG.padSens,oldInv=CFG.padInvY,
         same=NET.same,ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),fake,oldSave=saveProfile,oldKeysPad=KEYS.pad;
     function need(ok,msg){ if(!ok&&bad.length<24) bad.push(msg); }
     function len(v){ return Math.hypot(v.x,v.y); }
     function angle(v,t){ return Math.abs(Math.atan2(Math.sin(Math.atan2(v.y,v.x)-t),Math.cos(Math.atan2(v.y,v.x)-t)))*180/Math.PI; }
     function stick(x,y){ return typeof padStick==='function'?padStick(x,y):{x:padAxis(x),y:padAxis(y)}; }
     function poll(ax,down){ var bt=[],k; down=down||[]; for(k=0;k<17;k++) bt.push({pressed:down.indexOf(k)>=0,value:down.indexOf(k)>=0?1:0}); fake={connected:true,index:0,id:'Xbox controller',mapping:'standard',axes:ax,buttons:bt}; pollPad(); }
     function walk(x,y){
       p.x=WORLD_W/2; p.y=WORLD_H/2; p.vx=0; p.vy=0; p.kickT=0; p.roll=0; p.rollCd=0; p.downed=false; p.dying=false; p.specOut=false; p.autoJog=false; p.stimT=0; p.ads=false;
       keys={}; mouse.down=false; g.crouchTog=false; var sx=p.x,sy=p.y;
       for(var k=0;k<120;k++){ poll([x,y,0,0]); updatePlayer(1/60); }
       return Math.hypot(p.x-sx,p.y-sy);
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.padDz=0.22; CFG.padSens=1; CFG.padInvY=0;
       stage='pure angle sweep';
       [0.30,0.60,0.95].forEach(function(raw){
         var worst=0,missing=0;
         for(var deg=0;deg<360;deg++){ var t=deg*Math.PI/180,v=stick(raw*Math.cos(t),raw*Math.sin(t)); if(len(v)===0) missing++; else worst=Math.max(worst,angle(v,t)); }
         need(missing===0&&worst<=0.5,'angle sweep '+raw+': '+missing+' zero vectors, '+worst.toFixed(3)+' degrees');
       });
       stage='deadzone and sensitivity';
       [0.12,0.22,0.32,0.4].forEach(function(dz){
         CFG.padDz=dz;
         for(var deg=0;deg<360;deg++){
           var t=deg*Math.PI/180,v=stick((dz-0.001)*Math.cos(t),(dz-0.001)*Math.sin(t));
           need(v.x===0&&v.y===0,'below circular deadzone '+dz+' at '+deg);
           v=stick((dz+0.01)*Math.cos(t),(dz+0.01)*Math.sin(t));
           need(len(v)>0&&angle(v,t)<=0.5,'above circular deadzone '+dz+' at '+deg);
         }
         need(len(stick(0.707,0.707))>=0.99,'full diagonal length at deadzone '+dz);
         need(Math.abs(len(stick(1,0))-1)<1e-9,'full straight length at deadzone '+dz);
       });
       CFG.padDz=0.22;
       [0.75,1,1.25,1.5].forEach(function(s){
         CFG.padSens=s;
         var t=0.37,v=stick(0.6*Math.cos(t),0.6*Math.sin(t)),want=Math.min(1,(0.6-0.22)/(1-0.22-0.06)*s);
         need(Math.abs(len(v)-want)<1e-9&&angle(v,t)<=0.5,'sensitivity must scale length: '+s);
       });
       CFG.padSens=1;
       stage='deploy'; P=JSON.parse(JSON.stringify(P)); P.padPreset='pillagers'; P.padSticks=''; P.padmap={}; saveProfile=function(){}; NET.same=false;
       __deploy({kit:['bandage','gun_shotgun'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'staging: no live raid';
       __topClear(); state='raid'; CFG.padDz=0.22; CFG.padSens=1; CFG.padInvY=0; g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; g.trade=null; g.forgeUI=null; g.wheel=null; g.ents.length=0;
       p=g.player; p.iv=99; p.hp=p.maxhp; p.cooking=null; p.roll=0; p.downed=false; p.dying=false; keys={}; mouse.down=false;
       PAD.prev=[]; PAD.prevMap=null; PAD.mSpent=null; PAD.held={}; PADB.waiting=null; PAD.reach=200; PAD.announced=true;
       navigator.getGamepads=function(){ return [fake]; };
       stage='poll move and aim';
       g.camX=p.x-W/(2*ZOOM()); g.camY=p.y-H*0.54/ZOOM();
       [0.30,0.60,0.95].forEach(function(raw){
         for(var deg=0;deg<360;deg+=15){
           var t=deg*Math.PI/180,x=raw*Math.cos(t),y=raw*Math.sin(t),want=Math.min(1,(raw-0.22)/0.72);
           poll([x,y,x,y]); var v={x:PAD.mx,y:PAD.my};
           need(len(v)>0&&angle(v,t)<=0.5,'poll move '+raw+' at '+deg);
           need(PAD.aiming&&angle({x:Math.cos(PAD.aimA),y:Math.sin(PAD.aimA)},t)<=0.5,'poll aim '+raw+' at '+deg);
           var reach=Math.hypot(mouse.x-W/2,mouse.y-H*0.54)/(PAD.reach*ZOOM());
           need(Math.abs(reach-want)<0.001,'poll aim reach '+raw+' at '+deg+': '+reach);
         }
       });
       stage='two-second walking';
       g.map.walls=[]; g.wgrid=null; g.map.water=[]; g.sim=true;
       [0.22,0.4].forEach(function(dz){
         CFG.padDz=dz; var straight=walk(1,0),diagonal=walk(0.707,0.707);
         need(straight>1&&Math.abs(diagonal/straight-1)<=0.01,'two-second walk at deadzone '+dz+': straight '+straight+', diagonal '+diagonal);
       });
       CFG.padDz=0.22; g.sim=false;
       stage='eight-slot wheel';
       poll([0,0,0,0]); poll([0,0,0,0],[13]);
       need(!!g.wheel&&g.wheel.pad===1,'pad did not open item wheel');
       if(g.wheel){
         need(g.wheel.list.length===8,'wheel does not have eight slots');
         for(i=0;i<8;i++){
           for(j=0;j<5;j++){
             var offset=[0,22.3,22.7,-22.3,-22.7][j]; a=(i*45-90+offset)*Math.PI/180;
             poll([0,0,0.95*Math.cos(a),0.95*Math.sin(a)],[13]); wheelTick(1/60);
             var expected=(i+(offset>22.5?1:offset< -22.5?-1:0)+8)%8;
             need(g.wheel.sel===expected,'wheel slot '+i+' offset '+offset+' selected '+g.wheel.sel);
           }
           a=(i*45-90)*Math.PI/180;
           poll([0,0,0.6*Math.cos(a),0.6*Math.sin(a)],[13]); wheelTick(1/60);
           need(g.wheel.sel===i,'wheel at raw 0.60 selected '+g.wheel.sel+' instead of '+i);
         }
         poll([0,0,0.1,0.1],[13]); wheelTick(1/60); need(g.wheel.sel===-1,'wheel did not cancel inside deadzone');
         g.wheel=null;
       }
       stage='menu stick stepping';
       poll([0,0,0,0]); keysOpen(true); var md=document.getElementById('keysmodal');
       var start=document.getElementById('padlayout'); padSetFocus(start);
       var expected=padLayoutStep(start,1); need(!!expected&&expected!==start,'staging: no next controller row');
       PAD.mrepAt=null; poll([0,0.95,0,0]); need(PAD.focus===expected,'left stick did not step to next controller row');
       return bad.length?bad.join('; '):null;
     }catch(e){ return stage+': '+String(e&&e.message||e); }
     finally{
       try{ PAD.on=false; padRelease(); PAD.mx=0; PAD.my=0; PAD.prev=[]; PAD.prevMap=null; PAD.mSpent=null; PAD.aiming=false; }catch(_p){}
       if(own) navigator.getGamepads=ng; else delete navigator.getGamepads;
       keys={}; mouse.down=false; KEYS.pad=oldKeysPad;
       try{ __endRaid('abandon'); }catch(_e){}
       P=oldP; saveProfile=oldSave; NET.same=same; CFG.padDz=oldDz; CFG.padSens=oldSens; CFG.padInvY=oldInv; __topClear();
     }
   }},
  {v:'31.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
