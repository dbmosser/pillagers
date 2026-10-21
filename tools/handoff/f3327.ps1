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

if ($s.Contains("  {v:'33.27',what:")) { throw "check 33.27 is in the fixture already" }

SubRx @'
  {v:'33.26',what:
'@ @'
  {v:'33.27',what:'cw-pwrhalf, his order (2026-10-20) powerups need to be like 50 percent smaller: each of the five floating pickups draws its medallion at half the old radius while the ring at the pickup reach keeps its size',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pwrDraw!=='function'||typeof PWRI==='undefined') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, S, i, k, q, sp, proto, oArc, oOct, arcs, mr, ring, ks=['clip','dmg','rapid','shield','pulse'], want, got;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; g.pwr=null; S=pwrS(); render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oOct=styOct; q=ZOOM(); want=34*q*0.5;
       for(k=0;k<ks.length;k++){
         S.items.length=0; S.act={}; S.items.push({k:ks[k],x:p.x+120,y:p.y-30,t:3,life:16,id:5+k}); sp=w2s(S.items[0].x,0,S.items[0].y);
         arcs=[]; mr=0;
         proto.arc=function(){ arcs.push([arguments[0],arguments[1],arguments[2]]); return oArc.apply(this,arguments); };
         styOct=function(c2,r2,u2){ if(r2>mr) mr=r2; return oOct(c2,r2,u2); };
         try{ pwrDraw(ctx,p); } finally { proto.arc=oArc; styOct=oOct; }
         if(!(Math.abs(mr-want)<=want*0.05)) bad.push(ks[k]+': the medallion radius is '+mr.toFixed(2)+', not half the old '+(34*q).toFixed(2)+' ('+want.toFixed(2)+')');
         ring=0; for(i=0;i<arcs.length;i++) if(Math.abs(arcs[i][0]-sp.x)<1&&Math.abs(arcs[i][1]-sp.y)<1&&Math.abs(arcs[i][2]-PWR.pick*q)<1) ring++;
         if(!ring) bad.push(ks[k]+': the ring at the pickup reach ('+PWR.pick*q+') changed size');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oArc) proto.arc=oArc; if(oOct) styOct=oOct; }catch(_p){}
       keys={};
       try{ if(g){ g.pwr=null; } }catch(_gp){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'33.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
