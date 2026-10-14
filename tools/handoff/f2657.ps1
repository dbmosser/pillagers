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

if ($s.Contains("  {v:'26.57',what:")) { throw "check 26.57 is in the fixture already" }

SubRx @'
  {v:'26.56',what:
'@ @'
  {v:'26.57',what:'feel12, his order: the camera looks ahead toward the cursor, 0.20 of its distance from the centre with a gun and 0.30 with a long gun (the Marksman Rifle, the Longshot, the Meridian Lance), 0.13 with bare hands as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, oWep, oAmmo, oMx, oMy, oAds, dx=300, r1, r2, r3;
     function ratio(w){
       p.wep=w; p.ammo=w.mag||0; p.hand=false; p.ads=false;
       mouse.x=W/2+dx; mouse.y=H/2; __frame(0.5); __frame(0.5);
       return g.leanSX/dx;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oWep=p.wep; oAmmo=p.ammo; oMx=mouse.x; oMy=mouse.y; oAds=p.ads;
       r1=ratio(cloneObj(WEAPONS.pistol)); r2=ratio(cloneObj(WEAPONS.sniper)); r3=ratio(cloneObj(WEAPONS.fists));
       if(!(r1>0.19&&r1<0.21)) bad.push('ONE: with a pistol the camera leans '+r1.toFixed(3)+' of the cursor distance, not 0.20');
       if(!(r2>0.29&&r2<0.31)) bad.push('ONE: with the Longshot the camera leans '+r2.toFixed(3)+', not 0.30');
       if(!(r3>0.12&&r3<0.14)) bad.push('ONE: with bare hands the camera leans '+r3.toFixed(3)+', not 0.13');
       if(!(r2>r1)) bad.push('ONE: the long gun does not look farther than the pistol');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.ads=oAds; } if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
