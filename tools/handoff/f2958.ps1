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

if ($s.Contains("  {v:'29.58',what:")) { throw "check 29.58 is in the fixture already" }

SubRx @'
  {v:'29.57',what:
'@ @'
  {v:'29.58',what:'the Marksman Rifle and the Whisper are gone from every gun, item, loot and shop table, and a saved one pays its credits on load (his order 2026-10-18)',
   run:function(){
     var bad=[], k, i, t, p, paid, tabs, nm;
     if(typeof gunsGoneSweep!=='function') return 'no gunsGoneSweep: a saved Marksman Rifle or Whisper is not turned into credits';
     for(k in WEAPONS) if(/dmr|whisper/.test(k)) bad.push('WEAPONS.'+k);
     for(k in ITEMS) if(/dmr|whisper/.test(k)) bad.push('ITEMS.'+k);
     if(typeof RV_OF==='object'&&(RV_OF.dmr||RV_OF.whisper)) bad.push('a rarity twin of a gone gun');
     for(k in LOOT) for(i=0;i<LOOT[k].length;i++) if(/dmr|whisper/.test(String(LOOT[k][i][0]))) bad.push('LOOT.'+k+' row '+i);
     tabs={PED_GUNS:PED_GUNS, CRATE_KIT:CRATE_KIT, ARCADE_GUNS2:ARCADE_GUNS2, ARCADE_VAULT_GUNS:ARCADE_VAULT_GUNS, GAMBLE:GAMBLE_POOL.map(function(r){ return r[0]; }), WIRT:[].concat.apply([],WIRT_LOT_POOL)};
     for(nm in tabs) for(i=0;i<tabs[nm].length;i++) if(/dmr|whisper/.test(String(tabs[nm][i]))) bad.push(nm+' still lists '+tabs[nm][i]);
     if(!String(applyLoadedProfile).match(/gunsGoneSweep\(/)) bad.push('the loader does not run gunsGoneSweep');
     p={credits:100,stash:['gun_dmr','gun_whisper_v','plate'],weapons:['dmr','whisper','rifle'],kit:['gun_dmr','plate'],hotAssign:{0:'gun_whisper',1:'gun_rifle'},forged:{dmr:{a:1},rifle:{a:1}},wear:{whisper:3},gunPiled:[{gk:'dmr'},{gk:'rifle'}],equipped:'rifle'};
     paid=gunsGoneSweep(p);
     if(paid!==12500||p.credits!==12600) bad.push('paid '+paid+', credits '+p.credits+', not 12500 and 12600');
     if(p.stash.join()!=='plate'||p.weapons.join()!=='rifle'||p.kit.join()!=='plate') bad.push('the lists still hold them: '+p.stash.join()+' / '+p.weapons.join()+' / '+p.kit.join());
     if(p.hotAssign[0]!==undefined||p.hotAssign[1]!=='gun_rifle'||p.forged.dmr||!p.forged.rifle||p.wear.whisper!==undefined||p.gunPiled.length!==1) bad.push('the plans or records still name them');
     if(gunsGoneSweep({credits:5,stash:['plate'],weapons:['rifle']})!==0) bad.push('a clean profile was paid');
     return bad.length?bad.slice(0,4).join('; '):null;
   }},
  {v:'29.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
