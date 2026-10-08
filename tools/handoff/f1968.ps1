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

if ($s.Contains("  {v:'19.68',what:")) { throw "check 19.68 is in the fixture already" }

SubRx @'
  {v:'19.67',what:
'@ @'
  {v:'19.68',what:'the compact controls panel on a controller names no keyboard key: with the pad on, H full list is not drawn, and with it off it is',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawLegend!=='function'||typeof PAD==='undefined') return 'SKIP: no legend or pad here';
     var bad=[], g, oFT=ctx.fillText, on0=PAD.on, seen, h0=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined;
     function run(pad){ seen=false; PAD.on=pad; ctx.save(); try{ drawLegend(); } finally { ctx.restore(); } return seen; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.legendOn=1; if(P.hud&&P.hud.legend) P.hud.legend.c=0;
       ctx.fillText=function(t){ if(String(t).indexOf('full list')>=0) seen=true; return oFT.apply(this,arguments); };
       if(run(true)) bad.push('on a controller the panel still says H  full list');
       if(!run(false)) bad.push('control: with keyboard and mouse the panel does not say H  full list');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.on=on0; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(h0===undefined) delete P.hud; else P.hud=h0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
