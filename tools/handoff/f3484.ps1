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

if ($s.Contains("  {v:'34.84',what:")) { throw "check 34.84 is in the fixture already" }

SubRx @'
  {v:'34.83',what:
'@ @'
  {v:'34.84',what:'cw-nogunline, his note of 2026-10-25 ("why does it say gun = compact smg?!? get rid of that"): the going up box on the pre-raid page names no gun (no gun, gun 2 or own gun in stash chip, armed or not), the no armour warning still shows with no armour packed, and with armour packed the box is empty and leaves no blank band above the ascend plate',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)||typeof renderSector!=='function'||typeof syncSectorKit!=='function'||typeof packedCount!=='function') return 'SKIP: no pre-raid page';
     if(!WEAPONS.rifle||!WEAPONS.pistol||!WEAPONS.smg||!ITEMS.gun_smg||!ITEMS.bandage||!ITEMS.plate||ITEMS.plate.use!=='armor') return 'SKIP: staging: no rifle, pistol, smg, smg item, bandage or armour plate in this build';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), el=document.getElementById('sectorkit'), names, tx, wb, r, col, pk, pl, kd, ref, band;
     if(!sm||!el) return 'SKIP: no going up box';
     names=[WEAPONS.rifle.name,WEAPONS.pistol.name,WEAPONS.smg.name].map(function(s){ return String(s).toLowerCase(); });
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     function draw(){ renderSector(); openModal('sectormodal'); return String(el.textContent||''); }
     function gunSaid(t){ var lo=t.toLowerCase(), i; if(el.querySelector('.gc')) return el.querySelectorAll('.gc').length+' chip(s)'; if(/\bgun\b/.test(lo)) return 'the word gun'; if(lo.indexOf('scav pistol')>=0) return 'a scav pistol'; for(i=0;i<names.length;i++) if(lo.indexOf(names[i])>=0) return names[i]; return ''; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.freeKit=0; q.kitPick='mine';
       __hubEnter(); shut();
       // ONE (his note): a gun in each hand, another gun in the stash, no armour packed
       q.weapons=['rifle','pistol']; q.equipped='rifle'; q.equippedSec='pistol'; q.stash=['gun_smg','bandage']; q.kit=[];
       tx=draw(); r=gunSaid(tx);
       if(r) bad.push('ONE: armed, the going up box still names a gun ('+r+'): "'+tx.slice(0,90)+'"');
       wb=el.querySelector('.srsum .wn b');
       if(!wb||!/no armour equipped/i.test(wb.textContent)) bad.push('ONE: with no armour packed the armour warning is gone: "'+tx.slice(0,90)+'"');
       if(getComputedStyle(el).display==='none') bad.push('ONE: the box holding the armour warning is hidden');
       // TWO: nothing in his hands and a gun waiting in the stash: no scav pistol line, no own gun in stash note
       q.equipped='fists'; q.equippedSec='none';
       tx=draw(); r=gunSaid(tx);
       if(r||/own gun|in stash/i.test(tx)) bad.push('TWO: unarmed, the going up box still names a gun ('+(r||'own gun in stash')+'): "'+tx.slice(0,90)+'"');
       if(!/no armour equipped/i.test(tx)) bad.push('TWO: with no armour packed the armour warning is gone');
       // THREE: armed and armoured: nothing is left, and the empty box leaves no blank band above the ascend plate
       q.equipped='rifle'; q.equippedSec='pistol'; q.stash=['plate','gun_smg','bandage']; q.kit=['plate'];
       tx=draw();
       if(packedCount('plate')!==1) bad.push('THREE: staging: the plate did not pack ('+packedCount('plate')+')');
       else{
         if(el.firstChild) bad.push('THREE: armed and armoured, the going up box still holds "'+tx.slice(0,90)+'"');
         if(getComputedStyle(el).display!=='none') bad.push('THREE: the empty going up box still sits in the kit column (display '+getComputedStyle(el).display+')');
         col=document.getElementById('srkitcol'); pk=document.getElementById('sectorpack'); pl=sm.querySelector('.srplate'); kd=col?col.firstElementChild:null;
         if(col&&pk&&pl&&kd&&kd!==pk&&col.getBoundingClientRect().height>100){
           ref=pk.getBoundingClientRect().top-kd.getBoundingClientRect().bottom; band=pl.getBoundingClientRect().top-pk.getBoundingClientRect().bottom;
           if(band>ref+1.5) bad.push('THREE: '+Math.round(band)+' px sit between the pack and the ascend plate, where one column gap is '+Math.round(ref)+' px');
         }
       }
       // CONTROL: a kit picked on the page still says so under the row
       q.kitPick='free'; tx=draw();
       if(!/freebie kit/i.test(tx)||!/this raid only/i.test(tx)||getComputedStyle(el).display==='none') bad.push('control: with FREEBIE KIT picked the line under the row reads "'+tx.slice(0,90)+'"');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ shut(); }catch(_s){} try{ if(snap) __applyLoaded(snap); }catch(_a){} try{ __cleanProfile(); }catch(_c){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
