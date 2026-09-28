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

if ($s.Contains("  {v:'17.04',what:")) { throw "check 17.04 is in the fixture already" }

SubRx @'
  {v:'17.03',what:
'@ @'
  {v:'17.04',what:'a controller player down inside an uncalled ring calls for extraction by holding X however he got there: downed, X holds E and starts the call, never the reload key or the ring search left over from where he fell',
   run:function(){
     if(typeof pollPad!=='function'||typeof updatePlayer!=='function'||typeof PAD==='undefined'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this fixture cannot stage a controller raid';
     var NGA=navigator.getGamepads, oSay=say, keepN={on:NET.on,same:NET.same}, k0=keys, padKeep=null, m0={x:mouse.x,y:mouse.y,down:mouse.down,init:mouse.init}, bad=[], dn=false, none=false, p=null, z=null, i, kk;
     function pad(){ if(none) return []; var b=[],n; for(n=0;n<17;n++) b.push({pressed:(n===2&&dn),value:(n===2&&dn)?1:0,touched:(n===2&&dn)}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function poll(d){ dn=!!d; pollPad(); }
     function held(){ return ((keys['KeyR']?'R ':'')+(keys['KeyE']?'E ':'')+(keys['KeyX']?'X':'')).trim()||'nothing'; }
     function stale(){ G.nearContainer=null; G.nearPad=false; G.nearDown=null; G.nearDoor=null; G.nearPed=null; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||state!=='raid'||!G.zones) return 'SKIP: staging: no raid';
       padKeep={}; for(kk in PAD) padKeep[kk]=PAD[kk]; padKeep.prev=(PAD.prev||[]).slice(); if(PAD.held){ padKeep.held={}; for(kk in PAD.held) padKeep.held[kk]=PAD.held[kk]; }
       k0=keys; keys={}; say=function(){}; NET.on=false; NET.same=''; navigator.getGamepads=pad;
       p=G.player; p.roll=0; p.rollCd=0; p.downed=false; p.reloading=0; if(p.wep) p.ammo=p.wep.mag;
       G.sim=0; G.bagOpen=false; G.mapOpen=false; G.paused=false; G.trade=null; G.searching=null; mouse.down=false; PAD.xAfterTrade=0;
       none=true; poll(false); none=false; poll(false);
       for(i=0;i<G.zones.length&&!z;i++) if(G.zones[i].open&&G.zones[i].beaconT===null&&!(G.zones[i].hold>0)) z=G.zones[i];
       if(!z) return 'SKIP: staging: no open uncalled ring';
       // CONTROL: standing with nothing in reach, X holds R, so the press is seen and the setter works.
       stale(); poll(true);
       if(!keys['KeyR']||keys['KeyE']) return 'SKIP: staging: X standing with nothing in reach did not hold R here ('+held()+')';
       // ONE: X still held from before, and he goes down.
       p.downed=true; p.downT=60; p.healLock=true; poll(true);
       if(!keys['KeyE']||keys['KeyR']) bad.push('X held since standing and still held once downed held '+held()+', not E');
       poll(false);
       // TWO: he went down outside the ring and crawled in; a fresh press with the reach of where he fell (nothing).
       p.x=z.x; p.y=z.y; z.callT=0; stale(); poll(true);
       if(!keys['KeyE']||keys['KeyR']) bad.push('downed inside an uncalled open ring, a fresh X held '+held()+', not E');
       updatePlayer(0.1);
       if(!(z.callT>0)) bad.push('downed inside an uncalled open ring with X held, the call for extraction did not start');
       poll(false);
       // THREE: the reach left from his last standing frame says a box in a ring; on the floor X holds E, not the search key.
       G.nearPad=true; G.nearContainer=(G.containers&&G.containers[0])||{x:p.x,y:p.y}; poll(true);
       if(!keys['KeyE']||keys['KeyX']) bad.push('downed, with a box in a ring left in reach from his last standing frame, X held '+held()+', not E');
       poll(false);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ none=true; dn=false; pollPad(); }catch(e0){}
       navigator.getGamepads=NGA; say=oSay; NET.on=keepN.on; NET.same=keepN.same;
       try{ if(padKeep){ for(kk in PAD) if(!(kk in padKeep)) delete PAD[kk]; for(kk in padKeep) PAD[kk]=padKeep[kk]; } }catch(e1){}
       keys=k0||{}; mouse.x=m0.x; mouse.y=m0.y; mouse.down=m0.down; mouse.init=m0.init;
       try{ if(p){ p.downed=false; p.roll=0; } if(z) z.callT=0; if(G){ G.nearContainer=null; G.nearPad=false; G.searching=null; G.searchT=0; } __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
