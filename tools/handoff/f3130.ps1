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

if ($s.Contains("  {v:'31.30',what:")) { throw "check 31.30 is in the fixture already" }

SubRx @'
  {v:'31.29',what:
'@ @'
  {v:'31.30',what:'the downed block sits on one plate (uiPanel) and draws it every frame it is down, sized to its rows (critic on screen 34: a plate behind the whole block)',
   run:function(){
     if(typeof downPlateRect!=='function'||typeof downPlateDraw!=='function'||typeof DP_DRAWS!=='number') return 'the downed block has no plate behind it (no downPlateRect)';
     var g, p, i, d0, r, r2, md=mouse.down;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player; g.ents.length=0; p.hp=0; p.downed=true; p.downT=60; p.revived=1; p.iv=99; p.pendKiller=null; mouse.down=false;
       r=downPlateRect(960,500,39,19,false,false,false,null,true);
       r2=downPlateRect(960,500,39,19,true,true,false,{msg:'X',sub:'y'},true);
       if(!(r.w>=480&&r.h>=110)) return 'the plate is too small for the base rows ('+r.w+'x'+r.h+')';
       if(!(r2.h>r.h+60)) return 'the plate does not grow for the surrender and extraction rows ('+r.h+' to '+r2.h+')';
       if(typeof __vpAlive==='function'&&!__vpAlive()) return null;
       d0=DP_DRAWS;
       for(i=0;i<3;i++) __loop(performance.now()+i*17);
       if(DP_DRAWS<=d0) return 'a downed frame drew no plate behind the downed words';
       return null;
     } finally {
       mouse.down=md;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
