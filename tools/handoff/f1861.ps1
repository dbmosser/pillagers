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

if ($s.Contains("  {v:'18.61',what:")) { throw "check 18.61 is in the fixture already" }

SubRx @'
  {v:'18.60',what:
'@ @'
  {v:'18.61',what:'a stowed weapon with no magazine shows no ammo count: bare hands read STOWED  Bare Hands, and a stowed gun still shows its rounds',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, oFT=ctx.fillText, rec=[], oSec, oSA;
     function grab(){ rec=[]; ctx.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return rec.filter(function(t){ return t.indexOf('STOWED')===0; })[0]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; oSec=p.sec; oSA=p.secAmmo;
       if(typeof WEAPONS==='undefined'||!WEAPONS.fists) return 'SKIP: no bare hands here';
       p.sec=WEAPONS.fists; p.secAmmo=0;
       var s=grab();
       if(!s) return 'SKIP: no stowed line was drawn';
       if(/\s0$/.test(s)) bad.push('bare hands stowed read "'+s+'"');
       var gun=null, k; for(k in WEAPONS) if(WEAPONS[k]&&WEAPONS[k].mag>0){ gun=WEAPONS[k]; break; }
       if(gun){ p.sec=gun; p.secAmmo=17; s=grab()||''; if(!/\s17$/.test(s)) bad.push('control: a stowed gun read "'+s+'"'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ if(p){ p.sec=oSec; p.secAmmo=oSA; } }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
