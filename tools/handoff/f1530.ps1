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
  {v:'15.29',what:
'@ @'
  {v:'15.30',what:'an automatic gun that runs dry on a held trigger clicks once: a fresh pull on the empty gun clicks and says Out of ammo once, holding the trigger through its last two rounds with no ammo left in the backpack plays the dry click and says Out of ammo once, neither repeats over the held frames after, and a fresh pull after letting go clicks once again (sound audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof blip!=='function'||typeof say!=='function'||typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof mouse==='undefined'||typeof keys==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: no player update, blip, say, belt, trigger or weapon table in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, keepHot=null, _blip=blip, _say=say, heard=[], lines=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var count=function(t){ var c=0; for(var j=0;j<heard.length;j++) if(heard[j]===t) c++; return c; };
     var outs=function(){ var c=0; for(var j=0;j<lines.length;j++) if(lines[j]==='Out of ammo.') c++; return c; };
     var clear=function(){ heard.length=0; lines.length=0; };
     // Frames with the trigger held. updatePlayer alone does not move the raid clock, so the rate of fire clock is staged as run
     // out on each frame, the way a held automatic comes round to its next shot.
     var hold=function(nf){ for(var k in keys) keys[k]=false; mouse.down=true; for(var f=0;f<nf;f++){ p.lastShot=-1e9; updatePlayer(0.016); } };
     var letGo=function(){ for(var k in keys) keys[k]=false; mouse.down=false; updatePlayer(0.016); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.ents) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim, and a sim plays no sound';
       p=g.player;
       keep={wep:p.wep,ammo:p.ammo,reserve:p.reserve,reloading:p.reloading,jam:p.jam,fired:p.fired,lastShot:p.lastShot,trigYield:p.trigYield,cooking:p.cooking,swapped:p.swapped,downed:p.downed,roll:p.roll,iv:p.iv};
       keepEnts=g.ents; keepHot=g.hot;
       // An automatic: the gun in his hands if it is one, else a starter automatic. A copy with no jam, so the weapon table is
       // untouched and no round is lost to a jam roll.
       var base=(p.wep&&p.wep.auto&&p.wep.mag>0)?p.wep:(WEAPONS.sputter||WEAPONS.chatter||WEAPONS.smg);
       if(!(base&&base.auto&&base.mag>0)) return 'SKIP: no automatic gun in this build';
       var w=Object.assign({},base); w.jam=0;
       g.ents=[]; p.downed=false; p.roll=0; p.iv=99; p.cooking=0; p.trigYield=0; p.swapped=false;
       p.wep=w; p.reloading=0; p.jam=0; p.reserve=0; p.ammo=0; p.fired=false;
       g.hot=(typeof gunCell==='function')?gunCell():0;
       var sl=hotbarSlots(), hc=sl[hotSel()];
       // CONTROL: the selected belt cell is a gun cell, so the trigger goes to the gun and not to a held item.
       if(!(hc&&hc.kind==='gun')) return 'SKIP: the selected belt cell is not a gun cell here ('+(hc&&hc.kind)+')';
       blip=function(t){ heard.push(String(t)); try{ return _blip.apply(null,arguments); }catch(_b){} };
       say=function(m){ lines.push(String(m)); try{ return _say.apply(null,arguments); }catch(_s){} };
       // CONTROL: a fresh pull on the empty automatic, held three frames, clicks and says Out of ammo on either build, so the
       // recorder hears the empty gun and the held frames reach the trigger. Once only, on both builds.
       clear(); hold(3);
       if(p.wep!==w) return skip('the gun in his hands changed on the first frame, so the staged automatic was not the one pulled');
       if(count('dry')<1||outs()<1) return skip('a fresh pull on the empty '+w.name+' with nothing in the backpack gave '+count('dry')+' dry clicks and '+outs()+' Out of ammo lines, so the recorder cannot hear the empty gun here');
       if(count('dry')!==1||outs()!==1) bad.push('a fresh pull on the empty '+w.name+' held three frames gave '+count('dry')+' dry clicks and '+outs()+' Out of ammo lines, not one of each');
       letGo();
       // THE FIX: two rounds in the magazine, none in the backpack, a fresh pull held through both and four frames after.
       p.ammo=2; p.reloading=0; p.jam=0;
       clear(); hold(6);
       // CONTROL: both rounds left this gun on the one hold and nothing reloaded it.
       if(p.wep!==w||count('shot')!==2||p.ammo!==0||p.reloading>0) return skip('holding the trigger fired '+count('shot')+' of the two rounds and left '+p.ammo+' in the magazine (reloading '+p.reloading+(p.wep!==w?', and the gun in his hands changed':'')+'), so the gun did not run dry on the held trigger here');
       var dry=count('dry'), said=outs();
       if(dry===0&&said===0) bad.push('the '+w.name+' ran dry with the trigger held and nothing in the backpack and just stopped: no dry click and no Out of ammo over four more held frames');
       else {
         if(dry!==1) bad.push('the '+w.name+' ran dry with the trigger held and played the dry click '+dry+' times over four held frames, not once');
         if(said!==1) bad.push('the '+w.name+' ran dry with the trigger held and said Out of ammo '+said+' times over four held frames, not once');
       }
       letGo();
       // AND AGAIN: after letting go, a fresh pull on the empty gun clicks once more.
       clear(); hold(3);
       if(count('dry')!==1||outs()!==1) bad.push('after the held trigger ran the '+w.name+' dry and was let go, a fresh pull gave '+count('dry')+' dry clicks and '+outs()+' Out of ammo lines, not one of each');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       blip=_blip; say=_say;
       try{ mouse.down=false; for(var k2 in keys) keys[k2]=false; }catch(_m){}
       try{ if(g&&keepEnts) g.ents=keepEnts; if(g&&keep) g.hot=keepHot; }catch(_n){}
       try{ if(p&&keep){ for(var f2 in keep) p[f2]=keep[f2]; } }catch(_k){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
