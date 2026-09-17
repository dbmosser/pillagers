$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.32',what:
'@ @'
  {v:'15.33',what:'a missed extraction offers another call only when one can arrive: a landed window that runs out with 200 seconds on the raid clock still tells him to call for another, one that runs out with half an extraction wait left says the raid clock beats a call instead, and one that runs out past the point closing time offers no call while the point shuts in that same tick (extraction audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tickExtractPoints!=='function'||typeof raidClockOn!=='function'||typeof say!=='function'||typeof sayWhenFree!=='function'||typeof blip!=='function') return 'SKIP: no extraction tick, raid clock test, say, queued line or blip in this build';
     var bad=[], g=null, p=null, z=null, z2=null, keepZ=null, keepG=null, keepP=null, keepMiss, hadTel=false;
     var _say=say, _swf=sayWhenFree, _blip=blip, lines=[], queued=[], heard=[];
     var ZK=['open','closeAt','warned','beaconT','hold','holdMax','pullT','callT','boardT','pullFloor','siege','siegeSpawnT','siegeSpawned','siegeGreed','pullN','pinged','pingT'];
     // Assembled, so the needles are never written out whole in the page.
     var LEFT=['Extraction','left','without','you'].join(' '), CALL=['call','for','another'].join(' '), CLOCK=['raid','clock'].join(' '), SHUT=['is','closed'].join(' ');
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Every point quiet, then this one landed with 0.01 s of window left, him 300 units off its middle, the clock at tl. One
     // extraction tick of 0.05 s runs the window out. Returns the missed extraction line it said, or null.
     function run(Z,tl){
       for(var qi=0;qi<g.zones.length;qi++){ var q=g.zones[qi]; q.beaconT=null; q.hold=null; q.pullT=null; q.callT=0; }
       Z.open=true; Z.warned=1; Z.beaconT=-1; Z.hold=0.01; Z.holdMax=5; Z.pullT=null; Z.siege=0; Z.siegeSpawnT=0; Z.siegeSpawned=0;
       g.active=Z; g.siege=0; g.siegeSpawnT=0; g.timeLeft=tl;
       p.x=Z.x+300; p.y=Z.y;
       lines.length=0; queued.length=0; heard.length=0;
       tickExtractPoints(0.05);
       for(var i=0;i<lines.length;i++) if(lines[i].indexOf(LEFT)===0) return lines[i];
       return null;
     }
     function shutSaid(){ for(var i=0;i<queued.length;i++) if(queued[i].indexOf(SHUT)>=0) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.sim||!g.zones||!g.zones.length||!g.tel) return 'SKIP: no live raid with an extraction point and a raid record';
       p=g.player;
       // CONTROL: this raid runs a clock, and a new call takes long enough that half of it is a whole second.
       if(!raidClockOn()) return 'SKIP: the raid clock is off here, so no window can end with too little clock left';
       var W=CFG.extractWait;
       if(!(W>=2&&W<150)) return 'SKIP: a call takes '+W+' seconds here';
       for(var zi=0;zi<g.zones.length;zi++){
         var ZZ=g.zones[zi];
         if(!z&&ZZ.closeAt===undefined) z=ZZ;
         else if(!z2&&ZZ.closeAt!==undefined&&ZZ.closeAt-5>W) z2=ZZ;
       }
       if(!z){ for(var zj=0;zj<g.zones.length;zj++) if(g.zones[zj]!==z2){ z=g.zones[zj]; break; } }
       if(!z) return 'SKIP: only one extraction point here';
       keepZ=[]; for(var zk=0;zk<g.zones.length;zk++){ var kz={}; for(var ki=0;ki<ZK.length;ki++) kz[ZK[ki]]=g.zones[zk][ZK[ki]]; keepZ.push(kz); }
       keepG={active:g.active,beaconT:g.beaconT,shipHold:g.shipHold,shipHoldMax:g.shipHoldMax,siege:g.siege,siegeSpawnT:g.siegeSpawnT,siegeSpawned:g.siegeSpawned,timeLeft:g.timeLeft,msg:g.msg,msgT:g.msgT,msgQ:(g.msgQ?g.msgQ.slice():g.msgQ),ents:g.ents.slice()};
       keepP={x:p.x,y:p.y};
       hadTel=true; keepMiss=g.tel.beaconMissed;
       // No machine near a ring, so nothing the siege does can reach a line or a sound.
       g.ents.length=0;
       // The clock cases use a point with no closing time; on a map where every point has one, this one loses it (restored below).
       z.closeAt=undefined;
       say=function(m){ lines.push(String(m)); };
       sayWhenFree=function(m){ queued.push(String(m)); };
       blip=function(t){ heard.push(String(t)); };
       // CONTROL: with 200 seconds on the clock the window runs out, the clank sounds and the point stays open, on either build.
       var c0=run(z,200);
       if(!c0) return 'SKIP: staging: a window run out with 200 seconds on the clock said no missed extraction line here ('+(lines.join(' | ')||'nothing said')+')';
       if(z.hold!==null||z.beaconT!==null||heard.indexOf('clank')<0||!z.open) return 'SKIP: staging: the window did not end cleanly here (window '+z.hold+', open '+z.open+', sounds '+(heard.join(',')||'none')+')';
       // KEPT: with a new call able to arrive, the line still offers one.
       if(c0.indexOf(CALL)<0) bad.push('a window that ran out with 200 seconds on the raid clock no longer told him to call for another: '+c0);
       // THE FIX, CLOCK: the window runs out with half an extraction wait on the clock, so a new call arrives after the raid ends.
       var tl=Math.max(1,Math.floor(W/2));
       var c1=run(z,tl);
       if(!c1||z.hold!==null) return skip('staging: a window run out with '+tl+' seconds on the clock said no missed extraction line here');
       if(c1.indexOf(CALL)>=0) bad.push('a window that ran out with '+tl+' seconds on the raid clock still told him to call for another, a call that takes '+W+' seconds and cannot arrive: '+c1);
       else if(c1.indexOf(CLOCK)<0) bad.push('a window that ran out with '+tl+' seconds on the raid clock offered no call and did not say why: '+c1);
       // THE FIX, CLOSING: the window of a point runs out 5 seconds past its closing time, with plenty of clock left.
       if(!z2) return skip('no other point here has a closing time more than an extraction wait from the end of the raid');
       var tc=z2.closeAt-5;
       var c2=run(z2,tc);
       if(!c2||z2.hold!==null) return skip('staging: a window run out past its closing time said no missed extraction line here');
       // CONTROL: the close loop shut that point in the same tick and queued its closed line, on either build.
       if(z2.open||!shutSaid()) return skip('staging: the point past its closing time was not shut in the same tick here (open '+z2.open+', queued '+(queued.join(' | ')||'nothing')+')');
       if(c2.indexOf(CALL)>=0) bad.push('a window that ran out 5 seconds past the point closing time still told him to call for another at a point shut in that same tick: '+c2);
       if(c2.indexOf(CLOCK)>=0) bad.push('a window that ran out past the point closing time blamed the raid clock with '+tc+' seconds left: '+c2);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; sayWhenFree=_swf; blip=_blip;
       try{ if(g&&keepZ){ for(var rz=0;rz<keepZ.length&&rz<g.zones.length;rz++){ for(var rk in keepZ[rz]) g.zones[rz][rk]=keepZ[rz][rk]; } } }catch(_z){}
       try{
         if(g&&keepG){
           g.active=keepG.active; g.beaconT=keepG.beaconT; g.shipHold=keepG.shipHold; g.shipHoldMax=keepG.shipHoldMax;
           g.siege=keepG.siege; g.siegeSpawnT=keepG.siegeSpawnT; g.siegeSpawned=keepG.siegeSpawned; g.timeLeft=keepG.timeLeft;
           g.msg=keepG.msg; g.msgT=keepG.msgT; g.msgQ=keepG.msgQ;
           g.ents.length=0; for(var ke=0;ke<keepG.ents.length;ke++) g.ents.push(keepG.ents[ke]);
         }
       }catch(_g){}
       try{ if(p&&keepP){ p.x=keepP.x; p.y=keepP.y; } }catch(_pp){}
       try{ if(g&&hadTel&&g.tel) g.tel.beaconMissed=keepMiss; }catch(_t){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
