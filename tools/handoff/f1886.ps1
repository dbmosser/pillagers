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

if ($s.Contains("  {v:'18.86',what:")) { throw "check 18.86 is in the fixture already" }

SubRx @'
  {v:'18.85',what:
'@ @'
  {v:'18.86',what:'the controls legend steps aside for the backpack: with the backpack open no legend words are drawn, and with it closed they are',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oFT=ctx.fillText, seen;
     function legendDrawn(){ seen=false; ctx.fillText=function(s){ if(String(s)==='tactical belt'||String(s)==='crouch') seen=true; return oFT.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return seen; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); g.mapOpen=false; g.legendOn=1;
       g.bagOpen=false; if(!legendDrawn()) return 'SKIP: the compact legend is not drawn here';
       g.bagOpen=true; if(legendDrawn()) bad.push('the legend is drawn under the open backpack');
       g.bagOpen=false; if(!legendDrawn()) bad.push('the legend did not come back when the backpack closed');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2){ g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
