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
  {v:'15.54',what:
'@ @'
  {v:'15.55',what:'the Data Core KEY mark leaves a container once its key is taken out: with a core burned at seed 4242, a shut container staged with a locked room key and a Meridian Black Box carries a KEY on the sector map, X held beside it takes the key out first into the backpack, and with the box still shut and the Black Box still inside the map now draws no KEY on it, while a shut container still holding its key keeps its KEY (keys audit finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof drawMapOverlay!=='function'||typeof mapLabel!=='function'||typeof setLoot!=='function'||typeof losClear!=='function') return 'SKIP: this build has no player update, sector map, loot setter or sight test';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof WORLD_W!=='number'||typeof WORLD_H!=='number') return 'SKIP: no keys, mouse or world size in this build';
     if(!(ITEMS.blackbox&&ITEMS.blackbox.val)) return 'SKIP: this build has no Meridian Black Box to stage';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, so the sector map cannot be drawn';
     var bad=[], snap=null, g=null, p=null, _ml=mapLabel, keepP=null, keepG=null, keepIK=null, keepEnts=null, shut=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var isKey=function(k){ return String(k).indexOf('key_')===0; };
     var hasKey=function(x){ var l=(x&&x.loot)||[]; for(var q=0;q<l.length;q++) if(isKey(l[q])) return true; return false; };
     var closed=function(x){ return !!x&&!x.dropped&&!x.opened&&!x.auto&&!x.mercSrc&&Array.isArray(x.loot); };
     function clearKeys(){ for(var kk in keys) keys[kk]=false; mouse.down=false; }
     function dd(a,b){ var dx=a.x-b.x, dy=a.y-b.y; return Math.sqrt(dx*dx+dy*dy); }
     function count(k){ var c=0; for(var q=0;q<g.bag.length;q++) if(g.bag[q]===k) c++; return c; }
     // Open ground inside the world with no wall nearer than his radius and a margin, so standing there he is never pushed.
     function free(o){
       if(!(o.x>60&&o.y>60&&o.x<WORLD_W-60&&o.y<WORLD_H-60)) return false;
       var ws=g.map.walls, rr=(p.r||11)+1.5;
       for(var j=0;j<ws.length;j++){
         var WL=ws[j], qx=Math.max(WL.x,Math.min(o.x,WL.x+WL.w)), qy=Math.max(WL.y,Math.min(o.y,WL.y+WL.h)), ex=o.x-qx, ey=o.y-qy;
         if(ex*ex+ey*ey<rr*rr) return false;
       }
       return true;
     }
     // A spot inside the 46 unit search reach of a container, on open ground, with a clear line to it; null if there is none.
     function spot(c){
       var R=[24,32,40,16];
       for(var r=0;r<R.length;r++) for(var a=0;a<16;a++){
         var o={x:c.x+Math.cos(a*Math.PI/8)*R[r],y:c.y+Math.sin(a*Math.PI/8)*R[r]};
         if(dd(o,c)<46&&free(o)&&losClear(o.x,o.y,c.x,c.y,g.vseg)) return o;
       }
       return null;
     }
     // How many times the sector map writes KEY with only the given containers on the Data Core list. Calls are counted, not
     // placements, so the same-word merge in mapLabel cannot hide one.
     function marks(list){
       var c=0, err='';
       g.intelKeys=list;
       mapLabel=function(t){ try{ if(String(t)==='KEY') c++; }catch(_q){} return _ml.apply(this,arguments); };
       try{ drawMapOverlay(); }catch(de){ err=String((de&&de.message)||de); }
       mapLabel=_ml;
       return {n:c,err:err};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __P().intel=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||!g.map||!g.map.walls||!g.vseg||!g.bag||!g.containers) return 'SKIP: no live raid with walls, sight segments, containers and a backpack';
       p=g.player;
       // CONTROL: the ascent burned the core and built the list the sector map draws its KEY marks from.
       if(!g.intel||!Array.isArray(g.intelKeys)||__P().intel) return 'SKIP: the Data Core did not burn on this ascent here';
       keepIK=g.intelKeys.slice(); keepEnts=g.ents.slice();
       keepP={x:p.x,y:p.y,vx:p.vx,vy:p.vy,iv:p.iv,roll:p.roll,autoJog:p.autoJog};
       keepG={bagOpen:g.bagOpen,mapOpen:g.mapOpen,drag:g.drag,trade:g.trade,pedLock:g.pedLock,searching:g.searching,searchT:g.searchT,waveT:g.waveT};
       // The container: one the game listed, else any shut one, with a spot in reach. The key: its own, else a listed one, else the first door.
       var i, j, C=null, S=null, kid='';
       for(i=0;i<keepIK.length&&!S;i++){ if(closed(keepIK[i])&&hasKey(keepIK[i])){ S=spot(keepIK[i]); if(S) C=keepIK[i]; } }
       for(i=0;i<g.containers.length&&!S;i++){ if(closed(g.containers[i])&&!g.containers[i].strong){ S=spot(g.containers[i]); if(S) C=g.containers[i]; } }
       if(!S||!C) return 'SKIP: no shut container with open ground and a clear line within reach here';
       for(j=0;j<C.loot.length&&!kid;j++) if(isKey(C.loot[j])) kid=String(C.loot[j]);
       for(i=0;i<keepIK.length&&!kid;i++) for(j=0;j<(keepIK[i].loot||[]).length&&!kid;j++) if(isKey(keepIK[i].loot[j])) kid=String(keepIK[i].loot[j]);
       if(!kid&&g.map.locked&&g.map.locked.length) kid='key_'+g.map.locked[0].id;
       if(!kid||!ITEMS[kid]) return 'SKIP: no locked room key to stage on this map ('+kid+')';
       // THE STAGE: the key and a Black Box, sorted worst first by the game, so the key is the first thing out and the box is not
       // empty after it. The search starts from nothing.
       setLoot(C,[kid,'blackbox']); C.prog=0; C.pulled=0;
       if(C.loot.length!==2||C.loot[0]!==kid||C.loot[1]!=='blackbox') return 'SKIP: the key does not rank below a Meridian Black Box here, so it would not come out first';
       clearKeys();
       p.roll=0; p.autoJog=false; p.iv=99;
       g.bagOpen=false; g.mapOpen=false; g.drag=null; g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0; g.waveT=-1e9;
       p.x=S.x; p.y=S.y; p.vx=0; p.vy=0;
       // Only this container is in reach: any other shut one within 60 is marked opened for the check and put back in finally.
       for(i=0;i<g.containers.length;i++){ var CU=g.containers[i]; if(CU!==C&&!CU.opened&&dd(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       // CONTROL: a frame with no key down leaves him where he stands and finds this container in reach, unsearched.
       updatePlayer(1/30);
       if(p.downed||g.over) return 'SKIP: he was down or the raid was over before the search here';
       if(dd(p,S)>0.5) return 'SKIP: he moved '+dd(p,S).toFixed(2)+' units in a frame with no key down beside the container';
       if(g.nearContainer!==C) return 'SKIP: the search does not reach the staged container from where he stands here';
       if((C.prog||0)>0||(C.pulled||0)>0) return 'SKIP: a frame with no key down searched the container here';
       // CONTROL: before the search the sector map writes KEY on the one listed container, which holds its key.
       var m0=marks([C]);
       if(m0.err) return 'SKIP: the sector map threw before the search ('+m0.err+')';
       if(m0.n!==1) return 'SKIP: the sector map wrote '+m0.n+' KEY marks for the one listed container holding its key, so the intel marks are not drawn here';
       // THE PLAY PATH: X held, one frame at a time, until no key is left in the container.
       var had=count(kid), f=0;
       clearKeys(); keys['KeyX']=true;
       while(f<900&&hasKey(C)&&!C.opened&&!p.downed&&!g.over){ updatePlayer(1/30); f++; }
       clearKeys();
       // CONTROL: the staged pull took the key into his backpack and stopped there, with the box still shut and the Black Box inside.
       if(g.over||p.downed) return 'SKIP: the raid ended or he went down during the search here';
       if(count(kid)!==had+1) return 'SKIP: the key did not come out into the backpack after '+f+' frames of X here';
       if(C.opened) return 'SKIP: the search finished the container on the frame the key came out, so it is not half searched here';
       if(hasKey(C)||C.loot.length!==1||C.loot[0]!=='blackbox') return 'SKIP: the container does not hold the Black Box alone after the key came out here';
       // THE FIX: nothing left in the box is a key, so the map writes no KEY on it.
       var m1=marks([C]);
       if(m1.err) bad.push('the sector map threw with a half searched container on the Data Core list ('+m1.err+')');
       else if(m1.n) bad.push('the key came out of a half searched container into the backpack, and with the box still shut and only a Meridian Black Box inside the sector map still writes KEY on it');
       // THE FIX IS NARROW: a shut container still holding a key keeps its KEY.
       var K=null;
       for(i=0;i<keepIK.length&&!K;i++) if(keepIK[i]!==C&&closed(keepIK[i])&&hasKey(keepIK[i])) K=keepIK[i];
       for(i=0;i<g.containers.length&&!K;i++) if(g.containers[i]!==C&&closed(g.containers[i])){ K=g.containers[i]; if(!hasKey(K)) setLoot(K,K.loot.concat([kid])); }
       if(!K||!hasKey(K)) return skip('no second shut container to hold a key');
       var m2=marks([K]);
       if(m2.err) bad.push('the sector map threw with a shut container holding its key on the Data Core list ('+m2.err+')');
       else if(m2.n!==1) bad.push('the sector map wrote '+m2.n+' KEY marks for a shut container still holding its key, where it should write one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       mapLabel=_ml;
       try{ clearKeys(); }catch(_k){}
       try{ for(var s=0;s<shut.length;s++) shut[s].opened=false; }catch(_s){}
       try{ if(g&&keepIK) g.intelKeys=keepIK; }catch(_i){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var e2=0;e2<keepEnts.length;e2++) g.ents.push(keepEnts[e2]); } }catch(_n){}
       try{ if(p&&keepP){ p.x=keepP.x; p.y=keepP.y; p.vx=keepP.vx; p.vy=keepP.vy; p.iv=keepP.iv; p.roll=keepP.roll; p.autoJog=keepP.autoJog; } }catch(_p){}
       try{ if(g&&keepG){ g.bagOpen=keepG.bagOpen; g.mapOpen=keepG.mapOpen; g.drag=keepG.drag; g.trade=keepG.trade; g.pedLock=keepG.pedLock; g.searching=keepG.searching; g.searchT=keepG.searchT; g.waveT=keepG.waveT; } }catch(_g){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
