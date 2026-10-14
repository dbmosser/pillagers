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

if ($s.Contains("  {v:'26.67',what:")) { throw "check 26.67 is in the fixture already" }

SubRx @'
  {v:'26.66',what:
'@ @'
  {v:'26.67',what:'feel19, his order: the cursor outer ring widens with movement, sprint and firing and tightens when still or crouched, and the real spread of the rounds follows it (a sprint-and-shoot a third looser, crouched a tenth tighter, standing still exactly as before)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, all, oWep, oAmmo, oSpr, oCr, oMx, oMy, i, w, a0, b, dv, d0, d1, d2, cap=[], proto, oArc, r0, r1, r2, ok0, ok1, ok2;
     function settle(v,n){ for(var q=0;q<n;q++){ p.x+=v*0.016; bloomTick(p,0.016); } return p.bloom; }
     function spread(bl){
       var mx=0, q, ang;
       p.bloom=bl; p.bloomK=0; g.bullets.length=0;
       for(q=0;q<240;q++){ fireWeapon(p,w,p.x+100,p.y,true); b=g.bullets[g.bullets.length-1]; ang=Math.abs(Math.atan2(b.vy,b.vx)); if(ang>mx) mx=ang; g.bullets.length=0; }
       return mx;
     }
     function ringR(bl){
       var q, mr=0;
       p.bloom=bl; p.bloomK=0; p.drawT=0; p.reloading=0; p.ammo=p.wep.mag; mouse.x=W/2; mouse.y=H/2; cap.length=0; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.arc=oArc; }
       for(q=0;q<cap.length;q++) if(cap[q].length>=5&&Math.abs(cap[q][0]-mouse.x)<1.5&&Math.abs(cap[q][1]-mouse.y)<1.5&&cap[q][2]>mr) mr=cap[q][2];
       return mr;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; oWep=p.wep; oAmmo=p.ammo; oSpr=g.sprinting; oCr=g.pCrouch; oMx=mouse.x; oMy=mouse.y;
       w=cloneObj(WEAPONS.pistol); p.wep=w; p.ammo=w.mag; p.ads=false; p.roll=0; p.face=0; p.blmX=undefined; p.bloom=0; p.bloomK=0; g.sprinting=false; g.pCrouch=false;
       // ONE: the bloom follows what you are doing
       if(Math.abs(settle(0,40))>0.03) bad.push('ONE: standing still, the bloom is '+p.bloom.toFixed(2)+', not 0');
       if(!(settle(120,40)>0.3&&p.bloom<0.6)) bad.push('ONE: walking, the bloom is '+p.bloom.toFixed(2)+', not about 0.45');
       g.sprinting=true; if(!(settle(256,40)>0.7)) bad.push('ONE: sprinting, the bloom is '+p.bloom.toFixed(2)+', not about 0.9');
       g.sprinting=false; settle(0,60); g.pCrouch=true;
       if(!(settle(0,60)<-0.15)) bad.push('ONE: crouched and still, the bloom is '+p.bloom.toFixed(2)+', not tighter than standing');
       g.pCrouch=false; settle(0,60);
       for(i=0;i<4;i++) fireWeapon(p,w,p.x+100,p.y,true); g.bullets.length=0;
       for(i=0;i<6;i++) bloomTick(p,0.016);
       if(!(p.bloom>0.1)) bad.push('TWO: four shots left the bloom at '+p.bloom.toFixed(2));
       settle(0,200);
       if(Math.abs(p.bloom)>0.05) bad.push('TWO: the bloom is still '+p.bloom.toFixed(2)+' three seconds after the shots');
       // THREE: the spread follows the ring
       d0=spread(0); d1=spread(0.9); d2=spread(-0.3);
       if(!(d0>0.03)) bad.push('THREE: the pistol spread measured '+d0.toFixed(3));
       else {
         if(!(d1>d0*1.2&&d1<d0*1.45)) bad.push('THREE: at bloom 0.9 the spread is '+(d1/d0).toFixed(2)+' times standing, not about 1.32');
         if(!(d2<d0*0.95&&d2>d0*0.8)) bad.push('THREE: crouched the spread is '+(d2/d0).toFixed(2)+' times standing, not about 0.9');
       }
       // FOUR: the ring on the cursor
       r0=ringR(0); r1=ringR(1); r2=ringR(-0.3);
       if(!(r0>0)) bad.push('FOUR: no outer ring was drawn at the cursor');
       else {
         if(!(r1>r0+5)) bad.push('FOUR: at bloom 1 the ring is '+(r1-r0).toFixed(1)+' px wider than at rest, not 5 or more');
         if(!(r2<r0-1.5)) bad.push('FOUR: crouched the ring is '+(r0-r2).toFixed(1)+' px tighter than at rest, not 1.5 or more');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.bloom=0; p.bloomK=0; p.blmX=undefined; } if(g){ g.sprinting=oSpr; g.pCrouch=oCr; if(all) g.ents=all.slice(); g.bullets.length=0; } if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
