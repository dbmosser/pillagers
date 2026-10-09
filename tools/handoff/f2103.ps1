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

if ($s.Contains("  {v:'21.03',what:")) { throw "check 21.03 is in the fixture already" }

SubRx @'
  {v:'21.02',what:
'@ @'
  {v:'21.03',what:'on the sector map at 4K every extraction name stands clear of the line under it: the two lines are more than a line height of the lower one apart',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map here';
     var bad=[], g, oFT=ctx.fillText, oMO=drawMapOverlay, rec=[], on=false, i, a, b, n=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=true;
       __frame(0.016);
       drawMapOverlay=function(){ on=true; try{ return oMO.apply(this,arguments); } finally { on=false; } };
       ctx.fillText=function(s,x,y){ if(on){ var m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)); rec.push({s:String(s),y:m.d*y+m.f,px:(fm?parseFloat(fm[1]):0)*m.d}); } return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; drawMapOverlay=oMO; }
       for(i=0;i+1<rec.length;i++){
         a=rec[i]; if(!(/^EXTRACT [A-Z]$/).test(a.s)) continue;
         b=rec[i+1]; n++;
         if(!(b.px>0)) continue;
         if(b.y-a.y<b.px*1.1) bad.push(a.s+' and the line under it ('+b.s+') are '+Math.round(b.y-a.y)+' px apart for a '+Math.round(b.px)+' px line');
       }
       if(!n) return 'SKIP: no extraction name was drawn on the map';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; drawMapOverlay=oMO; try{ __forceSize(1920,1080); }catch(_f){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'21.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
