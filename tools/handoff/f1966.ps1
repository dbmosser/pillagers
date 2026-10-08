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

if ($s.Contains("  {v:'19.66',what:")) { throw "check 19.66 is in the fixture already" }

SubRx @'
  {v:'19.65',what:
'@ @'
  {v:'19.66',what:'the belt hint grows at 4K and stays clear: the line over the belt is about twice its 1080p size at 4K, and below the HOLD E line in a ring',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, p, z, oFT=ctx.fillText, cap=null, hold=null, s1, s4, d=(typeof DPR==='number'&&DPR>0)?DPR:1;
     function grab(inRing){ var k; for(k=0;k<8;k++){ cap=null; hold=null; if(inRing){ p.x=z.x; p.y=z.y; g.active=z; g.beaconT=null; } __frame(0.05); } return {cap:cap,hold:hold}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:['gun_smg'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: no ring';
       ctx.fillText=function(t,x,y){ var s=String(t), m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)), px=(fm?parseFloat(fm[1]):0)*m.d/d, sy=(m.d*y+m.f)/d; if(s.indexOf('[FIRE] use')>=0&&!cap) cap={px:px,y:sy}; if(/^HOLD .* TO CALL FOR EXTRACTION$/.test(s)&&!hold) hold={px:px,y:sy}; return oFT.apply(this,arguments); };
       s1=grab(false);
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       s4=grab(true);
       if(!s1.cap||!s4.cap) return 'SKIP: the belt hint was not drawn';
       if(s4.cap.px<s1.cap.px*1.8) bad.push('at 4K the belt hint is '+s4.cap.px.toFixed(1)+' px against '+s1.cap.px.toFixed(1)+' px at 1080p');
       if(s4.hold&&s4.hold.y+s4.hold.px*0.22>s4.cap.y-s4.cap.px*0.95) bad.push('at 4K the HOLD E line runs into the belt hint');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
