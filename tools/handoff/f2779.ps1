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

if ($s.Contains("  {v:'27.79',what:")) { throw "check 27.79 is in the fixture already" }

SubRx @'
  {v:'27.78',what:
'@ @'
  {v:'27.79',what:'feel2a, his yes to the Halo Reach bloom: every gun blooms its own way. Spamming the Marksman Rifle or the pistol opens the spread to over twice the first round, a beat of patience gives the pinpoint round back, a held Auto Rifle fills over about two seconds, every gun in the table opens a little, and the cursor ring grows with it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, all, oWep, oAmmo, w, ids, i, a, b, c, ps, rr, id;
     function wipe(){ p.bloom=0; p.bloomK=0; p.bloomPend=0; p.bloomQ=9; p.blmX=undefined; p.ads=false; p.roll=0; g.sprinting=false; g.pCrouch=false; }
     function spreadNow(wp){
       var mx=0, q, bb, ang;
       g.bullets.length=0;
       for(q=0;q<150;q++){ fireWeapon(p,wp,p.x+100,p.y,true); bb=g.bullets[g.bullets.length-1]; ang=Math.abs(Math.atan2(bb.vy,bb.vx)); if(ang>mx) mx=ang; g.bullets.length=0; }
       p.bloomPend=0; if(g.throws) g.throws.length=0;
       return mx;
     }
     function wait(sec){ var q, n=Math.round(sec/0.016); for(q=0;q<n;q++) bloomTick(p,0.016); }
     function volley(wp,gap,n){
       var out=[], q;
       wipe();
       for(q=0;q<n;q++){ wait(0.02); out.push(spreadNow(wp)); fireWeapon(p,wp,p.x+100,p.y,true); g.bullets.length=0; wait(gap); }
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; p.iv=99;
       // ONE: spamming the Marksman Rifle opens the spread, patience closes it
       w=cloneObj(WEAPONS.dmr); p.wep=w; p.ammo=w.mag;
       a=volley(w,0.68,4); b=volley(w,1.3,4);
       if(!(a[0]>0.005)) bad.push('ONE: the first Marksman round measured '+a[0].toFixed(4));
       else {
         if(!(a[3]>=a[0]*2)) bad.push('ONE: the 4th round of a spammed Marksman Rifle has '+(a[3]/a[0]).toFixed(2)+' times the first round spread, not 2 or more');
         if(!(b[3]<=b[0]*1.2)) bad.push('ONE: a Marksman Rifle paced at 1.3 s has '+(b[3]/b[0]).toFixed(2)+' times the first round spread on its 4th, not 1.2 or less');
       }
       // TWO: the pistol, the same
       w=cloneObj(WEAPONS.pistol); p.wep=w; p.ammo=w.mag;
       a=volley(w,0.29,4); b=volley(w,0.7,4);
       if(!(a[3]>=a[0]*1.6)) bad.push('TWO: the 4th round of a spammed pistol has '+(a[3]/a[0]).toFixed(2)+' times the first round spread, not 1.6 or more');
       if(!(b[3]<=b[0]*1.2)) bad.push('TWO: a pistol paced at 0.7 s has '+(b[3]/b[0]).toFixed(2)+' times the first round spread on its 4th, not 1.2 or less');
       // THREE: a held Auto Rifle fills over a couple of seconds and drains when you let go
       w=cloneObj(WEAPONS.rifle); p.wep=w; p.ammo=w.mag;
       a=volley(w,0.132,19);
       if(!(a[18]>=a[0]*1.5)) bad.push('THREE: the 19th round of a held Auto Rifle has '+(a[18]/a[0]).toFixed(2)+' times the first round spread, not 1.5 or more');
       wait(3); c=spreadNow(w);
       if(!(c<=a[0]*1.15)) bad.push('THREE: three seconds after the burst the Auto Rifle spread is still '+(c/a[0]).toFixed(2)+' times the first round');
       // FOUR: every gun opens a little and the ring follows
       ids=['pistol','magnum','dmr','sniper','carbine','shotgun','whisper','lance','smg','rifle','lmg'];
       for(i=0;i<ids.length;i++){
         id=ids[i]; if(!WEAPONS[id]) continue;
         w=cloneObj(WEAPONS[id]); p.wep=w; p.ammo=w.mag;
         a=volley(w,0.1,3);
         if(!(a[2]>=a[0]*1.04)) bad.push('FOUR: '+id+' does not open under fire ('+(a[2]/a[0]).toFixed(2)+' times)');
       }
       w=cloneObj(WEAPONS.pistol); p.wep=w; p.ammo=w.mag; wipe(); wait(0.1); ps=bloomPx(p);
       for(i=0;i<6;i++){ fireWeapon(p,w,p.x+100,p.y,true); g.bullets.length=0; wait(0.29); }
       rr=bloomPx(p);
       if(!(rr>=ps+10)) bad.push('FOUR: six pistol rounds grew the cursor ring by '+(rr-ps).toFixed(1)+' px, not 10 or more');
       wait(3); rr=bloomPx(p);
       if(!(rr<=ps+2)) bad.push('FOUR: three seconds later the cursor ring is still '+(rr-ps).toFixed(1)+' px wide');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.bloom=0; p.bloomK=0; p.bloomPend=0; p.blmX=undefined; } if(g){ if(all) g.ents=all.slice(); g.bullets.length=0; g.sprinting=false; g.pCrouch=false; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
