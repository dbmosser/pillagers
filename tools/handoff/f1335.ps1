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

# v13.35 CHECK, inserted before the v13.34 entry.
#
# ON THE PLAY PATH: X held at a real box through __loop, which is the staged pull a
# player uses, and the message line read only after whole frames with msgT above
# zero, so a line written and written over inside one frame is never seen. Two arms:
# the best gun in the table with the second slot free, and a stim with the belt plan
# cleared. Machines and waves are removed first (the r1334c lesson), and boxes in the
# hot zone are skipped so no bonus line is pushed in. An arm counts only when its item
# really reached its place; if neither does, the check skips rather than passes.
SubRx @'
  {v:'13.34',what:'the what-is-new card tells a player coming back that the welcome pack now goes to the stash and how to take a gun from it, Equip as your gun, within the entries the card draws, and its stamp is not older than the stash ruling',
'@ @'
  {v:'13.35',what:'searching a box the way he does, with X held, shows where the item went: a better gun taken into the free second slot and a stim pinned to a free key on the tactical belt each get their line on screen once Took runs out, instead of both being written over by Took in the same frame (2026-09-13 hunt)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid)) return 'SKIP: this fixture cannot drive a live raid';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof ITEMS==='undefined'||typeof WEAPONS==='undefined'||typeof WTIER==='undefined') return 'SKIP: this fixture cannot reach the item tables';
     var bad=[], measured=0;
     var slotNeedle=['to','your','empty','slot'].join(' ');
     var beltNeedle=['to','belt','slot'].join(' ');
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     // WHAT IS ON SCREEN: the message drawn is G.msg while msgT is above zero, read
     // after every whole frame. A line written and written over inside one frame is never here.
     function watch(n,seen){
       for(var f=0;f<n;f++){
         frames(1);
         var g0=__state(); if(!g0||g0.over) return;
         if(g0.msg&&g0.msgT>0&&(seen.length===0||seen[seen.length-1]!==String(g0.msg))) seen.push(String(g0.msg));
       }
     }
     function at(seen,needle){ for(var i=0;i<seen.length;i++) if(seen[i].indexOf(needle)>=0) return i; return -1; }
     function shown(seen){ return '['+seen.join(' | ').slice(0,240)+']'; }
     // THE PLAY PATH: one item staged in the box, X held until it opens, then hands
     // off while the message line plays out (up to ten seconds, stopping once found).
     function searchOut(box,key,needle){
       var g1=__state(), p1=g1.player;
       box.loot=[key]; box.opened=false; box.prog=0; box.pulled=0;
       if(!(box.time>0)) box.time=2;
       p1.x=box.x; p1.y=box.y; p1.downed=false;
       keysOff(); frames(3);
       g1.msgQ=[]; g1.msgT=0; g1.msg='';
       var seen=[];
       __keysRef()['KeyX']=true;
       for(var w=0;w<90&&!box.opened;w++) watch(10,seen);
       keysOff();
       if(!box.opened) return null;
       for(var r=0;r<20&&at(seen,needle)<0;r++) watch(30,seen);
       return seen;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||g.sim||!g.containers) return 'SKIP: no live raid with containers to search';
       // Nothing else may speak while the line is read: no machines and no wave (the r1334c lesson).
       g.ents.length=0; g.waveT=-1e9;
       var p=g.player, k, it, i;
       var boxes=[];
       for(i=0;i<g.containers.length&&boxes.length<2;i++){
         var c=g.containers[i];
         if(c.opened||c.strong||c.cache||c.dropped||c.auto) continue;
         if(g.hotZone&&Math.hypot(c.x-g.hotZone.x,c.y-g.hotZone.y)<=g.hotZone.r+20) continue;   // no bonus pushed in at the open
         boxes.push(c);
       }
       if(boxes.length<2) return 'SKIP: this landing has fewer than two plain unopened containers';
       // ONE: THE BEST GUN IN THE TABLE, with the second slot free.
       var best=null, bt=-1;
       for(k in ITEMS){ it=ITEMS[k]; if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]){ var t=WTIER[it.gk]||0; if(t>bt){ bt=t; best=k; } } }
       if(best&&bt>(WTIER[p.wep.id]||0)){
         p.sec=null;
         var s1=searchOut(boxes[0],best,slotNeedle);
         var sec=__state().player.sec;
         if(s1&&sec&&sec.id===ITEMS[best].gk){
           measured++;
           var slotAt=at(s1,slotNeedle), tookAt=at(s1,'Took ');
           if(slotAt<0)
             bad.push('a better gun searched out of a box went into his free second slot and the line saying so, and how to swap to it, never reached the screen '+shown(s1)+': Took wrote over it in the same frame');
           else if(tookAt>=0&&slotAt<tookAt)
             bad.push('the second slot line showed and was then written over by Took '+shown(s1));
         }
       }
       // TWO: A STIM, with the belt plan cleared so a free key takes it.
       var stimK=null;
       for(k in ITEMS){ it=ITEMS[k]; if(it&&it.use==='stim'){ stimK=k; break; } }
       if(stimK){
         var g2=__state(); g2.hotAssign={}; g2.hotAuto={};
         var s2=searchOut(boxes[1],stimK,beltNeedle);
         var pinned=false, g3=__state();
         for(var hb in (g3.hotAssign||{})) if(g3.hotAssign[hb]===stimK) pinned=true;
         if(s2&&pinned){
           measured++;
           if(at(s2,beltNeedle)<0)
             bad.push('a stim searched out of a box took a key on his tactical belt and the line naming the key never reached the screen '+shown(s2)+': the Found line wrote over it and Took wrote over that');
         }
       }
       if(!measured) return 'SKIP: neither pull took the branch under test (no better gun into a free second slot, no stim onto a free belt key)';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.34',what:'the what-is-new card tells a player coming back that the welcome pack now goes to the stash and how to take a gun from it, Equip as your gun, within the entries the card draws, and its stamp is not older than the stash ruling',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
