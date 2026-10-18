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

if ($s.Contains("  {v:'31.03',what:")) { throw "check 31.03 is in the fixture already" }

SubRx @'
  {v:'31.02',what:
'@ @'
  {v:'31.03',what:'the HUD panel is a flat fill (no gradient wash) and the demo gun card is 60 high or less, no empty strip above the name (the critic, 10-19)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof hudPanel!=='function') return 'SKIP: this fixture cannot deploy';
     var g=null, oP=hudPanel, rec=[], a0, keep=ctx, oc=document.createElement('canvas'), c2, ng=0, og, i, dc=null;
     try{
       oc.width=240; oc.height=140; c2=oc.getContext('2d'); og=c2.createLinearGradient;
       c2.createLinearGradient=function(){ ng++; return og.apply(c2,arguments); };
       try{ ctx=c2; hudPanel(20,20,200,100); } finally { ctx=keep; }
       if(ng>0) return 'the HUD panel still paints a gradient ('+ng+')';
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; a0=g.arcade; g.arcade=1;
       hudPanel=function(x,y,w,h,a,plain){ rec.push({w:w,h:h,a:a}); return oP.apply(this,arguments); };
       try{ __frame(0.016); }finally{ hudPanel=oP; }
       for(i=0;i<rec.length;i++) if(rec[i].a===0.62) dc=rec[i];
       if(!dc) return 'the demo gun card is not drawn';
       if(dc.h>LH(60)+0.5) return 'the demo gun card is '+dc.h+' high, over '+LH(60);
       return null;
     } finally {
       ctx=keep; hudPanel=oP;
       try{ if(g) g.arcade=a0; }catch(_e){}
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'31.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
