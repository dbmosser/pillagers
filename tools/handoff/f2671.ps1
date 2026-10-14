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

if ($s.Contains("  {v:'26.71',what:")) { throw "check 26.71 is in the fixture already" }

SubRx @'
  {v:'26.70',what:
'@ @'
  {v:'26.71',what:'flow2, his yes to the air strike: the damage you deal fills a meter (damage from anything else does not), the callout says AIR STRIKE READY, G aims it, LMB calls it, six blasts kill the hostile machines under it, it never hurts you, a teammate or hire, or a peaceful bystander, it does not refill its own meter, and the ring follows the cursor',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], e1, e2, eA, eN, A, hp0, i, sawR, sawI, needR='READ'+'Y', cap=[], proto, oArc, s, hit, oMx, oMy, oMd, pz, f;
     function nearCut(){ g.ents=g.ents.filter(function(q){ return !(q&&!q.neutral&&q.kind!=='peddler'&&q.kind!=='stray'&&(q.kind!=='raider'||q.hostile)&&dist(q,p)<1500); }); }
     function aimAt(wx,wy){ pz=ZOOM(); mouse.x=(wx-g.camX)*pz; mouse.y=(wy-g.camY)*pz; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof flowTick!=='function'||typeof airKey!=='function') return 'there is no air strike in this build';
       p=g.player; keys={}; oMx=mouse.x; oMy=mouse.y; oMd=mouse.down; mouse.down=false;
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; p.hurtAt=-999;
       nearCut();
       e1=mkCrawler(p.x+30,p.y); e2=mkCrawler(p.x-30,p.y+10); eA=mkCrawler(p.x,p.y-40); eN=mkCrawler(p.x+10,p.y+40);
       eA.merc=1; eN.neutral=1;
       g.ents.push(e1,e2,eA,eN);
       render2D(0);
       flowTick(0.016); A=g.flow&&g.flow.air;
       if(!A) return 'the air strike has no state after a tick';
       // ONE: only damage that carries your hit mark fills the meter
       e1.pHitT=0.3; e1.hp-=40; flowTick(0.016);
       if(Math.abs(A.m-40)>1) bad.push('ONE: 40 damage of yours fills the meter to '+A.m.toFixed(1));
       e2.pHitT=0; e2.hp-=30; flowTick(0.016);
       if(Math.abs(A.m-40)>1) bad.push('ONE: 30 damage that was not yours moved the meter to '+A.m.toFixed(1));
       // TWO: not charged, G only says how far it is, and does not aim
       if(airKey()!==false||A.aim) bad.push('TWO: G aimed an air strike with the meter at '+A.m.toFixed(0));
       // THREE: full, the callout, and G aims
       lines.length=0; A.m=AIR.need-3; e1.pHitT=0.3; e1.hp-=5; flowTick(0.016);
       if(!(A.m>=AIR.need)) bad.push('THREE: the meter is '+A.m.toFixed(1)+' of '+AIR.need);
       sawR=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needR)>=0) sawR=1;
       if(!sawR) bad.push('THREE: no AIR STRIKE READY callout (said: '+lines.slice(-3).join(' / ')+')');
       airKey(); if(!A.aim) bad.push('THREE: G did not aim a charged air strike');
       // FOUR: the aim ring follows the cursor, drawn on the HUD
       render2D(0); aimAt(p.x,p.y); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(p.x,0,p.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&cap[i][2]>AIR.R*ZOOM()) hit++;
       if(!hit) bad.push('FOUR: no aim ring was drawn at the cursor ('+cap.length+' arcs)');
       // FIVE: the click calls it (not before the aim has been held 0.15 s)
       flowTick(0.2); mouse.down=false; flowTick(0.016); mouse.down=true; flowTick(0.016); mouse.down=false;
       if(A.sk.length!==1) bad.push('FIVE: the click called '+A.sk.length+' strikes');
       if(A.m!==0||A.aim) bad.push('FIVE: the call left the meter at '+A.m+' and the aim '+A.aim);
       sawI=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf('INBO'+'UND')>=0) sawI=1;
       if(!sawI) bad.push('FIVE: no AIR STRIKE INBOUND callout');
       // SIX: the strike lands on the hostile, not on you, the hire or the bystander, and does not refill the meter
       hp0=p.hp; f=0;
       for(i=0;i<40;i++){ flowTick(0.1); f++; }
       if(!(e1.hp<=0&&e2.hp<=0)) bad.push('SIX: the machines under the strike live (hp '+Math.round(e1.hp)+' and '+Math.round(e2.hp)+')');
       else if(!e1.byPlayer) bad.push('SIX: the kill is not credited to you');
       if(eA.hp<eA.maxhp) bad.push('SIX: the strike hurt your hire ('+Math.round(eA.hp)+' of '+eA.maxhp+')');
       if(eN.hp<eN.maxhp) bad.push('SIX: the strike hurt a bystander ('+Math.round(eN.hp)+' of '+eN.maxhp+')');
       if(p.hp<hp0) bad.push('SIX: the strike hurt YOU ('+hp0+' to '+p.hp+')');
       if(A.m>1) bad.push('SIX: the strike refilled its own meter to '+A.m.toFixed(0));
       if(A.sk.length) bad.push('SIX: the strike never finished');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={}; try{ mouse.x=oMx; mouse.y=oMy; mouse.down=oMd; }catch(_m){}
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
