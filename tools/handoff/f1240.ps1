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

# v12.40 CHECK, inserted before the v12.39 entry. One room, three arms. A
# reviver and a downed man twenty units apart on a crew number no raid can
# roll, the player parked a thousand units away so the stage sits outside both
# the crawl-for-cover range and the engage range, and nobody else in the roster.
# The downed man is given a distinctive maximum health so the health he stands
# up on can only have been written by the pickup.
SubRx @'
  {v:'12.39',what:'a death that takes the sidearm empties gun slot 2, and the ascent check stops naming a gun that is no longer in the armoury (2026-09-07 audit, dead-slot2)',
'@ @'
  {v:'12.40',what:'a merc told to loot on his own does not pick up a downed HOSTILE pillager who happens to share his crew number; he still picks up one who has thrown in with you, and an ordinary crew still picks its own up (2026-09-07 audit, merc-loots-hostiles)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__P&&window.__identityIds))
       return 'SKIP: this fixture cannot hire a merc and step the pillagers';
     var P=window.__P(), ids=window.__identityIds(), bad=[];
     if(!ids.length) return 'SKIP: no identity to hire';
     var svMerc=P.merc, svCred=P.credits;
     // THE STAGE, three arms on one room. A reviver and a downed pillager twenty
     // units apart on the ground the hired man spawned on, both stamped crew 7 -
     // raiderCrews is 2, so 7 is a number no raid can roll and can only have come
     // from here. You are parked a thousand units away, which puts the stage
     // outside the crawl-for-cover branch (700) and outside engageNear (600), so
     // the downed man does not crawl out of reach and mercEngage never fires.
     // Nobody else is in G.ents. The order is LOOT, the order the finding names.
     // His bag is emptied because raiderUseKit heals a hurt pillager from his own
     // bag and would blur the 311 the pickup writes. Five seconds at 0.1 against
     // the 3.2 second pickup.
     function arm(mode){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.merc=ids[0]; P.credits=1000;
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, e, M=null, pool=[];
       for(i=0;i<g.ents.length;i++){
         e=g.ents[i];
         if(e.kind!=='raider') continue;
         if(e.merc){ if(!M) M=e; }
         else if(!e.downed&&!e.finished) pool.push(e);
       }
       if(!M) return {skip:'the hired merc did not spawn'};
       if(pool.length<2) return {skip:'fewer than two ordinary pillagers on this map and seed'};
       var E=(mode==='crew')?pool[0]:M, D=pool[1];
       var keepEnts=g.ents, keepOrder=g.mercOrder, keepHold=g.mercHold,
           keepRev=(g.tel?(g.tel.crewRevives||0):null), out=null;
       try{
         g.mercOrder='loot'; g.mercHold=null;
         p.downed=false; p.hp=p.maxhp; p.iv=99;
         p.x=(M.x+1000<WORLD_W-60)?(M.x+1000):(M.x-1000); p.y=M.y;
         E.x=M.x; E.y=M.y; E.crew=7; E.state='loot'; E.downed=false; E.finished=false;
         E.reviving=null; E.revProg=0; E.hp=E.maxhp; E.hostile=E.merc?false:true; E.friendlyPC=0;
         D.x=M.x+20; D.y=M.y; D.crew=7; D.downed=1; D.downT=16; D.state='down';
         D.finished=false; D.reviveT=0; D.maxhp=777; D.hp=50; D.bag=[]; D.healQ=0;
         D.hostile=(mode==='side')?false:true; D.friendlyPC=(mode==='side')?1:0;
         g.ents=[E,D];
         for(var f=0;f<50;f++) __ents(0.1);
         out={up:(!D.downed&&!D.finished), hp:Math.round(D.hp),
              latched:(E.reviving===D), gone:!!D.finished};
       } finally {
         // The raid itself is this check own deploy and the next check deploys
         // its own, but the roster array, the order, the hold point and the revive
         // counter are read by anything that runs after this one.
         g.ents=keepEnts; g.mercOrder=keepOrder; g.mercHold=keepHold;
         if(g.tel&&keepRev!==null) g.tel.crewRevives=keepRev;
       }
       return out;
     }
     try{
       // THE FINDING: your hire, told to loot on his own, and a downed HOSTILE
       // pillager who happens to carry his crew number.
       var A=arm('hostile');
       if(A.skip) return 'SKIP: '+A.skip;
       if(A.gone) bad.push('control: the downed man bled out inside the five seconds, so this arm never asked the question');
       else if(A.up) bad.push('the man you hired left your job and picked up a downed HOSTILE pillager because they share a crew number: he is on his feet with '+A.hp+' health and shooting at you again');
       else if(A.latched) bad.push('the man you hired broke off and knelt over a downed HOSTILE pillager of his crew number; the pickup was still running at five seconds');
       // CONTROL 1: AN ORDINARY CREW STILL PICKS ITS OWN UP, in this same room.
       // Without it, a fix that stopped every pickup everywhere would read green.
       var B=arm('crew');
       if(B.skip) return 'SKIP: '+B.skip;
       if(!B.up) bad.push('control: an ordinary pillager did not pick his own downed crewmate up in the same room (health '+B.hp+', bled out '+B.gone+'), so the stage produces no pickup at all and the merc arm proves nothing');
       else if(B.hp!==311) bad.push('control: the crewmate stood up on '+B.hp+' health, not the 311 the pickup writes (40 percent of the 777 this stage gave him), so something other than the pickup stood him up');
       // CONTROL 2: AND YOUR HIRE STILL PICKS UP A MAN ON YOUR SIDE who shares the
       // number, which is what separates a side test from a blanket ban on the man
       // you paid for helping anybody at all.
       var C=arm('side');
       if(C.skip) return 'SKIP: '+C.skip;
       if(!C.up) bad.push('control: the man you hired no longer picks up a downed pillager who has thrown in with you and shares his crew number (health '+C.hp+', bled out '+C.gone+'), so the fix bans him from helping anyone instead of telling the two sides apart');
     } finally {
       P.merc=svMerc; P.credits=svCred;
       __resetCfg(); __cleanProfile(); __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.39',what:'a death that takes the sidearm empties gun slot 2, and the ascent check stops naming a gun that is no longer in the armoury (2026-09-07 audit, dead-slot2)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
