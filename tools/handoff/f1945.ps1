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

if ($s.Contains("  {v:'19.45',what:")) { throw "check 19.45 is in the fixture already" }

SubRx @'
  {v:'19.44',what:
'@ @'
  {v:'19.45',what:'his own map marker is drawn over the labels: with the sector map open, the gold player dot is painted after every map label',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map overlay here';
     var bad=[], g, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oArc=proto.arc, dmo=drawMapOverlay, seq=0, lastText=-1, dot=-1, ink=0, inMap=false, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oOwn=ctx.fillText;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true;
       proto.fillText=function(){ if(inMap) lastText=++seq; return oFT.apply(this,arguments); };
       proto.arc=function(x,y,r){ if(inMap){ var fs=String(this.fillStyle).toLowerCase(); if(fs==='#120e0c') ink=r; else if(fs==='#ffc04a'&&ink>0&&Math.abs(r-ink*8/11)<0.05){ dot=++seq; ink=0; } else ink=0; } return oArc.apply(this,arguments); };
       drawMapOverlay=function(){ inMap=true; try{ return dmo.apply(this,arguments); } finally { inMap=false; } };
       __frame(0.001);
       if(dot<0) return 'SKIP: the player dot was not drawn';
       if(lastText<0) return 'SKIP: no map labels were drawn';
       if(dot<lastText) bad.push('a map label is painted after his own marker, over it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ drawMapOverlay=dmo; proto.fillText=oFT; proto.arc=oArc; if(own) ctx.fillText=oOwn; try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
