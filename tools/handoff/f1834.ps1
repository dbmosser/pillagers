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

if ($s.Contains("  {v:'18.34',what:")) { throw "check 18.34 is in the fixture already" }

SubRx @'
  {v:'18.33',what:
'@ @'
  {v:'18.34',what:'the belt keys are rounded tiles in the raid: with the HUD drawn, the outer corner pixel of the first belt key is left clear while a pixel just inside it is painted',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, C, oCR=ctx.clearRect, cor, ins, seq=0, after=0;
     function al(x,y){ return ctx.getImageData(Math.round(x*DPR),Math.round(y*DPR),1,1).data[3]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.bagOpen=false; g.legendOn=0;
       __frame(0.016); __frame(0.016);
       C=g.hotCells&&g.hotCells[0]; if(!C) return 'SKIP: no belt drawn';
       cor=al(C.x+0.6,C.y+0.6); ins=al(C.x+C.w*0.2,C.y+C.w*0.2);
       if(ins<120) bad.push('control: the belt key is not painted inside (alpha '+ins+')');
       if(cor>=ins-40) bad.push('the belt key corner is square (corner '+cor+', inside '+ins+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
