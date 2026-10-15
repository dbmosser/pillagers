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

if ($s.Contains("  {v:'27.23',what:")) { throw "check 27.23 is in the fixture already" }

SubRx @'
  {v:'27.22',what:
'@ @'
  {v:'27.23',what:'kit2, his word on RANDOM KIT: two different random guns he owns (the Scav Pistol only when it is all he has), the first in hand, each on its class key, the old gun keys cleared, a gun only in the stash moved to the armoury, no gun at all leaves the hands empty for the Scav Pistol; and one of each wheel item from the stash, the Armour only with a rig that holds plates, one Ammo Box, never more than the pack room, in wheel order when it runs short',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture has no profile';
     if(typeof kitFillRandom!=='function') return 'there is no new RANDOM KIT in this build';
     var bad=[], snap=null, q, i, r, n, srcs, seenG={}, wh=['medkit','smoke','frag','trip','plate','decoy','bandage','stim'], cnt, k, g1, g2, oRig=rigCeil, oSlots=DEPLOY_SLOTS, ck, owned;
     function count(a){ var o={}, j; for(j=0;j<a.length;j++) o[a[j]]=(o[a[j]]||0)+1; return o; }
     function stage(){
       q=__P(); q.weapons=['pistol','smg','rifle','magnum','lmg']; q.equipped='pistol'; q.equippedSec='none'; q.kit=[]; q.hotAssign={3:'gun_pistol'}; q.freeKit=0;
       q.stash=['gun_carbine','gun_shotgun','medkit','medkit','medkit','smoke','smoke','frag','plate','plate','plate','plate','bandage','bandage','bandage','bandage','bandage','stim','stim','trip','ammobox','ammobox','scrap','wire'];
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: two different guns, never the pistol, each on its class key, the first in hand
       for(i=0;i<40;i++){
         stage(); owned=['smg','rifle','magnum','lmg','carbine','shotgun'];
         r=kitFill(true);
         g1=q.equipped; g2=q.equippedSec;
         if(g1===g2||owned.indexOf(g1)<0||owned.indexOf(g2)<0){ bad.push('ONE: the guns were '+g1+' and '+g2); break; }
         seenG[g1+'/'+g2]=1;
         if(q.hotAssign[gunClassKey(gunClassOf(g1))]!=='gun_'+g1) bad.push('ONE: '+g1+' is not on its class key');
         if(q.hotAssign[gunClassKey(gunClassOf(g2))]!=='gun_'+g2) bad.push('ONE: '+g2+' is not on its class key');
         if(Object.keys(q.hotAssign).some(function(x){ return q.hotAssign[x]==='gun_pistol'; })) bad.push('ONE: the old plan kept its pistol key ('+JSON.stringify(q.hotAssign)+')');
         if(bad.length) break;
       }
       if(Object.keys(seenG).length<4) bad.push('ONE: 40 kits gave only '+Object.keys(seenG).length+' different pairs');
       // TWO: a gun that was only in the stash is now in the armoury; the stash item went with it
       stage(); q.weapons=['pistol']; q.stash=['gun_carbine','gun_shotgun','medkit'];
       kitFill(true);
       if(q.weapons.indexOf(q.equipped)<0||q.weapons.indexOf(q.equippedSec)<0) bad.push('TWO: a hand gun is not in the armoury ('+q.equipped+', '+q.equippedSec+')');
       if(q.stash.indexOf('gun_'+q.equipped)>=0&&q.weapons.filter(function(x){ return x===q.equipped; }).length>1) bad.push('TWO: the gun is in the armoury twice');
       // THREE: the pistol only when it is all he has; one other gun alone; no gun at all
       stage(); q.weapons=['pistol','smg']; q.stash=['medkit'];
       kitFill(true);
       if(q.equipped!=='smg'||q.equippedSec!=='none') bad.push('THREE: with one other gun the hands read '+q.equipped+' and '+q.equippedSec);
       stage(); q.weapons=['pistol']; q.stash=['medkit'];
       kitFill(true);
       if(q.equipped!=='pistol') bad.push('THREE: with only the pistol the hands read '+q.equipped);
       stage(); q.weapons=[]; q.stash=['medkit'];
       kitFill(true);
       if(q.equipped!=='fists'||q.equippedSec!=='none') bad.push('THREE: with no gun the hands read '+q.equipped+' and '+q.equippedSec+', not empty for the Scav Pistol');
       // FOUR: one of each wheel item, in the kit, and the rest of the stash left alone
       stage(); kitFill(true);
       cnt=count(q.kit);
       for(i=0;i<wh.length;i++){
         k=wh[i];
         n=(k==='decoy')?0:1;
         if(k==='plate'){ try{ if(!(rigCeil(myRig())>0)) n=0; }catch(_e){} }
         if((cnt[k]||0)!==n) bad.push('FOUR: '+k+' x'+(cnt[k]||0)+' in the kit, not '+n);
       }
       if((cnt.ammobox||0)!==1) bad.push('FOUR: '+(cnt.ammobox||0)+' ammo boxes, not 1');
       if(q.kit.some(function(x){ return ITEMS[x]&&ITEMS[x].use==='gun'; })) bad.push('FOUR: a gun item is in the kit');
       if(q.kit.indexOf('scrap')>=0||q.kit.indexOf('wire')>=0) bad.push('FOUR: salvage was packed');
       if(q.stash.indexOf('medkit')<0) bad.push('FOUR: the kit took items out of the stash before the raid');
       // FIVE: the Armour only with a rig that holds plates
       rigCeil=function(){ return 0; };
       stage(); kitFill(true);
       if(q.kit.indexOf('plate')>=0) bad.push('FIVE: an Armour Plate was packed with a rig that holds none');
       rigCeil=oRig;
       // SIX: room: it fills in wheel order and goes no further
       DEPLOY_SLOTS=3; stage(); kitFill(true);
       DEPLOY_SLOTS=oSlots;
       if(q.kit.length!==3) bad.push('SIX: '+q.kit.length+' items for a pack of 3');
       else if(q.kit.join()!=='medkit,smoke,frag') bad.push('SIX: the short pack reads '+q.kit.join()+', not medkit,smoke,frag');
       // SEVEN: the old names lead here, and the BEST KIT answer is untouched
       srcs=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(srcs.indexOf('if(rand) return kitFill'+'Random();')<0) bad.push('SEVEN: kitFill does not hand RANDOM KIT to the new fill');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ rigCeil=oRig; DEPLOY_SLOTS=oSlots; }catch(_a){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
