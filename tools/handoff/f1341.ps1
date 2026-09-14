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

# v13.41 CHECK, inserted before the v13.40 entry. Three arms per sector that authors
# decks: decks 1 must build them (the control, so this check can see a deck), the
# default must build none and leave no edge wall and no lift, and every container
# and machine must sit where it sat with the decks in. Then a walk through the real
# frame loop, north across where the DOCK CATWALK stood.
SubRx @'
  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
'@ @'
  {v:'13.41',what:'the raised decks are gone from both sectors: no deck, ramp or deck edge wall is left in a raid, he walks straight north across where the DOCK CATWALK stood, and every container and machine on the seed sits where it did with the decks in (his report of 2026-09-13)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot deploy and drive the player';
     if(typeof FIXED_MAPS==='undefined'||!FIXED_MAPS.length) return 'SKIP: this build has no authored maps';
     var bad=[], keepTs=lastTs, mi, i, sectors=0;
     function prints(g){
       var s=[], c;
       for(c=0;c<g.containers.length;c++) s.push(Math.round(g.containers[c].x)+','+Math.round(g.containers[c].y));
       for(c=0;c<g.ents.length;c++){ var e=g.ents[c]; if(e.kind==='sentry'||e.kind==='crawler') s.push(e.kind+Math.round(e.x)+','+Math.round(e.y)); }
       return s.join(';');
     }
     function fresh(){ __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); }
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     try{
       for(mi=0;mi<Math.min(2,FIXED_MAPS.length);mi++){
         var D=FIXED_MAPS[mi], nm=(D&&D.name)||('sector '+mi);
         if(!(D&&D.plats&&D.plats.length)) continue;
         sectors++;
         // CONTROL: decks 1 builds them, so a zero below is the build and not a blind check.
         fresh(); CFG.decks=1;
         __deploy({kit:[],mapIx:mi,seed:4242});
         var g1=__state(); if(!g1||!g1.map){ delete CFG.decks; return 'SKIP: no live raid on '+nm; }
         var led1=0; for(i=0;i<g1.map.walls.length;i++) if(g1.map.walls[i].ledge) led1++;
         var plats1=(g1.map.plats||[]).length, print1=prints(g1);
         endAny(); delete CFG.decks;
         // THE BUILD: the default raid.
         fresh();
         __deploy({kit:[],mapIx:mi,seed:4242});
         var g2=__state(); if(!g2||!g2.map) return 'SKIP: no second raid on '+nm;
         var M=g2.map, led=0;
         for(i=0;i<M.walls.length;i++) if(M.walls[i].ledge) led++;
         if(!plats1||!led1) bad.push('control: decks 1 on '+nm+' built '+plats1+' decks and '+led1+' edge walls, so this check cannot see a deck');
         if((M.plats||[]).length) bad.push(nm+': '+M.plats.length+' raised deck(s) still built');
         if((M.ramps||[]).length) bad.push(nm+': '+M.ramps.length+' ramp(s) still built');
         if(led) bad.push(nm+': '+led+' deck edge wall(s) still stand, and he collides with every one');
         for(i=0;i<D.plats.length;i++){
           var PL=D.plats[i], lf=M.liftAt?M.liftAt(PL.x+PL.w/2,PL.y+PL.h/2):0;
           if(lf) bad.push(nm+': the middle of '+(PL.name||'a deck')+' still lifts a man '+lf+' units');
         }
         if(print1!==prints(g2)) bad.push(nm+': taking the decks out moved a container or a machine on seed 4242, so the map is no longer the one every other check measures');
         endAny();
       }
       if(!sectors) return 'SKIP: no sector authors a raised deck';
       // THE WALK: south to north across the largest deck on the first sector that has one.
       var D0=null, PL0=null, mi0=-1;
       for(mi=0;mi<Math.min(2,FIXED_MAPS.length)&&!D0;mi++) if(FIXED_MAPS[mi].plats&&FIXED_MAPS[mi].plats.length){ D0=FIXED_MAPS[mi]; mi0=mi; }
       for(i=0;i<D0.plats.length;i++) if(!PL0||D0.plats[i].w*D0.plats[i].h>PL0.w*PL0.h) PL0=D0.plats[i];
       if(PL0.w<PL0.h) bad.push('staging: the largest deck on '+D0.name+' runs north to south, so a walk north does not cross its long edges');
       else {
         fresh();
         __deploy({kit:[],mapIx:mi0,seed:4242});
         var g=__state(), p=g.player, K=__keys(), k, cx=null, x;
         var yTop=PL0.y-50, yBot=PL0.y+PL0.h+50;
         for(x=PL0.x+40;x<=PL0.x+PL0.w-40&&cx===null;x+=20){
           var clear=true;
           for(i=0;i<g.map.walls.length&&clear;i++){ var W=g.map.walls[i]; if(W.ledge) continue;
             if(W.x<x+26&&W.x+W.w>x-26&&W.y<yBot&&W.y+W.h>yTop) clear=false; }
           for(i=0;i<g.containers.length&&clear;i++){ var C=g.containers[i];
             if(Math.abs(C.x-x)<40&&C.y>yTop-20&&C.y<yBot+20) clear=false; }
           if(clear) cx=x;
         }
         if(cx===null) bad.push('staging: no clear column 52 wide across where '+PL0.name+' stood, from 50 south of it to 50 north');
         else {
           for(k in K) delete K[k];
           g.ents.length=0; g.waveT=-1e9;
           p.downed=false; p.hp=100; p.iv=99; p.autoJog=false; p.roll=0; p.cooking=0;
           p.x=cx; p.y=PL0.y+PL0.h+36;
           var y0=p.y, clk=Math.max(performance.now(),(lastTs||0)+100);
           K['KeyW']=true;
           for(i=0;i<300&&p.y>PL0.y-24;i++){ p.iv=99; clk+=16.7; __loop(clk); if(__state()!==g||g.over) break; }
           for(k in K) delete K[k];
           if(!(p.y<=PL0.y-24)) bad.push('holding W from '+Math.round(y0)+' north across where '+PL0.name+' stood ('+PL0.y+' to '+(PL0.y+PL0.h)+'), he stopped at '+Math.round(p.y)+' and never reached '+(PL0.y-24));
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete CFG.decks; }catch(_d){}
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var gz=__state(); if(gz&&gz.player){ gz.player.iv=0; gz.player.downed=false; } }catch(_a){}
       endAny();
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
