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

if ($s.Contains("  {v:'36.93',what:")) { throw "check 36.93 is in the fixture already" }

SubRx @'
  {v:'36.92',what:
'@ @'
  {v:'36.93',what:'the medal row stays as wide as the feed and clear of the folded f1 controls chip at 1600x900, 1080p and 4k, career and the demo, with the big text setting too (cw-medalchip)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__forceSize||typeof arcadeDeploy!=='function'||typeof legChipSpot!=='function') return 'SKIP: no raid staging in this fixture';
     var bad=[], SZ=[[1600,900],[1920,1080],[3840,2160]], MD=['career','demo','career','demo'], si, mi, i, g, cs, M, F, sz, md, tg, tv;
     function hit(a,b){ return !!(a&&b&&a.w>0&&b.w>0&&a.h>0&&b.h>0&&a.x<b.x+b.w-0.5&&b.x<a.x+a.w-0.5&&a.y<b.y+b.h-0.5&&b.y<a.y+a.h-0.5); }
     function R(b){ return b?Math.round(b.x)+','+Math.round(b.y)+' '+Math.round(b.w)+'x'+Math.round(b.h):'none'; }
     function down(){ try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} try{ if(typeof ARCADE==='object'&&ARCADE){ ARCADE.over=null; ARCADE.ini=null; } }catch(_a){} try{ __topClear(); }catch(_t){} }
     down();
     try{
       for(si=0;si<SZ.length;si++) for(mi=0;mi<MD.length;mi++){
         sz=SZ[si]; md=MD[mi%2]; tv=(mi>=2)?1:0; tg=md+' '+sz[1]+(tv?' big text':'')+': ';
         down();
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); if(tv) P.uiScale=1.5;
         if(typeof PAD==='object'&&PAD) PAD.on=false;
         P.hud={}; _legBase=null; _legAnchorY=null;
         __forceSize(sz[0],sz[1]);
         if(md==='career'){ __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||g.over||!g.player){ bad.push(tg+'no raid'); continue; } g.career=1; g.arcade=0; }
         else { ARCADE.ini=null; ARCADE.over=null; if(!arcadeDeploy({mapIx:0,seed:4242})){ bad.push(tg+'no demo'); continue; } try{ attStop(); }catch(_as){} g=__state(); if(!g||g.over||!g.arcade||!g.player){ bad.push(tg+'no demo raid'); continue; } ARCADE.over=null; ARCADE.ini=null; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.role='host'; }
         g.legendAutoDone=true; g.legendOn=0; g.bagOpen=false; g.mapOpen=false; keys={};
         for(i=0;i<14;i++){ __frame(0.016); if(!__state()||__state().over) break; }
         cs=legChipSpot(); M=MEDALBOX; F=FEEDBOX;
         if(!cs){ bad.push(tg+'no folded chip spot'); continue; }
         if(!(M&&M.on&&M.w>0)){ bad.push(tg+'no medal spot'); continue; }
         if(hit(cs,M)) bad.push(tg+'the folded chip '+R(cs)+' is over the medal spot '+R(M));
         if(F&&F.on&&Math.abs(M.w-F.w)>0.5) bad.push(tg+'the medal row '+R(M)+' is not as wide as the feed '+R(F));
       }
     } finally { down(); delete P.uiScale; try{ __runPrep(); __topClear(); }catch(_c){} }
     return bad.length?bad.slice(0,4).join(' | '):null; }},
  {v:'36.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
