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

# v12.59 CHECK, inserted before the v12.58 entry. He is stood on the lift, which
# is the station whose key starts a raid, and the floor is stepped by its own
# update rather than by anything this check invents. The CONTROL runs first and
# with the backpack shut: the key must start a raid, or a quiet floor in the
# finding arm would only mean this check cannot drive a station at all.
SubRx @'
  {v:'12.58',what:'a weather pinned in Settings stops asking to change: with the turn clock expired the picker is not called at all, instead of thirteen seeded draws every frame for the rest of the raid, while an unpinned weather in the same state still asks and still turns (2026-09-06 in-raid audit, developer-facing)',
'@ @'
  {v:'12.59',what:'the open Undercroft backpack stops the floor: standing on the lift with it open, the key that starts a raid does nothing and no station is armed underneath, while with the backpack shut the same key still sends him up (2026-09-08 audit of the unlooked-at regions)',
   run:function(){
     if(!(window.__hubEnter&&window.__hb&&window.__keys&&window.__showScreen&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot walk the floor';
     if(typeof updateHubWorld!=='function'||typeof hubBagOpenSet!=='function') return 'SKIP: this build has no floor update or no Undercroft backpack';
     var bad=[];
     function stand(bagOpen){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       __showScreen('hub'); __hubEnter();
       var HBx=__hb(); if(!HBx||!HBx.stations) return {none:'no floor to stand on'};
       var lift=null, i;
       for(i=0;i<HBx.stations.length;i++) if(HBx.stations[i].id==='lift') lift=HBx.stations[i];
       if(!lift) return {none:'this build has no lift to stand on'};
       var K=__keys(), k;
       for(k in K) delete K[k];
       HBx.player.x=lift.x; HBx.player.y=lift.y; HBx.eLock=false;
       hubBagOpenSet(!!bagOpen);
       K.KeyR=1;
       var started=false, j;
       for(j=0;j<6&&!started;j++){
         updateHubWorld(0.05);
         try{ if(window.__screen&&window.__screen()==='raid') started=true; }catch(_s){}
         try{ var gg=__state(); if(gg&&gg.player&&!gg.over) started=true; }catch(_g){}
       }
       for(k in K) delete K[k];
       var near=HBx.near?HBx.near.id:null;
       hubBagOpenSet(false);
       return {started:started,near:near,lock:!!HBx.eLock};
     }
     try{
       // CONTROL FIRST: backpack shut. The key MUST send him up, or a quiet floor
       // below would only say this check cannot drive a station at all.
       var C=stand(false);
       if(!C) return 'SKIP: no floor to stand on';
       if(C.none) return 'SKIP: '+C.none;
       if(!C.started) return 'SKIP: with the backpack shut the key did not start a raid, so this check cannot drive the lift and proves nothing';
       // THE FINDING: the same key, the same spot, with the backpack open.
       try{ var g1=__state(); if(g1&&!g1.over){ g1.player.downed=false; __endRaid('abandon'); } }catch(_1){}
       var A=stand(true);
       if(A.none) return 'SKIP: '+A.none;
       if(A.started)
         bad.push('reading the backpack on the lift and pressing the ascent key started a raid from behind the panel: no sector page, no day reset, no question about what he was taking up, and the prompt that would have warned him is painted over by the panel he is looking at');
       if(A.near)
         bad.push('with the backpack open the floor still had him standing on the '+A.near+' station, so every key that station answers is live underneath the panel');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ hubBagOpenSet(false); }catch(_b){}
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __showScreen('hub'); }catch(_h){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.58',what:'a weather pinned in Settings stops asking to change: with the turn clock expired the picker is not called at all, instead of thirteen seeded draws every frame for the rest of the raid, while an unpinned weather in the same state still asks and still turns (2026-09-06 in-raid audit, developer-facing)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
