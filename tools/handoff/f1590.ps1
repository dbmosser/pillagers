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
  {v:'15.89',what:
'@ @'
  {v:'15.90',what:'pillagers never spawn inside a locked room: with you in the corner of COLD STORAGE farthest from a shut locked room and every one of the 24 wave candidates a wall-clear point on the open floor inside it, a forced wave lands nobody, and with one clear point outside the room among the same 24, a point nearer to you than the inside one, the wave lands its man on that point, while a wave whose candidates are all that clear point lands him there on either build (doors audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof tickRaiderWaves!=='function'||typeof freeSpot!=='function'||typeof spotFree!=='function'||typeof dist!=='function'||typeof CFG==='undefined') return 'SKIP: no wave clock, spot finder, wall test or dials in this build';
     if(typeof WORLD_W==='undefined'||typeof WORLD_H==='undefined') return 'SKIP: no world size in this build';
     var bad=[], snap=null, g=null, kept=null, realFS=null;
     var inside=function(R,o){ return o.x>R.x&&o.x<R.x+R.w&&o.y>R.y&&o.y<R.y+R.h; };
     var doorWall=function(map,id){ for(var w=0;w<map.walls.length;w++) if(map.walls[w].door===id) return true; return false; };
     var at=function(e){ return '('+Math.round(e.x)+','+Math.round(e.y)+')'; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||!g.map||!g.map.walls||!g.ents||!g.roster) return 'SKIP: no live raid';
       if(CFG.raiderWaves===0) return 'SKIP: waves are off at the pinned defaults';
       var rooms=g.map.locked||[];
       if(!rooms.length) return 'SKIP: no locked room on this map';
       var shutAt=function(o){ for(var r=0;r<rooms.length;r++) if(!rooms[r].open&&inside(rooms[r],o)) return rooms[r]; return null; };
       var p=g.player, i, LK=null, C=null, O=null, PX=null;
       var corners=[{x:90,y:90},{x:WORLD_W-90,y:90},{x:90,y:WORLD_H-90},{x:WORLD_W-90,y:WORLD_H-90}];
       // The stage: a shut room with a point on its floor that is clear ground at the pad the spot finder uses, so the
       // finder itself can hand that point out; you in the corner of the map farthest from that point; and one clear point
       // outside the room on the line from the inside point towards you, so it is nearer to you than the inside one.
       for(i=0;i<rooms.length&&!LK;i++){
         var R=rooms[i]; if(R.open||!doorWall(g.map,R.id)) continue;
         var c=null;
         for(var gy=R.y+R.h/2;gy<=R.y+R.h-50&&!c;gy+=20) for(var gx=R.x+R.w/2;gx<=R.x+R.w-50&&!c;gx+=20){ if(spotFree(g.map,gx,gy,30)) c={x:gx,y:gy}; }
         if(!c) continue;
         var cnr=null, fd=-1;
         for(var k=0;k<corners.length;k++){ var cd=dist(corners[k],c); if(cd>fd){ fd=cd; cnr=corners[k]; } }
         if(fd<1600) continue;
         var o=null;
         for(var t=40;t<=600&&!o;t+=40){
           var q={x:c.x+(cnr.x-c.x)*t/fd,y:c.y+(cnr.y-c.y)*t/fd};
           if(spotFree(g.map,q.x,q.y,30)&&!shutAt(q)) o=q;
         }
         if(o){ LK=R; C=c; O=o; PX=cnr; }
       }
       if(!LK) return 'SKIP: no shut room with clear floor inside it and a clear point outside it on this seed';
       kept={ents:g.ents,roster:g.roster,waveT:g.waveT,waveN:g.waveN,waveAt:g.waveAt,px:p.x,py:p.y};
       p.x=PX.x; p.y=PX.y; p.vx=0; p.vy=0;
       if(dist(p,O)<900||dist(p,O)>=dist(p,C)) return 'SKIP: the clear point outside '+LK.name+' did not stage nearer to you than the point inside it and past the wave floor';
       realFS=freeSpot; var calls=0, plan=null;
       freeSpot=function(map,pad){ calls++; return plan(calls); };
       if(freeSpot===realFS) return 'SKIP: the spot finder cannot be stood in for here';
       // One forced wave: the map emptied so the wave is urgent and both ceilings are waived, the clock past the gap, the
       // once-a-frame guard cleared, and the finder answering from the plan. Gives back the man it landed, if any.
       var wave=function(pl){ calls=0; plan=pl; g.ents=[]; g.roster=[]; g.waveT=1e9; g.waveN=0; g.waveAt=-1; tickRaiderWaves(0.05); return g.ents.length?g.ents[g.ents.length-1]:null; };
       // CONTROL: every candidate the clear point. The wave asks the stand-in 24 times and lands a pillager on it on either build.
       var e0=wave(function(){ return {x:O.x,y:O.y}; });
       if(calls!==24) return 'SKIP: the wave asked the spot finder '+calls+' times rather than 24, so it is not the wave this check knows';
       if(!e0||e0.kind!=='raider') return 'SKIP: a forced wave with clear ground landed nobody, so waves cannot be driven here';
       if(dist(e0,O)>1) return 'SKIP: the wave landed its man at '+at(e0)+' rather than on the clear point '+at(O);
       // THE FINDING: every candidate the point on the open floor inside the shut room. Nobody may land there.
       var e1=wave(function(){ return {x:C.x,y:C.y}; });
       if(e1&&inside(LK,e1)) bad.push('with every wave candidate on the open floor inside the shut '+LK.name+' the wave landed '+e1.name+' at '+at(e1)+', inside it, where he takes its caches and can never leave');
       else if(e1) bad.push('with every wave candidate inside the shut '+LK.name+' the wave landed '+e1.name+' at '+at(e1));
       // And with one clear point among the 24: the wave lands him on that point, not inside the room, and does not decline.
       var e2=wave(function(n){ return (n===12)?{x:O.x,y:O.y}:{x:C.x,y:C.y}; });
       if(!e2) bad.push('with one clear point outside '+LK.name+' among the 24 candidates the wave landed nobody');
       else if(inside(LK,e2)) bad.push('with one clear point outside '+LK.name+' among the 24 candidates the wave still landed '+e2.name+' inside it at '+at(e2)+', because the farther point won');
       else if(dist(e2,O)>1) bad.push('with one clear point outside '+LK.name+' among the 24 candidates the wave landed '+e2.name+' at '+at(e2)+' rather than on it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFS) freeSpot=realFS; }catch(_f){}
       try{ if(g&&kept){ g.ents=kept.ents; g.roster=kept.roster; g.waveT=kept.waveT; g.waveN=kept.waveN; g.waveAt=kept.waveAt; g.player.x=kept.px; g.player.y=kept.py; } }catch(_k){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
