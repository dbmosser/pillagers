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

# v13.32 CHECK, inserted before the v13.31 entry.
#
# ON THE PLAY PATH: it stands on the lift and presses the quick ascent key through the
# floor update, the way check 12.61 does, so the raid is started by the door itself.
# Then it steps the real frame loop, __loop, for about five seconds, which is past the
# 3.2 second weather line, and records every message shown. Three arms: a gun in the
# stash (the line must be shown), no gun in the stash, and a gun of his own equipped
# (the line must not be).
SubRx @'
  {v:'13.31',what:'the sector page the lift opens tells a player with nothing equipped that he has a gun of his own in his stash and how to take it, Equip as your gun, and only when his stash holds a gun (the pack guns wait there since his ruling)',
'@ @'
  {v:'13.32',what:'the quick ascent, which skips the sector page, tells a player who lands with a loaner that his own gun waits in his stash and how to take it, after the weather line rather than over it, and only when his stash holds a gun and nothing of his own is equipped',
   run:function(){
     if(!(window.__hubEnter&&window.__hb&&window.__keys&&window.__showScreen&&window.__state&&window.__endRaid&&window.__P&&window.__loop)) return 'SKIP: this fixture cannot walk the floor or step the loop';
     if(typeof updateHubWorld!=='function'||typeof startRaid!=='function') return 'SKIP: this build has no floor update or no raid to start';
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     var bad=[], P2=__P();
     var keep={equipped:P2.equipped,equippedSec:P2.equippedSec,weapons:(P2.weapons||[]).slice(),stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),freeKit:P2.freeKit,hot:JSON.parse(JSON.stringify(P2.hotAssign||{}))};
     var needle=['Equip','as','your','gun'].join(' ');
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     function ascend(equipped,weapons,stash){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       endAny();
       __showScreen('hub'); __hubEnter();
       var HBx=__hb(); if(!HBx||!HBx.stations) return {none:'no floor to stand on'};
       var lift=null, i;
       for(i=0;i<HBx.stations.length;i++) if(HBx.stations[i].id==='lift') lift=HBx.stations[i];
       if(!lift) return {none:'this build has no lift'};
       P2.freeKit=0; P2.kit=[]; P2.hotAssign={}; P2.equipped=equipped; P2.equippedSec='none'; P2.weapons=weapons.slice(); P2.stash=stash.slice();
       var K=__keys(), k;
       for(k in K) delete K[k];
       HBx.player.x=lift.x; HBx.player.y=lift.y; HBx.eLock=false;
       K.KeyR=1;
       for(i=0;i<6;i++) updateHubWorld(0.05);
       for(k in K) delete K[k];
       var G2=__state();
       if(!G2||G2.over||G2.sim) return {none:'the quick ascent key did not start a raid'};
       var seen=[], t0=performance.now();
       function note(){ var g=__state(); if(g&&g.msg&&seen.indexOf(g.msg)<0) seen.push(String(g.msg)); }
       note();
       for(i=0;i<300;i++){ __loop(t0+(i+1)*16.7); note(); }
       return {issued:!!G2.player.wepIssued, seen:seen};
     }
     try{
       // ONE: nothing equipped, a pack gun in the stash. He lands with a loaner.
       var A=ascend('fists',['pistol'],['gun_smg','bandage']);
       if(A.none) return 'SKIP: '+A.none;
       if(!A.issued) return 'SKIP: staging: the quick ascent did not issue a loaner, so there is nothing to measure';
       var hitA=A.seen.filter(function(m){ return m.indexOf(needle)>=0; });
       if(!hitA.length)
         bad.push('a player who takes the quick ascent with nothing equipped lands with a loaner and is never told his own gun waits in the stash [shown: '+A.seen.join(' | ').slice(0,200)+']');

       // TWO: nothing equipped, and no gun in the stash either.
       var B=ascend('fists',['pistol'],['bandage']);
       if(!B.none&&B.seen.some(function(m){ return m.indexOf(needle)>=0; }))
         bad.push('a player with no gun in his stash is told on landing to equip one from it');

       // THREE: a gun of his own equipped, another in the stash. No loaner, no line.
       var C=ascend('pistol',['pistol'],['gun_smg']);
       if(!C.none&&C.issued) bad.push('staging: a player with his own pistol equipped was issued a loaner');
       else if(!C.none&&C.seen.some(function(m){ return m.indexOf(needle)>=0; }))
         bad.push('a player who went up with his own gun is told he is carrying a loaner');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ P2.equipped=keep.equipped; P2.equippedSec=keep.equippedSec; P2.weapons=keep.weapons; P2.stash=keep.stash; P2.kit=keep.kit; P2.freeKit=keep.freeKit; P2.hotAssign=keep.hot; saveProfile(); }catch(_r){}
       try{ var K2=__keys(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.31',what:'the sector page the lift opens tells a player with nothing equipped that he has a gun of his own in his stash and how to take it, Equip as your gun, and only when his stash holds a gun (the pack guns wait there since his ruling)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
