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

if ($s.Contains("  {v:'26.89',what:")) { throw "check 26.89 is in the fixture already" }

SubRx @'
  {v:'26.88',what:
'@ @'
  {v:'26.89',what:'party3, his yes to the other power-ups (40): a MAGNET slides loose wrecks and pickups to you, a SHIELD BUBBLE takes every hit, a SCREEN CLEAR kills the ordinary machines on screen (never a boss, an elite or a pillager) for a flat bonus; all three drop, and are drawn',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__sim)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, S, i, j, a, x, y, ok, cc, d0, d1, hp0, oSh, oAr, oIv, kinds={}, cr, sn, bo, el, rd, far, arcs=[], txts=[], proto, oArc, oFt, sp, hit, q, it, oGlyph;
     function step(n){ var k; for(k=0;k<n;k++){ g.t+=0.016; __sim(0.016); } }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof pwrMagnet!=='function'||typeof pwrPulse!=='function'||typeof pwrShieldHit!=='function') return 'there are no magnet, shield or screen clear in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; hp0=p.hp;
       g.ents=g.ents.filter(function(q2){ return q2&&(q2.neutral||q2.kind==='peddler'||q2.kind==='stray'); });
       g.pwr=null; S=pwrS();
       // ONE: all six kinds drop
       for(i=0;i<3000;i++){ g.t+=1; S.items.length=0; pwrKill('crawler',0,false,p.x+60,p.y,null); }
       S.log.forEach(function(w){ kinds[w.split(':')[1]]=1; });
       S.log.length=0;
       ['clip','dmg','rapid','mag','shield','pulse'].forEach(function(k){ if(!kinds[k]) bad.push('ONE: '+k+' never dropped in three thousand kills'); });
       // TWO: the magnet: a body on open ground slides to the player, and a pickup too; with no magnet nothing moves
       S.items.length=0; S.act={}; ok=0;
       for(j=0;j<12&&!ok;j++){
         a=j*0.5236; x=p.x+Math.cos(a)*300; y=p.y+Math.sin(a)*300;
         if(losClear(p.x,p.y,x,y,g.map.segs)&&!shutRoomAt(g.map,x,y)){ ok=1; for(i=0;i<=20;i++) if(!spotFree(g.map,p.x+(x-p.x)*i/20,p.y+(y-p.y)*i/20,16)) ok=0; }
       }
       if(!ok) return 'SKIP: staging: no open ground 300 from the drop for a test wreck';
       cc=setLoot(mkContainer(x,y,'body'),['scrap']); g.containers.push(cc); g.searching=null;
       d0=Math.hypot(p.x-cc.x,p.y-cc.y); step(40); d1=Math.hypot(p.x-cc.x,p.y-cc.y);
       if(Math.abs(d1-d0)>1) bad.push('TWO: a wreck moved '+Math.round(d0-d1)+' with no magnet running');
       S.act.mag=20; d0=Math.hypot(p.x-cc.x,p.y-cc.y); step(40); d1=Math.hypot(p.x-cc.x,p.y-cc.y);
       if(!(d0-d1>=120)) bad.push('TWO: with the magnet a wreck 300 off came only '+Math.round(d0-d1)+' closer in 0.64 s');
       step(120); d1=Math.hypot(p.x-cc.x,p.y-cc.y);
       if(!(d1<=PWRX.magStop+2&&d1>=PWRX.magStop-2)) bad.push('TWO: the wreck stopped '+Math.round(d1)+' from the player, not at '+PWRX.magStop);
       g.containers.splice(g.containers.indexOf(cc),1);
       S.items.push({k:'dmg',x:p.x+400,y:p.y,t:0,life:16,id:1}); step(60);
       if(S.items.length&&S.items[0].x>p.x+390) bad.push('TWO: a pickup 400 away did not move toward the player under the magnet');
       S.items.length=0; S.act={};
       // THREE: the shield bubble takes every hit
       p.arcSh=0; p.armor=0; p.iv=0; p.hp=100; hp0=100;
       damagePlayer(20,'sentry','SENTRY',p.x+100,p.y);
       if(!(p.hp<hp0)) bad.push('THREE: the control hit did no damage');
       p.hp=100; S.act.shield=10; damagePlayer(20,'sentry','SENTRY',p.x+100,p.y);
       if(p.hp!==100) bad.push('THREE: a hit under the shield bubble took '+(100-p.hp));
       if(!(S.shFlash>0)) bad.push('THREE: the bubble did not flash');
       S.act.shield=0; p.hp=100;
       // FOUR: the screen clear
       render2D(0);
       cr=mkCrawler(p.x+100,p.y+20); sn=mkSentry(p.x-120,p.y-40); bo=mkCrawler(p.x+60,p.y-80); bo.boss=1; el=mkCrawler(p.x-60,p.y+90); el.elite=1;
       rd=mkRaider(p.x+150,p.y+60,undefined,true); rd.hostile=true; rd.downed=0; far=mkCrawler(p.x+6000,p.y);
       g.ents=[cr,sn,bo,el,rd,far];
       ARCADE.mine=0; ARCADE.streak=null; S.items.length=0; S.items.push({k:'pulse',x:p.x,y:p.y,t:0,life:16,id:9});
       pwrTick(p,0.05);
       if(!(cr.hp<=0)) bad.push('FOUR: a crawler on the screen survived the screen clear');
       if(!(sn.hp<=0)) bad.push('FOUR: a sentry on the screen survived the screen clear');
       if(!(bo.hp>0)) bad.push('FOUR: a boss died to the screen clear');
       if(!(el.hp>0)) bad.push('FOUR: an elite died to the screen clear');
       if(!(rd.hp>0)) bad.push('FOUR: a pillager died to the screen clear');
       if(!(far.hp>0)) bad.push('FOUR: a machine far off the screen died to the screen clear');
       if(ARCADE.mine!==2*PWRX.pulsePer) bad.push('FOUR: the screen clear paid '+ARCADE.mine+', not '+(2*PWRX.pulsePer));
       if(ARCADE.kills) bad.push('FOUR: the screen clear counted '+ARCADE.kills+' kills');
       if(!S.pulse) bad.push('FOUR: the screen clear left no wave to draw');
       // FIVE: the bubble, the wave, and the three coins are drawn
       S.act={shield:10}; S.pulse={t:0.2,x:p.x,y:p.y}; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ pwrDraw2(ctx,p); } finally { proto.arc=oArc; proto.fillText=oFt; }
       sp=w2s(p.x,0,p.y); hit=0; q=0;
       for(i=0;i<arcs.length;i++){ if(Math.abs(arcs[i][0]-sp.x)<1&&Math.abs(arcs[i][1]-(sp.y-14*ZOOM()))<1&&Math.abs(arcs[i][2]-34*ZOOM())<1.5) hit++; if(Math.abs(arcs[i][0]-sp.x)<1&&Math.abs(arcs[i][1]-sp.y)<1&&arcs[i][2]>60) q++; }
       if(hit<2) bad.push('FIVE: the shield bubble was not drawn round the player ('+arcs.length+' arcs)');
       if(!q) bad.push('FIVE: the screen clear wave was not drawn');
       arcs.length=0; txts.length=0; S.act={}; S.pulse=null; S.items.length=0;
       S.items.push({k:'mag',x:p.x+120,y:p.y,t:0,life:16,id:11}); S.items.push({k:'shield',x:p.x-120,y:p.y,t:0,life:16,id:12}); S.items.push({k:'pulse',x:p.x,y:p.y+120,t:0,life:16,id:13});
       render2D(0);
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ pwrDraw(ctx,p); } finally { proto.arc=oArc; }
       hit=0; for(j=0;j<S.items.length;j++){ sp=w2s(S.items[j].x,0,S.items[j].y); for(i=0;i<arcs.length;i++) if(Math.abs(arcs[i][0]-sp.x)<1&&Math.abs(arcs[i][1]-sp.y)<24*ZOOM()&&arcs[i][2]>=10*ZOOM()){ hit++; break; } }
       if(hit<3) bad.push('FIVE: only '+hit+' of the three new coins were drawn');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={}; try{ mouse.down=false; }catch(_m){}
       try{ if(p){ p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=hp0; } }catch(_w){}
       try{ if(g){ g.pwr=null; g.bullets.length=0; g.searching=null; } }catch(_gp){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; ARCADE.streak=null; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
