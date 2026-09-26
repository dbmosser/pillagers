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
  {v:'15.88',what:
'@ @'
  {v:'15.89',what:'your hire on FOLLOW keeps following past a locked room: standing outside a shut locked room within 160 of the cache inside it, with you at its door, he does not pick that cache and does not search it, while from the same two spots with the door opened by its key he picks it on the first frame and searches it (doors audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__ents)) return 'SKIP: this fixture cannot deploy or step the pillagers';
     if(typeof mkRaider!=='function'||typeof updatePlayer!=='function'||typeof spotFree!=='function'||typeof dist!=='function'||typeof ITEMS==='undefined') return 'SKIP: no pillagers, player update, wall test or items in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined') return 'SKIP: no key or mouse state in this build';
     var bad=[], snap=null, g=null, kept=null, key='';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var clearKeys=function(){ for(var kk in keys) keys[kk]=false; mouse.down=false; };
     var inside=function(R,o){ return o.x>R.x&&o.x<R.x+R.w&&o.y>R.y&&o.y<R.y+R.h; };
     var doorWall=function(map,id){ for(var w=0;w<map.walls.length;w++) if(map.walls[w].door===id) return true; return false; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||!g.map||!g.map.walls||!g.containers||!g.ents||!g.bag) return 'SKIP: no live raid';
       var rooms=g.map.locked||[];
       if(!rooms.length) return 'SKIP: no locked room on this map';
       var p=g.player, i, j, LK=null, c=null, H=null, Q=null;
       // The stage: a shut room, the cache inside it nearest its south wall, your hire 22 below that wall under the cache, you at
       // the door where the key is spent, both on clear ground.
       for(i=0;i<rooms.length&&!LK;i++){
         var R=rooms[i]; if(R.open||!doorWall(g.map,R.id)) continue;
         var q={x:R.doorX,y:R.y+R.h+40};
         if(dist(q,{x:R.doorX,y:R.doorY})>=52||!spotFree(g.map,q.x,q.y,14)) continue;
         var best=null;
         for(j=0;j<g.containers.length;j++){
           var ct=g.containers[j];
           if(ct.opened||ct.inLocked!==R.id||!inside(R,ct)) continue;
           var h={x:ct.x,y:R.y+R.h+22};
           if(dist(h,ct)>=160||dist(h,q)>=420||!spotFree(g.map,h.x,h.y,14)) continue;
           if(!best||ct.y>best.c.y) best={c:ct,h:h};
         }
         if(best){ LK=R; c=best.c; H=best.h; Q=q; }
       }
       if(!LK) return 'SKIP: no shut room with a cache near its south wall and clear ground outside it on this seed';
       key='key_'+LK.id;
       if(!ITEMS[key]||ITEMS[key].use!=='key'||ITEMS[key].door!==LK.id) return 'SKIP: no key item for '+LK.name+' in this build';
       kept={ents:g.ents,cont:g.containers,order:g.mercOrder,hold:g.mercHold,search:g.searching,wave:g.waveT};
       var M=mkRaider(H.x,H.y,null,false); M.merc=1; M.hostile=false; M.grudge=false; M.friendly=1;
       // One stage: nobody else on the map and only this cache, your hire under it outside the wall on FOLLOW, you at the door.
       var stage=function(){
         M.x=H.x; M.y=H.y; M.hp=1000; M.maxhp=1000; M.state='follow'; M.downed=false; M.finished=false; M.cd=0; M.roll=0;
         M.bag=[]; M.mgoal=null; M.mlootT=0; M.path=null; M.pathFail=false; M.pathT=0; M.pathGoal=null; M.slideT=0; M.stallT=0;
         c.opened=false; c.prog=0; c.pulled=0;
         g.ents=[M]; g.containers=[c]; g.mercOrder='follow'; g.mercHold=null; g.searching=null; g.waveT=-1e9;
         p.x=Q.x; p.y=Q.y; p.vx=0; p.vy=0; p.downed=false; p.hp=p.maxhp; p.iv=99; p.roll=0;
         clearKeys();
       };
       var step=function(k){ for(var f=0;f<k;f++) __ents(0.05); };
       var d0=Math.round(dist(H,c));
       // THE FINDING: the door still shut. One frame is the pick, then five seconds more.
       stage();
       // CONTROL: the stage is what the pick reads: the room shut with its door wall in place, the cache a shut box inside it,
       // your hire within 160 of it and you within 420 of both.
       if(LK.open||!doorWall(g.map,LK.id)) return 'SKIP: '+LK.name+' is not shut here';
       if(c.opened||(c.prog||0)>0||!inside(LK,c)) return 'SKIP: the cache inside '+LK.name+' is not a shut box inside it here';
       if(!(dist(M,c)<160&&dist(p,c)<420&&dist(M,p)<420)) return 'SKIP: your hire and you did not stage within the pick ranges here';
       step(1);
       if(g.ents.indexOf(M)<0||M.downed||g.over||p.downed) return 'SKIP: your hire did not stay on the stage here';
       var picked=(M.mgoal===c), dmin=dist(M,c);
       for(var f5=0;f5<99;f5++){ step(1); if(dist(M,c)<dmin) dmin=dist(M,c); }
       if(picked) bad.push('under FOLLOW, standing '+d0+' outside the shut '+LK.name+', your hire picked the cache inside it on the first frame, a box no route reaches while the door is locked; after 5 seconds he was '+(M.mgoal===c?'still aimed at it':'off it again')+' and had got no nearer than '+Math.round(dmin)+' to it');
       else if(M.mgoal) bad.push('with the door of '+LK.name+' shut your hire picked some other box: '+String(M.mgoal.type));
       if(c.opened||M.bag.length) bad.push('your hire searched the cache inside the shut '+LK.name+' through its wall');
       // CONTROL: the door opened the real way, its key in the backpack and E pressed at the door, then the same stage. Now he picks
       // the cache on the first frame and searches it, so the rule only shuts him out of a room that is still shut.
       stage();
       g.bag.push(key);
       keys['KeyE']=true; updatePlayer(1/60); clearKeys();
       if(g.over||p.downed) return skip('the raid ended or you went down at the door here');
       if(!LK.open||doorWall(g.map,LK.id)||g.bag.indexOf(key)>=0) return skip('the key did not open '+LK.name+' at its door here');
       stage();
       step(1);
       if(M.mgoal!==c) bad.push('with '+LK.name+' opened by its key, your hire standing '+d0+' from the cache inside did not pick it on the first frame');
       else {
         var f=1; while(f<300&&!c.opened&&!M.downed&&!g.over){ step(1); f++; }
         if(!c.opened) return skip('with the door open your hire did not reach and search the cache within 15 seconds here');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); }catch(_k0){}
       try{ if(g&&key&&g.bag){ var ki=g.bag.indexOf(key); if(ki>=0) g.bag.splice(ki,1); } }catch(_kb){}
       try{ if(g&&kept){ g.ents=kept.ents; g.containers=kept.cont; g.mercOrder=kept.order; g.mercHold=kept.hold; g.searching=kept.search; g.waveT=kept.wave; } }catch(_k){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
