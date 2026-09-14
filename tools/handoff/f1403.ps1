$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.02',what:
'@ @'
  {v:'14.03',what:'a gun taken out of the armoury comes back if the page goes away mid-raid: the armoury carbine bagged in a raid, saved, and loaded again through the real loader without the raid ever ending is back in the armoury, as an owned carbine saved and loaded is (saving, profile and settings audit 2026-09-15, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy or load a profile';
     if(typeof bagHeldGun!=='function'||!WEAPONS.carbine) return 'SKIP: no gun bagging in this build';
     var bad=[], keep=JSON.parse(JSON.stringify(__P()));
     function copyW(id){ var w={},k; for(k in WEAPONS[id]) w[k]=WEAPONS[id][k]; return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // CONTROL: an owned carbine saved and loaded is still owned.
       var P0=__P(); P0.weapons=['carbine']; P0.equipped='carbine'; P0.equippedSec='none';
       __applyLoaded(JSON.parse(JSON.stringify(P0)));
       if(__P().weapons.indexOf('carbine')<0) return 'SKIP: the loader dropped an owned carbine from an ordinary save, so nothing here can be measured';
       // THE FINDING: bag it mid-raid, save, and load that save with the raid never ended.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), P2=__P();
       if(!g||!g.player) return 'SKIP: no live raid';
       var p=g.player;
       g.ents.length=0; p.downed=false; g.spliced=null;
       P2.weapons=['carbine']; P2.equipped='carbine'; P2.equippedSec='none';
       p.wep=copyW('carbine'); p.ammo=p.wep.mag; p.wepIssued=false; p.wepFromArmory=true; p.swapped=false;
       p.sec=WEAPONS.fists; p.secIssued=true; p.secFromArmory=false;
       if(!bagHeldGun('gunA')) return 'SKIP: the belt would not bag the carbine';
       if(P2.weapons.indexOf('carbine')>=0) return 'SKIP: bagging did not take the carbine off the armoury list';
       var saved=JSON.parse(JSON.stringify(P2));
       __applyLoaded(saved);
       if(__P().weapons.indexOf('carbine')<0) bad.push('the armoury carbine bagged in a raid that never ended was in neither the armoury nor the stash after the save was loaded');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ __applyLoaded(keep); saveProfile(); }catch(_p){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
