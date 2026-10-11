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

if ($s.Contains("  {v:'22.92',what:")) { throw "check 22.92 is in the fixture already" }

SubRx @'
  {v:'22.91',what:
'@ @'
  {v:'22.92',what:'the reticle words grow at 4K: at 3840x2160 NO AMMO under the cross and the reload seconds beside it are drawn at least 1.9 times their 1080p font size',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace&&window.__forceSize)||typeof drawHUD!=='function'||typeof hudRes!=='function') return 'SKIP: no raid or HUD here';
     var bad=[], g=null, p=null, forced=false, mx0=mouse.x, my0=mouse.y, keep=null, a, b, k, DRY='NO '+'AMMO', loud=(CFG.cursorLoud!==0);
     function grab(w,h){
       var out={dry:0,sec:0}, tr, i, s;
       __forceSize(w,h); forced=true;
       mouse.x=Math.round(W*0.5); mouse.y=Math.round(H*0.4);
       g.bagOpen=false; g.mapOpen=false; p.downed=false;
       p.ammo=0; p.reserve=0; p.jam=0; p.reloading=0;
       tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} });
       for(i=0;i<tr.length;i++) if(tr[i].t===DRY&&!out.dry) out.dry=tr[i].px;
       p.reserve=30; p.reloading=1234;
       tr=__textTrace(function(){ try{ drawHUD(); }catch(_h2){} });
       for(i=0;i<tr.length;i++){ s=tr[i].t; if(s==='1.2s'&&!out.sec) out.sec=tr[i].px; }
       p.reloading=0;
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={};
       keep={wep:p.wep,ammo:p.ammo,reserve:p.reserve,jam:p.jam,reloading:p.reloading};
       if(!p.wep||!(p.wep.mag>0)){ for(k in WEAPONS) if(WEAPONS[k]&&WEAPONS[k].mag>0&&WEAPONS[k].reload){ p.wep=WEAPONS[k]; break; } }
       if(!p.wep||!(p.wep.mag>0)||!p.wep.reload) return 'SKIP: staging: no gun in hand';
       a=grab(1920,1080);
       b=grab(3840,2160);
       if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       if(!a.dry||!b.dry) return 'SKIP: staging: NO AMMO was not drawn under the cross';
       if(b.dry<a.dry*1.9) bad.push('at 4K NO AMMO is '+b.dry.toFixed(1)+' px against '+a.dry.toFixed(1)+' px at 1080p');
       if(loud){
         if(!a.sec||!b.sec) bad.push('control: the reload seconds were not drawn beside the cross');
         else if(b.sec<a.sec*1.9) bad.push('at 4K the reload seconds are '+b.sec.toFixed(1)+' px against '+a.sec.toFixed(1)+' px at 1080p');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       mouse.x=mx0; mouse.y=my0; keys={};
       try{ if(p&&keep){ p.wep=keep.wep; p.ammo=keep.ammo; p.reserve=keep.reserve; p.jam=keep.jam; p.reloading=keep.reloading; } }catch(_p){}
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
