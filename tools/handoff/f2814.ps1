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

if ($s.Contains("  {v:'28.14',what:")) { throw "check 28.14 is in the fixture already" }

SubRx @'
  {v:'28.13',what:
'@ @'
  {v:'28.14',what:'kit4, cloud review findings 20 and 32: a kit picked on the map select screen is for that raid only (the pick falls back to MY LOADOUT after going up and the line says THIS RAID ONLY), the quick ascent never takes a kept kit, and RANDOM KIT and BEST KIT never pick or move a gun he locked in the stash',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot reach the lift';
     if(typeof kitDeploy!=='function'||typeof kitFillBest!=='function') return 'there is no kit row in this build';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), went=0, fills=[], started=0, oAsc=ascendNow, oFill=kitFill, oStart=startRaid, on, tx, i, k, seen={}, locked;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0;
       __hubEnter(); shut();
       ascendNow=function(){ went++; return true; };
       kitFill=function(r){ fills.push(!!r); return {gun:null,kit:[]}; };
       startRaid=function(){ started++; };
       // ONE: the pick holds on the page, and falls back to MY LOADOUT once he has gone up with it
       q.kitPick='best'; renderSector(); openModal('sectormodal');
       tx=document.getElementById('sectorkit').textContent;
       if(tx.indexOf('BEST KIT')<0||tx.indexOf('THIS RAID ONLY')<0) bad.push('ONE: the line under the row reads "'+tx.slice(0,80)+'"');
       q.kitPick='mine'; renderSector();
       if(document.getElementById('sectorkit').textContent.indexOf('THIS RAID ONLY')>=0) bad.push('ONE: MY LOADOUT says THIS RAID ONLY');
       q.kitPick='best'; renderSector(); openModal('sectormodal');
       document.getElementById('sectordeploy').click();
       if(went!==1||fills.join()!=='false') bad.push('ONE: BEST KIT went '+went+' times and filled '+fills.join());
       if(q.kitPick!=='mine') bad.push('ONE: the pick stayed at '+q.kitPick+' after the raid was picked');
       renderSector(); on=document.querySelectorAll('#sectorkitpick .kitb.on');
       if(on.length!==1||on[0].getAttribute('data-kit')!=='mine') bad.push('ONE: the next map select screen does not open on MY LOADOUT');
       // TWO: the quick ascent never takes a kept kit
       shut(); started=0; fills.length=0; q.kitPick='rand'; q.freeKit=0; __hubEnter(); shut();
       __station('lift','KeyR');
       if(started!==1) bad.push('TWO: the quick ascent started '+started+' raids');
       if(fills.length) bad.push('TWO: the quick ascent filled a kept kit ('+fills.join()+')');
       // THREE: a gun locked in the stash is never picked or moved
       kitFill=oFill; ascendNow=oAsc; startRaid=oStart;
       locked=0;
       for(i=0;i<30;i++){
         q.weapons=['pistol','smg']; q.stash=['gun_carbine','gun_shotgun','gun_rifle','medkit']; q.keep={gun_carbine:1}; q.equipped='pistol'; q.equippedSec='none'; q.kit=[]; q.hotAssign={};
         if(i%2) kitFill(true); else kitFill(false);
         if(q.weapons.indexOf('carbine')>=0||q.equipped==='carbine'||q.equippedSec==='carbine'||q.kit.indexOf('gun_carbine')>=0) locked++;
         if(q.stash.indexOf('gun_carbine')<0) locked++;
         seen[q.equipped+'/'+q.equippedSec+'/'+q.kit.filter(function(x){ return x.indexOf('gun_')===0; }).join('+')]=1;
       }
       if(locked) bad.push('THREE: the locked Burst Carbine was picked or moved '+locked+' times');
       if(Object.keys(seen).length<2) bad.push('THREE: the kits never changed ('+Object.keys(seen).join(' | ')+')');
       // FOUR: the same stash with the lock off can pick it
       q.keep={}; locked=0;
       for(i=0;i<60&&!locked;i++){
         q.weapons=['pistol','smg']; q.stash=['gun_carbine','gun_shotgun','gun_rifle','medkit']; q.equipped='pistol'; q.equippedSec='none'; q.kit=[]; q.hotAssign={};
         kitFill(false);
         if(q.equipped==='carbine'||q.equippedSec==='carbine'||q.kit.indexOf('gun_carbine')>=0) locked=1;
       }
       if(!locked) bad.push('FOUR: with the lock off the Burst Carbine was never picked, so the lock proved nothing');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ ascendNow=oAsc; kitFill=oFill; startRaid=oStart; }catch(_a){}
       try{ shut(); }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
