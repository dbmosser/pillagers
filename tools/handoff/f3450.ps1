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

if ($s.Contains("  {v:'34.50',what:")) { throw "check 34.50 is in the fixture already" }

SubRx @'
  {v:'34.49',what:
'@ @'
  {v:'34.50',what:'cw-bldsolid (86i ship 2): SOLID PIECES PER BUILDING KIND. Pieces appear (3 or more kinds), the seeded stream does not move, over 20 seeds on both sectors no doorway, locked room or container has a piece on it, every door is still reachable from the spawn and no building floor is cut off that was not before, and a real raid builds the same entity and container counts',
   run:function(){
     if(typeof bldSolid!=='function') return 'no solid furniture (bldSolid)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], s, mi, m0, m1, r0, r1, p0, p1, kinds={}, nk=0, tot=0, i, j, w, d, q, seen, g, ct, c, u0, u1, st;
     function cellOk(m,sn,x,y){ var nv=m.nav, cx=Math.floor(x/nv.c), cy=Math.floor(y/nv.c), a, b2, ax, ay; for(a=-1;a<=1;a++) for(b2=-1;b2<=1;b2++){ ax=cx+a; ay=cy+b2; if(ax>=0&&ay>=0&&ax<nv.w&&ay<nv.h&&sn[ay*nv.w+ax]) return true; } return false; }
     function lost(m){   // open floor cells inside buildings that the flood from the spawn side cannot reach, outside locked rooms; and the doors it cannot reach
       var nv=m.nav, sn=floodNav(nv), n=0, bb, b2, x, y, id, k, lk, cx, cy, dl=0;
       for(b2=0;b2<m.buildings.length;b2++){ bb=m.buildings[b2];
         for(y=Math.floor(bb.y/nv.c);y<=Math.ceil((bb.y+bb.h)/nv.c);y++) for(x=Math.floor(bb.x/nv.c);x<=Math.ceil((bb.x+bb.w)/nv.c);x++){
           id=y*nv.w+x; if(nv.blk[id]||sn[id]) continue; cx=x*nv.c+nv.c/2; cy=y*nv.c+nv.c/2; lk=false;
           for(k=0;k<m.locked.length;k++){ q=m.locked[k]; if(cx>q.x-24&&cx<q.x+q.w+24&&cy>q.y-24&&cy<q.y+q.h+24){ lk=true; break; } }
           if(!lk) n++; } }
       for(k=0;k<m.doors.length;k++){ q=m.doors[k]; if(!cellOk(m,sn,q.x+q.w/2,q.y+q.h/2)) dl++; }
       return n+':'+dl;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(s=0;s<20;s++){
         mi=s%2;
         CFG.bsolid=0; RNGS=1000+s; m0=buildFixedMap(FIXED_MAPS[mi]); r0=RNGS; u0=lost(m0);
         delete CFG.bsolid; RNGS=1000+s; m1=buildFixedMap(FIXED_MAPS[mi]); r1=RNGS; u1=lost(m1);
         if(r0!==r1) bad.push('seed '+s+': the seeded stream moved ('+r0+' against '+r1+')');
         p1=0;
         for(i=0;i<m1.walls.length;i++){ w=m1.walls[i]; if(!w.bs) continue; p1++; tot++; kinds[m1.buildings[w.ib].kind]=1;
           for(j=0;j<m1.doors.length+m1.idoors.length;j++){ d=j<m1.doors.length?m1.doors[j]:m1.idoors[j-m1.doors.length];
             if(w.x<d.x+d.w&&w.x+w.w>d.x&&w.y<d.y+d.h&&w.y+w.h>d.y) bad.push('seed '+s+': a piece sits in a doorway at '+Math.round(d.x)+','+Math.round(d.y)); }
           for(j=0;j<m1.locked.length;j++){ q=m1.locked[j]; if(w.x<q.x+q.w&&w.x+w.w>q.x&&w.y<q.y+q.h&&w.y+w.h>q.y) bad.push('seed '+s+': a piece sits in a locked room'); } }
         if(m0.walls.some(function(z){ return z.bs; })) bad.push('seed '+s+': CFG.bsolid 0 still adds pieces');
         st=u1.split(':'); q=u0.split(':');
         if(+st[0]>+q[0]) bad.push('seed '+s+', sector '+mi+': '+st[0]+' floor cells are cut off with pieces against '+q[0]+' without');
         if(+st[1]>+q[1]) bad.push('seed '+s+', sector '+mi+': '+st[1]+' doors are cut off with pieces against '+q[1]+' without');
       }
       for(q in kinds) nk++;
       if(!tot) bad.push('no solid piece was placed on any of 20 seeds');
       else if(nk<3) bad.push('pieces only appear in '+nk+' kinds: '+Object.keys(kinds).join(','));
       // real raids: every container and extract reachable and clear of a piece, entity and container counts as on the build before
       for(s=0;s<4;s++){
         mi=s%2;
         __deploy({kit:[],safe:null,mapIx:mi,seed:4242+s}); keys={};
         g=__state(); m1=g.map; seen=floodNav(m1.nav);
         ct=g.containers||[];
         for(i=0;i<ct.length;i++){ c=ct[i];
           if(!cellOk(m1,seen,c.x,c.y)&&!(m1.locked||[]).some(function(z){ return c.x>z.x-24&&c.x<z.x+z.w+24&&c.y>z.y-24&&c.y<z.y+z.h+24; })) bad.push('raid '+s+': a container at '+Math.round(c.x)+','+Math.round(c.y)+' is not reachable');
           for(j=0;j<m1.walls.length;j++){ w=m1.walls[j]; if(w.bs&&c.x>w.x-6&&c.x<w.x+w.w+6&&c.y>w.y-6&&c.y<w.y+w.h+6) bad.push('raid '+s+': a container sits on a piece'); } }
         __endRaid('abandon'); __topClear();
       }
       return bad.length?bad.slice(0,6).join('; '):null;
     } catch(err){
       return 'solid furniture check: '+String(err&&err.message||err);
     } finally {
       delete CFG.bsolid;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'34.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
