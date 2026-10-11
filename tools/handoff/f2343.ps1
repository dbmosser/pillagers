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

if ($s.Contains("  {v:'23.43',what:")) { throw "check 23.43 is in the fixture already" }

SubRx @'
  {v:'23.42',what:
'@ @'
  {v:'23.43',what:'arcade20, his order 2026-10-11: Halloween dressing, an arcade raid burns orange lamps and has pumpkins by lamps and doors and a violet haze, all from the cosmetic stream (the raid stream RNGS never moves), and a normal raid has no pumpkins and its lamps unchanged',
   run:function(){
     var bad=[], g=null, g2=null, i, j, L, q, ok, r0, f0, iv, pumps0=null, pe=null, pf=null, nP=0, nH=0, tr, snap, near, D, ownE=false, ownF=false;
     function inSet(c){ return ARCADE_HALLOW.lamps.indexOf(c)>=0; }
     function stub(){
       pe=CanvasRenderingContext2D.prototype.ellipse; pf=CanvasRenderingContext2D.prototype.fillRect;
       wc.ellipse=function(){ if(String(this.fillStyle).toLowerCase()==='#c4561a') nP++; return pe.apply(this,arguments); }; ownE=true;
       wc.fillRect=function(){ if(String(this.fillStyle).replace(/\s/g,'').indexOf('rgba(70,30,110')===0) nH++; return pf.apply(this,arguments); }; ownF=true;
     }
     function unstub(){ if(ownE){ try{ delete wc.ellipse; }catch(_d1){} ownE=false; } if(ownF){ try{ delete wc.fillRect; }catch(_d2){} ownF=false; } }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeHallow!=='function'||typeof ARCADE_HALLOW!=='object') return 'no arcadeHallow in this build';
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!wc||Object.prototype.hasOwnProperty.call(wc,'ellipse')||Object.prototype.hasOwnProperty.call(wc,'fillRect')) return 'SKIP: the world canvas is missing or already stubbed';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!g||!g.arcade) return 'SKIP: no arcade raid';
       if(!g.lights||!g.lights.length) return 'SKIP: the arcade raid has no lamps';
       if(!g.arcPumps||!g.arcPumps.length) bad.push('the arcade drop put no pumpkins out (arcadePostBuild did not dress it)');
       for(i=0;i<g.lights.length;i++){ L=g.lights[i]; if(!inSet(L.c)){ bad.push('lamp '+i+' is '+L.c+', not orange'); break; } if(!(L.i>=L.i0-1e-9&&L.i<=ARCADE_HALLOW.lampMax+1e-9)){ bad.push('lamp '+i+' intensity '+L.i+' from '+L.i0); break; } }
       iv=g.lights.map(function(x){ return x.i; });
       r0=RNGS; f0=FXS;
       ok=arcadeHallow(g);
       if(ok!==true) bad.push('arcadeHallow on the arcade raid returned '+ok);
       if(RNGS!==r0) bad.push('arcadeHallow moved the raid stream RNGS');
       if(FXS===f0) bad.push('arcadeHallow did not draw from the cosmetic stream');
       for(i=0;i<g.lights.length;i++){ if(!inSet(g.lights[i].c)){ bad.push('after a redress lamp '+i+' is '+g.lights[i].c); break; } if(Math.abs(g.lights[i].i-iv[i])>1e-9){ bad.push('a redress compounded lamp '+i+' intensity'); break; } }
       if(!g.arcPumps||!g.arcPumps.length) bad.push('a redress put no pumpkins out');
       else {
         if(g.arcPumps.length>ARCADE_HALLOW.pumps) bad.push(g.arcPumps.length+' pumpkins, over the cap');
         for(i=0;i<g.arcPumps.length;i++){
           q=g.arcPumps[i];
           if(!spotFree(g.map,q.x,q.y,9)){ bad.push('pumpkin '+i+' sits in a wall'); break; }
           near=false;
           for(j=0;j<g.lights.length&&!near;j++) if(Math.hypot(g.lights[j].x-q.x,g.lights[j].y-q.y)<=44) near=true;
           for(j=0;j<(g.map.doors||[]).length&&!near;j++){ D=g.map.doors[j]; if(Math.hypot(D.x+D.w/2-q.x,D.y+D.h/2-q.y)<=44) near=true; }
           if(!near){ bad.push('pumpkin '+i+' is not by a lamp or a door'); break; }
         }
       }
       pumps0=g.arcPumps;
       g.arcPumps=[{x:g.player.x+40,y:g.player.y,s:1,f:0,lit:1}];
       stub(); nP=0; nH=0;
       __loop(performance.now()+1000); __loop(performance.now()+1050);
       unstub();
       g.arcPumps=pumps0; pumps0=null;
       if(!(nP>0)) bad.push('no pumpkin drawn beside the player');
       if(!(nH>0)) bad.push('no violet haze drawn');
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       if(g2.arcPumps!==undefined) bad.push('a normal raid has arcPumps');
       for(i=0;i<(g2.lights||[]).length;i++){ if(inSet(g2.lights[i].c)||g2.lights[i].i0!==undefined){ bad.push('a normal raid lamp is dressed'); break; } }
       snap=JSON.stringify(g2.lights||[]); r0=RNGS;
       if(arcadeHallow(g2)!==false) bad.push('arcadeHallow dressed a normal raid');
       if(JSON.stringify(g2.lights||[])!==snap||g2.arcPumps!==undefined||RNGS!==r0) bad.push('arcadeHallow changed a normal raid');
       stub(); nP=0; nH=0;
       __loop(performance.now()+20000);
       unstub();
       if(nP>0||nH>0) bad.push('a normal raid draws pumpkins or the haze');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       unstub();
       try{ if(g&&pumps0) g.arcPumps=pumps0; }catch(_pp){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
