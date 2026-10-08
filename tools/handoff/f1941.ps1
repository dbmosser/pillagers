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

if ($s.Contains("  {v:'19.41',what:")) { throw "check 19.41 is in the fixture already" }

SubRx @'
  {v:'19.40',what:
'@ @'
  {v:'19.41',what:'the full controls list fits its keys: the panel ends a little past its widest line, with no empty half and no divider down the middle',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawLegend!=='function'||typeof hudPanel!=='function') return 'SKIP: no legend here';
     var bad=[], g, oHP=hudPanel, oFT=ctx.fillText, panel=null, right=-1e9, lines=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.legendOn=2;
       if(P.hud&&P.hud.legend) P.hud.legend.c=0;
       hudPanel=function(x,y,w,h){ if(!panel) panel={x:x,w:w}; return oHP.apply(this,arguments); };
       ctx.fillText=function(t,x,y){ var w=ctx.measureText(String(t)).width, a=ctx.textAlign; var r=(a==='center')?x+w/2:((a==='right'||a==='end')?x:x+w); if(r>right) right=r; lines++; return oFT.apply(this,arguments); };
       ctx.save(); try{ drawLegend(); } finally { ctx.restore(); }
       if(!panel||lines<10) return 'SKIP: the full list was not drawn';
       if(panel.x+panel.w-right>Math.max(60,panel.w*0.15)) bad.push('the panel runs '+Math.round(panel.x+panel.w-right)+' px past its widest line, of '+Math.round(panel.w));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2&&!g2.over){ g2.legendOn=1; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
