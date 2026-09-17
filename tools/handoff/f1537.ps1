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
  {v:'15.36',what:
'@ @'
  {v:'15.37',what:'a crate on the far side of a wall never blocks the stall: beside the Peddler, an unopened crate within 46 units but just past a thin solid wall, where the search cannot reach it, no longer marks the stall blocked and E opens the stall, while the same crate on his own side of the wall still takes E for the search (peddler audit finding 9)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof mkPeddler!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof losClear!=='function') return 'SKIP: no player update, Peddler, crate or sight test in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof WORLD_W!=='number'||typeof WORLD_H!=='number'||!ITEMS.cell) return 'SKIP: no keys, mouse, world size or Cracked Cell in this build';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, shut=[], c=null, pd=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     function step(){ updatePlayer(1/60); }
     function dd(a,b){ var dx=a.x-b.x, dy=a.y-b.y; return Math.sqrt(dx*dx+dy*dy); }
     // Open ground: well inside the world and no wall nearer than 12.5, so a body of radius 11 standing there is never pushed.
     function free(o){
       if(!(o.x>60&&o.y>60&&o.x<WORLD_W-60&&o.y<WORLD_H-60)) return false;
       var ws=g.map.walls;
       for(var j=0;j<ws.length;j++){
         var W=ws[j], qx=Math.max(W.x,Math.min(o.x,W.x+W.w)), qy=Math.max(W.y,Math.min(o.y,W.y+W.h)), ex=o.x-qx, ey=o.y-qy;
         if(ex*ex+ey*ey<156.25) return false;
       }
       return true;
     }
     // Clear of everything else that claims E: the extraction rings, the seal and the locked doors.
     function quiet(o){
       var j, zs=g.zones||[], lk=g.map.locked||[];
       for(j=0;j<zs.length;j++) if(dd(o,zs[j])<(zs[j].r||0)+90) return false;
       if(g.seal&&dd(o,g.seal)<130) return false;
       for(j=0;j<lk.length;j++) if(dd(o,{x:lk[j].doorX,y:lk[j].doorY})<90) return false;
       return true;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map||!g.map.walls||!g.vseg) return 'SKIP: no live raid with walls and sight segments';
       p=g.player;
       keep={x:p.x,y:p.y,iv:p.iv};
       clearKeys(); mouse.down=false;
       p.downed=false; p.dying=false; p.roll=0; p.iv=99; p.autoJog=false;
       g.bagOpen=false; g.mapOpen=false; g.drag=null; g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0;
       // A solid wall 8 to 19 thick and at least 90 long. He stands 13 off the middle of one long face, the far spot is 13 off
       // the other face (under 46 from him, with the wall across the line), and the near spot is as far from him along his own face.
       var S=null, ws=g.map.walls;
       for(var i=0;i<ws.length&&!S;i++){
         var w=ws[i];
         if(!w||w.win||w.ledge||w.door||w.tree||w.noDes) continue;
         var vert=w.w<w.h, th=vert?w.w:w.h, len=vert?w.h:w.w;
         if(!(th>=8&&th<=19&&len>=90)) continue;
         for(var sd=-1;sd<=1&&!S;sd+=2){
           var P0,F0,nx,ny,tx,ty;
           if(vert){ var my=w.y+w.h/2; P0={x:(sd<0?w.x-13:w.x+w.w+13),y:my}; F0={x:(sd<0?w.x+w.w+13:w.x-13),y:my}; nx=sd; ny=0; tx=0; ty=1; }
           else { var mx=w.x+w.w/2; P0={x:mx,y:(sd<0?w.y-13:w.y+w.h+13)}; F0={x:mx,y:(sd<0?w.y+w.h+13:w.y-13)}; nx=0; ny=sd; tx=1; ty=0; }
           var D=dd(P0,F0);
           if(!(D<45.5)||!free(P0)||!free(F0)||!quiet(P0)) continue;
           if(losClear(P0.x,P0.y,F0.x,F0.y,g.vseg)) continue;
           for(var ts=-1;ts<=1&&!S;ts+=2){
             var N0={x:P0.x+tx*D*ts,y:P0.y+ty*D*ts};
             if(free(N0)&&losClear(P0.x,P0.y,N0.x,N0.y,g.vseg)) S={P:P0,F:F0,N:N0,Q:{x:P0.x+nx*40,y:P0.y+ny*40},th:th};
           }
         }
       }
       if(!S) return 'SKIP: no thin solid wall with open ground on both faces here';
       p.x=S.P.x; p.y=S.P.y; p.vx=0; p.vy=0;
       // Only the Peddler, 40 units out from the wall on his side, and no other unopened crate within 60 of him.
       keepEnts=g.ents.slice(); g.ents.length=0;
       for(var ci=0;ci<g.containers.length;ci++){ var CU=g.containers[ci]; if(!CU.opened&&dd(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       pd=mkPeddler(S.Q.x,S.Q.y,g.map); g.ents.push(pd);
       // CONTROL: with no crate near, a frame leaves him where he stands, finds the Peddler and reads the stall as free.
       step();
       if(dd(p,S.P)>0.5) return 'SKIP: he moved '+dd(p,S.P).toFixed(2)+' units in a frame with no key down beside the wall';
       if(g.nearPed!==pd) return 'SKIP: the Peddler 40 units away was not found beside him here';
       if(g.pedBlocked||g.nearContainer) return 'SKIP: something at his feet already claims E here';
       // CONTROL: E beside the Peddler with no crate near opens the stall.
       keys['KeyE']=true; step(); clearKeys();
       if(g.trade!==pd) return 'SKIP: E beside the Peddler with no crate near did not open the stall here';
       g.trade=null; step();
       if(g.pedLock) return 'SKIP: letting go of E did not free the stall key here';
       // A crate on his own side of the wall, as far from him as the far spot, with a clear line to it.
       c=setLoot(mkContainer(S.N.x,S.N.y,'crate'),['cell']); g.containers.push(c);
       step();
       // CONTROL: the search reaches that crate.
       if(g.nearContainer!==c) return skip('the search did not reach a crate '+dd(p,c).toFixed(1)+' units away on his side of the wall here');
       // GUARD: a crate the search can reach still keeps E from the stall, and E searches it.
       if(g.pedBlocked!==1) bad.push('an unopened crate '+dd(p,c).toFixed(1)+' units away on his side of the wall, which the search reaches, did not keep E from the stall');
       keys['KeyE']=true; step(); clearKeys();
       if(g.trade) bad.push('E with a crate he can search at his feet opened the stall instead of searching it');
       else if(g.searching!==c) bad.push('E with a crate he can search at his feet did not start the search');
       g.trade=null; g.pedLock=0; step();
       // The same crate, untouched, moved to the far side of the wall.
       c.x=S.F.x; c.y=S.F.y; c.prog=0; c.pulled=0; c.noiseAcc=0; setLoot(c,['cell']);
       g.searching=null; g.searchT=0;
       // CONTROL: the far crate is inside the 46 units and the wall is across the line to it.
       if(!(dd(p,c)<46)||losClear(p.x,p.y,c.x,c.y,g.vseg)) return skip('the far crate is '+dd(p,c).toFixed(1)+' units away with the line to it '+(losClear(p.x,p.y,c.x,c.y,g.vseg)?'clear':'blocked')+' here');
       step();
       // CONTROL: the Peddler is still found and the search reaches nothing from here.
       if(g.nearPed!==pd) return skip('the Peddler was not found beside him with the crate past the wall');
       if(g.nearContainer) return skip('the search reached something with the crate past the wall here');
       // THE FIX: a crate the search cannot reach does not block the stall, and E opens it.
       if(g.pedBlocked) bad.push('an unopened crate '+dd(p,c).toFixed(1)+' units away past a wall '+S.th+' thick, which the search cannot reach, still blocked the stall and the plate asked for the crate first');
       keys['KeyE']=true; step(); clearKeys();
       if(g.trade!==pd) bad.push('E beside the Peddler with that crate past the wall did nothing: the stall stayed shut and '+(g.searching?'a search started':'no search started'));
       if((c.prog||0)>0) bad.push('E searched the crate through the wall');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0; g.nearPed=null; g.pedBlocked=0; g.nearContainer=null; } }catch(_t){}
       try{ if(g&&c){ for(var rc=g.containers.length-1;rc>=0;rc--) if(g.containers[rc]===c) g.containers.splice(rc,1); } }catch(_r){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.iv=keep.iv; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
