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

if ($s.Contains("  {v:'19.55',what:")) { throw "check 19.55 is in the fixture already" }

SubRx @'
  {v:'19.54',what:
'@ @'
  {v:'19.55',what:'the world prompts grow at 4K: standing on a ring, [E] CALL FOR EXTRACTION over it is drawn about twice its 1080p size on a 4K screen, and nothing is left scaled after',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, p, z, oFT=ctx.fillText, hit=null, s1, s4, d=(typeof DPR==='number'&&DPR>0)?DPR:1, m0, m1;
     function grab(){ var k; hit=null; p.x=z.x; p.y=z.y; g.beaconT=null; for(k=0;k<12;k++){ hit=null; __frame(0.05); } return hit; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: no ring';
       g.active=z;
       ctx.fillText=function(t,x,y){ if(/^\[[^\]]+\] CALL FOR EXTRACTION$/.test(String(t))&&!hit){ var m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)); hit={px:(fm?parseFloat(fm[1]):0)*m.d/d,ok:isFinite(x)&&isFinite(y)}; } return oFT.apply(this,arguments); };
       s1=grab();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       m0=ctx.getTransform();
       s4=grab();
       m1=ctx.getTransform();
       if(!s1||!s4) return 'SKIP: the ring prompt was not drawn'; if(!s1.ok||!s4.ok) return 'SKIP: the ring prompt has no place on screen in this staging';
       if(s4.px<s1.px*1.7) bad.push('at 4K [E] CALL FOR EXTRACTION is '+s4.px.toFixed(1)+' px against '+s1.px.toFixed(1)+' px at 1080p');
       if(Math.abs(m0.a-m1.a)>1e-6||Math.abs(m0.e-m1.e)>1e-6) bad.push('the frame left the canvas transform changed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
