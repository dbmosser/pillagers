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

if ($s.Contains("  {v:'19.93',what:")) { throw "check 19.93 is in the fixture already" }

SubRx @'
  {v:'19.92',what:
'@ @'
  {v:'19.93',what:'the collapsed controls hint names no keyboard key on a pad: with the pad on, H controls and H hide are not drawn, and with it off they are',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawLegend!=='function'||typeof PAD==='undefined') return 'SKIP: no legend or pad here';
     var bad=[], g, oFT=ctx.fillText, on0=PAD.on, seen, h0=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined;
     function run(pad,lo){ seen={}; PAD.on=pad; g.legendOn=lo; ctx.save(); try{ drawLegend(); } finally { ctx.restore(); } return seen; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; if(P.hud&&P.hud.legend) P.hud.legend.c=0;
       ctx.fillText=function(t){ var s=String(t); if(s==='H  controls') seen.ctl=1; if(s==='H  hide') seen.hide=1; return oFT.apply(this,arguments); };
       if(run(true,0).ctl) bad.push('on a pad the collapsed panel says H  controls');
       if(run(true,2).hide) bad.push('on a pad the full list says H  hide');
       if(!run(false,0).ctl) bad.push('control: with keyboard and mouse the collapsed panel does not say H  controls');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.on=on0; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(h0===undefined) delete P.hud; else P.hud=h0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
