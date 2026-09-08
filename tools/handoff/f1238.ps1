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

# v12.38 CHECK, inserted before the v12.37 entry. Distinctive on purpose: the
# weakest gun in the file in slot 1 and the strongest in slot 2, a pair no
# starter roll, free kit or fallback can produce, and the exact pair the tier
# sort has to reverse. It then reads all three places he would see the loss:
# the two profile slots, the last screen before the lift, and the raid he
# actually deploys into next.
SubRx @'
  {v:'12.37',what:'F already held when the hit lands does not spend the one self-revive: put down with the strike key held he stays on the floor with the revive unspent, letting go and pressing F still stands him up, and a down with nothing held still revives on the first real press (2026-09-07 audit, f-held-revive)',
'@ @'
  {v:'12.38',what:'extracting with a gun in each hand leaves a gun in each hand: banking the better one into gun 1 no longer leaves gun 2 naming the same gun, so the ascent check does not print it twice and the next raid still comes up with a second gun (2026-09-07 audit, gun-slot-reconcile)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(typeof carriedGuns!=='function'||typeof saveProfile!=='function') return 'SKIP: this build does not bank carried guns';
     if(!(WEAPONS&&WEAPONS.pistol&&WEAPONS.sniper&&WTIER&&WTIER.sniper>WTIER.pistol)) return 'SKIP: the Longshot no longer outranks the Scav Pistol, so the tier sort cannot be staged';
     var bad=[], P2=__P(), i;
     var KEYS=['weapons','equipped','equippedSec','wear','stash','kit','kitChosen','dropKit','freeKit','kitBeforeFree','kitSaved','runs','ext','best','credits','kills','log','notExt','notoriety','mapIx'];
     function snap(v){ var o,k; if(v&&v.slice) return v.slice(); if(v&&typeof v==='object'){ o={}; for(k in v) o[k]=v[k]; return o; } return v; }
     var keep={}; for(i=0;i<KEYS.length;i++) keep[KEYS[i]]=snap(P2[KEYS[i]]);
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // DISTINCTIVE ON PURPOSE: the weakest gun in the file in slot 1 and the
       // strongest in slot 2. No starter roll, no free kit and no fallback can
       // produce a Longshot, and the tier sort must reverse this exact pair.
       P2.weapons=['pistol','sniper']; P2.equipped='pistol'; P2.equippedSec='sniper';
       P2.wear={}; P2.freeKit=0; P2.kitSaved=null; P2.kitBeforeFree=null;
       saveProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!p.wep||p.wep.id!=='pistol') bad.push('control: the raid did not start with the Scav Pistol in gun 1 (it holds '+(p.wep&&p.wep.id)+')');
       if(!p.sec||p.sec.id!=='sniper') bad.push('control: the raid did not start with the Longshot in gun 2 (it holds '+(p.sec&&p.sec.id)+')');
       if(p.wepIssued||p.secIssued) bad.push('control: a slot was filled with issued kit, so that gun would never be banked and the sort would not run');
       g.bag=[]; p.downed=false; p.hp=100;
       __endRaid('extract');
       if(P2.weapons.indexOf('pistol')<0||P2.weapons.indexOf('sniper')<0) bad.push('control: the extraction did not leave both guns in the armoury (it holds '+P2.weapons.join(',')+')');
       if(P2.equipped!=='sniper') bad.push('control: the extraction did not promote the Longshot into gun 1 (gun 1 reads '+P2.equipped+'), so the tier sort this check is about did not run');
       if(P2.equippedSec===P2.equipped) bad.push('after extracting with both guns, gun 1 and gun 2 both read '+P2.equipped+', so one gun is in two hands and the Scav Pistol he still owns has been unslotted by a run in which he lost nothing');
       else if(P2.equippedSec!=='pistol') bad.push('gun 2 reads '+P2.equippedSec+' after the extraction, not the Scav Pistol he carried out');
       // WHAT THE LAST SCREEN BEFORE THE LIFT PRINTS.
       if(window.__renderStage&&document.getElementById('stagesum')){
         __topClear();
         try{ __renderStage(); }catch(_rs){ bad.push('the ascent check threw: '+(_rs&&_rs.message||_rs)); }
         var sum=(document.getElementById('stagesum').textContent||'').replace(/\s+/g,' ');
         var nm=WEAPONS.sniper.name, none2='no second '+'gun';
         if(!sum) bad.push('control: the ascent check summary is empty, so what the last screen names cannot be read here');
         else{
           if(sum.split(nm).length-1>1) bad.push('the ascent check names the '+nm+' twice as his loadout ('+sum.slice(0,90)+')');
           if(sum.indexOf(WEAPONS.pistol.name)<0) bad.push('the ascent check does not name the Scav Pistol he carried out ('+sum.slice(0,90)+')');
           if(sum.indexOf(none2)>=0) bad.push('the ascent check says '+none2+' after a run in which he lost no gun ('+sum.slice(0,90)+')');
         }
       }
       // AND THE RAID HE ACTUALLY DEPLOYS INTO NEXT.
       __deploy({kit:[],mapIx:0,seed:4242});
       var g2=__state(), p2=g2.player;
       if(!p2.sec||p2.sec.id==='fists') bad.push('the next raid comes up with nothing in gun 2 after an extraction that lost no gun');
       else if(p2.wep&&p2.sec.id===p2.wep.id) bad.push('the next raid comes up holding two copies of the '+p2.sec.id);
       else if(p2.sec.id!=='pistol') bad.push('the next raid comes up with '+p2.sec.id+' in gun 2, not the Scav Pistol he carried out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; g3.bag=[]; __endRaid('extract'); } }catch(_e){}
       for(i=0;i<KEYS.length;i++) P2[KEYS[i]]=keep[KEYS[i]];
       try{ saveProfile(); }catch(_s2){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.37',what:'F already held when the hit lands does not spend the one self-revive: put down with the strike key held he stays on the floor with the revive unspent, letting go and pressing F still stands him up, and a down with nothing held still revives on the first real press (2026-09-07 audit, f-held-revive)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
