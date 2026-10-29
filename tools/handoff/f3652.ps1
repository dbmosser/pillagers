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

if ($s.Contains("  {v:'36.52',what:")) { throw "check 36.52 is in the fixture already" }

SubRx @'
  {v:'36.51',what:
'@ @'
  {v:'36.52',what:'one mark per seat: middle mouse, map click, move, toggle, clear, persistence, target expiry and host relay in all three views',
   run:function(){
     var keep={},ks=['on','role','seat','peers','pings','wps','pingAt','pingLast','pingTarget','entMap','upSeed'],g,p,e,m,first,i,j,MP,shown=[],sent=[],world=[],arcs=[];
     var mw=mouseWorld,bc=netBroadcast,ns=netSend,cg=colourCueGlyph,pl=netPingLabel,arc=ctx.arc,x0=mouse.x,y0=mouse.y;
     ks.forEach(function(k){keep[k]=NET[k];});
     function at(x,y){mouseWorld=function(){return {x:x,y:y};};}
     function click(button,x,y){var b=cv.getBoundingClientRect();mouse.x=x;mouse.y=y;cv.dispatchEvent(new MouseEvent('mousedown',{button:button,clientX:b.left+x,clientY:b.top+y,bubbles:true,cancelable:true}));cv.dispatchEvent(new MouseEvent('mouseup',{button:button,bubbles:true}));}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.on=false;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.rise=null;keys={};mouse.down=false;CFG.xfPix=0;
       netBroadcast=function(v){sent.push(v);};netSend=function(pe,v){sent.push(v);return true;};
       netPingLabel=function(t,x,y,r){world.push(t);return pl.apply(this,arguments);};
       colourCueGlyph=function(c,k,x,y,s){shown.push(k);return cg.apply(this,arguments);};
       ctx.arc=function(x,y,r){arcs.push({x:x,y:y,r:r});return arc.apply(this,arguments);};
       for(i=0;i<2;i++){
         NET.on=!!i;NET.role=i?'join':'host';NET.seat=i;NET.upSeed=g.seed;NET.pings=[];NET.wps={};NET.pingAt=0;NET.pingLast=null;g.waypoint=null;
         // v28.xx (cw-cx-onemark): an empty point under the cursor in the real seeded world.
         first=null;for(j=0;j<100&&!first;j++){var q={x:p.x+(j%10-5)*95,y:p.y+(Math.floor(j/10)-5)*95};if(q.x>0&&q.y>0&&q.x<WORLD_W&&q.y<WORLD_H&&!g.ents.some(function(v){return v.hp>0&&!v.merc&&dist(v,q)<NET_PING_SNAP+2;}))first=q;}
         if(!first)return 'cannot stage empty cursor point';
         at(first.x,first.y);raidKey('Mouse1',false,null);
         if(!g.waypoint||NET.pings.length!==1||g.waypoint!==NET.pings[0])return 'middle mouse did not set the one shared mark in seat '+i;
         m=NET.pings[0];m.at=Date.now()-60000;netPingUpdate();if(NET.pings[0]!==m||!g.waypoint)return 'spot faded';
         shown=[];arcs=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);if(!MMAP.got.wp)return 'spot missing on minimap';
         g.mapOpen=true;arcs=[];drawMapOverlayRaw();MP=mapProj();if(!arcs.some(function(a){return Math.abs(a.x-(MP.ox+m.x*MP.sc))<2&&Math.abs(a.y-(MP.oy+m.y*MP.sc))<2;}))return 'middle mouse spot missing on map';
         var nx=clamp(first.x+200,20,WORLD_W-20),ny=clamp(first.y+180,20,WORLD_H-20);
         click(0,MP.ox+nx*MP.sc,MP.oy+ny*MP.sc);
         if(!g.waypoint||Math.abs(g.waypoint.x-nx)>3||NET.pings.length!==1)return 'map click did not move same mark';
         g.mapOpen=false;world=[];if(netPingDraw()!==1||!world.some(function(t){return /\d+m/.test(t);}))return 'map mark missing raid marker/distance';
         at(first.x,first.y);raidKey('KeyN',false,null);if(NET.pings.length!==1||NET.pings[0].x!==Math.round(first.x))return 'second ping did not move mark';
         raidKey('KeyN',false,null);if(g.waypoint||NET.pings.length)return 'pinging own mark did not clear';
         at(first.x,first.y);raidKey('Mouse1',false,null);g.mapOpen=true;click(2,MP.ox+80,MP.oy+80);
         if(g.waypoint||NET.pings.length)return 'right click did not clear both';g.mapOpen=false;
         if(netMarkColour(0)!=='#ffc04a'||netMarkColour(1)!=='#6fe0ff')return 'seat colours differ';
         NET.on=true;NET.role=i?'join':'host';NET.peers=[{state:'in',seat:1-i},{state:'in',seat:2}];sent=[];
         var peer=NET.peers[0];netPingTake(peer,{s:1-i,x:first.x,y:first.y,spot:1});
         if(NET.pings.length!==1||NET.pings[0].s!==1-i||!NET.pings[0].spot||!NET.wps[1-i])return 'partner did not keep mark';
         shown=[];netWpMapDraw(0,0,.1);if(shown.indexOf('place')<0)return 'partner map lost mark';
         world=[];if(netPingDraw()!==1||world.length!==1)return 'partner raid missing or duplicate';
         if(!i&&(sent.length!==1||sent[0].s!==1))return 'host failed relay';
         netPingTake(peer,{s:1-i,x:first.x+90,y:first.y+80,spot:1});if(NET.pings.length!==1||NET.pings[0].x!==first.x+90)return 'partner move left old mark';
         netPingTake(peer,{s:1-i,clr:1});if(NET.pings.length||NET.wps[1-i])return 'partner clear left mark';
         NET.on=false;e=g.ents.filter(function(v){return v.hp>0&&!v.merc;})[0];NET.pingAt=0;
         at(e.x,e.y);raidKey('KeyN',false,null);m=NET.pings[0];if(!m||m.spot||m.target!==e)return 'entity lost timed tracking';
         e.x+=5;netPingUpdate();if(m.x!==e.x||g.waypoint.x!==e.x)return 'entity map position stale';
         m.at=Date.now()-10001;netPingUpdate();if(NET.pings.length||g.waypoint)return 'entity failed expiry';
       }
       return null;
     }finally{
       mouseWorld=mw;netBroadcast=bc;netSend=ns;colourCueGlyph=cg;netPingLabel=pl;ctx.arc=arc;mouse.x=x0;mouse.y=y0;
       NET.on=false;try{__endRaid('abandon');}catch(_e){}__topClear();keys={};mouse.down=false;ks.forEach(function(k){NET[k]=keep[k];});
     }
   }},
  {v:'36.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
