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

if ($s.Contains("  {v:'30.62',what:")) { throw "check 30.62 is in the fixture already" }

SubRx @'
  {v:'30.61',what:
'@ @'
  {v:'30.62',what:'the raid HUD panels draw no resize hatch until the pointer is over them (style guide: no clutter)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oS=ctx.stroke, n=0, mx0, my0, k, B=null, kk;
     function count(){ n=0; ctx.stroke=function(){ if(ctx.strokeStyle==='rgba(140, 152, 163, 0.45)') n++; return oS.apply(this,arguments); }; try{ __frame(0.016); }finally{ ctx.stroke=oS; } return n; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; mx0=mouse.x; my0=mouse.y;
       __frame(0.016);
       for(kk in HUDZ){ if(HUDBOX[kk]&&!hudOff(kk).c&&HUDBOX[kk].w>40&&HUDBOX[kk].h>40){ k=kk; B=HUDBOX[kk]; break; } }
       if(!B) return 'SKIP: no resizable panel on screen';
       mouse.x=-50; mouse.y=-50;
       if(count()>0) return 'the resize hatch is drawn on a panel with the pointer far away ('+n+' strokes)';
       mouse.x=B.x+B.w/2; mouse.y=B.y+B.h/2;
       if(count()===0) return 'the resize hatch does not show with the pointer over the '+k+' panel';
       return null;
     } finally {
       ctx.stroke=oS; try{ mouse.x=mx0; mouse.y=my0; }catch(_m){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
