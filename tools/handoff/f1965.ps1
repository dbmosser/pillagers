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

if ($s.Contains("  {v:'19.65',what:")) { throw "check 19.65 is in the fixture already" }

SubRx @'
  {v:'19.64',what:
'@ @'
  {v:'19.65',what:'a CACHE tag clears its own ring: on the sector map at 4K, every cache tag left where it was drawn sits wholly above its ring',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, k, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oArc=proto.arc, tags=[], rings=[], z, n=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true;
       for(k=0;k<4;k++) __frame(0.05);
       z=Math.max(1,hudRes());
       proto.arc=function(x,y,r){ if(String(this.strokeStyle).toLowerCase()==='#e0a0ff'&&r>=8.9*z&&r<=11.1*z) rings.push({x:x,y:y}); return oArc.apply(this,arguments); };
       proto.fillText=function(t,x,y){ var s=String(t); if(s==='CACHE'){ var fm=(/([\d.]+)px/).exec(String(this.font)); tags.push({x:x,y:y,fp:fm?parseFloat(fm[1]):12}); } return oFT.apply(this,arguments); };
       __frame(0.05);
       proto.arc=oArc; proto.fillText=oFT;
       if(!rings.length||!tags.length) return 'SKIP: no cache rings or tags drawn';
       tags.forEach(function(T){ rings.forEach(function(R){ if(Math.abs(T.x-R.x)<0.5&&R.y>T.y&&R.y-T.y<40*z){ n++; if(T.y+T.fp*0.22>R.y-12*z+1) bad.push('a CACHE tag reaches '+Math.round(T.y+T.fp*0.22-(R.y-12*z))+' px into its ring'); } }); });
       if(!n) return 'SKIP: every cache tag was moved off its own spot';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.arc=oArc; proto.fillText=oFT; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,2).join('; '):null; }},
  {v:'19.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
