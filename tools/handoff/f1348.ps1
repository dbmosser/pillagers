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
  {v:'13.47',what:
'@ @'
  {v:'13.48',what:'on a controller inside an extraction point X searches a box at his feet, as the [X] SEARCH prompt says, and with nothing in reach X still holds E for the dropship (audit item 4, 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid)) return 'SKIP: this fixture cannot drive a live raid';
     if(typeof pollPad!=='function') return 'SKIP: no pad poll in this build';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, keepTs=lastTs;
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
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||!g.zones.length) return 'SKIP: this map has no extraction point';
       var z=g.zones[0], p=g.player, box=null, i;
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(!c.opened&&c.loot&&c.loot.length){ box=c; break; } }
       if(!box) return 'SKIP: this landing has no container with anything left in it';
       g.ents.length=0; g.waveT=-1e9;
       box.x=z.x; box.y=z.y; box.opened=false;
       p.x=z.x; p.y=z.y; p.downed=false; p.iv=99;
       z.beaconT=null; z.hold=null; z.pullT=null; g.active=null; g.beaconT=null;
       keysOff(); padWith(-1); frames(3);
       if(__state().nearContainer!==box||!__state().nearPad) return 'SKIP: staging: the box on the ring was not found in reach ('+(__state().nearPad?'on the pad':'off the pad')+')';
       // THE FINDING: pad X on the ring with a box at his feet.
       padWith(2); frames(5);
       if(!__state().searching) bad.push('holding the pad X button on an extraction point with a box at his feet did not search it, while the prompt reads [X] SEARCH');
       padWith(-1); frames(2); keysOff();
       // CONTROL: the box moved out of reach, pad X is E again, the way out.
       g=__state(); g.searching=null; box.x=z.x+600; box.y=z.y;
       padWith(-1); frames(3);
       padWith(2); frames(2);
       if(!__keysRef()['KeyE']) bad.push('control: with nothing to search on the ring, the pad X button no longer holds E, so it cannot call the dropship');
       if(__keysRef()['KeyX']) bad.push('control: with nothing to search on the ring, the pad X button still holds X');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ keysOff(); }catch(_k){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var g3=__state(); if(g3&&g3.player){ g3.player.iv=0; g3.player.downed=false; } if(g3&&!g3.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
