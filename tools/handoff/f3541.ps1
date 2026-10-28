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

if ($s.Contains("  {v:'35.41',what:")) { throw "check 35.41 is in the fixture already" }

SubRx @'
  {v:'35.40',what:
'@ @'
  {v:'35.41',what:'solo mouse, N and pad pings draw in world, minimap and map, follow unnumbered enemies for 10 s, and retain host and guest pings',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy';
     var keep={},nk=['on','role','seat','same','peers','upSeed','entMap','wps','pings','pingAt','pingLast','pingTarget'],i,g,e,p,q,m,world=0,shown=[],sent=[],sounds=0,pad,clock=100,
       ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),ao=ARCADE.on,at=ATT.on,
       mw=mouseWorld,bc=netBroadcast,bp=blip,cg=colourCueGlyph,pd=netPingDraw,pn=netPadNow,ns=netSend;
     nk.forEach(function(k){keep[k]=NET[k];});
     function fresh(){NET.pings=[];NET.pingAt=0;NET.pingLast=null;NET.pingTarget=null;sent=[];sounds=0;}
     function poll(b){for(var j=0;j<17;j++)pad.buttons[j]={pressed:j===b,value:j===b?1:0};pollPad();}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       NET.on=false;NET.same=null;NET.peers=[];ARCADE.on=false;ATT.on=false;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.rise=null;keys={};mouse.down=false;p.iv=999;
       CFG.xfPix=0;
       e=g.ents.filter(function(v){return v.hp>0&&!v.merc;})[0];if(!e)return 'no target to stage';
       delete e.nid;e.x=p.x+80;e.y=p.y-60;
       mouseWorld=function(){return {x:e.x,y:e.y};};
       netBroadcast=function(v){sent.push(v);};blip=function(k){if(k==='pick')sounds++;};
       colourCueGlyph=function(c,k){shown.push(k);return cg.apply(this,arguments);};
       netPingDraw=function(){var n=pd();world+=n;return n;};
       fresh();raidKey('Mouse1',false,null);
       if(NET.pings.length!==1)return 'middle mouse made no solo ping';
       q=NET.pings[0];if(q.target!==e||q.w!==netPingName(e))return 'unnumbered solo enemy was not tagged';
       if(sent.length||sounds!==1)return 'solo ping sent a packet or missed the ordinary sound';
       e.x+=20;e.y+=10;shown=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);
       if(q.x!==e.x||q.y!==e.y||shown.indexOf('target')<0)return 'solo enemy not followed/drawn on minimap';
       g.mapOpen=true;e.x+=20;shown=[];drawMapOverlayRaw();
       if(q.x!==e.x||shown.indexOf('target')<0)return 'solo ping missing or stale on full map';
       g.mapOpen=false;drawHUD();if(!world)return 'solo world ping is not drawn by HUD';
       q.at=Date.now()-9000;netPingDraw();if(NET.pings.length!==1)return 'ping ended before 10 seconds';
       q.at=Date.now()-10001;g.mapOpen=true;shown=[];drawMapOverlayRaw();
       if(NET.pings.length||shown.indexOf('target')>=0)return 'ping outlived 10 seconds on open map';
       g.mapOpen=false;fresh();raidKey('KeyN',false,null);if(NET.pings.length!==1)return 'N made no solo ping';
       raidKey('KeyN',true,null);if(NET.pings.length!==1)return 'key repeat added a ping';
       raidKey('KeyN',false,null);if(NET.pings.length!==1||!NET.pings[0].dg||NET.pings[0].target!==e)return 'solo double-tap lost danger or target';
       fresh();pad={connected:true,index:0,id:'Xbox solo ping',mapping:'standard',axes:[0,0,0,0],buttons:[]};
       navigator.getGamepads=function(){return [pad];};netPadNow=function(){return clock;};
       PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.announced=true;PAD.focus=null;PAD.duAt=null;PAD.duHeld=0;PAD.lossIx=-1;PAD.lossRaid=null;PAD.lost=null;PAD.claim=null;
       poll(-1);poll(12);clock+=.1;poll(-1);
       if(g.mapOpen||NET.pings.length!==1)return 'solo d-up tap opened map or failed to ping';
       fresh();poll(12);clock+=.5;poll(12);poll(-1);
       if(!g.mapOpen||NET.pings.length)return 'd-up hold failed to open map without ping';
       poll(12);clock+=.1;poll(-1);if(g.mapOpen)return 'd-up tap did not close map';
       navigator.getGamepads=function(){return [];};PAD.on=false;
       e.nid=91;NET.entMap={91:e};NET.on=true;NET.upSeed=g.seed;
       for(i=0;i<2;i++){
         NET.seat=i;NET.role=i?'join':'host';fresh();raidKey('Mouse1',false,null);m=NET.pingLast;
         if(!m||m.id!==91||sent.length!==1||NET.pings.length!==1)return 'party sender failed in seat '+i;
         NET.pings=[];m.s=1-i;
         if(netPingTake({state:'in',seat:1-i},m)!=='png'||NET.pings.length!==1)return 'party receiver failed in seat '+i;
         e.x+=20;netPingDraw();if(NET.pings[0].x!==e.x)return 'party target stopped following in seat '+i;
       }
       NET.role='host';NET.seat=0;NET.peers=[{state:'in',seat:1}];fresh();
       netSend=function(pe,v){sent.push({seat:pe.seat,m:v});return true;};
       if(netPileShare(0,'bandage',p.x,p.y)!==1||sent.length!==1||!sent[0].m.pl||NET.pings.length)return 'host drop no longer marks only the teammate';
       fresh();if(netPileShare(1,'bandage',p.x,p.y)!==1||NET.pings.length!==1||!NET.pings[0].pl||sent.length)return 'guest drop no longer marks only the host';
       NET.on=false;NET.peers=[];fresh();
       if(netPileShare(0,'bandage',p.x,p.y)||NET.pings.length||sent.length)return 'solo drop started making automatic pings';
       raidKey('KeyN',false,null);
       __endRaid('abandon');__topClear();__deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(NET.pings.length||NET.pingAt||NET.pingLast||NET.pingTarget)return 'ping state leaked into next solo raid';
       return null;
     }finally{
       mouseWorld=mw;netBroadcast=bc;blip=bp;colourCueGlyph=cg;netPingDraw=pd;netPadNow=pn;netSend=ns;
       NET.on=false;try{__endRaid('abandon');}catch(_e){}__topClear();keys={};mouse.down=false;
       nk.forEach(function(k){NET[k]=keep[k];});ARCADE.on=ao;ATT.on=at;
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'35.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
