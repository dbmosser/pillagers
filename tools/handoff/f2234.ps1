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

if ($s.Contains("  {v:'22.34',what:")) { throw "check 22.34 is in the fixture already" }

SubRx @'
  {v:'22.33',what:
'@ @'
  {v:'22.34',what:'the pad walk over packed guns: with the rifle up, the SMG stowed and a shotgun and a marksman rifle packed on keys 3 and 4, RB from key 2 to key 5 passes keys 3 and 4 without drawing either (the rifle stays up, the SMG stowed, both packed guns in the backpack, a reload in progress kept), the walk stops its highlight on a packed gun, and the trigger on that highlight draws it and fires nothing',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__sim) return 'SKIP: this fixture cannot deploy or step a raid';
     if(typeof beltStep!=='function'||typeof hotbarSlots!=='function'||typeof GUNKEYS==='undefined'||GUNKEYS<4) return 'SKIP: no four gun keys here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!WEAPONS.dmr||!ITEMS.gun_shotgun||!ITEMS.gun_dmr) return 'SKIP: no rifle, smg, shotgun or marksman rifle here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, sl, s0=say, md0=mouse.down, KIT=['gun_shotgun','gun_dmr'], sh0, i, r0;
     function gid(c){ return String((c&&c.icon)||'').replace(/^gun_/,''); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:KIT.slice(),safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) return 'SKIP: staging: did not deploy with the rifle up and the SMG stowed';
       sl=hotbarSlots();
       if(!(gid(sl[2])==='shotgun'&&gid(sl[3])==='dmr'&&!sl[2].equipped&&!sl[3].equipped)) return 'SKIP: staging: keys 3 and 4 do not show the packed shotgun and marksman rifle';
       g.ents.length=0; p.iv=99; p.roll=0; p.downed=false; p.dying=false; g.paused=false; g.bagOpen=false; g.mapOpen=false; keys={};
       say=function(){};
       // the walk: key 2 is the stowed SMG; it is set straight on, so only keys 3, 4 and 5 are walked
       g.hot=1; r0=p.wep.reload||1; p.reloading=r0;
       beltStep(1);
       if(g.hot!==2) bad.push('RB from key 2 went to key '+(g.hot+1)+', not to key 3 with the packed shotgun');
       if(p.wep.id!=='rifle') bad.push('RB onto key 3 drew the '+p.wep.id+' from the backpack');
       if(!(p.reloading>0)) bad.push('RB onto key 3 cancelled the reload of the rifle');
       beltStep(1); beltStep(1);
       if(g.hot!==4) bad.push('RB three times from key 2 ended on key '+(g.hot+1)+', not on Smoke on key 5');
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) bad.push('walking from key 2 to key 5 left the '+(p.wep&&p.wep.id)+' up and the '+(p.sec&&p.sec.id)+' stowed, not the rifle and the SMG he had');
       for(i=0;i<KIT.length;i++) if(g.bag.indexOf(KIT[i])<0) bad.push('walking from key 2 to key 5 took the '+KIT[i]+' out of the backpack');
       beltStep(-1);
       if(g.hot!==3) bad.push('LB from key 5 went to key '+(g.hot+1)+', not to key 4 with the packed marksman rifle');
       if(p.wep.id!=='rifle') bad.push('LB onto key 4 drew the '+p.wep.id);
       // the trigger on the highlighted packed gun draws it and fires nothing
       p.reloading=0; p.fired=false; p.lastShot=-1e9; sh0=p.ammo; p.cooking=false; p.trigYield=false; p.jam=0;
       mouse.down=true; __sim(0.016); mouse.down=false; __sim(0.016);
       if(!(p.wep&&p.wep.id==='dmr')) bad.push('the trigger on the highlighted marksman rifle left the '+(p.wep&&p.wep.id)+' up instead of drawing it');
       else if(p.sec&&p.sec.id==='rifle'&&p.secAmmo!==sh0) bad.push('the trigger press that drew the marksman rifle also fired the rifle ('+sh0+' rounds then '+p.secAmmo+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=s0; mouse.down=md0; keys={};
       try{ var g2=__state(); if(g2){ g2.drag=null; if(g2.player){ g2.player.iv=0; g2.player.downed=false; g2.player.reloading=0; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
