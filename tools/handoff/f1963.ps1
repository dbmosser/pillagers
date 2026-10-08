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

if ($s.Contains("  {v:'19.63',what:")) { throw "check 19.63 is in the fixture already" }

SubRx @'
  {v:'19.62',what:
'@ @'
  {v:'19.63',what:'the sector map marker tags grow at 4K: a locked room or CACHE tag is drawn about twice its 1080p size on a 4K screen',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, k, proto=CanvasRenderingContext2D.prototype, o=proto.fillText, s1, s4;
     function grab(){ var m=null; for(k=0;k<4;k++) __frame(0.05); proto.fillText=function(t){ var s=String(t); if(!m&&(/  .  (LOCKED|OPEN)$/.test(s)||s==='CACHE'||s==='LOOTED')){ var tr=this.getTransform(), fm=(/([\d.]+)px/).exec(String(this.font)); m={t:s,px:(fm?parseFloat(fm[1]):0)*tr.d}; } return o.apply(this,arguments); }; try{ __frame(0.05); } finally { proto.fillText=o; } return m; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true;
       s1=grab();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       s4=grab();
       if(!s1||!s4) return 'SKIP: no marker tag was drawn';
       if(s4.px<s1.px*1.7) bad.push('at 4K the map tag '+s4.t+' is '+s4.px.toFixed(1)+' px against '+s1.px.toFixed(1)+' px at 1080p');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
