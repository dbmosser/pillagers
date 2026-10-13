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

if ($s.Contains("  {v:'25.45',what:")) { throw "check 25.45 is in the fixture already" }

SubRx @'
  {v:'25.44',what:
'@ @'
  {v:'25.45',what:'forge6: an acid round eats a Breacher Plate before it soaks and the corroded plate stops half, and a machine takes 1.25 times an acid round',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof elemHit!=='function'||typeof updateBullets!=='function') return 'SKIP: no raid or elemental rounds here';
     if(typeof elemShred!=='function'||typeof elemAbsorb!=='function') return 'no acid (elemShred, elemAbsorb)';
     var bad=[], g, p, all=null, oPX, oPY, rd, se, X0, Y0, dx=1, dy=0, k, ok=false, oW={}, h0, l1, l2, want;
     function shoot(e,el){
       g.ents=[e]; e.x=X0; e.y=Y0; e.face=Math.atan2(dy,dx); e.roll=0; e.rollCd=9;
       g.bullets.length=0;
       g.bullets.push({x:X0+dx*6,y:Y0+dy*6,vx:-dx*1180,vy:-dy*1180,dmg:30,life:0.5,player:true,owner:p,tint:'#ffffff',el:el||'',thru:0});
       updateBullets(0.001);
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); oPX=p.x; oPY=p.y; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ var ux=Math.cos(k*0.7854), uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*180,Y0+uy*180,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       p.x=X0-dx*200; p.y=Y0-dy*200;
       ['raider','sentry'].forEach(function(kd){ oW[kd]=WEAKPTS[kd]; WEAKPTS[kd]=null; });
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed; })[0];
       if(rd){
         rd.hp=rd.maxhp=2000; rd.hostile=true; rd.rig='heavy'; rd.armor=120; rd.corrT=0;
         shoot(rd,'acid');
         want=120-18; want-=Math.min(want,30*0.66*0.5);
         if(Math.abs(rd.armor-want)>0.05) bad.push('a Breacher Plate hit by an acid 30 has '+rd.armor.toFixed(2)+' armour, want '+want.toFixed(2));
         if(!(rd.corrT>0)) bad.push('the acid round did not corrode the plate');
         if(Math.abs((2000-rd.hp)-(30-30*0.33))>0.05) bad.push('the acid round dealt '+(2000-rd.hp).toFixed(2)+' through a corroded plate, want 20.1');
         rd.hp=2000; rd.armor=120; rd.corrT=0;
         shoot(rd,'');
         if(Math.abs(rd.armor-(120-30*0.66))>0.05) bad.push('a plain round soaked differently ('+rd.armor.toFixed(2)+')');
       }
       se=all.filter(function(x){ return x.kind==='sentry'&&x.hp>0; })[0];
       if(!se) return bad.length?bad.join('; '):'SKIP: no sentry on this map';
       se.hp=se.maxhp=2000; se.armor=0; se.overheat=0;
       shoot(se,''); l1=2000-se.hp;
       se.hp=2000; se.overheat=0; se.corrT=0;
       shoot(se,'acid'); l2=2000-se.hp;
       if(!(l1>0)) bad.push('the plain round missed the Sentry');
       else if(Math.abs(l2-l1*1.25)>0.5) bad.push('the acid Sentry lost '+l2.toFixed(1)+' against '+l1.toFixed(1)+', want 1.25 times');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ for(var kk in oW) WEAKPTS[kk]=oW[kk]; }catch(_w){}
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.bullets.length=0; if(g2.player){ g2.player.x=oPX; g2.player.y=oPY; } if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
