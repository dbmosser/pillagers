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

if ($s.Contains("  {v:'26.55',what:")) { throw "check 26.55 is in the fixture already" }

SubRx @'
  {v:'26.54',what:
'@ @'
  {v:'26.55',what:'feel10, his order: a heavy round (40 or more) stops the body it hits for a beat, a light round does not, the stop wears off, and the Meridian Lance shoves the player back a step while a pistol does not',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim&&window.__ents&&window.__bullets)) return 'SKIP: no raid here';
     var bad=[], g, p, all, cr, X0, Y0, dx=0, dy=0, ok=false, k, ux, uy, oWep, oAmmo, oFace, i, px, py, back, hp0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); X0=p.x; Y0=p.y; oWep=p.wep; oAmmo=p.ammo; oFace=p.face;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*120,Y0+uy*120,g.map.segs)&&losClear(X0,Y0,X0-ux*90,Y0-uy*90,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line both ways from the drop point';
       cr=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed&&!x.boss; })[0];
       if(!cr) return 'SKIP: no crawler on this map';
       // ONE: a heavy round stops the body
       g.ents=[cr]; cr.x=X0+dx*60; cr.y=Y0+dy*60; cr.hp=cr.maxhp=2000; cr.stopT=0; cr.state='chase'; cr.alert=3; cr.tx=X0; cr.ty=Y0;
       g.bullets.length=0;
       g.bullets.push({x:cr.x,y:cr.y,vx:0.01,vy:0,dmg:16,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0});
       updateBullets(0.001);
       if(cr.hp>=2000) bad.push('ONE: the light round staged did not land');
       if(cr.stopT>0) bad.push('ONE: a 16 damage round stopped the body ('+cr.stopT+')');
       cr.stopT=0; g.bullets.length=0;
       g.bullets.push({x:cr.x,y:cr.y,vx:0.01,vy:0,dmg:62,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0});
       updateBullets(0.001);
       if(!(cr.stopT>0)) bad.push('ONE: a 62 damage round left no hit-stop on the body');
       else {
         px=cr.x; py=cr.y; __ents(0.016); __ents(0.016);
         if(Math.abs(cr.x-px)>0.001||Math.abs(cr.y-py)>0.001) bad.push('ONE: the body moved while it was held ('+(cr.x-px).toFixed(2)+','+(cr.y-py).toFixed(2)+')');
         __ents(0.3);
         if(cr.stopT>0) bad.push('ONE: the hit-stop never wore off ('+cr.stopT+')');
       }
       // a boss is never held
       cr.stopT=0; cr.boss=true; g.bullets.length=0;
       g.bullets.push({x:cr.x,y:cr.y,vx:0.01,vy:0,dmg:62,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0});
       updateBullets(0.001); cr.boss=false;
       if(cr.stopT>0) bad.push('ONE: a boss was held by a hit');
       // TWO: the Lance kicks you back, a pistol does not
       g.ents=[]; g.bullets.length=0; cr.stopT=0;
       p.wep=cloneObj(WEAPONS.lance); p.ammo=3; p.x=X0; p.y=Y0; p.kickT=0;
       fireWeapon(p,p.wep,p.x+dx*100,p.y+dy*100,true);
       for(i=0;i<12;i++) __sim(0.016);
       back=(p.x-X0)*dx+(p.y-Y0)*dy;
       if(!(back<-10&&back>-45)) bad.push('TWO: after a Lance shot the player moved '+back.toFixed(1)+' along the shot, not back 10 to 45');
       g.bullets.length=0; p.wep=cloneObj(WEAPONS.pistol); p.ammo=8; p.x=X0; p.y=Y0; p.kickT=0;
       fireWeapon(p,p.wep,p.x+dx*100,p.y+dy*100,true);
       for(i=0;i<12;i++) __sim(0.016);
       back=(p.x-X0)*dx+(p.y-Y0)*dy;
       if(Math.abs(back)>2) bad.push('TWO: a pistol shot moved the player '+back.toFixed(1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.wep=oWep; p.ammo=oAmmo; p.face=oFace; p.kickT=0; } if(g&&all) g.ents=all.slice(); if(g) g.bullets.length=0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
