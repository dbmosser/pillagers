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

if ($s.Contains("  {v:'29.18',what:")) { throw "check 29.18 is in the fixture already" }

SubRx @'
  {v:'29.17',what:
'@ @'
  {v:'29.18',what:'the Rocket Launcher: a slow rocket (a blast where it ends), 2 to a load, 30 of the ammo pool a rocket, on class key 0, with a loot source and its own icon and HUD count (his order 2026-10-18)',
   run:function(){
     if(typeof rlHave!=='function'||typeof rktCost!=='function'||typeof rsvShow!=='function'||!WEAPONS.rocket) return 'no Rocket Launcher: no rocket gun, no 30 ammo a rocket';
     var g=null, bad=[], p, w=WEAPONS.rocket, e, f=null, i, hp0, bl, sp, ff;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player;
       if(w.mag!==2) bad.push('mag '+w.mag+' (want 2 rockets a load)');
       if(rktCost(w)!==30||rktCost(WEAPONS.pistol)!==1) bad.push('cost '+rktCost(w)+' / '+rktCost(WEAPONS.pistol));
       p.wep=w; p.ammo=0; p.reserve=29; if(rlHave(p)) bad.push('29 in the pool can load a rocket');
       p.reserve=30; if(!rlHave(p)) bad.push('30 in the pool cannot load a rocket');
       p.reserve=100; p.ammo=0; p.reloading=1; tickReload(0.1);
       if(p.ammo!==2||p.reserve!==40) bad.push('a reload from 100 left '+p.ammo+' loaded, '+p.reserve+' in the pool (want 2 and 40)');
       p.reserve=59; p.ammo=0; p.reloading=1; tickReload(0.1);
       if(p.ammo!==1||p.reserve!==29) bad.push('a reload from 59 left '+p.ammo+' loaded, '+p.reserve+' in the pool (want 1 and 29)');
       p.reserve=100; if(rsvShow(p)!==3) bad.push('the HUD count is '+rsvShow(p)+' (want 3 rockets from 100)');
       p.wep=WEAPONS.pistol; p.ammo=0; p.reserve=5; p.reloading=1; tickReload(0.1);
       if(p.ammo!==5||p.reserve!==0) bad.push('a pistol reload changed: '+p.ammo+' / '+p.reserve);
       // the round
       p.wep=w; p.ammo=2; g.bullets.length=0;
       fireWeapon(p,w,p.x+100,p.y,true);
       bl=g.bullets[g.bullets.length-1];
       sp=bl?Math.hypot(bl.vx,bl.vy):0;
       if(!bl||!bl.rkt) bad.push('the shot is not a rocket');
       else if(!(sp>200&&sp<700)) bad.push('the rocket speed is '+Math.round(sp)+' (want slow, under 700)');
       // the blast: a rocket that ends 100 units short of a body still hurts it
       g.bullets.length=0;
       for(i=0;i<g.ents.length;i++){ ff=g.ents[i]; if(ff.merc||ff.finished||ff.downed||!(ff.hp>0)) continue; if(!losClear(ff.x-100,ff.y,ff.x,ff.y,g.map.segs)) continue; f=ff; break; }
       if(!f) return 'SKIP: no clear target';
       hp0=f.hp;
       g.bullets.push({sx:f.x-100,sy:f.y,mzd:0,x:f.x-100,y:f.y,vx:RKT_SPD,vy:0,dmg:w.dmg,life:0.01,player:true,owner:p,tint:'#ffb070',el:'',rkt:1,_pen:99,thru:0,gid:'rocket'});
       for(i=0;i<3&&g.bullets.length;i++) updateBullets(1/60);
       if(g.bullets.length) bad.push('the rocket is still flying');
       if(!(f.hp<hp0)) bad.push('the blast 100 units off did nothing to the body ('+hp0+' to '+f.hp+')');
       if(!(ITEMS.gun_rocket&&ITEMS.gun_rocket.gk==='rocket')) bad.push('no gun_rocket item');
       if(gunClassOf('rocket')!=='rocket'||gunClassKey('rocket')!==8) bad.push('the rocket is not on class key 0');
       if(WIRT_LOT_POOL.join('|').indexOf('gun_rocket')<0) bad.push('no loot source: not in the Wirt lot');
       if(GUN_CLASS_ICON.rocket!=='gun_rocket'||!GUNDEF.rocket) bad.push('no icon or drawn gun');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
