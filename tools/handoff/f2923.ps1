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

if ($s.Contains("  {v:'29.23',what:")) { throw "check 29.23 is in the fixture already" }

SubRx @'
  {v:'29.22',what:
'@ @'
  {v:'29.23',what:'the Support MG gets about 30 percent wider the longer it fires without a break, the ring opens with it, and it is back to normal about a second after the trigger is let go (his order: lmg should get marginally less accurate the longer player fires it continuously)',
   run:function(){
     if(typeof lmgHeatMul!=='function') return 'the Support MG has no heat (no lmgHeatMul)';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid or frame here';
     var bad=[], g=null, p=null, all, oWep, oAmmo, w, i, early, late, iso, ringE, ringL, h, rel;
     function wait(sec){ var q, n=Math.round(sec/0.016); for(q=0;q<n;q++) bloomTick(p,0.016); }
     function spreadNow(wp){
       var mx=0, q, bb, ang;
       g.bullets.length=0;
       for(q=0;q<150;q++){ fireWeapon(p,wp,p.x+100,p.y,true); bb=g.bullets[g.bullets.length-1]; ang=Math.abs(Math.atan2(bb.vy,bb.vx)); if(ang>mx) mx=ang; g.bullets.length=0; }
       p.bloomPend=0; if(g.throws) g.throws.length=0;
       return mx;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; p.iv=99;
       w=cloneObj(WEAPONS.lmg); p.wep=w; p.ammo=w.mag;
       p.bloom=0; p.bloomK=0; p.bloomPend=0; p.bloomQ=9; p.blmX=undefined; p.ads=false; p.roll=0; g.sprinting=false; g.pCrouch=false; p.lmgHeat=0;
       for(i=0;i<50;i++){
         p.ammo=w.mag; wait(0.02);
         if(i===10){ early=spreadNow(w); ringE=bloomPx(p); }
         if(i===48){ late=spreadNow(w); ringL=bloomPx(p); h=p.lmgHeat; iso=null; }
         fireWeapon(p,w,p.x+100,p.y,true); g.bullets.length=0; wait(0.08);
       }
       if(!(h>=4.4&&h<=4.51)) bad.push('after 4.8 s of unbroken fire the heat is '+h+', not capped at 4.5');
       if(!(late>=early*1.3)) bad.push('the late spread is only '+(late/early).toFixed(2)+' times the 1 s spread, not 1.3 or more');
       if(!(late<=early*2.6)) bad.push('the late spread is '+(late/early).toFixed(2)+' times the 1 s spread, not 2.6 or less');
       if(!(ringL>ringE+0.5)) bad.push('the ring did not open from 1 s to 4.8 s ('+ringE.toFixed(1)+' to '+ringL.toFixed(1)+' px)');
       p.lmgHeat=4.5; iso=spreadNow(w); rel=p.lmgHeat; p.lmgHeat=0; var cool=spreadNow(w);
       if(!(iso>=cool*1.2&&iso<=cool*1.45)) bad.push('full heat is '+(iso/cool).toFixed(2)+' times a cold gun, not 1.2 to 1.45');
       p.lmgHeat=4.5; p.bloomQ=0.3; wait(0.3); if(!(p.lmgHeat<=3.3)) bad.push('0.3 s after the unbroken-fire grace the heat is still '+p.lmgHeat.toFixed(2)+', it cools too slowly');
       wait(0.8); if(p.lmgHeat!==0) bad.push('1.1 s after the unbroken-fire grace the heat is still '+p.lmgHeat.toFixed(2));
       w=cloneObj(WEAPONS.rifle); p.wep=w; p.lmgHeat=4.5; if(lmgHeatMul(p,w)!==1) bad.push('an Auto Rifle is affected by the Support MG heat');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.bloom=0; p.bloomK=0; p.bloomPend=0; p.lmgHeat=0; p.blmX=undefined; } if(g){ if(all) g.ents=all.slice(); g.bullets.length=0; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'29.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
