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

if ($s.Contains("  {v:'28.59',what:")) { throw "check 28.59 is in the fixture already" }

SubRx @'
  {v:'28.58',what:
'@ @'
  {v:'28.59',what:'cloud-raid-goldlabel: the GOLDEN label over the golden enemy does not print on top of its nameplate at 1080p',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__loop&&window.__textTrace)) return 'SKIP: no raid or text trace here';
     if(typeof arcadeDeploy!=='function'||typeof goldS!=='function') return 'SKIP: no arcade or golden enemy in this fixture';
     var g=null, p=null, e=null, i, ts, tr, gb=null, nb=null, mb=null, ix, iy, oIv, bad=[];
     function hold(){ e.x=p.x+180; e.y=p.y-40; e.vx=0; e.vy=0; e.state='idle'; e.alert=0; }
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; oIv=p.iv; ts=performance.now();
       for(i=0;i<300;i++){ p.iv=999; ts+=16.7; __loop(ts); }
       e=g.flow&&g.flow.gold&&g.flow.gold.ref;
       if(!e||!(e.hp>0)||!e.name) return 'SKIP: staging: no golden enemy with a name in this raid';
       for(i=0;i<20;i++){ p.iv=999; hold(); ts+=16.7; __loop(ts); }
       hold();
       tr=__textTrace(function(){ ts+=16.7; __loop(ts); });
       tr.forEach(function(o){ var x0=o.align==='center'?o.x-o.w/2:o.x, b={x:x0,y:o.y-o.px*0.8,w:o.w,h:o.px}; if(o.t==='GOLDEN') gb=b; else if(o.t.indexOf(e.name)===0) nb=b; });
       if(!gb||!nb) return 'SKIP: staging: the label or the nameplate was not drawn ('+(!!gb)+','+(!!nb)+')';
       ix=Math.min(gb.x+gb.w,nb.x+nb.w)-Math.max(gb.x,nb.x); iy=Math.min(gb.y+gb.h,nb.y+nb.h)-Math.max(gb.y,nb.y);
       if(ix>0&&iy>0) return 'GOLDEN overlaps the '+e.name+' nameplate by '+Math.round(ix)+'x'+Math.round(iy)+' px (GOLDEN y '+Math.round(gb.y)+', plate y '+Math.round(nb.y)+')';
       // and when it hunts, the ! or ? mark sits on the plate: GOLDEN stays clear of it too
       gb=null; nb=null; mb=null;
       tr=__textTrace(function(){ hold(); e.state='chase'; e.alert=3; ts+=16.7; __loop(ts); });
       tr.forEach(function(o){ var x0=o.align==='center'?o.x-o.w/2:o.x, b={x:x0,y:o.y-o.px*0.8,w:o.w,h:o.px}; if(o.t==='GOLDEN') gb=b; else if(o.t.indexOf(e.name)===0) nb=b; else if(o.t==='!'||o.t==='?') mb=b; });
       [nb,mb].forEach(function(q,qi){ if(!gb||!q) return; var jx=Math.min(gb.x+gb.w,q.x+q.w)-Math.max(gb.x,q.x), jy=Math.min(gb.y+gb.h,q.y+q.h)-Math.max(gb.y,q.y); if(jx>0&&jy>0) bad.push('while it hunts GOLDEN overlaps the '+(qi?'alert mark':'nameplate')+' by '+Math.round(jx)+'x'+Math.round(jy)+' px'); });
       return bad.length?bad.join('; '):null;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(p) p.iv=oIv; try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'28.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
