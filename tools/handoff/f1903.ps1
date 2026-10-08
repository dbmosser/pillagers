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

if ($s.Contains("  {v:'19.03',what:")) { throw "check 19.03 is in the fixture already" }

SubRx @'
  {v:'19.02',what:
'@ @'
  {v:'19.03',what:'the open map hides what is under it: the backing it lays over the whole screen is at least 98 percent opaque',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map here';
     var bad=[], g, oFR=ctx.fillRect, a=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=true;
       ctx.fillRect=function(x,y,w,h){ if(a===null&&x===0&&y===0&&w===W&&h===H){ var m=(/rgba\(\s*9\s*,\s*12\s*,\s*34\s*,\s*([\d.]+)\)/).exec(String(ctx.fillStyle).replace(/\s/g,'')); if(m) a=parseFloat(m[1]); else { var c=String(ctx.fillStyle); if(c.charAt(0)==='#'&&c.length===7) a=1; } } return oFR.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
       if(a===null) return 'SKIP: the map backing was not seen';
       if(a<0.98) bad.push('the map backing is '+a+' opaque, so the HUD under it shows through');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
