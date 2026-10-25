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

if ($s.Contains("  {v:'34.60',what:")) { throw "check 34.60 is in the fixture already" }

SubRx @'
  {v:'34.59',what:
'@ @'
  {v:'34.60',what:'cw-airchips: with all four power-up chips showing at 4K the air strike plate does not overlap the chip row (27.36 in one window)',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame&&window.__forceSize)) return 'SKIP: no frame or forced size here';
     if(typeof arcadeDeploy!=='function'||typeof airDraw!=='function'||typeof pwrDraw!=='function'||typeof HUDBOX!=='object') return 'SKIP: no arcade, air strike or power-ups here';
     var bad=[], g=null, p=null, oFR=null, ch=[], plate=null, A, S, z, HP=hudPlate, i, chip=null, r;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; p.iv=99; ARCADE.holdT=0; oFR=ctx.fillRect;
       __forceSize(3840,2160);
       A=airS(); A.m=Math.round(AIR.need*0.6); A.rdy=0; A.aim=0; A.sk=[];
       S=pwrS(); S.act={clip:12,dmg:8,rapid:5,shield:6};
       g.bagOpen=false; g.mapOpen=false; g.wheel=null;
       __frame(0.016); __frame(0.016);
       z=Math.max(1,hudRes());
       hudPlate=function(x,y,pw,ph){ if(!plate) plate={x:x,y:y,w:pw,h:ph}; return HP.apply(this,arguments); };
       try{ airDraw(ctx,p); } finally { hudPlate=HP; }
       ctx.fillRect=function(x,y,pw,ph){ if(Math.abs(ph-Math.round(24*z))<=1&&pw>40) ch.push({x:x,y:y,w:pw,h:ph}); return oFR.apply(this,arguments); };
       try{ pwrDraw(ctx,p); } finally { delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
       if(!plate) return 'the air strike plate was not drawn';
       if(!ch.length) return 'staging: no power-up chips drawn';
       chip={x:1e9,y:ch[0].y,w:0,h:ch[0].h}; r=-1e9;
       for(i=0;i<ch.length;i++){ chip.x=Math.min(chip.x,ch[i].x); r=Math.max(r,ch[i].x+ch[i].w); }
       chip.w=r-chip.x;
       if(plate.x<chip.x+chip.w&&plate.x+plate.w>chip.x&&plate.y<chip.y+chip.h&&plate.y+plate.h>chip.y) bad.push('the air strike plate ('+Math.round(plate.x)+','+Math.round(plate.y)+' '+Math.round(plate.w)+'x'+Math.round(plate.h)+') overlaps the power-up chips ('+Math.round(chip.x)+','+Math.round(chip.y)+' '+Math.round(chip.w)+'x'+Math.round(chip.h)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       hudPlate=HP; try{ delete ctx.fillRect; if(oFR&&ctx.fillRect!==oFR) ctx.fillRect=oFR; }catch(_f){}
       keys={};
       try{ if(g&&g.pwr) g.pwr.act={}; }catch(_pw){}
       try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_rz){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
