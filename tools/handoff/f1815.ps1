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

if ($s.Contains("  {v:'18.15',what:")) { throw "check 18.15 is in the fixture already" }

SubRx @'
  {v:'18.14',what:
'@ @'
  {v:'18.15',what:'the walls bake their weathering: with the sprites warm, one raid frame at the spawn issues under 1,500 fillRect calls (it issued about 3,650), the sprite store holds the walls on screen and does not grow on the next frame, and it never passes its cap',
   run:function(){
     if(typeof wallSprite!=='function'||typeof WALLSPR==='undefined') return 'the walls are repainted every frame';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], P2=CanvasRenderingContext2D.prototype, real=P2.fillRect, n=0, n1, n2, g, k0, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.legendOn=1;
       for(i=0;i<4;i++) __frame(0.016);
       k0=WALLSPR.n;
       if(!(k0>0)) bad.push('no wall sprite was baked ('+k0+')');
       if(k0>WALLSPR.max) bad.push('the sprite store holds '+k0+', over its cap of '+WALLSPR.max);
       P2.fillRect=function(){ n++; return real.apply(this,arguments); };
       __frame(0.016); n1=n; n=0; __frame(0.016); n2=n;
       P2.fillRect=real;
       if(!(n1<1500&&n2<1500)) bad.push('a warm frame still issues '+n1+' and '+n2+' fillRect calls');
       if(WALLSPR.n!==k0) bad.push('the sprite store grew from '+k0+' to '+WALLSPR.n+' standing still');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P2.fillRect=real; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
