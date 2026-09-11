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

# v12.84 CHECK. It equips a gun out of the backpack three ways and reads the one
# line he is left holding. No clock, no death, so it repeats.
SubRx @'
  {v:'12.83',what:'the seven lines he reads that used a retired word use his word instead: the shop line says Credits, the two seal lines say stage, and the three pack lines and the Peddler blurb say backpack, while every one of those lines still says the thing it is for (found by tools/lint.ps1, 2026-09-09)',
'@ @'
  {v:'12.84',what:'equipping a gun from the backpack says what became of the gun it replaced: an issued loaner says it was left behind and a gun he owns says it went back to the armoury, both surviving the line about what he is now holding, while equipping over an empty hand says exactly what it always said (found by tools/lint.ps1, the v12.73 class in a second place)',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof equipFromBag!=='function') return 'SKIP: this build has no equip from the backpack';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: this raid is a sim, where the equip says nothing';
       var p=g.player, k, gunKey=null, gunId=null, holdId=null;
       for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].gk&&WEAPONS[ITEMS[k].gk]){ gunKey=k; gunId=ITEMS[k].gk; break; } }
       var secId=null;
       for(k in WEAPONS){ if(!WEAPONS[k]||k===gunId||k==='fists'||!WEAPONS[k].mag) continue;
         if(!holdId) holdId=k; else if(!secId){ secId=k; break; } }
       if(!gunKey||!holdId||!secId) return 'SKIP: this build has too few guns to fill both hands for a swap';
       function equip(issued,owned){
         g.bag=[gunKey];
         p.wep=WEAPONS[holdId]; p.ammo=WEAPONS[holdId].mag||0;
         p.wepIssued=!!issued; p.wepFromArmory=!!owned;
         // Both hands full, or the gun routes to the free slot and displaces
         // nothing, which is not the case this check is about.
         p.sec=WEAPONS[secId]; p.secAmmo=WEAPONS[secId].mag||0; p.downed=false; p.roll=0;
         if(owned&&P.weapons.indexOf(holdId)<0) P.weapons.push(holdId);
         g.msg='';
         equipFromBag(0);
         return String(g.msg||'');
       }
       var A=equip(true,false);
       if(A&&A.toLowerCase().indexOf('left behind')<0)
         bad.push('equipping over an issued loaner left him with ['+A+'], so he was never told the loaner is gone for good: the line saying so was written and then written over by the name of the gun he had just chosen, which he already knew');
       var B=equip(false,true);
       if(B&&B.toLowerCase().indexOf('armoury')<0)
         bad.push('equipping over a gun he owns left him with ['+B+'], so he was never told it went back to the armoury rather than into his backpack');
       // CONTROL: an empty hand displaces nothing and must read as it always did.
       g.bag=[gunKey];
       p.wep=WEAPONS.fists; p.ammo=0; p.wepIssued=false; p.wepFromArmory=false;
       p.sec=WEAPONS.fists; p.secAmmo=0; g.msg='';
       equipFromBag(0);
       var C=String(g.msg||'');
       if(C.toLowerCase().indexOf('left behind')>=0||C.toLowerCase().indexOf('armoury')>=0)
         bad.push('control: equipping with nothing in his hands still reports a displaced gun ['+C+'], so the line is printed whether it is true or not');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.83',what:'the seven lines he reads that used a retired word use his word instead: the shop line says Credits, the two seal lines say stage, and the three pack lines and the Peddler blurb say backpack, while every one of those lines still says the thing it is for (found by tools/lint.ps1, 2026-09-09)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
