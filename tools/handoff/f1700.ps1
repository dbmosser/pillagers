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

if ($s.Contains("  {v:'17.00',what:")) { throw "check 17.00 is in the fixture already" }

SubRx @'
  {v:'16.99',what:
'@ @'
  {v:'17.00',what:'a controller X is a new press after a pad gap or after another screen had the pad, and X pressed during a roll onto a box chooses when the roll ends: each time, X held beside a box in reach holds E and searches instead of holding the reload key from before',
   run:function(){
     if(typeof pollPad!=='function'||typeof updatePlayer!=='function'||typeof padRelease!=='function'||typeof PAD==='undefined'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this fixture cannot stage a controller raid';
     var NGA=navigator.getGamepads, oSay=say, keepN={on:NET.on,same:NET.same}, k0=keys, padKeep=null, m0={x:mouse.x,y:mouse.y,down:mouse.down,init:mouse.init}, bad=[], dn=false, none=false, p=null, ct=null, c, z, q, ok, kk;
     function pad(){ if(none) return []; var b=[],n; for(n=0;n<17;n++) b.push({pressed:(n===2&&dn),value:(n===2&&dn)?1:0,touched:(n===2&&dn)}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function poll(d){ dn=!!d; pollPad(); }
     function held(){ return ((keys['KeyR']?'R ':'')+(keys['KeyE']?'E ':'')+(keys['KeyX']?'X':'')).trim()||'nothing'; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player||state!=='raid'||!G.containers||!G.zones) return 'SKIP: staging: no raid';
       padKeep={}; for(kk in PAD) padKeep[kk]=PAD[kk]; padKeep.prev=(PAD.prev||[]).slice(); if(PAD.held){ padKeep.held={}; for(kk in PAD.held) padKeep.held[kk]=PAD.held[kk]; }
       k0=keys; keys={}; say=function(){}; NET.on=false; NET.same=''; navigator.getGamepads=pad;
       p=G.player; p.roll=0; p.rollCd=0; p.downed=false; p.reloading=0; if(p.wep) p.ammo=p.wep.mag;
       G.sim=0; G.bagOpen=false; G.mapOpen=false; G.paused=false; G.trade=null; mouse.down=false; PAD.xAfterTrade=0;
       none=true; poll(false); none=false; poll(false);
       for(c=0;c<G.containers.length&&c<60&&!ct;c++){
         q=G.containers[c]; if(!q||q.opened||q.auto) continue;
         ok=true; for(z=0;z<G.zones.length;z++) if(dist(q,G.zones[z])<G.zones[z].r+60) ok=false;
         if(!ok) continue;
         p.x=q.x+6; p.y=q.y; G.nearContainer=null; updatePlayer(0.001);
         if(G.nearContainer&&!G.nearPad) ct=G.nearContainer;
       }
       if(!ct) return 'SKIP: staging: no box could be put in reach';
       G.searching=null; G.searchT=0;
       // ONE: a pad gap between two X presses. The first press, with nothing in reach, reloads.
       G.nearContainer=null; G.nearPad=false; G.nearDown=null; G.nearDoor=null; G.nearPed=null;
       poll(true);
       if(!keys['KeyR']||keys['KeyE']) return 'SKIP: staging: X with nothing in reach did not hold R here ('+held()+')';
       none=true; poll(false); none=false;
       G.nearContainer=ct; poll(true);
       if(!keys['KeyE']||keys['KeyR']) bad.push('after a pad gap, X pressed again beside a box held '+held()+', not E: the press was not seen as new');
       poll(false);
       // TWO: X let go and pressed again while another screen had the pad.
       G.nearContainer=null; poll(true);
       state='zqxcheck'; poll(false); poll(true); state='raid';
       G.nearContainer=ct; poll(true);
       if(!keys['KeyE']||keys['KeyR']) bad.push('X pressed again while another screen had the pad, held beside a box back in the raid, held '+held()+', not E');
       poll(false);
       // THREE: X pressed during a roll onto the box, and still held after landing.
       G.nearContainer=null; G.searching=null; p.roll=0.02; p.rollDir={x:0,y:0};
       poll(true);
       updatePlayer(0.05);
       if(p.roll>0) return bad.length?bad.join('; '):'SKIP: staging: the roll did not end';
       poll(true); updatePlayer(0.05);
       if(!G.nearContainer) return bad.length?bad.join('; '):'SKIP: staging: the box was not in reach after the roll';
       poll(true); updatePlayer(0.05);
       if(!G.searching) bad.push('X pressed during a roll onto a box and held after landing did not search (held '+held()+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(state==='zqxcheck') state='raid';
       try{ none=true; dn=false; pollPad(); }catch(e0){}
       navigator.getGamepads=NGA; say=oSay; NET.on=keepN.on; NET.same=keepN.same;
       try{ if(padKeep){ for(kk in PAD) if(!(kk in padKeep)) delete PAD[kk]; for(kk in padKeep) PAD[kk]=padKeep[kk]; } }catch(e1){}
       keys=k0||{}; mouse.x=m0.x; mouse.y=m0.y; mouse.down=m0.down; mouse.init=m0.init;
       try{ if(p) p.roll=0; if(G){ G.searching=null; G.searchT=0; } __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
