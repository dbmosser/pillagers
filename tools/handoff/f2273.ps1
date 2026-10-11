$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'22.73',what:")) { throw "check 22.73 is in the fixture already" }

SubRx @'
  {v:'22.72',what:
'@ @'
  {v:'22.73',what:'the feed stops repeating the gun card and the reticle: a dry pull that reloads, the reload running out, a pull with no rounds left, the gun swap and a belt key on a stack say no Reloading, Reloaded, Out of ammo, gun UP or item count line, while the reload the gun card draws still runs',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof swapGuns!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function'||typeof hotSel!=='function'||typeof gunCell!=='function'||typeof mouse==='undefined'||typeof keys==='undefined'||typeof WEAPONS==='undefined'||!ITEMS.bandage) return 'SKIP: no player update, gun swap, belt or weapon table in this build';
     var bad=[], g=null, p=null, keep=null, keepEnts=null, keepHot=null, keepBag=null, keepHA=null, _say=say, lines=[], ids=[], w=null, w2=null, k, i, n=0, hits=[], RL='RELO'+'AD', OA='OUT OF '+'AMMO';
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function cl(q){ var o={}, ff; for(ff in WEAPONS[q]) o[ff]=WEAPONS[q][ff]; o.jam=0; return o; }
     function frames(nf,dt){ for(var j=0;j<nf;j++){ p.lastShot=-1e9; updatePlayer(dt||0.016); } }
     function pull(){ for(var kk in keys) keys[kk]=false; p.fired=false; mouse.down=true; frames(2); mouse.down=false; frames(1); }
     function hit(m){ var s=String(m), u=s.toUpperCase(); return u.indexOf(RL)===0||u.indexOf(OA)===0||(w&&u===(w.name+' UP').toUpperCase())||(w2&&u===(w2.name+' UP').toUpperCase())||s.indexOf('  '+'x')>0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the raid is a sim';
       p=g.player;
       keep={wep:p.wep,sec:p.sec,ammo:p.ammo,secAmmo:p.secAmmo,reserve:p.reserve,reloading:p.reloading,jam:p.jam,fired:p.fired,lastShot:p.lastShot,trigYield:p.trigYield,cooking:p.cooking,swapped:p.swapped,downed:p.downed,roll:p.roll,iv:p.iv,dryTold:p.dryTold};
       keepEnts=g.ents; keepHot=g.hot; keepBag=g.bag.slice(); keepHA=JSON.parse(JSON.stringify(g.hotAssign||{}));
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&WEAPONS[k].mag>0&&WEAPONS[k].reload>0) ids.push(k);
       if(ids.length<2) return 'SKIP: fewer than two guns with a magazine in this build';
       w=cl(ids[0]); w2=cl(ids[1]);
       g.ents=[]; p.downed=false; p.roll=0; p.iv=99; p.cooking=0; p.trigYield=0; p.swapped=false; p.jam=0; p.dryTold=0;
       p.wep=w; p.sec=w2; p.secAmmo=w2.mag; p.ammo=0; p.reserve=w.mag*3; p.reloading=0; p.fired=false;
       g.hot=gunCell();
       var hc=hotbarSlots()[hotSel()];
       if(!(hc&&hc.kind==='gun')) return 'SKIP: the selected belt cell is not a gun cell here ('+(hc&&hc.kind)+')';
       say=function(m){ lines.push(String(m)); try{ return _say.apply(this,arguments); }catch(_s){} };
       // ONE: a dry pull with rounds in the backpack starts the reload the gun card draws.
       pull();
       if(!(p.reloading>0)) return skip('a dry pull on the '+w.name+' with '+p.reserve+' rounds in reserve started no reload here');
       // TWO: the reload runs out.
       for(i=0;i<600&&p.reloading>0;i++) frames(1,0.05);
       if(p.reloading>0||!(p.ammo>0)) return skip('the reload on the '+w.name+' did not finish ('+p.reloading+' ms left, '+p.ammo+' rounds)');
       // THREE: no rounds anywhere, a fresh pull.
       p.ammo=0; p.reserve=0; p.reloading=0; p.dryTold=0; pull();
       // FOUR: the gun swap.
       p.swapped=false; p.roll=0; p.reloading=0;
       if(!swapGuns()) bad.push('SKIP: staging: the gun swap was refused');
       // FIVE: a belt key holding a stack of two Bandages.
       g.bag.push('bandage'); g.bag.push('bandage');
       var sl=hotbarSlots(), bi=-1;
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind!=='gun'&&!sl[i].vacant&&sl[i].itemKey==='bandage'){ bi=i; break; }
       if(bi<0){ for(i=sl.length-1;i>=0;i--) if(sl[i]&&sl[i].kind!=='gun'&&!sl[i].vacant){ g.hotAssign[i]='bandage'; break; } sl=hotbarSlots(); for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind!=='gun'&&sl[i].itemKey==='bandage'){ bi=i; break; } }
       if(bi>=0){ g.hot=gunCell(); setHot(bi); }
       for(i=0;i<lines.length;i++) if(hit(lines[i])){ n++; hits.push(lines[i]); }
       if(n) bad.push('the reload, the empty gun, the swap and the belt key said '+n+' lines the gun card, the reticle and the belt already show: '+hits.slice(0,5).join(' | '));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=_say;
       try{ mouse.down=false; for(var k2 in keys) keys[k2]=false; }catch(_m){}
       try{ if(g&&keepEnts) g.ents=keepEnts; if(g&&keep){ g.hot=keepHot; g.bag=keepBag; g.hotAssign=keepHA; } }catch(_n){}
       try{ if(p&&keep){ for(var f2 in keep) p[f2]=keep[f2]; } }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
