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

if ($s.Contains("  {v:'36.80',what:")) { throw "check 36.80 is in the fixture already" }

SubRx @'
  {v:'36.79',what:
'@ @'
  {v:'36.80',what:'the downed card shows the self-revive key on a keycap chip, not in square brackets',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&typeof __frame==='function')) return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, g=null, p=null, keyDrawn=0, bracket=0, words=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: no live raid';
       p=g.player; g.ents=[]; g.bagOpen=false; g.mapOpen=false; g.paused=false;
       p.downed=true; p.downT=(CFG.downTime||30)*0.8; p.revived=false;
       PR.fillText=function(s){ var t=String(s).toLowerCase(); if(t==='f') keyDrawn++; if(/^\[f\]/.test(t)) bracket++; if(/self-revive/.test(t)) words++; return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of;
       if(!words) return 'the downed card did not draw the self-revive words';
       if(bracket) return 'the self-revive key is still drawn in square brackets';
       if(!keyDrawn) return 'the self-revive key is not drawn on a keycap';
       return null;
     } finally {
       PR.fillText=of;
       try{ p.downed=false; }catch(_e0){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
