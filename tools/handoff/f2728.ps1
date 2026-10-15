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

if ($s.Contains("  {v:'27.28',what:")) { throw "check 27.28 is in the fixture already" }

SubRx @'
  {v:'27.27',what:
'@ @'
  {v:'27.28',what:'kit3, his word on BEST KIT: his three best guns by the colour they wear, then tier, then worth, three different models, the best in hand, the second in the other hand, the third packed, each on its class key; and up to three of each wheel item from the stash in wheel order, the Armour only with a rig that holds plates, the biggest Ammo Box, never more than the pack room',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture has no profile';
     if(typeof kitFillBest!=='function') return 'there is no new BEST KIT in this build';
     var bad=[], snap=null, q, i, n, k, cnt, wh=['medkit','smoke','frag','trip','plate','decoy','bandage','stim'], want, oRig=rigCeil, oSlots=DEPLOY_SLOTS, am, bigA, srcs;
     function count(a){ var o={}, j; for(j=0;j<a.length;j++) o[a[j]]=(o[a[j]]||0)+1; return o; }
     function stage(){
       q=__P(); q.weapons=['pistol','smg','rifle','magnum','lmg']; q.equipped='smg'; q.equippedSec='none'; q.kit=[]; q.hotAssign={}; q.freeKit=0;
       q.stash=['gun_dmr','gun_whisper','gun_sniper','gun_lance','medkit','medkit','medkit','medkit','medkit','smoke','smoke','frag','trip','trip','trip','trip','plate','plate','plate','plate','plate','plate','plate','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','bandage','stim','stim','stim','ammobox','ammobox','scrap','wire'];
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: the three best, in hand, in the other hand, and packed, each on its class key
       stage(); kitFill(false);
       if(q.equipped!=='lance'||q.equippedSec!=='sniper') bad.push('ONE: the hands read '+q.equipped+' and '+q.equippedSec+', not the Meridian Lance and the Longshot');
       if(q.kit.filter(function(x){ return x==='gun_whisper'; }).length!==1) bad.push('ONE: the Whisper is not packed once ('+q.kit.join()+')');
       if(q.kit.filter(function(x){ return ITEMS[x]&&ITEMS[x].use==='gun'; }).length!==1) bad.push('ONE: '+q.kit.filter(function(x){ return ITEMS[x]&&ITEMS[x].use==='gun'; }).length+' gun items packed, not 1');
       ['lance','sniper','whisper'].forEach(function(g){ if(q.hotAssign[gunClassKey(gunClassOf(g))]!=='gun_'+g) bad.push('ONE: '+g+' is not on its class key ('+JSON.stringify(q.hotAssign)+')'); });
       if(q.weapons.indexOf('lance')<0||q.weapons.indexOf('sniper')<0) bad.push('ONE: the stash guns in hand were not moved to the armoury');
       // TWO: a third gun from the armoury leaves it for the stash to be packed
       stage(); q.weapons=['pistol','smg','rifle','magnum']; q.stash=['medkit']; kitFill(false);
       if(q.equipped!=='rifle'||q.equippedSec!=='magnum') bad.push('TWO: the hands read '+q.equipped+' and '+q.equippedSec+', not the rifle and the Magnum');
       if(q.kit.indexOf('gun_smg')<0) bad.push('TWO: the third gun, the Compact SMG, is not packed ('+q.kit.join()+')');
       if(q.weapons.indexOf('smg')>=0) bad.push('TWO: the packed gun is still in the armoury');
       // THREE: fewer than three guns, one gun, none
       stage(); q.weapons=['pistol']; q.stash=['medkit']; kitFill(false);
       if(q.equipped!=='pistol'||q.equippedSec!=='none') bad.push('THREE: with only the pistol the hands read '+q.equipped+' and '+q.equippedSec);
       stage(); q.weapons=[]; q.stash=['medkit']; kitFill(false);
       if(q.equipped!=='fists') bad.push('THREE: with no gun the hands read '+q.equipped+', not empty for the Scav Pistol');
       // FOUR: up to three of each wheel item, the pack otherwise as the stash has it
       stage(); kitFill(false);
       cnt=count(q.kit);
       want={medkit:3,smoke:2,frag:1,trip:3,plate:3,decoy:0,bandage:3,stim:3};
       try{ if(!(rigCeil(myRig())>0)) want.plate=0; }catch(_e){}
       for(i=0;i<wh.length;i++){ k=wh[i]; if((cnt[k]||0)!==want[k]) bad.push('FOUR: '+k+' x'+(cnt[k]||0)+' in the kit, not '+want[k]); }
       if((cnt.ammobox||0)!==1) bad.push('FOUR: '+(cnt.ammobox||0)+' ammo boxes, not 1');
       if(q.kit.indexOf('scrap')>=0||q.kit.indexOf('wire')>=0) bad.push('FOUR: salvage was packed');
       if(q.stash.indexOf('medkit')<0) bad.push('FOUR: the kit took items out of the stash before the raid');
       // FIVE: the Armour only with a rig that holds plates
       rigCeil=function(){ return 0; }; stage(); kitFill(false); rigCeil=oRig;
       if(q.kit.indexOf('plate')>=0) bad.push('FIVE: an Armour Plate was packed with a rig that holds none');
       // SIX: room: the packed gun counts, and the items fill in wheel order
       DEPLOY_SLOTS=4; stage(); kitFill(false); DEPLOY_SLOTS=oSlots;
       if(q.kit.length!==4) bad.push('SIX: '+q.kit.length+' things for a pack of 4');
       else if(q.kit.join()!=='gun_whisper,medkit,medkit,medkit') bad.push('SIX: the short pack reads '+q.kit.join());
       // SEVEN: RANDOM KIT is still its own, and the old TOP GEAR fill is gone
       stage(); kitFill(true);
       if(q.equipped===q.equippedSec) bad.push('SEVEN: RANDOM KIT gave one gun twice');
       srcs=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(srcs.indexOf('(tc[pool[i]]||0)<'+'2')>=0) bad.push('SEVEN: the old two-of-each TOP GEAR fill is still in the file');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ rigCeil=oRig; DEPLOY_SLOTS=oSlots; }catch(_a){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
