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

if ($s.Contains("  {v:'28.37',what:")) { throw "check 28.37 is in the fixture already" }

SubRx @'
  {v:'28.36',what:
'@ @'
  {v:'28.37',what:'cloud-coop-pad-active-reload: on a controller (player 2) X in the sweet spot of a reload lands the active reload even with a box in reach, as R does on the keyboard; a downed teammate in reach still takes the revive, and X early or late in the reload next to a box still searches',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof pollPad!=='function'||typeof PAD==='undefined'||typeof activeReloadTick!=='function'||typeof AR_A!=='number') return 'SKIP: no pad or active reload in this fixture';
     var bad=[], gp, hadOwn=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), kNG=navigator.getGamepads, kPAD={on:PAD.on,aiming:PAD.aiming,curOwn:PAD.curOwn,brand:PAD.brand,aimA:PAD.aimA}, r;
     function mkpad(down){ var bt=[], q, d; for(q=0;q<17;q++){ d=down.indexOf(q)>=0; bt.push({pressed:d,value:d?1:0}); } return {connected:true,id:'Xbox Wireless Controller',index:0,axes:[0,0,0,0],buttons:bt,mapping:'standard'}; }
     function poll(down){ gp=mkpad(down); navigator.getGamepads=function(){ return [gp]; }; pollPad(); }
     function trial(withBox,frac,down){
       var o={}, g, p, ct=null, i;
       __topClear(); __runPrep(); __deploy({kit:[],mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return null;
       p=g.player; keys={}; mouse.down=false; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null;
       p.wep=cloneObj(WEAPONS.smg||WEAPONS.pistol); p.ammo=0; p.reserve=60; p.hand=null; p.jam=0; p.iv=99;
       for(i=0;i<g.containers.length;i++){ if(!g.containers[i].opened){ ct=g.containers[i]; break; } }
       if(withBox){ if(!ct) return null; ct.x=p.x+12; ct.y=p.y; }
       else { for(i=0;i<g.containers.length;i++){ if(dist(p,g.containers[i])<200) g.containers[i].x+=5000; } }
       PAD.prev=[]; PAD.xWas=false; PAD.xMode=null; PAD.xAfterTrade=0; PAD.xNearN=null;
       poll([]); updatePlayer(0.016); o.near=!!g.nearContainer;
       p.reloading=p.wep.reload; p.rlTot=0; activeReloadTick(p);
       p.reloading=p.rlTot*(1-frac);
       if(down) g.nearDown={x:p.x,y:p.y,downed:true};
       poll([2]); o.xMode=PAD.xMode;
       activeReloadTick(p); o.arBonus=p.arBonus||0;
       if(down) g.nearDown=null;
       updatePlayer(0.016); o.searching=!!g.searching;
       poll([]);
       try{ __endRaid('abandon'); }catch(_e){}
       return o;
     }
     try{
       r=trial(false,0.5,false);
       if(!r) return 'SKIP: no raid for the bare trial';
       if(r.xMode!=='KeyR'||r.arBonus!==1) bad.push('with nothing near, X in the sweet spot read '+JSON.stringify(r));
       r=trial(true,0.5,false);
       if(!r||!r.near) return 'SKIP: no box could be put in reach';
       if(r.xMode!=='KeyR'||r.arBonus!==1||r.searching) bad.push('next to a box, X in the sweet spot did not land the active reload: '+JSON.stringify(r));
       r=trial(true,0.5,true);
       if(r&&r.xMode!=='KeyE') bad.push('next to a downed teammate, X in the sweet spot no longer picks the revive: '+JSON.stringify(r));
       r=trial(true,0.3,false);
       if(r&&(r.xMode!=='KeyE'||r.arBonus)) bad.push('next to a box, X early in the reload (0.3) no longer searches: '+JSON.stringify(r));
       r=trial(true,0.7,false);
       if(r&&(r.xMode!=='KeyE'||r.arBonus)) bad.push('next to a box, X late in the reload (0.7) no longer searches: '+JSON.stringify(r));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hadOwn) navigator.getGamepads=kNG; else delete navigator.getGamepads; }catch(_n){}
       try{ PAD.prev=[]; PAD.xWas=false; PAD.xMode=null; PAD.xNearN=null; PAD.xAfterTrade=0; PAD.on=kPAD.on; PAD.aiming=kPAD.aiming; PAD.curOwn=kPAD.curOwn; PAD.brand=kPAD.brand; PAD.aimA=kPAD.aimA; if(typeof padRelease==='function') padRelease(); }catch(_p){}
       keys={}; mouse.down=false;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
