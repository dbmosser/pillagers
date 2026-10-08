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

if ($s.Contains("  {v:'19.34',what:")) { throw "check 19.34 is in the fixture already" }

SubRx @'
  {v:'19.33',what:
'@ @'
  {v:'19.34',what:'the belt hint reads on any ground: the line over the belt ([FIRE] use) is drawn on a dark strip that covers its words',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, oFT=ctx.fillText, oFR=ctx.fillRect, rects=[], cap=null, d=(typeof DPR==='number'&&DPR>0)?DPR:1, i, r, cx, cy, ok=false;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_smg'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       ctx.fillRect=function(x,y,w,h){ var m=ctx.getTransform(), fs=String(ctx.fillStyle), a=(/rgba\(\s*(\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)/).exec(fs); if(a&&(+a[1]+(+a[2])+(+a[3]))<120&&+a[4]>=0.4) rects.push({l:(m.a*x+m.e)/d,t:(m.d*y+m.f)/d,r:(m.a*(x+w)+m.e)/d,b:(m.d*(y+h)+m.f)/d}); return oFR.apply(this,arguments); };
       ctx.fillText=function(t,x,y){ if(String(t).indexOf('[FIRE] use')>=0&&!cap){ var m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):11, w=ctx.measureText(String(t)).width; cap={x:(m.a*x+m.e)/d,y:(m.d*(y-fp*0.35)+m.f)/d,hw:(w/2)*m.a/d}; } return oFT.apply(this,arguments); };
       __frame(0.001);
       if(!cap) return 'SKIP: the belt hint was not drawn';
       for(i=0;i<rects.length;i++){ r=rects[i]; if(r.l<=cap.x-cap.hw*0.9&&r.r>=cap.x+cap.hw*0.9&&r.t<=cap.y&&r.b>=cap.y){ ok=true; break; } }
       if(!ok) bad.push('the belt hint has no dark strip behind its words');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; delete ctx.fillRect; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
