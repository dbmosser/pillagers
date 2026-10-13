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

if ($s.Contains("  {v:'25.51',what:")) { throw "check 25.51 is in the fixture already" }

SubRx @'
  {v:'25.50',what:
'@ @'
  {v:'25.51',what:'his answer 37 a: light blood from pillagers and players only: a hit player and a shot pillager bleed, a shot machine sparks',
   run:function(){
     var bad=[], g, p, s0, d0, cw, e, r, i, k, ux=0, uy=0, a8, ca, sa, sv=null, rx, ry;
     function bl(from){ var n=0, j; for(j=from;j<g.sparks.length;j++) if(g.sparks[j].c==='#b3241b') n++; return n; }
     function shoot(t){ g.bullets.length=0; s0=g.sparks.length; t.x=p.x+ux*110; t.y=p.y+uy*110; t.hp=t.maxhp=5000; t.roll=0;
       g.bullets.push({x:p.x+ux*30,y:p.y+uy*30,vx:1180*ux,vy:1180*uy,dmg:5,life:1,player:true,owner:p,tint:'#ffd48a',thru:0});
       for(k=0;k<6;k++) updateBullets(0.016); g.bullets.length=0; return bl(s0); }
     try{
       __topClear(); __runPrep(); __resetCfg();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       p.iv=0; p.armor=0; p.downed=false; p.hp=100;
       s0=g.sparks.length; d0=g.puffs.length;
       damagePlayer(12,'sentry','T',p.x+200,p.y);
       if(!bl(s0)) bad.push('a hit player does not bleed');
       if(!(g.puffs.length>d0)) bad.push('no blood mist on a hit player');
       if(bl(s0)>8) bad.push('a 12 point hit sprays '+bl(s0)+' drops, not light');
       p.hp=100; p.iv=0;
       for(k=0;k<8&&!ux&&!uy;k++){ a8=k*0.7854; ca=Math.cos(a8); sa=Math.sin(a8); if(losClear(p.x,p.y,p.x+ca*200,p.y+sa*200,g.map.segs)){ ux=ca; uy=sa; } }
       if(!ux&&!uy) return bad.length?bad.join('; '):'SKIP: walls all round the drop';
       cw=mkCrawler(0,0); g.ents.push(cw);
       if(shoot(cw)) bad.push('a shot machine bleeds');
       g.ents.splice(g.ents.indexOf(cw),1);
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc){ r=g.ents[i]; break; }
       if(!r) return bad.length?bad.join('; '):'SKIP: no pillager on the map';
       sv={x:r.x,y:r.y,hp:r.hp,maxhp:r.maxhp,hostile:r.hostile,state:r.state,alert:r.alert};
       if(!shoot(r)) bad.push('a shot pillager does not bleed');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(sv&&r){ for(var q in sv) r[q]=sv[q]; } }catch(_r){}
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; } }catch(_p){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
