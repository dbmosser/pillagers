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

if ($s.Contains("  {v:'37.54',what:")) { throw "check 37.54 is in the fixture already" }

SubRx @'
  {v:'37.53',what:
'@ @'
  {v:'37.54',what:'extracted host watches the partner live and can ping without acting or rejoining; retained career host and extracted player 2 also ping',
   run:function(){
     var g, nk={}, ak={}, staged=false, k, sent=[], send0=netSend, fast0=netSendFast, mate, e, packet, cam, p, px, py, mag, peer={state:'in',seat:1,name:'partner'};
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||!g.player) return 'no raid';
       for(k in NET) nk[k]=NET[k]; for(k in ARCADE) ak[k]=ARCADE[k]; staged=true;
       g.sim=false; g.arcade=true; g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false;
       ARCADE.on=true; ARCADE.role='host'; ARCADE.solo=false; ARCADE.xOut=0; ARCADE.ext=0; ARCADE.ownAt=Date.now(); ARCADE.mateAt=Date.now();
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.upOut={}; NET.specG=null; NET.peers=[peer]; NET.max=4;
       NET.roster=[{seat:0,name:'watcher'},{seat:1,name:'partner'}];
       p=g.player; px=p.x; py=p.y;
       mate={seat:1,n:1,age:0,sd:g.seed>>>0,x:2600,y:2000,tx:2600,ty:2000,f:0,tf:0,dn:0}; NET.up=[mate];
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; }; netSendFast=function(){return true;};
       if(!arcadeExtractEnd()||!p.specOut||ARCADE.xOut!=='h') return 'host did not extract and stay out';
       arcadeAttTick(); if(ATT.on) return 'extracted host is covered by attract';
       if(typeof netWatchOn!=='function'||!netWatchOn()) return 'host has no watch view';
       render2D(0); cam={x:g.camX,y:g.camY,z:ZOOM()}; if(Math.hypot(cam.x+W/(2*cam.z)-mate.x,cam.y+H/(2*cam.z)-mate.y)>40) return 'watch camera is not on partner';
       mate.x+=120; mate.tx=mate.x; cam=adsCameraFrame(.016); if(Math.abs(cam.x+W/(2*cam.z)-mate.x)>40) return 'watch camera did not follow';
       g.camX=cam.x; g.camY=cam.y;
       e=g.ents.filter(function(q){return q.kind==='crawler'&&q.hp>0;})[0]; if(!e) return 'no crawler';
       e.x=mate.x+100; e.y=mate.y; netEntsInit(g); NET.pingAt=0; NET.pingLast=null; NET.pings=[];
       mouse.x=(e.x-g.camX)*cam.z; mouse.y=(e.y-g.camY)*cam.z;
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyN',key:'n',bubbles:true,cancelable:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyN',key:'n',bubbles:true,cancelable:true}));
       packet=sent.filter(function(m){return m.t==='png'&&m.id===e.nid;}).pop(); if(!packet||String(packet.w).toLowerCase()!=='crawler') return 'watcher key sent no named crawler ping';
       mag=p.wep&&p.wep.mag;
       raidKey('KeyE',false); raidKey('KeyB',false); raidKey('Space',false);
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true}));
       if(mouse.down||keys.KeyE||g.bagOpen||!p.specOut||p.x!==px||p.y!==py||(p.wep&&p.wep.mag)!==mag) return 'watcher acted or rejoined';
       netPingMake(); if(!NET.pingLast.dg) return 'double ping is not danger';
       // Deliver the actual host packet through the receiving role, retaining the watcher seat.
       NET.role='join'; NET.seat=1; NET.pings=[]; NET.wps={}; peer={state:'in',seat:0}; NET.peers=[peer];
       if(netOnMsg(peer,JSON.stringify(packet))!=='png'||!NET.pings.length||NET.pings[0].s!==0||String(NET.pings[0].w).toLowerCase()!=='crawler') return 'partner did not receive watcher crawler identity';
       ARCADE.role='p2'; g.arcX=1; NET.pingAt=0; if(!netWatchOn()||!netPingMake()) return 'extracted player 2 cannot ping';
       ARCADE.on=false; g.arcade=false; NET.role='host'; NET.seat=0; NET.specG=g; g.over='extract'; NET.pingAt=0;
       g.mapOpen=true; g.mapCur={x:0,y:0}; packet=netPingMake(); if(!packet||packet.id!==e.nid) return 'career spectator ping used map or was blocked';
       NET.specG=null; if(netWatchOn()||netPingMake()) return 'finished raid still accepts watch pings';
       return null;
     }finally{
       netSend=send0; netSendFast=fast0; mouse.down=false; keys={};
       if(staged){
         for(k in NET) if(!(k in nk)) delete NET[k]; for(k in nk) NET[k]=nk[k];
         for(k in ARCADE) if(!(k in ak)) delete ARCADE[k]; for(k in ak) ARCADE[k]=ak[k];
       }
       if(g){g.arcade=false;g.over=false;g.mapOpen=false;} try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'37.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
