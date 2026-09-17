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
  {v:'15.18',what:
'@ @'
  {v:'15.19',what:'your hire leaves the crate you are searching: under FOLLOW, beside a part searched crate, he neither opens it nor takes its Data Core, whether or not he had picked it before you started, while an untouched crate in the same spot he still loots (hire audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__ents)) return 'SKIP: this fixture cannot deploy or step the pillagers';
     if(typeof mkRaider!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof losClear!=='function'||!ITEMS.scrap||!ITEMS.core) return 'SKIP: no pillagers, crates or items in this build';
     var bad=[], snap=null, g=null, kept=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var has=function(a,k){ return (a||[]).indexOf(k)>=0; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(!g.zones||!g.zones.length||!g.containers) return 'SKIP: no open ground or crates to stage on';
       var p=g.player, Z=null, zi;
       for(zi=0;zi<g.zones.length&&!Z;zi++) if(losClear(g.zones[zi].x-60,g.zones[zi].y,g.zones[zi].x+60,g.zones[zi].y,g.map.segs)) Z=g.zones[zi];
       if(!Z) return 'SKIP: no clear spot beside a ring';
       kept={ents:g.ents,cont:g.containers,order:g.mercOrder,hold:g.mercHold,search:g.searching};
       var M=mkRaider(Z.x+20,Z.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1;
       // One stage: nobody else on the map, you 30 left of a crate of two Scrap Metal and a Data Core, your hire 20 right of it, on FOLLOW.
       // He starts within reach of the crate, so no walk and no fight is involved: only which crate he may take.
       var stage=function(prog,picked){
         var ct=setLoot(mkContainer(Z.x,Z.y,'crate'),['scrap','scrap','core']);
         ct.prog=prog; ct.pulled=0;
         g.containers=[ct]; g.ents=[M];
         M.x=Z.x+20; M.y=Z.y; M.hp=1000; M.maxhp=1000; M.state='follow'; M.downed=false; M.finished=false; M.cd=0;
         M.bag=[]; M.mgoal=picked?ct:null; M.mlootT=picked?1.5:0;
         p.x=Z.x-30; p.y=Z.y; p.downed=false; p.hp=p.maxhp; p.iv=99;
         g.mercOrder='follow'; g.mercHold=null; g.searching=(prog>0)?ct:null;
         return ct;
       };
       var step=function(k){ for(var f=0;f<k;f++) __ents(0.05); };
       // CONTROL: an untouched crate beside him with nobody searching it. He opens it and the Data Core goes into his pack.
       var c0=stage(0,false);
       step(60);
       if(g.ents.indexOf(M)<0||M.downed) return 'SKIP: the hire did not stay on the stage here';
       if(!(c0.opened===true&&has(M.bag,'core'))) return 'SKIP: your hire did not loot an untouched crate beside him in three seconds here (opened '+c0.opened+', pack '+M.bag.join(',')+')';
       // THE FINDING: you are holding X on the crate, its bar part done, and he has not picked it yet.
       var c1=stage(0.3,false);
       if(c1.prog!==0.3||g.searching!==c1||g.mercOrder!=='follow'||M.mgoal!==null) return skip('the search could not be staged here');
       step(60);
       if(c1.opened||has(M.bag,'core')) bad.push('under FOLLOW your hire took the crate you were searching: he marked it opened and put its '+M.bag.length+' remaining items in his pack, the Data Core your search had not reached among them');
       // AND: he was already working the crate when you started on it.
       var c2=stage(0.3,true);
       if(M.mgoal!==c2||g.searching!==c2||M.mlootT!==1.5) return skip('the crate he had picked could not be staged here');
       step(20);
       if(c2.opened||has(M.bag,'core')) bad.push('your hire already working a crate kept at it after you started searching it, marked it opened and took its Data Core');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&kept){ g.ents=kept.ents; g.containers=kept.cont; g.mercOrder=kept.order; g.mercHold=kept.hold; g.searching=kept.search; } }catch(_k){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
