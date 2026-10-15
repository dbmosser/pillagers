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

if ($s.Contains("  {v:'26.88',what:")) { throw "check 26.88 is in the fixture already" }

SubRx @'
  {v:'26.87',what:
'@ @'
  {v:'26.88',what:'party2, his yes to arcade power-ups (40): kills drop timed pickups at a low rate from a side stream (the same raid drops the same ones and the main stream does not move); walking over one takes it; BOTTOMLESS CLIP keeps the magazine full and the trigger live with nothing in reserve; DOUBLE DAMAGE doubles a round; RAPID FIRE shortens the trigger gap; the coin, the ring and a timer chip are drawn',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__sim)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oWep, oAmmo, oRes, i, S, last, log1, log2, n1, s0, s1, kinds={}, d1, d2, c1, c2, arcs=[], txts=[], proto, oArc, oFt, sp, hit;
     function step(n){ var q; for(q=0;q<n;q++){ g.t+=0.016; __sim(0.016); } }
     function arm(w,a,r){ var HS=hotbarSlots(), ix=-1, q0; for(q0=0;q0<HS.length;q0++) if(HS[q0]&&HS[q0].kind==='gun'&&!HS[q0].vacant){ ix=q0; break; } if(ix>=0&&hotSel()!==ix) setHot(ix); mouse.down=false; p.wep=w; p.ammo=a; p.reserve=r; p.reloading=0; p.hand=false; p.jam=0; p.fired=false; p.spin=0; g.t+=0.016; __sim(0.016); for(var q=0;q<260&&p.drawT>0;q++){ g.t+=0.016; __sim(0.016); } p.lastShot=-1e9; p.fired=false; g.bullets.length=0; }
     function drops(){ var q; g.pwr=null; S=pwrS(); for(q=0;q<1000;q++){ g.t+=1; S.items.length=0; pwrKill('crawler',0,false,p.x+60,p.y,null); } return S; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof pwrKill!=='function'||typeof pwrTick!=='function'||typeof pwrDraw!=='function') return 'there are no power-ups in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve;
       g.ents=g.ents.filter(function(q){ return q&&(q.neutral||q.kind==='peddler'||q.kind==='stray'); });
       // ONE: a low rate from a side stream: the same kills drop the same pickups, and the main stream does not move
       s0=RNGS; S=drops(); s1=RNGS; n1=S.drops; log1=S.log.join(',');
       if(s0!==s1) bad.push('ONE: a thousand kills moved the main random stream');
       if(!(n1>=10&&n1<=80)) bad.push('ONE: a thousand kills dropped '+n1+' power-ups (not a low rate)');
       S=drops(); log2=S.log.join(',');
       if(log1!==log2) bad.push('ONE: the same raid and the same kills dropped different power-ups the second time');
       S.log.forEach(function(w){ kinds[w.split(':')[1]]=1; });
       if(Object.keys(kinds).length<3) bad.push('ONE: only '+Object.keys(kinds).join(',')+' ever dropped');
       g.pwr=null; S=pwrS(); g.t+=100; pwrKill('warden',0,true,p.x+60,p.y,{});
       if(S.items.length!==1) bad.push('ONE: a boss kill dropped '+S.items.length+' power-ups, not one');
       // TWO: walk over to take it; a far one stays; an old one goes
       S.items.length=0; S.act={};
       S.items.push({k:'clip',x:p.x+10,y:p.y,t:0,life:16,id:1}); S.items.push({k:'dmg',x:p.x+500,y:p.y,t:0,life:16,id:2});
       pwrTick(p,0.05);
       if(!(S.act.clip>19.5&&S.act.clip<=20)) bad.push('TWO: walking over a bottomless clip set its clock to '+S.act.clip);
       if(S.items.length!==1||S.act.dmg>0) bad.push('TWO: a pickup 500 away was taken ('+S.items.length+' left)');
       S.items[0].t=15.99; pwrTick(p,0.05);
       if(S.items.length) bad.push('TWO: a pickup past its life stayed on the floor');
       // THREE: BOTTOMLESS CLIP: nothing in reserve, the trigger held: three rounds without it, a stream with it
       S.act={}; arm(cloneObj(WEAPONS.smg),3,0); mouse.down=true; step(40); c1=g.bullets.length;
       if(c1!==3) bad.push('THREE: the control fired '+c1+' rounds from a 3 round magazine with nothing in reserve');
       arm(cloneObj(WEAPONS.smg),3,0); S.act.clip=20; mouse.down=true; step(60); c2=g.bullets.length;
       if(c2<8) bad.push('THREE: with the bottomless clip only '+c2+' rounds left the gun in a second');
       if(p.ammo!==p.wep.mag) bad.push('THREE: the magazine reads '+p.ammo+' of '+p.wep.mag+' under the bottomless clip');
       if(p.reloading>0) bad.push('THREE: the gun is reloading under the bottomless clip');
       // FOUR: DOUBLE DAMAGE: one round, twice as hard
       S.act={}; arm(cloneObj(WEAPONS.smg),30,300); mouse.down=true; step(8); d1=g.bullets.length?g.bullets[0].dmg:0;
       arm(cloneObj(WEAPONS.smg),30,300); S.act.dmg=15; mouse.down=true; step(8); d2=g.bullets.length?g.bullets[0].dmg:0;
       if(!(d1>0)||Math.abs(d2/d1-2)>1e-9) bad.push('FOUR: a round did '+d1+' and with double damage '+d2);
       // FIVE: RAPID FIRE: more rounds in the same second
       S.act={}; arm(cloneObj(WEAPONS.smg),30,300); mouse.down=true; step(60); c1=g.bullets.length;
       arm(cloneObj(WEAPONS.smg),30,300); S.act.rapid=15; mouse.down=true; step(60); c2=g.bullets.length;
       if(!(c1>=5&&c2>=c1*1.4)) bad.push('FIVE: a second of fire gave '+c1+' rounds and with rapid fire '+c2);
       mouse.down=false; S.act={};
       // SIX: the coin, the ring and the chip are drawn
       S.items.length=0; S.act={clip:20};
       S.items.push({k:'dmg',x:p.x+160,y:p.y+30,t:0,life:16,id:3});
       render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push(String(arguments[0])); return oFt.apply(this,arguments); };
       try{ pwrDraw(ctx,p); } finally { proto.arc=oArc; proto.fillText=oFt; }
       sp=w2s(p.x+160,0,p.y+30); hit=0;
       for(i=0;i<arcs.length;i++) if(Math.abs(arcs[i][0]-sp.x)<1&&Math.abs(arcs[i][1]-sp.y)<24*ZOOM()&&arcs[i][2]>=10*ZOOM()) hit++;
       if(hit<2) bad.push('SIX: the pickup coin was not drawn where it lies ('+arcs.length+' arcs)');
       if(txts.join('|').indexOf('BOTTOMLESS'+' CLIP')<0) bad.push('SIX: the timer chip did not name the bottomless clip');
       if(txts.join('|').indexOf('2X')<0) bad.push('SIX: the double damage coin has no glyph');
       arcs.length=0; txts.length=0; S.items.length=0; S.act={};
       proto.arc=function(){ arcs.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ pwrDraw(ctx,p); } finally { proto.arc=oArc; }
       if(arcs.length) bad.push('SIX: something was drawn with no pickup and no power-up running ('+arcs.length+' arcs)');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={}; try{ mouse.down=false; }catch(_m){}
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.fired=false; } }catch(_w){}
       try{ if(g){ g.pwr=null; g.bullets.length=0; } }catch(_gp){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
