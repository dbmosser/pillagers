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

# v12.42 CHECK, inserted before the v12.41 entry. It measures a CONSERVED
# QUANTITY, loaded plus reserve, rather than a level, because a level could be
# calibrated on the bug itself. Forty seven rounds in a sixty round magazine
# with an empty reserve: 47 is a number no roll, no pickup and no half magazine
# can produce, and half of sixty is thirty, so a conjured magazine cannot be
# mistaken for the real load. The empty arm is the faucet running the other
# way. The control keeps his own rule for a gun found in the field.
SubRx @'
  {v:'12.41',what:'the key on an empty throwable cell spends nothing from another cell: it names what is missing and puts the gun up instead of quietly walking the hidden selector on and throwing the grenade you did have, on the derived cell, the assigned cell and the cook alike, while a cell that does hold one still throws it (closes the not-verified line on v12.08)',
'@ @'
  {v:'12.42',what:'a gun that goes through the backpack keeps its magazine: loaded plus reserve is conserved across a stow and an equip, on a full gun and on an empty one, so stowing no longer throws the load away and re-equipping no longer conjures half a magazine, while a gun found in the field still arrives on half a magazine (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof bagHeldGun!=='function'||typeof equipFromBag!=='function') return 'SKIP: this build cannot bag and re-equip a gun';
     if(!(WEAPONS&&WEAPONS.lmg&&WEAPONS.lmg.mag===60&&ITEMS&&ITEMS.gun_lmg&&ITEMS.gun_dmr&&WEAPONS.dmr)) return 'SKIP: the Support MG is no longer a sixty round gun, so this staging cannot be built';
     var bad=[];
     // The rounds are conserved across four places, not three: loaded, stowed on
     // the other gun, in the reserve, and riding with a gun in the backpack.
     function total(p){
       var t=(p.ammo|0)+(p.secAmmo|0)+(p.reserve|0), g=__state(), k, q, j;
       if(g&&g.stowAmmo) for(k in g.stowAmmo){ q=g.stowAmmo[k];
         if(q&&q.length) for(j=0;j<q.length;j++) t+=(q[j]|0); }
       return t;
     }
     function arm(loaded){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player, w={},k;
       for(k in WEAPONS.lmg) w[k]=WEAPONS.lmg[k];
       p.downed=false; p.roll=0; g.over=false; g.paused=false;
       p.wep=w; p.ammo=loaded; p.wepIssued=false; p.wepFromArmory=false; p.swapped=false;
       p.sec=WEAPONS.fists; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false;
       p.reserve=0; g.bag=[]; g.stowAmmo=null;
       var t0=total(p);
       if(!bagHeldGun('gunA')) return {skip:'the Support MG would not go into the backpack'};
       var ix=g.bag.indexOf('gun_lmg');
       if(ix<0) return {skip:'the Support MG did not arrive in the backpack'};
       var t1=total(p);
       if(!equipFromBag(ix,1)) return {skip:'the Support MG would not come back out of the backpack'};
       return {t0:t0,t1:t1,t2:total(p),ammo:(p.ammo|0),res:(p.reserve|0)};
     }
     try{
       // THE FINDING, full: forty seven loaded, nothing in reserve.
       var A=arm(47);
       if(!A) return 'SKIP: no live raid to stage a gun in';
       if(A.skip) return 'SKIP: '+A.skip;
       if(A.t1!==A.t0) bad.push('putting a gun in the backpack threw its magazine away: the rounds he owns went from '+A.t0+' to '+A.t1+', so '+(A.t0-A.t1)+' of them stopped existing while the gun sat in the backpack');
       if(A.t2!==A.t0) bad.push('a gun through the backpack came back with a different amount of ammunition than it went in with: loaded plus reserve went from '+A.t0+' to '+A.t2);
       if(A.ammo!==47) bad.push('the Support MG came back out of the backpack on '+A.ammo+' rounds, not the 47 it went in with');
       // THE FINDING, the other way: an EMPTY gun, which is the faucet.
       var B=arm(0);
       if(B.skip) return 'SKIP: '+B.skip;
       if(B.t2!==0) bad.push('an empty gun through the backpack came back with '+B.t2+' rounds that no reserve paid for, and the trip can be repeated as often as he likes');
       // CONTROL: HIS RULE FOR A GUN FOUND IN THE FIELD IS UNTOUCHED. A key that
       // was never stowed has no load to remember, so it still arrives on half a
       // magazine; without this a fix that simply handed out nothing reads green.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g2=__state(), p2=g2.player;
       p2.downed=false; p2.roll=0; g2.over=false; g2.paused=false;
       p2.wep=WEAPONS.fists; p2.ammo=0; p2.wepIssued=false; p2.wepFromArmory=false; p2.swapped=false;
       p2.sec=WEAPONS.fists; p2.secAmmo=0; p2.secIssued=true; p2.secFromArmory=false;
       p2.reserve=0; g2.bag=['gun_dmr']; g2.stowAmmo=null;
       var want=Math.ceil(WEAPONS.dmr.mag/2);
       if(!equipFromBag(0,1)) bad.push('control: a gun found in the field would not come out of the backpack at all');
       else if((p2.ammo|0)!==want) bad.push('control: a Marksman Rifle found in the field came up on '+(p2.ammo|0)+' rounds, not the half magazine of '+want+' that is his rule for a find');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ gz.stowAmmo=null; if(gz.bag) gz.bag.length=0; } }catch(_e){}
       try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; __endRaid('abandon'); } }catch(_e2){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.41',what:'the key on an empty throwable cell spends nothing from another cell: it names what is missing and puts the gun up instead of quietly walking the hidden selector on and throwing the grenade you did have, on the derived cell, the assigned cell and the cook alike, while a cell that does hold one still throws it (closes the not-verified line on v12.08)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
