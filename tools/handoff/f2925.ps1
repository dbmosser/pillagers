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

if ($s.Contains("  {v:'29.25',what:")) { throw "check 29.25 is in the fixture already" }

SubRx @'
  {v:'29.24',what:
'@ @'
  {v:'29.25',what:'a killed Peddler leaves wreckage in its own shape (drawn by the Peddler wreck path, drawWreckPeddler), not the generic wreck box (his note: show wreckage instead, same for other enemy deaths)',
   run:function(){
     if(typeof __frame!=='function'||typeof mkPeddler!=='function'||typeof __ents!=='function') return 'SKIP: no frame or entity helper';
     var PR=CanvasRenderingContext2D.prototype, otr=PR.translate, g=null, p, e, i, c, ct=null, hit=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       e=mkPeddler(p.x+60,p.y);  e.hp=0; e.byPlayer=1; g.ents=[e]; __ents(0.016);
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(Math.abs(c.x-e.x)<2&&Math.abs(c.y-e.y)<2&&c.bot==='peddler'){ ct=c; break; } }
       if(!ct) return 'a dead Peddler left no wreck container tagged peddler';
       p.x=ct.x-60; p.y=ct.y;
       PR.translate=function(x,y){ if(Math.abs(x-ct.x)<0.01&&/drawContS/.test(String(new Error().stack))&&/drawWreckPeddler/.test(String(new Error().stack))) hit++; return otr.apply(this,arguments); };
       __frame(); __frame();
       PR.translate=otr;
       if(!hit) return 'a dead Peddler loot is not drawn by the Peddler wreck path (still the generic wreck)';
       return null;
     } finally {
       PR.translate=otr;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
