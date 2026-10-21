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

if ($s.Contains("  {v:'33.38',what:")) { throw "check 33.38 is in the fixture already" }

SubRx @'
  {v:'33.37',what:
'@ @'
  {v:'33.38',what:'cw-cornercompact, his order: the raid corner money block is one short plate (at most 40 percent of the four-row height) at 1080 and 4K, all four figures drawn, the minimap one gap under it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof trColDraw!=='function'||typeof trGeo!=='function'||typeof trDemo!=='function') return 'SKIP: no corner rows here';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), f0=ctx.fillText;
     var sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, sizes=[[1920,1080],[3840,2160]], k, g, gg, oldH, r, n, a, R, mb, keepC, keepX, p;
     try{
       for(k=0;k<sizes.length;k++){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         p=__P(); keepC=p.credits; keepX=p.xp; p.credits=4321; p.xp=77;
         __forceSize(sizes[k][0],sizes[k][1]);
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
         if(trDemo()) return 'SKIP: this raid counts as the demo';
         p=__P(); p.credits=4321; p.xp=77; g.tel.notes=[];
         _trLast=''; syncTopRight(); __frame(0.016);
         gg=trGeo(); oldH=4*(16+LH(13))+3*gg.gp;
         if(!(gg.rh<=0.4*oldH)) bad.push(sizes[k][0]+': the block is '+gg.rh+' tall, over 40 percent of the old '+oldH);
         r=[]; if(own) delete ctx.fillText;
         proto.fillText=function(s){ if(this===ctx) r.push({s:String(s),al:this.textAlign}); return oFt.apply(this,arguments); };
         try{ n=trColDraw(); } finally { proto.fillText=oFt; if(own) ctx.fillText=f0; }
         if(!(n>=4)) bad.push(sizes[k][0]+': the corner drew '+n+' figures');
         R=[]; for(a=0;a<r.length;a++) if(r[a].al==='right') R.push(r[a].s);
         if(R[0]!=='$'+(4321).toLocaleString()||R[1]!==(77).toLocaleString()||!/^\$[0-9]/.test(R[2]||'')||!/^\$[0-9]/.test(R[3]||'')) bad.push(sizes[k][0]+': the four figures read '+R.slice(0,4).join(' | '));
         __frame(0.016); mb=MMAP.box;
         if(mb){ if(Math.abs(mb.y-Math.ceil((gg.y0+gg.rh+gg.gp)*gg.z))>1) bad.push(sizes[k][0]+': the minimap top '+mb.y+' is not one gap under the block'); }
         else bad.push(sizes[k][0]+': no minimap box to measure the gap');
         try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
         p=__P(); p.credits=keepC; p.xp=keepX;
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       proto.fillText=oFt; if(own) ctx.fillText=f0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       try{ var pf=__P(); pf.credits=keepC; pf.xp=keepX; }catch(_r){}
       _trLast=''; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
