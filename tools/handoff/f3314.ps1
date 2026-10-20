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

if ($s.Contains("  {v:'33.14',what:")) { throw "check 33.14 is in the fixture already" }

SubRx @'
  {v:'33.13',what:
'@ @'
  {v:'33.14',what:'cw-raiddollar, his rule (Q59: $ for money): in a career raid the corner rows read $ on money, stash and backpack with no credits word, and the Undercroft line reads stash $ and bag $',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof trColDraw!=='function'||typeof syncTopRight!=='function'||typeof trDemo!=='function') return 'SKIP: no corner rows here';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], el=document.getElementById('topright'), proto=CanvasRenderingContext2D.prototype, oFt=proto.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), f0=ctx.fillText;
     var sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, p, g, t, r=[], n, keepC, keepX, a, L=[], R=[];
     if(!el) return 'SKIP: no corner readout';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       p=__P(); keepC=p.credits; keepX=p.xp; p.credits=4321; p.xp=77;
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       _trLast=''; syncTopRight(); t=String(el.textContent||'').replace(/\s+/g,' ');
       if(!/STASH \$[0-9]/.test(t)) bad.push('the Undercroft line does not read STASH $ ("'+t+'")');
       if(!/BAG \$[0-9]/.test(t)) bad.push('the Undercroft line does not read BAG $ ("'+t+'")');
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(trDemo()) return 'SKIP: this raid counts as the demo';
       p=__P(); p.credits=4321; p.xp=77; g.tel.notes=[];
       _trLast=''; syncTopRight(); __frame(0.016);
       if(own) delete ctx.fillText;
       proto.fillText=function(s){ if(this===ctx) r.push({s:String(s),al:this.textAlign}); return oFt.apply(this,arguments); };
       try{ n=trColDraw(); } finally { proto.fillText=oFt; if(own) ctx.fillText=f0; }
       if(!(n>=4)) return 'SKIP: the corner drew '+n+' rows here';
       for(a=0;a<r.length;a++){ if(r[a].al==='left') L.push(r[a].s); else if(r[a].al==='right') R.push(r[a].s); }
       for(a=0;a<L.length;a++) if(/credit/i.test(L[a])) bad.push('a corner row is still labelled "'+L[a]+'"');
       if(R[0]!=='$'+(4321).toLocaleString()) bad.push('the money row reads "'+R[0]+'", not $'+(4321).toLocaleString());
       if(R[1]!==(77).toLocaleString()) bad.push('the xp row reads "'+R[1]+'", not a plain '+(77).toLocaleString());
       if(!/^\$[0-9]/.test(R[2]||'')) bad.push('the stash row reads "'+R[2]+'" with no $');
       if(!/^\$[0-9]/.test(R[3]||'')) bad.push('the backpack row reads "'+R[3]+'" with no $');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       proto.fillText=oFt; if(own) ctx.fillText=f0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       try{ var pf=__P(); pf.credits=keepC; pf.xp=keepX; }catch(_r){}
       _trLast=''; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
