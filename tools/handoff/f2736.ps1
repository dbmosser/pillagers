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

if ($s.Contains("  {v:'27.36',what:")) { throw "check 27.36 is in the fixture already" }

SubRx @'
  {v:'27.35',what:
'@ @'
  {v:'27.36',what:'strikeplace, his playtest note (air strike bar in a weird place, colliding): the air strike plate sits over on the right, at the right end of the gun bar and past the power-up chips, clear of the keys, the chips, the item in hand and the gear card, at 1080p and 4K, in player 1 and player 2 windows',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame&&window.__forceSize)) return 'SKIP: no frame or forced size here';
     if(typeof arcadeDeploy!=='function'||typeof airDraw!=='function'||typeof pwrDraw!=='function'||typeof drawHand!=='function'||typeof HUDBOX!=='object') return 'SKIP: no arcade, air strike or power-ups here';
     var bad=[], g=null, p=null, NK={}, k, HP=hudPlate, oFR=null, sizes=[[1920,1080],[3840,2160]], si, ri, roles=['host','join'], oIv, oSh, oAr, staged=false;
     function hit(a,b,m){ m=m||0; return !!a&&!!b&&a.x<b.x+b.w+m&&a.x+a.w>b.x-m&&a.y<b.y+b.h+m&&a.y+a.h>b.y-m; }
     function scene(w,h,role){
       var z, A, S, plate=null, hand=null, chip=null, cells, last, i, tag=w+' '+role+': ', ch=[], c, ov, r;
       __forceSize(w,h);
       NET.on=true; NET.max=4; NET.role=role; NET.seat=(role==='host')?0:1; NET.up=[]; NET.peers=[]; NET.upSeed=g.seed>>>0;
       A=airS(); A.m=Math.round(AIR.need*0.6); A.rdy=0; A.aim=0; A.sk=[];
       S=pwrS(); S.act={clip:12,dmg:8,rapid:5,shield:6,mag:9};
       p.hand={k:'bandage',t:0.4,len:1.2}; g.bagOpen=false; g.mapOpen=false; g.wheel=null;
       __frame(0.016); __frame(0.016);
       z=Math.max(1,hudRes());
       cells=g.hotCells||[]; last=cells.length?cells[cells.length-1]:null;
       if(!last){ bad.push(tag+'no belt drawn'); return; }
       hudPlate=function(x,y,pw,ph){ if(!plate) plate={x:x,y:y,w:pw,h:ph}; return HP.apply(this,arguments); };
       try{ airDraw(ctx,p); } finally { hudPlate=HP; }
       hudPlate=function(x,y,pw,ph){ if(!hand) hand={x:x,y:y,w:pw,h:ph}; return HP.apply(this,arguments); };
       try{ drawHand(); } finally { hudPlate=HP; }
       ctx.fillRect=function(x,y,pw,ph){ if(Math.abs(ph-Math.round(24*z))<=1&&pw>40) ch.push({x:x,y:y,w:pw,h:ph}); return oFR.apply(this,arguments); };
       try{ pwrDraw(ctx,p); } finally { delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
       if(ch.length){ chip={x:1e9,y:ch[0].y,w:0,h:ch[0].h}; r=-1e9; for(i=0;i<ch.length;i++){ chip.x=Math.min(chip.x,ch[i].x); r=Math.max(r,ch[i].x+ch[i].w); } chip.w=r-chip.x; }
       if(!plate){ bad.push(tag+'the air strike plate was not drawn'); return; }
       if(!chip) bad.push(tag+'staging: no power-up chips drawn');
       if(!hand) bad.push(tag+'staging: no item in hand drawn');
       if(plate.x<0||plate.y<0||plate.x+plate.w>W||plate.y+plate.h>H) bad.push(tag+'the plate is partly off the screen ('+Math.round(plate.x)+','+Math.round(plate.y)+' '+Math.round(plate.w)+'x'+Math.round(plate.h)+' on '+W+'x'+H+')');
       for(i=0;i<cells.length;i++) if(hit(plate,cells[i],0)){ bad.push(tag+'the plate overlaps belt key '+i); break; }
       if(chip&&hit(plate,chip,0)) bad.push(tag+'the plate overlaps the power-up chips');
       if(hand&&hit(plate,hand,0)) bad.push(tag+'the plate overlaps the item in hand');
       if(hand&&plate.x<hand.x+hand.w) bad.push(tag+'the plate starts left of the end of the item in hand');
       if(hit(plate,HUDBOX.gear,0)) bad.push(tag+'the plate overlaps the gear card');
       if(hit(plate,HUDBOX.body,0)) bad.push(tag+'the plate overlaps the health block');
       if(Math.abs((plate.x+plate.w)-(last.x+last.w))>Math.round(24*z)) bad.push(tag+'the plate ends at '+Math.round(plate.x+plate.w)+', not at the right end of the gun bar ('+Math.round(last.x+last.w)+')');
       if(!(plate.y+plate.h<=last.y)) bad.push(tag+'the plate is not over the gun bar');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oSh=p.arcSh; oAr=p.armor; oIv=p.iv; p.iv=99; ARCADE.holdT=0;
       oFR=ctx.fillRect;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       for(si=0;si<sizes.length;si++) for(ri=0;ri<roles.length;ri++) scene(sizes[si][0],sizes[si][1],roles[ri]);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       hudPlate=HP; try{ delete ctx.fillRect; if(oFR&&ctx.fillRect!==oFR) ctx.fillRect=oFR; }catch(_f){}
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       keys={};
       try{ if(p){ p.hand=null; p.arcSh=oSh; p.armor=oAr; p.iv=oIv; p.hp=100; } }catch(_q){}
       try{ if(g&&g.pwr) g.pwr.act={}; }catch(_pw){}
       try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_rz){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
