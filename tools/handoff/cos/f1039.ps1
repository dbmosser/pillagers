$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.38',what:'the full controls list is centred, on the screen and clear of the conditions panel at 1080p, 1440p and 4K',
'@ @'
  {v:'10.39',what:'the Spartan helmet and the ghost mask are on the headgear rack, drawn on the sprite, covering the face',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
     if(typeof COSMETICS==='undefined'||typeof cosSwatch!=='function') return 'SKIP: no racks in this build';
     var want=['spartan','ghostmask'], have=want.filter(function(id){ return !!cosFind(id)&&cosFind(id).kind==='hat'; });
     // THE FINDING. On v10.38 neither was on the racks.
     if(have.length<2) return 'the headgear rack is missing '+want.filter(function(id){ return have.indexOf(id)<0; }).join(', ');
     want.forEach(function(id){ var c=cosFind(id); if(String(c.how).indexOf('buy:')===0||c.how==='always') bad.push(id+' is not earned'); });
     __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); if(!g) return 'SKIP: no raid';
     var p=g.player; g.ents.length=0; p.hp=100000; p.maxhp=100000;
     var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,xpLevel:P2.xpLevel,cosHat:P2.cosHat,cosBeard:P2.cosBeard,cosFace:P2.cosFace};
     P2.runs=999; P2.ext=999; P2.kills={warden:9}; P2.xpLevel=99;
     var cvs=(window.__canvases&&__canvases().world)||document.getElementById('cv'), wctx=cvs.getContext('2d');
     function head(){ for(var f=0;f<3;f++) __frame(0.016); var sx=Math.round(p.x-(g.camX||0)), sy=Math.round(p.y-(g.camY||0)); sx=Math.max(40,Math.min(cvs.width-40,sx)); sy=Math.max(90,Math.min(cvs.height-20,sy)); return wctx.getImageData(sx-40,sy-90,80,110).data; }
     function diff(a,b){ var d=0; for(var i=0;i<a.length;i+=4) if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])>40) d++; return d; }
     function greenish(px){ var n=0; for(var i=0;i<px.length;i+=4) if(px[i+3]>40&&px[i+1]>px[i]+20&&px[i+1]>px[i+2]+20) n++; return n; }
     // The raid is lit dark, so white never reads above 215 on the canvas; pale is
     // measured as bright and unsaturated, against the bare head.
     function pale(px){ var n=0; for(var i=0;i<px.length;i+=4){ if(px[i+3]<40) continue; var r=px[i],gg=px[i+1],b=px[i+2],L=(r+gg+b)/3,sat=Math.max(r,gg,b)-Math.min(r,gg,b); if(sat<28&&L>150) n++; } return n; }
     P2.cosHat='none'; P2.cosBeard='clean'; P2.cosFace='faceplain'; var bare=head();
     P2.cosHat='spartan'; var sp=head();
     if(diff(sp,bare)<40) bad.push('the Spartan helmet draws almost nothing ('+diff(sp,bare)+' px)');
     if(greenish(sp)-greenish(bare)<25) bad.push('the Spartan helmet is not green on the sprite');
     P2.cosHat='ghostmask'; var gm=head();
     if(diff(gm,bare)<40) bad.push('the ghost mask draws almost nothing ('+diff(gm,bare)+' px)');
     if(pale(gm)-pale(bare)<25) bad.push('the ghost mask is not white on the sprite');
     // Both cover the face: a full beard under either must not show.
     P2.cosBeard='fullbeard'; var gmB=head();
     if(diff(gm,gmB)>8) bad.push('a beard shows through the ghost mask ('+diff(gm,gmB)+' px)');
     P2.cosHat='spartan'; var spB=head();
     if(diff(sp,spB)>8) bad.push('a beard shows through the Spartan helmet ('+diff(sp,spB)+' px)');
     // Swatches and the figure glyph exist. (Everything stays earned until the end:
     // cosWorn falls back to Bare for a locked hat, and the first draft restored the
     // counters here and then blamed the figure.)
     want.forEach(function(id){ if(/>\?</.test(cosSwatch(cosFind(id)))) bad.push(id+' has no swatch'); });
     P2.cosHat='ghostmask'; var html=(typeof avatarHTML==='function')?avatarHTML():'';
     if(html.indexOf('avhat')<0) bad.push('the figure does not draw the ghost mask');
     // CONTROL: the older headgear still draws.
     P2.cosBeard='clean'; P2.cosHat='visor'; var vs=head();
     if(diff(vs,bare)<6) bad.push('control: the visor no longer draws');
     for(var k in keep) P2[k]=keep[k];
     return bad.length?bad.join('; '):null; }},
  {v:'10.38',what:'the full controls list is centred, on the screen and clear of the conditions panel at 1080p, 1440p and 4K',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
