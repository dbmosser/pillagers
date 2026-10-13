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

if ($s.Contains("  {v:'25.24',what:")) { throw "check 25.24 is in the fixture already" }

SubRx @'
  {v:'25.23',what:
'@ @'
  {v:'25.24',what:'forge5: cryo chills a body to 60 percent speed, five hits of 30 freeze it, a frozen body neither moves nor fires, no refreeze inside the immunity, and the cold runs off with the chill',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof elemHit!=='function'||typeof moveToward!=='function') return 'SKIP: no raid or elemental rounds here';
     var bad=[], g, p, all=null, oPX, oPY, A, rd, X0, Y0, dx=1, dy=0, k, ok=false, x0, y0, m1, m2, f1, mine;
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); oPX=p.x; oPY=p.y; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ var ux=Math.cos(k*0.7854), uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*180,Y0+uy*180,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       A=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed; })[0];
       if(!A) return 'SKIP: no crawler on this map';
       g.ents=[A]; A.hp=A.maxhp=2000; A.chill=0; A.chillT=0; A.frozenT=0; A.freezeImm=0;
       A.x=X0; A.y=Y0; moveToward(A,X0+dx*500,Y0+dy*500,100,0.1); m1=Math.hypot(A.x-X0,A.y-Y0);
       if(Math.abs(m1-10)>0.05) bad.push('a plain step of 10 moved '+m1.toFixed(2));
       elemHit(A,'cryo',30,0,p.x,p.y);
       if(!(A.chillT>0)) bad.push('a cryo hit did not chill');
       A.x=X0; A.y=Y0; moveToward(A,X0+dx*500,Y0+dy*500,100,0.1); m2=Math.hypot(A.x-X0,A.y-Y0);
       if(Math.abs(m2-6)>0.05) bad.push('a chilled step of 10 moved '+m2.toFixed(2)+', want 6');
       A.x=X0; A.y=Y0;
       for(k=0;k<4;k++) elemHit(A,'cryo',30,0,p.x,p.y);
       if(!(A.frozenT>0)) bad.push('five cryo hits of 30 did not freeze (cold '+A.chill+')');
       if(A.chill!==0) bad.push('the cold did not reset on the freeze ('+A.chill+')');
       A.state='chase'; A.alert=3; A.tx=X0+dx*300; A.ty=Y0+dy*300; x0=A.x; y0=A.y;
       __ents(0.2);
       if(Math.hypot(A.x-x0,A.y-y0)>0.01) bad.push('the frozen crawler moved '+Math.hypot(A.x-x0,A.y-y0).toFixed(1));
       f1=A.frozenT;
       for(k=0;k<6;k++) elemHit(A,'cryo',30,0,p.x,p.y);
       if(A.frozenT>f1+1e-9) bad.push('cryo hits inside the immunity froze it again');
       elemTick(3);
       if(A.chill!==0||A.chillT!==0) bad.push('the cold did not run off with the chill ('+A.chill+', '+A.chillT+')');
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed; })[0];
       if(rd){
         g.ents=[rd]; rd.x=X0+dx*120; rd.y=Y0+dy*120; rd.hp=rd.maxhp=2000; rd.armor=0; rd.hostile=true; rd.state='chase'; rd.alert=3;
         rd.tx=p.x; rd.ty=p.y; rd.cd=0; rd.roll=0; rd.rollCd=9; rd.chill=0; rd.freezeImm=0; rd.frozenT=0; rd.seenYou=1;
         for(k=0;k<5;k++) elemHit(rd,'cryo',30,0,p.x,p.y);
         if(!(rd.frozenT>0)) bad.push('a pillager did not freeze');
         g.bullets.length=0; x0=rd.x; y0=rd.y;
         for(k=0;k<4;k++) __ents(0.1);
         mine=g.bullets.filter(function(b){ return b.owner===rd; }).length;
         if(mine) bad.push('a frozen pillager fired '+mine+' rounds');
         if(Math.hypot(rd.x-x0,rd.y-y0)>0.01) bad.push('a frozen pillager moved');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.bullets.length=0; if(g2.player){ g2.player.x=oPX; g2.player.y=oPY; } if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
