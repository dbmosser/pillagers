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

if ($s.Contains("  {v:'26.60',what:")) { throw "check 26.60 is in the fixture already" }

SubRx @'
  {v:'26.59',what:
'@ @'
  {v:'26.60',what:'feel13, his order: the Support MG spins up. Held, it fires nothing for the first 0.15 s, the first gap is long and the gap closes to the gun own 105 ms by 0.75 s; let go and it winds down; a pistol fires at once',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     var bad=[], g, p, all, oWep, oAmmo, oRes, oDown, shots=[], last, i, gap1, gapN, sp;
     function step(n){ for(var q=0;q<n;q++){ g.t+=0.016; __sim(0.016); if(p.lastShot!==last){ last=p.lastShot; shots.push(last); } } }
     function arm(w,a){ mouse.down=false; p.wep=w; p.ammo=a; p.reserve=300; p.reloading=0; p.hand=false; p.jam=0; p.fired=false; p.spin=0; g.t+=0.016; __sim(0.016); for(var q=0;q<260&&p.drawT>0;q++){ g.t+=0.016; __sim(0.016); } p.lastShot=-1e9; p.fired=false; p.spin=0; last=p.lastShot; shots.length=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oDown=mouse.down;
       // ONE: the Support MG, held
       arm(cloneObj(WEAPONS.lmg),60);
       mouse.down=true; step(6);
       if(shots.length) bad.push('ONE: the Support MG fired inside its spin-up delay ('+shots.length+' shots in 0.1 s)');
       step(75);
       if(shots.length<6) bad.push('ONE: the Support MG fired only '+shots.length+' rounds in 1.3 s held');
       else {
         gap1=shots[1]-shots[0]; gapN=shots[shots.length-1]-shots[shots.length-2];
         if(!(gap1>=165)) bad.push('ONE: the first gap is '+Math.round(gap1)+' ms, not a slow wind-up gap (165 or more)');
         if(!(gapN<=135)) bad.push('ONE: the last gap is '+Math.round(gapN)+' ms, not the gun own 105 (135 or less)');
       }
       // TWO: let go and it winds down, so the next burst waits again
       mouse.down=false; step(70); sp=p.spin||0;
       if(sp>0.01) bad.push('TWO: the spin is '+sp.toFixed(2)+' a second after letting go');
       shots.length=0; p.fired=false; p.lastShot=-1e9; last=p.lastShot;
       mouse.down=true; step(6);
       if(shots.length) bad.push('TWO: a second hold after a pause fired at once');
       // THREE: another gun is not slowed
       arm(cloneObj(WEAPONS.pistol),12);
       mouse.down=true; step(3);
       if(!shots.length) bad.push('THREE: a pistol did not fire at once');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.spin=0; p.fired=false; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; if(typeof lmgWhirrStop==='function') lmgWhirrStop(); }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
