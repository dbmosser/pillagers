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

if ($s.Contains("  {v:'23.68',what:")) { throw "check 23.68 is in the fixture already" }

SubRx @'
  {v:'23.67',what:
'@ @'
  {v:'23.68',what:'his answer 22 (2026-10-12), no Halloween dressing: the dressing code is gone, an arcade raid at seed 4242 puts out no pumpkins, burns no lamp in the dressing orange and redresses none, draws no pumpkin and no violet haze, and the arcade attract says nothing about Halloween',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__loop)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof arcadeEnter!=='function'||typeof arcadeLeave!=='function'||typeof arcadeAttStart!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, base=null, i, pe=null, pf=null, nP=0, nH=0, ownE=false, ownF=false, HW=['HALLO','WEEN'].join(''), d, bo, src0, tried0, svA=false;
     function stub(){
       pe=CanvasRenderingContext2D.prototype.ellipse; pf=CanvasRenderingContext2D.prototype.fillRect;
       wc.ellipse=function(){ if(String(this.fillStyle).toLowerCase()==='#c4561a') nP++; return pe.apply(this,arguments); }; ownE=true;
       wc.fillRect=function(){ if(String(this.fillStyle).replace(/\s/g,'').indexOf('rgba(70,30,110')===0) nH++; return pf.apply(this,arguments); }; ownF=true;
     }
     function unstub(){ if(ownE){ try{ delete wc.ellipse; }catch(_d1){} ownE=false; } if(ownF){ try{ delete wc.fillRect; }catch(_d2){} ownF=false; } }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!wc||Object.prototype.hasOwnProperty.call(wc,'ellipse')||Object.prototype.hasOwnProperty.call(wc,'fillRect')) return 'SKIP: the world canvas is missing or already stubbed';
       if(typeof arcadeHallow==='function'||typeof ARCADE_HALLOW!=='undefined'||typeof arcadePumpDraw==='function'||typeof arcadeHazeDraw==='function') bad.push('the Halloween dressing code is still in the build');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.lights||!g.lights.length) return bad.length?bad.join('; '):'SKIP: staging: no lamps in a normal raid';
       base=g.lights.map(function(x){ return String(x.c); });
       __endRaid('abandon'); __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.length?bad.join('; '):'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return bad.length?bad.join('; '):'SKIP: no arcade raid';
       if(g.arcPumps!==undefined) bad.push('the arcade raid put pumpkins out ('+(g.arcPumps&&g.arcPumps.length)+')');
       var ORG=['#ff7a1a','#ff8a2e','#ff9a3c','#ffae55'], nO=0;
       if(!g.lights||!g.lights.length) bad.push('the arcade raid has no lamps');
       for(i=0;i<(g.lights||[]).length;i++){
         if(g.lights[i].i0!==undefined){ bad.push('arcade lamp '+i+' was redressed (i0 set)'); break; }
         if(ORG.indexOf(String(g.lights[i].c).toLowerCase())>=0) nO++;
       }
       if(nO>0) bad.push(nO+' of '+g.lights.length+' arcade lamps burn the dressing orange');
       for(i=0;i<base.length;i++) if(ORG.indexOf(base[i].toLowerCase())>=0){ bad.push('control: a normal raid lamp burns the dressing orange, so the colour test cannot tell'); break; }
       stub(); nP=0; nH=0;
       __loop(performance.now()+1000); __loop(performance.now()+1050);
       unstub();
       if(nP>0) bad.push('the arcade raid drew '+nP+' pumpkins');
       if(nH>0) bad.push('the arcade raid drew the violet haze');
       arcadeLeave();
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; svA=true;
       if(!arcadeEnter('host')||!ARCADE.on) return bad.length?bad.join('; '):'SKIP: arcadeEnter did not turn the arcade on';
       arcadeAttStart();
       d=attEl();
       if(!d||d.style.display!=='block') return bad.length?bad.join('; '):'SKIP: the arcade attract is not up';
       if(String(d.textContent||'').toUpperCase().indexOf(HW)>=0) bad.push('the arcade attract still says '+HW);
       bo=d.querySelector('.arcboo');
       if(bo&&bo.style.display!=='none') bad.push('the Halloween banner element is still shown on the attract');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       unstub();
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; } }catch(_m){}
       try{ if(svA){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
