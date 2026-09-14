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
  {v:'13.50',what:
'@ @'
  {v:'13.51',what:'on a controller in an extraction point the way out stays reachable: X still searches a box it can open, but with the search refused (a full backpack) X holds E for the call after a short grace, and with nothing in reach X holds E at once (key prompt audit 2026-09-14, my v13.48 regression)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot drive a live raid';
     if(typeof pollPad!=='function'||typeof bagWeight!=='function') return 'SKIP: no pad poll or bag weight in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, keepTs=lastTs, keepBW=bagWeight, P2=__P(), keepAuto=P2.autoloot;
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padWith(down){
       var bts=[],i;
       for(i=0;i<16;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     var T0=Math.max(performance.now(),(lastTs||0)+100);
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.autoloot=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||!g.zones.length) return 'SKIP: this map has no extraction point';
       var z=g.zones[0], p=g.player, box=null, i;
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ box=c; break; } }
       if(!box) return 'SKIP: this landing has no container with anything left in it';
       g.ents.length=0; g.waveT=-1e9;
       box.x=z.x; box.y=z.y; box.opened=false; box.prog=0;
       p.x=z.x; p.y=z.y; p.downed=false; p.iv=99;
       z.beaconT=null; z.hold=null; z.pullT=null; g.active=null; g.beaconT=null;
       keysOff(); padWith(-1); frames(3);
       if(__state().nearContainer!==box||!__state().nearPad) return 'SKIP: staging: the box on the ring was not found in reach';
       // ARM A, KEPT FROM v13.48: a box that can be searched is searched.
       padWith(2); frames(5);
       if(!__state().searching) bad.push('holding pad X on the ring with an openable box at his feet no longer searches it');
       padWith(-1); frames(2); keysOff();
       // ARM B, THE FINDING: the search is refused (a full backpack), so the box never opens.
       g=__state(); g.searching=null; box.prog=0;
       bagWeight=function(){ return 1e9; };
       padWith(-1); frames(3);
       padWith(2); frames(30);
       if(!__keysRef()['KeyE']) bad.push('with the search refused by a full backpack, half a second of pad X on the ring still did not hold E, so he cannot call for extraction while that box sits at his feet');
       if(__keysRef()['KeyX']) bad.push('with the search refused, pad X still holds X half a second in');
       padWith(-1); frames(2); keysOff();
       bagWeight=keepBW;
       // CONTROL: nothing in reach, X is the call at once.
       g=__state(); g.searching=null; box.x=z.x+600; box.y=z.y;
       padWith(-1); frames(3);
       padWith(2); frames(2);
       if(!__keysRef()['KeyE']) bad.push('control: with nothing to search on the ring, pad X does not hold E');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ bagWeight=keepBW; }catch(_bw){}
       try{ P2.autoloot=keepAuto; }catch(_al){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ keysOff(); }catch(_k){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var g3=__state(); if(g3&&g3.player){ g3.player.iv=0; g3.player.downed=false; } if(g3&&!g3.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
