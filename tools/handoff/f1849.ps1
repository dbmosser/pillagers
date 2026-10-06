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

if ($s.Contains("  {v:'18.49',what:")) { throw "check 18.49 is in the fixture already" }

SubRx @'
  {v:'18.48',what:
'@ @'
  {v:'18.49',what:'at 4K the HUD stack does not overlap: the HIDDEN chip sits above the weapon panel, the boss name sits below the clock and compass, and the offer line below the boss bar',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     if(typeof hudPanel!=='function') return 'SKIP: no HUD panel';
     var bad=[], g, oHP=hudPanel, seen=[], oFT=ctx.fillText, texts=[], chip=null, wp=null, i, e=null, bossY=null, compY=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(3840,2160);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.bagOpen=false; g.pCrouch=true;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].name===BOSS_NAME&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(e){ e.x=g.player.x+150; e.y=g.player.y; g.bossRef=e; }
       __frame(0.016);
       hudPanel=function(x,y,w,h,a){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; seen.push([(m.a*x+m.c*y+m.e)/d,(m.b*x+m.d*y+m.f)/d,w*m.a/d,h*m.d/d]); return oHP.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; texts.push([String(s),(m.b*x+m.d*y+m.f)/d]); return oFT.apply(this,arguments); };
       __frame(0.016);
       hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT;
       seen.forEach(function(r){ if(r[0]+r[2]>=W-40&&r[1]>H*0.5){ if(r[3]<H*0.04) chip=r; else wp=r; } });
       if(chip&&wp&&chip[1]+chip[3]>wp[1]+1) bad.push('the HIDDEN chip (bottom '+Math.round(chip[1]+chip[3])+') runs into the weapon panel (top '+Math.round(wp[1])+')');
       if(!chip) bad.push('control: no crouch chip was drawn');
       texts.forEach(function(t){ if(/^EXTRACT /.test(t[0])||/^\d+:\d\d$/.test(t[0])) compY=Math.max(compY,t[1]); if(e&&t[0]===String(e.name)) bossY=t[1]; });
       if(e&&bossY!==null&&bossY<compY+4) bad.push('the boss name (y '+Math.round(bossY)+') prints into the clock and compass (down to '+Math.round(compY)+')');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; keys={}; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} try{ var g2=__state(); if(g2){ g2.pCrouch=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
