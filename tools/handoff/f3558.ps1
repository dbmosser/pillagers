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

if ($s.Contains("  {v:'35.58',what:")) { throw "check 35.58 is in the fixture already" }

SubRx @'
  {v:'35.57',what:
'@ @'
  {v:'35.58',what:'a partner-called ship survives the host extracting, reaches player 2 without an active pull, and still boards them; solo extraction still ends and doubles score',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof arcadeDeploy!=='function'||typeof netWorldSend!=='function'||typeof netBeaconTake!=='function') return 'SKIP: no extraction fixture';
     var h, j, hz, z, ix, i, k, nk={}, ak={}, peer={state:'in',seat:1}, wd=null, out=null,
         send=netSendFast, post=netSamePost, hostMine=1500, hostMate=400;
     function need(ok,msg){ if(!ok) throw Error(msg); }
     function deploy(){
       ARCADE.role='host';
       need(arcadeDeploy({mapIx:0,seed:4242}), 'could not stage an arcade raid');
       var g=__state(); need(g&&g.player&&!g.over, 'no live arcade player');
       CFG.xfPix=0; keys={}; mouse.down=false; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null;
       ARCADE.ownAt=Date.now(); ARCADE.mateAt=Date.now(); ARCADE.run={id:'cx-partnership'};
       g.ents.length=0; g.player.iv=999; g.player.downed=false; g.player.buzz=0;
       return g;
     }
     function board(g){ for(var n=0;n<40&&!g.arcX&&!g.arcEnd;n++) tryExtractTick(0.1,true); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(k in NET) nk[k]=NET[k]; for(k in ARCADE) ak[k]=ARCADE[k];
       netSendFast=function(p,m){ if(m.t==='wd') wd=JSON.parse(JSON.stringify(m)); return true; };
       netSamePost=function(m){ if(m.t==='arcx') out=JSON.parse(JSON.stringify(m)); return true; };
       h=deploy(); ARCADE.role='host'; ARCADE.solo=0; ARCADE.mine=hostMine; ARCADE.mate=hostMate;
       NET.on=true; NET.role='host'; NET.same='host'; NET.seat=0; NET.upSeed=h.seed>>>0;
       NET.peers=[peer]; NET.up=[{seat:1,x:h.player.x,y:h.player.y,hp:100,age:0}];
       ix=h.zones.findIndex(function(q){return q&&q.open!==false;}); need(ix>=0,'no open ring'); hz=h.zones[ix];
       hz.beaconT=null; hz.hold=null; h.player.x=hz.x; h.player.y=hz.y;
       need(netBeaconTake(peer,{i:ix,g:0})==='called','partner call was not accepted by the host');
       hz.beaconT=0; tickExtractPoints(0.05); need(hz.hold>0,'partner ship did not land');
       board(h);
       need(h.arcX&&h.player.specOut&&!h.arcEnd,'host did not extract while the partner stayed in');
       need(hz.beaconT!==null&&hz.hold>0,'host extraction dismissed the partner ship');
       need(hz.hold<30&&h.shipHold===hz.hold,'boarding time or the host mirror was reset');
       for(i=0;i<h.zones.length;i++) need(h.zones[i].pullT===null&&h.zones[i].boardT===0&&h.zones[i].pullFloor===0,'host boarding progress survived');
       // World packets round clocks to hundredths through netNum, unlike the live floating-point timer.
       var left=hz.hold, wireLeft=netNum(left), sent=netWorldSend();
       need(sent===1&&wd&&wd.z[ix]&&wd.z[ix][2]===wireLeft,'host did not transmit the live ship: sent '+sent+', hold '+left+', packet '+(wd&&wd.z[ix]&&wd.z[ix][2]));
       // Receive the real world packet in the other role with no pull or recent-call grace period.
       NET.on=false; j=deploy(); ARCADE.role='p2'; ARCADE.solo=0; ARCADE.mine=500;
       NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=j.seed>>>0; NET.peers=[peer]; NET.up=[];
       z=j.zones[ix]; z.pullT=null; delete z.netCallAt; j.player.x=z.x; j.player.y=z.y;
       need(netWorldTake(peer,wd)==='wd','player 2 rejected the world packet');
       need(z.beaconT!==null&&z.hold===wireLeft,'player 2 lost the ship without a pull in progress');
       board(j); need(j.arcX&&j.player.specOut&&out&&out.t==='arcx','player 2 could not board the retained ship');
       // Deliver player 2 extraction back to the already extracted host.
       G=h; ARCADE.role='host'; ARCADE.mine=hostMine; ARCADE.mate=hostMate; ARCADE.xOut='h';
       NET.role='host'; NET.same='host'; NET.seat=0;
       need(arcadeOnMsg(out)==='arcx'&&h.arcEnd==='extract','both extractions did not end the run');
       need(ARCADE.mine+ARCADE.mate===4000,'both-out extraction score was not doubled once');
       NET.on=false; h.arcEnd=null;
       // Solo control uses the same boarding path and still ends immediately.
       var s=deploy(); ARCADE.role='host'; ARCADE.solo=1; ARCADE.mine=700; ARCADE.mate=0;
       z=s.zones[ix]; s.active=z; z.open=true; z.beaconT=0; z.hold=20; z.holdMax=30; z.pullT=null;
       s.player.x=z.x; s.player.y=z.y; board(s);
       need(s.arcEnd==='extract'&&ARCADE.mine===1400&&!s.player.specOut,'solo extraction changed');
       return null;
     }catch(e){ return String(e&&e.message||e); }
     finally{
       netSendFast=send; netSamePost=post; keys={};
       try{ NET.on=false; ARCADE.ini=null; if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       for(k in nk) NET[k]=nk[k]; for(k in ak) ARCADE[k]=ak[k];
       __topClear();
     }
   }},
  {v:'35.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
