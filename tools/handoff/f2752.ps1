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

if ($s.Contains("  {v:'27.52',what:")) { throw "check 27.52 is in the fixture already" }

SubRx @'
  {v:'27.51',what:
'@ @'
  {v:'27.52',what:'feel2d, his words: the Support MG needs a higher fire rate once fully spinning. Held, the gap between rounds keeps closing past the gun own 105 ms to about 81 ms (1.3 times the rate), the report rises in pitch with the rate, and it drops back when the trigger is released; other guns are untouched',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)) return 'SKIP: no raid here';
     var bad=[], g, p, all, oWep, oAmmo, oRes, oDown, shots=[], last, i, sum, pitches=[], realBlip, p0, p1, m0, m1;
     function step(n){ for(var q=0;q<n;q++){ g.t+=0.016; __sim(0.016); if(p.lastShot!==last){ last=p.lastShot; shots.push(last); } } }
     function arm(w,a){ mouse.down=false; p.wep=w; p.ammo=a; p.reserve=300; p.reloading=0; p.hand=false; p.jam=0; p.fired=false; p.spin=0; g.t+=0.016; __sim(0.016); for(var q=0;q<260&&p.drawT>0;q++){ g.t+=0.016; __sim(0.016); } p.lastShot=-1e9; p.fired=false; p.spin=0; last=p.lastShot; shots.length=0; pitches.length=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oRes=p.reserve; oDown=mouse.down;
       realBlip=blipMine; blipMine=function(type){ if(type==='shot') pitches.push((typeof SND_PITCH==='undefined')?1:SND_PITCH); };
       // ONE: the Support MG, held for two seconds: the rate at full spin is well above the gun own
       arm(cloneObj(WEAPONS.lmg),60); p.iv=99;
       mouse.down=true; step(125);
       if(shots.length<12) bad.push('ONE: the Support MG fired only '+shots.length+' rounds in 2 s held');
       else {
         sum=0; for(i=shots.length-8;i<shots.length;i++) sum+=shots[i]-shots[i-1];
         sum/=8;
         if(!(sum<=100)) bad.push('ONE: at full spin the gap is '+Math.round(sum)+' ms, not 100 or less (the gun own gap is 105)');
         if(!(sum>=64)) bad.push('ONE: at full spin the gap is '+Math.round(sum)+' ms, faster than 1.3 times the rate allows');
       }
       // TWO: the report rises with the rate
       p0=pitches.length?pitches[0]:null; p1=pitches.length?pitches[pitches.length-1]:null;
       if(pitches.length<12) bad.push('TWO: only '+pitches.length+' shot voices were played');
       else {
         if(!(p1>=1.06)) bad.push('TWO: the report at full spin is at pitch '+(+p1).toFixed(2)+', not 1.06 or more');
         if(!(p0<=0.92)) bad.push('TWO: the first report is at pitch '+(+p0).toFixed(2)+', not 0.92 or less');
       }
       // THREE: let go and the rate drops back
       m1=spinMul(p);
       mouse.down=false; step(70);
       m0=spinMul(p);
       if(!(m1<=0.85)) bad.push('THREE: at full spin the gap multiplier is '+m1.toFixed(2)+', not 0.85 or less');
       if(!(m0>=1.2)) bad.push('THREE: a second after letting go the gap multiplier is '+m0.toFixed(2)+', not 1.2 or more');
       // FOUR: another gun is not touched
       arm(cloneObj(WEAPONS.rifle),25); mouse.down=true; step(40);
       if(Math.abs(spinMul(p)-1)>0.001) bad.push('FOUR: the Auto Rifle has a spin multiplier of '+spinMul(p).toFixed(2));
       if(pitches.length&&pitches.some(function(x){ return Math.abs(x-1)>0.001; })) bad.push('FOUR: the Auto Rifle report is at a pitch other than 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realBlip) blipMine=realBlip; mouse.down=false; if(p){ p.wep=oWep; p.ammo=oAmmo; p.reserve=oRes; p.spin=0; p.fired=false; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; if(typeof lmgWhirrStop==='function') lmgWhirrStop(); }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
