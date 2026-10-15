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

if ($s.Contains("  {v:'27.05',what:")) { throw "check 27.05 is in the fixture already" }

SubRx @'
  {v:'27.04',what:
'@ @'
  {v:'27.05',what:'his answer 30: red explosive barrels with a big white !, several in every raid on open floor, placed on a side stream, a round sets one off, the blast hurts what is near and sets off the next in a chain',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof updateBullets!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, i, k, pos=[], pos2=[], A, B, e, eh, ph, sds=[4242,9071], si, ux=0, uy=0, a8, ca, sa;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       for(si=0;si<sds.length;si++){
         __deploy({kit:[],safe:null,mapIx:0,seed:sds[si]});
         g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
         if(!Array.isArray(g.brl)){ bad.push('seed '+sds[si]+': a raid has no barrel list'); __endRaid('abandon'); __topClear(); continue; }
         if(g.brl.length<8) bad.push('seed '+sds[si]+': only '+g.brl.length+' barrels on the map');
         for(i=0;i<g.brl.length;i++){ if(Math.hypot(g.brl[i].x-p.x,g.brl[i].y-p.y)<450) bad.push('seed '+sds[si]+': a barrel at the drop'); if(si===0) pos.push(Math.round(g.brl[i].x)+','+Math.round(g.brl[i].y)); }
         __endRaid('abandon'); __topClear();
       }
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player;
       if(!Array.isArray(g.brl)) return bad.length?bad.join('; '):'a raid has no barrel list';
       for(i=0;i<g.brl.length;i++) pos2.push(Math.round(g.brl[i].x)+','+Math.round(g.brl[i].y));
       if(pos.join(';')!==pos2.join(';')) bad.push('the same seed placed the barrels differently');
       for(k=0;k<8&&!ux&&!uy;k++){ a8=k*0.7854; ca=Math.cos(a8); sa=Math.sin(a8); if(losClear(p.x,p.y,p.x+ca*260,p.y+sa*260,g.map.segs)&&losClear(p.x-sa*20,p.y+ca*20,p.x+ca*260-sa*20,p.y+sa*260+ca*20,g.map.segs)){ ux=ca; uy=sa; } }
       if(!ux&&!uy) return bad.length?bad.join('; '):'SKIP: walls all round the drop';
       g.brl=[]; A={id:0,x:p.x+ux*120,y:p.y+uy*120+10,hp:BRL_HP,fuse:-1,by:-1,gone:0}; B={id:1,x:p.x+ux*165,y:p.y+uy*165+10,hp:BRL_HP,fuse:-1,by:-1,gone:0}; g.brl.push(A,B);
       e=mkCrawler(p.x+ux*200-uy*20,p.y+uy*200+ux*20); e.hp=e.maxhp=900; g.ents.push(e); eh=e.hp;
       p.iv=0; p.armor=0; p.downed=false; p.hp=100; ph=p.hp;
       g.bullets.length=0;
       g.bullets.push({x:p.x+ux*30,y:p.y+uy*30+10,vx:1180*ux,vy:1180*uy,dmg:200,life:1,player:true,owner:p,tint:'#ffd48a',thru:0});
       for(k=0;k<6;k++) updateBullets(0.016);
       if(!(A.fuse>=0||A.gone)) bad.push('a round into the barrel did not set it off');
       if(B.fuse>=0||B.gone) bad.push('the round went through the first barrel');
       for(k=0;k<40;k++) brlTick(0.02);
       if(!A.gone) bad.push('the lit barrel never went up');
       if(!B.gone) bad.push('the barrel beside it did not go up in the chain');
       if(!(e.hp<eh)) bad.push('a machine 80 from the blast took nothing');
       if(!(p.hp<ph)) bad.push('the player 120 from the blast took nothing');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; g2.player.dying=false; g2.deathBeat=null; } }catch(_p){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
