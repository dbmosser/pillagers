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

# v13.16 CHECK, inserted before the v13.15 entry.
#
# IT SEARCHES A REAL CONTAINER ON THE REAL KEY. The award happens inside the
# search, so calling the award function directly would test a function rather
# than the thing he did. The container is one the map already made; only its
# contents are set, because a landing is not guaranteed to contain a plate and
# the plate is the thing under test.
#
# ARMOUR STARTS AT ZERO ON PURPOSE. The old line only applied a plate while
# armour was below the cap, so a full bar would have passed this check for
# entirely the wrong reason.
#
# FOUR ARMS, ONE PER HALF OF HIS SENTENCE: the bar must not move, the plate must
# be in the backpack, the tactical belt must offer it, and then equipping it must
# take its wind-up before the bar moves.
SubRx @'
  {v:'13.15',what:'the death card says you died carrying medical you never used, and says nothing when you did use one or had none to use (his telemetry: heals 0 and downs 2 on every run)',
'@ @'
  {v:'13.16',what:'a looted armour plate does not turn itself into armour: the bar does not move, the plate is in the backpack, the tactical belt offers it, and only the wind-up puts it on the bar (his note of 2026-09-12)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     if(typeof hotbarSlots!=='function'||typeof useArmor!=='function')
       return 'SKIP: this fixture cannot reach the belt or the equip path';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     function bagPlates(){
       var st=__state(),c=0;
       if(!st||!st.bag) return -1;
       for(var i=0;i<st.bag.length;i++){ var it=ITEMS[st.bag[i]]; if(it&&it.use==='armor') c++; }
       return c;
     }
     function beltHasPlate(){
       try{ var sl=hotbarSlots();
         for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='plate') return true;
       }catch(_b){}
       return false;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.containers||!g.containers.length) return 'SKIP: this landing has no containers';
       if(!ITEMS.plate||ITEMS.plate.use!=='armor') return 'SKIP: this build has no armour plate item';
       var box=null;
       for(var i=0;i<g.containers.length;i++){ if(!g.containers[i].opened){ box=g.containers[i]; break; } }
       if(!box) return 'SKIP: this landing has no unopened container';
       // A REAL container, contents set, because a landing is not guaranteed to
       // hold a plate and the plate is the thing under test.
       box.loot=['plate']; box.opened=false;
       var p=g.player;
       p.x=box.x; p.y=box.y; p.downed=false;
       // ZERO ON PURPOSE: the old line only applied a plate below the cap, so a
       // full bar would pass this for the wrong reason.
       p.armor=0;
       g.bag.length=0;
       keysOff(); frames(3);
       if(bagPlates()!==0) return 'SKIP: the staging did not start with an empty backpack';

       // SEARCH IT, on the real key, for as long as the real search takes.
       keysOff(); __keysRef()['KeyX']=true;
       for(var w=0;w<60;w++){ frames(10); if(box.opened) break; }
       keysOff(); frames(4);
       if(!box.opened) return 'SKIP: the container never opened, so nothing was looted';

       var s1=__state();
       if(Math.round(s1.player.armor)>0)
         bad.push('a plate found in a container turns itself straight into armour on the bar, so it can never be carried home, never be sold, never be put on a belt key and never be spent when he chooses, and the wind-up that makes armour a decision under fire is skipped');
       if(bagPlates()<1)
         bad.push('the looted plate is not in the backpack, so there is nothing to equip and nothing to carry out');
       if(!beltHasPlate())
         bad.push('the tactical belt does not offer the plate he just picked up, so the key he would reach for is not there');

       // AND THE WIND-UP IS WHAT PUTS IT ON THE BAR.
       var before=Math.round(__state().player.armor);
       useArmor();
       frames(2);
       var mid=Math.round(__state().player.armor);
       if(mid>before)
         bad.push('equipping a plate is instant, so the two second cost that makes it a decision under fire is not paid');
       frames(180);
       var after=Math.round(__state().player.armor);
       if(!(after>before))
         bad.push('the plate never reaches the armour bar at all, so it cannot be equipped and the item is dead weight');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.15',what:'the death card says you died carrying medical you never used, and says nothing when you did use one or had none to use (his telemetry: heals 0 and downs 2 on every run)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
