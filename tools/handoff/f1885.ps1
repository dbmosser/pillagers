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

if ($s.Contains("  {v:'18.85',what:")) { throw "check 18.85 is in the fixture already" }

SubRx @'
  {v:'18.84',what:
'@ @'
  {v:'18.85',what:'the backpack text grows with the backpack: at 4K the BACKPACK title is drawn at least 1.6 times its 1080p size, as the panel is, and at 1080p it is unchanged',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     var bad=[], g, oFT=ctx.fillText, px1=null, px4=null, w1=0, w4=0;
     function grab(){ var px=null; ctx.fillText=function(s){ if(String(s)==='BACKPACK'){ var m=(/([\d.]+)px/).exec(String(ctx.font)); if(m) px=parseFloat(m[1]); } return oFT.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return px; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(1920,1080);
       __deploy({kit:['bandage','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); g.mapOpen=false; g.bagOpen=true;
       __frame(0.016); px1=grab(); w1=g.bagPanel?g.bagPanel.w:0;
       __forceSize(3840,2160); __frame(0.016); px4=grab(); w4=g.bagPanel?g.bagPanel.w:0;
       if(px1===null||px4===null) return 'SKIP: the backpack title was not drawn';
       if(!(w4>w1*1.5)) return 'SKIP: the panel did not grow at 4K here';
       if(px4<px1*1.6) bad.push('at 4K the title is '+px4+'px against '+px1+'px at 1080p while the panel grew '+(w4/w1).toFixed(2)+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} try{ var g2=__state(); if(g2){ g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
