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

if ($s.Contains("  {v:'22.49',what:")) { throw "check 22.49 is in the fixture already" }

SubRx @'
  {v:'22.48',what:
'@ @'
  {v:'22.49',what:'the freebie kit pistol in the backpack never becomes gun 1 at an extraction (from the review of build 4): on the freebie kit with a field shotgun in the other hand, a Compact SMG drawn from the backpack puts the kit pistol in the backpack on key 1, and after the extraction neither gun slot names the kit pistol (v15.58)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot start a raid, end it and restore the profile';
     if(typeof commitKit!=='function'||typeof drawGun!=='function'||typeof hotbarSlots!=='function'||typeof FREEKIT_GUN==='undefined'||!WEAPONS[FREEKIT_GUN]||!WEAPONS.rifle||!WEAPONS.shotgun||!WEAPONS.smg||!ITEMS.gun_smg||!ITEMS['gun_'+FREEKIT_GUN]) return 'SKIP: no freebie kit, drawGun or the guns this check stages in this build';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], snap=null, g, p, q, sl, ix, PG='gun_'+FREEKIT_GUN;
     function gid(c){ return (c&&c.kind==='gun'&&!c.vacant)?String(c.icon||'').replace(/^gun_/,''):''; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       q=__P();
       q.autoExport=false;
       q.weapons=['rifle']; q.equipped='rifle'; q.equippedSec='none';
       q.stash=[]; q.kit=[]; q.hotAssign={}; q.safe=null; q.dropKit=[]; q.kitChosen=0; q.devKit=0;
       q.kitSaved=null; q.kitBeforeFree=null; q.hotBeforeFree=null; q.gunBeforeFree=null; q.freeKit=1;
       saveProfile();
       commitKit();
       __startRaid({mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||g.over||!p) return 'SKIP: no live raid';
       if(g.freeKit!==1||!p.wep||p.wep.id!==FREEKIT_GUN||p.wepIssued||p.wepFromArmory) return 'SKIP: staging: the raid did not go up on the freebie kit with its own pistol in hand';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false; g.drag=null; keys={};
       // A field shotgun in the Bare Hands slot, and a Compact SMG found into the backpack.
       p.sec=WEAPONS.shotgun; p.secAmmo=WEAPONS.shotgun.mag; p.secIssued=false; p.secFromArmory=false;
       g.bag.push('gun_smg'); ix=g.bag.lastIndexOf('gun_smg');
       if(!drawGun(ix)) return 'SKIP: staging: the SMG could not be drawn from the backpack';
       sl=hotbarSlots();
       if(!(p.wep&&p.wep.id==='smg'&&g.bag.indexOf(PG)>=0&&gid(sl[0])===FREEKIT_GUN&&!sl[0].inHand)) return 'SKIP: staging: drawing the SMG did not leave the kit pistol in the backpack on key 1 (in hand '+(p.wep&&p.wep.id)+', key 1 '+gid(sl[0])+')';
       p.downed=false; p.hp=100;
       __endRaid('extract');
       q=__P();
       if(g.over!=='extract') return 'SKIP: the raid did not end as an extraction';
       if(q.equipped===FREEKIT_GUN) bad.push('the freebie kit pistol, carried out in the backpack on key 1, became gun 1 at home, so the next raid goes up with it (v15.58 says the kit never changes the gun he goes up with)');
       if(q.equippedSec===FREEKIT_GUN) bad.push('the freebie kit pistol, carried out in the backpack, became gun 2 at home');
       if((q.weapons||[]).indexOf('smg')<0||(q.weapons||[]).indexOf('shotgun')<0) bad.push('control: the SMG and the shotgun he carried out did not both reach the armoury ('+(q.weapons||[]).join(',')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
