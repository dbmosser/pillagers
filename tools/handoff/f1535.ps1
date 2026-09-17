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
  {v:'15.34',what:
'@ @'
  {v:'15.35',what:'a mouse click on the open stall never fires the gun behind it: a left click on the open Peddler stall spends no Scav Pistol round and leaves the stall open, a Compact SMG trigger held while E opens the stall lets go and fires no more behind the panel, and with the stall shut the same click still fires (peddler audit finding 7)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof mkPeddler!=='function'||typeof hotbarSlots!=='function'||typeof gunCell!=='function'||typeof hotSel!=='function'||typeof inRect!=='function') return 'SKIP: no player update, Peddler or tactical belt in this build';
     if(typeof keys==='undefined'||typeof mouse==='undefined'||typeof cv==='undefined'||!cv) return 'SKIP: no raid canvas, mouse or keys in this build';
     if(!WEAPONS.pistol||!WEAPONS.smg||!WEAPONS.smg.auto||!(WEAPONS.pistol.mag>0)) return 'SKIP: no Scav Pistol or automatic Compact SMG in this build';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, shut=[], pt=null, keepMouse={x:mouse.x,y:mouse.y};
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; w.jam=0; return w; }
     // A fresh gun of that kind in his hands, a full magazine, no reserve, and the trigger clear; the highlight on its cell.
     function arm(id){ p.wep=copyW(id); p.ammo=p.wep.mag; p.reserve=0; p.reloading=0; p.jam=0; p.cooking=0; p.fired=false; p.trigYield=0; p.lastShot=-1e9; g.hot=gunCell(); }
     // The HUD panels and the belt cells claim a click of their own, so the point must be clear of both.
     function furniture(x,y){
       var k,i,c=g.hotCells||[];
       if(typeof HUDBOX!=='undefined') for(k in HUDBOX){ if(HUDBOX[k]&&inRect(HUDBOX[k],x,y)) return true; }
       for(i=0;i<c.length;i++) if(inRect(c[i],x,y)) return true;
       return false;
     }
     function down(){ mouse.x=pt.x; mouse.y=pt.y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,clientX:pt.x,clientY:pt.y,bubbles:true,cancelable:true})); }
     function up(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); mouse.down=false; }
     // One player frame. Rounds it fires are counted off the magazine and then taken out of the air, so none reaches the Peddler.
     function step(){ var nb=g.bullets?g.bullets.length:0; updatePlayer(1/60); if(g.bullets) g.bullets.length=nb; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       p=g.player;
       keep={wep:p.wep,ammo:p.ammo,reserve:p.reserve,reloading:p.reloading,jam:p.jam,cooking:p.cooking,fired:p.fired,trigYield:p.trigYield,lastShot:p.lastShot,hot:g.hot};
       clearKeys(); mouse.down=false;
       p.downed=false; p.dying=false; p.roll=0; p.iv=99;
       g.bagOpen=false; g.mapOpen=false; g.drag=null; g.trade=null; g.pedLock=0;
       // Only the Peddler, 40 units to his right, and no crate under his feet to take E from the stall.
       keepEnts=g.ents.slice(); g.ents.length=0;
       for(var ci=0;ci<g.containers.length;ci++){ var CU=g.containers[ci]; if(!CU.opened&&dist(CU,p)<60){ CU.opened=true; shut.push(CU); } }
       var pd=mkPeddler(p.x+40,p.y,g.map); g.ents.push(pd);
       arm('pistol');
       var hs=hotbarSlots()[hotSel()];
       // CONTROL: the highlighted cell is the Scav Pistol in his hands, so the trigger fires it.
       if(!(hs&&hs.kind==='gun'&&p.wep.id==='pistol'&&p.ammo>0)) return 'SKIP: the highlighted belt cell is not the Scav Pistol in his hands here ('+(hs&&hs.kind)+')';
       // The left half of the stall panel, which sits in the middle of the screen, then points off it.
       var cw=(typeof W==='number'&&W>0)?W:1920, ch=(typeof H==='number'&&H>0)?H:1080, pw=(typeof LH==='function')?LH(340):340;
       var cand=[[cw/2-pw*0.3,ch/2],[cw/2-pw*0.3,ch/2-pw*0.2],[cw/2+pw*0.3,ch/2],[cw*0.3,ch*0.4],[cw*0.7,ch*0.4]];
       for(var q=0;q<cand.length&&!pt;q++) if(!furniture(cand[q][0],cand[q][1])) pt={x:cand[q][0],y:cand[q][1]};
       if(!pt) return 'SKIP: every point tried is under a HUD panel or a belt cell here';
       // CONTROL: with the stall shut, a left click at that point fires one round.
       var a0=p.ammo; down(); step(); up();
       if(p.ammo!==a0-1) return 'SKIP: a left click with the stall shut spent '+(a0-p.ammo)+' rounds here, so a shot cannot be seen';
       // Open the stall the way he does: one frame with E down beside the Peddler, one with it up.
       clearKeys(); g.pedLock=0; keys['KeyE']=true; step(); clearKeys(); step();
       // CONTROL: the stall is open.
       if(g.trade!==pd) return 'SKIP: E beside the Peddler did not open the stall here';
       // THE FIX, ONE: a left click on the open stall spends no round and leaves the stall open.
       arm('pistol'); var a1=p.ammo;
       down(); step(); up();
       if(p.ammo!==a1) bad.push('with the stall open, a left click on the panel fired the Scav Pistol behind it ('+(a1-p.ammo)+' round spent)');
       if(g.trade!==pd) bad.push('a left click on the open stall shut it');
       // THE FIX, TWO: the stall shut, the Compact SMG trigger held, and E pressed beside the Peddler.
       g.trade=null; g.pedLock=0; clearKeys();
       arm('smg');
       hs=hotbarSlots()[hotSel()];
       if(!(hs&&hs.kind==='gun'&&p.wep.id==='smg'&&p.ammo>0)) return skip('the highlighted belt cell is not the Compact SMG in his hands here');
       down();
       // CONTROL: the click with the stall shut holds the trigger.
       if(!mouse.down) return skip('a left click with the stall shut did not hold the trigger here');
       var a2=p.ammo;
       keys['KeyE']=true; step(); clearKeys();
       // CONTROL: the held trigger fired once on the frame before the stall took over, and the stall is open.
       if(g.trade!==pd) return skip('E beside the Peddler with the trigger held did not open the stall here');
       if(p.ammo!==a2-1) return skip('the held trigger spent '+(a2-p.ammo)+' Compact SMG rounds on the frame the stall opened, not 1');
       var a3=p.ammo;
       for(var f=0;f<3;f++){ p.lastShot=-1e9; step(); }
       if(p.ammo!==a3) bad.push('a Compact SMG trigger held while E opened the stall kept firing behind the panel: '+(a3-p.ammo)+' rounds in 3 frames with the stall open');
       up();
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ up(); }catch(_u){}
       try{ mouse.x=keepMouse.x; mouse.y=keepMouse.y; }catch(_m){}
       try{ clearKeys(); }catch(_k){}
       try{ if(g){ g.trade=null; g.pedLock=0; } }catch(_t){}
       try{ if(p&&keep){ p.wep=keep.wep; p.ammo=keep.ammo; p.reserve=keep.reserve; p.reloading=keep.reloading; p.jam=keep.jam; p.cooking=keep.cooking; p.fired=keep.fired; p.trigYield=keep.trigYield; p.lastShot=keep.lastShot; g.hot=keep.hot; } }catch(_p){}
       try{ for(var sh=0;sh<shut.length;sh++) shut[sh].opened=false; }catch(_o){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
