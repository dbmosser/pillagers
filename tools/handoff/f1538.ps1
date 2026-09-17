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
  {v:'15.37',what:
'@ @'
  {v:'15.38',what:'downed at the stall, the Peddler plate stops offering a deal: shot to the floor 40 units from the Peddler, ten frames down with E pressed on one of them, the drawn plate over him reads THE PEDDLER with no deal while the stall stays shut, and standing there before the hit and after a self-revive it offers the deal (peddler audit finding 10)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__textTrace)) return 'SKIP: this fixture cannot deploy and read the drawn text';
     if(typeof updatePlayer!=='function'||typeof damagePlayer!=='function'||typeof selfRevive!=='function'||typeof losClear!=='function') return 'SKIP: no player update, damage, self-revive or sight test in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof WORLD_W!=='number'||typeof WORLD_H!=='number') return 'SKIP: no keys, mouse or world size in this build';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, shut=[], pd=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // Assembled, never written whole, so nothing but the drawn plate can hold it.
     var DEAL='] DE'+'AL';
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
     // The Peddler plate as one drawn frame paints it: the one offering the deal if any does, else the first, '' for none, null on a throw.
     function plate(){
       var d=null, t='';
       try{ d=__textTrace(function(){ __frame(0.016); }); }catch(_t){ return null; }
       for(var i=0;i<d.length;i++){
         var s2=String(d[i].t||'');
         if(s2.indexOf('THE PEDDLER')!==0) continue;
         if(s2.indexOf(DEAL)>=0) return s2;
         if(!t) t=s2;
       }
       return t;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map||!g.map.walls||!g.vseg) return 'SKIP: no live raid with walls and sight segments';
       p=g.player;
       keep={x:p.x,y:p.y,iv:p.iv,hp:p.hp,armor:p.armor,revived:p.revived};
       clearKeys(); mouse.down=false;
       p.downed=false; p.dying=false; p.roll=0; p.iv=99; p.autoJog=false; p.revived=false;
       g.bagOpen=false; g.mapOpen=false; g.drag=null; g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0; g.waveT=-1e9;
       keepEnts=g.ents.slice();
       // The raid's own Peddler with a free, quiet spot 40 units out and a clear line to him; else one put on open ground.
       var own=null, S=null, i, a;
       for(i=0;i<keepEnts.length;i++) if(keepEnts[i]&&keepEnts[i].kind==='peddler'){ own=keepEnts[i]; break; }
       if(own) for(a=0;a<16&&!S;a++){
         var o={x:own.x+Math.cos(a*Math.PI/8)*40,y:own.y+Math.sin(a*Math.PI/8)*40};
         if(free(o)&&quiet(o)&&losClear(o.x,o.y,own.x,own.y,g.vseg)) S={P:o,Q:own};
       }
       if(!S&&typeof mkPeddler==='function') for(var gx=200;gx<WORLD_W-200&&!S;gx+=97) for(var gy=200;gy<WORLD_H-200&&!S;gy+=97){
         var o2={x:gx,y:gy}, q2={x:gx+40,y:gy};
         if(free(o2)&&free(q2)&&quiet(o2)&&losClear(o2.x,o2.y,q2.x,q2.y,g.vseg)) S={P:o2,Q:q2};
       }
       if(!S) return 'SKIP: no open ground 40 units from a Peddler here';
       pd=(S.Q===own)?own:mkPeddler(S.Q.x,S.Q.y,g.map);
       // Only the Peddler, and no other unopened crate within 60 of him.
       g.ents.length=0; g.ents.push(pd);
       p.x=S.P.x; p.y=S.P.y; p.vx=0; p.vy=0;
       for(i=0;i<g.containers.length;i++){ var CU=g.containers[i]; if(!CU.opened&&dd(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       // CONTROL: a frame with no key leaves him where he stands, finds the Peddler and reads the stall free.
       step();
       if(dd(p,S.P)>0.5) return 'SKIP: he moved '+dd(p,S.P).toFixed(2)+' units in a frame with no key down beside the Peddler';
       if(p.downed) return 'SKIP: he was down before the hit here';
       if(g.nearPed!==pd) return 'SKIP: the Peddler 40 units away was not found beside him here';
       if(g.pedBlocked) return 'SKIP: a crate at his feet already claims E here';
       // CONTROL: standing there, the drawn plate offers the deal, so the plate can be read.
       var before=plate();
       if(before===null) return 'SKIP: drawing a frame threw here, so the plate cannot be read';
       if(before.indexOf(DEAL)<0) return 'SKIP: standing 40 units from the Peddler the drawn plate read ['+before+'], not the deal, so the plate cannot be read here';
       // Shot to the floor where he stands.
       p.iv=0; p.armor=0; p.hp=20;
       damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
       if(!p.downed) return 'SKIP: the staged hit did not put him on the floor';
       for(var f=0;f<10;f++){ clearKeys(); keys['KeyE']=(f===4); step(); if(!p.downed) break; }
       clearKeys();
       if(!p.downed) return 'SKIP: he did not stay down for ten frames here';
       // CONTROL: E on the floor opened nothing, so a deal offered there is one he cannot take.
       if(g.trade) return 'SKIP: E on the floor opened the stall here, so the deal on the plate was real';
       var down=plate();
       // CONTROL: the plate is still drawn over the Peddler while he is down, so no deal on it is not simply no plate.
       if(down===null||down.indexOf('THE PEDDLER')!==0) return 'SKIP: no Peddler plate was drawn while he was down ('+down+'), so the plate cannot be read on the floor';
       // THE FIX: on the floor the plate does not offer the deal.
       if(down.indexOf(DEAL)>=0) bad.push('shot to the floor 40 units from the Peddler, ten frames down with E pressed on one of them and the stall still shut, the drawn plate over him still read ['+down+'] (the stall still counted as '+(g.nearPed===pd?'beside him':'not beside him')+')');
       // CONTROL: back on his feet, the first standing frame offers the deal again, so the plate follows him and is not just switched off.
       selfRevive(); clearKeys(); step();
       if(p.downed) return skip('the self-revive did not stand him up here');
       var after=plate();
       if(after===null) return skip('drawing a frame after the self-revive threw here');
       if(after.indexOf(DEAL)<0) bad.push('back on his feet after a self-revive 40 units from the Peddler, the drawn plate read ['+after+'] and did not offer the deal again');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); mouse.down=false; }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; g.searching=null; g.searchT=0; g.nearPed=null; g.pedBlocked=0; } }catch(_t){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.downed=false; p.downT=0; p.pendKiller=null; p.hp=keep.hp; p.armor=keep.armor; p.revived=keep.revived; p.x=keep.x; p.y=keep.y; p.iv=keep.iv; } }catch(_p){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
