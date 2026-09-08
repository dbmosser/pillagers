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

# v12.49 CHECK, inserted before the v12.48 entry. It does not assume where a
# wall is: it walks a real building's west face until it finds a row the map's
# own segments actually block, and skips honestly if the map has no such row.
# The burst is placed in the street, so the v10.63 roof gate is inert and the
# only thing that can stop the blast is the wall. Two controls, both required:
# the same shell must still hurt a man standing in the open the same distance
# away, and a pillager behind that wall must be spared exactly as he is.
SubRx @'
  {v:'12.48',what:'the what is new card obeys his vocabulary list: no entry names the extraction as a vehicle or uses the retired arrival word, and the old names for the tactical belt and the backpack appear only inside the entries that announce those renames, which still exist (his order of 2026-09-02, my slip of 2026-09-08)',
'@ @'
  {v:'12.49',what:'a Howler shell bursting in the street does not reach through a solid wall: the man forty units inside loses nothing and a pillager behind the same wall loses nothing, while the same shell still hurts anyone standing in the open the same distance away (2026-09-07 audit, the remaining half of his 2026-09-06 note)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__howlerHit&&window.__buildings)) return 'SKIP: this fixture cannot deploy a raid and land a Howler shell';
     if(typeof losClear!=='function') return 'SKIP: this build has no line of sight test to hold the blast to';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to stand in';
       var p=g.player, segs=g.map&&g.map.segs, B=__buildings(), i, j;
       var e=null;
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'){ e=g.ents[i]; break; }
       if(!segs||!segs.length) return 'SKIP: this map carries no wall segments';
       if(!B||!B.length) return 'SKIP: this map built no buildings to hide in';
       // A REAL WALL, FOUND RATHER THAN ASSUMED. Walk the west face of every
       // building big enough to stand well inside, and take the first row where
       // the map's own segments block a line from the street to a point forty
       // units in. That skips doorways and windows without naming them.
       var b=null, wy=0, OUT=30, IN=40;
       for(i=0;i<B.length&&!b;i++){
         var cand=B[i]; if(!(cand.w>=140&&cand.h>=140)) continue;
         for(j=-3;j<=3;j++){
           var ty=cand.y+cand.h/2+j*20;
           if(ty<cand.y+20||ty>cand.y+cand.h-20) continue;
           if(!losClear(cand.x-OUT,ty,cand.x+IN,ty,segs)){ b=cand; wy=ty; break; }
         }
       }
       if(!b) return 'SKIP: no building on this map and seed has a solid west face to stand behind, so there is no wall here to test';
       var TX=b.x-OUT, TY=wy;
       // The one arm that must never be skipped quietly: the burst has to be in
       // the open, or the v10.63 roof gate would be doing this checks work.
       if(typeof roofAt==='function'&&roofAt(TX,TY)) return 'SKIP: the burst point is under a roof, so the roof rule would answer this and not the wall';
       function shell(){ __howlerHit({tx:TX,ty:TY,x0:TX-370,y0:TY,dmg:35}); }
       function ready(x,y){ p.x=x; p.y=y; p.hp=100; p.maxhp=Math.max(100,p.maxhp||100);
                            p.armor=0; p.iv=0; p.downed=false; p.roll=0; p.healQ=0; }
       // CONTROL ONE FIRST: the same shell, the same distance, nothing between.
       // Without it, a build that simply stopped the Howler hurting anyone reads
       // green on the finding below.
       g.ents.length=0;
       ready(TX-70,TY);
       if(!losClear(TX,TY,p.x,p.y,segs)) return 'SKIP: the open ground the other side of the burst is not open on this seed, so the control cannot be staged';
       shell();
       var openLoss=100-p.hp;
       if(!(openLoss>0)) return 'SKIP: the shell took nothing off a man standing seventy units away in the open, so this check cannot see the blast at all';
       // THE FINDING: the same shell, the same seventy units, one wall between.
       g.ents.length=0;
       ready(b.x+IN,TY);
       shell();
       var wallLoss=100-p.hp;
       if(wallLoss>0)
         bad.push('a Howler shell bursting in the street took '+Math.round(wallLoss)+' health off a man standing '+IN+' units inside a solid wall, through masonry, with the hit ring pointing at a burst he cannot see (the same shell takes '+Math.round(openLoss)+' in the open)');
       // AND THE SAME RULE FOR EVERYONE ELSE, since the entity loop has the same
       // hole and a pillager sheltering behind that wall is in the same room.
       if(e){
         ready(b.x+IN,TY);
         e.x=b.x+IN; e.y=TY; e.hp=200; e.maxhp=200; e.downed=false; e.finished=false;
         g.ents.length=0; g.ents.push(e);
         shell();
         if(e.hp<200) bad.push('the same shell took '+Math.round(200-e.hp)+' off a pillager sheltering behind that same wall, so the blast reaches through it for everyone and not only for him');
         // CONTROL TWO: and it must still reach that pillager in the open.
         e.x=TX-70; e.y=TY; e.hp=200; ready(TX-2000,TY);
         shell();
         if(!(e.hp<200)) bad.push('control: the shell took nothing off a pillager standing seventy units away in the open either, so the entity half of this check cannot see the blast and proves nothing');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var gz=__state(); if(gz&&gz.player){ gz.player.hp=100; gz.player.iv=0; gz.player.downed=false; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.48',what:'the what is new card obeys his vocabulary list: no entry names the extraction as a vehicle or uses the retired arrival word, and the old names for the tactical belt and the backpack appear only inside the entries that announce those renames, which still exist (his order of 2026-09-02, my slip of 2026-09-08)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
