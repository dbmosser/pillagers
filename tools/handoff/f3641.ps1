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

if ($s.Contains("  {v:'36.41',what:")) { throw "check 36.41 is in the fixture already" }

SubRx @'
  {v:'36.40',what:
'@ @'
  {v:'36.41',what:'fixed HUD panels fade to 35 percent over your pillager and recover clear of the hysteresis margin',
   run:function(){
     if(typeof hudFadeFrame!=='function'||typeof HUDFADE!=='object') return 'no HUD panel obstruction fade';
     var g,base,oldNow=hudFadeNow,now=1000,oldImage,images=[],score,far,p,x,y,i,e,oldTv=CFG.hudTv,oldAlpha;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'no raid to stage';
       g.career=true; g.arcade=false; g.bagOpen=false; g.mapOpen=false; g.paused=false;
       keys={}; mouse.down=false; g.player.iv=9999;
       __frame(0.016); base=ctx; oldImage=base.drawImage; oldAlpha=base.globalAlpha;
       hudFadeNow=function(){return now;};
       HUDFADE.g=null; drawHUD(); score={x:SCOREBOX.x,y:SCOREBOX.y,w:SCOREBOX.w,h:SCOREBOX.h};
       if(!(score.w>0&&score.h>0)) return 'score plate was not drawn';
       base.drawImage=function(){var a=HUDFADE.active; if(a&&a.key==='score') images.push(this.globalAlpha); return oldImage.apply(this,arguments);};
       p=g.player; x=p.x; y=p.y;
       p.x=VX+(score.x+score.w/2)/ZOOM(); p.y=VY+(score.y+score.h/2+16*hudRes())/ZOOM();
       for(i=0;i<12;i++){now+=0.016;drawHUD();}
       if(!HUDFADE.panels.score||HUDFADE.panels.score.a!==0.35) return 'score opacity did not reach 0.35 within 0.192 seconds';
       if(!images.length||Math.abs(images[images.length-1]-0.35)>0.00001) return 'score was not composited at 35 percent';
       far=HUDFADE.panels.gun;
       if(!far||far.a!==1||!far.box) return 'a far away gun panel faded';
       // A DOM panel uses the same projected body, elapsed time and margins as the canvas panels.
       e=document.createElement('div'); e.setAttribute('data-hud-panel','fade-check');
       e.style.cssText='position:fixed;left:'+score.x+'px;top:'+score.y+'px;width:'+score.w+'px;height:'+score.h+'px;opacity:1;pointer-events:none';
       document.getElementById('root').appendChild(e); HUDFADE.scan=0;
       for(i=0;i<12;i++){now+=0.016;drawHUD();}
       if(Math.abs(+e.style.opacity-0.35)>0.00001) return 'DOM panel did not reach 35 percent';
       p.x=VX+(score.x+score.w+100*hudRes())/ZOOM();
       for(i=0;i<12;i++){now+=0.016;drawHUD();}
       if(HUDFADE.panels.score.a!==1||+e.style.opacity!==1) return 'canvas or DOM panel did not recover 100 pixels clear';
       if(HUDFADE.panels.gun.a!==1) return 'far away panel changed opacity';
       // At twice the HUD scale, the 48px entry and 64px exit margins keep an edge from flickering.
       var s={a:1,near:false,at:0},b={x:100,y:100,w:100,h:100};
       hudFadeStep(s,b,[{x:247,y:120,w:10,h:10}],2,0.2); if(s.a!==0.35) return 'scaled entry margin missing';
       hudFadeStep(s,b,[{x:260,y:120,w:10,h:10}],2,0.4); if(s.a!==0.35) return 'exit hysteresis flickers';
       hudFadeStep(s,b,[{x:265,y:120,w:10,h:10}],2,0.6); if(s.a!==1) return 'scaled exit margin stuck';
       p.x=x;p.y=y;g.mapOpen=true;drawHUD();
       if(+e.style.opacity!==1) return 'DOM opacity leaked into a menu';
       return null;
     } finally {
       hudFadeNow=oldNow;CFG.hudTv=oldTv;
       if(base&&oldImage){base.drawImage=oldImage;ctx=base;base.globalAlpha=oldAlpha;}
       try{hudFadeDomReset();HUDFADE.active=null;}catch(_hf){}
       if(e&&e.parentNode)e.parentNode.removeChild(e);
       try{__endRaid('abandon');}catch(_end){}
       __topClear();
     }
   }},
  {v:'36.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
