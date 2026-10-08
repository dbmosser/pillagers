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

if ($s.Contains("  {v:'19.22',what:")) { throw "check 19.22 is in the fixture already" }

SubRx @'
  {v:'19.21',what:
'@ @'
  {v:'19.22',what:'the raid labels grow at 4K: the cover chip and an extraction ring label are drawn about twice their 1080p size on a 4K screen, with their backing still behind them',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, p, z=null, oFT=ctx.fillText, rec=[], s1, s4, i;
     function grab(){ rec.length=0; g.pCrouch=true; p.x=z.x+150; p.y=z.y; g.anchX=p.x; g.anchY=p.y; __frame(0.001); __frame(0.001); var c=null, r=null; for(var k=0;k<rec.length;k++){ if(!c&&/(HIDDEN|CONCEALED|CRASHING)/.test(rec[k].t)) c=rec[k]; if(!r&&/^EXTRACTION POINT/.test(rec[k].t)) r=rec[k]; } return {c:c,r:r}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       z=g.zones&&g.zones[0];
       if(!z) return 'SKIP: no ring to label';
       ctx.fillText=function(t,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, fm=(/([\d.]+)px/).exec(String(ctx.font)); rec.push({t:String(t),px:(fm?parseFloat(fm[1]):0)*m.d/d}); return oFT.apply(this,arguments); };
       s1=grab();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       s4=grab();
       if(!s1.c||!s4.c) return 'SKIP: the cover chip was not drawn';
       if(s4.c.px<s1.c.px*1.7) bad.push('at 4K the cover chip is '+s4.c.px.toFixed(1)+' px against '+s1.c.px.toFixed(1)+' px at 1080p');
       if(s1.r&&s4.r){ if(s4.r.px<s1.r.px*1.7) bad.push('at 4K the ring label is '+s4.r.px.toFixed(1)+' px against '+s1.r.px.toFixed(1)+' px at 1080p'); }
       else bad.push('control: the ring label was not drawn ('+(!!s1.r)+'/'+(!!s4.r)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.pCrouch=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
